#!/usr/bin/env python3
"""
Extrae el listado de pacientes del PDF "REPORTE PACIENTES" de DoctorPad a JSON limpio.
NO contiene datos: es solo la lógica de parseo. El PDF de entrada y el JSON de salida
son datos reales de pacientes (LOPDP) y NO deben subirse al repo (ver .gitignore).

Uso:  python scripts/doctorpad/parse-patients.py <Pacientes.pdf> <salida.json>
Requiere:  pip install pdfplumber

Columnas del reporte (posiciones x0 derivadas de las cabeceras):
  No. | Nombres | Apellidos | F.Nacimiento | Cédula | Género | Email | Teléfono | Seguro
"""
import sys, json, re
import pdfplumber

BOUNDS = [(0, 65, 'no'), (65, 149, 'nombres'), (149, 231, 'apellidos'), (231, 283, 'fnac'),
          (283, 342, 'cedula'), (342, 400, 'genero'), (400, 486, 'email'), (486, 536, 'tel'), (536, 999, 'seguro')]

def col_of(x0):
    for a, b, name in BOUNDS:
        if a <= x0 < b:
            return name
    return 'x'

def parse(pdf_path):
    recs = []
    with pdfplumber.open(pdf_path) as pdf:
        for pg in pdf.pages:
            rows = {}
            for w in pg.extract_words(keep_blank_chars=False):
                rows.setdefault(round(w['top']), []).append(w)
            for top in sorted(rows):
                cells = {}
                for w in rows[top]:
                    cells.setdefault(col_of(w['x0']), []).append(w['text'])
                no = ' '.join(cells.get('no', [])).strip()
                if not re.fullmatch(r'\d+', no or ''):   # solo filas de paciente
                    continue
                blob = ' '.join(cells.get('genero', []) + cells.get('email', []) + cells.get('cedula', []))
                m = re.search(r'[\w.\-]+@[\w.\-]+', blob)
                g = ' '.join(cells.get('genero', [])).strip().split()
                recs.append({
                    'nombres': ' '.join(cells.get('nombres', [])).strip(),
                    'apellidos': ' '.join(cells.get('apellidos', [])).strip(),
                    'fnac': ' '.join(cells.get('fnac', [])).strip(),
                    'cedula': re.sub(r'[^\dKk]', '', ' '.join(cells.get('cedula', []))),
                    'genero': g[0] if g and g[0] in ('M', 'F') else '',
                    'email': m.group(0) if m else '',
                    'telefono': re.sub(r'\D', '', ' '.join(cells.get('tel', []))),
                })
    return recs

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(1)
    out = parse(sys.argv[1])
    json.dump(out, open(sys.argv[2], 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    print(f'{len(out)} pacientes -> {sys.argv[2]}')
