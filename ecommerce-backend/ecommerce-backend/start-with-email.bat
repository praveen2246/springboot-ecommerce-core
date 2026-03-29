@echo off
setlocal enabledelayedexpansion

set RAZORPAY_API_KEY=rzp_test_SWC6COoQ9VJ87v
set RAZORPAY_API_SECRET=yo7jgg5M13s22Krc4GWxmNfi
set SPRING_PROFILES_ACTIVE=prod

echo.
echo ========================================
echo Backend with Gmail Email Notifications
echo ========================================
echo Email: tbpraveen23@gmail.com
echo.

cd /d "D:\arena\ecommerce-backend\ecommerce-backend"

java -Dspring.profiles.active=prod -jar "target\ecommerce-backend-0.0.1-SNAPSHOT.jar"

pause
