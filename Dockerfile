# syntax=docker/dockerfile:1

# Arguments that can be overridden
ARG PYTHON_VERSION=3.13
ARG PYTHON_BASE_IMAGE=slim
ARG APP_USER=appuser
ARG APP_GROUP=appgroup
ARG APP_UID=10001
ARG APP_GID=10001
ARG APP_ROOT=/app

# Build stage
FROM python:${PYTHON_VERSION}-${PYTHON_BASE_IMAGE} AS builder

# Build arguments
ARG APP_ROOT
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_DEFAULT_TIMEOUT=100

WORKDIR ${APP_ROOT}

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements*.txt ./
RUN --mount=type=cache,target=/root/.cache/pip \
    pip wheel --no-deps --wheel-dir wheels -r requirements.txt && \
    pip install -r requirements.txt

# Copy only necessary files for collecting static
COPY manage.py .
COPY .env .env
COPY test_project/ test_project/
COPY apidemo/ apidemo/
COPY static/ static/

# Collect static files
RUN python manage.py collectstatic --noinput

# Final stage
FROM python:${PYTHON_VERSION}-${PYTHON_BASE_IMAGE} AS runtime

# Runtime arguments and environment variables
ARG APP_USER
ARG APP_GROUP
ARG APP_UID
ARG APP_GID
ARG APP_ROOT

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    APP_ROOT=${APP_ROOT}

WORKDIR ${APP_ROOT}

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create app user and group
RUN groupadd --gid ${APP_GID} ${APP_GROUP} && \
    useradd --uid ${APP_UID} --gid ${APP_GID} --no-create-home --home-dir /nonexistent \
    --shell /sbin/nologin --system ${APP_USER}

# Create necessary directories with proper permissions
RUN mkdir -p ${APP_ROOT}/static ${APP_ROOT}/media /var/run/django && \
    chown -R ${APP_USER}:${APP_GROUP} ${APP_ROOT} /var/run/django

# Copy wheels and install dependencies
COPY --from=builder ${APP_ROOT}/wheels /wheels
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-cache-dir /wheels/*

# Copy application code and static files
COPY --chown=${APP_USER}:${APP_GROUP} . .
COPY --from=builder --chown=${APP_USER}:${APP_GROUP} ${APP_ROOT}/static ${APP_ROOT}/static

# Copy and set up entrypoint
COPY --chown=${APP_USER}:${APP_GROUP} docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set up health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=30s \
    CMD curl -f http://localhost:8000/health/ || exit 1

# Set default environment variables for Gunicorn
ENV GUNICORN_WORKERS=4 \
    GUNICORN_THREADS=2 \
    GUNICORN_WORKER_CLASS=gthread \
    GUNICORN_MAX_REQUESTS=1000 \
    GUNICORN_MAX_REQUESTS_JITTER=50

# Switch to non-privileged user
USER ${APP_USER}:${APP_GROUP}

EXPOSE 8000

ENTRYPOINT ["docker-entrypoint.sh"]
CMD gunicorn \
    --workers=${GUNICORN_WORKERS} \
    --threads=${GUNICORN_THREADS} \
    --worker-class=${GUNICORN_WORKER_CLASS} \
    --bind=0.0.0.0:8000 \
    --max-requests=${GUNICORN_MAX_REQUESTS} \
    --max-requests-jitter=${GUNICORN_MAX_REQUESTS_JITTER} \
    test_project.wsgi:application
