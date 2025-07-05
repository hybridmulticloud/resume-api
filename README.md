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

---

## 🚀 How To Deploy (Manually)
This walkthrough assumes you’re setting up everything via the AWS Console. Automation via GitHub Actions will be added later.

1️⃣ Create DynamoDB Table
Go to DynamoDB → Create table

Table name: visitor_count

Partition key: id (String)

Create the table, then manually insert an item:
