#!/bin/bash

sudo apt update
sudo apt install -y git curl

curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs

git clone https://github.com/TanUjNimkar/hiring-devops-assignment.git

cd hiring-devops-assignment/may-2026/devops/quickstart/workers/caller-worker

npm install