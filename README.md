# S3 Bucket Infrastructure Documentation

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Security Considerations](#security-considerations)
- [Infrastructure Details](#infrastructure-details)

## Prerequisites

### Terraform Installation
Before you can use this configuration, you need to have Terraform installed on your system:

1. Visit the [official Terraform downloads page](https://developer.hashicorp.com/terraform/downloads)
2. Download the appropriate version for your operating system
3. Add Terraform to your system's PATH
4. Verify installation by running:
   ```bash
   terraform --version
   ```

### AWS Credentials
You'll need AWS credentials with appropriate permissions to create S3 buckets. Ensure you have:
- AWS Access Key ID
- AWS Secret Access Key
- Appropriate IAM permissions to create and manage S3 buckets


## Configuration

### 1. Environment Variables and Variable Handling

Terraform provides multiple ways to set variables. They are read in the following order (later sources take precedence):

1. **Environment Variables**: Set directly in your system
   ```bash
   export TF_VAR_AWS_ACCESS_KEY_ID="your-access-key"
   export TF_VAR_AWS_SECRET_ACCESS_KEY="your-secret-key"
   export TF_VAR_AWS_REGION="eu-west-2"
   ```

2. **Variable Files**: Create a `.tfvars` file (e.g., `terraform.tfvars`):
   ```hcl
   AWS_ACCESS_KEY_ID     = "your-access-key"
   AWS_SECRET_ACCESS_KEY = "your-secret-key"
   AWS_REGION           = "eu-west-2"  # Default is eu-west-2, change if needed
   ```

3. **Command Line Flags**:
   ```bash
   terraform apply -var="AWS_REGION=eu-west-2"
   ```

4. **AWS CLI Configuration**: You can also use AWS CLI credentials:
   ```bash
   aws configure
   ```
   This will create/update your AWS credentials file (~/.aws/credentials) which Terraform can use automatically.

⚠️ **Important**: 
- Never commit the `.tfvars` file to version control. Add it to `.gitignore`.
- Using AWS CLI configuration is recommended for development environments.
- For production environments, consider using AWS IAM roles and instance profiles instead of access keys.

### 2. Project Structure
Ensure your project follows this structure:
```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
└── modules/
    └── s3/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Usage

### 1. Initialize Terraform
Run the following command to initialize Terraform and download required providers:
```bash
terraform init
```

### 2. Plan the Infrastructure
Review the changes that will be made:
```bash
terraform plan -var-file="terraform.tfvars"
```

### 3. Apply the Configuration
Create the infrastructure:
```bash
terraform apply -var-file="terraform.tfvars"
```

### 4. Destroy Infrastructure (if needed)
To remove all created resources:
```bash
terraform destroy -var-file="terraform.tfvars"
```

## Infrastructure Details

### S3 Bucket Configuration
This Terraform configuration creates an S3 bucket with the following features:

- **Bucket Name**: "learnd-pdf" (configured through the module)
- **Versioning**: Enabled by default
- **Force Destroy**: Enabled (allows deletion of bucket even if it contains objects)
- **CORS Configuration**:
  - Allowed Methods: PUT, GET, POST, DELETE
  - Allowed Origins: * (all origins)
  - Allowed Headers: * (all headers)
  - Max Age: 3000 seconds
  - Expose Headers: ETag
- **Server-Side Encryption**: AES256 encryption enabled by default

### Output Values
After successful creation, you can access:
- Bucket ARN: `terraform output bucket_arn`
- Bucket ID: `terraform output bucket_id`

## Security Considerations

1. **CORS Configuration**: The current configuration allows all origins (`*`). For production, restrict this to specific domains.
2. **Encryption**: Server-side encryption is enabled using AES256.
3. **Access Keys**: Always use environment variables or AWS profiles instead of hardcoding credentials.
4. **Versioning**: Enabled by default for data protection and recovery.

## Troubleshooting

Common issues and solutions:

1. **Bucket Name Conflict**: S3 bucket names must be globally unique. If creation fails, try a different name.
2. **Permission Issues**: Ensure your AWS credentials have sufficient permissions.
3. **State Lock**: If you get a state lock error, check if another process is running or if a previous process failed to release the lock.

## Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/index.html)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
