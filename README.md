# Document Processing Infrastructure Documentation

## Table of Contents
1. [Overview](#overview)
2. [Project Structure](#project-structure)
3. [Prerequisites](#prerequisites)
   - [Required Tools](#required-tools)
   - [AWS Configuration](#aws-configuration)
     - [Variable Handling in Terraform](#variable-handling-in-terraform)
     - [Important Notes](#important-notes)
4. [Setup Instructions](#setup-instructions)
   - [Lambda Function Setup](#1-lambda-function-setup)
   - [Terraform Configuration](#2-terraform-configuration)
5. [Infrastructure Components](#infrastructure-components)
   - [S3 Bucket](#s3-bucket)
   - [DynamoDB Table](#dynamodb-table)
   - [Lambda Function](#lambda-function)
6. [Testing the Setup](#testing-the-setup)
7. [Cleanup](#cleanup)
8. [Security Considerations](#security-considerations)
   - [Access Control](#1-access-control)
   - [Data Protection](#2-data-protection)
9. [Troubleshooting](#troubleshooting)
   - [Lambda Container Issues](#1-lambda-container-issues)
   - [Infrastructure Deployment](#2-infrastructure-deployment)
   - [S3 Events](#3-s3-events)
10. [Resource Links](#resource-links)

## Overview
This project sets up a serverless document processing infrastructure on AWS using Terraform. The system consists of:
- An S3 bucket for document storage
- A DynamoDB table for document metadata
- A Lambda function that processes documents when they are uploaded/deleted from S3

## Project Structure
```
.
├── infra/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── modules/
│       ├── s3/
│       ├── dynamodb/
│       └── lambda/
├── lambda/
│   └── DocumentProcessor/
│       ├── Makefile
│       ├── Dockerfile
│       ├── processor.py
│       └── requirements.txt
```

## Prerequisites

### Required Tools
1. **AWS CLI** - [Installation Guide](https://aws.amazon.com/cli/)
2. **Terraform** (version ~> 5.0) - [Installation Guide](https://developer.hashicorp.com/terraform/downloads)
3. **Docker** - [Installation Guide](https://docs.docker.com/get-docker/)

### AWS Configuration

#### Variable Handling in Terraform
Terraform provides multiple ways to set variables, which are read in the following order (later sources take precedence):

1. **Environment Variables**:

   Linux/macOS:
   ```bash
   export TF_VAR_AWS_ACCESS_KEY_ID="your-access-key"
   export TF_VAR_AWS_SECRET_ACCESS_KEY="your-secret-key"
   export TF_VAR_AWS_REGION="your-region"
   export TF_VAR_environment="dev"
   export TF_VAR_ecr_namespace="your-account-id.dkr.ecr.region.amazonaws.com"
   ```

   Windows (Command Prompt):
   ```cmd
   set TF_VAR_AWS_ACCESS_KEY_ID=your-access-key
   set TF_VAR_AWS_SECRET_ACCESS_KEY=your-secret-key
   set TF_VAR_AWS_REGION=your-region
   set TF_VAR_environment=dev
   set TF_VAR_ecr_namespace=your-account-id.dkr.ecr.region.amazonaws.com
   ```

   Windows (PowerShell):
   ```powershell
   $env:TF_VAR_AWS_ACCESS_KEY_ID="your-access-key"
   $env:TF_VAR_AWS_SECRET_ACCESS_KEY="your-secret-key"
   $env:TF_VAR_AWS_REGION="your-region"
   $env:TF_VAR_environment="dev"
   $env:TF_VAR_ecr_namespace="your-account-id.dkr.ecr.region.amazonaws.com"
   ```

2. **Variable Files**: Create a `terraform.tfvars` file:
   ```hcl
   AWS_ACCESS_KEY_ID     = "your-access-key"
   AWS_SECRET_ACCESS_KEY = "your-secret-key"
   AWS_REGION           = "your-region"
   environment          = "dev"
   ecr_namespace        = "your-account-id.dkr.ecr.region.amazonaws.com"
   ```

3. **Command Line Flags**:
   ```bash
   terraform apply -var="AWS_REGION=eu-west-2" -var="environment=dev"
   ```

4. **AWS CLI Configuration** (Recommended for Development):
   ```bash
   aws configure
   ```
   This will create/update your AWS credentials file (~/.aws/credentials) which Terraform can use automatically.

⚠️ **Important Notes**: 
- Never commit credentials or `.tfvars` files to version control
- Add `*.tfvars` to your `.gitignore`
- For development environments, using AWS CLI configuration is recommended
- For production environments, consider using AWS IAM roles and instance profiles
- Environment variables with the prefix `TF_VAR_` are automatically loaded by Terraform

## Setup Instructions

## Setup Instructions

### 1. Lambda Function Setup
Navigate to the `lambda/DocumentProcessor` directory and:

1. Set required environment variables:

   Linux/macOS:
   ```bash
   export AWS_REGION="your-region"
   export ECR_REPOSITORY="your-account-id.dkr.ecr.region.amazonaws.com/namespace/repository-name"
   ```

   Windows (Command Prompt):
   ```cmd
   set AWS_REGION=your-region
   set ECR_REPOSITORY=your-account-id.dkr.ecr.region.amazonaws.com/namespace/repository-name
   ```

   Windows (PowerShell):
   ```powershell
   $env:AWS_REGION="your-region"
   $env:ECR_REPOSITORY="your-account-id.dkr.ecr.region.amazonaws.com/namespace/repository-name"
   ```


2. Build and push the Lambda container:
   ```bash
   make all
   ```
   This will:
   - Authenticate with AWS ECR
   - Build the Docker image
   - Tag the image
   - Push it to ECR


### 2. Terraform Configuration

1. Navigate to the `infra` directory

2. Create a `terraform.tfvars` file:
   ```hcl
   AWS_REGION           = "your-region"
   AWS_ACCESS_KEY_ID    = "your-access-key"
   AWS_SECRET_ACCESS_KEY = "your-secret-key"
   environment          = "dev"
   ecr_namespace        = "your-account-id.dkr.ecr.region.amazonaws.com/namespace"
   ```

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Preview the changes:
   ```bash
   terraform plan
   ```

5. Apply the configuration:
   ```bash
   terraform apply
   ```

## Infrastructure Components

### S3 Bucket
- Name: "learnd-documents-bucket"
- Features:
  - Versioning enabled
  - Server-side encryption (AES256)
  - CORS configuration for GET, PUT, DELETE operations
  - Force destroy enabled for easy cleanup

### DynamoDB Table
- Table Name: "Learnd_Documents_Metadata"
- Primary Key: "ID" (String)
- On-demand billing mode (PAY_PER_REQUEST)

### Lambda Function
- Name: "document_processor"
- Runtime: Python 3.12
- Trigger: S3 events (ObjectCreated, ObjectRemoved)
- IAM Role: Basic Lambda execution permissions

## Testing the Setup

1. Upload a document to the S3 bucket:
   ```bash
   aws s3 cp test-document.pdf s3://learnd-documents-bucket/
   ```

2. Check Lambda logs:
   ```bash
   aws logs get-log-events --log-group-name /aws/lambda/document_processor --log-stream-name <latest-stream>
   ```

3. Verify metadata in DynamoDB:
   ```bash
   aws dynamodb scan --table-name Learnd_Documents_Metadata
   ```

## Cleanup

To remove all created resources:

```bash
terraform destroy
```

Then clean up Docker images (optional):
```bash
cd lambda/DocumentProcessor
make clean
```

## Security Considerations

1. **Access Control**: 
   - S3 bucket allows all origins (*) - restrict this for production
   - Lambda has minimal IAM permissions
   - DynamoDB uses on-demand pricing to prevent DOS attacks

2. **Data Protection**:
   - S3 bucket has versioning enabled
   - Server-side encryption enabled by default
   - CORS rules configured for specific HTTP methods

## Troubleshooting

1. **Lambda Container Issues**:
   - Verify ECR repository exists
   - Check Docker build logs
   - Ensure AWS credentials are correct

2. **Infrastructure Deployment**:
   - Verify AWS credentials
   - Check Terraform state file
   - Review CloudWatch logs for Lambda errors

3. **S3 Events**:
   - Verify bucket notification configuration
   - Check Lambda permissions
   - Review CloudWatch logs for event triggers

## Resource Links
- [AWS Lambda Container Images](https://docs.aws.amazon.com/lambda/latest/dg/images-create.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS S3 Event Notifications](https://docs.aws.amazon.com/AmazonS3/latest/userguide/NotificationHowTo.html)
