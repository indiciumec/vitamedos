// scripts/load-cie10.mjs
// Carga el catálogo CIE-10 (español) en la tabla public.cie10 (crear antes con 007_cie10.sql).
// Fuente del CSV: https://github.com/verasativa/CIE-10 (cie-10.csv, UTF-8).
//
// Uso:
//   node scripts/load-cie10.mjs --input <cie10.csv>            (DRY-RUN)
//   node scripts/load-cie10.mjs --input <cie10.csv> --commit   (carga; idempotente por code)
//
// Env (para --commit), una de dos vías:
//   A) NEXT_PUBLIC_SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY
//   B) NEXT_PUBLIC_SUPABASE_URL + NEXT_PUBLIC_SUPABASE_ANON_KEY + VITAMED_EMAIL + VITAMED_PASSWORD (rol medico)
import { readFileSync } from 'node:fs';

const args = process.argv.slice(2);
const input = args[args.indexOf('--input') + 1];
const COMMIT = args.includes('--commit');
if (!input) { console.error('Falta --input <cie10.csv>'); process.exit(1); }

// CSV robusto (comillas dobles, comas dentro de comillas)
function parseLine(line) {
  const out = []; let cur = '', q = false;
  for (let i = 0; i < line.length; i++) {
    const c = line[i];
    if (q) {
      if (c === '"' && line[i + 1] === '"') { cur += '"'; i++; }
      else if (c === '"') q = false;
      else cur += c;
    } else if (c === '"') q = true;
    else if (c === ',') { out.push(cur); cur = ''; }
    else cur += c;
  }
  out.push(cur);
  return out;
}

// Códigos reales (categorías y subcategorías); excluye rangos de capítulo/bloque (con guion).
// Los subcódigos vienen sin punto (G130) → se formatean a G13.0.
const CODE = /^[A-Z]\d{2}\d*$/;
const fmt = (c) => (c.length > 3 ? `${c.slice(0, 3)}.${c.slice(3)}` : c);
const rows = readFileSync(input, 'utf8').split(/\r?\n/);
const header = parseLine(rows[0]);
const iCode = header.indexOf('code');
const iDesc = header.indexOf('description');

const seen = new Set();
const records = [];
for (let r = 1; r < rows.length; r++) {
  if (!rows[r].trim()) continue;
  const f = parseLine(rows[r]);
  const raw = (f[iCode] || '').trim();
  const desc = (f[iDesc] || '').trim();
  if (!CODE.test(raw) || !desc) continue;
  const code = fmt(raw);
  if (seen.has(code)) continue;
  seen.add(code);
  records.push({ code, description: desc });
}

console.log('─'.repeat(46));
console.log(`Origen:  ${input}`);
console.log(`Códigos CIE-10 válidos: ${records.length}`);
console.log('Muestra:');
for (const r of records.slice(0, 4)) console.log(`  ${r.code}  ${r.description}`);
console.log('─'.repeat(46));

if (!COMMIT) { console.log('DRY-RUN — no se escribió nada. Añade --commit para cargar.'); process.exit(0); }

const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
if (!url) { console.error('FALTA NEXT_PUBLIC_SUPABASE_URL'); process.exit(1); }
const { createClient } = await import('@supabase/supabase-js');
let supabase;
if (serviceKey) supabase = createClient(url, serviceKey, { auth: { persistSession: false } });
else if (anonKey && process.env.VITAMED_EMAIL) {
  supabase = createClient(url, anonKey, { auth: { persistSession: false } });
  const { error } = await supabase.auth.signInWithPassword({ email: process.env.VITAMED_EMAIL, password: process.env.VITAMED_PASSWORD });
  if (error) { console.error('Login falló:', error.message); process.exit(1); }
} else { console.error('Faltan credenciales (service_role o email/password)'); process.exit(1); }

let ok = 0;
for (let i = 0; i < records.length; i += 500) {
  const batch = records.slice(i, i + 500);
  const { error } = await supabase.from('cie10').upsert(batch, { onConflict: 'code', ignoreDuplicates: true });
  if (error) { console.error(`\nLote ${i}: ${error.message}`); }
  else { ok += batch.length; process.stdout.write(`\rCargados: ${ok}/${records.length}`); }
}
console.log(`\nListo. Códigos cargados: ${ok}`);
