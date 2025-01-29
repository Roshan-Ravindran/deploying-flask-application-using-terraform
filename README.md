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

## Terraform Configuration

The Terraform script provisions the following resources:

### EC2 Instance:

```hcl
resource "aws_instance" "ubuntu" {
  ami                         = "ami-04b4f1a9cf54c11d0"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet_public.id
  vpc_security_group_ids      = [aws_security_group.sg_22_5000.id]
  user_data                   = file("provide.yaml")
}
```

### network.tf file

- creates a VPC in 10.0.0.0/16
- creates a internet gateway for the VPC
- creates a subnet inside the VPC (10.1.0.0/24)
- creates a route table to route any traffic destined to 0.0.0.0/0 to go through via internet gateway
- creates a route table association by attaching the route table to the subnet created

### securitygroup.tf

- creates security group to be attached to the EC2 instance to allow TCP connections on port 22 and 5000 for SSH and HTTP connection

### cloud-config File:

#### Cloud-Config file:

- Sets up user accounts and permissions.
- adds ssh public key to the linux machine to SSH. (can use key-name attribute from instance as well.)
- Shell script to install required software (e.g., Flask) and deploy the website.

```yaml
#cloud-config
groups:
  - ubuntu: [root, sys]
  - hashicorp

# Add users to the system. Users are added after groups are added.
users:
  - default
  - name: terraform
    gecos: terraform
    shell: /bin/bash
    primary_group: hashicorp
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    lock_passwd: false
    ssh_authorized_keys:
      - ssh-rsa yourkeyhere.... example@gmail.com

# Sets the GOPATH & downloads the demo payload
#cloud-config

runcmd:
  - apt update -y # Update package lists
  - sudo apt install -y python3-pip python3-venv curl # Install Python3 pip, venv, and curl
  - python3 -m venv flask-env # Create a Python virtual environment
  - . flask-env/bin/activate # Activate the virtual environment
  - pip install flask # Install Flask in the virtual environment
  - curl -o app.py https://raw.githubusercontent.com/Roshan-Ravindran/deploying-flask-application-using-terraform/refs/heads/master/flask/app.py # Download the app.py
  - mkdir -p templates # Create templates directory
  - curl -o templates/index.html https://raw.githubusercontent.com/Roshan-Ravindran/deploying-flask-application-using-terraform/refs/heads/master/flask/templates/index.html # Download the index.html template
  - chmod +x app.py # Make app.py executable
  - python3 app.py # Run the Flask app
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

   - Use the public IP of the EC2 instance to access the website in your browser: `http://<PUBLIC_IP>:5000`.

4. **SSH Access**:
   ```bash
   ssh terraform@$(terraform output -raw web_public_ip) -i /path/to/ssh-private-key
   ```

## Troubleshooting

1. **Software Installation Errors**:

   - If pip installation fails, ensure the virtual environment is activated correctly.

2. **Access Issues**:

   - Verify the security group allows inbound traffic on required ports.

3. **Troubleshoot shell script:**
   - Check the `cloud-init` logs at `/var/log/cloud-init-output.log` for errors.
