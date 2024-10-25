#!/bin/bash

NODENAME="DRIA"
GREENCOLOR="\e[32m"
DEFAULTCOLOR="\e[0m"

setup() {
    curl -s https://raw.githubusercontent.com/Widiskel/Widiskel/refs/heads/main/show_logo.sh | bash
    sleep 3

    echo "Updating & Upgrading Packages..."
    sudo apt update -y && sudo apt upgrade -y
    if ! command -v screen &> /dev/null; then
        echo "Installing Screen..."
        sudo apt install -y screen
        echo "Screen installed successfully."
    else
        echo "Screen is already installed."
    fi

    cd ~
    if [ -d "node" ]; then
        echo "The 'node' directory already exists."
    else
        mkdir node
        echo "Created the 'node' directory."
    fi
    cd node

    mkdir dria && cd dria
}

dockerSetup(){
    if ! command -v docker &> /dev/null; then
        echo "Installing Docker..."
        for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
            sudo apt-get remove -y $pkg
        done

        sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        
        sudo apt update -y && sudo apt install -y docker-ce
        sudo systemctl start docker
        sudo systemctl enable docker

        echo "Installing Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose

        echo "Docker installed successfully."
    else
        echo "Docker is already installed."
    fi
}

installRequirements(){
    echo "Installing Package Required by $NODENAME"
    sleep 2


    if ! command -v ollama &> /dev/null; then
        echo "Installing Ollama..."
        curl -fsSL https://ollama.com/install.sh | sh
        echo "Ollama Installed"
    else
        echo "Ollama is already installed."
    fi

    echo "Installing $NODENAME Compute Node"
    if [ ! -d "dkn-compute-node" ] && [ ! -f "dkn-compute-node.zip" ]; then
        echo "Downloading dkn-compute-node.zip"
        curl -L -o dkn-compute-node.zip https://github.com/firstbatchxyz/dkn-compute-launcher/releases/latest/download/dkn-compute-launcher-linux-amd64.zip 
        echo "Unzipping dkn-compute-node.zip"
        unzip dkn-compute-node.zip 
        rm dkn-compute-node.zip 
        cd dkn-compute-node
    else
        echo "dkn-compute-node folder already exists or dkn-compute-node.zip already downloaded."
        if [ -d "dkn-compute-node" ]; then
            cd dkn-compute-node
        fi
    fi
    echo "$NODENAME Compute Node Installed"
}

finish() {
    if ! [ -f help.txt ]; then
        {
            echo "Setup Complete"
            echo ""
            echo "Follow this guide to start your node:"
            echo "To start Your Node run ./dkn-compute-launcher"
            echo "-> Enter your DKN wallet Secret key / Private Key"
            echo "-> Before picking your models, Check the team's guide https://github.com/0xmoei/Dria-Node for Recommendations"
            echo "-> Pick a Model, recommended with Gemini + Llama3_1_8B models"
            echo "-> Get Gemini APIKEY Here https://aistudio.google.com/app/apikey"
            echo "-> Get Jina API: https://jina.ai/embeddings/ (Optional Press Enter To SKIP)"
            echo "-> Get Serper API: https://serper.dev/api-key (Optional Press Enter To SKIP)"
            echo "-> DONE. Now your node will start Downloading Model files and Testing them. Each model must pass its test, and it only depends on your system specification."
            echo ""
            echo "Useful Commands:"
            echo "- Restart your Dria Node: ./dkn-compute-launcher"
            echo "- Delete your Node: cd \$HOME && rm -r dkn-compute-node"
            echo ""
            echo "To exit from this Screen press Ctrl + A + D"
        } > help.txt
    fi
    cat help.txt
}


setup
screen -S "$NODENAME" -d -m  
screen -S "$NODENAME" -X stuff "bash -c '$(typeset -f dockerSetup); $(typeset -f installRequirements); $(typeset -f finish); dockerSetup; installRequirements; finish;'"
screen -r "$NODENAME"

