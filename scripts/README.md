# E-Commerce Platform Scripts

This directory contains utility scripts for development, deployment, backup, and monitoring of the e-commerce platform.

## 📋 Available Scripts

### 1. **deploy.sh** - Deployment Orchestration
Automates deployment to different environments (local, Docker, production).

**Usage:**
```bash
./deploy.sh [environment] [options]
```

**Environments:**
- `local` - Local development with Maven and Node.js
- `docker` - Docker Compose deployment
- `production` - Production deployment guidance
- `aws` - AWS deployment (documentation only)
- `heroku` - Heroku deployment (documentation only)
- `azure` - Azure deployment (documentation only)

**Options:**
- `--verbose, -v` - Enable verbose output
- `--dry-run` - Show what would be executed without running
- `--skip-tests` - Skip running tests before deployment
- `--help, -h` - Show help message

**Examples:**
```bash
# Deploy locally
./deploy.sh local

# Deploy with Docker Compose
./deploy.sh docker --verbose

# Dry run to see what would happen
./deploy.sh docker --dry-run
```

---

### 2. **init-db.sql** - Database Initialization
SQL script to initialize database schema with sample data.

**Features:**
- Creates all required tables
- Inserts sample categories and products
- Sets up indexes for performance
- Includes test data

**Usage:**
```bash
# PostgreSQL
psql -h localhost -U postgres -d ecommerce -f scripts/init-db.sql

# MySQL
mysql -u root -p ecommerce < scripts/init-db.sql

# H2 (via application startup)
# Automatically executed by DataInitializer
```

---

### 3. **postgres-init.sh** - PostgreSQL Initialization (Linux/Mac)
Automated PostgreSQL database setup and initialization.

**Usage:**
```bash
./postgres-init.sh [options]
```

**Options:**
```bash
# With custom configuration
./postgres-init.sh
```

**Environment Variables:**
```bash
DB_HOST=localhost
DB_PORT=5432
DB_NAME=ecommerce
DB_USER=postgres
DB_PASSWORD=postgres
```

**Example:**
```bash
# Run with custom host
DB_HOST=192.168.1.100 ./postgres-init.sh
```

---

### 4. **postgres-init.bat** - PostgreSQL Initialization (Windows)
Windows batch script for PostgreSQL database setup.

**Usage:**
```cmd
postgres-init.bat [options]
```

**Options:**
```cmd
postgres-init.bat --host 192.168.1.100 --user admin --password mypass
postgres-init.bat --db custom_db --port 5433
```

**Supported Options:**
- `--host` - PostgreSQL host (default: localhost)
- `--port` - PostgreSQL port (default: 5432)
- `--db` - Database name (default: ecommerce)
- `--user` - PostgreSQL user (default: postgres)
- `--password` - PostgreSQL password (default: postgres)
- `--help` - Show help

---

### 5. **backup-restore.sh** - Backup Management (Linux/Mac)
Backup and restore PostgreSQL database with automatic rotation.

**Usage:**
```bash
./backup-restore.sh [command] [options]
```

**Commands:**
- `backup` - Create a new database backup
- `restore` - Restore from a backup file
- `list` - List all existing backups
- `clean` - Remove old backups (keeps last 7)
- `help` - Show help message

**Backup Options:**
```bash
./backup-restore.sh backup [--host localhost] [--db ecommerce] [--user postgres]
```

**Restore Options:**
```bash
./backup-restore.sh restore --file ./backups/ecommerce_backup_20240115_120000.sql
```

**Examples:**
```bash
# Create a backup
./backup-restore.sh backup

# Create backup with custom settings
./backup-restore.sh backup --db mydb --user admin

# List all backups
./backup-restore.sh list

# Restore from specific backup
./backup-restore.sh restore --file ./backups/ecommerce_backup_20240115_120000.sql

# Clean old backups (keep last 7)
./backup-restore.sh clean
```

---

### 6. **backup-restore.bat** - Backup Management (Windows)
Windows batch script for PostgreSQL backup and restore operations.

**Usage:**
```cmd
backup-restore.bat [command] [options]
```

**Commands:**
- `backup` - Create database backup
- `restore` - Restore from backup
- `list` - List backups
- `clean` - Clean old backups
- `help` - Show help

**Examples:**
```cmd
# Create backup
backup-restore.bat backup

# Restore from backup
backup-restore.bat restore --file backups\ecommerce_backup_20240115_120000.sql

# List all backups
backup-restore.bat list

# Clean old backups
backup-restore.bat clean
```

---

### 7. **health-check.sh** - System Health Monitoring
Monitor backend, frontend, database, and Docker health.

**Usage:**
```bash
./health-check.sh [options]
```

**Monitoring Features:**
- ✅ Backend API health
- ✅ Frontend health
- ✅ Database connectivity
- ✅ API endpoints
- ✅ Docker container status
- ✅ System resources

