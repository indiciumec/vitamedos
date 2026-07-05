'use server';
// lib/queries/patients.ts
import { createClient } from '@/lib/supabase/server';
import { requireRole } from '@/lib/auth';
import { patientSchema, type PatientInput } from '@/lib/validators';
import type { Patient, PatientBasic } from '@/types/database.types';

/** Búsqueda unificada: cédula, nombre (trigram) o teléfono. */
export async function searchPatients(term: string, limit = 10): Promise<PatientBasic[]> {
  const supabase = await createClient();
  const q = term.trim();
  if (q.length < 2) return [];

  const { data, error } = await supabase
    .from('patients_basic')
    .select('*')
    .or(
      `identification_number.ilike.%${q}%,` +
      `first_name.ilike.%${q}%,` +
      `last_name.ilike.%${q}%,` +
      `phone.ilike.%${q}%`
    )
    .limit(limit);

  if (error) throw error;
  return data;
}

/** Ficha completa (solo médico). Registra el acceso en auditoría. */
export async function getPatientClinical(patientId: string): Promise<Patient> {
  await requireRole('medico');
  const supabase = await createClient();

  const { data, error } = await supabase
    .from('patients')
    .select('*')
    .eq('id', patientId)
    .single();
  if (error) throw error;

  // Auditoría de lectura de historia clínica
  await supabase.rpc('log_clinical_access', { p_patient: patientId });
  return data;
}

export async function createPatient(input: PatientInput): Promise<Patient> {
  await requireRole('medico', 'recepcion');
  const parsed = patientSchema.parse(input);
  const supabase = await createClient();

  const { data, error } = await supabase
    .from('patients')
    .insert({
      ...parsed,
      email: parsed.email || null,
      data_consent_date: parsed.data_consent_signed ? new Date().toISOString() : null,
    })
    .select()
    .single();

  if (error) {
    if (error.code === '23505') throw new Error('Ya existe un paciente con esa identificación');
    throw error;
  }
  return data;
}

export async function updatePatient(id: string, input: Partial<PatientInput>): Promise<Patient> {
  await requireRole('medico', 'recepcion');
  const supabase = await createClient();

  const { data, error } = await supabase
    .from('patients')
    .update(input)
    .eq('id', id)
    .select()
    .single();
  if (error) throw error;
  return data;
}
