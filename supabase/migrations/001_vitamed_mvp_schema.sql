-- ============================================================
-- VITAMED OS — MVP v0.1
-- Migración inicial Supabase (PostgreSQL 15+)
-- Alcance: pacientes, agenda, consulta, receta DCI, vademécum,
--          documentos, caja, auditoría, RLS por rol.
-- Ejecutar en SQL Editor de Supabase o via supabase db push.
-- ============================================================

-- ------------------------------------------------------------
-- 0. EXTENSIONES
-- ------------------------------------------------------------
create extension if not exists "pgcrypto";      -- gen_random_uuid
create extension if not exists "pg_trgm";       -- búsqueda fuzzy de pacientes

-- ------------------------------------------------------------
-- 1. ENUMS
-- ------------------------------------------------------------
create type user_role as enum ('medico', 'recepcion', 'admin', 'tecnico');

create type appointment_status as enum (
  'solicitada', 'por_confirmar', 'confirmada', 'en_espera',
  'en_consulta', 'atendida', 'cancelada', 'no_asistio'
);

create type consultation_status as enum ('borrador', 'cerrada', 'enmendada', 'anulada');

create type document_type as enum (
  'certificado_medico', 'reposo_medico', 'constancia_asistencia',
  'solicitud_examenes', 'referencia_especialista', 'informe_clinico',
  'consentimiento_informado', 'consentimiento_datos'
);

create type payment_method as enum ('efectivo', 'transferencia', 'tarjeta', 'cortesia', 'pendiente');
create type payment_status as enum ('pagado', 'pendiente', 'cortesia', 'anulado');

create type identification_type as enum ('cedula', 'pasaporte', 'ruc');

-- ------------------------------------------------------------
-- 2. PERFILES (extiende auth.users de Supabase)
-- ------------------------------------------------------------
create table public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  full_name   text not null,
  role        user_role not null default 'recepcion',
  is_active   boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Helper: rol del usuario actual (SECURITY DEFINER evita recursión en RLS)
create or replace function public.current_role()
returns user_role
language sql stable security definer set search_path = public
as $$
  select role from public.profiles where id = auth.uid() and is_active;
$$;

-- ------------------------------------------------------------
-- 3. PACIENTES
-- ------------------------------------------------------------
create table public.patients (
  id                      uuid primary key default gen_random_uuid(),
  identification_type     identification_type not null default 'cedula',
  identification_number   text not null,
  first_name              text not null,
  last_name               text not null,
  birth_date              date,
  sex                     text check (sex in ('M','F','O')),
  phone                   text,
  whatsapp                text,
  email                   text,
  address                 text,
  sector                  text,
  emergency_contact_name  text,
  emergency_contact_phone text,
  -- Datos clínicos de cabecera (acceso restringido vía vista, ver §10)
  allergies               text,
  personal_history        text,
  family_history          text,
  current_medication      text,
  notes                   text,
  -- Consentimiento LOPDP
  data_consent_signed     boolean not null default false,
  data_consent_date       timestamptz,
  created_by              uuid references public.profiles(id),
  created_at              timestamptz not null default now(),
  updated_at              timestamptz not null default now(),
  unique (identification_type, identification_number)
);

create index idx_patients_name_trgm on public.patients
  using gin ((first_name || ' ' || last_name) gin_trgm_ops);
create index idx_patients_ident on public.patients (identification_number);
create index idx_patients_phone on public.patients (phone);

-- Edad calculada (no se almacena, se deriva)
create or replace function public.patient_age(p_birth date)
returns int language sql immutable
as $$ select extract(year from age(current_date, p_birth))::int $$;

-- ------------------------------------------------------------
-- 4. SERVICIOS Y AGENDA
-- ------------------------------------------------------------
create table public.services (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  price       numeric(10,2) not null default 0,
  duration_min int not null default 30,
  is_active   boolean not null default true,
  created_at  timestamptz not null default now()
);

