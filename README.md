# Hosting a Website on AWS EC2 Using Terraform

This README documents the steps and configurations used to host a website on an AWS EC2 instance using Terraform. It covers the infrastructure setup, website deployment, and troubleshooting methods.

## Overview

The hosted website is deployed on an AWS EC2 instance using a pre-configured Terraform script and a `cloud-config` file. Terraform provisions the infrastructure, and the cloud-config file sets up the EC2 instance with the necessary software and configurations for the website.

![diagram](https://github.com/mathesh-me/application-deployment-in-aws-terraform/assets/144098846/03e4386d-3d6f-4d96-ba07-fe828175a634)

## Prerequisites

1. **Terraform**: Ensure Terraform is installed (v1.x or later).
2. **AWS Account**: A valid AWS account with necessary permissions.
3. **Key Pair**: An existing AWS key pair to allow SSH access to the EC2 instance.
4. **AWS CLI**: Installed and configured for your account.

## AWS Resources Used

1. **EC2 Instance**:

   - **AMI**: Ubuntu (e.g., `ami-04b4f1a9cf54c11d0`).
   - **Instance Type**: `t2.micro`.

2. **Networking**:

   - **VPC and Subnet**: The instance is provisioned in a public subnet.
   - **Security Groups**: Allow inbound traffic on necessary ports (e.g., port 80 for HTTP).

3. **Cloud-Config**:
   - Sets up user accounts and permissions.
   - Installs required software (e.g., Flask).
   - Deploys the website.

## Terraform Configuration

The Terraform script provisions the following resources:

1. **EC2 Instance**:

   - Provisions an Ubuntu instance with the specified AMI.
   - Attaches the `cloud-config` file via the `user_data` argument.
   - Associates the instance with a security group.

2. **Security Group**:

   - Allows inbound traffic on:
     - Port 22 (SSH).
     - Port 5000 (for HTTP connection).

3. **User Data (Cloud-Config)**:
   - Configures the instance with:
     - A `terraform` user with SSH access.
     - Flask installation and environment setup.

### Example Terraform Configuration

```hcl
resource "aws_instance" "ubuntu" {
  ami                         = "ami-04b4f1a9cf54c11d0"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet_public.id
  vpc_security_group_ids      = [aws_security_group.sg_22_80.id]
  user_data                   = file("provide.yaml")
}
```

## Cloud-Config File

The `cloud-config` file contains:

1. **User Configuration**:

   - Adds a `terraform` user with SSH access.
   - Configures SSH keys for secure login.

2. **Software Installation**:

   - Updates package lists and installs dependencies (Python, Flask, etc.).
   - Sets up a Python virtual environment.

3. **Website Deployment**:
   - Deploys a simple Flask application.

### Example Cloud-Config

```yaml
#cloud-config
groups:
  - terraform

users:
  - name: terraform
    gecos: terraform
    shell: /bin/bash
    primary_group: terraform
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    ssh_authorized_keys:
      - ssh-rsa AAAAB3...your-key...

runcmd:
  - apt update -y
  - apt install -y python3-pip python3-venv curl
  - python3 -m venv flask-env
  - source flask-env/bin/activate
  - pip install flask
  - echo "from flask import Flask; app = Flask(__name__); @app.route('/')\ndef hello(): return 'Hello, World!'; app.run(host='0.0.0.0')" > app.py
  - nohup python3 app.py &
```

## Deployment Steps

1. **Initialize Terraform**:

   ```bash
   terraform init
   ```

2. **Apply Terraform Configuration**:

   ```bash
   terraform apply
   ```

   - Review the proposed changes and type `yes` to apply them.

3. **Access the Website**:

   - Use the public IP of the EC2 instance to access the website in your browser: `http://<PUBLIC_IP>`.

4. **SSH Access**:
   ```bash
   ssh -i <key.pem> ubuntu@<PUBLIC_IP>
   ```

## Troubleshooting

1. **User Creation Failures**:

   - Ensure `lock_passwd: false` and a valid `ssh_authorized_keys` entry.

2. **Software Installation Errors**:

   - If pip installation fails, ensure the virtual environment is activated correctly.

3. **Access Issues**:
   - Verify the security group allows inbound traffic on required ports.
   - Check the `cloud-init` logs at `/var/log/cloud-init-output.log` for errors.

## Tools and Dependencies

1. **Terraform**: Infrastructure as Code.
2. **AWS CLI**: Configures and manages AWS resources.
3. **Flask**: Python web framework for the hosted website.

## Challenges and Solutions

1. **SSH Access Issues**:

   - Resolved by correctly setting up the `ssh_authorized_keys` in the cloud-config file.

2. **Pip Installation Errors**:
   - Used `python3 -m ensurepip` to ensure pip was available in the virtual environment.

## Next Steps

1. Add monitoring for the EC2 instance (e.g., using CloudWatch).
2. Automate deployments with CI/CD pipelines.
3. Secure the instance further by restricting access to specific IP ranges.

## Author

Roshan
