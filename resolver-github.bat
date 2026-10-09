@echo off
chcp 65001 >nul
title Tinta Laser - Resolver sincronizacion con GitHub
setlocal EnableDelayedExpansion

set "CONFIG_FILE=%USERPROFILE%\.tinta-laser\config.env"
cd /d "%~dp0"

echo ================================================
echo   Tinta Laser - Resolver sincronizacion con GitHub
echo ================================================
echo.
echo Este proceso hace que GitHub quede IGUAL a tu carpeta local.
echo Lo que haya en GitHub y no esté en tu carpeta se reemplaza.
echo.

where git >nul 2>nul || (echo [X] Falta Git & goto :fin)
if not exist "%CONFIG_FILE%" (
  echo [X] No existe config.env. Ejecuta setup-accesos.bat primero.
  goto :fin
)
if not exist ".git" (
  git init -b main >nul
  echo [OK] Repositorio local creado
)

set "GITHUB_TOKEN="
for /f "usebackq tokens=1,* delims==" %%A in ("%CONFIG_FILE%") do (
  if "%%A"=="GITHUB_TOKEN" set "GITHUB_TOKEN=%%B"
)
if "!GITHUB_TOKEN!"=="" (
  echo [X] Falta GITHUB_TOKEN en config.env.
  goto :fin
)

REM 0. Conectar con GitHub usando la URL guardada en config.env
set "CFG_REPO="
for /f "usebackq tokens=1,* delims==" %%A in ("%CONFIG_FILE%") do (
  if "%%A"=="GITHUB_REPO_URL" set "CFG_REPO=%%B"
)
git remote get-url origin >nul 2>nul
if errorlevel 1 (
  if "!CFG_REPO!"=="" (
    echo [X] No hay GITHUB_REPO_URL en config.env. Ejecuta setup-accesos.bat y pega la URL en el punto 6.
    goto :limpiar
  )
  git remote add origin "!CFG_REPO!"
  echo [OK] Repositorio remoto configurado
)

REM 1. Cancelar cualquier fusion a medias
if exist ".git\rebase-merge" git rebase --abort >nul 2>nul
if exist ".git\rebase-apply" git rebase --abort >nul 2>nul
if exist ".git\MERGE_HEAD" git merge --abort >nul 2>nul
echo [OK] Estado de Git limpio
echo.

REM 2. Confirmar cambios pendientes
git add -A
git diff --cached --quiet
if errorlevel 1 (
  git -c user.name="Tinta Laser Gestion" -c user.email="tintalaser.gestion@gmail.com" commit -q -m "Version local consolidada"
  echo [OK] Cambios pendientes confirmados
)

REM 3. Confirmacion explicita
set "OK="
set /p "OK=Continuar y reemplazar GitHub con tu carpeta local? (S/N): "
if /i not "!OK!"=="S" (
  echo Cancelado. No se cambio nada en GitHub.
  goto :fin
)

REM 4. Subir con autenticacion por cabecera
for /f %%B in ('powershell -NoProfile -Command "[Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes('x-access-token:' + $env:GITHUB_TOKEN))"') do set "B64=%%B"

git branch -M main
git -c http.extraheader="AUTHORIZATION: basic !B64!" push --force -u origin main
if errorlevel 1 (
  echo [X] No se pudo subir. Copia el mensaje y envialo al chat.
  goto :limpiar
)
git -c http.extraheader="AUTHORIZATION: basic !B64!" push --tags --force origin
echo.
echo [OK] GitHub quedo igual a tu carpeta local.

:limpiar
set "GITHUB_TOKEN="
set "B64="

:fin
echo.
pause
endlocal
