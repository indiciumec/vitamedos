'use server';
// lib/queries/consultations.ts — solo rol medico (RLS + requireRole)
import { createClient } from '@/lib/supabase/server';
import { requireRole } from '@/lib/auth';
import { consultationSchema, type ConsultationInput } from '@/lib/validators';
import type { Consultation } from '@/types/database.types';

export async function getPatientConsultations(patientId: string): Promise<Consultation[]> {
  await requireRole('medico');
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('consultations')
    .select('*')
    .eq('patient_id', patientId)
    .order('created_at', { ascending: false });
  if (error) throw error;
  return data;
}

export async function createDraftConsultation(input: ConsultationInput): Promise<Consultation> {
  const profile = await requireRole('medico');
  const parsed = consultationSchema.parse(input);
  const supabase = await createClient();

  // IMC calculado si hay peso y talla
  const vs = parsed.vital_signs;
  if (vs.peso && vs.talla) {
    vs.imc = Math.round((vs.peso / Math.pow(vs.talla / 100, 2)) * 10) / 10;
  }

  const { data, error } = await supabase
    .from('consultations')
    .insert({ ...parsed, vital_signs: vs, doctor_id: profile.id, status: 'borrador' })
    .select()
    .single();
  if (error) throw error;

  // Si viene de una cita, moverla a en_consulta
  if (parsed.appointment_id) {
    await supabase
      .from('appointments')
      .update({ status: 'en_consulta' })
      .eq('id', parsed.appointment_id);
  }
  return data;
}

export async function updateDraftConsultation(
  id: string,
  input: Partial<ConsultationInput>
): Promise<Consultation> {
  await requireRole('medico');
  const supabase = await createClient();
  // El trigger de BD bloquea si no está en borrador; aquí solo propagamos el error legible
  const { data, error } = await supabase
    .from('consultations')
    .update(input)
    .eq('id', id)
    .eq('status', 'borrador')
    .select()
    .single();
  if (error) throw new Error('Solo se pueden editar consultas en borrador');
  return data;
}

/** Cierre: la consulta queda inmutable (trigger de BD). */
export async function closeConsultation(id: string): Promise<Consultation> {
  await requireRole('medico');
  const supabase = await createClient();

  const { data, error } = await supabase
    .from('consultations')
    .update({ status: 'cerrada', closed_at: new Date().toISOString() })
    .eq('id', id)
    .eq('status', 'borrador')
    .select()
    .single();
  if (error) throw new Error('No se pudo cerrar la consulta (¿ya está cerrada?)');

  if (data.appointment_id) {
    await supabase
      .from('appointments')
      .update({ status: 'atendida' })
      .eq('id', data.appointment_id);
  }
  return data;
}

/**
 * Enmienda: crea una nueva consulta vinculada y marca la original como 'enmendada'.
 * Nunca se edita la consulta cerrada.
 */
export async function amendConsultation(
  originalId: string,
  input: ConsultationInput,
  amendmentNote: string
): Promise<Consultation> {
  const profile = await requireRole('medico');
  const parsed = consultationSchema.parse(input);
  const supabase = await createClient();

  const { data: amendment, error: e1 } = await supabase
    .from('consultations')
    .insert({ ...parsed, doctor_id: profile.id, status: 'borrador' })
    .select()
    .single();
  if (e1) throw e1;

  const { error: e2 } = await supabase
    .from('consultations')
    .update({ status: 'enmendada', amended_by_id: amendment.id, amendment_note: amendmentNote })
    .eq('id', originalId);
  if (e2) throw e2;

  return amendment;
}
