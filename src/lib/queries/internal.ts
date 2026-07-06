'use server';
// lib/queries/internal.ts — Tablero interno (tareas + mensajes) médico ↔ recepción.
import { createClient } from '@/lib/supabase/server';
import { requireRole } from '@/lib/auth';
import type { InternalNote, InternalNoteKind } from '@/types/database.types';

export type InternalNoteWithPatient = InternalNote & {
  patient: { first_name: string; last_name: string } | null;
};

export type InternalNoteInput = {
  kind: InternalNoteKind;
  body: string;
  target_role?: string | null;
  patient_id?: string | null;
};

export async function listInternalNotes(): Promise<InternalNoteWithPatient[]> {
  await requireRole('medico', 'recepcion', 'admin');
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('internal_notes')
    .select('*, patient:patients_basic(first_name, last_name)')
    .order('created_at', { ascending: false })
    .limit(200);
  if (error) throw error;
  return data as unknown as InternalNoteWithPatient[];
}

export async function createInternalNote(input: InternalNoteInput): Promise<InternalNote> {
  const profile = await requireRole('medico', 'recepcion', 'admin');
  const body = input.body.trim();
  if (body.length < 2) throw new Error('Escribe el contenido');
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('internal_notes')
    .insert({
      kind: input.kind,
      body,
      target_role: input.target_role ?? null,
      patient_id: input.patient_id ?? null,
      author_name: profile.full_name,
      created_by: profile.id,
    })
    .select()
    .single();
  if (error) throw error;
  return data;
}

export async function toggleTaskDone(id: string, done: boolean): Promise<InternalNote> {
  await requireRole('medico', 'recepcion', 'admin');
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('internal_notes')
    .update({ is_done: done, done_at: done ? new Date().toISOString() : null })
    .eq('id', id)
    .select()
    .single();
  if (error) throw error;
  return data;
}

export async function deleteInternalNote(id: string): Promise<void> {
  await requireRole('medico', 'recepcion', 'admin');
  const supabase = await createClient();
  const { error } = await supabase.from('internal_notes').delete().eq('id', id);
  if (error) throw error;
}

/** Contadores para el badge del panel/nav: tareas abiertas y mensajes de hoy. */
export async function getInternalCounts(): Promise<{ openTasks: number; messages: number }> {
  await requireRole('medico', 'recepcion', 'admin');
  const supabase = await createClient();
  const { count: openTasks } = await supabase
    .from('internal_notes')
    .select('id', { count: 'exact', head: true })
    .eq('kind', 'tarea')
    .eq('is_done', false);
  const { count: messages } = await supabase
    .from('internal_notes')
    .select('id', { count: 'exact', head: true })
    .eq('kind', 'mensaje');
  return { openTasks: openTasks ?? 0, messages: messages ?? 0 };
}
