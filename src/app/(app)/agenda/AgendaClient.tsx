'use client';

import Link from 'next/link';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { changeAppointmentStatusAction, createAppointmentAction } from '@/lib/actions';
import type { AppointmentWithPatient } from '@/lib/queries/appointments';
import type { AppointmentStatus, PatientBasic, Service, UserRole } from '@/types/database.types';
import PatientSearchSelect from '@/components/PatientSearchSelect';
import {
  APPT_ACTION_LABELS, APPT_STATUS_BADGE, APPT_STATUS_LABELS, APPT_TRANSITIONS,
  formatDate, formatDateLong, formatTime, toOffsetISO,
} from '@/lib/utils';

type Props = {
  role: UserRole;
  fecha: string;
  vista: 'dia' | 'semana';
  days: string[];
  citas: AppointmentWithPatient[];
  services: Service[];
  hoy: string;
  prevFecha: string;
  nextFecha: string;
  preselectedPatient: PatientBasic | null;
};

const inputCls =
  'mt-1 w-full rounded-md border border-vitamed-200 px-3 py-2 text-sm focus:border-vitamed-500 focus:outline-none focus:ring-1 focus:ring-vitamed-500';

export default function AgendaClient({
  role, fecha, vista, days, citas, services, hoy, prevFecha, nextFecha, preselectedPatient,
}: Props) {
  const router = useRouter();
  const [showForm, setShowForm] = useState(!!preselectedPatient);
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState<string | null>(null);

  // Formulario nueva cita
  const [patient, setPatient] = useState<PatientBasic | null>(preselectedPatient);
  const [fDate, setFDate] = useState(fecha);
  const [fTime, setFTime] = useState('09:00');
  const [fDuration, setFDuration] = useState(30);
  const [fService, setFService] = useState('');
  const [fReason, setFReason] = useState('');
  const [saving, setSaving] = useState(false);

  async function handleCreate(e: React.FormEvent) {
    e.preventDefault();
    if (!patient) {
      setError('Selecciona un paciente');
      return;
    }
    setError(null);
    setSaving(true);
    const res = await createAppointmentAction({
      patient_id: patient.id,
      service_id: fService || null,
      scheduled_at: toOffsetISO(fDate, fTime),
      duration_min: fDuration,
      reason: fReason.trim() || null,
    });
    setSaving(false);
    if (!res.ok) {
      setError(res.error);
      return;
    }
    setShowForm(false);
    setPatient(null);
    setFReason('');
    router.push(`/agenda?fecha=${fDate}`);
    router.refresh();
  }

  async function handleTransition(id: string, next: AppointmentStatus) {
    if (next === 'cancelada' && !window.confirm('¿Cancelar esta cita?')) return;
    setBusy(id);
    const res = await changeAppointmentStatusAction(id, next);
    setBusy(null);
    if (!res.ok) {
      setError(res.error);
      return;
    }
    router.refresh();
  }

  function selectService(id: string) {
    setFService(id);
    const s = services.find((x) => x.id === id);
    if (s) setFDuration(s.duration_min);
  }

  const citasDe = (d: string) =>
    citas.filter((c) => {
      const local = new Date(new Date(c.scheduled_at).getTime() - 5 * 3600_000);
      return local.toISOString().slice(0, 10) === d;
    });

  return (
    <main className="mx-auto max-w-5xl p-8">
      <header className="mb-6 flex flex-wrap items-center justify-between gap-3">
        <h1 className="font-brand text-2xl font-semibold text-vitamed-900">Agenda</h1>
        <div className="flex items-center gap-2">
          <Link href={`/agenda?vista=${vista}&fecha=${prevFecha}`} className="rounded-md border border-vitamed-200 px-3 py-1.5 text-sm text-vitamed-800 hover:bg-vitamed-50">←</Link>
          <Link href={`/agenda?vista=${vista}&fecha=${hoy}`} className="rounded-md border border-vitamed-200 px-3 py-1.5 text-sm text-vitamed-800 hover:bg-vitamed-50">Hoy</Link>
          <Link href={`/agenda?vista=${vista}&fecha=${nextFecha}`} className="rounded-md border border-vitamed-200 px-3 py-1.5 text-sm text-vitamed-800 hover:bg-vitamed-50">→</Link>
          <div className="ml-2 flex rounded-md border border-vitamed-200 p-0.5">
            <Link href={`/agenda?vista=dia&fecha=${fecha}`} className={`rounded px-3 py-1 text-sm ${vista === 'dia' ? 'bg-vitamed-500 text-white' : 'text-vitamed-700'}`}>Día</Link>
            <Link href={`/agenda?vista=semana&fecha=${fecha}`} className={`rounded px-3 py-1 text-sm ${vista === 'semana' ? 'bg-vitamed-500 text-white' : 'text-vitamed-700'}`}>Semana</Link>
          </div>
          <button
            onClick={() => setShowForm((v) => !v)}
            className="ml-2 rounded-md bg-vitamed-500 px-4 py-2 text-sm font-medium text-white hover:bg-vitamed-600"
          >
            Nueva cita
          </button>
        </div>
      </header>

      {error && <p className="mb-4 text-sm text-red-600">{error}</p>}

      {showForm && (
        <form onSubmit={handleCreate} className="mb-6 rounded-xl border border-vitamed-100 bg-white p-6">
          <h2 className="mb-4 text-sm font-semibold text-vitamed-900">Nueva cita</h2>
          <div className="mb-4">
            <span className="text-sm font-medium text-vitamed-900">Paciente *</span>
            <div className="mt-1">
              <PatientSearchSelect selected={patient} onSelect={(p) => setPatient(p ?? null)} />
            </div>
          </div>
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-5">
            <label className="block">
              <span className="text-sm font-medium text-vitamed-900">Fecha *</span>
              <input type="date" required value={fDate} onChange={(e) => setFDate(e.target.value)} className={inputCls} />
            </label>
            <label className="block">
              <span className="text-sm font-medium text-vitamed-900">Hora *</span>
              <input type="time" required value={fTime} onChange={(e) => setFTime(e.target.value)} className={inputCls} />
            </label>
            <label className="block">
              <span className="text-sm font-medium text-vitamed-900">Duración (min)</span>
              <input type="number" min={5} max={240} value={fDuration} onChange={(e) => setFDuration(Number(e.target.value))} className={inputCls} />
            </label>
            <label className="block lg:col-span-2">
              <span className="text-sm font-medium text-vitamed-900">Servicio</span>
              <select value={fService} onChange={(e) => selectService(e.target.value)} className={inputCls}>
                <option value="">—</option>
                {services.map((s) => (
                  <option key={s.id} value={s.id}>{s.name}</option>
                ))}
              </select>
            </label>
            <label className="block sm:col-span-2 lg:col-span-5">
              <span className="text-sm font-medium text-vitamed-900">Motivo</span>
              <input value={fReason} onChange={(e) => setFReason(e.target.value)} className={inputCls} />
            </label>
          </div>
          <div className="mt-4 flex gap-3">
            <button type="submit" disabled={saving} className="rounded-md bg-vitamed-500 px-5 py-2 text-sm font-medium text-white hover:bg-vitamed-600 disabled:opacity-50">
              {saving ? 'Agendando…' : 'Agendar'}
            </button>
            <button type="button" onClick={() => setShowForm(false)} className="rounded-md border border-vitamed-200 px-5 py-2 text-sm text-vitamed-800 hover:bg-vitamed-50">
              Cancelar
            </button>
          </div>
        </form>
      )}

      {vista === 'dia' ? (
        <section className="rounded-xl border border-vitamed-100 bg-white">
          <h2 className="border-b border-vitamed-100 px-5 py-3 text-sm font-semibold capitalize text-vitamed-900">
            {formatDateLong(fecha)}
          </h2>
          {citasDe(fecha).length === 0 ? (
            <p className="px-5 py-6 text-sm text-vitamed-500">Sin citas este día.</p>
          ) : (
            <ul className="divide-y divide-vitamed-50">
              {citasDe(fecha).map((c) => (
                <li key={c.id} className="px-5 py-3">
                  <div className="flex flex-wrap items-center gap-3">
                    <span className="w-12 text-sm font-semibold tabular-nums text-vitamed-900">
                      {formatTime(c.scheduled_at)}
                    </span>
                    <Link href={`/pacientes/${c.patient.id}`} className="flex-1 truncate text-sm font-medium text-vitamed-900 hover:underline">
                      {c.patient.first_name} {c.patient.last_name}
                      {c.reason && <span className="font-normal text-vitamed-500"> · {c.reason}</span>}
                    </Link>
                    <span className={`rounded-full px-2.5 py-0.5 text-xs font-medium ${APPT_STATUS_BADGE[c.status]}`}>
                      {APPT_STATUS_LABELS[c.status]}
                    </span>
                  </div>
                  <div className="mt-1.5 flex flex-wrap gap-1.5 pl-14">
                    {role === 'medico' && ['confirmada', 'en_espera'].includes(c.status) && (
                      <Link
                        href={`/consulta/nueva?paciente=${c.patient.id}&cita=${c.id}`}
                        className="rounded border border-vitamed-500 px-2 py-0.5 text-xs font-medium text-vitamed-700 hover:bg-vitamed-50"
                      >
                        Iniciar consulta
                      </Link>
                    )}
                    {APPT_TRANSITIONS[c.status]
                      .filter((n) => n !== 'en_consulta' || role !== 'medico') // el médico entra vía "Iniciar consulta"
                      .map((n) => (
                        <button
                          key={n}
                          disabled={busy === c.id}
                          onClick={() => handleTransition(c.id, n)}
                          className={`rounded border px-2 py-0.5 text-xs disabled:opacity-50 ${
                            n === 'cancelada' || n === 'no_asistio'
                              ? 'border-red-200 text-red-700 hover:bg-red-50'
                              : 'border-vitamed-200 text-vitamed-700 hover:bg-vitamed-50'
                          }`}
                        >
                          {APPT_ACTION_LABELS[n]}
                        </button>
                      ))}
                  </div>
                </li>
              ))}
            </ul>
          )}
        </section>
      ) : (
        <div className="grid gap-3 md:grid-cols-7">
          {days.map((d) => (
            <Link
              key={d}
              href={`/agenda?vista=dia&fecha=${d}`}
              className={`rounded-xl border bg-white p-3 hover:border-vitamed-400 ${
                d === hoy ? 'border-vitamed-500' : 'border-vitamed-100'
              }`}
            >
              <div className="mb-2 text-xs font-semibold uppercase text-vitamed-600">
                {formatDate(d, { weekday: 'short', day: '2-digit', month: undefined, year: undefined })}
              </div>
              {citasDe(d).length === 0 ? (
                <div className="text-xs text-vitamed-400">—</div>
              ) : (
                <ul className="space-y-1">
                  {citasDe(d).slice(0, 5).map((c) => (
                    <li key={c.id} className="truncate text-xs text-vitamed-800">
                      <span className="font-semibold tabular-nums">{formatTime(c.scheduled_at)}</span>{' '}
                      {c.patient.last_name}
                    </li>
                  ))}
                  {citasDe(d).length > 5 && (
                    <li className="text-xs text-vitamed-500">+{citasDe(d).length - 5} más</li>
                  )}
                </ul>
              )}
            </Link>
          ))}
        </div>
      )}
    </main>
  );
}
