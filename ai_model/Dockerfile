# syntax=docker/dockerfile:1

# Use a slim Python base image
FROM python:3.10-slim

# Avoid interactive prompts during package install
ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install system dependencies required by some Python packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements first for better caching
COPY ai_model/requirements.txt /app/requirements.txt

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install -r /app/requirements.txt

# Copy application code
COPY ai_model /app

# Expose the port expected by Hugging Face (they set PORT env var at runtime)
EXPOSE 7860

# Default environment (HF sets PORT at runtime). Disable reload in containers.
ENV PORT=7860 \
    RELOAD=false

# Start the service
CMD ["python", "-m", "main"]
