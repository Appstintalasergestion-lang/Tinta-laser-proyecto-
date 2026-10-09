-- =====================================================================
-- Clientes y cotizaciones (pesos chilenos: montos sin decimales)
-- Acceso: miembros de la empresa. Escritura: owner, admin y contador.
-- =====================================================================

-- ---------- Clientes ----------
create table if not exists public.clientes (
  id          uuid primary key default gen_random_uuid(),
  company_id  uuid not null references public.companies(id) on delete cascade,
  rut         text,
  nombre      text not null,
  giro        text,
  correo      text,
  telefono    text,
  direccion   text,
  created_by  uuid references auth.users(id) on delete set null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (company_id, rut)
);

-- ---------- Cotizaciones ----------
create table if not exists public.cotizaciones (
  id          uuid primary key default gen_random_uuid(),
  company_id  uuid not null references public.companies(id) on delete cascade,
  cliente_id  uuid references public.clientes(id) on delete set null,
  numero      integer not null,
  fecha       date not null default current_date,
  estado      text not null default 'borrador'
              check (estado in ('borrador','enviada','aceptada','rechazada','vencida')),
  neto        numeric(14,0) not null default 0,
  iva         numeric(14,0) not null default 0,
  total       numeric(14,0) not null default 0,
  notas       text,
  created_by  uuid references auth.users(id) on delete set null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (company_id, numero)
);

-- ---------- Items de cotizacion ----------
create table if not exists public.cotizacion_items (
  id               uuid primary key default gen_random_uuid(),
  company_id       uuid not null references public.companies(id) on delete cascade,
  cotizacion_id    uuid not null references public.cotizaciones(id) on delete cascade,
  descripcion      text not null,
  cantidad         numeric(14,2) not null default 1,
  precio_unitario  numeric(14,0) not null default 0,
  subtotal         numeric(14,0) not null default 0,
  created_at       timestamptz not null default now()
);

-- ---------- Actualizar fecha de modificacion ----------
drop trigger if exists trg_clientes_upd on public.clientes;
create trigger trg_clientes_upd before update on public.clientes
  for each row execute function public.set_updated_at();

drop trigger if exists trg_cotizaciones_upd on public.cotizaciones;
create trigger trg_cotizaciones_upd before update on public.cotizaciones
  for each row execute function public.set_updated_at();

-- ---------- Row Level Security ----------
alter table public.clientes          enable row level security;
alter table public.cotizaciones      enable row level security;
alter table public.cotizacion_items  enable row level security;

drop policy if exists "clientes: ver" on public.clientes;
create policy "clientes: ver" on public.clientes
  for select using (public.is_member(company_id));
drop policy if exists "clientes: escribir" on public.clientes;
create policy "clientes: escribir" on public.clientes
  for all using (public.has_role(company_id, array['owner','admin','contador']))
  with check (public.has_role(company_id, array['owner','admin','contador']));

drop policy if exists "cotizaciones: ver" on public.cotizaciones;
create policy "cotizaciones: ver" on public.cotizaciones
  for select using (public.is_member(company_id));
drop policy if exists "cotizaciones: escribir" on public.cotizaciones;
create policy "cotizaciones: escribir" on public.cotizaciones
  for all using (public.has_role(company_id, array['owner','admin','contador']))
  with check (public.has_role(company_id, array['owner','admin','contador']));

drop policy if exists "items: ver" on public.cotizacion_items;
create policy "items: ver" on public.cotizacion_items
  for select using (public.is_member(company_id));
drop policy if exists "items: escribir" on public.cotizacion_items;
create policy "items: escribir" on public.cotizacion_items
  for all using (public.has_role(company_id, array['owner','admin','contador']))
  with check (public.has_role(company_id, array['owner','admin','contador']));
