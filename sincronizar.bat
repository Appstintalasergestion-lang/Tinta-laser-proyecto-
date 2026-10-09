@echo off
chcp 65001 >nul
title Tinta Laser - Sincronizar con GitHub
setlocal EnableExtensions EnableDelayedExpansion

set "CONFIG_FILE=%USERPROFILE%\.tinta-laser\config.env"
cd /d "%~dp0"

echo ================================================
echo   Tinta Laser - Sincronizar con GitHub
echo ================================================
echo.

REM --- 1. Requisitos ---
where git >nul 2>nul || (echo [X] Falta Git ^(git-scm.com^) & goto :fin)
if not exist "%CONFIG_FILE%" (
  echo [X] No existe la configuracion. Ejecuta setup-accesos.bat primero.
  goto :fin
)

REM --- 2. Token de GitHub (solo en memoria, nunca en el repositorio) ---
set "GITHUB_TOKEN="
for /f "usebackq tokens=1,* delims==" %%A in ("%CONFIG_FILE%") do (
  if "%%A"=="GITHUB_TOKEN" set "GITHUB_TOKEN=%%B"
)
if "!GITHUB_TOKEN!"=="" (
  echo [X] Falta GITHUB_TOKEN en la configuracion. Ejecuta setup-accesos.bat.
  goto :fin
)

REM --- 3. Repositorio local y remoto ---
if not exist ".git" (
  git init -b main >nul
  echo [OK] Repositorio local creado
)
if not exist ".gitignore" call :crear_gitignore

git remote get-url origin >nul 2>nul
if errorlevel 1 (
  set "REPO_URL="
  set /p "REPO_URL=URL del repositorio GitHub (https://github.com/usuario/repo.git): "
  if "!REPO_URL!"=="" (
    echo [X] Sin URL de repositorio.
    goto :limpiar
  )
  git remote add origin "!REPO_URL!"
  if errorlevel 1 (
    echo [X] No se pudo registrar la URL. Debe ser una direccion https de GitHub.
    goto :limpiar
  )
  echo [OK] Repositorio remoto configurado
)
echo.

REM --- 4. Preparar cambios ---
git add -A

REM --- 5. Revision de seguridad: no subir claves reales ---
REM Los patrones se arman en partes para que este script no se detecte a si mismo.
set "K1=sbp"
set "K1=!K1!_"
set "K2=github"
set "K2=!K2!_pat_"
set "K3=ghp"
set "K3=!K3!_"
set "K4=eyJ"
set "K4=!K4!hbGci"

git diff --cached -U0 > "%TEMP%\tl-diff.txt"
findstr /I /R "!K1![A-Za-z0-9] !K2![A-Za-z0-9] !K3![A-Za-z0-9] !K4!" "%TEMP%\tl-diff.txt" >nul
if not errorlevel 1 (
  echo [X] Se detecto una posible clave en los cambios. NADA fue subido.
  echo     Revisa con: git diff --cached
  git reset -q
  del "%TEMP%\tl-diff.txt" >nul 2>nul
  goto :limpiar
)
del "%TEMP%\tl-diff.txt" >nul 2>nul
echo [OK] Revision de seguridad aprobada
echo.

REM --- 6. Confirmar cambios y etiquetar version ---
git diff --cached --quiet
if errorlevel 1 (
  for /f %%T in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HHmm"') do set "STAMP=%%T"
  git -c user.name="Tinta Laser Gestion" -c user.email="tintalaser.gestion@gmail.com" commit -q -m "Version !STAMP!"
  git tag -a "v!STAMP!" -m "Version !STAMP!"
  echo [OK] Nueva version confirmada: v!STAMP!
) else (
  echo No hay cambios nuevos que confirmar.
)
echo.

REM --- 7. Subir a GitHub (token por cabecera, no queda guardado) ---
for /f %%B in ('powershell -NoProfile -Command "[Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes('x-access-token:' + $env:GITHUB_TOKEN))"') do set "B64=%%B"

echo Sincronizando con GitHub...
git -c http.extraheader="AUTHORIZATION: basic !B64!" ls-remote --exit-code --heads origin main >nul 2>nul
if errorlevel 1 (
  echo [..] El repositorio remoto esta vacio: primera subida.
) else (
  git -c http.extraheader="AUTHORIZATION: basic !B64!" pull --rebase -q origin main
  if errorlevel 1 (
    echo [X] No se pudo actualizar desde GitHub. Revisa el mensaje anterior.
    goto :limpiar
  )
)
git -c http.extraheader="AUTHORIZATION: basic !B64!" push -q -u origin main --follow-tags
if errorlevel 1 (
  echo [X] No se pudo subir. Revisa el token y los permisos del repositorio.
  goto :limpiar
)
echo [OK] Subido a GitHub.
echo.

REM --- 8. Opcional: aplicar migraciones a Supabase ---
if exist "supabase\migrations\*.sql" (
  set "APLICAR="
  set /p "APLICAR=Aplicar migraciones a Supabase ahora? (S/N): "
  if /i "!APLICAR!"=="S" call "%~dp0aplicar-db.bat"
)

:limpiar
set "GITHUB_TOKEN="
set "B64="
goto :fin

:crear_gitignore
> .gitignore echo # Tinta Laser - nunca subir secretos
>> .gitignore echo .env
>> .gitignore echo *.env
>> .gitignore echo *.key
>> .gitignore echo *.pem
>> .gitignore echo config.env
>> .gitignore echo supabase/.temp/
>> .gitignore echo node_modules/
>> .gitignore echo dist/
>> .gitignore echo .DS_Store
>> .gitignore echo Thumbs.db
>> .gitignore echo docs/empresa/
echo [OK] .gitignore creado
exit /b 0

:fin
echo.
pause
endlocal
