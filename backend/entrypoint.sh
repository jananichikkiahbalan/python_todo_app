#!/bin/sh
set -e

echo "[entrypoint] Fetching database credentials from AWS Secrets Manager..."

# Step 1 — Call AWS Secrets Manager and get the secret JSON string
SECRET=$(aws secretsmanager get-secret-value \
  --secret-id "${SECRET_NAME}" \
  --region "${AWS_REGION}" \
  --query 'SecretString' \
  --output text)

# Step 2 & 3 — Parse each field from JSON and export as env variables
export DB_HOST=$(echo "$SECRET"     | jq -r '.host')
export DB_PORT=$(echo "$SECRET"     | jq -r '.port')
export DB_NAME=$(echo "$SECRET"     | jq -r '.dbname')
export DB_USER=$(echo "$SECRET"     | jq -r '.username')
export DB_PASSWORD=$(echo "$SECRET" | jq -r '.password')

# Step 4 — Confirm credentials were fetched (never print actual values!)
echo "[entrypoint] DB_HOST     = $DB_HOST"
echo "[entrypoint] DB_PORT     = $DB_PORT"
echo "[entrypoint] DB_NAME     = $DB_NAME"
echo "[entrypoint] DB_USER     = $DB_USER"
echo "[entrypoint] DB_PASSWORD = [HIDDEN]"

# Step 5 — Start the actual Python application
echo "[entrypoint] Starting Flask application..."
exec python app.py