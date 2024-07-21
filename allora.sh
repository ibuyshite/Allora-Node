# Install Prerequisite
sudo su -
sudo apt update 
sudo apt upgrade -y

#Install Go
curl -OL https://go.dev/dl/go1.22.4.linux-amd64.tar.gz
tar -C /usr/local -xvf go1.22.4.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
go version

#Install Python3
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo chmod +x /usr/local/bin/docker-compose
docker compose version

#Install allocmd CLI
pip install allocmd --upgrade
allocmd --version

#Wallet Setup
curl -sSL https://raw.githubusercontent.com/allora-network/allora-chain/main/install.sh | bash -s -- v0.0.10
export PATH="$PATH:/root/.local/bin"
git clone -b v0.0.10 https://github.com/allora-network/allora-chain.git
cd allora-chain && make all
allorad version
allorad keys add testkey --recover

#Setup coin prediction worker ( reference @0xmoei)
cd $HOME && git clone https://github.com/allora-network/basic-coin-prediction-node && cd basic-coin-prediction-node
mkdir worker-data
mkdir head-data

#Create head keys
sudo docker run -it --entrypoint=bash -v ./head-data:/data alloranetwork/allora-inference-base:latest -c "mkdir -p /data/keys && (cd /data/keys && allora-keys)"

#Create worker keys
sudo docker run -it --entrypoint=bash -v ./worker-data:/data alloranetwork/allora-inference-base:latest -c "mkdir -p /data/keys && (cd /data/keys && allora-keys)"

