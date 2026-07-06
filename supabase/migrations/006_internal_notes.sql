-- ============================================================
-- 006_internal_notes.sql — Coordinación interna del consultorio
-- Tablero compartido entre médico y recepción: tareas (checklist) y
-- mensajes internos (recados). No es dato clínico; es operación diaria.
--
-- IDEMPOTENTE: se puede correr varias veces sin error.
-- ============================================================

-- Enum (guard para re-ejecución: Postgres no tiene CREATE TYPE IF NOT EXISTS)
do $$ begin
  create type internal_note_kind as enum ('tarea', 'mensaje');
exception when duplicate_object then null;
end $$;

create table if not exists public.internal_notes (
  id           uuid primary key default gen_random_uuid(),
  kind         internal_note_kind not null default 'tarea',
  body         text not null,
  target_role  text,                    -- 'medico' | 'recepcion' | null (para todos)
  patient_id   uuid references public.patients(id) on delete set null,
  author_name  text,                    -- snapshot para mostrar sin join a profiles (RLS)
  is_done      boolean not null default false,
  done_at      timestamptz,
  created_by   uuid references public.profiles(id),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create index if not exists idx_internal_open on public.internal_notes (created_at desc);
create index if not exists idx_internal_pending on public.internal_notes (kind, is_done) where is_done = false;

drop trigger if exists set_updated_at on public.internal_notes;
create trigger set_updated_at
  before update on public.internal_notes
  for each row execute function public.set_updated_at();

-- Coordinación interna: médico, recepción y admin gestionan todo el tablero.
alter table public.internal_notes enable row level security;

drop policy if exists internal_notes_rw on public.internal_notes;
create policy internal_notes_rw on public.internal_notes
  for all using (public.current_role() in ('medico', 'recepcion', 'admin'))
  with check (public.current_role() in ('medico', 'recepcion', 'admin'));
