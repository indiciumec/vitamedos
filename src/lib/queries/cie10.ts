'use server';
// lib/queries/cie10.ts — búsqueda en el catálogo CIE-10 para el diagnóstico.
import { createClient } from '@/lib/supabase/server';
import { requireRole } from '@/lib/auth';

export type Cie10 = { code: string; description: string };

/** Busca por código (prefijo) o por descripción. Escribir 2+ caracteres. */
export async function searchCie10(term: string): Promise<Cie10[]> {
  await requireRole('medico', 'admin');
  const q = term.trim().replace(/[,()]/g, ' ').trim(); // evita romper el filtro .or
  if (q.length < 2) return [];
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('cie10')
    .select('code, description')
    .or(`code.ilike.${q}%,description.ilike.%${q}%`)
    .order('code', { ascending: true })
    .limit(15);
  if (error) throw error;
  return data ?? [];
}
