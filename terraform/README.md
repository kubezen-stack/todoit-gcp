# GCP Terraform Configuration

This directory contains the Terraform configuration for deploying the Jenkins project infrastructure on Google Cloud Platform (GCP).

## Migration from AWS to GCP

The following AWS resources have been migrated to their GCP equivalents:

### Networking
- **AWS VPC** → **Google Cloud VPC Network**
- **AWS Subnet** → **Google Cloud Subnet**
- **AWS Internet Gateway** → **Google Cloud Router + NAT**

### Compute
- **AWS EC2 Instance** → **Google Compute Engine Instance**
- **AWS AMI (Ubuntu 22.04)** → **Google Cloud Ubuntu 22.04 LTS Image**

### Security
- **AWS Security Groups** → **Google Cloud Firewall Rules**

## Prerequisites

1. **GCP Account**: Create a GCP project
2. **Terraform**: Install Terraform >= 1.0
3. **Google Cloud SDK**: Install and configure `gcloud` CLI
4. **Authentication**: Run `gcloud auth application-default login`

## Project Structure

```
terraform/
├── provider.tf              # GCP provider configuration
├── variables.tf             # Root-level variables
├── main.tf                  # Module composition
├── outputs.tf               # Root-level outputs
├── terraform.tfvars.example # Example variable values
├── vpc/                     # VPC network module
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── provider.tf
├── security_groups/         # Firewall rules module
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── provider.tf
└── ec2/                     # Compute instance module
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── provider.tf
```

## Configuration

1. **Create `terraform.tfvars`** from the example:
   ```bash
   cp terraform/terraform.tfvars.example terraform/terraform.tfvars
   ```

2. **Update `terraform.tfvars`** with your GCP project ID:
   ```hcl
   gcp_project_id = "your-actual-gcp-project-id"
   gcp_region     = "us-central1"  # or your preferred region
   app_zone       = "us-central1-a" # must be in the same region
   ```

## Usage

### Initialize Terraform
```bash
cd terraform
terraform init
```

### Validate Configuration
```bash
terraform validate
```

### Plan Deployment
```bash
terraform plan -out=tfplan
```

### Apply Configuration
```bash
terraform apply tfplan
```

### Destroy Resources
```bash
terraform destroy
```

## Resource Details

### VPC Network
- **CIDR Block**: 10.0.0.0/16 (configurable)
- **Region**: us-central1 (configurable)
- Includes automatic subnet creation
- Cloud NAT for outbound internet access

### Compute Instance
- **Machine Type**: e2-micro (eligible for free tier)
- **Image**: Ubuntu 22.04 LTS
- **Boot Disk**: 20GB (configurable)
- **Public IP**: Assigned automatically
- **OS Login**: Enabled for secure SSH access

### Firewall Rules
- **SSH (port 22)**: Open to all (0.0.0.0/0) - consider restricting
- **App (port 8000)**: Open to all - for FastAPI application
- **PostgreSQL (port 5432)**: Internal only (from "app" tagged instances)
- **Egress**: All outbound traffic allowed

## Key Differences from AWS

| Feature | AWS | GCP |
|---------|-----|-----|
| SSH Keys | EC2 Key Pairs | Cloud OS Login / Metadata |
| Security | Security Groups | Firewall Rules + Network Tags |
| Networking | VPC with IGW | VPC with Cloud NAT |
| Instance Selection | Instance Types | Machine Types |
| Storage | EBS Volumes | Persistent Disks |
| Images | AMIs | Machine Images |
| Pricing | Per-instance | Committed discounts available |

## Security Best Practices

1. **SSH Access**: Restrict SSH ingress to specific IP addresses:
   ```hcl
   source_ranges = ["YOUR_IP_ADDRESS/32"]
   ```

2. **IAM**: Use GCP service accounts instead of hardcoded credentials

3. **Firewall Rules**: Follow least-privilege principle for ingress rules

4. **Remote State**: Enable GCS backend for Terraform state (see provider.tf)

## Troubleshooting

### Authentication Error
```bash
gcloud auth application-default login
```

### Instance Not Accessible
1. Verify firewall rules: `gcloud compute firewall-rules list`
2. Check instance status: `gcloud compute instances list`
3. Verify SSH keys/OS Login: `gcloud compute instances describe INSTANCE_NAME --zone=ZONE`

### Quota Exceeded
Check your GCP quotas: `gcloud compute project-info describe --project=PROJECT_ID`

## Cost Estimation

Use the [GCP Pricing Calculator](https://cloud.google.com/products/calculator) to estimate costs.

Free tier includes:
- 1 e2-micro VM (up to 730 hours/month)
- 30GB standard persistent disk
- 1GB of outbound bandwidth/month

## References

- [GCP Terraform Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Terraform on GCP Best Practices](https://cloud.google.com/docs/terraform)
- [Google Cloud VM Instances](https://cloud.google.com/compute/docs/instances)