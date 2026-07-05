import Link from 'next/link';
import { getCurrentProfile } from '@/lib/auth';
import { getAppointments } from '@/lib/queries/appointments';
import { getDailyCash } from '@/lib/queries/payments';
import { listMyDrafts } from '@/lib/queries/extra';
import {
  APPT_STATUS_BADGE, APPT_STATUS_LABELS, dayRange, formatDateLong, formatMoney, formatTime, todayEC,
} from '@/lib/utils';

export const dynamic = 'force-dynamic';

export default async function PanelPage() {
  const profile = (await getCurrentProfile())!;
  const hoy = todayEC();
  const { from, to } = dayRange(hoy);

  const canAgenda = ['medico', 'recepcion', 'admin'].includes(profile.role);
  const [citas, caja, borradores] = await Promise.all([
    canAgenda ? getAppointments(from, to).catch(() => []) : Promise.resolve([]),
    canAgenda ? getDailyCash(hoy).catch(() => null) : Promise.resolve(null),
    profile.role === 'medico' ? listMyDrafts().catch(() => []) : Promise.resolve([]),
  ]);

  const activas = citas.filter((c) => !['cancelada', 'no_asistio'].includes(c.status));

  return (
    <main className="mx-auto max-w-5xl p-8">
      <header className="mb-6">
        <h1 className="font-brand text-2xl font-semibold text-vitamed-900">
          Hola, {profile.full_name.split(' ')[0]}
        </h1>
        <p className="text-sm capitalize text-vitamed-600">{formatDateLong(hoy)}</p>
      </header>

      {profile.role === 'tecnico' ? (
        <p className="text-vitamed-700">Rol técnico: sin acceso a datos clínicos ni administrativos.</p>
      ) : (
        <>
          <div className="mb-8 grid gap-4 sm:grid-cols-3">
            <div className="rounded-xl border border-vitamed-100 bg-white p-5">
              <div className="text-3xl font-semibold text-vitamed-900">{activas.length}</div>
              <div className="text-sm text-vitamed-600">Citas hoy</div>
            </div>
            <div className="rounded-xl border border-vitamed-100 bg-white p-5">
              <div className="text-3xl font-semibold text-vitamed-900">
                {caja ? formatMoney(caja.total) : '—'}
              </div>
              <div className="text-sm text-vitamed-600">Cobrado hoy</div>
            </div>
            {profile.role === 'medico' ? (
              <div className="rounded-xl border border-vitamed-100 bg-white p-5">
                <div className="text-3xl font-semibold text-vitamed-900">{borradores.length}</div>
                <div className="text-sm text-vitamed-600">Consultas en borrador</div>
              </div>
            ) : (
              <div className="rounded-xl border border-vitamed-100 bg-white p-5">
                <div className="text-3xl font-semibold text-vitamed-900">
                  {caja ? caja.pendingCount : '—'}
                </div>
                <div className="text-sm text-vitamed-600">Pagos pendientes</div>
              </div>
            )}
          </div>

          <div className="mb-8 flex flex-wrap gap-3">
            <Link href="/agenda" className="rounded-md bg-vitamed-500 px-4 py-2 text-sm font-medium text-white hover:bg-vitamed-600">
              Ver agenda
            </Link>
            <Link href="/pacientes/nuevo" className="rounded-md border border-vitamed-300 bg-white px-4 py-2 text-sm font-medium text-vitamed-800 hover:bg-vitamed-50">
              Nuevo paciente
            </Link>
            {profile.role === 'medico' && (
              <Link href="/consulta" className="rounded-md border border-vitamed-300 bg-white px-4 py-2 text-sm font-medium text-vitamed-800 hover:bg-vitamed-50">
                Iniciar consulta
              </Link>
            )}
          </div>

          <section className="rounded-xl border border-vitamed-100 bg-white">
            <h2 className="border-b border-vitamed-100 px-5 py-3 text-sm font-semibold text-vitamed-900">
              Agenda de hoy
            </h2>
            {citas.length === 0 ? (
              <p className="px-5 py-6 text-sm text-vitamed-500">Sin citas para hoy.</p>
            ) : (
              <ul className="divide-y divide-vitamed-50">
                {citas.map((c) => (
                  <li key={c.id} className="flex items-center gap-4 px-5 py-3">
                    <span className="w-12 text-sm font-semibold tabular-nums text-vitamed-900">
                      {formatTime(c.scheduled_at)}
                    </span>
                    <span className="flex-1 truncate text-sm text-vitamed-800">
                      {c.patient.first_name} {c.patient.last_name}
                      {c.reason && <span className="text-vitamed-500"> · {c.reason}</span>}
                    </span>
                    <span className={`rounded-full px-2.5 py-0.5 text-xs font-medium ${APPT_STATUS_BADGE[c.status]}`}>
                      {APPT_STATUS_LABELS[c.status]}
                    </span>
                  </li>
                ))}
              </ul>
            )}
          </section>
        </>
      )}
    </main>
  );
}
