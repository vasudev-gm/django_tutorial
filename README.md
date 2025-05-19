# Django Tutorial using DRF and DRF Spectacular OpenAPI

Django DRF with SQLite, NGINX load balancing, and production-grade deployment setup.

Features:

- Basic CRUD API for Employees and Department using Django DRF
- Load balanced using NGINX
- Deployed using Gunicorn Server
- Multi-stage Docker builds for optimized images
- Zstandard and Gzip compression
- Health checks and automatic failover

## Architecture

- NGINX load balancer with 2 Django application replicas
- Gunicorn as the WSGI server
- Static files served by NGINX
- Health monitoring and automatic failover
- Session persistence using IP hash

## Docker Compose Commands

### Build and Run

```powershell
# Enable BuildKit for optimized builds
$env:DOCKER_BUILDKIT=1

# Build and start all services
docker compose up --build -d

# Scale only web service
docker compose up -d --scale web=2
```

### Container Management

```powershell
# List running containers
docker compose ps

# View logs for specific service
docker compose logs -f web    # Django app logs
docker compose logs -f nginx  # NGINX logs

# Execute commands in container
docker compose exec web python manage.py migrate
docker compose exec web python manage.py collectstatic --noinput

# View logs with timestamps
docker compose logs --timestamps --tail=100
```

### Health and Status

```powershell
# Check health endpoint
curl http://localhost/health/

# Check NGINX status
docker compose exec nginx nginx -t

# View real-time container stats
docker compose top
```

### Maintenance

```powershell
# Stop all services
docker compose down

# Remove volumes (careful - this deletes data!)
docker compose down -v

# View container resource usage
docker stats
```

## Configuration

### Environment Variables

- `GUNICORN_WORKERS`: Number of worker processes (default: 4)
- `GUNICORN_THREADS`: Threads per worker (default: 2)
- `GUNICORN_MAX_REQUESTS`: Max requests per worker (default: 1000)

### NGINX Features

- Load balancing (least connections + IP hash)
- Zstandard and Gzip compression
- Static file serving
- Health checks
- Rate limiting
- Security headers

### Security

- Non-root container execution
- Rate limiting
- HTTP security headers
- No build tools in production image

## API Documentation

Access the API documentation at these endpoints:

- Swagger UI: [http://localhost/apidocs_swagger/](http://localhost/apidocs_swagger/)
- ReDoc: [http://localhost/apidocs_redoc/](http://localhost/apidocs_redoc/)
- OpenAPI Schema: [http://localhost/apidocs/](http://localhost/apidocs/)

## Development

For local development without Docker:

```powershell
# Install pipenv if you haven't already
pip install --user pipenv

# Install dependencies using Pipenv
pipenv install

# Activate the virtual environment
pipenv shell

# Run migrations
python manage.py migrate

# Start the development server
python manage.py runserver
```

### Additional Development Commands

```powershell
# Install a new package
pipenv install package_name

# Install development dependencies
pipenv install --dev

# Update all dependencies
pipenv update

# Generate requirements.txt (for Docker build)
pipenv requirements > requirements.txt

# Check security vulnerabilities
pipenv check
```

The project uses Pipfile and Pipfile.lock for dependency management, ensuring consistent environments across development machines.
