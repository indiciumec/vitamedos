#!/usr/bin/env python3
"""
Importa la HISTORIA CLÍNICA de DoctorPad (best-effort) uniendo 3 reportes PDF:
  - rptConsultas  → narrativa / enfermedad actual  (contenido principal)
  - rptMotivCons  → motivo de consulta
  - rptDiagCons   → diagnóstico
Se unen por (paciente, fecha) y se vinculan al paciente por conjunto de nombres.
Cada consulta se crea como CERRADA y fechada con su fecha original, marcada
"Importado de DoctorPad". Idempotente: no reimporta (paciente, fecha, marca) ya existentes.

Uso:
  python scripts/doctorpad/import-history.py --dir "reportes doctor pad"            (DRY-RUN)
  python scripts/doctorpad/import-history.py --dir "reportes doctor pad" --commit   (escribe)

Requiere env (para --commit):  NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY,
                               VITAMED_EMAIL, VITAMED_PASSWORD  (usuario con rol medico)
Requiere:  pip install pdfplumber
"""
import sys, os, re, json, glob, unicodedata
import urllib.request as U
import pdfplumber

DATE = re.compile(r'(\d{2}/\d{2}/\d{4})')
HEADER = {'VITAMED','REPORTE','DE','CONSULTAS','DIAGNOSTICOS','MOTIVOS','POR','FECHA','DESDE','HASTA',
          'PACIENTE','SEGURO','MOTIVO','TIPO','CONSULTA','CONSULTORIO','IMPR','PM','AM','MEDICO','TOTAL'}

def norm(s):
    s = unicodedata.normalize('NFD', s)
    s = ''.join(c for c in s if unicodedata.category(c) != 'Mn')
    s = re.sub(r'[^A-Za-z0-9 ]', ' ', s).upper()
    return frozenset(t for t in s.split() if len(t) > 1 and t not in HEADER)

def iso(d):
    m = re.match(r'(\d{2})/(\d{2})/(\d{4})', d)
    if not m: return None
    dd, mm, yy = m.groups()
    if not (1900 <= int(yy) <= 2026): return None
    return f'{yy}-{mm}-{dd}'

def find(dirpath, prefix):
    g = glob.glob(os.path.join(dirpath, prefix + '*.pdf'))
    return g[0] if g else None

def parse_anchored(pdf_path, name_xmax=100, narr_xmin=205):
    """Reportes con fecha a la izquierda, nombre partido en 2 líneas, texto a la derecha."""
    out = []
    with pdfplumber.open(pdf_path) as pdf:
        for pg in pdf.pages:
            ws = [(w['top'], w['x0'], w['text']) for w in pg.extract_words(keep_blank_chars=False)]
            hdr = [t for t, x, txt in ws if txt in ('Motivo', 'Paciente') and x > 150]
            data_top = (max(hdr) + 3) if hdr else 0
            med = {round(t) for t, x, txt in ws if txt.startswith('M') and 'DICO' in txt.upper() and x < 60}
            ws = [(t, x, txt) for t, x, txt in ws if t > data_top and round(t) not in med]
            anchors = sorted(t for t, x, txt in ws if 100 <= x < narr_xmin and DATE.match(txt))
            if not anchors: continue
            buckets = {a: [] for a in anchors}
            for t, x, txt in ws:
                a = min(anchors, key=lambda A: abs(A - t)); buckets[a].append((t, x, txt))
            for a in anchors:
                name, text, date = [], [], None
                for t, x, txt in buckets[a]:
                    if 100 <= x < narr_xmin and DATE.match(txt):
                        date = date or DATE.match(txt).group(1)
                    elif x < name_xmax: name.append((t, x, txt))
                    elif x >= narr_xmin: text.append((t, x, txt))
                nm = ' '.join(w for _, _, w in sorted(name, key=lambda z: (z[0], z[1])))
                tx = ' '.join(w for _, _, w in sorted(text, key=lambda z: (z[0], z[1])))
                if date and nm.strip():
                    out.append((nm.strip(), iso(date), tx.strip()))
    return out

def api(method, path, tok, body=None):
    url = os.environ['NEXT_PUBLIC_SUPABASE_URL'] + '/rest/v1/' + path
    data = json.dumps(body).encode() if body is not None else None
    h = {'apikey': os.environ['NEXT_PUBLIC_SUPABASE_ANON_KEY'], 'Authorization': 'Bearer ' + tok,
         'Content-Type': 'application/json', 'Prefer': 'return=minimal'}
    r = U.Request(url, data=data, headers=h, method=method)
    return U.urlopen(r)

