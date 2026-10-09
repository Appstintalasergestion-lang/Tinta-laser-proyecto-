-- Protege el historial de migraciones: sin RLS, la API publica lo expone con la anon key.
-- Sin politicas: anon y authenticated no pueden leer ni escribir. Solo el propietario (scripts) accede.
alter table public.schema_migrations enable row level security;
