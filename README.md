# ☁️ Cloud Resume Challenge – Visitor Counter API

Welcome! This repository contains the backend code for my https://hybridmulti.cloud/ project — a serverless visitor counter API built on AWS.

It leverages **Lambda**, **API Gateway**, and **DynamoDB** to count and return the number of visitors to my resume website in real time.

---

## 📦 What This Code Does

When someone visits my website, this Lambda function is triggered via an API Gateway endpoint. It connects to DynamoDB, increments a counter, and returns the updated count to the frontend.

This is part of the challenge’s goal to demonstrate hands-on experience with real cloud infrastructure — including infrastructure as code, CI/CD, and serverless development.

---

## ⚙️ Tech Stack

- **AWS Lambda** – Runs the Python function
- **Amazon DynamoDB** – Stores the visitor count
- **API Gateway (HTTP API)** – Exposes the API to the web
- **Python 3.x** – Used for the backend logic (`boto3` SDK)
- **GitHub** – Source control and CI/CD
- **GitHub Actions** – Automates deployment (coming soon)

---

## 🧪 Example Response

```json
{
  "visits": 42
}
```

---

## 🚀 How To Deploy (Manually)
This walkthrough assumes you’re setting up everything via the AWS Console. Automation via GitHub Actions will be added later.

1️⃣ Create DynamoDB Table
Go to DynamoDB → Create table

Table name: visitor_count

Partition key: id (String)

Create the table, then manually insert an item:
```json
{
  "id": "count",
  "visits": 0
}
```

---

## 2️⃣ Create Lambda Function
Go to Lambda → Create function

Name: UpdateVisitorCount

Runtime: Python 3.x

Use the code from lambda_function.py in this repo

Add environment variables if needed

✅ Permissions:

Attach AmazonDynamoDBFullAccess for testing (restrict later)

3️⃣ Create API Gateway
Go to API Gateway → Create HTTP API

Add integration: select your Lambda function

Route: POST /UpdateVisitorCount

Enable CORS (for browser access later)

Deploy to the default stage ($default)

4️⃣ Test Your API
You can test the deployed endpoint using Postman or curl:

Method: POST

URL: https://<api-id>.execute-api.<region>.amazonaws.com/UpdateVisitorCount

Body:

```json
{}
```

Expected response:

```json
{
  "visits": 1
}
```

---

## 🤖 How To Deploy (Automatically via GitHub Actions) – Coming Soon
I'll be adding a GitHub Actions workflow to automatically deploy changes to Lambda whenever I push to this repo.

This will involve:

Creating an IAM user for GitHub Actions

Adding AWS credentials as GitHub secrets

Writing a .github/workflows/deploy.yml CI/CD pipeline

---

## 🧠 Lessons Learned
This chunk of the Cloud Resume Challenge taught me:

How to connect AWS services using IAM and event-driven design

How to write clean Python code using the boto3 SDK

How to expose secure APIs via API Gateway

And perhaps most importantly — how to get “real world” experience building cloud-native applications, even in a personal project.

---

## ✍️ Author
Hi! I'm Kerem Kirci, 

👉 Visit my resume site https://hybridmulti.cloud
