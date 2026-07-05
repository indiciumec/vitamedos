// lib/auth.ts — sesión y rol (server-side)
import { createClient } from '@/lib/supabase/server';
import type { Profile, UserRole } from '@/types/database.types';

export async function getCurrentProfile(): Promise<Profile | null> {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return null;

  const { data } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .single();

  return data ?? null;
}

/** Lanza si el usuario no tiene uno de los roles requeridos. Usar al inicio de Server Actions. */
export async function requireRole(...roles: UserRole[]): Promise<Profile> {
  const profile = await getCurrentProfile();
  if (!profile || !profile.is_active || !roles.includes(profile.role)) {
    throw new Error('No autorizado');
  }
  return profile;
}
