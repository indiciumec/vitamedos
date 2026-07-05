'use server';
// lib/queries/documents.ts
import { createClient } from '@/lib/supabase/server';
import { requireRole } from '@/lib/auth';
import { documentSchema, type DocumentInput } from '@/lib/validators';
import type { MedicalDocument, DocumentTemplate, DocumentType } from '@/types/database.types';

export async function getTemplates(docType?: DocumentType): Promise<DocumentTemplate[]> {
  await requireRole('medico', 'admin');
  const supabase = await createClient();
  let q = supabase.from('document_templates').select('*').eq('is_active', true);
  if (docType) q = q.eq('doc_type', docType);
  const { data, error } = await q;
  if (error) throw error;
  return data;
}

/**
 * Resuelve placeholders {{clave}} de una plantilla.
 * Claves estándar: paciente, cedula, edad, fecha, diagnostico, dias_reposo, medico.
 */
export async function resolveTemplate(
  templateId: string,
  vars: Record<string, string>
): Promise<string> {
  await requireRole('medico');
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('document_templates')
    .select('body_template')
    .eq('id', templateId)
    .single();
  if (error) throw error;

  return data.body_template.replace(/\{\{(\w+)\}\}/g, (_, key) => vars[key] ?? `{{${key}}}`);
}

/** Emite el documento con el texto final ya editado por la doctora. */
export async function issueDocument(input: DocumentInput): Promise<MedicalDocument> {
  const profile = await requireRole('medico');
  const parsed = documentSchema.parse(input);
  const supabase = await createClient();

  const { data, error } = await supabase
    .from('medical_documents')
    .insert({ ...parsed, issued_by: profile.id })
    .select()
    .single();
  if (error) throw error;
  return data;
}

export async function getPatientDocuments(patientId: string): Promise<MedicalDocument[]> {
  await requireRole('medico');
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('medical_documents')
    .select('*')
    .eq('patient_id', patientId)
    .order('issued_at', { ascending: false });
  if (error) throw error;
  return data;
}
