#!/bin/bash

sudo apt update
sudo apt install -y git python3-venv python3-pip

git clone https://github.com/TanUjNimkar/hiring-devops-assignment.git

cd hiring-devops-assignment/may-2026/devops/quickstart/workers/inference-worker

python3 -m venv venv
source venv/bin/activate

pip install --upgrade pip

pip install torch --index-url https://download.pytorch.org/whl/cpu

pip install iii-sdk==0.11.0 watchfiles transformers gguf accelerate