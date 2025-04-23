#!/bin/bash
set -e

# Start PostgreSQL service using sudo
echo "Starting PostgreSQL..."
sudo service postgresql start

# Wait for PostgreSQL to start
echo "Waiting for PostgreSQL to start..."
until sudo -u postgres pg_isready; do
  sleep 1
done
echo "PostgreSQL started"

# Create PostgreSQL user if it doesn't exist (with database creation privileges)
if ! sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='brmuser'" | grep -q 1; then
  echo "Creating PostgreSQL user brmuser with database creation privileges..."
  sudo -u postgres createuser -d brmuser
fi

# Drop and recreate database to ensure clean state
echo "Recreating database..."
sudo -u postgres psql -c 'DROP DATABASE IF EXISTS brmbar;'
createdb brmbar

# Load base schema (following INSTALL.md approach)
echo "Loading base schema..."
psql brmbar < /app/SQL

# Load schema files in order, stopping on first error
echo "Loading schema files..."
for f in /app/schema/[0-9]*-*.sql; do
  echo "Loading schema file: $f"
  if ! psql brmbar -f "$f"; then
    echo "Error loading $f - stopping schema load process"
    break
  fi
done

if [ "$1" == "test" ]; then
  echo "Running tests..."
  
  # Load test data
  echo "Loading test data..."
  psql brmbar < /app/SQL.test
  
  # Run test (as brmuser)
  echo "Running python test..."
  python3 -m pytest # Run pytest as a module
else
  # Run the specified command
  exec "$@"
fi
