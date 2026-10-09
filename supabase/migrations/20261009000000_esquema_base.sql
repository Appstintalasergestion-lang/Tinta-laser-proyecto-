-- =====================================================================
-- Tinta Laser · Esquema base (v1)
-- Ejecutar en Supabase > SQL Editor. Se puede ejecutar mas de una vez.
-- Principio: cada dato pertenece a una empresa y solo lo ven sus miembros
-- (Row Level Security activo desde el inicio).
-- =====================================================================

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------
-- 1. Perfiles (uno por usuario autenticado)
-- ---------------------------------------------------------------------
create table if not exists public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  nombre      text,
  correo      text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 2. Empresas
-- ---------------------------------------------------------------------
create table if not exists public.companies (
  id            uuid primary key default gen_random_uuid(),
  rut           text not null unique,
  razon_social  text not null,
  regimen       text not null default 'pro_pyme_14d8',
  created_by    uuid references auth.users(id) on delete set null,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 3. Membresias: quien puede operar cada empresa y con que rol
-- ---------------------------------------------------------------------
create table if not exists public.company_members (
  company_id  uuid not null references public.companies(id) on delete cascade,
  user_id     uuid not null references auth.users(id) on delete cascade,
  role        text not null check (role in ('owner','admin','contador','lector')),
  created_at  timestamptz not null default now(),
  primary key (company_id, user_id)
);

-- ---------------------------------------------------------------------
-- 4. Funciones auxiliares (security definer evita recursion en RLS)
-- ---------------------------------------------------------------------
create or replace function public.is_member(p_company uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.company_members m
    where m.company_id = p_company and m.user_id = auth.uid()
  );
$$;

create or replace function public.has_role(p_company uuid, p_roles text[])
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.company_members m
    where m.company_id = p_company
      and m.user_id = auth.uid()
      and m.role = any(p_roles)
  );
$$;

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_profiles_upd on public.profiles;
create trigger trg_profiles_upd before update on public.profiles
  for each row execute function public.set_updated_at();

drop trigger if exists trg_companies_upd on public.companies;
create trigger trg_companies_upd before update on public.companies
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------
-- 5. Crear perfil automaticamente al registrarse un usuario
-- ---------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, correo, nombre)
  values (new.id, new.email, coalesce(new.raw_user_meta_data->>'nombre', ''))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------
-- 6. Crear empresa: el usuario que la crea queda como owner
--    (no se permite insertar empresas directamente)
-- ---------------------------------------------------------------------
create or replace function public.crear_empresa(p_rut text, p_razon_social text)
returns uuid language plpgsql security definer set search_path = public as $$
declare
  v_id uuid;
begin
  if auth.uid() is null then
    raise exception 'No autenticado';
  end if;

  insert into public.companies (rut, razon_social, created_by)
  values (p_rut, p_razon_social, auth.uid())
  returning id into v_id;

  insert into public.company_members (company_id, user_id, role)
  values (v_id, auth.uid(), 'owner');

  return v_id;
end;
$$;

-- ---------------------------------------------------------------------
-- 7. Row Level Security
-- ---------------------------------------------------------------------
alter table public.profiles        enable row level security;
alter table public.companies       enable row level security;
alter table public.company_members enable row level security;

-- Perfiles: cada usuario ve y edita solo el suyo
drop policy if exists "perfil: ver propio" on public.profiles;
create policy "perfil: ver propio" on public.profiles
  for select using (id = auth.uid());

drop policy if exists "perfil: editar propio" on public.profiles;
create policy "perfil: editar propio" on public.profiles
  for update using (id = auth.uid()) with check (id = auth.uid());

-- Empresas: ver si es miembro; editar solo owner/admin; sin insert/delete directo
drop policy if exists "empresa: ver si es miembro" on public.companies;
create policy "empresa: ver si es miembro" on public.companies
  for select using (public.is_member(id));

drop policy if exists "empresa: editar owner/admin" on public.companies;
create policy "empresa: editar owner/admin" on public.companies
  for update using (public.has_role(id, array['owner','admin']))
  with check (public.has_role(id, array['owner','admin']));

-- Membresias: ver las de mis empresas; solo el owner administra miembros
drop policy if exists "miembros: ver de mis empresas" on public.company_members;
create policy "miembros: ver de mis empresas" on public.company_members
  for select using (public.is_member(company_id));

drop policy if exists "miembros: gestionar solo owner" on public.company_members;
create policy "miembros: gestionar solo owner" on public.company_members
  for all using (public.has_role(company_id, array['owner']))
  with check (public.has_role(company_id, array['owner']));

-- ---------------------------------------------------------------------
-- Regla para tablas futuras (ventas, facturas, inventario, etc.):
--   company_id uuid not null references companies(id)
--   alter table ... enable row level security;
--   policy select: public.is_member(company_id)
--   policy write:  public.has_role(company_id, array['owner','admin','contador'])
-- ---------------------------------------------------------------------
