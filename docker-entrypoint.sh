#!/bin/bash
set -eo pipefail

# Create runtime directory if it doesn't exist
mkdir -p /var/run/django

# Create media directory if it doesn't exist
mkdir -p "${APP_ROOT}/media"

# Apply database migrations
echo "Applying database migrations..."
python manage.py migrate --noinput

# Create health check endpoint
cat > apidemo/health_check.py << EOF
from django.http import HttpResponse
from django.urls import path

def health_check(request):
    return HttpResponse("ok")

urlpatterns = [
    path('health/', health_check, name='health_check'),
]
EOF

# Start the application
echo "Starting application..."
exec "$@"
