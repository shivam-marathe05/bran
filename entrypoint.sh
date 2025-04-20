#!/bin/sh
set -e

# Apply DB migrations
echo "=> Applying database migrations…"
python manage.py migrate --noinput

# Then exec the CMD from the Dockerfile
exec "$@"

