# Tinta Láser · Guía de tareas

Estados: ✅ hecho · 🔄 en curso · ⬜ pendiente

## Etapa 0 · Base técnica ✅
- ✅ Correo único del proyecto (tintalaser.gestion@gmail.com)
- ✅ Gestor de contraseñas y checklist de cuentas (docs/CUENTAS_TINTA_LASER.md)
- ✅ Supabase con esquema base y Row Level Security
- ✅ Repositorio en GitHub con versiones etiquetadas
- ✅ Scripts: setup-accesos, aplicar-db, sincronizar, diagnostico-github

## Etapa 1 · Base de datos del negocio 🔄
- ✅ Empresas, miembros y roles (owner, admin, contador, lector)
- ✅ Perfiles automáticos al registrarse
- 🔄 Clientes, cotizaciones e items (migración lista, falta aplicar)
- ⬜ Pedidos y productos
- ⬜ Inventario y mermas
- ⬜ Documentos tributarios (boletas, facturas, DTE) y su registro

## Etapa 2 · App de escritorio conectada ⬜
- ⬜ Corregir la carga de `web/index.html` (ya está en la ruta correcta)
- ⬜ Inicio de sesión con contraseña por usuario
- ⬜ Conectar cotizaciones a Supabase en lugar de datos locales

## Etapa 3 · Interfaz móvil y tablet ⬜
- ⬜ Diseño de pantallas pensado para celular primero
- ⬜ Navegador guiado integrado para cada trámite, con validación de cada paso

## Etapa 4 · Ciclo del contribuyente ⬜
- ⬜ Ciclo mensual, anual y de inicio de actividades según el perfil de la empresa
- ⬜ Alertas de vencimientos (F29, renta, patentes)

## Etapa 5 · Simulador SII ⬜
- ⬜ Simulador de F29 con las mismas validaciones del SII
- ⬜ Preparación de la presentación final, con confirmación del usuario antes de enviar

## Etapa 6 · Contador digital ⬜
- ⬜ Base legal chilena que aplica al negocio
- ⬜ Herramientas de cálculo (IVA, PPM, retenciones, depreciación)
- ⬜ Revisión de consistencia contable (partida doble, cuadres, auditoría)

## Etapa 7 · Redes y respuestas automáticas ⬜
- ⬜ WhatsApp Business y redes de la empresa vinculadas
- ⬜ Respuestas automáticas para consultas frecuentes

## Etapa 8 · Instalación y descargas ⬜
- ⬜ bat de instalación de dependencias pesadas al ejecutar el proyecto
- ⬜ Limpieza y orden automático de carpetas

## Etapa 9 · Entrega ⬜
- ⬜ Revisión final de seguridad
- ⬜ Rotación de todas las claves al terminar la construcción
