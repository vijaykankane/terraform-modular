

Activity List:
--------------
1.) Create a reusable Terraform codebase that provisions a complete environment in AWS for four environments (dev, qa, staging, prod). 
2.) Each environment must have its own remote state backend (S3) and state locking (DynamoDB). 
3.) The codebase should be modular and reusable. 
4.) The infra for each environment should have following services:
    - 1 VPC with 3 public subnets and 3 private subnets
    - Internet Gateway, NAT Gateway(s), route tables
    - Security Groups (bastion/ssh, app/tcp 80/443)
    - 1 EC2 instance (web) in private subnet (with a bastion in public subnet for SSH)
    - 1 S3 bucket for application data -- need to do 
    - IAM role/policy for the EC2 instance to access S3 need to do 

Deliverables: 
-------------
A full set of Terraform files (modules + envs) you can place into a repo and run

--------------------------------------------------------------------------------

Project layout (recommended)
----------------------------

Step 1 – Setup project structure

Create a folder structure like this:
Note: All the code with respect to below steps / phases are in "learn-tf-modules" directory

learn-tf-modules/
    modules/
        vpc/
            main.tf
            variables.tf
            outputs.tf
        ec2/
            main.tf
            variables.tf
            outputs.tf
        s3/
            main.tf
            variables.tf
            outputs.tf
    envs/
        dev/
            providers.tf
            main.tf
            variables.tf
            dev.tfvars
        qa/
            providers.tf
            main.tf
            variables.tf
            qa.tfvars
        staging/
            providers.tf
            main.tf
            variables.tf
            staging.tfvars
        prod/
            providers.tf
            main.tf
            variables.tf
            prod.tfvars
README.md

-----------------------------------------------------------------------------

Step-by-step Guide:
-------------------

Phase 0 - Pre-reqs (one-time)
-----------------------------

- AWS account with permissions to create VPC, EC2, S3, IAM, DynamoDB
- AWS CLI configured on your machine (profiles optional)
- Terraform latest version installed
- Create a S3 bucket and DynamoDB table for remote state locking:
    S3 bucket: <your-name>-terraform-state
    DynamoDB table: Name "terraform-locks" with Partition key LockID (string)


Phase 1 - Create modules
------------------------

Create three modules: vpc, compute, and storage.

Module 1: modules/vpc
Path: 
- Inputs: vpc_cidr, public_subnet_cidrs, private_subnet_cidrs, region, env
- Resources: aws_vpc, aws_internet_gateway, aws_subnet (public/private), aws_route_table, aws_route_table_association, aws_eip + aws_nat_gateway (optional single NAT), security group outputs.

Module 2: modules/ec2
- Inputs: ami_id, instance_type, subnet_id, key_name, vpc_security_group_ids, iam_instance_profile, env
- Resources: aws_instance for bastion (public), aws_instance for private web or aws_launch_template + aws_autoscaling_group (for simplicity we'll create 1 EC2 web instance), security group rules.

Module 3: modules/storage
- Inputs: bucket_name, versioning, env
- Resources: aws_s3_bucket, aws_s3_bucket_public_access_block, aws_s3_bucket_versioning, aws_iam_role & aws_iam_policy (for instance to access S3)

Important: Each module will expose outputs for IDs required by other modules.

Phase 2 - Environment directories, providers & remote state:
------------------------------------------------------------

- Each envs/<env> folder contains all environment-specific configuration, including both provider configuration and backend (remote state + locking) in the providers.tf file.

Each environment folder must include:
1.) providers.tf with:
- AWS provider configuration (region, profile, assume-role, etc.)
- S3 backend configuration for remote state
- DynamoDB table for state locking

2.) main.tf
- Calls the modules (vpc, ec2, s3), wires outputs and IAM roles, and consumes variables defined for that environment sourced from <env>.tfvars

3.) variables.tf
- Defines the variables required in that environment - such as region, env name, VPC CIDRs, instance types, bucket names, etc.

4.) <env-name>.tfvars e.g.: dev.tfvars / qa.tfvars / stag.tfvars / prod.tfvars
CIDR blocks
EC2 instance type
S3 bucket name
AMI ID
AWS profile
Env name (dev, qa, staging, prod)

Phase 3: Workflow to run for each environment (example for dev):
-----------------------------------------------------------------

cd envs/dev

# Initialize and configures remote backend (S3 + DynamoDB locking), download AWS plugin for communicating with AWS and connects to the correct AWS account:
terraform init

# Plan and verify the output:
terraform plan -var-file=dev.tfvars

# Apply the terraform file to achieve the desired state on AWS
terraform apply -var-file=terraform.tfvars

Why this works well:
--------------------
- Each environment has its own backend key, meaning each environment gets its own isolated state file.
- All environments share the same modules, ensuring consistency.
- Providers & backend configs live in the environment folder, ensuring zero accidental cross-environment contamination.

Phase 4 - Additional Best Practices:
-------------------------------------

- Use "terraform fmt" and "terraform validate" for linting.
- Always use terraform plan before apply to validate the changes especially in production / critical envs


To findout the cost of the infra we are provisioning please use open source infracost

installation for the various platforms

# Install Infracost
brew install infracost  # macOS
# or: curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh


For Windows:
bash# Install via Chocolatey
choco install infracost

# Or download directly
curl -O https://github.com/infracost/infracost/releases/latest/download/infracost-windows-amd64.tar.gz
tar -xzf infracost-windows-amd64.tar.gz

# Authenticate
infracost auth login



# Generate Terraform plan
terraform init
terraform plan -out=tfplan.binary --var-file=dev.tfvars
terraform show -json tfplan.binary > plan.json

# Get cost breakdown
Go into teh directory of the plan.json and run the below command.

infracost breakdown --path .

infracost breakdown --path . --format html > report.html

# Compare changes
infracost diff --path plan.json
