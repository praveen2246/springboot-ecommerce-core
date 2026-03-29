#!/bin/bash
# Database Backup and Restore Script for PostgreSQL
# Usage: ./scripts/backup-restore.sh [backup|restore] [options]

set -e

# Default values
DB_HOST=localhost
DB_PORT=5432
DB_NAME=ecommerce
DB_USER=postgres
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_backup_${TIMESTAMP}.sql"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Functions
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

show_help() {
    cat << EOF
Database Backup and Restore Script

Usage: ./backup-restore.sh [command] [options]

Commands:
  backup      Create a new database backup
  restore     Restore from a backup file
  list        List all existing backups
  clean       Remove old backups (keep last 7)
  help        Show this help message

Backup Options:
  --host      PostgreSQL host (default: localhost)
  --port      PostgreSQL port (default: 5432)
  --db        Database name (default: ecommerce)
  --user      PostgreSQL user (default: postgres)
  --dir       Backup directory (default: ./backups)

Restore Options:
  --file      Path to backup file (required)
  --host      PostgreSQL host (default: localhost)
  --port      PostgreSQL port (default: 5432)
  --db        Database name (default: ecommerce)
  --user      PostgreSQL user (default: postgres)

Examples:
  # Create a backup
  ./backup-restore.sh backup
  
  # Create a backup with custom database
  ./backup-restore.sh backup --db mydb --user admin
  
  # List all backups
  ./backup-restore.sh list
  
  # Restore from specific backup
  ./backup-restore.sh restore --file ./backups/ecommerce_backup_20240101_120000.sql
  
  # Clean old backups (keep last 7)
  ./backup-restore.sh clean

EOF
}

create_backup() {
    print_info "Creating database backup..."
    print_info "Database: $DB_NAME"
    print_info "Host: $DB_HOST:$DB_PORT"
    print_info "User: $DB_USER"
    print_info "Backup file: $BACKUP_FILE"
    
    # Create backup directory if it doesn't exist
    mkdir -p "$BACKUP_DIR"
    
    # Check PostgreSQL connection
    if ! PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "SELECT 1" > /dev/null 2>&1; then
        print_error "Cannot connect to PostgreSQL"
        return 1
    fi
    
    # Create backup
    if PGPASSWORD=$PGPASSWORD pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME > "$BACKUP_FILE" 2>/dev/null; then
        SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
        print_success "Backup created: $BACKUP_FILE ($SIZE)"
        return 0
    else
        print_error "Failed to create backup"
        return 1
    fi
}

restore_backup() {
    if [ -z "$RESTORE_FILE" ]; then
        print_error "Restore file not specified. Use --file option"
        exit 1
    fi
    
    if [ ! -f "$RESTORE_FILE" ]; then
        print_error "Backup file not found: $RESTORE_FILE"
        exit 1
    fi
    
    print_info "Restoring database from backup..."
    print_info "Backup file: $RESTORE_FILE"
    print_info "Target database: $DB_NAME"
    
    # Check PostgreSQL connection
    if ! PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "SELECT 1" > /dev/null 2>&1; then
        print_error "Cannot connect to PostgreSQL"
        return 1
    fi
    
    # Drop existing database if it exists
    print_info "Dropping existing database..."
    PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "DROP DATABASE IF EXISTS $DB_NAME;" 2>/dev/null || true
    
    # Create new database
    print_info "Creating new database..."
    PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "CREATE DATABASE $DB_NAME;" 2>/dev/null
    
    # Restore from backup
    if PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME < "$RESTORE_FILE" > /dev/null 2>&1; then
        print_success "Database restored successfully"
        return 0
    else
        print_error "Failed to restore database"
        return 1
    fi
}

list_backups() {
    if [ ! -d "$BACKUP_DIR" ]; then
        print_info "No backup directory found: $BACKUP_DIR"
        return 0
    fi
    
    BACKUP_COUNT=$(find "$BACKUP_DIR" -name "${DB_NAME}_backup_*.sql" 2>/dev/null | wc -l)
    
    if [ $BACKUP_COUNT -eq 0 ]; then
        print_info "No backups found in $BACKUP_DIR"
        return 0
    fi
    
    print_info "Available backups ($BACKUP_COUNT total):"
    echo ""
    
    ls -lh "$BACKUP_DIR"/${DB_NAME}_backup_*.sql 2>/dev/null | while read -r line; do
        FILE=$(echo "$line" | awk '{print $NF}')
        SIZE=$(echo "$line" | awk '{print $5}')
        DATE=$(echo "$line" | awk '{print $6, $7, $8}')
        FILENAME=$(basename "$FILE")
        echo "  $FILENAME ($SIZE) - $DATE"
    done
}

clean_old_backups() {
    if [ ! -d "$BACKUP_DIR" ]; then
        print_info "No backup directory found: $BACKUP_DIR"
        return 0
    fi
    
    KEEP=7
    BACKUP_COUNT=$(find "$BACKUP_DIR" -name "${DB_NAME}_backup_*.sql" 2>/dev/null | wc -l)
    DELETE_COUNT=$((BACKUP_COUNT - KEEP))
    
    if [ $DELETE_COUNT -le 0 ]; then
        print_info "Already have $BACKUP_COUNT backups (keeping $KEEP)"
        return 0
    fi
    
    print_info "Removing $DELETE_COUNT old backup(s), keeping the last $KEEP..."
    
    find "$BACKUP_DIR" -name "${DB_NAME}_backup_*.sql" -type f | sort -r | tail -n +$((KEEP + 1)) | while read -r file; do
        print_info "Deleting: $(basename "$file")"
        rm "$file"
    done
    
    print_success "Cleanup completed"
}

# Parse arguments
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

COMMAND=$1
shift

while [ $# -gt 0 ]; do
    case "$1" in
        --host)
            DB_HOST="$2"
            shift 2
            ;;
        --port)
            DB_PORT="$2"
            shift 2
            ;;
        --db)
            DB_NAME="$2"
            shift 2
            ;;
        --user)
            DB_USER="$2"
            shift 2
            ;;
        --dir)
            BACKUP_DIR="$2"
            shift 2
            ;;
        --file)
            RESTORE_FILE="$2"
            shift 2
            ;;
        --password)
            PGPASSWORD="$2"
            shift 2
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Prompt for password if not provided
if [ -z "$PGPASSWORD" ]; then
    read -s -p "Enter PostgreSQL password for $DB_USER: " PGPASSWORD
    echo ""
fi

# Execute command
case "$COMMAND" in
    backup)
        create_backup
        ;;
    restore)
        restore_backup
        ;;
    list)
        list_backups
        ;;
    clean)
        clean_old_backups
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $COMMAND"
        echo ""
        show_help
        exit 1
        ;;
esac

echo ""
