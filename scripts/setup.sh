#!/bin/bash
# Quick Setup Script for E-Commerce Platform
# Automates initial setup for developers

set -e

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}════════════════════════════════════════════${NC}"
    echo ""
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

print_step() {
    echo ""
    echo -e "${BLUE}→ $1${NC}"
}

check_command() {
    if command -v $1 &> /dev/null; then
        return 0
    else
        return 1
    fi
}

install_java() {
    print_step "Installing Java..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update
        sudo apt-get install -y openjdk-17-jdk
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install java@17
    else
        print_error "Please install Java 17 manually"
        return 1
    fi
    
    print_success "Java installed"
}

install_nodejs() {
    print_step "Installing Node.js..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install node@18
    else
        print_error "Please install Node.js 18 manually"
        return 1
    fi
    
    print_success "Node.js installed"
}

install_maven() {
    print_step "Installing Maven..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get install -y maven
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install maven
    else
        print_error "Please install Maven manually"
        return 1
    fi
    
    print_success "Maven installed"
}

install_docker() {
    print_step "Installing Docker..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        rm get-docker.sh
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install docker docker-compose
    else
        print_error "Please install Docker manually from https://www.docker.com/products/docker-desktop"
        return 1
    fi
    
    print_success "Docker installed"
}

install_postgresql() {
    print_step "Installing PostgreSQL..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get install -y postgresql postgresql-contrib
        sudo systemctl start postgresql
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install postgresql
        brew services start postgresql
    else
        print_error "Please install PostgreSQL manually"
        return 1
    fi
    
    print_success "PostgreSQL installed and started"
}

setup_backend() {
    print_step "Setting up backend..."
    
    cd ecommerce-backend/ecommerce-backend
    
    # Create .env file if it doesn't exist
    if [ ! -f .env ]; then
        print_warning "Creating .env file with default values"
        cat > .env << EOF
# Spring Boot Configuration
SPRING_PROFILES_ACTIVE=dev

# Database Configuration
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/ecommerce
SPRING_DATASOURCE_USERNAME=postgres
SPRING_DATASOURCE_PASSWORD=postgres

# Razorpay Configuration
RAZORPAY_KEY_ID=rzp_test_SX0HsSL3fbdppU
RAZORPAY_KEY_SECRET=56qR9eMxCmCoRxc64t05c4X9

# Email Configuration
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password

# JWT Configuration
JWT_SECRET=your-secret-key-change-this-in-production

# File Upload Configuration
FILE_UPLOAD_DIR=uploads/
EOF
        print_success ".env file created"
        print_warning "Please update email credentials in .env file"
    fi
    
    # Build backend
    print_info "Building backend with Maven..."
    mvn clean package -DskipTests -q
    
    cd ../..
    print_success "Backend setup complete"
}

setup_frontend() {
    print_step "Setting up frontend..."
    
    cd ecommerce-frontend
    
    # Install dependencies
    print_info "Installing frontend dependencies..."
    npm install --silent
    
    # Create .env file if it doesn't exist
    if [ ! -f .env.local ]; then
        print_warning "Creating .env.local file"
        cat > .env.local << EOF
VITE_API_BASE_URL=http://localhost:8080
VITE_APP_NAME=E-Commerce Platform
VITE_APP_VERSION=1.0.0
EOF
        print_success ".env.local file created"
    fi
    
    cd ..
    print_success "Frontend setup complete"
}

setup_database() {
    print_step "Setting up database..."
    
    if ! check_command psql; then
        print_warning "PostgreSQL CLI not found. Attempting to initialize database..."
        if [ -f scripts/postgres-init.sh ]; then
            bash scripts/postgres-init.sh
        else
            print_error "Could not find postgres-init.sh"
        fi
    else
        # Initialize database
        print_info "Initializing PostgreSQL database..."
        psql -h localhost -U postgres -c "CREATE DATABASE ecommerce;" 2>/dev/null || print_warning "Database might already exist"
        psql -h localhost -U postgres -d ecommerce -f scripts/init-db.sql
    fi
    
    print_success "Database setup complete"
}

