#!/bin/bash
# Development Utilities Script
# Common tasks for development

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Functions
clean() {
    print_info "Cleaning project..."
    
    # Clean Maven builds
    print_info "Cleaning Maven artifacts..."
    cd "$PROJECT_ROOT/ecommerce-backend/ecommerce-backend"
    mvn clean -q
    
    # Clean Node modules (optional, keep for faster rebuild)
    if [ "$1" == "--full" ]; then
        print_info "Cleaning Node modules..."
        cd "$PROJECT_ROOT/ecommerce-frontend"
        rm -rf node_modules
        rm -rf .dist
    fi
    
    cd "$PROJECT_ROOT"
    print_success "Clean complete"
}

rebuild() {
    print_info "Rebuilding project..."
    
    clean
    
    # Build backend
    print_info "Building backend..."
    cd "$PROJECT_ROOT/ecommerce-backend/ecommerce-backend"
    mvn clean package -DskipTests -q
    
    if [ $? -ne 0 ]; then
        print_error "Backend build failed"
        return 1
    fi
    
    # Build frontend
    print_info "Building frontend..."
    cd "$PROJECT_ROOT/ecommerce-frontend"
    npm install --silent
    npm run build --silent
    
    if [ $? -ne 0 ]; then
        print_error "Frontend build failed"
        return 1
    fi
    
    cd "$PROJECT_ROOT"
    print_success "Rebuild complete"
}

run_backend() {
    cd "$PROJECT_ROOT/ecommerce-backend/ecommerce-backend"
    print_info "Starting backend on http://localhost:8080..."
    mvn spring-boot:run
}

run_frontend() {
    cd "$PROJECT_ROOT/ecommerce-frontend"
    print_info "Starting frontend on http://localhost:5173..."
    npm run dev
}

run_tests() {
    print_info "Running tests..."
    
    # Backend tests
    print_info "Running backend tests..."
    cd "$PROJECT_ROOT/ecommerce-backend/ecommerce-backend"
    mvn test -q
    
    if [ $? -ne 0 ]; then
        print_error "Backend tests failed"
        return 1
    fi
    
    # Frontend tests (if configured)
    print_info "Running frontend tests..."
    cd "$PROJECT_ROOT/ecommerce-frontend"
    npm test 2>/dev/null || print_warning "Frontend tests not configured"
    
    cd "$PROJECT_ROOT"
    print_success "Tests complete"
}

format_code() {
    print_info "Formatting code..."
    
    # Format Java code (using Maven plugin)
    print_info "Formatting Java code..."
    cd "$PROJECT_ROOT/ecommerce-backend/ecommerce-backend"
    mvn spotless:apply -q 2>/dev/null || print_warning "Code formatter not configured"
    
    # Format JavaScript/React code
    print_info "Formatting JavaScript code..."
    cd "$PROJECT_ROOT/ecommerce-frontend"
    npm run format 2>/dev/null || print_warning "JavaScript formatter not configured"
    
    cd "$PROJECT_ROOT"
    print_success "Code formatting complete"
}

check_code_quality() {
    print_info "Checking code quality..."
    
    # Run linters
    print_info "Running linters..."
    cd "$PROJECT_ROOT/ecommerce-frontend"
    npm run lint 2>/dev/null || print_warning "Linter not configured"
    
    cd "$PROJECT_ROOT"
    print_success "Code quality check complete"
}

generate_docs() {
    print_info "Generating documentation..."
    
    # Backend Javadoc
    print_info "Generating Javadoc..."
    cd "$PROJECT_ROOT/ecommerce-backend/ecommerce-backend"
    mvn javadoc:javadoc -q 2>/dev/null || print_warning "Javadoc generation skipped"
    
    # Frontend documentation
    print_info "Generating API documentation..."
    cd "$PROJECT_ROOT/ecommerce-frontend"
    npm run docs 2>/dev/null || print_warning "Frontend docs not configured"
    
    cd "$PROJECT_ROOT"
    print_success "Documentation generation complete"
}

view_logs() {
    COMMAND=$1
    
    if [ -z "$COMMAND" ]; then
        COMMAND="docker-compose"
    fi
    
    if [ "$COMMAND" == "docker-compose" ] || [ "$COMMAND" == "docker" ]; then
        print_info "Viewing Docker Compose logs..."
        docker-compose logs -f --tail=100
    else
        print_error "Unknown log command: $COMMAND"
    fi
}

