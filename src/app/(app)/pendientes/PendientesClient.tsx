'use client';

import Link from 'next/link';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import {
  createInternalNoteAction, deleteInternalNoteAction, toggleTaskDoneAction,
} from '@/lib/actions';
import { formatDate, formatTime } from '@/lib/utils';
import type { InternalNoteWithPatient } from '@/lib/queries/internal';
import type { InternalNoteKind, UserRole } from '@/types/database.types';

const TARGET_LABELS: Record<string, string> = {
  todos: 'Para todos',
  medico: 'Para el médico',
  recepcion: 'Para recepción',
};

const inputCls =
  'w-full rounded-md border border-vitamed-200 px-3 py-2 text-sm focus:border-vitamed-500 focus:outline-none focus:ring-1 focus:ring-vitamed-500';

type Props = {
  notes: InternalNoteWithPatient[] | null;
  role: UserRole;
};

export default function PendientesClient({ notes, role }: Props) {
  const router = useRouter();
  // Default: un mensaje de recepción suele ir al médico y viceversa.
  const defaultTarget = role === 'recepcion' ? 'medico' : role === 'medico' ? 'recepcion' : 'todos';
  const [kind, setKind] = useState<InternalNoteKind>('tarea');
  const [body, setBody] = useState('');
  const [target, setTarget] = useState(defaultTarget);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleAdd(e: React.FormEvent) {
    e.preventDefault();
    if (body.trim().length < 2) return;
    setBusy(true);
    setError(null);
    const res = await createInternalNoteAction({
      kind,
      body: body.trim(),
      target_role: target === 'todos' ? null : target,
    });
    setBusy(false);
    if (!res.ok) {
      setError(res.error);
      return;
    }
    setBody('');
    router.refresh();
  }

  async function toggle(id: string, done: boolean) {
    await toggleTaskDoneAction(id, done);
    router.refresh();
  }

  async function remove(id: string) {
    if (!window.confirm('¿Eliminar este elemento?')) return;
    await deleteInternalNoteAction(id);
    router.refresh();
  }

  const list = notes ?? [];
  const tareasPend = list.filter((n) => n.kind === 'tarea' && !n.is_done);
  const tareasHechas = list.filter((n) => n.kind === 'tarea' && n.is_done);
  const mensajes = list.filter((n) => n.kind === 'mensaje');

  function targetBadge(t: string | null) {
    if (!t) return null;
    return (
      <span className="rounded-full bg-vitamed-100 px-2 py-0.5 text-[10px] font-medium text-vitamed-700">
        {TARGET_LABELS[t] ?? t}
      </span>
    );
  }

  return (
    <main className="mx-auto max-w-3xl p-8">
      <header className="mb-6">
        <h1 className="font-brand text-2xl font-semibold text-vitamed-900">Pendientes</h1>
        <p className="text-sm text-vitamed-600">
          Coordinación entre recepción y el médico: tareas por hacer y recados internos.
        </p>
      </header>

      {notes === null && (
        <p className="mb-6 rounded-lg border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-800">
          No se pudo cargar el tablero. Verifica que la migración{' '}
          <code>006_internal_notes.sql</code> esté ejecutada en Supabase.
        </p>
      )}

      {/* Composer */}
      <form onSubmit={handleAdd} className="mb-6 rounded-xl border border-vitamed-100 bg-white p-4">
        <div className="mb-2 flex gap-1 rounded-md border border-vitamed-200 p-0.5 text-sm">
          <button
            type="button"
            onClick={() => setKind('tarea')}
            className={`flex-1 rounded px-3 py-1 font-medium ${kind === 'tarea' ? 'bg-vitamed-500 text-white' : 'text-vitamed-700'}`}
          >
            ✓ Tarea
          </button>
          <button
            type="button"
            onClick={() => setKind('mensaje')}
            className={`flex-1 rounded px-3 py-1 font-medium ${kind === 'mensaje' ? 'bg-vitamed-500 text-white' : 'text-vitamed-700'}`}
          >
            💬 Mensaje
          </button>
        </div>
        <textarea
          value={body}
          onChange={(e) => setBody(e.target.value)}
          rows={2}
          placeholder={kind === 'tarea' ? 'Ej: Llamar al laboratorio por los resultados de…' : 'Ej: Dra., el paciente de las 3pm confirmó que llega tarde'}
          className={inputCls}
        />
        <div className="mt-2 flex flex-wrap items-center gap-2">
          <select value={target} onChange={(e) => setTarget(e.target.value)} className="rounded-md border border-vitamed-200 px-2 py-1.5 text-sm">
            <option value="todos">Para todos</option>
            <option value="medico">Para el médico</option>
            <option value="recepcion">Para recepción</option>
          </select>
          <button
            type="submit"
            disabled={busy || body.trim().length < 2}
            className="ml-auto rounded-md bg-vitamed-500 px-5 py-2 text-sm font-medium text-white hover:bg-vitamed-600 disabled:opacity-50"
          >
            {busy ? 'Guardando…' : kind === 'tarea' ? 'Agregar tarea' : 'Enviar mensaje'}
          </button>
        </div>
        {error && <p className="mt-2 text-sm text-red-600">{error}</p>}
      </form>

      {/* Tareas pendientes */}
      <section className="mb-6 rounded-xl border border-vitamed-100 bg-white">
        <h2 className="flex items-center justify-between border-b border-vitamed-100 px-5 py-3 text-sm font-semibold text-vitamed-900">
          Tareas por hacer
          <span className="rounded-full bg-vitamed-100 px-2 py-0.5 text-xs text-vitamed-700">{tareasPend.length}</span>
        </h2>
        {tareasPend.length === 0 ? (
          <p className="px-5 py-6 text-sm text-vitamed-500">Sin tareas pendientes. 🎉</p>
        ) : (
          <ul className="divide-y divide-vitamed-50">
            {tareasPend.map((n) => (
              <li key={n.id} className="flex items-start gap-3 px-5 py-3">
                <input
                  type="checkbox"
                  checked={false}
                  onChange={() => toggle(n.id, true)}
                  className="mt-0.5 h-4 w-4 accent-vitamed-500"
                />
                <div className="min-w-0 flex-1">
                  <p className="text-sm text-vitamed-900">{n.body}</p>
                  <div className="mt-0.5 flex flex-wrap items-center gap-2 text-[11px] text-vitamed-500">
                    {targetBadge(n.target_role)}
                    {n.author_name && <span>{n.author_name}</span>}
                    <span>· {formatDate(n.created_at)}</span>
                    {n.patient && (
                      <span>· {n.patient.first_name} {n.patient.last_name}</span>
                    )}
                  </div>
                </div>
                <button onClick={() => remove(n.id)} className="text-xs text-vitamed-400 hover:text-red-600" title="Eliminar">✕</button>
              </li>
            ))}
          </ul>
        )}
        {tareasHechas.length > 0 && (
          <details className="border-t border-vitamed-50">
            <summary className="cursor-pointer px-5 py-2 text-xs text-vitamed-500">
              {tareasHechas.length} tarea(s) completada(s)
            </summary>
            <ul className="divide-y divide-vitamed-50">
              {tareasHechas.map((n) => (
                <li key={n.id} className="flex items-start gap-3 px-5 py-2">
                  <input
                    type="checkbox"
                    checked
                    onChange={() => toggle(n.id, false)}
                    className="mt-0.5 h-4 w-4 accent-vitamed-500"
                  />
                  <p className="flex-1 text-sm text-vitamed-400 line-through">{n.body}</p>
                  <button onClick={() => remove(n.id)} className="text-xs text-vitamed-300 hover:text-red-600">✕</button>
                </li>
              ))}
            </ul>
          </details>
        )}
      </section>

      {/* Mensajes internos */}
      <section className="rounded-xl border border-vitamed-100 bg-white">
        <h2 className="border-b border-vitamed-100 px-5 py-3 text-sm font-semibold text-vitamed-900">
          Mensajes internos
        </h2>
        {mensajes.length === 0 ? (
          <p className="px-5 py-6 text-sm text-vitamed-500">Sin mensajes.</p>
        ) : (
          <ul className="divide-y divide-vitamed-50">
            {mensajes.map((n) => (
              <li key={n.id} className="px-5 py-3">
                <div className="flex items-start justify-between gap-2">
                  <p className="text-sm text-vitamed-900">{n.body}</p>
                  <button onClick={() => remove(n.id)} className="shrink-0 text-xs text-vitamed-400 hover:text-red-600">✕</button>
                </div>
                <div className="mt-0.5 flex flex-wrap items-center gap-2 text-[11px] text-vitamed-500">
                  {targetBadge(n.target_role)}
                  {n.author_name && <span className="font-medium text-vitamed-600">{n.author_name}</span>}
                  <span>· {formatDate(n.created_at)} {formatTime(n.created_at)}</span>
                  {n.patient && (
                    <Link href={`/pacientes/${n.patient_id}`} className="hover:underline">
                      · {n.patient.first_name} {n.patient.last_name}
                    </Link>
                  )}
                </div>
              </li>
            ))}
          </ul>
        )}
      </section>
    </main>
  );
}
