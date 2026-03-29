@echo off
REM PostgreSQL Database Initialization Script for Windows
REM Usage: postgres-init.bat

setlocal enabledelayedexpansion

echo.
echo 🚀 Starting PostgreSQL Database Initialization...
echo.

set DB_HOST=localhost
set DB_PORT=5432
set DB_NAME=ecommerce
set DB_USER=postgres
set DB_PASSWORD=postgres

if "%1"=="--help" (
    echo Usage: postgres-init.bat [options]
    echo.
    echo Options:
    echo   --host         PostgreSQL host (default: localhost)
    echo   --port         PostgreSQL port (default: 5432)
    echo   --db           Database name (default: ecommerce)
    echo   --user         PostgreSQL user (default: postgres)
    echo   --password     PostgreSQL password (default: postgres)
    echo.
    echo Example:
    echo   postgres-init.bat --host 192.168.1.5 --user admin --password mypass
    echo.
    exit /b 0
)

REM Parse command line arguments
:parse_args
if "%1"=="" goto :end_args
if "%1"=="--host" (
    set DB_HOST=%2
    shift
    shift
    goto :parse_args
)
if "%1"=="--port" (
    set DB_PORT=%2
    shift
    shift
    goto :parse_args
)
if "%1"=="--db" (
    set DB_NAME=%2
    shift
    shift
    goto :parse_args
)
if "%1"=="--user" (
    set DB_USER=%2
    shift
    shift
    goto :parse_args
)
if "%1"=="--password" (
    set DB_PASSWORD=%2
    shift
    shift
    goto :parse_args
)
shift
goto :parse_args

:end_args

echo 🔍 Checking PostgreSQL connection...
echo set PGPASSWORD=%DB_PASSWORD% | psql -h %DB_HOST% -U %DB_USER% -d postgres -c "SELECT 1;" > nul 2>&1

if errorlevel 1 (
    echo ❌ PostgreSQL connection failed.
    echo Make sure PostgreSQL is running and credentials are correct.
    echo.
    echo Connection details:
    echo   Host: %DB_HOST%
    echo   Port: %DB_PORT%
    echo   User: %DB_USER%
    echo.
    exit /b 1
)

echo ✅ PostgreSQL is running

echo 📦 Creating database '%DB_NAME%'...
set PGPASSWORD=%DB_PASSWORD%
createdb -h %DB_HOST% -p %DB_PORT% -U %DB_USER% %DB_NAME% 2> nul
if errorlevel 1 (
    echo ℹ️  Database '%DB_NAME%' already exists or couldn't be created
)

echo 📝 Running initialization script...
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -f scripts/init-db.sql

if errorlevel 1 (
    echo ❌ Error running initialization script
    exit /b 1
)

echo ✅ Database initialization completed successfully!
echo.
echo 📊 Database Summary:
echo -------------------
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -c ^
    "SELECT COUNT(*) as users FROM users; SELECT COUNT(*) as categories FROM categories; SELECT COUNT(*) as products FROM products;"

echo.
echo 🎉 Your e-commerce database is ready!
echo Connection details:
echo   Host: %DB_HOST%
echo   Port: %DB_PORT%
echo   Database: %DB_NAME%
echo   User: %DB_USER%
echo.
endlocal
