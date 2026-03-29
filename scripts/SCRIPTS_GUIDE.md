# Scripts Guide - Complete Reference

A comprehensive guide to all utility scripts in the e-commerce platform project.

## 📁 Scripts Directory Structure

```
scripts/
├── README.md                 # Script documentation index
├── SCRIPTS_GUIDE.md         # This file - comprehensive reference
├── setup.sh                 # Quick setup (Linux/Mac)
├── setup.bat                # Quick setup (Windows)
├── deploy.sh                # Deployment orchestration
├── init-db.sql              # Database initialization SQL
├── postgres-init.sh         # PostgreSQL setup (Linux/Mac)
├── postgres-init.bat        # PostgreSQL setup (Windows)
├── backup-restore.sh        # Backup management (Linux/Mac)
├── backup-restore.bat       # Backup management (Windows)
├── health-check.sh          # System monitoring
└── dev-utils.sh             # Development utilities
```

## 🚀 Quick Start Scripts

### setup.sh / setup.bat
**Purpose:** Automated initial setup for new developers
**When to Use:** First time cloning the project
**What It Does:**
- Checks for required software (Java, Node.js, Maven)
- Installs missing dependencies (optional)
- Builds backend and frontend
- Creates configuration files
- Initializes database (optional)
- Verifies project structure

**Usage:**
```bash
# Linux/Mac
./scripts/setup.sh

# Windows
scripts\setup.bat

# Skip automatic installation
./scripts/setup.sh --skip-install
```

**Output:**
- ✅ Configured backend (.env)
- ✅ Configured frontend (.env.local)
- ✅ Compiled backend JAR
- ✅ Installed frontend dependencies
- ✅ Initialized database (if chosen)

**Time Required:** 5-15 minutes depending on internet speed

---

## 🗄️ Database Scripts

### init-db.sql
**Purpose:** Initialize database schema and sample data
**When to Use:** Setting up a fresh database
**What It Does:**
- Creates 8 database tables
- Sets up relationships and constraints
- Creates indexes for performance
- Inserts sample categories and products
- Inserts test user for development

**Usage:**
```bash
# PostgreSQL
psql -h localhost -U postgres -d ecommerce -f scripts/init-db.sql

# MySQL
mysql -u root ecommerce < scripts/init-db.sql
```

**Tables Created:**
1. `users` - User accounts and profiles
2. `categories` - Product categories
3. `products` - Product catalog
4. `carts` - Shopping carts
5. `cart_items` - Items in carts
6. `orders` - Customer orders
7. `order_items` - Items in orders
8. `payments` - Payment records
9. `reviews` - Product reviews

---

### postgres-init.sh / postgres-init.bat
**Purpose:** Complete PostgreSQL database setup
**When to Use:** Setting up PostgreSQL from scratch
**What It Does:**
- Verifies PostgreSQL is running
- Creates database if it doesn't exist
- Runs init-db.sql automatically
- Shows connection summary

**Usage (Linux/Mac):**
```bash
./scripts/postgres-init.sh

# With custom configuration
DB_HOST=192.168.1.100 DB_USER=admin DB_PASSWORD=pass ./scripts/postgres-init.sh
```

**Usage (Windows):**
```cmd
scripts\postgres-init.bat

# With custom configuration
postgres-init.bat --host 192.168.1.100 --user admin --password pass
```

**Prerequisites:**
- PostgreSQL server running
- Environment variables or command-line options set

---

## 💾 Backup Scripts

### backup-restore.sh / backup-restore.bat
**Purpose:** Automated database backup and restore
**When to Use:** 
- Before major changes
- Regular scheduled backups
- Disaster recovery
- Testing database migrations

**Commands:**

**Backup:**
```bash
./scripts/backup-restore.sh backup
./scripts/backup-restore.sh backup --db custom_db
```

**Restore:**
```bash
./scripts/backup-restore.sh restore --file ./backups/ecommerce_backup_20240115_120000.sql
```

