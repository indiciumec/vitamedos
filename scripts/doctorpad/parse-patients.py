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
    """Los apellidos largos (dos apellidos) se parten en 2 líneas alrededor de la
    fila principal. Por eso NO se agrupa por 'top' exacto: se toma cada fila con
    número (No.) como ancla y se asigna cada palabra a su ancla vertical más cercana."""
    recs = []
    with pdfplumber.open(pdf_path) as pdf:
        for pg in pdf.pages:
            words = [(w['top'], w['x0'], w['text']) for w in pg.extract_words(keep_blank_chars=False)]
            anchors = sorted(t for t, x, txt in words if x < 65 and re.fullmatch(r'\d+', txt))
            if not anchors:
                continue
            buckets = {a: [] for a in anchors}
            for t, x, txt in words:
                if x < 65 and re.fullmatch(r'\d+', txt):   # el propio número de fila
                    continue
                a = min(anchors, key=lambda A: abs(A - t))  # ancla (paciente) más cercana
                buckets[a].append((t, x, txt))
            for a in anchors:
                cells = {}
                for t, x, txt in sorted(buckets[a], key=lambda z: (col_of(z[1]), z[0], z[1])):
                    cells.setdefault(col_of(x), []).append(txt)
                nombres = ' '.join(cells.get('nombres', [])).strip()
                apellidos = ' '.join(cells.get('apellidos', [])).strip()
                if not nombres and not apellidos:
                    continue
                blob = ' '.join(cells.get('genero', []) + cells.get('email', []) + cells.get('cedula', []))
                m = re.search(r'[\w.\-]+@[\w.\-]+', blob)
                g = ' '.join(cells.get('genero', [])).strip().split()
                recs.append({
                    'nombres': nombres,
                    'apellidos': apellidos,
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
