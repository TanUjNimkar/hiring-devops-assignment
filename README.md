DevOps Internship Assignment Overview

This project deploys a distributed worker-based inference architecture on AWS using Terraform.

The deployment includes:

Public API Gateway VM Internal caller-worker VM Internal inference-worker VM Private RPC communication over VPC networking Public JSON API exposure

Infrastructure provisioning and deployment are fully reproducible using Terraform.

Architecture Internet | v +----------------+ | API Gateway | | Public VM | | 52.66.197.75 | +----------------+ | Internal VPC Traffic | v +----------------+ | caller-worker | | Internal VM | | 10.0.1.101 | +----------------+ | Internal RPC | v +-------------------+ | inference-worker | | Internal VM | | 10.0.1.136 | +-------------------+ Infrastructure

Provisioned using:

Terraform AWS EC2 AWS VPC Security Groups Public & Private Networking

Infrastructure components:

Custom VPC Public subnet Internal worker isolation Security groups SSH key provisioning Multi-VM deployment Repository Structure infra/ ├── provider.tf ├── network.tf ├── security.tf ├── compute.tf ├── outputs.tf

scripts/ ├── setup-api.sh ├── setup-caller.sh ├── setup-inference.sh

.gitignore README.md Deployment Instructions

    Clone Repository git clone cd
    Initialize Terraform cd infra terraform init
    Validate Configuration terraform validate
    Deploy Infrastructure terraform apply

Type:

yes

Terraform will provision:

VPC Subnet Security Groups EC2 Instances Networking configuration Worker Setup

Run deployment scripts on corresponding VMs:

bash scripts/setup-api.sh bash scripts/setup-caller.sh bash scripts/setup-inference.sh API Usage Endpoint POST /infer curl Command curl -X POST http://52.66.197.75:8000/infer
-H "Content-Type: application/json"
-d '{"prompt":"hello"}' Sample Response { "prompt": "hello", "response": "Inference pipeline connected successfully" } Worker Details caller-worker

Private IP:

10.0.1.101

Stack:

Node.js TypeScript iii-sdk inference-worker

Private IP:

10.0.1.136

Stack:

Python Transformers CPU-only PyTorch Security Design

Implemented security measures:

Only API VM is publicly accessible Workers are reachable only through private VPC networking SSH access restricted via security groups Internal RPC communication over private IPs Worker isolation enforced through networking rules Production Improvements

Before production deployment, I would additionally implement:

HTTPS/TLS termination NAT Gateway for private worker outbound access Application Load Balancer Auto Scaling Groups IAM least-privilege policies CloudWatch logging & monitoring CI/CD pipeline Secrets Manager integration Health checks & worker supervision Docker containerization ECS/Kubernetes orchestration Scaling Considerations

If the model size increased significantly:

Use GPU-enabled EC2 instances Deploy distributed inference architecture Use Kubernetes for orchestration Use optimized runtimes like: vLLM Text Generation Inference (TGI) Add autoscaling Introduce queue-based request handling Separate orchestration and inference layers Notes CPU-only PyTorch wheels were used to reduce unnecessary CUDA dependencies. Worker instances use larger gp3 volumes due to dependency and model size requirements. Internal worker communication was validated through private VPC networking. Infrastructure deployment and teardown are fully reproducible using Terraform. Cleanup

To destroy infrastructure:

terraform destroy .gitignore .terraform/ *.tfstate *.tfstate.backup node_modules/ venv/