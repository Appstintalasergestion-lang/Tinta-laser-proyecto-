# Tinta Láser · Proyecto

Sistema de gestión y contador digital para TINTA LÁSER MANUFACTURA CIRCULAR SPA.

## Estructura

| Carpeta / archivo | Contenido |
|---|---|
| `main.js`, `package.json` | App de escritorio (Electron) |
| `web/` | Interfaz de la app (`index.html`) |
| `supabase/migrations/` | Cambios de la base de datos, en orden por fecha |
| `scripts/` | Lógica que usan los .bat |
| `docs/` | Documentación, checklist de cuentas y documentos de la empresa |
| `setup-accesos.bat` | Guarda claves y tokens en un archivo local fuera del proyecto |
| `aplicar-db.bat` | Aplica las migraciones pendientes a Supabase |
| `sincronizar.bat` | Confirma cambios, crea versión y sube a GitHub |

## Primer uso

1. Instala **Node.js (LTS)** y **Git**.
2. Ejecuta `setup-accesos.bat` y pega URL, claves y tokens. Se guardan en `%USERPROFILE%\.tinta-laser\config.env`.
3. Ejecuta `aplicar-db.bat` para crear las tablas en Supabase.
4. Ejecuta `sincronizar.bat` para subir el proyecto a GitHub.
5. Para abrir la app: `npm install` y luego `npm start`.

## Reglas

- Las claves nunca van en el proyecto ni dentro de un .bat. Solo en `config.env`.
- Cada cambio de base de datos es un archivo nuevo en `supabase/migrations/`. Nunca se edita uno ya aplicado.
- La interfaz se diseña como para celular o tablet, para que el paso a móvil sea directo.
- Antes de cerrar cada etapa de trabajo, `sincronizar.bat` guarda una versión.
