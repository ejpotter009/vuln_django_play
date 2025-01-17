#!/usr/bin/env bash
# Build and run vuln-django with Nginx and PostgreSQL

set -ex

# We'll use this 'docker-compose exec command a lot...
MSTR_CMD='docker-compose --file docker-micro.yml exec vuln-django'
EXEC_CMD="${MSTR_CMD} python manage.py"

# Build docker images
docker-compose -f docker-micro.yml build

# Launch the app stack
docker-compose -f docker-micro.yml up --detach

# Wait for the database, using netcat to ping it
echo "Wait for database to become available..."
#while ! ${MSTR_CMD} bash -c 'nc -z "${SQL_HOST}" "${SQL_PORT}"'; do
sleep 1.5
#done
echo Database ready!

# Run database migrations to build tables
${EXEC_CMD} migrate

# Create Django admin user from environment variables
${EXEC_CMD} createsuperuser --no-input

# See database with test data
${EXEC_CMD} seed polls --number=7

# Run unit tests
${EXEC_CMD} test
