# Cloud Resume Challenge: Backend API

This repository hosts the backend infrastructure for my personal resume site, built as part of the Cloud Resume Challenge. It wires up:

- An **HTTP API** (API Gateway)  
- A **Lambda function** (`UpdateVisitorCount`)  
- A **DynamoDB** table (`VisitorCount`)

Each time someone visits my resume, the Lambda increments a counter—so you can see real-time visitor stats on the frontend.

---

## How It Links to the Frontend

The frontend (in [resume-api-frontend](https://github.com/hybridmulticloud/resume-api-frontend)) downloads two artifacts that this backend emits:

1. **API Gateway URL** (`api_gateway_url`)  
2. **CloudFront Distribution ID** (`cloudfront_distribution_id`)

These values let the static site call the visitor-count API and invalidate its cache whenever we deploy.

---

## Architecture

```plaintext
                                                          +----------------------+
                                                          |  DynamoDB Visitor    |
                                                          |      Count Table     |
                                                          +----------+-----------+
                                                                     ^
                                                                     |
                            +-------------+                  +--------+--------+
                            |   API       |    Invoke      | Lambda Function |
      Route53 Alias         |  Gateway    | ─────────────> | UpdateVisitor   |
   hybridmulti.cloud  ──►   +-------------+                +-----------------+

Prerequisites
Terraform ≥ 1.5.7

AWS credentials with permissions to create: IAM, Lambda, DynamoDB, API Gateway

GitHub Actions runner (CI/CD) with secrets configured (see below)

Quick Start
Clone and enter the repo

bash
git clone https://github.com/hybridmulticloud/resume-api-backend.git
cd resume-api-backend
(Optional) Override defaults in variables.tf.

Bootstrap your environment and deploy:

bash
terraform init
terraform fmt
terraform validate
terraform plan   # review
terraform apply  # provision
Note the API Gateway URL and CloudFront ID printed at the end.

Switch to the frontend repo, update its workflow secrets/placeholders with these values, then trigger deployment.

Outputs
Name	Description
api_gateway_url	Full POST URL for visitor-count endpoint
api_endpoint	Base API Gateway URL
cloudfront_distribution_id	Frontend CloudFront Distribution identifier
dynamodb_table_name	Name of the DynamoDB table
lambda_function_name	Deployed Lambda function name
lambda_execution_role_arn	IAM role ARN used by the Lambda function
CI/CD
A GitHub Actions workflow (.github/workflows/deploy-backend.yml) automatically:

Formats & validates Terraform

Runs plan & apply on main

Exposes api-url & cloudfront-id artifacts for the frontend to consume

This backend powers my resume at https://hybridmulti.cloud as part of the Cloud Resume Challenge!