verify_setup() {
    print_header "Verifying Setup"
    
    FAILED=0
    
    # Check Java
    if check_command java; then
        JAVA_VERSION=$(java -version 2>&1 | head -1)
        print_success "Java: $JAVA_VERSION"
    else
        print_error "Java not found"
        FAILED=$((FAILED + 1))
    fi
    
    # Check Node.js
    if check_command node; then
        NODE_VERSION=$(node --version)
        print_success "Node.js: $NODE_VERSION"
    else
        print_error "Node.js not found"
        FAILED=$((FAILED + 1))
    fi
    
    # Check Maven
    if check_command mvn; then
        print_success "Maven found"
    else
        print_error "Maven not found"
        FAILED=$((FAILED + 1))
    fi
    
    # Check project structure
    if [ -d "ecommerce-backend" ] && [ -d "ecommerce-frontend" ]; then
        print_success "Project structure valid"
    else
        print_error "Project structure invalid"
        FAILED=$((FAILED + 1))
    fi
    
    if [ $FAILED -eq 0 ]; then
        print_success "All verifications passed!"
        return 0
    else
        print_warning "$FAILED verification(s) failed"
        return 1
    fi
}

show_next_steps() {
    print_header "Setup Complete! 🎉"
    
    echo "Next steps to start developing:"
    echo ""
    echo "1. Update configuration files:"
    echo "   - ecommerce-backend/ecommerce-backend/.env (email credentials)"
    echo "   - ecommerce-frontend/.env.local (API URL if needed)"
    echo ""
    echo "2. Start the backend (in one terminal):"
    echo "   cd ecommerce-backend/ecommerce-backend"
    echo "   mvn spring-boot:run"
    echo ""
    echo "3. Start the frontend (in another terminal):"
    echo "   cd ecommerce-frontend"
    echo "   npm run dev"
    echo ""
    echo "4. Open browser and navigate to:"
    echo "   Frontend: http://localhost:5173"
    echo "   Backend: http://localhost:8080"
    echo "   API Docs: http://localhost:8080/swagger-ui.html"
    echo ""
    echo "5. Optional - Run health check:"
    echo "   ./scripts/health-check.sh --db-password postgres"
    echo ""
    echo "Documentation:"
    echo "   - README.md - Main documentation"
    echo "   - docs/API.md - API reference"
    echo "   - scripts/README.md - Script documentation"
    echo ""
}

# Main execution
main() {
    print_header "E-Commerce Platform - Quick Setup"
    
    # Check if we're in the right directory
    if [ ! -f "README.md" ] || [ ! -d "ecommerce-backend" ]; then
        print_error "Please run this script from the project root directory"
        exit 1
    fi
    
    # Parse arguments
    SKIP_INSTALL=false
    for arg in "$@"; do
        if [ "$arg" = "--skip-install" ]; then
            SKIP_INSTALL=true
        fi
    done
    
    if [ "$SKIP_INSTALL" = false ]; then
        # Check and install prerequisites
        print_header "Checking Prerequisites"
        
        if ! check_command java; then
            print_warning "Java not found"
            install_java || exit 1
        else
            print_success "Java found: $(java -version 2>&1 | head -1)"
        fi
        
        if ! check_command node; then
            print_warning "Node.js not found"
            install_nodejs || exit 1
        else
            print_success "Node.js found: $(node --version)"
        fi
        
        if ! check_command mvn; then
            print_warning "Maven not found"
            install_maven || exit 1
        else
            print_success "Maven found"
        fi
        
        # Optional Docker installation
        if ! check_command docker; then
            read -p "Do you want to install Docker? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                install_docker || print_warning "Docker installation failed, continuing without Docker"
            fi
        else
            print_success "Docker found: $(docker --version)"
        fi
        
        # PostgreSQL installation
        if ! check_command psql; then
            read -p "Do you want to install PostgreSQL? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                install_postgresql || print_warning "PostgreSQL installation failed"
            fi
        else
            print_success "PostgreSQL found"
        fi
    else
        print_info "Skipping dependency installation"
    fi
    
    # Setup project
    print_header "Setting Up Project"
    
    setup_backend
    setup_frontend
    
    # Database setup
    read -p "Initialize database? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_database
    fi
    
    # Verify setup
    verify_setup
    
    # Show next steps
    show_next_steps
}

# Run main function
main "$@"
