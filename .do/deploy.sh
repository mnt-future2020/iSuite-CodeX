#!/bin/bash
set -e

echo "🚀 Starting DigitalOcean deployment build..."

# Check Python version
echo "📦 Python version:"
python3 --version

# Install Poetry if not available
if ! command -v poetry &> /dev/null; then
    echo "📥 Installing Poetry..."
    curl -sSL https://install.python-poetry.org | python3 -
    export PATH="/root/.local/bin:$PATH"
fi

# Install Python dependencies
echo "📦 Installing Python dependencies..."
cd /workspace
poetry config virtualenvs.create false
poetry install --without evaluation --without llama-index

# Install frontend dependencies and build
echo "🎨 Building frontend..."
cd frontend
npm install
npm run build

echo "✅ Build completed successfully!"
