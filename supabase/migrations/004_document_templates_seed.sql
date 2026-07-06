-- ============================================================
-- 004_document_templates_seed.sql — Plantillas iniciales de documentos
-- Idempotente (guardado por nombre). Requiere correr en SQL Editor:
-- la RLS de document_templates solo permite escritura al rol admin.
-- Placeholders: {{paciente}} {{cedula}} {{edad}} {{fecha}} {{diagnostico}} {{dias_reposo}} {{medico}}
-- ============================================================

insert into public.document_templates (doc_type, name, body_template, is_active)
select v.doc_type::document_type, v.name, v.body, true
from (values
  ('certificado_medico', 'Certificado médico general',
'CERTIFICADO MÉDICO

Quien suscribe, {{medico}}, certifica que el/la paciente {{paciente}}, portador/a de la cédula de identidad N.º {{cedula}}, de {{edad}} años de edad, fue atendido/a en este consultorio el día {{fecha}}.

Diagnóstico: {{diagnostico}}

Se extiende el presente certificado a petición del/de la interesado/a, para los fines que estime convenientes.

{{fecha}}'),

  ('reposo_medico', 'Reposo médico',
'CERTIFICADO DE REPOSO MÉDICO

Quien suscribe, {{medico}}, certifica que el/la paciente {{paciente}}, con cédula de identidad N.º {{cedula}}, de {{edad}} años de edad, fue atendido/a en este consultorio el día {{fecha}}.

Diagnóstico: {{diagnostico}}

Por su condición de salud, se prescribe REPOSO MÉDICO por {{dias_reposo}} día(s) a partir de la presente fecha, período durante el cual no deberá realizar sus actividades habituales.

{{fecha}}'),

  ('constancia_asistencia', 'Constancia de asistencia',
'CONSTANCIA DE ASISTENCIA

Quien suscribe, {{medico}}, deja constancia de que el/la paciente {{paciente}}, con cédula de identidad N.º {{cedula}}, asistió a consulta médica en este consultorio el día {{fecha}}.

Se extiende la presente constancia a petición del/de la interesado/a para justificar su asistencia.

{{fecha}}'),

  ('solicitud_examenes', 'Solicitud de exámenes',
'SOLICITUD DE EXÁMENES

Paciente: {{paciente}}
Cédula: {{cedula}}
Edad: {{edad}} años
Fecha: {{fecha}}

Diagnóstico presuntivo: {{diagnostico}}

Se solicita comedidamente realizar los siguientes exámenes:

-
-
-

Atentamente,
{{medico}}'),

  ('referencia_especialista', 'Referencia a especialista',
'REFERENCIA MÉDICA

Paciente: {{paciente}}
Cédula: {{cedula}}
Edad: {{edad}} años
Fecha: {{fecha}}

Estimado/a colega:

Refiero al/a la paciente arriba indicado/a, con diagnóstico de {{diagnostico}}, para valoración y manejo por su especialidad.

Resumen clínico y tratamiento actual:


Agradezco su gentil atención.

{{medico}}'),

  ('consentimiento_datos', 'Consentimiento de datos personales (LOPDP)',
'CONSENTIMIENTO PARA TRATAMIENTO DE DATOS PERSONALES

Yo, {{paciente}}, con cédula de identidad N.º {{cedula}}, en cumplimiento de la Ley Orgánica de Protección de Datos Personales del Ecuador, autorizo de manera libre, expresa e informada al consultorio y a {{medico}} para recolectar, almacenar y tratar mis datos personales y datos de salud, con la finalidad exclusiva de gestionar mi atención médica, historial clínico, agenda de citas y comunicaciones relacionadas con mi tratamiento.

Declaro conocer mis derechos de acceso, rectificación, eliminación, oposición y portabilidad de mis datos, que podré ejercer en cualquier momento.

Fecha: {{fecha}}


_______________________
Firma del/de la paciente
C.I. {{cedula}}')
) as v(doc_type, name, body)
where not exists (
  select 1 from public.document_templates t where t.name = v.name
);
