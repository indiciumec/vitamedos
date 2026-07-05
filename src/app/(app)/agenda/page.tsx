import { getCurrentProfile } from '@/lib/auth';
import { getAppointments } from '@/lib/queries/appointments';
import { getPatientBasic, getServices } from '@/lib/queries/extra';
import { addDays, dayRange, todayEC, weekDays } from '@/lib/utils';
import AgendaClient from './AgendaClient';

export const dynamic = 'force-dynamic';

type Search = { fecha?: string; vista?: string; paciente?: string };

export default async function AgendaPage({ searchParams }: { searchParams: Search }) {
  const profile = (await getCurrentProfile())!;
  const fecha = /^\d{4}-\d{2}-\d{2}$/.test(searchParams.fecha ?? '') ? searchParams.fecha! : todayEC();
  const vista = searchParams.vista === 'semana' ? 'semana' : 'dia';

  const days = vista === 'semana' ? weekDays(fecha) : [fecha];
  const from = dayRange(days[0]).from;
  const to = dayRange(days[days.length - 1]).to;

  const [citas, services, preselected] = await Promise.all([
    getAppointments(from, to).catch(() => []),
    getServices().catch(() => []),
    searchParams.paciente ? getPatientBasic(searchParams.paciente) : Promise.resolve(null),
  ]);

  return (
    <AgendaClient
      role={profile.role}
      fecha={fecha}
      vista={vista}
      days={days}
      citas={citas}
      services={services}
      hoy={todayEC()}
      prevFecha={addDays(fecha, vista === 'semana' ? -7 : -1)}
      nextFecha={addDays(fecha, vista === 'semana' ? 7 : 1)}
      preselectedPatient={preselected}
    />
  );
}
