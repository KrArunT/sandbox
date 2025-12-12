FROM python:3.11-slim

# Install dependencies for installing other tools
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.cargo/bin:$PATH"

# Install Node.js and npm (LTS version)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Install nvm
ENV NVM_DIR /root/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Working directory
WORKDIR /app

# Copy python dependencies
COPY requirements.txt .

# Install python dependencies using uv (as pip replacement)
# uv pip install need a venv usually, but we can install to system or create one.
# Simplest for docker is to create a venv or use --system if uv supports it cleanly in newer versions, 
# strictly speaking uv pip install --system is essentially 'uv pip install --python /usr/bin/python3'.
# But standard practice with uv is often just 'uv pip install -r requirements.txt --system'
RUN uv pip install --system --no-cache -r requirements.txt

# Copy application
COPY . .

# Expose port 7860 for HF Spaces
EXPOSE 7860

# Command to run
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "7860"]
