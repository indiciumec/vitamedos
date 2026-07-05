import { getDailyCash, getPendingPayments } from '@/lib/queries/payments';
import { getDayPayments, getServices } from '@/lib/queries/extra';
import { addDays, dayRange, todayEC } from '@/lib/utils';
import CajaClient from './CajaClient';

export const dynamic = 'force-dynamic';

export default async function CajaPage({ searchParams }: { searchParams: Promise<{ fecha?: string }> }) {
  const sp = await searchParams;
  const fecha = /^\d{4}-\d{2}-\d{2}$/.test(sp.fecha ?? '') ? sp.fecha! : todayEC();
  const { from, to } = dayRange(fecha);

  const [reporte, pagosDia, pendientes, services] = await Promise.all([
    getDailyCash(fecha).catch(() => null),
    getDayPayments(from, to).catch(() => []),
    getPendingPayments().catch(() => []),
    getServices().catch(() => []),
  ]);

  return (
    <CajaClient
      fecha={fecha}
      hoy={todayEC()}
      prevFecha={addDays(fecha, -1)}
      nextFecha={addDays(fecha, 1)}
      reporte={reporte}
      pagosDia={pagosDia}
      pendientes={pendientes}
      services={services}
    />
  );
}
