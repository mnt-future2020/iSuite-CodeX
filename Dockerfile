FROM python:3.13-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN pip install poetry==1.8.2

# Copy only dependency files first (for better caching)
COPY pyproject.toml poetry.lock ./

# Install Python dependencies
RUN poetry config virtualenvs.create false \
    && poetry install --without evaluation --without llama-index --no-interaction --no-ansi

# Copy frontend package files
COPY frontend/package*.json ./frontend/

# Install frontend dependencies
RUN cd frontend && npm ci

# Copy the rest of the application
COPY . .

# Build frontend
RUN cd frontend && npm run build

# Create workspace directory
RUN mkdir -p /workspace

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
    CMD curl -f http://localhost:3000/api/options/models || exit 1

# Start the application
CMD ["uvicorn", "openhands.server.listen:app", "--host", "0.0.0.0", "--port", "3000"]
