'use server';
// lib/queries/payments.ts
import { createClient } from '@/lib/supabase/server';
import { requireRole } from '@/lib/auth';
import { paymentSchema, type PaymentInput } from '@/lib/validators';
import type { Payment, PaymentMethod } from '@/types/database.types';

export async function registerPayment(input: PaymentInput): Promise<Payment> {
  const profile = await requireRole('recepcion', 'admin');
  const parsed = paymentSchema.parse(input);
  const supabase = await createClient();

  const { data, error } = await supabase
    .from('payments')
    .insert({
      ...parsed,
      registered_by: profile.id,
      paid_at: parsed.status === 'pagado' ? new Date().toISOString() : null,
    })
    .select()
    .single();
  if (error) throw error;
  return data;
}

export async function settlePending(paymentId: string, method: PaymentMethod): Promise<Payment> {
  await requireRole('recepcion', 'admin');
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('payments')
    .update({ status: 'pagado', method, paid_at: new Date().toISOString() })
    .eq('id', paymentId)
    .eq('status', 'pendiente')
    .select()
    .single();
  if (error) throw new Error('El pago no está en estado pendiente');
  return data;
}

export interface DailyCashReport {
  date: string;
  total: number;
  byMethod: Record<string, number>;
  paymentsCount: number;
  pendingTotal: number;
  pendingCount: number;
}

/** Cierre diario: totales por método + pendientes acumulados. */
export async function getDailyCash(dateISO: string): Promise<DailyCashReport> {
  await requireRole('medico', 'recepcion', 'admin');
  const supabase = await createClient();

  const from = `${dateISO}T00:00:00-05:00`; // Ecuador UTC-5
  const to = `${dateISO}T23:59:59-05:00`;

  const { data: paid, error: e1 } = await supabase
    .from('payments')
    .select('amount, method')
    .eq('status', 'pagado')
    .gte('paid_at', from)
    .lte('paid_at', to);
  if (e1) throw e1;

  const { data: pending, error: e2 } = await supabase
    .from('payments')
    .select('amount')
    .eq('status', 'pendiente');
  if (e2) throw e2;

  const byMethod: Record<string, number> = {};
  let total = 0;
  for (const p of paid) {
    byMethod[p.method] = (byMethod[p.method] ?? 0) + Number(p.amount);
    total += Number(p.amount);
  }

  return {
    date: dateISO,
    total,
    byMethod,
    paymentsCount: paid.length,
    pendingTotal: pending.reduce((s, p) => s + Number(p.amount), 0),
    pendingCount: pending.length,
  };
}

export async function getPendingPayments(): Promise<Payment[]> {
  await requireRole('recepcion', 'admin', 'medico');
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('payments')
    .select('*')
    .eq('status', 'pendiente')
    .order('created_at', { ascending: true });
  if (error) throw error;
  return data;
}
