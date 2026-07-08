-- ============================================================
-- 007_cie10.sql — Catálogo CIE-10 (diagnósticos) para autocompletar
-- Datos se cargan aparte con scripts/load-cie10.mjs (≈12k códigos).
-- IDEMPOTENTE.
-- ============================================================

create table if not exists public.cie10 (
  code        text primary key,
  description text not null
);

-- Búsqueda por descripción (trigram) y por código
create index if not exists idx_cie10_desc_trgm on public.cie10
  using gin (description gin_trgm_ops);
create index if not exists idx_cie10_code on public.cie10 (code text_pattern_ops);

-- RLS: catálogo de referencia (no es dato de paciente).
alter table public.cie10 enable row level security;

drop policy if exists cie10_read on public.cie10;
create policy cie10_read on public.cie10
  for select using (public.current_role() in ('medico', 'recepcion', 'admin'));

drop policy if exists cie10_write on public.cie10;
create policy cie10_write on public.cie10
  for all using (public.current_role() in ('medico', 'admin'))
  with check (public.current_role() in ('medico', 'admin'));
