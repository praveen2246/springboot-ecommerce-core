#!/bin/bash
# PostgreSQL Database Initialization Script
# Usage: ./scripts/postgres-init.sh

set -e

echo "🚀 Starting PostgreSQL Database Initialization..."

# PostgreSQL connection variables
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}
DB_NAME=${DB_NAME:-ecommerce}
DB_USER=${DB_USER:-postgres}
DB_PASSWORD=${DB_PASSWORD:-postgres}

# Check if PostgreSQL is running
echo "🔍 Checking PostgreSQL connection..."
if ! PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d postgres -c "SELECT 1" > /dev/null 2>&1; then
    echo "❌ PostgreSQL connection failed. Make sure PostgreSQL is running."
    exit 1
fi

echo "✅ PostgreSQL is running"

# Create database if it doesn't exist
echo "📦 Creating database '$DB_NAME'..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d postgres -c \
    "SELECT 'CREATE DATABASE IF NOT EXISTS $DB_NAME' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$DB_NAME')\gexec" 2>/dev/null || \
    PGPASSWORD=$DB_PASSWORD createdb -h $DB_HOST -U $DB_USER $DB_NAME 2>/dev/null || true

echo "📝 Running initialization script..."
# Run the SQL initialization script
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f scripts/init-db.sql

echo "✅ Database initialization completed successfully!"
echo ""
echo "📊 Database Summary:"
echo "-------------------"
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c \
    "SELECT 
        (SELECT COUNT(*) FROM users) as users,
        (SELECT COUNT(*) FROM categories) as categories,
        (SELECT COUNT(*) FROM products) as products,
        (SELECT COUNT(*) FROM orders) as orders,
        (SELECT COUNT(*) FROM payments) as payments;"

echo ""
echo "🎉 Your e-commerce database is ready!"
echo "Connection details:"
echo "  Host: $DB_HOST"
echo "  Port: $DB_PORT"
echo "  Database: $DB_NAME"
echo "  User: $DB_USER"
