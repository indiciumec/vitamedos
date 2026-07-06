'use server';
// lib/queries/communications.ts — CRM WhatsApp sobre wa.me.
// Registra contactos iniciados (bitácora) y arma la cola "a quién contactar hoy".
// Los enlaces wa.me no confirman entrega; el estado se marca manualmente.
import { createClient } from '@/lib/supabase/server';
import { getCurrentProfile, requireRole } from '@/lib/auth';
import { addDays, dayRange, todayEC } from '@/lib/utils';
import type {
  Communication, CommunicationKind, CommunicationStatus,
} from '@/types/database.types';

export type CommunicationInput = {
  patient_id: string;
  kind: CommunicationKind;
  message_snapshot?: string | null;
  appointment_id?: string | null;
  consultation_id?: string | null;
  follow_up_date?: string | null;
  notes?: string | null;
};

export async function logCommunication(input: CommunicationInput): Promise<Communication> {
  const profile = await requireRole('medico', 'recepcion', 'admin');
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('communications')
    .insert({
      patient_id: input.patient_id,
      channel: 'whatsapp',
      kind: input.kind,
      message_snapshot: input.message_snapshot ?? null,
      status: 'enviado',
      appointment_id: input.appointment_id ?? null,
      consultation_id: input.consultation_id ?? null,
      follow_up_date: input.follow_up_date ?? null,
      notes: input.notes ?? null,
      created_by: profile.id,
    })
    .select()
    .single();
  if (error) throw error;
  return data;
}

export async function updateCommunicationStatus(
  id: string,
  status: CommunicationStatus
): Promise<Communication> {
  await requireRole('medico', 'recepcion', 'admin');
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('communications')
    .update({ status })
    .eq('id', id)
    .select()
    .single();
  if (error) throw error;
  return data;
}

export async function getPatientCommunications(patientId: string): Promise<Communication[]> {
  await requireRole('medico', 'recepcion', 'admin');
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('communications')
    .select('*')
    .eq('patient_id', patientId)
    .order('created_at', { ascending: false });
  if (error) throw error;
  return data;
}

export type CommunicationWithPatient = Communication & {
  patient: { first_name: string; last_name: string; phone: string | null; whatsapp: string | null };
};

export async function listRecentCommunications(limit = 30): Promise<CommunicationWithPatient[]> {
  await requireRole('medico', 'recepcion', 'admin');
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('communications')
    .select('*, patient:patients_basic!inner(first_name, last_name, phone, whatsapp)')
    .order('created_at', { ascending: false })
    .limit(limit);
  if (error) throw error;
  return data as unknown as CommunicationWithPatient[];
}

// ---------- Cola de contactos "a quién contactar hoy" ----------
export type QueueItem = {
  patientId: string;
  patientName: string;
  firstName: string;
  phone: string | null;
  kind: CommunicationKind;
  reason: string;
  refDate: string;
  appointmentId: string | null;
  consultationId: string | null;
  done: boolean;
};

export type ContactQueue = {
  confirmaciones: QueueItem[];
  controles: QueueItem[];
  seguimientos: QueueItem[];
  role: string;
};

const pickPhone = (p: { phone: string | null; whatsapp?: string | null }) => p.whatsapp ?? p.phone;

