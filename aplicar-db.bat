@echo off
chcp 65001 >nul
title Tinta Laser - Aplicar cambios a la base de datos
setlocal

set "CONFIG_FILE=%USERPROFILE%\.tinta-laser\config.env"
cd /d "%~dp0"

echo ================================================
echo   Tinta Laser - Aplicar cambios a Supabase
echo ================================================
echo.

where powershell >nul 2>nul || (echo [X] No se encuentra PowerShell & goto :fin)
if not exist "%CONFIG_FILE%" (
  echo [X] No existe la configuracion. Ejecuta setup-accesos.bat primero.
  goto :fin
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\aplicar-db.ps1" -ConfigFile "%CONFIG_FILE%" -MigDir "%~dp0supabase\migrations"
if errorlevel 1 (
  echo.
  echo [X] Hubo un error. Copia el mensaje completo y envialo al chat.
) else (
  echo.
  echo [OK] Listo.
)

:fin
echo.
pause
endlocal
