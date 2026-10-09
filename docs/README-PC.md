# Programa de escritorio (Windows, Mac, Linux)

Esta carpeta convierte la app en un programa instalable en tu PC, usando **Electron** (licencia MIT).

## Requisitos
- Node.js LTS (descárgalo de nodejs.org).

## Probar
```
cd pc-app
npm install
npm start
```

## Crear el instalador
```
npm run build:win     # genera un instalador .exe en dist/
```
La primera vez tarda unos minutos porque descarga Electron.

## Datos
Los datos se guardan en el perfil de tu usuario del sistema (no dentro de la carpeta del programa).
Antes de reinstalar, descarga un respaldo desde Ajustes.

## Firma del instalador
Sin firma digital, Windows muestra una advertencia "editor desconocido". Es normal en apps propias.
Una firma de código tiene costo anual; decídelo más adelante.
