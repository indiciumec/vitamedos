'use server';
// lib/queries/prescriptions.ts — REGLA DCI aplicada en 3 capas: Zod, esta acción, y CHECK en BD
import { createClient } from '@/lib/supabase/server';
import { requireRole } from '@/lib/auth';
import { prescriptionSchema, type PrescriptionInput } from '@/lib/validators';
import type {
  Prescription, PrescriptionItem, DrugCatalogItem, CommercialBrand,
} from '@/types/database.types';

export type FullPrescription = Prescription & { items: PrescriptionItem[] };
export type DrugWithBrands = DrugCatalogItem & { brands: CommercialBrand[] };

/** Autocompletar del vademécum: escribir 2+ letras del genérico. */
export async function searchVademecum(term: string, limit = 8): Promise<DrugWithBrands[]> {
  await requireRole('medico');
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('drug_catalog')
    .select('*, brands:commercial_brands(*)')
    .ilike('generic_name', `%${term.trim()}%`)
    .eq('is_active', true)
    .limit(limit);
  if (error) throw error;
  return data as unknown as DrugWithBrands[];
}

/**
 * Emite receta. Copia alergias del paciente como snapshot (regla de seguridad clínica:
 * la receta refleja las alergias conocidas AL MOMENTO de emitir).
 */
export async function issuePrescription(input: PrescriptionInput): Promise<FullPrescription> {
  const profile = await requireRole('medico');
  const parsed = prescriptionSchema.parse(input); // valida DCI en cada item
  const supabase = await createClient();

  const { data: patient, error: eP } = await supabase
    .from('patients')
    .select('allergies')
    .eq('id', parsed.patient_id)
    .single();
  if (eP) throw eP;

  const { data: rx, error: e1 } = await supabase
    .from('prescriptions')
    .insert({
      patient_id: parsed.patient_id,
      consultation_id: parsed.consultation_id ?? null,
      doctor_id: profile.id,
      diagnosis_code: parsed.diagnosis_code ?? null,
      diagnosis_text: parsed.diagnosis_text ?? null,
      allergies_snapshot: patient.allergies,
    })
    .select()
    .single();
  if (e1) throw e1;

  const { data: items, error: e2 } = await supabase
    .from('prescription_items')
    .insert(parsed.items.map((i) => ({ ...i, prescription_id: rx.id })))
    .select();
  if (e2) {
    // rollback manual: anular cabecera huérfana
    await supabase.from('prescriptions').update({ status: 'anulada' }).eq('id', rx.id);
    throw e2;
  }

  return { ...rx, items };
}

export async function getPrescription(id: string): Promise<FullPrescription> {
  await requireRole('medico');
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('prescriptions')
    .select('*, items:prescription_items(*)')
    .eq('id', id)
    .single();
  if (error) throw error;
  return data as unknown as FullPrescription;
}

export async function voidPrescription(id: string): Promise<void> {
  await requireRole('medico');
  const supabase = await createClient();
  const { error } = await supabase
    .from('prescriptions')
    .update({ status: 'anulada' })
    .eq('id', id);
  if (error) throw error;
}

// ---------- Vademécum CRUD ----------
export async function upsertDrug(
  drug: Partial<DrugCatalogItem> & { generic_name: string }
): Promise<DrugCatalogItem> {
  await requireRole('medico', 'admin');
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('drug_catalog')
    .upsert(drug)
    .select()
    .single();
  if (error) throw error;
  return data;
}

export async function addBrand(
  drugCatalogId: string,
  brandName: string,
  isPreferred = false
): Promise<CommercialBrand> {
  await requireRole('medico', 'admin');
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('commercial_brands')
    .insert({
      drug_catalog_id: drugCatalogId,
      brand_name: brandName,
      is_preferred: isPreferred,
      is_active: true,
      laboratory: null,
      notes: null,
    })
    .select()
    .single();
  if (error) throw error;
  return data;
}