create table public.appointments (
  id            uuid primary key default gen_random_uuid(),
  patient_id    uuid not null references public.patients(id),
  service_id    uuid references public.services(id),
  scheduled_at  timestamptz not null,
  duration_min  int not null default 30,
  reason        text,
  status        appointment_status not null default 'solicitada',
  phone_snapshot text,
  notes         text,
  created_by    uuid references public.profiles(id),
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create index idx_appointments_date on public.appointments (scheduled_at);
create index idx_appointments_patient on public.appointments (patient_id);
create index idx_appointments_status on public.appointments (status);

-- ------------------------------------------------------------
-- 5. CONSULTAS
-- ------------------------------------------------------------
create table public.consultations (
  id                uuid primary key default gen_random_uuid(),
  patient_id        uuid not null references public.patients(id),
  appointment_id    uuid references public.appointments(id),
  doctor_id         uuid not null references public.profiles(id),
  reason            text,
  current_illness   text,
  vital_signs       jsonb default '{}'::jsonb,  -- {pa, fc, fr, temp, spo2, peso, talla, imc}
  physical_exam     text,
  diagnosis_code    text,           -- CIE-10
  diagnosis_text    text,
  treatment_plan    text,
  recommendations   text,
  requested_exams   text,
  next_control_date date,
  status            consultation_status not null default 'borrador',
  closed_at         timestamptz,
  -- Enmiendas: consulta cerrada nunca se edita, se enmienda
  amended_by_id     uuid references public.consultations(id),
  amendment_note    text,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create index idx_consultations_patient on public.consultations (patient_id, created_at desc);
create index idx_consultations_status on public.consultations (status);

-- REGLA CRÍTICA: inmutabilidad de consulta cerrada
create or replace function public.block_closed_consultation_edit()
returns trigger language plpgsql
as $$
begin
  if old.status in ('cerrada', 'anulada') then
    -- Solo se permite marcarla como 'enmendada' vinculando la nueva consulta
    if not (new.status = 'enmendada'
            and new.amended_by_id is not null
            and row(new.*) is not distinct from row(
              old.id, old.patient_id, old.appointment_id, old.doctor_id,
              old.reason, old.current_illness, old.vital_signs, old.physical_exam,
              old.diagnosis_code, old.diagnosis_text, old.treatment_plan,
              old.recommendations, old.requested_exams, old.next_control_date,
              'enmendada'::consultation_status, old.closed_at,
              new.amended_by_id, new.amendment_note, old.created_at, new.updated_at
            )) then
      raise exception 'Consulta cerrada no editable. Cree una enmienda (nueva consulta vinculada).';
    end if;
  end if;
  return new;
end $$;

create trigger trg_consultations_immutable
  before update on public.consultations
  for each row execute function public.block_closed_consultation_edit();

-- ------------------------------------------------------------
-- 6. VADEMÉCUM
-- ------------------------------------------------------------
create table public.drug_catalog (
  id                  uuid primary key default gen_random_uuid(),
  generic_name        text not null,            -- DCI: campo rector
  therapeutic_class   text,
  pharmaceutical_form text,
  concentration       text,
  route               text default 'Oral',
  usual_quantity      text,
  usual_dose          text,
  usual_frequency     text,
  usual_duration      text,
  usual_indications   text,
  warnings            text,
  is_active           boolean not null default true,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create index idx_drug_generic_trgm on public.drug_catalog
  using gin (generic_name gin_trgm_ops);

create table public.commercial_brands (
  id              uuid primary key default gen_random_uuid(),
  drug_catalog_id uuid not null references public.drug_catalog(id) on delete cascade,
  brand_name      text not null,
  laboratory      text,
  notes           text,
  is_preferred    boolean not null default false,
  is_active       boolean not null default true
);

-- ------------------------------------------------------------
-- 7. RECETAS
-- ------------------------------------------------------------
create sequence public.prescription_number_seq start 1;

create table public.prescriptions (
  id                  uuid primary key default gen_random_uuid(),
  prescription_number bigint not null default nextval('public.prescription_number_seq'),
  patient_id          uuid not null references public.patients(id),
  consultation_id     uuid references public.consultations(id),
  doctor_id           uuid not null references public.profiles(id),
  diagnosis_code      text,
  diagnosis_text      text,
  allergies_snapshot  text,        -- copia al momento de emitir
  status              text not null default 'emitida' check (status in ('emitida','anulada')),
  qr_token            uuid not null default gen_random_uuid(),
  issued_at           timestamptz not null default now(),
  created_at          timestamptz not null default now()
);

create index idx_prescriptions_patient on public.prescriptions (patient_id, issued_at desc);

create table public.prescription_items (
  id                        uuid primary key default gen_random_uuid(),
  prescription_id           uuid not null references public.prescriptions(id) on delete cascade,
  drug_catalog_id           uuid references public.drug_catalog(id),
  -- REGLA DCI: genérico obligatorio, snapshot inmutable
  generic_name_snapshot     text not null check (length(trim(generic_name_snapshot)) > 0),
  concentration             text,
  pharmaceutical_form       text,
  route                     text,
  quantity                  text,
  dose                      text,
  frequency                 text,
  duration                  text,
  instructions              text,
  -- Marca comercial: opcional, editable, nunca sustituye al genérico
  optional_commercial_brand text,
  created_at                timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 8. DOCUMENTOS MÉDICOS
-- ------------------------------------------------------------
create sequence public.document_number_seq start 1;

create table public.document_templates (
  id            uuid primary key default gen_random_uuid(),
  doc_type      document_type not null,
  name          text not null,
  body_template text not null,     -- con placeholders {{paciente}}, {{fecha}}, {{diagnostico}}...
  is_active     boolean not null default true,
  created_at    timestamptz not null default now()
);

create table public.medical_documents (
  id              uuid primary key default gen_random_uuid(),
  document_number bigint not null default nextval('public.document_number_seq'),
  doc_type        document_type not null,
  patient_id      uuid not null references public.patients(id),
  consultation_id uuid references public.consultations(id),
  issued_by       uuid not null references public.profiles(id),
  body_final      text not null,   -- texto ya resuelto/editado
  qr_token        uuid not null default gen_random_uuid(),
  issued_at       timestamptz not null default now()
);

create index idx_documents_patient on public.medical_documents (patient_id, issued_at desc);

-- ------------------------------------------------------------
-- 9. CAJA
-- ------------------------------------------------------------
create table public.payments (
  id              uuid primary key default gen_random_uuid(),
  patient_id      uuid not null references public.patients(id),
  consultation_id uuid references public.consultations(id),
  service_id      uuid references public.services(id),
  amount          numeric(10,2) not null default 0,
  method          payment_method not null default 'efectivo',
  status          payment_status not null default 'pagado',
  notes           text,
  paid_at         timestamptz,
  registered_by   uuid references public.profiles(id),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create index idx_payments_date on public.payments (created_at);
create index idx_payments_status on public.payments (status);

-- ------------------------------------------------------------
-- 10. AUDITORÍA
-- ------------------------------------------------------------
create table public.audit_logs (
  id          bigint generated always as identity primary key,
  occurred_at timestamptz not null default now(),
  user_id     uuid,                 -- auth.uid(), null en operaciones de sistema
  action      text not null,       -- INSERT / UPDATE / DELETE
  table_name  text not null,
  record_id   text,
  old_data    jsonb,
  new_data    jsonb
);

create index idx_audit_table_record on public.audit_logs (table_name, record_id);
create index idx_audit_user on public.audit_logs (user_id, occurred_at desc);

create or replace function public.audit_trigger()
returns trigger language plpgsql security definer set search_path = public
as $$
begin
  insert into public.audit_logs (user_id, action, table_name, record_id, old_data, new_data)
  values (
    auth.uid(),
    tg_op,
    tg_table_name,
    coalesce(
      case when tg_op = 'DELETE' then (to_jsonb(old)->>'id') else (to_jsonb(new)->>'id') end
    ),
    case when tg_op in ('UPDATE','DELETE') then to_jsonb(old) end,
    case when tg_op in ('INSERT','UPDATE') then to_jsonb(new) end
  );
  return coalesce(new, old);
end $$;

-- Tablas sensibles bajo auditoría completa
do $$
declare t text;
begin
  foreach t in array array[
    'patients','consultations','prescriptions','prescription_items',
    'medical_documents','payments','appointments'
  ] loop
    execute format(
      'create trigger trg_audit_%1$s after insert or update or delete on public.%1$s
       for each row execute function public.audit_trigger()', t);
  end loop;
end $$;

-- Auditoría de lectura de historia clínica (llamar desde la app al abrir ficha)
create or replace function public.log_clinical_access(p_patient uuid)
returns void language sql security definer set search_path = public
as $$
  insert into public.audit_logs (user_id, action, table_name, record_id)
  values (auth.uid(), 'READ_CLINICAL', 'patients', p_patient::text);
$$;

-- ------------------------------------------------------------
-- 11. updated_at automático
-- ------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger language plpgsql
as $$ begin new.updated_at = now(); return new; end $$;

do $$
declare t text;
begin
  foreach t in array array[
    'profiles','patients','appointments','consultations',
    'drug_catalog','payments'
  ] loop
    execute format(
      'create trigger trg_updated_%1$s before update on public.%1$s
       for each row execute function public.set_updated_at()', t);
  end loop;
end $$;

-- ------------------------------------------------------------
-- 12. RLS — MATRIZ DE PERMISOS
-- ------------------------------------------------------------
-- medico:    todo clínico. Caja solo lectura.
-- recepcion: agenda, datos básicos paciente, caja. SIN contenido clínico.
-- admin:     configuración, caja, auditoría. Historia clínica NO editable.
-- tecnico:   nada vía API de datos (acceso solo infraestructura).

alter table public.profiles           enable row level security;
alter table public.patients           enable row level security;
alter table public.services           enable row level security;
alter table public.appointments       enable row level security;
alter table public.consultations      enable row level security;
alter table public.drug_catalog       enable row level security;
alter table public.commercial_brands  enable row level security;
alter table public.prescriptions      enable row level security;
alter table public.prescription_items enable row level security;
alter table public.document_templates enable row level security;
alter table public.medical_documents  enable row level security;
alter table public.payments           enable row level security;
alter table public.audit_logs         enable row level security;

-- PROFILES
create policy profiles_self_read on public.profiles
  for select using (id = auth.uid() or public.current_role() = 'admin');
create policy profiles_admin_write on public.profiles
  for all using (public.current_role() = 'admin');

-- PATIENTS: médico y recepción crean/editan; recepción NO ve columnas clínicas
-- (restricción de columnas se aplica en la vista patients_basic, ver abajo)
create policy patients_clinical_full on public.patients
  for all using (public.current_role() in ('medico','recepcion'))
  with check (public.current_role() in ('medico','recepcion'));
create policy patients_admin_read on public.patients
  for select using (public.current_role() = 'admin');

-- Vista para recepción SIN datos clínicos (usar en frontend cuando rol = recepcion)
create or replace view public.patients_basic
with (security_invoker = true) as
  select id, identification_type, identification_number, first_name, last_name,
         birth_date, public.patient_age(birth_date) as age, sex, phone, whatsapp,
         email, address, sector, emergency_contact_name, emergency_contact_phone,
         data_consent_signed, data_consent_date, created_at
  from public.patients;

-- SERVICES
create policy services_read on public.services
  for select using (public.current_role() in ('medico','recepcion','admin'));
create policy services_admin_write on public.services
  for all using (public.current_role() = 'admin');

-- APPOINTMENTS
create policy appointments_rw on public.appointments
  for all using (public.current_role() in ('medico','recepcion','admin'))
  with check (public.current_role() in ('medico','recepcion','admin'));

-- CONSULTATIONS: solo médico
create policy consultations_medico on public.consultations
  for all using (public.current_role() = 'medico')
  with check (public.current_role() = 'medico');

-- VADEMÉCUM: médico edita, admin edita, recepción no ve
create policy drug_catalog_rw on public.drug_catalog
  for all using (public.current_role() in ('medico','admin'));
create policy brands_rw on public.commercial_brands
  for all using (public.current_role() in ('medico','admin'));

-- PRESCRIPTIONS: solo médico crea/lee; admin solo metadatos vía audit_logs
create policy prescriptions_medico on public.prescriptions
  for all using (public.current_role() = 'medico')
  with check (public.current_role() = 'medico');
create policy prescription_items_medico on public.prescription_items
  for all using (public.current_role() = 'medico')
  with check (public.current_role() = 'medico');

-- DOCUMENTS
create policy templates_read on public.document_templates
  for select using (public.current_role() in ('medico','admin'));
create policy templates_admin_write on public.document_templates
  for all using (public.current_role() = 'admin');
create policy documents_medico on public.medical_documents
  for all using (public.current_role() = 'medico')
  with check (public.current_role() = 'medico');

-- PAYMENTS: recepción y admin editan, médico lee
create policy payments_write on public.payments
  for all using (public.current_role() in ('recepcion','admin'))
  with check (public.current_role() in ('recepcion','admin'));
create policy payments_medico_read on public.payments
  for select using (public.current_role() = 'medico');

-- AUDIT: solo admin lee. Nadie escribe directo (solo trigger SECURITY DEFINER).
create policy audit_admin_read on public.audit_logs
  for select using (public.current_role() = 'admin');

-- ------------------------------------------------------------
-- 13. SEED — Vademécum inicial y servicios
-- ------------------------------------------------------------
insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_dose, usual_frequency, usual_duration)
values
  ('Losartán',      'Antihipertensivo ARA-II', 'Tableta',   '50 mg',        'Oral',       '1 tableta', 'Cada 24 horas', '30 días'),
  ('Paracetamol',   'Analgésico/Antipirético', 'Tableta',   '500 mg',       'Oral',       '1 tableta', 'Cada 8 horas',  '5 días'),
  ('Ibuprofeno',    'AINE',                    'Tableta',   '400 mg',       'Oral',       '1 tableta', 'Cada 8 horas',  '5 días'),
  ('Omeprazol',     'Inhibidor bomba protones','Cápsula',   '20 mg',        'Oral',       '1 cápsula', 'Cada 24 horas', '14 días'),
  ('Loratadina',    'Antihistamínico',         'Tableta',   '10 mg',        'Oral',       '1 tableta', 'Cada 24 horas', '7 días'),
  ('Metformina',    'Hipoglucemiante',         'Tableta',   '850 mg',       'Oral',       '1 tableta', 'Cada 12 horas', '30 días'),
  ('Atorvastatina', 'Hipolipemiante',          'Tableta',   '20 mg',        'Oral',       '1 tableta', 'Cada 24 horas (noche)', '30 días'),
  ('Salbutamol',    'Broncodilatador',         'Inhalador', '100 mcg/dosis','Inhalatoria','2 puffs',   'Cada 6-8 horas PRN', 'Según evolución');

insert into public.commercial_brands (drug_catalog_id, brand_name, is_preferred)
select id, b.brand, b.pref from public.drug_catalog d
join (values
  ('Losartán','Cozaar',true), ('Losartán','Losacor',false),
  ('Paracetamol','Tempra',true), ('Paracetamol','Panadol',false),
  ('Ibuprofeno','Advil',true), ('Ibuprofeno','Motrin',false),
  ('Omeprazol','Losec',true), ('Omeprazol','Ulceral',false),
  ('Loratadina','Clarityne',true),
  ('Metformina','Glucophage',true),
  ('Atorvastatina','Lipitor',true),
  ('Salbutamol','Ventolin',true)
) as b(generic, brand, pref) on d.generic_name = b.generic;

insert into public.services (name, price, duration_min) values
  ('Consulta general', 25.00, 30),
  ('Consulta de control', 20.00, 20),
  ('Certificado médico', 10.00, 15);

-- ------------------------------------------------------------
-- 14. NOTAS DE IMPLEMENTACIÓN (no ejecutables)
-- ------------------------------------------------------------
-- 1. Crear usuarios en Supabase Auth y luego insertar en profiles con su rol.
--    Activar MFA (TOTP) para medico y admin desde el dashboard de Auth.
-- 2. Adjuntos clínicos (v0.2): usar Supabase Storage con bucket privado
--    'clinical-files', políticas por rol y signed URLs de 15 min.
-- 3. Llamar public.log_clinical_access(patient_id) desde el frontend
--    cada vez que se abra una historia clínica (auditoría de lectura).
-- 4. Backups: activar PITR en Supabase (plan Pro) o pg_dump diario
--    cifrado a R2/S3 con retención 7 diarios / 4 semanales / 6 mensuales.
-- 5. NUNCA usar service_role key en el frontend. Solo anon key + RLS.
-- 6. Frontend recepción: consumir patients_basic, no patients.
