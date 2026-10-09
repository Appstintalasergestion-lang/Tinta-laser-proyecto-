@echo off
chcp 65001 >nul
title Tinta Laser - Diagnostico de GitHub
setlocal EnableDelayedExpansion

set "CONFIG_FILE=%USERPROFILE%\.tinta-laser\config.env"
cd /d "%~dp0"

echo ================================================
echo   Tinta Laser - Diagnostico de GitHub
echo ================================================
echo.

where git >nul 2>nul || (echo [X] Falta Git & goto :fin)
if not exist "%CONFIG_FILE%" (
  echo [X] No existe config.env. Ejecuta setup-accesos.bat primero.
  goto :fin
)

set "GITHUB_TOKEN="
for /f "usebackq tokens=1,* delims==" %%A in ("%CONFIG_FILE%") do (
  if "%%A"=="GITHUB_TOKEN" set "GITHUB_TOKEN=%%B"
)
if "!GITHUB_TOKEN!"=="" (
  echo [X] GITHUB_TOKEN esta vacio en config.env.
  goto :fin
)

set "REPO_URL="
for /f "delims=" %%U in ('git remote get-url origin 2^>nul') do set "REPO_URL=%%U"
if "!REPO_URL!"=="" (
  echo [X] Este proyecto no tiene repositorio remoto. Ejecuta sincronizar.bat primero.
  goto :fin
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\diagnostico-github.ps1" -RepoUrl "!REPO_URL!" -Token "!GITHUB_TOKEN!"

:fin
echo.
pause
endlocal
