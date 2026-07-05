'use client';

import { useEffect, useRef, useState } from 'react';
import { searchPatientsAction } from '@/lib/actions';
import WAButton from '@/components/wa-button';
import type { PatientBasic } from '@/types/database.types';

type Props = {
  onSelect: (patient: PatientBasic) => void;
  selected?: PatientBasic | null;
  placeholder?: string;
  autoFocus?: boolean;
  /** Muestra un botón de WhatsApp por resultado (usado en /pacientes). */
  showWhatsApp?: boolean;
};

/** Buscador de pacientes (cédula, nombre o teléfono) con dropdown de resultados. */
export default function PatientSearchSelect({ onSelect, selected, placeholder, autoFocus, showWhatsApp }: Props) {
  const [term, setTerm] = useState('');
  const [results, setResults] = useState<PatientBasic[]>([]);
  const [open, setOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const timer = useRef<ReturnType<typeof setTimeout> | undefined>(undefined);

  useEffect(() => {
    if (term.trim().length < 2) {
      setResults([]);
      return;
    }
    clearTimeout(timer.current);
    timer.current = setTimeout(async () => {
      setLoading(true);
      const res = await searchPatientsAction(term);
      setLoading(false);
      if (res.ok) {
        setResults(res.data);
        setOpen(true);
      }
    }, 300);
    return () => clearTimeout(timer.current);
  }, [term]);

  if (selected) {
    return (
      <div className="flex items-center justify-between rounded-md border border-vitamed-200 bg-vitamed-50 px-3 py-2">
        <div>
          <div className="text-sm font-medium text-vitamed-900">
            {selected.first_name} {selected.last_name}
          </div>
          <div className="text-xs text-vitamed-600">
            {selected.identification_number}
            {selected.age != null && ` · ${selected.age} años`}
            {selected.phone && ` · ${selected.phone}`}
          </div>
        </div>
        <button
          type="button"
          onClick={() => onSelect(null as unknown as PatientBasic)}
          className="text-xs text-vitamed-600 underline-offset-2 hover:underline"
        >
          Cambiar
        </button>
      </div>
    );
  }

  return (
    <div className="relative">
      <input
        type="text"
        value={term}
        autoFocus={autoFocus}
        onChange={(e) => setTerm(e.target.value)}
        onFocus={() => results.length > 0 && setOpen(true)}
        onBlur={() => setTimeout(() => setOpen(false), 150)}
        placeholder={placeholder ?? 'Buscar por cédula, nombre o teléfono…'}
        className="w-full rounded-md border border-vitamed-200 px-3 py-2 text-sm focus:border-vitamed-500 focus:outline-none focus:ring-1 focus:ring-vitamed-500"
      />
      {loading && (
        <span className="absolute right-3 top-2.5 text-xs text-vitamed-400">buscando…</span>
      )}
      {open && results.length > 0 && (
        <ul className="absolute z-20 mt-1 max-h-64 w-full overflow-auto rounded-md border border-vitamed-100 bg-white shadow-lg">
          {results.map((p) => (
            <li key={p.id} className="flex items-center gap-2 pr-2 hover:bg-vitamed-50">
              <button
                type="button"
                onMouseDown={() => {
                  onSelect(p);
                  setTerm('');
                  setOpen(false);
                }}
                className="min-w-0 flex-1 px-3 py-2 text-left"
              >
                <div className="truncate text-sm font-medium text-vitamed-900">
                  {p.first_name} {p.last_name}
                </div>
                <div className="truncate text-xs text-vitamed-600">
                  {p.identification_number}
                  {p.age != null && ` · ${p.age} años`}
                  {p.phone && ` · ${p.phone}`}
                </div>
              </button>
              {showWhatsApp && (
                <span onMouseDown={(e) => e.preventDefault()}>
                  <WAButton compact label="WA" phone={p.whatsapp ?? p.phone} />
                </span>
              )}
            </li>
          ))}
        </ul>
      )}
      {open && !loading && term.trim().length >= 2 && results.length === 0 && (
        <div className="absolute z-20 mt-1 w-full rounded-md border border-vitamed-100 bg-white px-3 py-2 text-sm text-vitamed-500 shadow-lg">
          Sin resultados.
        </div>
      )}
    </div>
  );
}
