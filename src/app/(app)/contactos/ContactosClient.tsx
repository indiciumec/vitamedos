'use client';

import Link from 'next/link';
import { useState } from 'react';
import WAButton from '@/components/wa-button';
import { WA_TEMPLATES } from '@/lib/whatsapp';
import { updateCommunicationStatusAction } from '@/lib/actions';
import {
  COMM_KIND_LABELS, COMM_STATUS_BADGE, COMM_STATUS_LABELS, formatDate, formatTime, todayEC,
} from '@/lib/utils';
import type { ContactQueue, QueueItem, CommunicationWithPatient } from '@/lib/queries/communications';
import type { CommunicationStatus } from '@/types/database.types';

type Props = {
  queue: ContactQueue | null;
  recent: CommunicationWithPatient[];
  clinicName: string;
};

export default function ContactosClient({ queue, recent, clinicName }: Props) {
  const [done, setDone] = useState<Set<string>>(new Set());
  const [rows, setRows] = useState(recent);

  function keyOf(it: QueueItem) {
    return `${it.kind}:${it.appointmentId ?? it.consultationId ?? it.patientId}`;
  }

  function messageFor(it: QueueItem): string {
    if (it.kind === 'confirmacion') {
      return WA_TEMPLATES.confirmacion({
        clinica: clinicName,
        nombre: it.firstName,
        fecha: formatDate(it.refDate),
        hora: formatTime(it.refDate),
      });
    }
    if (it.kind === 'control') {
      const dias = Math.max(0, Math.round(
        (new Date(`${it.refDate}T12:00:00-05:00`).getTime() -
          new Date(`${todayEC()}T12:00:00-05:00`).getTime()) / 86400000
      ));
      return WA_TEMPLATES.control({ clinica: clinicName, nombre: it.firstName, dias });
    }
    return WA_TEMPLATES.postconsulta({ clinica: clinicName, nombre: it.firstName });
  }

  async function setStatus(id: string, status: CommunicationStatus) {
    setRows((prev) => prev.map((r) => (r.id === id ? { ...r, status } : r)));
    await updateCommunicationStatusAction(id, status);
  }

  function Section({ title, items }: { title: string; items: QueueItem[] }) {
    if (items.length === 0) return null;
    return (
      <section className="rounded-xl border border-vitamed-100 bg-white">
        <h2 className="flex items-center justify-between border-b border-vitamed-100 px-5 py-3 text-sm font-semibold text-vitamed-900">
          {title}
          <span className="rounded-full bg-vitamed-100 px-2 py-0.5 text-xs text-vitamed-700">
            {items.filter((i) => !i.done && !done.has(keyOf(i))).length} pendiente(s)
          </span>
        </h2>
        <ul className="divide-y divide-vitamed-50">
          {items.map((it) => {
            const isDone = it.done || done.has(keyOf(it));
            return (
              <li key={keyOf(it)} className="flex flex-wrap items-center gap-3 px-5 py-3">
                <div className="min-w-0 flex-1">
                  <Link href={`/pacientes/${it.patientId}`} className="truncate text-sm font-medium text-vitamed-900 hover:underline">
                    {it.patientName}
                  </Link>
                  <div className="truncate text-xs text-vitamed-600">{it.reason}</div>
                </div>
                {isDone ? (
                  <span className="text-xs font-medium text-emerald-700">✓ Contactado</span>
                ) : (
                  <span onClick={() => setDone((p) => new Set(p).add(keyOf(it)))}>
                    <WAButton
                      compact
                      label="Enviar"
                      phone={it.phone}
                      message={messageFor(it)}
                      log={{
                        patientId: it.patientId,
                        kind: it.kind,
                        appointmentId: it.appointmentId,
                        consultationId: it.consultationId,
                      }}
                    />
                  </span>
                )}
                {!it.phone && <span className="text-xs text-vitamed-400">sin WhatsApp</span>}
              </li>
            );
          })}
        </ul>
      </section>
    );
  }

  const totalPend = queue
    ? [...queue.confirmaciones, ...queue.controles, ...queue.seguimientos].filter(
        (i) => !i.done && !done.has(keyOf(i))
      ).length
    : 0;

  return (
    <main className="mx-auto max-w-4xl p-8">
      <header className="mb-6">
        <h1 className="font-brand text-2xl font-semibold text-vitamed-900">Contactos</h1>
        <p className="text-sm text-vitamed-600">
          {totalPend > 0
            ? `${totalPend} paciente(s) por contactar hoy vía WhatsApp`
            : 'Sin contactos pendientes por ahora'}
        </p>
      </header>

      {!queue ? (
        <p className="rounded-lg border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-800">
          No se pudo cargar la cola de contactos. Verifica que la migración{' '}
          <code>005_communications.sql</code> esté ejecutada en Supabase.
        </p>
      ) : (
        <div className="space-y-6">
          <Section title="Confirmar citas de mañana" items={queue.confirmaciones} />
          <Section title="Avisos de control" items={queue.controles} />
          <Section title="Seguimiento post-consulta" items={queue.seguimientos} />

          {queue.confirmaciones.length === 0 &&
            queue.controles.length === 0 &&
            queue.seguimientos.length === 0 && (
              <p className="rounded-xl border border-vitamed-100 bg-white px-5 py-6 text-sm text-vitamed-500">
                No hay pacientes por contactar hoy. 🎉
              </p>
            )}

          {queue.role === 'recepcion' && (
            <p className="text-xs text-vitamed-500">
              Recepción ve las confirmaciones de citas. Los avisos de control y seguimiento clínico
              los gestiona el médico (datos clínicos protegidos).
            </p>
          )}
        </div>
      )}

      {/* Bitácora reciente */}
      <section className="mt-8 rounded-xl border border-vitamed-100 bg-white">
        <h2 className="border-b border-vitamed-100 px-5 py-3 text-sm font-semibold text-vitamed-900">
          Historial de contactos
        </h2>
        {rows.length === 0 ? (
          <p className="px-5 py-6 text-sm text-vitamed-500">Aún no hay contactos registrados.</p>
        ) : (
          <ul className="divide-y divide-vitamed-50">
            {rows.map((c) => (
              <li key={c.id} className="flex flex-wrap items-center gap-3 px-5 py-3">
                <span className="w-24 shrink-0 text-xs tabular-nums text-vitamed-600">
                  {formatDate(c.created_at)}
                </span>
                <div className="min-w-0 flex-1">
                  <Link href={`/pacientes/${c.patient_id}`} className="truncate text-sm font-medium text-vitamed-900 hover:underline">
                    {c.patient.first_name} {c.patient.last_name}
                  </Link>
                  <div className="text-xs text-vitamed-500">{COMM_KIND_LABELS[c.kind]}</div>
                </div>
                <select
                  value={c.status}
                  onChange={(e) => setStatus(c.id, e.target.value as CommunicationStatus)}
                  className={`rounded-full border-0 px-2.5 py-0.5 text-xs font-medium ${COMM_STATUS_BADGE[c.status]}`}
                >
                  {(Object.keys(COMM_STATUS_LABELS) as CommunicationStatus[]).map((s) => (
                    <option key={s} value={s}>{COMM_STATUS_LABELS[s]}</option>
                  ))}
                </select>
                <WAButton compact label="WA" phone={c.patient.whatsapp ?? c.patient.phone} />
              </li>
            ))}
          </ul>
        )}
      </section>
    </main>
  );
}
