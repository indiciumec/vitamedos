'use client';

import { useRef, useState } from 'react';
import { searchCie10Action } from '@/lib/actions';
import type { Cie10 } from '@/lib/queries/cie10';

const inputCls =
  'w-full rounded-md border border-vitamed-200 px-3 py-2 text-sm focus:border-vitamed-500 focus:outline-none focus:ring-1 focus:ring-vitamed-500';

/** Buscador CIE-10: al elegir, entrega { code, description } para llenar el diagnóstico. */
export default function Cie10Search({
  onPick, disabled,
}: { onPick: (c: Cie10) => void; disabled?: boolean }) {
  const [term, setTerm] = useState('');
  const [results, setResults] = useState<Cie10[]>([]);
  const [open, setOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const timer = useRef<ReturnType<typeof setTimeout> | undefined>(undefined);

  function onChange(v: string) {
    setTerm(v);
    clearTimeout(timer.current);
    if (v.trim().length < 2) { setResults([]); setOpen(false); return; }
    timer.current = setTimeout(async () => {
      setLoading(true);
      const res = await searchCie10Action(v);
      setLoading(false);
      if (res.ok) { setResults(res.data); setOpen(true); }
    }, 250);
  }

  return (
    <div className="relative">
      <input
        type="text"
        value={term}
        disabled={disabled}
        onChange={(e) => onChange(e.target.value)}
        onBlur={() => setTimeout(() => setOpen(false), 150)}
        placeholder="Buscar CIE-10 por diagnóstico o código (ej. rinofaringitis, J00)…"
        className={inputCls}
      />
      {loading && <span className="absolute right-3 top-2.5 text-xs text-vitamed-400">buscando…</span>}
      {open && results.length > 0 && (
        <ul className="absolute z-20 mt-1 max-h-64 w-full overflow-auto rounded-md border border-vitamed-100 bg-white shadow-lg">
          {results.map((c) => (
            <li key={c.code}>
              <button
                type="button"
                onMouseDown={() => { onPick(c); setTerm(''); setResults([]); setOpen(false); }}
                className="flex w-full items-baseline gap-2 px-3 py-2 text-left hover:bg-vitamed-50"
              >
                <span className="shrink-0 rounded bg-vitamed-100 px-1.5 py-0.5 text-xs font-semibold text-vitamed-800">{c.code}</span>
                <span className="text-sm text-vitamed-900">{c.description}</span>
              </button>
            </li>
          ))}
        </ul>
      )}
      {open && !loading && term.trim().length >= 2 && results.length === 0 && (
        <div className="absolute z-20 mt-1 w-full rounded-md border border-vitamed-100 bg-white px-3 py-2 text-sm text-vitamed-500 shadow-lg">
          Sin coincidencias. Puedes escribir el diagnóstico manualmente.
        </div>
      )}
    </div>
  );
}
