FROM alpine:3.15

ENV POETRY_VERSION=1.1.13 \
    HOME=/home/user \
    PATH="${HOME}/.local/bin:${PATH}"

# Create user and install dependencies
RUN addgroup -S user && adduser -S -G user -h $HOME -s /bin/sh user &&\
    apk add --no-cache --virtual .build-deps \
        gcc \
        libressl-dev \
        musl-dev \
        libffi-dev \
        python3-dev &&\
    apk add --no-cache \
        curl \
        python3 &&\
    curl -sSL https://install.python-poetry.org | python3 - --version $POETRY_VERSION &&\
    apk del .build-deps

# Copy application code
COPY app/ /app/

# Install Python dependencies with Poetry
RUN cd /app && poetry install --no-dev --no-root --no-interaction --no-ansi --no-cache

# Switch to non-root user
USER user

# Expose port
EXPOSE 8080

# Entrypoint and CMD
ENTRYPOINT ["poetry", "run"]
CMD ["sh", "-c", "uvicorn --host=0.0.0.0 --port=${PORT} --workers=${UVICORN_WORKERS}"]
