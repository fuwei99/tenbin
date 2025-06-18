# This Dockerfile is for deploying on Hugging Face Spaces.
# It pulls a private, pre-built image from GHCR and runs both services using supervisord.

# 1. Pull the base image.
# IMPORTANT: You must set DOCKER_USERNAME and DOCKER_PASSWORD as secrets in your Space settings
# for this to work with a private repository.
FROM ghcr.io/fuwei99/tenbin:main

# 2. Install supervisord to manage multiple processes.
USER root
RUN apt-get update && \
    apt-get install -y supervisor && \
    rm -rf /var/lib/apt/lists/*

# 3. Create the supervisor configuration file.
# This file defines how to run the turnstile-solver and the main api adapter.
RUN echo "[supervisord]" > /etc/supervisor/conf.d/supervisord.conf && \
    echo "nodaemon=true\n" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "[program:turnstile-solver]" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "command=xvfb-run -a python3 /app/Turnstile-Solver/api_solver.py --browser_type chrome --host 0.0.0.0 --port 5000" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "directory=/app/Turnstile-Solver" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "autostart=true" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "stdout_logfile=/dev/stdout" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "stdout_logfile_maxbytes=0" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "stderr_logfile=/dev/stderr" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "stderr_logfile_maxbytes=0\n" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "[program:api-adapter]" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "command=uvicorn main:app --host 0.0.0.0 --port 8000" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "directory=/app" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "autostart=true" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "stdout_logfile=/dev/stdout" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "stdout_logfile_maxbytes=0" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "stderr_logfile=/dev/stderr" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "stderr_logfile_maxbytes=0" >> /etc/supervisor/conf.d/supervisord.conf

# 4. Configuration is now handled by environment variables (Secrets) in the Hugging Face Space.
# No need to copy JSON files anymore.

# 5. Set the entrypoint to run supervisord.
# This will start and manage both services.
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