**List Backups:**
```bash
./scripts/backup-restore.sh list
```

**Clean Old Backups:**
```bash
./scripts/backup-restore.sh clean  # Keeps last 7
```

**Backup File Location:**
- Default: `./backups/`
- Format: `ecommerce_backup_YYYYMMDD_HHMMSS.sql`
- Size: Typically 1-5 MB depending on data

**Restoration Process:**
1. Drops existing database
2. Creates new empty database
3. Restores from backup file
4. Verifies restoration

**Automated Backups (Cron):**
```bash
# Daily backup at 2 AM
0 2 * * * cd /path/to/project && ./scripts/backup-restore.sh backup

# Weekly cleanup at 3 AM Sunday
0 3 * * 0 cd /path/to/project && ./scripts/backup-restore.sh clean
```

---

## 🚀 Deployment Scripts

### deploy.sh
**Purpose:** Deploy to different environments
**When to Use:** Setting up environments for different stages
**What It Does:**
- Verifies dependencies
- Builds project
- Configures environment
- Starts services

**Environments:**

**Local Development:**
```bash
./scripts/deploy.sh local
```
- Uses H2 in-memory database
- Runs with Maven and npm
- Outputs instructions for starting services

**Docker Deployment:**
```bash
./scripts/deploy.sh docker
```
- Starts Docker Compose services
- Sets up PostgreSQL, backend, frontend
- Configures networking and volumes

**Production:**
```bash
./scripts/deploy.sh production
```
- Shows detailed setup instructions
- Lists environment variables
- Provides deployment checklist

**Options:**
```bash
./scripts/deploy.sh local --verbose
./scripts/deploy.sh docker --dry-run
./scripts/deploy.sh docker --skip-tests
```

**What Gets Started:**
- Backend API (port 8080)
- Frontend (port 5173 dev / port 80 Docker)
- Database (port 5432 Docker)
- Nginx proxy (port 80)

---

## 📊 Monitoring Scripts

### health-check.sh
**Purpose:** Monitor system health and connectivity
**When to Use:**
- During development (verify services running)
- Before/after deployments
- Continuous monitoring in production
- Troubleshooting issues

**What It Checks:**
- Backend API health (`/actuator/health`)
- Frontend availability
- Database connectivity
- API endpoints responsiveness
- Docker container status
- System resources (CPU, memory)

**Usage:**

**Single Check:**
```bash
./scripts/health-check.sh
```

**Continuous Monitoring:**
```bash
./scripts/health-check.sh --continuous --interval 30
```

**With Custom Endpoints:**
```bash
./scripts/health-check.sh \
  --backend-url http://192.168.1.100:8080 \
  --frontend-url http://192.168.1.100:5173 \
  --db-host 192.168.1.100 \
  --db-password postgres
```

**With Docker Check:**
```bash
./scripts/health-check.sh --docker --continuous
```

**Output Example:**
```
[INFO] Backend health check...
[SUCCESS] Backend is responding
[SUCCESS] Products API is responsive
[SUCCESS] Swagger UI is accessible
[SUCCESS] Database connection successful
[SUCCESS] Database 'ecommerce' exists
[SUCCESS] Database has 8 tables
```

**Log File:**
- Default: `./health-check.log`
- Cumulative logs from all runs
- Useful for tracking issues over time

---

## 🛠️ Development Scripts

### dev-utils.sh
**Purpose:** Common development tasks
**When to Use:** During development workflow
**What It Does:** Various utility commands for development

**Commands:**

**Build Management:**
```bash
./scripts/dev-utils.sh clean           # Clean artifacts
./scripts/dev-utils.sh clean --full    # Clean including node_modules
./scripts/dev-utils.sh rebuild         # Full rebuild
./scripts/dev-utils.sh install-deps    # Install dependencies
./scripts/dev-utils.sh update-deps     # Check for updates
```

