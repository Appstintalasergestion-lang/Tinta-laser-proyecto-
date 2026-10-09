# Tinta Láser · Integraciones, requisitos y decisiones

Esta guía separa lo que ya funciona, lo que requiere cuentas tuyas y lo que
conviene decidir antes de avanzar. Las cifras de costos son referenciales:
confírmalas en cada sitio antes de contratar.

## 1. Lo que ya funciona sin cuentas externas
- Cotizaciones, pedidos, inventario, mermas, Sercotec, calendario y recorrido guiado.
- F29 con códigos oficiales del instructivo del SII (Cód. 503, 502, 519, 520, 504, 89, 77, 62, 151, 91).
- Libro diario de partida doble, documentos PDF y planillas.
- Enviar cotizaciones por WhatsApp con el enlace oficial wa.me (gratuito, sin API).
- Conciliación de cartola bancaria (CSV).

## 2. SII: lo que la app puede y no puede hacer
| Tema | Realidad | Decisión recomendada |
|---|---|---|
| Declarar el F29 desde la app | No hay API pública para personas naturales ni empresas para presentar el F29 | Declarar en sii.cl; la app prepara los números |
| Emitir boletas y facturas | Deben emitirse en el SII o en software certificado (p. ej. LibreDTE) | Usar LibreDTE o el portal SII; la app solo registra el número |
| Guardar tu clave tributaria en la app | Riesgo alto de seguridad y no está permitido por el SII | **Nunca** guardarla en la app ni en el repositorio |
| Firma electrónica | Obligatoria para documentos y declaraciones | Tramítala y guárdala tú; la app solo te recuerda vencimientos |
| Automatizar el portal del SII con robots | Frágil y contrario a sus condiciones | No implementar |

## 3. WhatsApp
| Opción | Qué sirve | Costo | Recomendación |
|---|---|---|---|
| Enlace wa.me (ya integrado) | Enviar una cotización a un contacto con un toque | Gratis | Usar esta primero |
| WhatsApp Business app | Respuestas rápidas, catálogo, etiquetas | Gratis | Instalar en tu celular |
| WhatsApp Business Platform (API oficial de Meta) | Envíos automáticos y mensajes a gran escala | Por mensaje, con cuenta verificada | Solo cuando el volumen lo justifique |
| Librerías no oficiales (automatizar WhatsApp Web) | Automatización sin permiso de Meta | — | **No usar**: riesgo de bloqueo de tu número |

## 4. Dominio, correo y publicación
- **GitHub gratis:** basta para código y GitHub Pages.
- **GitHub Pro (pago):** no incluye dominio. Sirve para repositorios privados.
- **Dominio propio (ej. tintalaser.cl):** se compra aparte, cada año. Necesario para correos profesionales.
- **Correo con dominio:** Google Workspace o Zoho Mail (pagos) o el correo del dominio.
- **Resend (correo transaccional):** requiere dominio verificado con registros DNS. Solo lo necesitarás si tienes usuarios que se registran. Para uso personal no hace falta.
- **Confirmación de cuentas:** si la app es solo para ti, desactiva los registros públicos en Supabase.

## 5. Base de datos y nube
- **Supabase gratis:** suficiente para empezar. Los proyectos inactivos pueden pausarse.
- **Alternativas:** Firebase (Google), Cloudflare D1, o PocketBase (código abierto, autoalojado).
- Ejecuta `supabase/schema.sql` antes de conectar la sincronización.
- Guarda las claves en un archivo `.env` fuera del repositorio.

## 6. Programa de escritorio
- Carpeta `pc-app/` con Electron (MIT). Requiere Node.js LTS.
- Instalador para Windows, Mac o Linux con `npm run build:win` (u otro sistema).
- Sin firma digital, Windows advierte "editor desconocido". Una firma tiene costo anual.

## 7. Cosas que probablemente vas a necesitar y aún no has pensado
1. **Respaldos automáticos:** hoy dependen de que los descargues. La nube resuelve esto.
2. **Protección de datos personales:** la Ley 21.719 sobre datos personales entra en vigor a fines de 2026. Revisa sus obligaciones antes de guardar datos de clientes.
3. **Términos de uso y política de privacidad:** necesarios si otras personas usan la app.
4. **Cuenta bancaria exclusiva de la empresa:** separa ventas y gastos personales desde el primer día.
5. **Medios de pago para clientes:** transferencia, enlaces de pago u otros. Revisa comisiones antes de elegir.
6. **Seguro del taller:** cubre equipos (máquina láser) y responsabilidad frente a clientes.
7. **Mantención de la máquina láser:** lentes, correas y filtros. La app ya registra horas; falta un recordatorio.
8. **Ley de seguridad y salud en el trabajo:** aplica si tienes trabajadores; revisa con un prevencionista si contratas.
9. **Contrato con tu contador:** define quién prepara el F29, el balance y la renta, y con qué documentos.
10. **Copia de seguridad de la firma electrónica y de los certificados:** guárdalos en un lugar seguro fuera del equipo.
11. **Plan de contingencia:** qué hacer si el equipo falla un día de entrega.
12. **Actualizaciones:** revisar cada tres meses las fechas tributarias y los códigos del F29 en sii.cl.

## 8. Próximos pasos sugeridos (en orden)
1. Probar la app en tu celular desde `publicar/` y en tu PC con `pc-app/`.
2. Definir si la sincronización se hace con Supabase (recomendado) y crear la cuenta.
3. Consultar con tu contador los puntos 7.7 y 7.9.
4. Decidir si el envío por WhatsApp Business Platform es necesario (probablemente no al inicio).
