#!/bin/bash
# Health Check Script for E-Commerce Platform
# Monitors backend, frontend, and database health

# Configuration
BACKEND_URL=${BACKEND_URL:-http://localhost:8080}
FRONTEND_URL=${FRONTEND_URL:-http://localhost:5173}
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}
DB_NAME=${DB_NAME:-ecommerce}
DB_USER=${DB_USER:-postgres}
CHECK_INTERVAL=${CHECK_INTERVAL:-30}
LOG_FILE=${LOG_FILE:-./health-check.log}

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Functions
log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        INFO)
            echo -e "${BLUE}[INFO]${NC} $message" | tee -a "$LOG_FILE"
            ;;
        SUCCESS)
            echo -e "${GREEN}[SUCCESS]${NC} $message" | tee -a "$LOG_FILE"
            ((PASSED++))
            ;;
        WARNING)
            echo -e "${YELLOW}[WARNING]${NC} $message" | tee -a "$LOG_FILE"
            ((WARNINGS++))
            ;;
        ERROR)
            echo -e "${RED}[ERROR]${NC} $message" | tee -a "$LOG_FILE"
            ((FAILED++))
            ;;
    esac
}

check_backend() {
    log INFO "Checking backend health..."
    
    if curl -s "$BACKEND_URL/actuator/health" > /dev/null 2>&1; then
        RESPONSE=$(curl -s "$BACKEND_URL/actuator/health" | grep -q '"status":"UP"')
        if [ $? -eq 0 ]; then
            log SUCCESS "Backend health check passed"
            return 0
        else
            log WARNING "Backend is responding but status is not UP"
            return 1
        fi
    else
        log ERROR "Backend health check failed (Connection refused)"
        return 1
    fi
}

check_backend_endpoints() {
    log INFO "Checking backend endpoints..."
    
    # Check API health
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BACKEND_URL/api/products")
    if [ "$HTTP_CODE" = "200" ]; then
        log SUCCESS "Products API is responding (HTTP $HTTP_CODE)"
    else
        log WARNING "Products API returned HTTP $HTTP_CODE"
    fi
    
    # Check Swagger endpoint
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BACKEND_URL/swagger-ui.html")
    if [ "$HTTP_CODE" = "200" ]; then
        log SUCCESS "Swagger UI is accessible (HTTP $HTTP_CODE)"
    else
        log WARNING "Swagger UI returned HTTP $HTTP_CODE"
    fi
}

check_frontend() {
    log INFO "Checking frontend health..."
    
    if curl -s "$FRONTEND_URL" > /dev/null 2>&1; then
        log SUCCESS "Frontend is responding"
        return 0
    else
        log ERROR "Frontend health check failed"
        return 1
    fi
}

