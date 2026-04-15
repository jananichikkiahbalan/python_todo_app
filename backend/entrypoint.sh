#!/bin/sh
set -e

echo "[entrypoint] Using environment variables for DB connection..."

echo "[entrypoint] DB_HOST     = $DB_HOST"
echo "[entrypoint] DB_PORT     = $DB_PORT"
echo "[entrypoint] DB_NAME     = $DB_NAME"
echo "[entrypoint] DB_USER     = $DB_USER"
echo "[entrypoint] DB_PASSWORD = [HIDDEN]"

echo "[entrypoint] Starting Flask application..."
exec python app.py