**Options:**
- `--backend-url URL` - Backend URL (default: http://localhost:8080)
- `--frontend-url URL` - Frontend URL (default: http://localhost:5173)
- `--db-host HOST` - Database host (default: localhost)
- `--db-port PORT` - Database port (default: 5432)
- `--db-name NAME` - Database name (default: ecommerce)
- `--db-user USER` - Database user (default: postgres)
- `--db-password PASSWORD` - Database password
- `--interval SECONDS` - Check interval for continuous mode
- `--log-file FILE` - Log file path (default: ./health-check.log)
- `--continuous` - Run continuous health checks
- `--docker` - Check Docker container status
- `--help` - Show help

**Examples:**
```bash
# Single health check
./health-check.sh

# With database password
./health-check.sh --db-password mypassword

# Continuous monitoring (every 60 seconds)
./health-check.sh --continuous --interval 60

# Check Docker containers
./health-check.sh --docker

# Full monitoring with custom settings
./health-check.sh --backend-url http://192.168.1.100:8080 \
                  --db-host 192.168.1.100 \
                  --db-password mypass \
                  --continuous
```

---

## 🚀 Quick Start Guide

### Local Development Setup
```bash
# 1. Initialize database
./postgres-init.sh

# 2. Deploy locally
./deploy.sh local

# 3. Start backend and frontend as instructed
```

### Docker Deployment
```bash
# 1. Deploy with Docker Compose
./deploy.sh docker

# 2. Check health
./health-check.sh --docker
```

### Production Setup
```bash
# 1. Create initial backup
./backup-restore.sh backup

# 2. Follow production deployment guide
./deploy.sh production
```

### Regular Maintenance
```bash
# Daily health check
./health-check.sh

# Weekly backup
./backup-restore.sh backup

# Monthly cleanup (remove old backups)
./backup-restore.sh clean
```

---

## 📊 Backup Strategy

### Recommended Backup Schedule

**Daily:**
```bash
# Create daily backup
0 2 * * * /path/to/scripts/backup-restore.sh backup
```

**Weekly Cleanup:**
```bash
# Clean old backups every Sunday at 3 AM
0 3 * * 0 /path/to/scripts/backup-restore.sh clean
```

### Backup Retention Policy
- Last 7 backups are kept automatically by `clean` command
- Each backup includes full database schema and data
- Backups are timestamped for easy identification
- Restore operation drops existing database before restoring

---

## 🔒 Security Considerations

### Password Management
- Never hardcode passwords in scripts
- Use environment variables or command-line prompts
- Store sensitive credentials in `.env` files
- Add `.env` to `.gitignore` to prevent accidental commits

### Database Backups
- Store backups in secure locations
- Encrypt backups for production environments
- Test restore procedures regularly
- Keep offsite copies for disaster recovery

### Health Checks
- Use HTTPS for production monitoring
- Implement authentication for health endpoints
- Monitor system resources for anomalies
- Set up alerts for critical failures

---

## 🐛 Troubleshooting

### PostgreSQL Connection Issues
```bash
# Test connection
psql -h localhost -U postgres -d postgres -c "SELECT 1;"

# Check PostgreSQL status
sudo systemctl status postgresql

# View PostgreSQL logs
sudo tail -f /var/log/postgresql/
```

### Docker Issues
```bash
# Check Docker status
docker-compose ps

# View logs
docker-compose logs -f

# Restart services
docker-compose restart
```

### Database Restoration Problems
```bash
# Check backup file validity
psql -d postgres -f backups/ecommerce_backup_20240115_120000.sql --dry-run

# Verify database exists
psql -l | grep ecommerce
```

---

## 📝 Environment Variables Reference

| Variable | Default | Description |
|----------|---------|-------------|
| `DB_HOST` | `localhost` | PostgreSQL host |
| `DB_PORT` | `5432` | PostgreSQL port |
| `DB_NAME` | `ecommerce` | Database name |
| `DB_USER` | `postgres` | PostgreSQL user |
| `DB_PASSWORD` | - | PostgreSQL password |
| `BACKEND_URL` | `http://localhost:8080` | Backend API URL |
| `FRONTEND_URL` | `http://localhost:5173` | Frontend URL |
| `BACKUP_DIR` | `./backups` | Backup directory |
| `CHECK_INTERVAL` | `30` | Health check interval (seconds) |
| `LOG_FILE` | `./health-check.log` | Health check log file |

---

## 📚 Additional Resources

- [README.md](../README.md) - Main project documentation
- [docker-compose.yml](../docker-compose.yml) - Docker configuration
- [Dockerfile](../ecommerce-backend/ecommerce-backend/Dockerfile) - Backend container
- [docs/API.md](../docs/API.md) - API documentation

---

## 💡 Tips and Tricks

### Create Cron Jobs for Automated Backup
```bash
# Edit crontab
crontab -e

# Add this line to run backup daily at 2 AM
0 2 * * * cd /path/to/arena && ./scripts/backup-restore.sh backup

# Add this line to clean old backups weekly
0 3 * * 0 cd /path/to/arena && ./scripts/backup-restore.sh clean
```

### Monitor System Continuously
```bash
# Run health check continuously
./health-check.sh --continuous --interval 30 --db-password mypass
```

### Automated Deployment Pipeline
```bash
# Create deployment script
#!/bin/bash
./scripts/deploy.sh docker
./scripts/health-check.sh --docker
echo "✅ Deployment successful!"
```

---

## 🤝 Contributing

To add new scripts or improve existing ones:
1. Follow naming conventions (`action-target.sh` or `action-target.bat`)
2. Include help messages with `--help` option
3. Add logging and error handling
4. Document usage in this README
5. Test on multiple environments (Linux, Mac, Windows)

---

**Last Updated:** 2024-01-15
**Scripts Version:** 1.0.0
**Compatibility:** Linux/Mac/Windows

For issues or questions, refer to the main [README.md](../README.md) or project documentation.
