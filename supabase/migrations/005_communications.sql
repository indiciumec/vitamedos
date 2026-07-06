-- ============================================================
-- 005_communications.sql — Bitácora de comunicaciones (CRM WhatsApp sobre wa.me)
-- Registra cada contacto INICIADO con el paciente (los enlaces wa.me no pueden
-- confirmar entrega/lectura; el estado se marca manualmente). Base del módulo
-- Contactos: cola de "a quién contactar hoy" + historial en el timeline.
--
-- IDEMPOTENTE: se puede correr varias veces sin error.
-- ============================================================

do $$ begin
  create type communication_kind as enum (
    'confirmacion', 'recordatorio', 'postconsulta', 'control', 'pago', 'manual'
  );
exception when duplicate_object then null;
end $$;

do $$ begin
  create type communication_status as enum (
    'enviado', 'respondido', 'confirmado', 'sin_respuesta'
  );
exception when duplicate_object then null;
end $$;

create table if not exists public.communications (
  id               uuid primary key default gen_random_uuid(),
  patient_id       uuid not null references public.patients(id) on delete cascade,
  channel          text not null default 'whatsapp',
  kind             communication_kind not null default 'manual',
  message_snapshot text,                                    -- lo que se envió
  status           communication_status not null default 'enviado',
  appointment_id   uuid references public.appointments(id)  on delete set null,
  consultation_id  uuid references public.consultations(id) on delete set null,
  follow_up_date   date,                                    -- próximo contacto sugerido
  notes            text,
  created_by       uuid references public.profiles(id),
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create index if not exists idx_comm_patient   on public.communications (patient_id, created_at desc);
create index if not exists idx_comm_followup  on public.communications (follow_up_date) where follow_up_date is not null;
create index if not exists idx_comm_appt      on public.communications (appointment_id) where appointment_id is not null;

drop trigger if exists set_updated_at on public.communications;
create trigger set_updated_at
  before update on public.communications
  for each row execute function public.set_updated_at();

drop trigger if exists audit_trigger on public.communications;
create trigger audit_trigger
  after insert or update or delete on public.communications
  for each row execute function public.audit_trigger();

-- RLS: médico, recepción y admin gestionan comunicaciones (contacto operativo).
alter table public.communications enable row level security;

drop policy if exists communications_rw on public.communications;
create policy communications_rw on public.communications
  for all using (public.current_role() in ('medico', 'recepcion', 'admin'))
  with check (public.current_role() in ('medico', 'recepcion', 'admin'));
