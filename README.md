# resume-api
# Cloud Resume Challenge – Visitor Counter API

This is the backend code for the **Cloud Resume Challenge**, specifically the **API and database layer** that tracks how many people have viewed the resume website.

It’s built using 100% serverless AWS services — no servers, no containers, just clean and simple cloud-native infrastructure.

---

## 📦 What This Code Does

Every time someone visits the website, this Python function is triggered by an HTTP API call. It talks to DynamoDB and increments a counter by 1. The new count is then returned as a JSON response.

---

## ⚙️ How It Works

- **AWS Lambda**: Runs the Python function
- **Amazon DynamoDB**: Stores the visit count (`visits`)
- **API Gateway (HTTP API)**: Exposes the Lambda to the web as a RESTful POST endpoint

---

## 🧪 Example Response

```json
{
  "visits": 78
}

---

---

## ⚙️ How It Works

- **AWS Lambda**: Runs the Python function
- **Amazon DynamoDB**: Stores the visit count (`visits`)
- **API Gateway (HTTP API)**: Exposes the Lambda to the web as a RESTful POST endpoint

---

## 🚀 How To Deploy (Manually)
Create a DynamoDB table named visitor_count

Partition key: id (String)

Add item:

json
Copy
Edit
{
  "id": "count",
  "visits": 0
}
Create a Lambda function in the AWS Console

Use lambda_function.py as the code

Attach IAM role with AmazonDynamoDBFullAccess (or restrict it properly)

Create an HTTP API in API Gateway

Route: POST /UpdateVisitorCount

Integration: Lambda function

Enable CORS

---

## 🛠 Tech Stack
Python 3.x

AWS Lambda

DynamoDB

API Gateway (HTTP API)

GitHub (for source control)

---

## ✍️ Author
Built with care as part of the Cloud Resume Challenge.
