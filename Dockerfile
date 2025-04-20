FROM python:3.12

# non‑interactive tzdata install
ENV DEBIAN_FRONTEND=noninteractive TZ=UTC PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y tzdata && dpkg-reconfigure -f noninteractive tzdata && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

# Copy & enable entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
WORKDIR /app/backend

EXPOSE 8000
ENTRYPOINT ["/entrypoint.sh"]
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

