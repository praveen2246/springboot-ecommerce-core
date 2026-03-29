@echo off
REM Database Backup and Restore Script for Windows/PostgreSQL
REM Usage: backup-restore.bat [backup|restore] [options]

setlocal enabledelayedexpansion

REM Default values
set DB_HOST=localhost
set DB_PORT=5432
set DB_NAME=ecommerce
set DB_USER=postgres
set BACKUP_DIR=backups
set TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set BACKUP_FILE=%BACKUP_DIR%\%DB_NAME%_backup_%TIMESTAMP%.sql

if "%1"=="" (
    call :show_help
    exit /b 0
)

set COMMAND=%1
shift

REM Parse arguments
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

if "%1"=="--dir" (
    set BACKUP_DIR=%2
    shift
    shift
    goto :parse_args
)

if "%1"=="--file" (
    set RESTORE_FILE=%2
    shift
    shift
    goto :parse_args
)

if "%1"=="--password" (
    set PGPASSWORD=%2
    shift
    shift
    goto :parse_args
)

shift
goto :parse_args

:end_args

REM Execute command
if /i "%COMMAND%"=="backup" (
    call :create_backup
    exit /b !ERRORLEVEL!
) else if /i "%COMMAND%"=="restore" (
    call :restore_backup
    exit /b !ERRORLEVEL!
) else if /i "%COMMAND%"=="list" (
    call :list_backups
    exit /b 0
) else if /i "%COMMAND%"=="clean" (
    call :clean_old_backups
    exit /b 0
) else if /i "%COMMAND%"=="help" (
    call :show_help
    exit /b 0
) else (
    echo ❌ Unknown command: %COMMAND%
    echo.
    call :show_help
    exit /b 1
)

:create_backup
echo.
echo ✅ Creating database backup...
echo ℹ️  Database: %DB_NAME%
echo ℹ️  Host: %DB_HOST%:%DB_PORT%
echo ℹ️  User: %DB_USER%
echo ℹ️  Backup file: %BACKUP_FILE%
echo.

if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

set PGPASSWORD=%DB_PASSWORD%
if "%PGPASSWORD%"=="" (
    set /p PGPASSWORD="Enter PostgreSQL password for %DB_USER%: "
)

pg_dump -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% > "%BACKUP_FILE%" 2>nul

if errorlevel 1 (
    echo ❌ Failed to create backup
    exit /b 1
) else (
    for %%A in ("%BACKUP_FILE%") do set SIZE=%%~zA
    echo ✅ Backup created: %BACKUP_FILE% (!SIZE! bytes)
    exit /b 0
)

:restore_backup
if "%RESTORE_FILE%"=="" (
    echo ❌ Restore file not specified. Use --file option
    exit /b 1
)

if not exist "%RESTORE_FILE%" (
    echo ❌ Backup file not found: %RESTORE_FILE%
    exit /b 1
)

echo.
echo ℹ️  Restoring database from backup...
echo ℹ️  Backup file: %RESTORE_FILE%
echo ℹ️  Target database: %DB_NAME%
echo.

set PGPASSWORD=%DB_PASSWORD%
if "%PGPASSWORD%"=="" (
    set /p PGPASSWORD="Enter PostgreSQL password for %DB_USER%: "
)

REM Drop existing database
echo ℹ️  Dropping existing database...
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d postgres -c "DROP DATABASE IF EXISTS %DB_NAME%;" > nul 2>&1

REM Create new database
echo ℹ️  Creating new database...
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d postgres -c "CREATE DATABASE %DB_NAME%;" > nul 2>&1

REM Restore from backup
echo ℹ️  Restoring from backup...
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% < "%RESTORE_FILE%" > nul 2>&1

if errorlevel 1 (
    echo ❌ Failed to restore database
    exit /b 1
) else (
    echo ✅ Database restored successfully
    exit /b 0
)

:list_backups
if not exist "%BACKUP_DIR%" (
    echo ℹ️  No backup directory found: %BACKUP_DIR%
    exit /b 0
)

echo.
echo ℹ️  Available backups:
echo.

for /f "delims=" %%F in ('dir /o-d /b "%BACKUP_DIR%\%DB_NAME%_backup_*.sql" 2^>nul') do (
    for %%A in ("%BACKUP_DIR%\%%F") do (
        set SIZE=%%~zA
        echo   %%F !SIZE! bytes
    )
)
exit /b 0

:clean_old_backups
setlocal enabledelayedexpansion
set KEEP=7
set COUNT=0

for /f "delims=" %%F in ('dir /o-d /b "%BACKUP_DIR%\%DB_NAME%_backup_*.sql" 2^>nul') do (
    set /a COUNT+=1
)

if %COUNT% leq %KEEP% (
    echo ℹ️  Already have %COUNT% backups ^(keeping %KEEP%^)
    exit /b 0
)

echo.
echo ℹ️  Removing old backup^(s^), keeping the last %KEEP%...
echo.

set DELETE_COUNT=0
for /f "delims=" %%F in ('dir /o-d /b "%BACKUP_DIR%\%DB_NAME%_backup_*.sql" 2^>nul') do (
    set /a DELETE_COUNT+=1
    if !DELETE_COUNT! gtr %KEEP% (
        set FILE=%BACKUP_DIR%\%%F
        echo ℹ️  Deleting: %%F
        del "!FILE!"
    )
)

echo ✅ Cleanup completed
endlocal
exit /b 0

:show_help
echo.
echo Database Backup and Restore Script for Windows
echo.
echo Usage: backup-restore.bat [command] [options]
echo.
echo Commands:
echo   backup    Create a new database backup
echo   restore   Restore from a backup file
echo   list      List all existing backups
echo   clean     Remove old backups ^(keep last 7^)
echo   help      Show this help message
echo.
echo Backup Options:
echo   --host    PostgreSQL host ^(default: localhost^)
echo   --port    PostgreSQL port ^(default: 5432^)
echo   --db      Database name ^(default: ecommerce^)
echo   --user    PostgreSQL user ^(default: postgres^)
echo   --dir     Backup directory ^(default: backups^)
echo.
echo Restore Options:
echo   --file    Path to backup file ^(required^)
echo   --host    PostgreSQL host ^(default: localhost^)
echo   --port    PostgreSQL port ^(default: 5432^)
echo   --db      Database name ^(default: ecommerce^)
echo   --user    PostgreSQL user ^(default: postgres^)
echo.
echo Examples:
echo   # Create a backup
echo   backup-restore.bat backup
echo.
echo   # Create a backup with custom database
echo   backup-restore.bat backup --db mydb --user admin
echo.
echo   # List all backups
echo   backup-restore.bat list
echo.
echo   # Restore from specific backup
echo   backup-restore.bat restore --file backups\ecommerce_backup_20240101_120000.sql
echo.
echo   # Clean old backups ^(keep last 7^)
echo   backup-restore.bat clean
echo.
exit /b 0
