#!/bin/bash

sudo apt update
sudo apt install -y python3-venv python3-pip git

mkdir ~/api-gateway
cd ~/api-gateway

python3 -m venv venv
source venv/bin/activate

pip install fastapi uvicorn requests