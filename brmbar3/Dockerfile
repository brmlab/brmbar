FROM debian:bookworm-slim

# Install dependencies including PostgreSQL server (newer version)
RUN apt-get update && apt-get install -y \
    python3 \
    python3-psycopg2 \
    postgresql \
    postgresql-client \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for running the application (matching INSTALL.md)
RUN useradd -m -s /bin/bash brmuser

# Give brmuser permissions to manage postgresql service
RUN echo "brmuser ALL=(ALL) NOPASSWD: /usr/sbin/service postgresql start, /usr/sbin/service postgresql stop, /usr/sbin/service postgresql status" > /etc/sudoers.d/brmuser && \
    echo "brmuser ALL=(postgres) NOPASSWD: ALL" >> /etc/sudoers.d/brmuser && \
    chmod 0440 /etc/sudoers.d/brmuser

# Create working directory
WORKDIR /app

# Copy application files
COPY . /app/

# Setup entrypoint script
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set proper permissions
RUN chown -R brmuser:brmuser /app

# Switch to non-root user
USER brmuser

ENTRYPOINT ["/entrypoint.sh"]
CMD ["test"]