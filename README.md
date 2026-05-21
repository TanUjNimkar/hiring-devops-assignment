# DevOps Internship Assignment

## Overview

This project deploys a distributed worker-based inference architecture on AWS using Terraform.

The deployment includes:

- Public API Gateway VM
- Internal caller-worker VM
- Internal inference-worker VM
- Internal worker communication over VPC networking
- Public JSON API exposure

The infrastructure and deployment are fully reproducible using Terraform.

---

# Architecture

```text
                     Internet
                         |
                         v
                +----------------+
                |   API Gateway  |
                |   Public VM    |
                | 52.66.197.75   |
                +----------------+
                         |
               Internal VPC Traffic
                         |
                         v
                +----------------+
                | caller-worker  |
                | Internal VM    |
                | 10.0.1.101     |
                +----------------+
                         |
                    Internal RPC
                         |
                         v
                +-------------------+
                | inference-worker  |
                | Internal VM       |
                | 10.0.1.136        |
                +-------------------+

Infrastructure

Provisioned using:

    Terraform
    AWS EC2
    AWS VPC
    Security Groups
    Public and Internal Networking

Infrastructure includes:

    Custom VPC
    Public subnet
    Worker isolation
    Security group configuration
    SSH key provisioning
    Multi-VM deployment

Terraform Deployment

Initialize Terraform:
terraform init

Validate configuration:
terraform validate

Deploy infrastructure:
terraform apply

API Usage
Endpoint


POST /infer
Example Request

PowerShell:
Invoke-RestMethod `
  -Uri "http://52.66.197.75:8000/infer" `
  -Method POST `
  -ContentType "application/json" `
  -Body '{"prompt":"hello"}'

  Example Response

JSON

{
  "prompt": "hello",
  "response": "Inference pipeline connected successfully"
}

Worker Deployment
caller-worker

Runs on:

text

10.0.1.101

Technology stack:

    Node.js
    TypeScript
    iii-sdk

inference-worker

Runs on:

text

10.0.1.136

Technology stack:

    Python
    Transformers
    CPU-only PyTorch

Security Design

Implemented security measures:

    Only API VM exposes public traffic
    Worker communication restricted to internal VPC networking
    SSH access restricted using security groups
    Internal worker isolation
    RPC communication over private IP addresses

Deployment Scripts

Automation scripts are available under:

text

scripts/

Included scripts:

    setup-api.sh
    setup-caller.sh
    setup-inference.sh

These scripts automate dependency installation and environment setup.
Production Improvements

Before production deployment, I would additionally implement:

    NAT Gateway for private worker outbound access
    HTTPS and TLS termination
    Application Load Balancer
    Auto Scaling Groups
    IAM least-privilege policies
    CloudWatch logging and monitoring
    CI/CD pipeline
    Secret management using AWS Secrets Manager
    Health checks and worker supervision
    Containerization with Docker
    Kubernetes/ECS deployment for orchestration

Scaling Considerations

If the model size increased significantly:

    Use GPU-enabled EC2 instances
    Use model sharding and distributed inference
    Deploy using Kubernetes
    Use optimized inference runtimes such as:
        vLLM
        Text Generation Inference (TGI)
    Separate inference and orchestration layers
    Add autoscaling and queue-based request handling

Notes

    CPU-only PyTorch wheels were used to avoid unnecessary CUDA dependencies.
    Worker instances were provisioned with larger gp3 volumes due to dependency size requirements.
    Internal communication between worker nodes was validated through VPC networking.
    Infrastructure deployment and teardown are fully reproducible through Terraform.

Repository Structure

text

infra/
├── provider.tf
├── network.tf
├── security.tf
├── compute.tf
├── outputs.tf

scripts/
├── setup-api.sh
├── setup-caller.sh
├── setup-inference.sh

Notes

    CPU-only PyTorch wheels were used to reduce storage usage.
    Worker instances were provisioned with larger gp3 volumes due to model dependency size.
    Internal worker communication was validated through private VPC networking.

text


==================================================
CREATE .gitignore
==================================================

```gitignore
.terraform/
*.tfstate
*.tfstate.backup
node_modules/
venv/