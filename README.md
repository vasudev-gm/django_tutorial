# Django Tutorial using DRF and DRF Spectacular OpenAPI

Django DRF with SQLite, Angie load balancing, and production-grade deployment setup.

Features:

- Basic CRUD API for Employees and Department using Django DRF
- Load balanced using Angie
- Deployed using Gunicorn Server
- Multi-stage Docker builds for optimized images
- Zstandard and Gzip compression
- Health checks and automatic failover

## Architecture

- Angie load balancer with 2 Django application replicas
- Automatic Let's Encrypt certificates for `api.example.com`, with HTTP redirected to HTTPS
- Gunicorn as the WSGI server
- Static files served by Angie
- Health monitoring and automatic failover
- Session persistence using IP hash

## Docker Compose Commands

### Build and Run

Before starting, point `api.example.com` to the Docker host and allow inbound
ports 80 and 443 through your firewall. Angie requests and renews the
certificate automatically; the `angie_acme` volume preserves certificates and
ACME account data across container recreation.

```powershell
# Enable BuildKit for optimized builds
$env:DOCKER_BUILDKIT=1

# Build and start all services
docker compose up --build -d

# Scale only web service
docker compose up -d --scale web=2
```

### Local HTTP Development

For local access without a public domain or Let's Encrypt certificate, use the
local Compose override. It serves the Angie proxy over HTTP and publishes the
Django app directly on port 8000:

```powershell
docker compose -f compose.yaml -f compose.local.yaml up --build -d
```

Then open `http://localhost/` through Angie, `http://localhost:8000/` directly,
or the Angie Console Light monitoring page at `http://localhost/console/`.
The local Angie listener is bound to loopback; use this command form for
subsequent Compose operations on the local stack too.

### Container Management

```powershell
# List running containers
docker compose ps

# View logs for specific service
docker compose logs -f web    # Django app logs
docker compose logs -f angie  # Angie logs

# Execute commands in container
docker compose exec web python manage.py migrate
docker compose exec web python manage.py collectstatic --noinput

# View logs with timestamps
docker compose logs --timestamps --tail=100
```

### Health and Status

```powershell
# Check health endpoint
curl https://api.example.com/health/

# Check Angie status
docker compose exec angie angie -t

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

### Angie Features

- Load balancing with IP-based session affinity
- Zstandard and Gzip compression
- Static file serving
- Health checks
- Rate limiting
- Security headers
- Automatic Let's Encrypt certificate issuance and renewal

### Security

- Non-root container execution
- Rate limiting
- HTTP security headers
- No build tools in production image

## API Documentation

Access the API documentation at these endpoints:

- Swagger UI: [https://api.example.com/apidocs_swagger/](https://api.example.com/apidocs_swagger/)
- ReDoc: [https://api.example.com/apidocs_redoc/](https://api.example.com/apidocs_redoc/)
- OpenAPI Schema: [https://api.example.com/apidocs/](https://api.example.com/apidocs/)

## Development

For local development without Docker:

```powershell
# Install pipenv if you haven't already
pip install --user pipenv

# Install dependencies using Pipenv or uv
pipenv install

## UV commands to setup environment and run the project

> uv venv -p 3.13 --python-preference managed
> uv sync

## UV command to upgrade python and packages

> uv python upgrade
> uv sync --upgrade

## UV export to requirements.txt

> uv export --format=requirements.txt --all-packages > .\requirements.txt

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
OR
uv export --format=requirements.txt --all-packages > .\requirements.txt

# Check security vulnerabilities
pipenv check
```

The project uses pyproject.toml, Pipfile and Pipfile.lock for dependency management, ensuring consistent environments across development machines.
