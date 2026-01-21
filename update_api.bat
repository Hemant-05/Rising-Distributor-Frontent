@echo off
echo ==========================================
echo 1. Fetching new API definition (using NPM)...
echo ==========================================
:: This is the line we changed for you:
call openapi-generator-cli generate -c openapi-config.yaml

echo.
echo ==========================================
echo 2. Re-building Data Models...
echo ==========================================
cd lib/api_client
call flutter pub get
call dart run build_runner build --delete-conflicting-outputs

echo.
echo ==========================================
echo DONE! Your App is now synced with Backend.
echo ==========================================
cd ../..
pause