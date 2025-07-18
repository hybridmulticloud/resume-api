# Cloud Resume Challenge: Backend API

This repository hosts the backend infrastructure for my personal resume site, built as part of the Cloud Resume Challenge. It wires up:

- An **HTTP API** (API Gateway)
- A **Lambda function** (`UpdateVisitorCount`)
- A **DynamoDB** table (`VisitorCount`)
- Infrastructure as Code (Terraform)

🌐 Live Resume Site: [https://hybridmulti.cloud](https://hybridmulti.cloud)

---

## How It Links to the Frontend

The frontend ([resume-api-frontend](https://github.com/hybridmulticloud/resume-api-frontend)) downloads these backend build artifacts:

1. `api_gateway_url` – Used in the frontend to fetch visitor counts
2. `cloudfront_distribution_id` – Used to invalidate cache after deployment

---

## Architecture

```plaintext
     API Gateway
         │
         ▼
+----------------------+       +----------------------+
|   Lambda Function     | ◄──→ |   DynamoDB Table     |
| UpdateVisitorCount    |      | VisitorCount         |
+----------------------+       +----------------------+
         ▲
         │
   Triggered via frontend (CloudFront → API Gateway)
```

---

## CI/CD with GitHub Actions

GitHub Actions handle all deployment via `.github/workflows/`:

- **infra.yml** – Terraform plan and apply
- **lambda-deploy.yml** – Zips and uploads Lambda
- **deploy-backend.yml** – Coordinates full backend deployment

---

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for contribution and branching guidelines.
