@echo off
REM Quick Setup Script for E-Commerce Platform (Windows)
REM Automates initial setup for developers

setlocal enabledelayedexpansion

REM Color codes (Windows 10+ with ANSI support)
set GREEN=[32m
set RED=[31m
set YELLOW=[33m
set BLUE=[34m
set NC=[0m

:main
cls
echo.
echo ════════════════════════════════════════════════════════════════
echo E-Commerce Platform - Quick Setup (Windows)
echo ════════════════════════════════════════════════════════════════
echo.

REM Check if running from correct directory
if not exist "README.md" (
    echo ❌ Please run this script from the project root directory
    exit /b 1
)

REM Check prerequisites
echo Checking Prerequisites...
echo.

REM Check Java
java -version >nul 2>&1
if errorlevel 1 (
    echo ❌ Java not found
    echo Please install Java 17 from: https://adoptopenjdk.net/
    echo Then close and reopen your terminal
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%i in ('java -version 2^>^&1') do (
        set JAVA_VERSION=%%i
        goto :end_java
    )
    :end_java
    echo ✅ Java found: !JAVA_VERSION!
)

REM Check Node.js
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js not found
    echo Please install Node.js 18 from: https://nodejs.org/
    echo Then close and reopen your terminal
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%i in ('node --version') do (
        echo ✅ Node.js found: %%i
    )
)

REM Check Maven
mvn --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Maven not found
    echo Please install Maven from: https://maven.apache.org/download.cgi
    echo And add it to your PATH environment variable
    echo Then close and reopen your terminal
    pause
    exit /b 1
) else (
    echo ✅ Maven found
)

REM Check Git
git --version >nul 2>&1
if errorlevel 1 (
    echo ⚠️  Git not found (optional)
) else (
    echo ✅ Git found
)

REM Check PostgreSQL
psql --version >nul 2>&1
if not errorlevel 1 (
    echo ✅ PostgreSQL found
    set POSTGRES_FOUND=1
) else (
    echo ⚠️  PostgreSQL not found (optional, uses H2 by default)
    set POSTGRES_FOUND=0
)

REM Check Docker
docker --version >nul 2>&1
if not errorlevel 1 (
    echo ✅ Docker found
    set DOCKER_FOUND=1
) else (
    echo ⚠️  Docker not found (optional)
    set DOCKER_FOUND=0
)

echo.
echo Verifying project structure...

if not exist "ecommerce-backend\" (
    echo ❌ ecommerce-backend folder not found
    exit /b 1
)
echo ✅ Backend folder found

if not exist "ecommerce-frontend\" (
    echo ❌ ecommerce-frontend folder not found
    exit /b 1
)
echo ✅ Frontend folder found

if not exist "scripts\" (
    echo ❌ scripts folder not found
    exit /b 1
)
echo ✅ Scripts folder found

echo.
echo Proceeding with setup...
echo.

REM Setup Backend
echo Setting up backend...
cd ecommerce-backend\ecommerce-backend

REM Check if .env exists
if not exist ".env" (
    echo Creating .env file with default values...
    (
        echo # Spring Boot Configuration
        echo SPRING_PROFILES_ACTIVE=dev
        echo.
        echo # Database Configuration
        echo SPRING_DATASOURCE_URL=jdbc:h2:mem:ecommerce
        echo SPRING_DATASOURCE_USERNAME=sa
        echo SPRING_DATASOURCE_PASSWORD=
        echo.
        echo # Razorpay Configuration
        echo RAZORPAY_KEY_ID=rzp_test_SX0HsSL3fbdppU
        echo RAZORPAY_KEY_SECRET=56qR9eMxCmCoRxc64t05c4X9
        echo.
        echo # Email Configuration
        echo MAIL_HOST=smtp.gmail.com
        echo MAIL_PORT=587
        echo MAIL_USERNAME=your-email^@gmail.com
        echo MAIL_PASSWORD=your-app-password
        echo.
        echo # JWT Configuration
        echo JWT_SECRET=your-secret-key-change-this-in-production
    ) > .env
    echo ✅ .env file created
    echo ⚠️  Please update email credentials in .env file
) else (
    echo .env file already exists
)

echo Building backend with Maven...
call mvn clean package -DskipTests -q
if errorlevel 1 (
    echo ❌ Backend build failed
    exit /b 1
)
echo ✅ Backend build successful

cd ..\..

REM Setup Frontend
echo.
echo Setting up frontend...
cd ecommerce-frontend

echo Installing dependencies...
call npm install --silent
if errorlevel 1 (
    echo ❌ Failed to install frontend dependencies
    exit /b 1
)
echo ✅ Frontend dependencies installed

REM Check if .env.local exists
if not exist ".env.local" (
    echo Creating .env.local file...
    (
        echo VITE_API_BASE_URL=http://localhost:8080
        echo VITE_APP_NAME=E-Commerce Platform
        echo VITE_APP_VERSION=1.0.0
    ) > .env.local
    echo ✅ .env.local file created
) else (
    echo .env.local file already exists
)

cd ..

REM Setup Database
echo.
if %POSTGRES_FOUND% equ 1 (
    set /p DB_SETUP="Initialize PostgreSQL database? (y/n): "
    if /i "!DB_SETUP!"=="y" (
        echo Initializing database...
        psql -h localhost -U postgres -c "CREATE DATABASE ecommerce;" 2>nul
        psql -h localhost -U postgres -d ecommerce -f scripts\init-db.sql
        echo ✅ Database initialized
    )
) else (
    echo Using H2 in-memory database (development only)
)

REM Final message
cls
echo.
echo ════════════════════════════════════════════════════════════════
echo Setup Complete! 
echo ════════════════════════════════════════════════════════════════
echo.
echo Next steps to start developing:
echo.
echo 1. Update configuration files if needed:
echo    - ecommerce-backend\ecommerce-backend\.env
echo    - ecommerce-frontend\.env.local
echo.
echo 2. Start the backend (open new terminal):
echo    cd ecommerce-backend\ecommerce-backend
echo    mvn spring-boot:run
echo.
echo 3. Start the frontend (open another terminal):
echo    cd ecommerce-frontend
echo    npm run dev
echo.
echo 4. Open browser and navigate to:
echo    Frontend:  http://localhost:5173
echo    Backend:   http://localhost:8080
echo    API Docs:  http://localhost:8080/swagger-ui.html
echo.
echo 5. Optional - Run health check:
echo    scripts\health-check.sh
echo.
echo Documentation:
echo    - README.md - Main documentation
echo    - docs\API.md - API reference
echo    - scripts\README.md - Script documentation
echo.
echo Useful Commands:
echo    Deploy locally:    scripts\deploy.sh local
echo    Deploy Docker:     scripts\deploy.sh docker
echo    Create backup:     scripts\backup-restore.bat backup
echo    Health check:      scripts\health-check.sh
echo.

pause
