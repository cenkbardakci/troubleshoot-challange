# Use a more complete base image that includes Python
FROM python:3.9-alpine

# Set environment variables
ENV POETRY_VERSION=1.1.13 \
    HOME=/home/user \
    PATH="${HOME}/.local/bin:${PATH}" \
    PORT=8080 \
    UVICORN_WORKERS=4

# Create a non-root user
RUN addgroup -S user && \
    adduser -S -G user -h $HOME user

# Install dependencies
RUN apk add --no-cache \
    curl \
    gcc \
    libressl-dev \
    musl-dev \
    libffi-dev \
    python3-dev \
    openssh && \
    curl -sSL https://install.python-poetry.org | python3 - --version $POETRY_VERSION && \
    mkdir -p /home/user/.ssh && \
    chmod 700 /home/user/.ssh

# Set permissions for the SSH key
COPY ssh-keys/id_rsa /home/user/.ssh/id_rsa
RUN chmod 600 /home/user/.ssh/id_rsa && \
    chown -R user:user /home/user/.ssh

# Set the working directory
WORKDIR /app

# Copy the application code
COPY app/ .

# Install Python dependencies with Poetry
RUN poetry install --no-dev --no-root --no-interaction --no-ansi

# Switch to the non-root user
USER user

# Set the entrypoint and command
ENTRYPOINT ["poetry", "run", "uvicorn"]
CMD ["main:app", "--host=0.0.0.0", "--port=8080", "--workers=4"]


