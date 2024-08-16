
## Requirements


- You must need to buy a VPS for running Allora Node
- You can buy from : [Contabo]([https://pq.hosting/en/vps](https://www.anrdoezrs.net/click-101219450-13796470))
- Buy VPS which is fulfilling all these requirements : 
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

## Install dependecies
```console
# Install Packages
sudo apt update & sudo apt upgrade -y

sudo apt install ca-certificates zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev curl git wget make jq build-essential pkg-config lsb-release libssl-dev libreadline-dev libffi-dev gcc screen unzip lz4 -y
```
```console
# Install Python3
sudo apt install python3
python3 --version

sudo apt install python3-pip
pip3 --version
```
```console
# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
docker version

# Install Docker-Compose
VER=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)

curl -L "https://github.com/docker/compose/releases/download/"$VER"/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose
docker-compose --version

# Docker Permission to user
sudo groupadd docker
sudo usermod -aG docker $USER
```
```console
# Install Go
sudo rm -rf /usr/local/go
curl -L https://go.dev/dl/go1.22.4.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> $HOME/.bash_profile
source .bash_profile
go version
```


 ## Config HuggingFace worker
```console
cd $HOME
git clone https://github.com/allora-network/allora-huggingface-walkthrough
cd allora-huggingface-walkthrough
```
```
mkdir -p worker-data
chmod -R 777 worker-data
```
```
cp config.example.json config.json
nano config.json
```

Paste below code:
* Replace `testkey` with wallet name: `allorad keys list`
* Replace `SeedPhrase` with your wallet seed phrase
* `nodeRpc`: You can use `https://allora-testnet-rpc.polkachu.com/` or `https://beta.multi-rpc.com/allora_testnet/ `
```
{
    "wallet": {
        "addressKeyName": "testkey",
        "addressRestoreMnemonic": "SeedPhrase",
        "alloraHomeDir": "/root/.allorad",
        "gas": "1000000",
        "gasAdjustment": 1.0,
        "nodeRpc": "https://allora-rpc.testnet-1.testnet.allora.network/",
        "maxRetries": 1,
        "delay": 1,
        "submitTx": false
    },
    "worker": [
        {
            "topicId": 1,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 1,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "ETH"
            }
        },
        {
            "topicId": 2,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 3,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "ETH"
            }
        },
        {
            "topicId": 3,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 5,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "BTC"
            }
        },
        {
            "topicId": 4,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 2,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "BTC"
            }
        },
        {
            "topicId": 5,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 4,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "SOL"
            }
        },
        {
            "topicId": 6,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 5,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "SOL"
            }
        },
        {
            "topicId": 7,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 2,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "ETH"
            }
        },
        {
            "topicId": 8,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 3,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "BNB"
            }
        },
        {
            "topicId": 9,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 5,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "ARB"
            }
        }
        
    ]
}
```

CTRL+X+Y+ENTER to save and exit

## Create Coingecko API key
https://www.coingecko.com/en/developers/dashboard

* Replace Coingecko API in `app.py`

```
nano app.py
```

![Screenshot_186](https://github.com/user-attachments/assets/ad0c0192-4fb0-4708-9378-443e5adb1928)
CTRL+X+Y+Enter to save & exit

## Run Huggingface Worker
```console
chmod +x init.config
./init.config
```

```console
docker compose up --build -d
```

Logs:
```
docker compose logs -f worker
```
```
docker compose logs -f
```


