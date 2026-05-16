# OS Login Configuration Guide

This project has been updated to use **OS Login** instead of SSH keys for all infrastructure access.

## Changes Made

### 1. **Terraform** (`terraform/`)
- ✅ Enabled OS Login on EC2 instances (`enable-oslogin = "TRUE"`)
- ✅ Removed SSH key management from instance metadata
- ✅ Removed SSH key secret variables
- ✅ Updated firewall rules to use Cloud IAP IP ranges (`35.235.240.0/20`) instead of `0.0.0.0/0`

### 2. **Ansible** (`ansible/`)
- ✅ Updated inventory to use instance names instead of IP addresses
- ✅ Added `ansible.cfg` for OS Login SSH configuration
- ✅ Removed dependency on SSH private keys from Secret Manager
- ✅ Created `ssh_config.template` for reference

### 3. **Jenkinsfile**
- ✅ Removed SSH key retrieval from Secret Manager
- ✅ Updated Ansible stage to use OS Login authentication
- ✅ Simplified Ansible playbook invocation

## Prerequisites for Your Team

### Local Setup
Each team member needs:
1. **gcloud CLI** installed and authenticated:
   ```bash
   gcloud init
   gcloud auth login
   ```

2. **Ansible** installed:
   ```bash
   pip install ansible google-cloud-compute
   ```

3. **SSH key pair** (for local authentication, not used for VM access):
   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
   ```

### Google Cloud Setup
1. **OS Login enabled** at project level (already configured via Terraform)
2. **IAM roles** assigned to users/service accounts:
   - `roles/compute.osLogin` — allows SSH access via OS Login
   - `roles/compute.osAdminLogin` — allows sudo access
   - `roles/compute.instanceAdmin.v1` — allows managing instances

3. **Service Account** created with proper permissions (already configured via Terraform)

## How It Works Now

### Before (SSH Keys)
```
Jenkins → Retrieve SSH key from Secret Manager → SSH into VM with key
Team member → Local SSH key file → SSH into VM manually
```

### After (OS Login)
```
Jenkins → gcloud auth (service account) → OS Login → SSH into VM (no keys)
Team member → gcloud auth (Google account) → OS Login → SSH into VM (no keys)
```

## Testing OS Login Access

### Verify Setup
```bash
# Check if OS Login is enabled on instances
gcloud compute instances describe jenkins-project-dev-app-instance \
  --zone=us-central1-a \
  --format='value(metadata[enable-oslogin])'
# Should return: TRUE
```

### Test Access
```bash
# SSH via gcloud (OS Login)
gcloud compute ssh jenkins-project-dev-app-instance \
  --zone=us-central1-a \
  --project=todo-app-496222

# Or for Jenkins instance
gcloud compute ssh jenkins-project-dev-jenkins-instance \
  --zone=us-central1-a \
  --project=todo-app-496222
```

### Test Ansible
```bash
cd ansible

# Test inventory (should list your instances)
ansible-inventory -i inventory/gcp_compute.yml --list

# Test connectivity
ansible all -i inventory/gcp_compute.yml -m ping

# Run playbook
ansible-playbook -i inventory/gcp_compute.yml playbook.yml
```

## Jenkins Configuration

The Jenkins pipeline now:
1. Uses service account authentication (GOOGLE_APPLICATION_CREDENTIALS)
2. Applies Terraform without SSH keys
3. Runs Ansible playbook using OS Login via gcloud

No changes needed to Jenkins credentials for SSH keys.

## Cloud IAP (Advanced - Optional)

For even more security, you can add Cloud IAP:

```bash
# Tunnel through IAP instead of exposing SSH
gcloud compute ssh jenkins-project-dev-app-instance \
  --zone=us-central1-a \
  --tunnel-through-iap

# Then remove SSH firewall rule entirely
```

## Troubleshooting

### "Permission denied (publickey)"
- Verify your user has `roles/compute.osLogin` in the project
- Run: `gcloud compute os-login describe-profile`
- Ensure SSH key check is disabled in ansible.cfg

### "Cannot find instance"
- Verify instance exists: `gcloud compute instances list`
- Check zone matches: `--zone=us-central1-a`
- Confirm labels match inventory filter: `--filter="labels.project=jenkins-project"`

### Ansible "Failed to connect"
- Run `ansible-inventory -i inventory/gcp_compute.yml --list` to check inventory
- Verify gcloud is authenticated: `gcloud auth list`
- Check firewall allows port 22 from IAP range

## Benefits

| Feature | SSH Keys | OS Login |
|---------|----------|----------|
| Key Management | Manual | Automatic (IAM-based) |
| Team Access | Distribute keys | Add IAM role |
| Audit Trail | Limited | Full (Cloud Audit Logs) |
| Access Revocation | Manual | Instant (remove IAM role) |
| Security | Medium | High (no keys in transit) |

## Next Steps

1. ✅ Deploy infrastructure with new Terraform configuration
2. ✅ Test gcloud SSH access from your machine
3. ✅ Run Ansible playbook to configure VMs
4. ✅ Verify Jenkins pipeline runs successfully
5. (Optional) Add Cloud IAP for additional security layer
