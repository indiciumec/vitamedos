'use server';
// lib/queries/extra.ts — lecturas de apoyo para las pantallas del MVP
// (complementa la capa entregada sin modificarla)
import { createClient } from '@/lib/supabase/server';
import { requireRole } from '@/lib/auth';
import type {
  Consultation, DocumentTemplate, MedicalDocument, PatientBasic,
  Payment, Prescription, Service,
} from '@/types/database.types';
import type { DrugWithBrands } from '@/lib/queries/prescriptions';

export type WithPatientName = { patient: { first_name: string; last_name: string } };

export async function getPatientBasic(id: string): Promise<PatientBasic | null> {
  const supabase = await createClient();
  const { data } = await supabase.from('patients_basic').select('*').eq('id', id).single();
  return data ?? null;
}

export async function getServices(): Promise<Service[]> {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('services').select('*').eq('is_active', true).order('name');
  if (error) throw error;
  return data;
}

/** Pagos de un paciente (para el timeline de la ficha). Médico/admin lectura. */
export async function getPatientPayments(patientId: string): Promise<Payment[]> {
  await requireRole('medico', 'admin', 'recepcion');
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('payments')
    .select('*')
    .eq('patient_id', patientId)
    .order('created_at', { ascending: false });
  if (error) throw error;
  return data;
}

export async function getConsultation(id: string): Promise<Consultation> {
  await requireRole('medico');
  const supabase = await createClient();
  const { data, error } = await supabase.from('consultations').select('*').eq('id', id).single();
  if (error) throw error;
  return data;
}

/** Borradores abiertos del médico actual, para retomarlos desde /consulta. */
export async function listMyDrafts(): Promise<(Consultation & WithPatientName)[]> {
  const profile = await requireRole('medico');
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('consultations')
    .select('*, patient:patients_basic!inner(first_name, last_name)')
    .eq('doctor_id', profile.id)
    .eq('status', 'borrador')
    .order('created_at', { ascending: false });
  if (error) throw error;
  return data as unknown as (Consultation & WithPatientName)[];
}

export async function listRecentPrescriptions(limit = 15): Promise<(Prescription & WithPatientName)[]> {
  await requireRole('medico');
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('prescriptions')
    .select('*, patient:patients_basic!inner(first_name, last_name)')
    .order('issued_at', { ascending: false })
    .limit(limit);
  if (error) throw error;
  return data as unknown as (Prescription & WithPatientName)[];
}

export async function getPatientPrescriptions(patientId: string): Promise<Prescription[]> {
  await requireRole('medico');
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('prescriptions')
    .select('*')
    .eq('patient_id', patientId)
    .order('issued_at', { ascending: false });
  if (error) throw error;
  return data;
}

export async function getDocument(id: string): Promise<MedicalDocument> {
  await requireRole('medico');
  const supabase = await createClient();
  const { data, error } = await supabase.from('medical_documents').select('*').eq('id', id).single();
  if (error) throw error;
  return data;
}

export async function listRecentDocuments(limit = 15): Promise<(MedicalDocument & WithPatientName)[]> {
  await requireRole('medico');
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('medical_documents')
    .select('*, patient:patients_basic!inner(first_name, last_name)')
    .order('issued_at', { ascending: false })
    .limit(limit);
  if (error) throw error;
  return data as unknown as (MedicalDocument & WithPatientName)[];
}

export async function getDayPayments(fromISO: string, toISO: string): Promise<(Payment & WithPatientName)[]> {
  await requireRole('medico', 'recepcion', 'admin');
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('payments')
    .select('*, patient:patients_basic!inner(first_name, last_name)')
    .gte('created_at', fromISO)
    .lt('created_at', toISO)
    .order('created_at', { ascending: false });
  if (error) throw error;
  return data as unknown as (Payment & WithPatientName)[];
}

export async function listDrugsWithBrands(): Promise<DrugWithBrands[]> {
  await requireRole('medico', 'admin');
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('drug_catalog')
    .select('*, brands:commercial_brands(*)')
    .order('generic_name');
  if (error) throw error;
  return data as unknown as DrugWithBrands[];
}

/** Alta/edición de plantillas de documentos (matriz: medico RW, admin plantillas). */
export async function upsertTemplate(
  tpl: Partial<DocumentTemplate> & Pick<DocumentTemplate, 'doc_type' | 'name' | 'body_template'>
): Promise<DocumentTemplate> {
  await requireRole('medico', 'admin');
  const supabase = await createClient();
  const { data, error } = await supabase.from('document_templates').upsert(tpl).select().single();
  if (error) throw error;
  return data;
}

export async function getProfileName(id: string): Promise<string> {
  const supabase = await createClient();
  const { data } = await supabase.from('profiles').select('full_name').eq('id', id).single();
  return data?.full_name ?? '';
}