def main():
    d = sys.argv[sys.argv.index('--dir') + 1] if '--dir' in sys.argv else 'reportes doctor pad'
    commit = '--commit' in sys.argv
    cons = parse_anchored(find(d, 'rptConsultas'))
    motiv = parse_anchored(find(d, 'rptMotivCons'))
    mot_by = {(norm(n), f): t for n, f, t in motiv if f}
    # diagnósticos: rptDiagCons agrupa por diagnóstico; parse simple por líneas
    diag_by = {}
    with pdfplumber.open(find(d, 'rptDiagCons')) as pdf:
        cur = None
        for pg in pdf.pages:
            for line in (pg.extract_text() or '').split('\n'):
                s = line.strip()
                if not s or s.startswith('Total de ') or s.startswith('VITAMED') or s.startswith('REPORTE') or s.startswith('Fecha '):
                    continue
                m = DATE.match(s)
                if m and cur:
                    nm = s[m.end():].strip()
                    diag_by.setdefault((norm(nm), iso(m.group(1))), cur)
                elif not m:
                    cur = s  # encabezado de diagnóstico

    # índice de pacientes
    if not os.environ.get('VITAMED_EMAIL'):
        print('Faltan credenciales en env (VITAMED_EMAIL/PASSWORD, SUPABASE URL/ANON).'); sys.exit(1)
    au = json.load(U.urlopen(U.Request(
        os.environ['NEXT_PUBLIC_SUPABASE_URL'] + '/auth/v1/token?grant_type=password',
        data=json.dumps({'email': os.environ['VITAMED_EMAIL'], 'password': os.environ['VITAMED_PASSWORD']}).encode(),
        headers={'apikey': os.environ['NEXT_PUBLIC_SUPABASE_ANON_KEY'], 'Content-Type': 'application/json'})))
    tok, doctor_id = au['access_token'], au['user']['id']
    pts = json.load(U.urlopen(U.Request(
        os.environ['NEXT_PUBLIC_SUPABASE_URL'] + '/rest/v1/patients_basic?select=id,first_name,last_name&limit=3000',
        headers={'apikey': os.environ['NEXT_PUBLIC_SUPABASE_ANON_KEY'], 'Authorization': 'Bearer ' + tok})))
    idx = {}
    for p in pts:
        idx.setdefault(norm(p['first_name'] + ' ' + p['last_name']), p['id'])

    # existentes (idempotencia): consultas ya importadas → (patient_id, fecha)
    existing = set()
    try:
        ex = json.load(U.urlopen(U.Request(
            os.environ['NEXT_PUBLIC_SUPABASE_URL'] + '/rest/v1/consultations?select=patient_id,created_at,current_illness&limit=10000',
            headers={'apikey': os.environ['NEXT_PUBLIC_SUPABASE_ANON_KEY'], 'Authorization': 'Bearer ' + tok})))
        for e in ex:
            if 'DoctorPad' in (e.get('current_illness') or ''):
                existing.add((e['patient_id'], (e['created_at'] or '')[:10]))
    except Exception as e:
        print('(aviso: no se pudo consultar existentes, sin dedup:', str(e)[:80], ')')

    records, no_match, skipped = [], 0, 0
    for nm, fecha, narrativa in cons:
        if not fecha: continue
        pid = idx.get(norm(nm))
        if not pid: no_match += 1; continue
        if (pid, fecha) in existing: skipped += 1; continue
        motivo = mot_by.get((norm(nm), fecha), '')
        diag = diag_by.get((norm(nm), fecha), '')
        reason = (motivo or narrativa or 'Consulta')[:490] or 'Consulta'
        # La tabla consultations no tiene columna 'notes'; el marcador va al final
        # de current_illness (traza el origen y sirve de ancla de idempotencia).
        illness = ((narrativa + '\n\n') if narrativa else '') + '[Importado de DoctorPad]'
        records.append({
            'patient_id': pid, 'doctor_id': doctor_id,
            'reason': reason,
            'current_illness': illness,
            'diagnosis_text': (diag or None),
            'vital_signs': {}, 'status': 'cerrada',
            'created_at': f'{fecha}T12:00:00-05:00', 'closed_at': f'{fecha}T12:00:00-05:00',
        })

    print('─' * 52)
    print(f'Consultas en PDF:      {len(cons)}')
    print(f'  · vinculadas:        {len(cons) - no_match}')
    print(f'  · sin match paciente:{no_match}')
    print(f'  · ya importadas:     {skipped}')
    print(f'Con motivo:            {sum(1 for r in records if r["reason"])}')
    print(f'Con diagnóstico:       {sum(1 for r in records if r["diagnosis_text"])}')
    print(f'A insertar:            {len(records)}')
    print('─' * 52)
    for r in records[:3]:
        print(f"  [{r['created_at'][:10]}] reason={r['reason'][:45]!r} dx={str(r['diagnosis_text'])[:30]!r}")
    print('─' * 52)
    if not commit:
        print('DRY-RUN — no se escribió nada. Añade --commit para importar.')
        return
    ok = 0
    for i in range(0, len(records), 100):
        batch = records[i:i + 100]
        try:
            api('POST', 'consultations', tok, batch); ok += len(batch)
            print(f'\rInsertadas: {ok}/{len(records)}', end='')
        except Exception as e:
            print('\nError lote', i, str(e)[:120])
    print(f'\nListo. Consultas insertadas: {ok}')

if __name__ == '__main__':
    main()
