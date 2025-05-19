#!/bin/bash
set -eo pipefail

# Create runtime directory if it doesn't exist
mkdir -p /var/run/django

# Create media directory if it doesn't exist
mkdir -p "${APP_ROOT}/media"

# Apply database migrations
echo "Applying database migrations..."
python manage.py migrate --noinput


# Start the application
echo "Starting application..."
exec "$@"
