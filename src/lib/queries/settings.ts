'use server';
// lib/queries/settings.ts — perfil del consultorio (fila singleton id=1)
import { createClient } from '@/lib/supabase/server';
import { requireRole } from '@/lib/auth';
import type { ClinicSettings } from '@/types/database.types';

export async function getClinicSettings(): Promise<ClinicSettings> {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('clinic_settings')
    .select('*')
    .eq('id', 1)
    .single();
  if (error) throw error;
  return data;
}

export async function updateClinicSettings(
  patch: Partial<Omit<ClinicSettings, 'id' | 'updated_at'>>
): Promise<ClinicSettings> {
  await requireRole('medico', 'admin');
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('clinic_settings')
    .update(patch)
    .eq('id', 1)
    .select()
    .single();
  if (error) throw error;
  return data;
}
