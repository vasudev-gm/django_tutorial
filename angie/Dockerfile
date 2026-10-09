FROM docker.angie.software/angie:latest

# Forward request logs to Docker's log collector.
RUN ln -sf /dev/stdout /var/log/angie/access.log && \
    ln -sf /dev/stderr /var/log/angie/error.log

EXPOSE 80
