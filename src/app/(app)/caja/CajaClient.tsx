'use client';

import Link from 'next/link';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { registerPaymentAction, settlePendingAction } from '@/lib/actions';
import type { DailyCashReport } from '@/lib/queries/payments';
import type { WithPatientName } from '@/lib/queries/extra';
import type { Payment, PaymentMethod, PatientBasic, Service } from '@/types/database.types';
import PatientSearchSelect from '@/components/PatientSearchSelect';
import {
  PAYMENT_METHOD_LABELS, PAYMENT_STATUS_BADGE, PAYMENT_STATUS_LABELS,
  formatDateLong, formatMoney, formatTime,
} from '@/lib/utils';

const inputCls =
  'mt-1 w-full rounded-md border border-vitamed-200 px-3 py-2 text-sm focus:border-vitamed-500 focus:outline-none focus:ring-1 focus:ring-vitamed-500';

type Props = {
  fecha: string;
  hoy: string;
  prevFecha: string;
  nextFecha: string;
  reporte: DailyCashReport | null;
  pagosDia: (Payment & WithPatientName)[];
  pendientes: Payment[];
  services: Service[];
};

export default function CajaClient({
  fecha, hoy, prevFecha, nextFecha, reporte, pagosDia, pendientes, services,
}: Props) {
  const router = useRouter();
  const [showForm, setShowForm] = useState(false);
  const [patient, setPatient] = useState<PatientBasic | null>(null);
  const [serviceId, setServiceId] = useState('');
  const [amount, setAmount] = useState('');
  const [method, setMethod] = useState<PaymentMethod>('efectivo');
  const [notes, setNotes] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [settleMethod, setSettleMethod] = useState<Record<string, PaymentMethod>>({});

  function pickService(id: string) {
    setServiceId(id);
    const s = services.find((x) => x.id === id);
    if (s) setAmount(String(s.price));
  }

  async function handleRegister(e: React.FormEvent) {
    e.preventDefault();
    if (!patient) {
      setError('Selecciona un paciente');
      return;
    }
    setError(null);
    setBusy(true);
    const status = method === 'pendiente' ? 'pendiente' : method === 'cortesia' ? 'cortesia' : 'pagado';
    const res = await registerPaymentAction({
      patient_id: patient.id,
      service_id: serviceId || null,
      amount: parseFloat(amount || '0'),
      method,
      status,
      notes: notes.trim() || null,
    });
    setBusy(false);
    if (!res.ok) {
      setError(res.error);
      return;
    }
    setShowForm(false);
    setPatient(null);
    setAmount('');
    setNotes('');
    router.refresh();
  }

  async function handleSettle(id: string) {
    const m = settleMethod[id] ?? 'efectivo';
    setBusy(true);
    const res = await settlePendingAction(id, m);
    setBusy(false);
    if (!res.ok) {
      setError(res.error);
      return;
    }
    router.refresh();
  }

  return (
    <main className="mx-auto max-w-5xl p-8">
      <header className="mb-6 flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="font-brand text-2xl font-semibold text-vitamed-900">Caja</h1>
          <p className="text-sm capitalize text-vitamed-600">{formatDateLong(fecha)}</p>
        </div>
        <div className="flex items-center gap-2">
          <Link href={`/caja?fecha=${prevFecha}`} className="rounded-md border border-vitamed-200 px-3 py-1.5 text-sm text-vitamed-800 hover:bg-vitamed-50">←</Link>
          <Link href={`/caja?fecha=${hoy}`} className="rounded-md border border-vitamed-200 px-3 py-1.5 text-sm text-vitamed-800 hover:bg-vitamed-50">Hoy</Link>
          <Link href={`/caja?fecha=${nextFecha}`} className="rounded-md border border-vitamed-200 px-3 py-1.5 text-sm text-vitamed-800 hover:bg-vitamed-50">→</Link>
          <button
            onClick={() => setShowForm((v) => !v)}
            className="ml-2 rounded-md bg-vitamed-500 px-4 py-2 text-sm font-medium text-white hover:bg-vitamed-600"
          >
            Registrar pago
          </button>
        </div>
      </header>

      {error && <p className="mb-4 text-sm text-red-600">{error}</p>}

      {showForm && (
        <form onSubmit={handleRegister} className="mb-6 rounded-xl border border-vitamed-100 bg-white p-6">
          <h2 className="mb-4 text-sm font-semibold text-vitamed-900">Registrar pago</h2>
          <div className="mb-4">
            <span className="text-sm font-medium text-vitamed-900">Paciente *</span>
            <div className="mt-1">
              <PatientSearchSelect selected={patient} onSelect={(p) => setPatient(p ?? null)} />
            </div>
          </div>
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
            <label className="block">
              <span className="text-sm font-medium text-vitamed-900">Servicio</span>
              <select value={serviceId} onChange={(e) => pickService(e.target.value)} className={inputCls}>
                <option value="">—</option>
                {services.map((s) => (
                  <option key={s.id} value={s.id}>{s.name} ({formatMoney(s.price)})</option>
                ))}
              </select>
            </label>
            <label className="block">
              <span className="text-sm font-medium text-vitamed-900">Monto *</span>
              <input type="number" step="0.01" min="0" required value={amount} onChange={(e) => setAmount(e.target.value)} className={inputCls} />
            </label>
            <label className="block">
              <span className="text-sm font-medium text-vitamed-900">Método</span>
              <select value={method} onChange={(e) => setMethod(e.target.value as PaymentMethod)} className={inputCls}>
                {Object.entries(PAYMENT_METHOD_LABELS).map(([k, v]) => (
                  <option key={k} value={k}>{v}</option>
                ))}
              </select>
            </label>
            <label className="block">
              <span className="text-sm font-medium text-vitamed-900">Notas</span>
              <input value={notes} onChange={(e) => setNotes(e.target.value)} className={inputCls} />
            </label>
          </div>
          <div className="mt-4 flex gap-3">
            <button type="submit" disabled={busy} className="rounded-md bg-vitamed-500 px-5 py-2 text-sm font-medium text-white hover:bg-vitamed-600 disabled:opacity-50">
              {busy ? 'Registrando…' : 'Registrar'}
            </button>
            <button type="button" onClick={() => setShowForm(false)} className="rounded-md border border-vitamed-200 px-5 py-2 text-sm text-vitamed-800 hover:bg-vitamed-50">
              Cancelar
            </button>
          </div>
        </form>
      )}

      {/* Cierre diario */}
      <div className="mb-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <div className="rounded-xl border border-vitamed-100 bg-white p-5">
          <div className="text-2xl font-semibold text-vitamed-900">{reporte ? formatMoney(reporte.total) : '—'}</div>
          <div className="text-sm text-vitamed-600">Total cobrado ({reporte?.paymentsCount ?? 0} pagos)</div>
        </div>
        <div className="rounded-xl border border-vitamed-100 bg-white p-5">
          <div className="text-sm font-semibold text-vitamed-900">Por método</div>
          {reporte && Object.keys(reporte.byMethod).length > 0 ? (
            <ul className="mt-1 space-y-0.5 text-sm text-vitamed-700">
              {Object.entries(reporte.byMethod).map(([m, v]) => (
                <li key={m} className="flex justify-between">
                  <span>{PAYMENT_METHOD_LABELS[m as PaymentMethod] ?? m}</span>
                  <span className="tabular-nums">{formatMoney(v)}</span>
                </li>
              ))}
            </ul>
          ) : (
            <div className="mt-1 text-sm text-vitamed-400">Sin cobros</div>
          )}
        </div>
        <div className="rounded-xl border border-amber-200 bg-amber-50 p-5">
          <div className="text-2xl font-semibold text-amber-900">
            {reporte ? formatMoney(reporte.pendingTotal) : '—'}
          </div>
          <div className="text-sm text-amber-800">Pendiente acumulado ({reporte?.pendingCount ?? 0})</div>
        </div>
        <div className="rounded-xl border border-vitamed-100 bg-white p-5">
          <div className="text-2xl font-semibold text-vitamed-900">{pagosDia.length}</div>
          <div className="text-sm text-vitamed-600">Movimientos del día</div>
        </div>
      </div>

      {/* Movimientos del día */}
      <section className="mb-6 rounded-xl border border-vitamed-100 bg-white">
        <h2 className="border-b border-vitamed-100 px-5 py-3 text-sm font-semibold text-vitamed-900">
          Movimientos del día
        </h2>
        {pagosDia.length === 0 ? (
          <p className="px-5 py-6 text-sm text-vitamed-500">Sin movimientos.</p>
        ) : (
          <ul className="divide-y divide-vitamed-50">
            {pagosDia.map((p) => (
              <li key={p.id} className="flex items-center gap-3 px-5 py-3">
                <span className="w-12 text-sm tabular-nums text-vitamed-600">{formatTime(p.created_at)}</span>
                <span className="flex-1 truncate text-sm text-vitamed-900">
                  {p.patient.first_name} {p.patient.last_name}
                  {p.notes && <span className="text-vitamed-500"> · {p.notes}</span>}
                </span>
                <span className="text-sm text-vitamed-600">{PAYMENT_METHOD_LABELS[p.method]}</span>
                <span className="w-20 text-right text-sm font-semibold tabular-nums text-vitamed-900">
                  {formatMoney(p.amount)}
                </span>
                <span className={`rounded-full px-2.5 py-0.5 text-xs font-medium ${PAYMENT_STATUS_BADGE[p.status]}`}>
                  {PAYMENT_STATUS_LABELS[p.status]}
                </span>
              </li>
            ))}
          </ul>
        )}
      </section>

      {/* Pendientes */}
      <section className="rounded-xl border border-vitamed-100 bg-white">
        <h2 className="border-b border-vitamed-100 px-5 py-3 text-sm font-semibold text-vitamed-900">
          Pagos pendientes
        </h2>
        {pendientes.length === 0 ? (
          <p className="px-5 py-6 text-sm text-vitamed-500">No hay pagos pendientes. 🎉</p>
        ) : (
          <ul className="divide-y divide-vitamed-50">
            {pendientes.map((p) => (
              <li key={p.id} className="flex flex-wrap items-center gap-3 px-5 py-3">
                <span className="flex-1 text-sm text-vitamed-900">
                  {p.notes ?? 'Pago pendiente'}
                </span>
                <span className="text-sm font-semibold tabular-nums text-vitamed-900">
                  {formatMoney(p.amount)}
                </span>
                <select
                  value={settleMethod[p.id] ?? 'efectivo'}
                  onChange={(e) => setSettleMethod((prev) => ({ ...prev, [p.id]: e.target.value as PaymentMethod }))}
                  className="rounded-md border border-vitamed-200 px-2 py-1 text-xs"
                >
                  <option value="efectivo">Efectivo</option>
                  <option value="transferencia">Transferencia</option>
                  <option value="tarjeta">Tarjeta</option>
                </select>
                <button
                  disabled={busy}
                  onClick={() => handleSettle(p.id)}
                  className="rounded-md bg-vitamed-500 px-3 py-1 text-xs font-medium text-white hover:bg-vitamed-600 disabled:opacity-50"
                >
                  Liquidar
                </button>
              </li>
            ))}
          </ul>
        )}
      </section>
    </main>
  );
}
