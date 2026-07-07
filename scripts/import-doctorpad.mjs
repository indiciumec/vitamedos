// scripts/import-doctorpad.mjs
// Importa pacientes de DoctorPad (extraídos de los PDF de reportes → JSON limpio)
// hacia Supabase. ÚNICO lugar autorizado a usar la SERVICE_ROLE key, leída de env.
//
// Uso:
//   node scripts/import-doctorpad.mjs --input <patients.json>              (DRY-RUN: no escribe)
//   node scripts/import-doctorpad.mjs --input <patients.json> --commit     (escribe de verdad)
//
// Requiere en el entorno (solo para --commit):
//   NEXT_PUBLIC_SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
//
// Idempotente: ancla en identification_number (on conflict do nothing).
import { readFileSync } from 'node:fs';

const args = process.argv.slice(2);
const inputPath = args[args.indexOf('--input') + 1];
const COMMIT = args.includes('--commit');
if (!inputPath) { console.error('Falta --input <patients.json>'); process.exit(1); }

// --- Validador de cédula ecuatoriana (módulo 10) ---
function validCedulaEC(c) {
  if (!/^\d{10}$/.test(c)) return false;
  const prov = parseInt(c.slice(0, 2), 10);
  if (prov < 1 || (prov > 24 && prov !== 30)) return false;
  const d = c.split('').map(Number);
  const ver = d.pop();
  const sum = d.reduce((a, n, i) => { let v = i % 2 === 0 ? n * 2 : n; if (v > 9) v -= 9; return a + v; }, 0);
  return (10 - (sum % 10)) % 10 === ver;
}

// DD/MM/YYYY → YYYY-MM-DD (o null)
function toISODate(s) {
  const m = /^(\d{1,2})\/(\d{1,2})\/(\d{4})$/.exec((s || '').trim());
  if (!m) return null;
  const [, d, mo, y] = m;
  const yr = parseInt(y, 10);
  if (yr < 1900 || yr > 2026) return null;
  return `${y}-${mo.padStart(2, '0')}-${d.padStart(2, '0')}`;
}

const raw = JSON.parse(readFileSync(inputPath, 'utf-8'));

const seen = new Set();
const records = [];
const warnings = { sinCedula: 0, cedulaInvalida: 0, sinFecha: 0, duplicados: 0 };
let sinCedulaSeq = 0;

for (const r of raw) {
  const nombres = (r.nombres || '').trim();
  const apellidos = (r.apellidos || '').trim();
  if (!nombres && !apellidos) continue;

  let ced = (r.cedula || '').replace(/[^\dKk]/g, '');
  let idType, idNum;
  if (ced && validCedulaEC(ced)) {
    idType = 'cedula'; idNum = ced;
  } else if (ced) {
    idType = 'pasaporte'; idNum = ced; warnings.cedulaInvalida++;   // pasaporte evita el CHECK módulo-10
  } else {
    idType = 'pasaporte'; idNum = `SINCED-${String(++sinCedulaSeq).padStart(4, '0')}`; warnings.sinCedula++;
  }

  if (seen.has(idNum)) { warnings.duplicados++; continue; }
  seen.add(idNum);

  const fnac = toISODate(r.fnac);
  if (!fnac) warnings.sinFecha++;
  const genero = (r.genero || '').trim().toUpperCase();
  const email = (r.email || '').trim();
  const tel = (r.telefono || '').replace(/\D/g, '');

  records.push({
    identification_type: idType,
    identification_number: idNum,
    first_name: nombres || '(sin nombre)',
    last_name: apellidos || '(sin apellido)',
    birth_date: fnac,
    sex: genero === 'M' || genero === 'F' ? genero : null,
    phone: tel || null,
    whatsapp: tel || null,
    email: /.+@.+\..+/.test(email) ? email : null,
    data_consent_signed: false,   // re-consentimiento LOPDP lo confirma la doctora
    notes: idNum.startsWith('SINCED-') ? 'Importado de DoctorPad — completar identificación' : 'Importado de DoctorPad',
  });
}

console.log('─'.repeat(48));
console.log(`Origen:            ${inputPath}`);
console.log(`Pacientes válidos: ${records.length}`);
console.log(`  · con cédula EC válida:  ${records.filter(r => r.identification_type === 'cedula').length}`);
console.log(`  · como pasaporte/otro:   ${records.filter(r => r.identification_type === 'pasaporte').length}`);
console.log(`Avisos:`);
console.log(`  · sin cédula (placeholder SINCED-*): ${warnings.sinCedula}`);
console.log(`  · cédula inválida → pasaporte:       ${warnings.cedulaInvalida}`);
console.log(`  · sin fecha de nacimiento:           ${warnings.sinFecha}`);
console.log(`  · duplicados omitidos:               ${warnings.duplicados}`);
console.log('─'.repeat(48));
console.log('Muestra (primeros 3):');
for (const r of records.slice(0, 3)) console.log('  ', JSON.stringify(r));
console.log('─'.repeat(48));

if (!COMMIT) {
  console.log('DRY-RUN — no se escribió nada. Añade --commit para importar de verdad.');
  process.exit(0);
}

// --- Escritura real (idempotente) ---
const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
if (!url || !serviceKey) {
  console.error('FALTAN env: NEXT_PUBLIC_SUPABASE_URL y/o SUPABASE_SERVICE_ROLE_KEY');
  process.exit(1);
}
const { createClient } = await import('@supabase/supabase-js');
const supabase = createClient(url, serviceKey, { auth: { persistSession: false } });

let ok = 0, err = 0;
for (let i = 0; i < records.length; i += 100) {
  const batch = records.slice(i, i + 100);
  const { error } = await supabase
    .from('patients')
    .upsert(batch, { onConflict: 'identification_number', ignoreDuplicates: true });
  if (error) { console.error(`Lote ${i}-${i + batch.length}: ${error.message}`); err += batch.length; }
  else { ok += batch.length; process.stdout.write(`\rImportados: ${ok}/${records.length}`); }
}
console.log(`\nListo. Insertados/ya existentes: ${ok} · errores: ${err}`);