**Development Servers:**
```bash
./scripts/dev-utils.sh backend         # Start backend server
./scripts/dev-utils.sh frontend        # Start frontend dev server
```

**Testing & Quality:**
```bash
./scripts/dev-utils.sh test            # Run all tests
./scripts/dev-utils.sh format          # Format code
./scripts/dev-utils.sh lint            # Check code quality
./scripts/dev-utils.sh docs            # Generate documentation
```

**Maintenance:**
```bash
./scripts/dev-utils.sh logs            # View Docker logs
./scripts/dev-utils.sh reset-db        # Reset database
./scripts/dev-utils.sh clear-cache     # Clear caches
```

**Typical Development Workflow:**
```bash
# First time setup
./scripts/setup.sh

# Daily work
./scripts/dev-utils.sh backend    # Terminal 1
./scripts/dev-utils.sh frontend   # Terminal 2

# Before committing
./scripts/dev-utils.sh format
./scripts/dev-utils.sh lint
./scripts/dev-utils.sh test

# Maintenance
./scripts/dev-utils.sh update-deps
```

---

## 📋 Script Decision Tree

### Choose script based on your task:

```
What are you doing?
│
├─→ Setting up project for first time?
│   └─→ Run: setup.sh (or setup.bat on Windows)
│
├─→ Starting development servers?
│   └─→ Run: dev-utils.sh backend & dev-utils.sh frontend
│
├─→ Deploying application?
│   ├─→ Local → deploy.sh local
│   ├─→ Docker → deploy.sh docker
│   └─→ Production → Review deploy.sh production output
│
├─→ Managing database?
│   ├─→ Creating backup → backup-restore.sh backup
│   ├─→ Restoring backup → backup-restore.sh restore
│   ├─→ Initializing → postgres-init.sh / init-db.sql
│   └─→ Resetting → dev-utils.sh reset-db
│
├─→ Checking system health?
│   ├─→ Quick check → health-check.sh
│   └─→ Continuous monitoring → health-check.sh --continuous
│
├─→ Building/Testing project?
│   ├─→ Full rebuild → dev-utils.sh rebuild
│   ├─→ Run tests → dev-utils.sh test
│   ├─→ Format code → dev-utils.sh format
│   └─→ Check quality → dev-utils.sh lint
│
└─→ Need help?
    └─→ Read: README.md, scripts/README.md, or this guide
```

---

## 🔧 Common Scenarios

### Scenario 1: Setting Up Development Environment
```bash
# Step 1: Initial setup
./scripts/setup.sh

# Step 2: Start services
./scripts/dev-utils.sh backend &
./scripts/dev-utils.sh frontend

# Step 3: Verify everything
./scripts/health-check.sh
```

### Scenario 2: Docker Deployment
```bash
# Step 1: Deploy
./scripts/deploy.sh docker

# Step 2: Monitor
./scripts/health-check.sh --docker --continuous

# Step 3: Backup before changes
./scripts/backup-restore.sh backup
```

### Scenario 3: Production Deployment
```bash
# Step 1: Backup current database
./scripts/backup-restore.sh backup

# Step 2: View deployment instructions
./scripts/deploy.sh production

# Step 3: Follow output instructions
# (Configure PostgreSQL, Razorpay, email, SSL, etc.)

# Step 4: Verify after deployment
./scripts/health-check.sh --backend-url https://yourdomain.com
```

### Scenario 4: Weekly Maintenance
```bash
# Check for updates
./scripts/dev-utils.sh update-deps

# Run tests
./scripts/dev-utils.sh test

# Create backup
./scripts/backup-restore.sh backup

# Clean old backups
./scripts/backup-restore.sh clean

# Check system health
./scripts/health-check.sh
```

### Scenario 5: Disaster Recovery
```bash
# List available backups
./scripts/backup-restore.sh list

# Choose backup file and restore
./scripts/backup-restore.sh restore --file ./backups/ecommerce_backup_20240115_120000.sql

# Verify restoration
./scripts/health-check.sh --db-password postgres
```

