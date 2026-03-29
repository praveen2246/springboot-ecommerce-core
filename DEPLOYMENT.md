# Deployment Guide

Complete guide for deploying the e-commerce platform to different environments.

## 📋 Table of Contents

1. [Local Development Setup](#local-development-setup)
2. [Docker Deployment](#docker-deployment)
3. [Production Deployment](#production-deployment)
4. [Cloud Deployment (AWS, Azure, Heroku)](#cloud-deployment)
5. [Troubleshooting](#troubleshooting)

---

## Local Development Setup

### Prerequisites

- **Java 17+** - [Download](https://adoptopenjdk.net/)
- **Node.js 18+** - [Download](https://nodejs.org/)
- **Maven 3.8+** - [Download](https://maven.apache.org/)
- **PostgreSQL 12+** (optional, uses H2 by default) - [Download](https://www.postgresql.org/)
- **Git** - [Download](https://git-scm.com/)

### Quick Start (Automated)

```bash
# Clone repository
git clone https://github.com/praveen2246/springboot-ecommerce-core.git
cd springboot-ecommerce-core

# Run setup script (Linux/Mac)
./scripts/setup.sh

# Or on Windows
scripts\setup.bat
```

### Manual Setup

#### 1. Backend Setup

```bash
# Navigate to backend directory
cd ecommerce-backend/ecommerce-backend

# Create .env file from template
cp .env.example .env

# Update .env with your configuration
# - Database credentials (if using PostgreSQL)
# - Razorpay test credentials
# - Gmail SMTP credentials

# Build backend
mvn clean package -DskipTests -q

# Start backend
mvn spring-boot:run

# Backend will be available at http://localhost:8080
```

#### 2. Frontend Setup

```bash
# Navigate to frontend directory
cd ecommerce-frontend

# Create .env file from template
cp .env.example .env.local

# Install dependencies
npm install

# Start development server
npm run dev

# Frontend will be available at http://localhost:5173
```

#### 3. Database Setup (Optional - for PostgreSQL)

```bash
# Initialize PostgreSQL database
./scripts/postgres-init.sh

# Or on Windows
scripts\postgres-init.bat
```

### Environment Configuration

#### Backend (.env)

```env
# Database
SPRING_DATASOURCE_URL=jdbc:h2:mem:ecommerce
SPRING_DATASOURCE_USERNAME=sa
SPRING_DATASOURCE_PASSWORD=

# Payment (Razorpay)
RAZORPAY_API_KEY=rzp_test_SX0HsSL3fbdppU
RAZORPAY_API_SECRET=56qR9eMxCmCoRxc64t05c4X9

# Email
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password

# JWT Secret
JWT_SECRET=your-super-secret-key-min-32-chars
```

#### Frontend (.env.local)

```env
VITE_API_BASE_URL=http://localhost:8080
VITE_APP_NAME=E-Commerce Platform
```

### Verification

```bash
# Check backend health
curl http://localhost:8080/actuator/health

# Check API documentation
open http://localhost:8080/swagger-ui.html

# Test login endpoint
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test"}'
```

---

## Docker Deployment

### Prerequisites

- **Docker** - [Download](https://www.docker.com/products/docker-desktop)
- **Docker Compose** - Included with Docker Desktop

### Quick Start

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Services Started

| Service | Port | Purpose |
|---------|------|---------|
| Frontend | 80 | React application |
| Backend | 8080 | Spring Boot API |
| PostgreSQL | 5432 | Database |
| Nginx | 80 | Reverse proxy |

### Configuration

Edit `docker-compose.yml` to customize:

```yaml
environment:
  SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/ecommerce
  SPRING_DATASOURCE_USERNAME: postgres
  SPRING_DATASOURCE_PASSWORD: postgres
  RAZORPAY_API_KEY: your-key
  MAIL_USERNAME: your-email
```

### Accessing Services

```
Frontend:    http://localhost
Backend:     http://localhost:8080
API Docs:    http://localhost:8080/swagger-ui.html
Database:    localhost:5432
```

### Database Persistence

Data is stored in Docker volumes:
- `postgres_data` - Database data persists across restarts
- `backend_uploads` - File uploads from users

To reset database:
```bash
docker volume rm ecommerce-postgres_data
docker-compose up -d postgres
```

---

## Production Deployment

### Prerequisites

- **Server/VM** with at least 2GB RAM, 10GB storage
- **Linux OS** (Ubuntu 20.04+ recommended)
- **Domain Name**
- **SSL Certificate** (Let's Encrypt)
- **Email Account** for notifications
- **Razorpay Live Credentials**

### Step 1: Server Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
sudo apt install docker.io docker-compose -y

# Install Git
sudo apt install git -y

# Clone repository
git clone https://github.com/praveen2246/springboot-ecommerce-core.git
cd springboot-ecommerce-core
```

### Step 2: Configure Environment Variables

```bash
# Create production .env
cat > docker-compose.override.yml << EOF
version: '3.8'

services:
  backend:
    environment:
      SPRING_PROFILES_ACTIVE: prod
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/ecommerce
      RAZORPAY_API_KEY: ${RAZORPAY_LIVE_KEY}
      RAZORPAY_API_SECRET: ${RAZORPAY_LIVE_SECRET}
      MAIL_USERNAME: ${MAIL_USERNAME}
      MAIL_PASSWORD: ${MAIL_PASSWORD}
      JWT_SECRET: ${JWT_SECRET}
    ports:
      - "8080:8080"

  postgres:
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

volumes:
  postgres_data:
EOF
```

### Step 3: SSL/HTTPS Setup

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Get certificate for your domain
sudo certbot certonly --standalone -d yourdomain.com

# Update Nginx configuration to use SSL
# Edit nginx-frontend.conf and add SSL directives
```

### Step 4: Deploy

```bash
# Build and start services
docker-compose up -d

# Verify services are running
docker-compose ps

# Check logs
docker-compose logs -f backend

# Database initialization (first time only)
docker-compose exec -T postgres psql -U postgres -d ecommerce -f /scripts/init-db.sql
```

### Step 5: DNS Configuration

Update your domain's DNS records to point to server IP:

```
A Record: yourdomain.com -> YOUR_SERVER_IP
```

### Monitoring

```bash
# Health check
curl https://yourdomain.com/api/health

# View logs
docker-compose logs -f

# Check disk usage
df -h

# Check memory
free -h
```

### Backup

```bash
# Automated daily backup
docker-compose exec postgres pg_dump -U postgres ecommerce > /backups/db_backup_$(date +%Y%m%d).sql
```

---

## Cloud Deployment

### AWS EC2 + RDS

#### Step 1: Create EC2 Instance

1. Go to AWS Console → EC2
2. Create new instance (Ubuntu 20.04)
3. Choose instance type: t2.medium (2vCPU, 4GB RAM)
4. Configure security groups:
   - Allow port 80 (HTTP)
   - Allow port 443 (HTTPS)
   - Allow port 8080 (Backend)

#### Step 2: Create RDS Database

1. Go to AWS Console → RDS
2. Create PostgreSQL instance
3. Database name: `ecommerce`
4. Master username: `admin`
5. Store password securely

#### Step 3: Deploy Application

```bash
# SSH into EC2 instance
ssh -i your-key.pem ec2-user@your-instance-ip

# Install Docker and Docker Compose
sudo yum update -y
sudo yum install docker docker-compose -y

# Deploy application
git clone https://github.com/praveen2246/springboot-ecommerce-core.git
cd springboot-ecommerce-core

# Update docker-compose.yml with RDS endpoint
vi docker-compose.yml

# Start services
docker-compose up -d
```

### Azure App Service

#### Step 1: Create Azure Resources

```bash
# Create resource group
az group create --name ecommerce-rg --location eastus

# Create App Service
az appservice plan create --name ecommerce-plan --resource-group ecommerce-rg --sku B1 --is-linux

# Create PostgreSQL
az postgres server create --resource-group ecommerce-rg --name ecommerce-db --location eastus
```

#### Step 2: Deploy

```bash
# Build Docker images
docker build -t ecommerce-backend:latest ./ecommerce-backend
docker build -t ecommerce-frontend:latest ./ecommerce-frontend

# Push to Azure Container Registry
az acr login --name youracr
docker tag ecommerce-backend:latest youracr.azurecr.io/ecommerce-backend:latest
docker push youracr.azurecr.io/ecommerce-backend:latest
```

### Heroku Deployment

#### Step 1: Setup

```bash
# Install Heroku CLI
curl https://cli.heroku.com/install.sh | sh

# Login to Heroku
heroku login

# Create app
heroku create ecommerce-app
```

#### Step 2: Deploy Backend

```bash
cd ecommerce-backend/ecommerce-backend

# Add Heroku remote
heroku git:remote -a ecommerce-app

# Deploy
git push heroku main
```

#### Step 3: Deploy Frontend

```bash
cd ecommerce-frontend

# Create Heroku app for frontend
heroku create ecommerce-frontend

# Add buildpack for Node.js
heroku buildpacks:add heroku/nodejs

# Deploy
git push heroku main
```

---

## Troubleshooting

### Common Issues

#### 1. Backend won't start

```bash
# Check logs
docker-compose logs backend

# Common causes:
# - Database connection failed
# - Port 8080 already in use
# - Missing environment variables
```

#### 2. Frontend build fails

```bash
# Clear node_modules and rebuild
rm -rf node_modules package-lock.json
npm install
npm run build
```

#### 3. Database connection error

```bash
# Check PostgreSQL is running
docker-compose ps

# Verify credentials in .env
cat docker-compose.yml | grep POSTGRES

# Test connection
docker-compose exec postgres psql -U postgres -c "\l"
```

#### 4. SSL Certificate issues

```bash
# Renew certificate
sudo certbot renew

# Check certificate validity
sudo certbot certificates
```

#### 5. Out of memory error

```bash
# Check available memory
free -h

# Increase swap
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### Performance Optimization

```bash
# Enable database query caching
# Update application-prod.properties

# Use CDN for static assets
# Configure nginx to cache responses

# Enable gzip compression
# Update nginx-frontend.conf
```

---

## Monitoring and Maintenance

### Health Checks

```bash
# Monitor application health
./scripts/health-check.sh --continuous --interval 60
```

### Backups

```bash
# Automated backups
./scripts/backup-restore.sh backup

# Backup schedule (add to crontab)
0 2 * * * /path/to/scripts/backup-restore.sh backup
0 3 * * 0 /path/to/scripts/backup-restore.sh clean
```

### Updates

```bash
# Update dependencies
./scripts/dev-utils.sh update-deps

# Rebuild and redeploy
docker-compose up -d --build
```

---

## Support and Resources

- **GitHub Issues**: https://github.com/praveen2246/springboot-ecommerce-core/issues
- **Documentation**: See README.md and docs/API.md
- **API Testing**: Use Postman collection in postman/ directory
- **Scripts Guide**: See scripts/SCRIPTS_GUIDE.md

---

**Last Updated**: 2024-01-15
**Maintained by**: Praveen Kumar
