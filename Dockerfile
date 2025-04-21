FROM python:3.12

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive TZ=UTC PYTHONUNBUFFERED=1

# Set timezone and install dependencies
RUN apt-get update && \
    apt-get install -y tzdata && \
    dpkg-reconfigure -f noninteractive tzdata && \
    rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /app

# Copy only requirements first (better cache reuse)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy only relevant project files
COPY ./backend ./backend
COPY ./entrypoint.sh /entrypoint.sh

# Ensure entrypoint is executable
RUN chmod +x /entrypoint.sh

# Set working directory to backend
WORKDIR /app/backend

# Expose the default Django port
EXPOSE 8000

# Entrypoint
ENTRYPOINT ["/entrypoint.sh"]
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]


