# ☁️ Cloud Resume Challenge – Backend Infrastructure (Terraform + Lambda)

This repository contains the backend infrastructure and Lambda function for the [hybridmulti.cloud](https://hybridmulti.cloud) resume project.

It demonstrates:
- ✅ Real-world use of **Terraform** to deploy AWS resources
- ✅ Direct **Lambda deployment** via GitHub Actions using AWS CLI
- ✅ Clean separation of infrastructure and function code

---

## 🚀 Components

| Component        | Service           | Description |
|------------------|-------------------|-------------|
| Compute          | AWS Lambda        | Python 3.x function for counting site visits |
| API Layer        | API Gateway v2    | Public HTTP endpoint (`/UpdateVisitorCount`) |
| Data Layer       | DynamoDB          | NoSQL table tracking visitor counts |
| IaC              | Terraform         | Declarative deployment of all AWS resources |
| CI/CD            | GitHub Actions    | Split pipelines for infra and function code |

---

## 🧱 Directory Structure

```
resume-api/
├── lambda_function.py           # Lambda visitor counter logic
├── infra/                       # Terraform IaC
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
└── .github/
    └── workflows/
        ├── infra.yml            # Deploys infrastructure
        └── lambda-deploy.yml    # Updates Lambda code directly
```

---

## ⚙️ How It Works

### Frontend JS (in hybridmulti.cloud) does:

```js
fetch("https://<api-id>.execute-api.<region>.amazonaws.com/UpdateVisitorCount", {
  method: "POST",
  body: JSON.stringify({})
});
```

### Backend Lambda Function:

- Increments `visits` in DynamoDB table `VisitorCount`
- Returns the updated count

---

## 📦 Deployment Instructions

### 1️⃣ Provision AWS Infrastructure

Trigger GitHub Actions: **`.github/workflows/infra.yml`** or run manually:

```bash
cd infra
terraform init
terraform apply
```

Creates:
- Lambda function (no ZIP file attached)
- IAM role (with least privilege)
- API Gateway integration
- DynamoDB table (with seeded counter)

---

### 2️⃣ Deploy Lambda Code

Triggered automatically on `lambda_function.py` changes via **`.github/workflows/lambda-deploy.yml`**

Or run locally:
```bash
zip function.zip lambda_function.py
aws lambda update-function-code \
  --function-name UpdateVisitorCount \
  --zip-file fileb://function.zip
```

---

## 🔐 IAM & Security

- Lambda has minimal access: `dynamodb:GetItem`, `dynamodb:UpdateItem`
- Lambda logs to CloudWatch
- API Gateway CORS restricted to `https://hybridmulti.cloud`

---

## 📤 Outputs

Run `terraform output` to get:
- `api_gateway_url` — ready to plug into frontend
- `dynamodb_table_name` — current storage table
- `lambda_function_name` — deployed name for updates

---

## ✍️ Author

**Kerem Kirci** – Senior Technical Consultant  
🔗 [linkedin.com/in/kerem-kirci](https://linkedin.com/in/kerem-kirci)  
🌐 [https://hybridmulti.cloud](https://hybridmulti.cloud)
