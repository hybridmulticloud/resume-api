name: Deploy Backend Infrastructure

on:
  push:
    branches:
      - main
    paths:
      - infra/**
      - lambda_function.py
      - .github/workflows/deploy-backend.yml
  workflow_dispatch:

jobs:
  terraform_backend:
    name: Apply Terraform Infra
    runs-on: ubuntu-latest

    env:
      AWS_REGION:               ${{ secrets.AWS_REGION }}
      AWS_ACCESS_KEY_ID:        ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY:    ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      TF_TOKEN_app_terraform_io: ${{ secrets.TF_API_TOKEN }}

      # var.route53_zone_id will be set via TF_VAR_… so we can output it later
      TF_VAR_route53_zone_id:   ${{ secrets.ROUTE53_ZONE_ID }}

    steps:
      - name: Checkout source
        uses: actions/checkout@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id:     ${{ env.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ env.AWS_SECRET_ACCESS_KEY }}
          aws-region:            ${{ env.AWS_REGION }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: "1.5.7"

      - name: Terraform Init
        working-directory: infra
        run: terraform init -input=false

      - name: Terraform Plan
        working-directory: infra
        run: terraform plan -out=tfplan -input=false

      - name: Terraform Apply
        working-directory: infra
        run: terraform apply -auto-approve tfplan

      - name: Export all IDs from remote state
        working-directory: infra
        run: |
          terraform output -raw cloudfront_oac_id       > ../cloudfront_oac_id.txt
          terraform output -raw cloudfront_distribution_id > ../cloudfront_distribution_id.txt
          terraform output -raw route53_zone_id          > ../route53_zone_id.txt

      - name: Upload IDs as artifact
        uses: actions/upload-artifact@v4
        with:
          name: infra-ids
          path: |
            cloudfront_oac_id.txt
            cloudfront_distribution_id.txt
            route53_zone_id.txt

  terraform_imports:
    name: Import Existing Frontend Infra
    runs-on: ubuntu-latest
    needs: terraform_backend
    if: github.event_name == 'workflow_dispatch'  # optional guard

    env:
      AWS_REGION:               ${{ secrets.AWS_REGION }}
      AWS_ACCESS_KEY_ID:        ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY:    ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      TF_TOKEN_app_terraform_io: ${{ secrets.TF_API_TOKEN }}

    steps:
      - name: Download infra-ids artifact
        uses: actions/download-artifact@v4
        with:
          name: infra-ids

      - name: Read IDs into env
        run: |
          echo "CLOUDFRONT_OAC_ID=$(cat cloudfront_oac_id.txt)" >> $GITHUB_ENV
          echo "CLOUDFRONT_DIST_ID=$(cat cloudfront_distribution_id.txt)" >> $GITHUB_ENV
          echo "ROUTE53_ZONE_ID=$(cat route53_zone_id.txt)" >> $GITHUB_ENV

      - name: Checkout source
        uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: "1.5.7"

      - name: Terraform Init
        working-directory: infra
        run: terraform init -input=false

      - name: Import S3 bucket
        working-directory: infra
        run: terraform import aws_s3_bucket.frontend "${{ env.FRONTEND_BUCKET_NAME }}"

      - name: Import S3 public access block
        working-directory: infra
        run: terraform import aws_s3_bucket_public_access_block.frontend "${{ env.FRONTEND_BUCKET_NAME }}"

      - name: Import CloudFront OAC
        working-directory: infra
        run: terraform import aws_cloudfront_origin_access_control.frontend_oac "${{ env.CLOUDFRONT_OAC_ID }}"

      - name: Import CloudFront distribution
        working-directory: infra
        run: terraform import aws_cloudfront_distribution.frontend "${{ env.CLOUDFRONT_DIST_ID }}"

      - name: Import S3 bucket policy
        working-directory: infra
        run: terraform import aws_s3_bucket_policy.frontend "${{ env.FRONTEND_BUCKET_NAME }}"

      - name: Import Route53 A record
        working-directory: infra
        run: terraform import aws_route53_record.frontend_alias "${{ env.ROUTE53_ZONE_ID }}_${{ env.FRONTEND_BUCKET_NAME }}_A"
