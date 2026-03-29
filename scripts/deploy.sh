#!/bin/bash
# E-Commerce Platform Deployment Script
# Supports local development, Docker, and cloud deployments
# Usage: ./scripts/deploy.sh [environment] [options]

set -e

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT=${1:-local}
VERBOSE=false

# Functions
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

show_help() {
    cat << EOF
E-Commerce Platform Deployment Script v$VERSION

Usage: ./deploy.sh [environment] [options]

Environments:
  local           Deploy for local development (default)
  docker          Deploy using Docker Compose
  production      Deploy to production server
  aws             Deploy to AWS (EC2/ECS)
  heroku          Deploy to Heroku
  azure           Deploy to Azure

Options:
  --verbose, -v   Enable verbose output
  --dry-run       Show what would be executed without running
  --skip-tests    Skip running tests before deployment
  --help, -h      Show this help message

Examples:
  ./deploy.sh local
  ./deploy.sh docker --verbose
  ./deploy.sh production --skip-tests

EOF
}

# Parse arguments
SKIP_TESTS=false
DRY_RUN=false

for arg in "${@:2}"; do
    case $arg in
        --verbose|-v) VERBOSE=true ;;
        --dry-run) DRY_RUN=true ;;
        --skip-tests) SKIP_TESTS=true ;;
        --help|-h) show_help; exit 0 ;;
        *) print_warning "Unknown option: $arg" ;;
    esac
done

run_command() {
    local cmd="$1"
    local description="$2"
    
    if [ "$VERBOSE" = true ]; then
        print_info "Running: $cmd"
    fi
    
    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY-RUN] $cmd"
        return 0
    fi
    
    echo "  $description..."
    if eval "$cmd" > /dev/null 2>&1; then
        print_success "$description"
    else
        print_error "Failed: $description"
        return 1
    fi
}

# Deployment functions
deploy_local() {
    print_header "Local Development Deployment"
    
    print_info "Environment: Local Development"
    print_info "Database: H2 (in-memory)"
    print_info "Frontend: Vite dev server (http://localhost:5173)"
    print_info "Backend: Spring Boot (http://localhost:8080)"
    
    cd "$PROJECT_ROOT"
    
    # Check prerequisites
    print_info "Checking prerequisites..."
    
    if ! command -v java &> /dev/null; then
        print_error "Java is not installed"
        exit 1
    fi
    JDK_VERSION=$(java -version 2>&1 | head -1)
    print_success "Java found: $JDK_VERSION"
    
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed"
        exit 1
    fi
    NODE_VERSION=$(node --version)
    print_success "Node.js found: $NODE_VERSION"
    
    if ! command -v mvn &> /dev/null; then
        print_error "Maven is not installed"
        exit 1
    fi
    MVN_VERSION=$(mvn --version | head -1)
    print_success "Maven found: $MVN_VERSION"
    
    # Build backend
    echo ""
    print_info "Building backend..."
    cd "$PROJECT_ROOT/ecommerce-backend/ecommerce-backend"
    run_command "mvn clean package -DskipTests -q" "Backend build complete"
    
    # Build frontend
    echo ""
    print_info "Building frontend..."
    cd "$PROJECT_ROOT/ecommerce-frontend"
    run_command "npm install --silent" "Installing frontend dependencies"
    
    # Start services
    echo ""
    print_info "Services ready for local development:"
    print_success "Backend build: ecommerce-backend/ecommerce-backend/target/app.jar"
    print_success "Frontend: Ready for development"
    
    echo ""
    echo "Next steps:"
    echo "1. Start backend:"
    echo "   cd ecommerce-backend/ecommerce-backend"
    echo "   mvn spring-boot:run"
    echo ""
    echo "2. In another terminal, start frontend:"
    echo "   cd ecommerce-frontend"
    echo "   npm run dev"
    echo ""
    echo "3. Open http://localhost:5173 in your browser"
}

deploy_docker() {
    print_header "Docker Deployment"
    
    print_info "Environment: Docker Compose"
    
    cd "$PROJECT_ROOT"
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        exit 1
    fi
    print_success "Docker found: $(docker --version)"
    
    if [ "$DRY_RUN" = false ]; then
        # Start Docker Compose
        print_info "Starting Docker containers..."
        docker-compose up -d
        
        # Wait for services to be ready
        echo ""
        print_info "Waiting for services to be ready..."
        sleep 10
        
        # Show service status
        echo ""
        print_success "Docker Compose is running!"
        docker-compose ps
        
        echo ""
        echo "Services are available at:"
        echo "  Frontend:  http://localhost"
        echo "  Backend:   http://localhost:8080"
        echo "  API Docs:  http://localhost:8080/swagger-ui.html"
        echo "  Database:  localhost:5432 (PostgreSQL)"
        echo ""
        echo "Useful commands:"
        echo "  View logs:     docker-compose logs -f"
        echo "  Stop services: docker-compose down"
        echo "  Rebuild:       docker-compose up --build -d"
    else
        print_info "[DRY-RUN] Would execute: docker-compose up -d"
    fi
}

deploy_production() {
    print_header "Production Deployment"
    
    print_error "Production deployment requires manual configuration"
    echo ""
    echo "Steps to deploy to production:"
    echo ""
    echo "1. Choose your hosting platform (AWS, Azure, Google Cloud, etc.)"
    echo "2. Set up PostgreSQL database on your hosting platform"
    echo "3. Update environment variables:"
    echo "   - DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD"
    echo "   - RAZORPAY_KEY_ID (set to live Razorpay credentials)"
    echo "   - RAZORPAY_KEY_SECRET (set to live Razorpay credentials)"
    echo "   - MAIL_USERNAME, MAIL_PASSWORD (set to production email)"
    echo "4. Build and push Docker images:"
    echo "   docker build -t yourregistry/ecommerce-backend:latest ./ecommerce-backend"
    echo "   docker build -t yourregistry/ecommerce-frontend:latest ./ecommerce-frontend"
    echo "   docker push yourregistry/ecommerce-backend:latest"
    echo "   docker push yourregistry/ecommerce-frontend:latest"
    echo "5. Deploy using Docker Compose or Kubernetes"
    echo "6. Set up SSL/TLS certificate (Let's Encrypt or your provider)"
    echo "7. Configure DNS and CDN for static assets"
    echo ""
    print_info "See DEPLOYMENT.md for detailed production setup instructions"
}

# Main
case "$ENVIRONMENT" in
    local)
        deploy_local
        ;;
    docker)
        deploy_docker
        ;;
    production)
        deploy_production
        ;;
    aws|heroku|azure)
        print_error "Deployment to $ENVIRONMENT is not yet automated"
        print_info "See deployment documentation for manual setup instructions"
        exit 1
        ;;
    *)
        print_error "Unknown environment: $ENVIRONMENT"
        echo ""
        show_help
        exit 1
        ;;
esac

echo ""
print_success "Deployment script completed!"
