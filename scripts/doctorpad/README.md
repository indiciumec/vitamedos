# Importación de datos de DoctorPad

Pipeline para migrar datos de DoctorPad hacia Vitamed. Los archivos de datos
(PDF, .bak, JSON/CSV intermedios) contienen datos reales de pacientes (LOPDP) y
están excluidos del repo por `.gitignore`. Aquí vive solo la **lógica**.

## Contexto
El backup nativo de DoctorPad es un `.bak` (SQL Server) **cifrado con AES**; sin la
contraseña del proveedor solo se restaura dentro de su plataforma (lock-in). Vía
alterna usada: exportar reportes **PDF** desde la interfaz y parsearlos.

## Estado
- **Pacientes** ✅ importados del "REPORTE PACIENTES" (574 pacientes, en producción).
- **Historia clínica** ✅ best-effort importado: 752 consultas de los 3 reportes
  (Consultas + Motivos + Diagnósticos), unidas por nombre+fecha, 97% vinculadas a
  paciente, 453 pacientes con historia. Cada consulta se creó CERRADA, fechada con su
  fecha original, con marca `[Importado de DoctorPad]` al final de `current_illness`.
  16 consultas sin match de paciente (nombres no encontrados) quedaron fuera.
  Nota: `consultations` no tiene columna `notes`; el marcador va en `current_illness`.

## Uso
```bash
pip install pdfplumber

# 1) PDF de DoctorPad → JSON limpio (fuera del repo)
python scripts/doctorpad/parse-patients.py "reportes doctor pad/Pacientes-*.pdf" ./patients_clean.json

# 2) Vista previa (NO escribe nada)
node scripts/import-doctorpad.mjs --input ./patients_clean.json

# 3) Import real de pacientes (idempotente). Vía service_role, o vía sesión de médico:
#    NEXT_PUBLIC_SUPABASE_URL + NEXT_PUBLIC_SUPABASE_ANON_KEY + VITAMED_EMAIL + VITAMED_PASSWORD
node scripts/import-doctorpad.mjs --input ./patients_clean.json --commit

# 4) Import de historia clínica (best-effort, une los 3 reportes por nombre+fecha)
python scripts/doctorpad/import-history.py --dir "reportes doctor pad"            # vista previa
python scripts/doctorpad/import-history.py --dir "reportes doctor pad" --commit   # escribe
```

## Mapeo de pacientes
| DoctorPad | Vitamed | Regla |
|---|---|---|
| Cédula | identification_number / _type | 10 dígitos válidos (módulo 10) → `cedula`; resto → `pasaporte` |
| (sin cédula) | identification_number | placeholder `SINCED-0001…` + nota "completar identificación" |
| Nombres / Apellidos | first_name / last_name | |
| F. Nacimiento | birth_date | DD/MM/YYYY → YYYY-MM-DD |
| Género | sex | M/F |
| Teléfono | phone + whatsapp | |
| Email | email | solo si es válido |
| — | data_consent_signed | `false` (re-consentimiento LOPDP lo confirma la doctora) |
