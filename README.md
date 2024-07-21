
## Requirements


- You must need to buy a VPS for running Allora Node
- You can buy from : [Contabo]([https://pq.hosting/en/vps](https://www.anrdoezrs.net/click-101219450-13796470))
- - You should buy VPS which is fulfilling all these requirements : 
```bash
Operating System : Ubuntu 22.04
CPU : Minimum of 1/2 core
RAM : 2 to 4 GB
Storage : SSD or NVMe with at least 5GB of space
```
## Create Wallet & Request Faucet

- Install : [Leap Extension](https://chromewebstore.google.com/detail/leap-cosmos-wallet/fcfcfllfndlomdhbehjjcoimbgofdncg)
- Create a new Wallet
- Visit : [Allora Website](https://app.allora.network?ref=eyJyZWZlcnJlcl9pZCI6ImY2ZDJjMzU0LTdmM2UtNDg3My05ZGExLWExNThmZDViZTZmMyJ9)
- Copy your allora address from here
- Visit and Request faucet : [Allora Faucet](https://faucet.testnet-1.testnet.allora.network/)
- If there is an error, try 3-5 times

 ## Deployment Part 1
```
wget https://raw.githubusercontent.com/ibuyshite/Allora-Node/main/allora.sh && chmod +x allora.sh && ./allora.sh
```
Copy the head-id and keep it in notepad (copy before rootxxx as heighlighted)
```
cat head-data/keys/identity
```
![image](https://github.com/papaperez1/Allora/assets/118633093/0fe235f7-18d1-458f-9b46-c334583be6ad)
### Run the worker node
```
rm -rf docker-compose.yml && nano docker-compose.yml
```
Copy & Paste the following code in it
Replace `head-id` & `WALLET_SEED_PHRASE`
```
version: '3'

services:
  inference:
    container_name: inference-basic-eth-pred
    build:
      context: .
    command: python -u /app/app.py
    ports:
      - "8000:8000"
    networks:
      eth-model-local:
        aliases:
          - inference
        ipv4_address: 172.22.0.4
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/inference/ETH"]
      interval: 10s
      timeout: 5s
      retries: 12
    volumes:
      - ./inference-data:/app/data

  updater:
    container_name: updater-basic-eth-pred
    build: .
    environment:
      - INFERENCE_API_ADDRESS=http://inference:8000
    command: >
      sh -c "
      while true; do
        python -u /app/update_app.py;
        sleep 24h;
      done
      "
    depends_on:
      inference:
        condition: service_healthy
    networks:
      eth-model-local:
        aliases:
          - updater
        ipv4_address: 172.22.0.5

  worker:
    container_name: worker-basic-eth-pred
    environment:
      - INFERENCE_API_ADDRESS=http://inference:8000
      - HOME=/data
    build:
      context: .
      dockerfile: Dockerfile_b7s
    entrypoint:
      - "/bin/bash"
      - "-c"
      - |
        if [ ! -f /data/keys/priv.bin ]; then
          echo "Generating new private keys..."
          mkdir -p /data/keys
          cd /data/keys
          allora-keys
        fi
        # Change boot-nodes below to the key advertised by your head
        allora-node --role=worker --peer-db=/data/peerdb --function-db=/data/function-db \
          --runtime-path=/app/runtime --runtime-cli=bls-runtime --workspace=/data/workspace \
          --private-key=/data/keys/priv.bin --log-level=debug --port=9011 \
          --boot-nodes=/ip4/172.22.0.100/tcp/9010/p2p/head-id \
          --topic=allora-topic-1-worker \
          --allora-chain-key-name=testkey \
          --allora-chain-restore-mnemonic='WALLET_SEED_PHRASE' \
          --allora-node-rpc-address=https://allora-rpc.testnet-1.testnet.allora.network/ \
          --allora-chain-topic-id=1
    volumes:
      - ./worker-data:/data
    working_dir: /data
    depends_on:
      - inference
      - head
    networks:
      eth-model-local:
        aliases:
          - worker
        ipv4_address: 172.22.0.10

  head:
    container_name: head-basic-eth-pred
    image: alloranetwork/allora-inference-base-head:latest
    environment:
      - HOME=/data
    entrypoint:
      - "/bin/bash"
      - "-c"
      - |
        if [ ! -f /data/keys/priv.bin ]; then
          echo "Generating new private keys..."
          mkdir -p /data/keys
          cd /data/keys
          allora-keys
        fi
        allora-node --role=head --peer-db=/data/peerdb --function-db=/data/function-db  \
          --runtime-path=/app/runtime --runtime-cli=bls-runtime --workspace=/data/workspace \
          --private-key=/data/keys/priv.bin --log-level=debug --port=9010 --rest-api=:6000
    ports:
      - "6000:6000"
    volumes:
      - ./head-data:/data
    working_dir: /data
    networks:
      eth-model-local:
        aliases:
          - head
        ipv4_address: 172.22.0.100


networks:
  eth-model-local:
    driver: bridge
    ipam:
      config:
        - subnet: 172.22.0.0/24

volumes:
  inference-data:
  worker-data:
  head-data:
```
Build and run the image
```
docker compose build
docker compose up -d
```
```
docker ps
```
copy the container ID of the worker and run the below command
![image](https://github.com/papaperez1/Allora/assets/118633093/c165c1f2-a357-4572-97ba-a545acc08f6e)

```
docker logs -f CONTAINER_ID
```
![image](https://github.com/papaperez1/Allora/assets/118633093/72dd4f6e-a10a-43c8-afd7-ef862d281dd2)

### Check node status
```
apt install jq
```
```
network_height=$(curl -s -X 'GET' 'https://allora-rpc.testnet-1.testnet.allora.network/abci_info?' -H 'accept: application/json' | jq -r .result.response.last_block_height) && \
curl --location 'http://localhost:6000/api/v1/functions/execute' --header 'Content-Type: application/json' --data '{
    "function_id": "bafybeigpiwl3o73zvvl6dxdqu7zqcub5mhg65jiky2xqb4rdhfmikswzqm",
    "method": "allora-inference-function.wasm",
    "parameters": null,
    "topic": "1",
    "config": {
        "env_vars": [
            {
                "name": "BLS_REQUEST_PATH",
                "value": "/api"
            },
            {
                "name": "ALLORA_ARG_PARAMS",
                "value": "ETH"
            },
            {
                "name": "ALLORA_BLOCK_HEIGHT_CURRENT",
                "value": "'"${network_height}"'"
            }
        ],
        "number_of_nodes": -1,
        "timeout": 10
    }
}' | jq
```
Response:
![image](https://github.com/user-attachments/assets/e48a687c-28ec-499d-bcb2-f6fe3bee3681)


### Step to Restart docker containers for Troubleshooting

```
docker compose down
```
```
docker compose up -d
```

References: 
https://docs.allora.network/
https://github.com/0xmoei/allora-testnet/edit/main/README.md


