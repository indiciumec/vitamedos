'use server';
// lib/queries/appointments.ts
import { createClient } from '@/lib/supabase/server';
import { requireRole } from '@/lib/auth';
import { appointmentSchema, type AppointmentInput } from '@/lib/validators';
import type { Appointment, AppointmentStatus } from '@/types/database.types';

// Máquina de estados: transiciones válidas
const TRANSITIONS: Record<AppointmentStatus, AppointmentStatus[]> = {
  solicitada:    ['por_confirmar', 'confirmada', 'cancelada'],
  por_confirmar: ['confirmada', 'cancelada'],
  confirmada:    ['en_espera', 'cancelada', 'no_asistio'],
  en_espera:     ['en_consulta', 'cancelada'],
  en_consulta:   ['atendida'],
  atendida:      [],
  cancelada:     [],
  no_asistio:    [],
};

export type AppointmentWithPatient = Appointment & {
  patient: { id: string; first_name: string; last_name: string; phone: string | null };
};

/** Agenda del día (o rango). Base del Panel diario y Sala de espera. */
export async function getAppointments(
  fromISO: string,
  toISO: string
): Promise<AppointmentWithPatient[]> {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('appointments')
    .select('*, patient:patients_basic!inner(id, first_name, last_name, phone)')
    .gte('scheduled_at', fromISO)
    .lt('scheduled_at', toISO)
    .order('scheduled_at', { ascending: true });

  if (error) throw error;
  return data as unknown as AppointmentWithPatient[];
}

export async function createAppointment(input: AppointmentInput): Promise<Appointment> {
  await requireRole('medico', 'recepcion', 'admin');
  const parsed = appointmentSchema.parse(input);
  const supabase = await createClient();

  // Anti solapamiento: verifica choque con citas activas
  const start = new Date(parsed.scheduled_at);
  const end = new Date(start.getTime() + parsed.duration_min * 60_000);
  const { data: overlap } = await supabase
    .from('appointments')
    .select('id, scheduled_at, duration_min')
    .gte('scheduled_at', new Date(start.getTime() - 4 * 3600_000).toISOString())
    .lte('scheduled_at', end.toISOString())
    .not('status', 'in', '(cancelada,no_asistio,atendida)');

  const clash = (overlap ?? []).some((a) => {
    const aStart = new Date(a.scheduled_at).getTime();
    const aEnd = aStart + a.duration_min * 60_000;
    return aStart < end.getTime() && aEnd > start.getTime();
  });
  if (clash) throw new Error('El horario se solapa con otra cita activa');

  const { data, error } = await supabase
    .from('appointments')
    .insert({ ...parsed, status: 'solicitada' })
    .select()
    .single();
  if (error) throw error;
  return data;
}

export async function changeAppointmentStatus(
  id: string,
  next: AppointmentStatus
): Promise<Appointment> {
  await requireRole('medico', 'recepcion', 'admin');
  const supabase = await createClient();

  const { data: current, error: e1 } = await supabase
    .from('appointments')
    .select('status')
    .eq('id', id)
    .single();
  if (e1) throw e1;

  if (!TRANSITIONS[current.status].includes(next)) {
    throw new Error(`Transición inválida: ${current.status} → ${next}`);
  }

  const { data, error } = await supabase
    .from('appointments')
    .update({ status: next })
    .eq('id', id)
    .select()
    .single();
  if (error) throw error;
  return data;
}

export async function reschedule(id: string, newISO: string, durationMin?: number): Promise<Appointment> {
  await requireRole('medico', 'recepcion', 'admin');
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('appointments')
    .update({
      scheduled_at: newISO,
      ...(durationMin ? { duration_min: durationMin } : {}),
      status: 'por_confirmar',
    })
    .eq('id', id)
    .select()
    .single();
  if (error) throw error;
  return data;
}