---

## 🔐 Security Best Practices

### Password Management
- ✅ Never hardcode passwords in scripts
- ✅ Use environment variables: `PGPASSWORD=xxx ./script.sh`
- ✅ Add `.env` files to `.gitignore`
- ✅ Use command-line prompts for sensitive data

### Backup Security
- ✅ Encrypt backup files for production
- ✅ Store backups in secure locations
- ✅ Test backups regularly
- ✅ Keep offsite copies

### File Permissions
```bash
# Make scripts executable (Linux/Mac)
chmod +x scripts/*.sh

# Restrict backup access
chmod 600 backups/*.sql
```

---

## 🐛 Troubleshooting

### Scripts won't execute (Linux/Mac)
```bash
# Make executable
chmod +x scripts/*.sh

# Run with bash explicitly
bash scripts/setup.sh
```

### psql: command not found
```bash
# Add PostgreSQL to PATH
export PATH="/usr/lib/postgresql/14/bin:$PATH"

# Or install PostgreSQL
apt-get install postgresql postgresql-contrib
```

### Docker commands fail
```bash
# Check Docker is running
docker --version

# Start Docker daemon (Linux)
sudo systemctl start docker

# Use without sudo (Linux)
sudo usermod -aG docker $USER
```

### Database connection failed
```bash
# Check PostgreSQL is running
psql -h localhost -U postgres -c "SELECT 1;"

# Check credentials in .env
cat ecommerce-backend/ecommerce-backend/.env | grep DATASOURCE
```

### Scripts timeout or hang
```bash
# Run with timeout (Linux/Mac)
timeout 60 ./scripts/health-check.sh

# Check running processes
ps aux | grep java
ps aux | grep node
```

---

## 📚 Related Documentation

- [Main README](../README.md) - Project overview
- [API Documentation](../docs/API.md) - API reference
- [Docker Setup](../docker-compose.yml) - Docker configuration
- [Backend README](../ecommerce-backend/README.md) - Backend details
- [Frontend README](../ecommerce-frontend/README.md) - Frontend details

---

## 📞 Getting Help

1. **Check the script help:**
   ```bash
   ./script.sh --help
   ```

2. **Read documentation:**
   - scripts/README.md
   - This file (SCRIPTS_GUIDE.md)
   - Main README.md

3. **View logs:**
   - health-check.log
   - Docker logs: `docker-compose logs`
   - Application logs: Check console output

4. **Enable verbose mode:**
   ```bash
   ./scripts/deploy.sh local --verbose
   ./scripts/health-check.sh --db-password postgres
   ```

---

## 🎯 Scripts Quick Reference

| Task | Script | Command |
|------|--------|---------|
| Initial Setup | setup.sh | `./scripts/setup.sh` |
| Deploy Locally | deploy.sh | `./scripts/deploy.sh local` |
| Deploy Docker | deploy.sh | `./scripts/deploy.sh docker` |
| Start Backend | dev-utils.sh | `./scripts/dev-utils.sh backend` |
| Start Frontend | dev-utils.sh | `./scripts/dev-utils.sh frontend` |
| Create Backup | backup-restore.sh | `./scripts/backup-restore.sh backup` |
| Restore Backup | backup-restore.sh | `./scripts/backup-restore.sh restore --file FILE` |
| Health Check | health-check.sh | `./scripts/health-check.sh` |
| Run Tests | dev-utils.sh | `./scripts/dev-utils.sh test` |
| Format Code | dev-utils.sh | `./scripts/dev-utils.sh format` |
| Reset Database | dev-utils.sh | `./scripts/dev-utils.sh reset-db` |

---

**Last Updated:** 2024-01-15
**Version:** 1.0.0
**Compatibility:** Linux, macOS, Windows (with WSL or Git Bash)