check_database() {
    log INFO "Checking database connection..."
    
    if [ -z "$PGPASSWORD" ]; then
        log WARNING "Database password not set, skipping database check"
        return 0
    fi
    
    if PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "SELECT 1" > /dev/null 2>&1; then
        log SUCCESS "Database connection successful"
        
        # Check if ecommerce database exists
        if PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" | grep -q "1"; then
            log SUCCESS "Database '$DB_NAME' exists"
            
            # Count tables
            TABLE_COUNT=$(PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public';" 2>/dev/null | grep -oE '[0-9]+' | head -1)
            log SUCCESS "Database has $TABLE_COUNT tables"
        else
            log ERROR "Database '$DB_NAME' not found"
            return 1
        fi
        return 0
    else
        log ERROR "Database connection failed"
        return 1
    fi
}

check_docker() {
    log INFO "Checking Docker services..."
    
    if ! command -v docker-compose &> /dev/null; then
        log WARNING "Docker Compose not installed"
        return 0
    fi
    
    if docker-compose ps 2>/dev/null | grep -q "postgres"; then
        POSTGRES_STATUS=$(docker-compose ps postgres 2>/dev/null | grep -q "Up")
        if [ $? -eq 0 ]; then
            log SUCCESS "PostgreSQL container is running"
        else
            log ERROR "PostgreSQL container is not running"
        fi
    fi
    
    if docker-compose ps 2>/dev/null | grep -q "backend"; then
        BACKEND_STATUS=$(docker-compose ps backend 2>/dev/null | grep -q "Up")
        if [ $? -eq 0 ]; then
            log SUCCESS "Backend container is running"
        else
            log ERROR "Backend container is not running"
        fi
    fi
}

check_system_resources() {
    log INFO "Checking system resources..."
    
    if [ -f /proc/loadavg ]; then
        LOAD=$(cat /proc/loadavg | awk '{print $1}')
        log INFO "System load average: $LOAD"
    fi
    
    if command -v free &> /dev/null; then
        MEMORY=$(free | grep Mem | awk '{printf("%.2f%%", ($3/$2) * 100)}')
        log INFO "Memory usage: $MEMORY"
    fi
}

generate_report() {
    log INFO "Health check report"
    log INFO "===================="
    log INFO "Timestamp: $(date)"
    log INFO "Backend URL: $BACKEND_URL"
    log INFO "Frontend URL: $FRONTEND_URL"
    log INFO "Database: $DB_HOST:$DB_PORT/$DB_NAME"
    log INFO ""
    log INFO "Results Summary:"
    log INFO "  Passed:  $PASSED"
    log INFO "  Warnings: $WARNINGS"
    log INFO "  Failed:  $FAILED"
    log INFO "===================="
}

show_help() {
    cat << EOF
Health Check Script for E-Commerce Platform

Usage: ./health-check.sh [options]

Options:
  --backend-url URL     Backend URL (default: http://localhost:8080)
  --frontend-url URL    Frontend URL (default: http://localhost:5173)
  --db-host HOST        Database host (default: localhost)
  --db-port PORT        Database port (default: 5432)
  --db-name NAME        Database name (default: ecommerce)
  --db-user USER        Database user (default: postgres)
  --db-password PASSWORD Database password (required for DB check)
  --interval SECONDS    Check interval for continuous monitoring
  --log-file FILE       Log file path (default: ./health-check.log)
  --continuous          Run continuous health checks
  --docker              Check Docker container status
  --help                Show this help message

Examples:
  # Single health check
  ./health-check.sh
  
  # With database password
  ./health-check.sh --db-password mypassword
  
  # Continuous monitoring
  ./health-check.sh --continuous --interval 60
  
  # Check Docker containers
  ./health-check.sh --docker

EOF
}

# Parse arguments
CONTINUOUS=false
CHECK_DOCKER=false

while [ $# -gt 0 ]; do
    case "$1" in
        --backend-url)
            BACKEND_URL="$2"
            shift 2
            ;;
        --frontend-url)
            FRONTEND_URL="$2"
            shift 2
            ;;
        --db-host)
            DB_HOST="$2"
            shift 2
            ;;
        --db-port)
            DB_PORT="$2"
            shift 2
            ;;
        --db-name)
            DB_NAME="$2"
            shift 2
            ;;
        --db-user)
            DB_USER="$2"
            shift 2
            ;;
        --db-password)
            PGPASSWORD="$2"
            shift 2
            ;;
        --interval)
            CHECK_INTERVAL="$2"
            shift 2
            ;;
        --log-file)
            LOG_FILE="$2"
            shift 2
            ;;
        --continuous)
            CONTINUOUS=true
            shift
            ;;
        --docker)
            CHECK_DOCKER=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Main logic
echo "E-Commerce Platform Health Check"
echo "Using log file: $LOG_FILE"
echo ""

if [ "$CONTINUOUS" = true ]; then
    log INFO "Starting continuous health checks (interval: ${CHECK_INTERVAL}s)"
    while true; do
        PASSED=0
        FAILED=0
        WARNINGS=0
        check_backend
        check_backend_endpoints
        check_frontend
        check_database
        if [ "$CHECK_DOCKER" = true ]; then
            check_docker
        fi
        check_system_resources
        generate_report
        echo ""
        sleep $CHECK_INTERVAL
    done
else
    check_backend
    check_backend_endpoints
    check_frontend
    check_database
    if [ "$CHECK_DOCKER" = true ]; then
        check_docker
    fi
    check_system_resources
    generate_report
fi
