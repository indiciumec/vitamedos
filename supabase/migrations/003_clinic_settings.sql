-- ============================================================
-- 003_clinic_settings.sql — Perfil del consultorio (singleton)
-- (Numerada 003: la 002 es el vademécum Ecuador.)
-- ============================================================

create table public.clinic_settings (
  id                 int primary key default 1 check (id = 1),
  clinic_name        text not null default 'Vitamed',
  professional_name  text,
  professional_title text default 'Medicina General',
  license_number     text,
  address            text,
  phone              text,
  whatsapp           text,
  email              text,
  updated_at         timestamptz not null default now()
);

insert into public.clinic_settings (id) values (1)
on conflict (id) do nothing;

-- Triggers existentes: updated_at + auditoría
create trigger set_updated_at
  before update on public.clinic_settings
  for each row execute function public.set_updated_at();

create trigger audit_trigger
  after insert or update or delete on public.clinic_settings
  for each row execute function public.audit_trigger();

-- RLS: lectura para roles operativos, escritura solo medico/admin
alter table public.clinic_settings enable row level security;

create policy clinic_settings_read on public.clinic_settings
  for select using (public.current_role() in ('medico', 'recepcion', 'admin'));

create policy clinic_settings_update on public.clinic_settings
  for update using (public.current_role() in ('medico', 'admin'))
  with check (public.current_role() in ('medico', 'admin'));