reset_database() {
    print_warning "This will reset your database!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Cancelled"
        return 0
    fi
    
    print_info "Resetting database..."
    
    if command -v psql &> /dev/null; then
        PGPASSWORD=${DB_PASSWORD:-postgres} psql -h localhost -U postgres -d postgres \
            -c "DROP DATABASE IF EXISTS ecommerce;" 2>/dev/null
        PGPASSWORD=${DB_PASSWORD:-postgres} psql -h localhost -U postgres -d postgres \
            -c "CREATE DATABASE ecommerce;" 2>/dev/null
        
        if [ -f "$PROJECT_ROOT/scripts/init-db.sql" ]; then
            PGPASSWORD=${DB_PASSWORD:-postgres} psql -h localhost -U postgres -d ecommerce \
                -f "$PROJECT_ROOT/scripts/init-db.sql" > /dev/null 2>&1
            print_success "Database reset and initialized"
        fi
    else
        print_error "PostgreSQL CLI not found"
        return 1
    fi
}

reset_cache() {
    print_info "Clearing caches..."
    
    # Clear Maven cache
    print_info "Clearing Maven cache..."
    rm -rf ~/.m2/repository 2>/dev/null || print_warning "Could not clear Maven cache"
    
    # Clear npm cache
    print_info "Clearing npm cache..."
    npm cache clean --force 2>/dev/null || print_warning "npm cache already clean"
    
    print_success "Cache cleared"
}

install_dependencies() {
    print_info "Installing/updating dependencies..."
    
    # Backend dependencies
    print_info "Installing backend dependencies..."
    cd "$PROJECT_ROOT/ecommerce-backend/ecommerce-backend"
    mvn dependency:resolve -q
    
    # Frontend dependencies
    print_info "Installing frontend dependencies..."
    cd "$PROJECT_ROOT/ecommerce-frontend"
    npm install --silent
    
    cd "$PROJECT_ROOT"
    print_success "Dependencies installed"
}

update_dependencies() {
    print_info "Checking for dependency updates..."
    
    # Check backend updates
    print_info "Checking Maven dependency updates..."
    cd "$PROJECT_ROOT/ecommerce-backend/ecommerce-backend"
    mvn versions:display-dependency-updates -quiet 2>/dev/null || echo ""
    
    # Check frontend updates
    print_info "Checking npm updates..."
    cd "$PROJECT_ROOT/ecommerce-frontend"
    npm outdated 2>/dev/null || echo ""
    
    cd "$PROJECT_ROOT"
    print_success "Dependency check complete"
}

usage() {
    cat << EOF
Development Utilities Script

Usage: ./utils.sh [command] [options]

Commands:
  clean              Clean build artifacts
  clean --full       Clean artifacts and node_modules
  rebuild            Clean and rebuild entire project
  backend            Start backend (runs on 8080)
  frontend           Start frontend (runs on 5173)
  test               Run all tests
  format             Format code (Java and JavaScript)
  lint               Check code quality
  docs               Generate documentation
  logs               View Docker Compose logs
  reset-db           Reset database to initial state
  clear-cache        Clear Maven and npm caches
  install-deps       Install/update dependencies
  update-deps        Check for dependency updates
  help               Show this help message

Examples:
  ./utils.sh clean
  ./utils.sh rebuild
  ./utils.sh backend
  ./utils.sh frontend
  ./utils.sh test
  ./utils.sh format
  ./utils.sh logs

EOF
}

# Main
cd "$PROJECT_ROOT"

if [ $# -eq 0 ]; then
    usage
    exit 0
fi

case "$1" in
    clean)
        clean "$2"
        ;;
    rebuild)
        rebuild
        ;;
    backend)
        run_backend
        ;;
    frontend)
        run_frontend
        ;;
    test)
        run_tests
        ;;
    format)
        format_code
        ;;
    lint)
        check_code_quality
        ;;
    docs)
        generate_docs
        ;;
    logs)
        view_logs "$2"
        ;;
    reset-db)
        reset_database
        ;;
    clear-cache)
        reset_cache
        ;;
    install-deps)
        install_dependencies
        ;;
    update-deps)
        update_dependencies
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        usage
        exit 1
        ;;
esac
