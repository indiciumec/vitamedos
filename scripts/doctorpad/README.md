# Importación de datos de DoctorPad

Pipeline para migrar datos de DoctorPad hacia Vitamed. Los archivos de datos
(PDF, .bak, JSON/CSV intermedios) contienen datos reales de pacientes (LOPDP) y
están excluidos del repo por `.gitignore`. Aquí vive solo la **lógica**.

## Contexto
El backup nativo de DoctorPad es un `.bak` (SQL Server) **cifrado con AES**; sin la
contraseña del proveedor solo se restaura dentro de su plataforma (lock-in). Vía
alterna usada: exportar reportes **PDF** desde la interfaz y parsearlos.

## Estado
- **Pacientes** ✅ recuperados del "REPORTE PACIENTES" (574 pacientes).
- **Historia clínica** ⏳ fragmentada en 3 reportes (Consultas, Diagnósticos, Motivos),
  vinculada solo por nombre+fecha → importación best-effort pendiente. Ideal: obtener
  el `.bak` descifrado vía solicitud de portabilidad LOPDP para una historia limpia.

## Uso
```bash
pip install pdfplumber

# 1) PDF de DoctorPad → JSON limpio (fuera del repo)
python scripts/doctorpad/parse-patients.py "reportes doctor pad/Pacientes-*.pdf" ./patients_clean.json

# 2) Vista previa (NO escribe nada)
node scripts/import-doctorpad.mjs --input ./patients_clean.json

# 3) Import real (idempotente por cédula). Requiere en el entorno:
#    NEXT_PUBLIC_SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY (solo aquí se usa la service key)
node scripts/import-doctorpad.mjs --input ./patients_clean.json --commit
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