export async function getContactQueue(): Promise<ContactQueue> {
  const profile = await getCurrentProfile();
  if (!profile) throw new Error('No autorizado');
  const supabase = await createClient();

  const hoy = todayEC();
  const manana = addDays(hoy, 1);
  const { from: mFrom, to: mTo } = dayRange(manana);

  // Comunicaciones recientes para marcar "ya contactado"
  const { data: recentComms } = await supabase
    .from('communications')
    .select('kind, appointment_id, consultation_id')
    .gte('created_at', dayRange(addDays(hoy, -10)).from);
  const doneAppt = new Set(
    (recentComms ?? []).filter((c) => c.appointment_id).map((c) => `${c.kind}:${c.appointment_id}`)
  );
  const doneConsult = new Set(
    (recentComms ?? []).filter((c) => c.consultation_id).map((c) => `${c.kind}:${c.consultation_id}`)
  );

  // 1) Confirmaciones — citas de mañana por confirmar/confirmadas (médico y recepción)
  const confirmaciones: QueueItem[] = [];
  const { data: citas } = await supabase
    .from('appointments')
    .select('id, scheduled_at, status, patient:patients_basic!inner(id, first_name, last_name, phone, whatsapp)')
    .gte('scheduled_at', mFrom)
    .lt('scheduled_at', mTo)
    .in('status', ['por_confirmar', 'confirmada'])
    .order('scheduled_at');
  for (const c of (citas ?? []) as unknown as Array<{
    id: string; scheduled_at: string;
    patient: { id: string; first_name: string; last_name: string; phone: string | null; whatsapp: string | null };
  }>) {
    const hora = new Date(c.scheduled_at).toLocaleTimeString('es-EC', {
      hour: '2-digit', minute: '2-digit', hour12: false, timeZone: 'America/Guayaquil',
    });
    confirmaciones.push({
      patientId: c.patient.id,
      patientName: `${c.patient.first_name} ${c.patient.last_name}`,
      firstName: c.patient.first_name,
      phone: pickPhone(c.patient),
      kind: 'confirmacion',
      reason: `Cita mañana a las ${hora}`,
      refDate: c.scheduled_at,
      appointmentId: c.id,
      consultationId: null,
      done: doneAppt.has(`confirmacion:${c.id}`),
    });
  }

  // 2) y 3) requieren leer consultations (solo médico por RLS)
  const controles: QueueItem[] = [];
  const seguimientos: QueueItem[] = [];
  if (profile.role === 'medico') {
    const limite = addDays(hoy, 7);
    const { data: ctrl } = await supabase
      .from('consultations')
      .select('id, next_control_date, patient:patients_basic!inner(id, first_name, last_name, phone, whatsapp)')
      .gte('next_control_date', hoy)
      .lte('next_control_date', limite)
      .order('next_control_date');
    for (const c of (ctrl ?? []) as unknown as Array<{
      id: string; next_control_date: string;
      patient: { id: string; first_name: string; last_name: string; phone: string | null; whatsapp: string | null };
    }>) {
      const dias = Math.max(0, Math.round(
        (new Date(`${c.next_control_date}T12:00:00-05:00`).getTime() -
          new Date(`${hoy}T12:00:00-05:00`).getTime()) / 86400000
      ));
      controles.push({
        patientId: c.patient.id,
        patientName: `${c.patient.first_name} ${c.patient.last_name}`,
        firstName: c.patient.first_name,
        phone: pickPhone(c.patient),
        kind: 'control',
        reason: dias === 0 ? 'Control es hoy' : `Control en ${dias} día(s)`,
        refDate: c.next_control_date,
        appointmentId: null,
        consultationId: c.id,
        done: doneConsult.has(`control:${c.id}`),
      });
    }

    const desdeAyer = dayRange(addDays(hoy, -1)).from;
    const { data: cerradas } = await supabase
      .from('consultations')
      .select('id, closed_at, patient:patients_basic!inner(id, first_name, last_name, phone, whatsapp)')
      .eq('status', 'cerrada')
      .gte('closed_at', desdeAyer)
      .order('closed_at', { ascending: false });
    for (const c of (cerradas ?? []) as unknown as Array<{
      id: string; closed_at: string;
      patient: { id: string; first_name: string; last_name: string; phone: string | null; whatsapp: string | null };
    }>) {
      seguimientos.push({
        patientId: c.patient.id,
        patientName: `${c.patient.first_name} ${c.patient.last_name}`,
        firstName: c.patient.first_name,
        phone: pickPhone(c.patient),
        kind: 'postconsulta',
        reason: 'Consulta reciente — enviar seguimiento',
        refDate: c.closed_at,
        appointmentId: null,
        consultationId: c.id,
        done: doneConsult.has(`postconsulta:${c.id}`),
      });
    }
  }

  return { confirmaciones, controles, seguimientos, role: profile.role };
}
