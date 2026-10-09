@echo off
chcp 65001 >nul
title Tinta Laser - Configuracion de accesos
setlocal

set "CONFIG_DIR=%USERPROFILE%\.tinta-laser"
set "CONFIG_FILE=%CONFIG_DIR%\config.env"

echo ================================================
echo   Tinta Laser - Configuracion de accesos
echo ================================================
echo.

REM --- 1. Herramientas necesarias ---
where node >nul 2>nul || (echo [X] Falta Node.js ^(nodejs.org, version LTS^) & goto :fin)
where git  >nul 2>nul || (echo [X] Falta Git ^(git-scm.com^) & goto :fin)
echo [OK] Node.js y Git instalados
echo.

REM --- 2. Carpeta local fuera de cualquier repositorio ---
if not exist "%CONFIG_DIR%" mkdir "%CONFIG_DIR%"
git -C "%CONFIG_DIR%" rev-parse --is-inside-work-tree >nul 2>nul
if not errorlevel 1 (
  echo [X] La carpeta de configuracion esta dentro de un repositorio Git.
  echo     Muevela fuera del proyecto antes de continuar.
  goto :fin
)
echo [OK] Carpeta de configuracion segura: %CONFIG_DIR%
echo.

REM --- 3. Leer valores actuales (si existen) ---
set "CUR_SUPA_URL="
set "CUR_ANON="
set "CUR_SERVICE="
set "CUR_GH="
set "CUR_SUPA_TOKEN="
set "CUR_REPO="
if exist "%CONFIG_FILE%" (
  for /f "usebackq tokens=1,* delims==" %%A in ("%CONFIG_FILE%") do (
    if "%%A"=="SUPABASE_URL" set "CUR_SUPA_URL=%%B"
    if "%%A"=="SUPABASE_ANON_KEY" set "CUR_ANON=%%B"
    if "%%A"=="SUPABASE_SERVICE_ROLE_KEY" set "CUR_SERVICE=%%B"
    if "%%A"=="GITHUB_TOKEN" set "CUR_GH=%%B"
    if "%%A"=="SUPABASE_ACCESS_TOKEN" set "CUR_SUPA_TOKEN=%%B"
    if "%%A"=="GITHUB_REPO_URL" set "CUR_REPO=%%B"
  )
)

echo Enter sin escribir nada = mantener el valor actual.
echo.

REM --- 4. Pedir cada dato (no se muestra en pantalla por lo que se escribe aqui) ---
set "NEW_SUPA_URL="
set /p "NEW_SUPA_URL=1) URL del proyecto Supabase: "

set "NEW_ANON="
set /p "NEW_ANON=2) anon key (publica, va en la app): "

set "NEW_SERVICE="
set /p "NEW_SERVICE=3) service_role key (SOLO mantenimiento, nunca en la app): "

set "NEW_SUPA_TOKEN="
set /p "NEW_SUPA_TOKEN=4) Supabase access token sbp_... (opcional): "

set "NEW_GH="
set /p "NEW_GH=5) Token de GitHub fine-grained (opcional): "

set "NEW_REPO="
set /p "NEW_REPO=6) URL del repositorio GitHub https://github.com/usuario/repo.git (opcional): "

REM --- 5. Elegir valor final ---
if defined NEW_SUPA_URL set "CUR_SUPA_URL=%NEW_SUPA_URL%"
if defined NEW_ANON set "CUR_ANON=%NEW_ANON%"
if defined NEW_SERVICE set "CUR_SERVICE=%NEW_SERVICE%"
if defined NEW_SUPA_TOKEN set "CUR_SUPA_TOKEN=%NEW_SUPA_TOKEN%"
if defined NEW_GH set "CUR_GH=%NEW_GH%"
if defined NEW_REPO set "CUR_REPO=%NEW_REPO%"

REM --- 6. Reescribir el archivo completo (sin residuos del anterior) ---
> "%CONFIG_FILE%" echo # Tinta Laser - configuracion local. NO copiar a ningun repositorio.
>> "%CONFIG_FILE%" echo CORREO_PROYECTO=tintalaser.gestion@gmail.com
>> "%CONFIG_FILE%" echo SUPABASE_URL=%CUR_SUPA_URL%
>> "%CONFIG_FILE%" echo SUPABASE_ANON_KEY=%CUR_ANON%
>> "%CONFIG_FILE%" echo SUPABASE_SERVICE_ROLE_KEY=%CUR_SERVICE%
>> "%CONFIG_FILE%" echo SUPABASE_ACCESS_TOKEN=%CUR_SUPA_TOKEN%
>> "%CONFIG_FILE%" echo GITHUB_TOKEN=%CUR_GH%
>> "%CONFIG_FILE%" echo GITHUB_REPO_URL=%CUR_REPO%

echo.
echo [OK] Configuracion guardada en %CONFIG_FILE%
echo.
echo Recordatorios:
echo  - La service_role y los tokens NUNCA van en la app ni en el repositorio.
echo  - Si alguna clave se compartio en un chat, regenerala en Supabase / GitHub.
echo  - El token de GitHub debe ser fine-grained, solo para este repositorio y con vencimiento.

:fin
echo.
pause
endlocal
