# DevOps Internship Assignment — Distributed Inference Architecture on AWS

## Overview

This project deploys a distributed worker-based inference architecture on AWS using Terraform. It exposes a public JSON API that routes inference requests through a private RPC chain of internal worker VMs, all isolated within a custom VPC.

---

## Architecture

```
         Internet
             |
             v
   +------------------+
   |   API Gateway    |
   |   Public VM      |
   |  52.66.197.75    |
   +------------------+
             |
      Internal VPC Traffic
             |
             v
   +------------------+
   |  caller-worker   |
   |  Internal VM     |
   |  10.0.1.101      |
   +------------------+
             |
       Internal RPC
             |
             v
   +--------------------+
   | inference-worker   |
   | Internal VM        |
   | 10.0.1.136         |
   +--------------------+
```

**Request Flow:**
1. Client sends `POST /infer` to the public API Gateway VM
2. API Gateway forwards the request internally to the **caller-worker** (Node.js/TypeScript)
3. caller-worker calls the **inference-worker** (Python/PyTorch) over private VPC networking
4. The inference result is returned back up the chain to the client

---

## Infrastructure

Provisioned entirely with Terraform on AWS:

- Custom VPC with public and private subnets
- EC2 instances (1 public, 2 internal)
- Security groups enforcing public/private access rules
- SSH key provisioning
- `gp3` EBS volumes (sized for model dependencies)

---

## Repository Structure

```
infra/
├── provider.tf         # AWS provider + region config
├── network.tf          # VPC, subnets, routing
├── security.tf         # Security groups
├── compute.tf          # EC2 instance definitions
└── outputs.tf          # Public IP, private IPs

scripts/
├── setup-api.sh        # Bootstrap API Gateway VM
├── setup-caller.sh     # Bootstrap caller-worker VM
└── setup-inference.sh  # Bootstrap inference-worker VM

README.md
.gitignore
```

---

## Deployment Instructions

### Prerequisites

- Terraform >= 1.3
- AWS CLI configured (`aws configure`) with sufficient IAM permissions
- An SSH key pair (or let Terraform generate one)

### 1. Clone the Repository

```bash
git clone <repo-url>
cd <repo-directory>
```

### 2. Initialize Terraform

```bash
cd infra
terraform init
```

### 3. Validate Configuration

```bash
terraform validate
```

### 4. Deploy Infrastructure

```bash
terraform apply
```

Type `yes` when prompted. Terraform will provision:
- VPC and subnets
- Security groups
- EC2 instances
- All networking configuration

> **Note:** Save the output values — you will need the public IP and private IPs for the next steps.

### 5. Run Worker Setup Scripts

SSH into each VM and run the corresponding setup script:

```bash
# On the API Gateway VM (public IP from Terraform output)
bash scripts/setup-api.sh

# On the caller-worker VM (10.0.1.101, reached via API VM or bastion)
bash scripts/setup-caller.sh

# On the inference-worker VM (10.0.1.136)
bash scripts/setup-inference.sh
```

---

## API Usage

### Endpoint

```
POST /infer
Host: 52.66.197.75:8000
Content-Type: application/json
```

### Example Request

```bash
curl -X POST http://52.66.197.75:8000/infer \
  -H "Content-Type: application/json" \
  -d '{"prompt":"hello"}'
```

### Example Response

```json
{
  "prompt": "hello",
  "response": "Inference pipeline connected successfully"
}
```

---

## Worker Details

### caller-worker

| Property   | Value       |
|------------|-------------|
| Private IP | 10.0.1.101  |
| Runtime    | Node.js     |
| Language   | TypeScript  |
| SDK        | iii-sdk     |

Receives requests from the API Gateway and forwards them to the inference-worker via internal RPC.

### inference-worker

| Property   | Value                        |
|------------|------------------------------|
| Private IP | 10.0.1.136                   |
| Runtime    | Python                       |
| Libraries  | Transformers, PyTorch (CPU)  |

Runs the actual model inference and returns results upstream. CPU-only PyTorch wheels are used to avoid unnecessary CUDA dependencies.

---

## Security Design

| Control | Implementation |
|---------|---------------|
| Public exposure | Only the API Gateway VM has a public IP |
| Worker isolation | caller-worker and inference-worker are in a private subnet with no public IP |
| Internal communication | All RPC traffic stays within the VPC on private IPs |
| SSH access | Restricted via security group rules (specific CIDR or key-based) |
| Internet access for workers | Not configured (no NAT Gateway in this MVP) |

---

## Debugging & Troubleshooting

### API not responding?

```bash
# Check EC2 status from Terraform output
terraform output

# SSH into API VM and check service
ssh -i ~/.ssh/devops-key ec2-user@52.66.197.75
systemctl status nodejs-api
journalctl -u nodejs-api -n 50
```

- Confirm the API Gateway VM is running (EC2 console or `terraform output`)
- Verify port `8000` is open in the security group for inbound traffic

### Inference returning errors?

```bash
# Hop from API VM to caller-worker
ssh ubuntu@10.0.1.101

# Check inference-worker health
curl http://10.0.1.136:<port>/health
```

- Check logs on each worker VM
- Verify the inference-worker is reachable from the caller-worker

### Terraform apply fails?

```bash
terraform validate
terraform plan
```

- Ensure your AWS credentials have EC2, VPC, and IAM permissions
- Check that `terraform.tfstate` is not corrupted

---

## Cleanup

To destroy all provisioned infrastructure:

```bash
cd infra
terraform destroy
```

Type `yes` when prompted. This removes all EC2 instances, VPC resources, and security groups.

---

## Production Improvements

The following would be added before a production deployment:

**Security & Networking**
- HTTPS/TLS termination (ACM + ALB)
- NAT Gateway for private worker outbound access
- IAM least-privilege policies
- Secrets Manager for credentials

**Reliability & Observability**
- Application Load Balancer
- Auto Scaling Groups
- CloudWatch logging and monitoring
- Health checks and worker supervision

**Deployment & Operations**
- CI/CD pipeline (GitHub Actions / CodePipeline)
- Docker containerization
- ECS or Kubernetes orchestration

---

## Scaling Considerations

If the model size increases significantly:

- Switch to GPU-enabled EC2 instances (e.g., `g4dn` family)
- Use optimized inference runtimes: **vLLM** or **Text Generation Inference (TGI)**
- Deploy a distributed inference architecture across multiple GPUs/nodes
- Use **Kubernetes** for orchestration and autoscaling
- Introduce queue-based request handling (**SQS**) to decouple ingestion from inference
- Separate orchestration and inference layers for independent scaling

---

## Notes

- CPU-only PyTorch wheels are used intentionally to reduce image size and avoid unnecessary CUDA dependencies.
- Worker instances use `gp3` volumes sized to accommodate Python dependency and model weight storage requirements.
- Internal worker communication was validated through private VPC networking — no public internet path exists between workers.
- Infrastructure deployment and teardown are fully reproducible via Terraform with no manual AWS console steps.

---

## .gitignore

```gitignore
.terraform/
*.tfstate
*.tfstate.backup
*.tfvars
.terraform.lock.hcl
node_modules/
venv/
__pycache__/
*.pyc
*.pem
*.key
.env
.DS_Store
```
