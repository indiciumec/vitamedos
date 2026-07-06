'use client';

import Link from 'next/link';
import { useState } from 'react';
import { formatDate } from '@/lib/utils';

export type TimelineType = 'consulta' | 'receta' | 'documento' | 'pago' | 'comunicacion';

export type TimelineItem = {
  id: string;
  type: TimelineType;
  date: string;
  title: string;
  subtitle?: string | null;
  badge?: string | null;
  badgeClass?: string | null;
  href?: string | null;
};

const META: Record<TimelineType, { label: string; dot: string; icon: string }> = {
  consulta: { label: 'Consultas', dot: 'bg-vitamed-500', icon: '🩺' },
  receta: { label: 'Recetas', dot: 'bg-emerald-500', icon: '℞' },
  documento: { label: 'Documentos', dot: 'bg-blue-500', icon: '📄' },
  pago: { label: 'Pagos', dot: 'bg-amber-500', icon: '💵' },
  comunicacion: { label: 'WhatsApp', dot: 'bg-green-500', icon: '💬' },
};

const FILTERS: Array<{ key: TimelineType | 'todo'; label: string }> = [
  { key: 'todo', label: 'Todo' },
  { key: 'consulta', label: 'Consultas' },
  { key: 'receta', label: 'Recetas' },
  { key: 'documento', label: 'Documentos' },
  { key: 'pago', label: 'Pagos' },
  { key: 'comunicacion', label: 'WhatsApp' },
];

export default function PatientTimeline({ items }: { items: TimelineItem[] }) {
  const [filter, setFilter] = useState<TimelineType | 'todo'>('todo');
  const shown = filter === 'todo' ? items : items.filter((i) => i.type === filter);

  return (
    <section className="rounded-xl border border-vitamed-100 bg-white">
      <div className="flex flex-wrap items-center gap-1.5 border-b border-vitamed-100 px-5 py-3">
        <h2 className="mr-2 text-sm font-semibold text-vitamed-900">Historial</h2>
        {FILTERS.map((f) => {
          const count = f.key === 'todo' ? items.length : items.filter((i) => i.type === f.key).length;
          if (f.key !== 'todo' && count === 0) return null;
          return (
            <button
              key={f.key}
              onClick={() => setFilter(f.key)}
              className={`rounded-full px-2.5 py-1 text-xs font-medium transition-colors ${
                filter === f.key
                  ? 'bg-vitamed-500 text-white'
                  : 'bg-vitamed-50 text-vitamed-700 hover:bg-vitamed-100'
              }`}
            >
              {f.label} {count > 0 && <span className="opacity-70">{count}</span>}
            </button>
          );
        })}
      </div>

      {shown.length === 0 ? (
        <p className="px-5 py-6 text-sm text-vitamed-500">Sin registros en esta categoría.</p>
      ) : (
        <ol className="relative px-5 py-4">
          <span className="absolute bottom-4 left-[26px] top-4 w-px bg-vitamed-100" aria-hidden />
          {shown.map((it) => {
            const m = META[it.type];
            const row = (
              <div className="flex gap-3">
                <span
                  className={`z-10 mt-0.5 flex h-5 w-5 shrink-0 items-center justify-center rounded-full text-[10px] text-white ${m.dot}`}
                  title={m.label}
                >
                  {m.icon}
                </span>
                <div className="min-w-0 flex-1">
                  <div className="flex flex-wrap items-baseline gap-x-2">
                    <span className="text-xs tabular-nums text-vitamed-500">{formatDate(it.date)}</span>
                    <span className="truncate text-sm font-medium text-vitamed-900">{it.title}</span>
                    {it.badge && (
                      <span className={`rounded-full px-2 py-0.5 text-[11px] font-medium ${it.badgeClass ?? 'bg-slate-100 text-slate-700'}`}>
                        {it.badge}
                      </span>
                    )}
                  </div>
                  {it.subtitle && <div className="truncate text-xs text-vitamed-500">{it.subtitle}</div>}
                </div>
              </div>
            );
            return (
              <li key={`${it.type}-${it.id}`} className="py-2">
                {it.href ? (
                  <Link href={it.href} className="block rounded-md hover:bg-vitamed-50">{row}</Link>
                ) : (
                  row
                )}
              </li>
            );
          })}
        </ol>
      )}
    </section>
  );
}
