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
