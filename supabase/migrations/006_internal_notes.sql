-- ============================================================
-- 006_internal_notes.sql — Coordinación interna del consultorio
-- Tablero compartido entre médico y recepción: tareas (checklist) y
-- mensajes internos (recados). No es dato clínico; es operación diaria.
-- ============================================================

create type internal_note_kind as enum ('tarea', 'mensaje');

create table public.internal_notes (
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

create index idx_internal_open on public.internal_notes (created_at desc);
create index idx_internal_pending on public.internal_notes (kind, is_done) where is_done = false;

create trigger set_updated_at
  before update on public.internal_notes
  for each row execute function public.set_updated_at();

-- Coordinación interna: médico, recepción y admin gestionan todo el tablero.
alter table public.internal_notes enable row level security;

create policy internal_notes_rw on public.internal_notes
  for all using (public.current_role() in ('medico', 'recepcion', 'admin'))
  with check (public.current_role() in ('medico', 'recepcion', 'admin'));
