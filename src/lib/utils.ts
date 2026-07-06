// lib/utils.ts — helpers de fecha (TZ Ecuador -05:00), formato y etiquetas
import type {
  AppointmentStatus, CommunicationKind, CommunicationStatus, ConsultationStatus,
  DocumentType, PaymentMethod, PaymentStatus,
} from '@/types/database.types';

export const EC_OFFSET = '-05:00';
export const EC_TZ = 'America/Guayaquil';

/** Fecha de hoy en Ecuador como YYYY-MM-DD. */
export function todayEC(): string {
  return new Date(Date.now() - 5 * 3600_000).toISOString().slice(0, 10);
}

/** Combina fecha (YYYY-MM-DD) y hora (HH:mm) en ISO con offset de Ecuador. */
export function toOffsetISO(date: string, time: string): string {
  return `${date}T${time}:00${EC_OFFSET}`;
}

/** Rango [00:00, 24:00) de un día de Ecuador, en ISO. */
export function dayRange(dateISO: string): { from: string; to: string } {
  const start = new Date(`${dateISO}T00:00:00${EC_OFFSET}`);
  return { from: start.toISOString(), to: new Date(start.getTime() + 86400_000).toISOString() };
}

export function addDays(dateISO: string, days: number): string {
  const start = new Date(`${dateISO}T00:00:00${EC_OFFSET}`);
  return new Date(start.getTime() + days * 86400_000 + 5 * 3600_000).toISOString().slice(0, 10);
}

/** Lunes a domingo de la semana que contiene la fecha. */
export function weekDays(dateISO: string): string[] {
  const d = new Date(`${dateISO}T00:00:00${EC_OFFSET}`);
  const dow = (d.getUTCDay() + 6) % 7; // getUTCDay sobre las 05:00Z = día calendario EC
  const monday = addDays(dateISO, -dow);
  return Array.from({ length: 7 }, (_, i) => addDays(monday, i));
}

export function formatTime(iso: string): string {
  return new Date(iso).toLocaleTimeString('es-EC', {
    hour: '2-digit', minute: '2-digit', hour12: false, timeZone: EC_TZ,
  });
}

export function formatDate(dateOrISO: string, opts?: Intl.DateTimeFormatOptions): string {
  const iso = dateOrISO.length === 10 ? `${dateOrISO}T12:00:00${EC_OFFSET}` : dateOrISO;
  return new Date(iso).toLocaleDateString('es-EC', {
    day: '2-digit', month: 'short', year: 'numeric', timeZone: EC_TZ, ...opts,
  });
}

export function formatDateLong(dateOrISO: string): string {
  return formatDate(dateOrISO, { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' });
}

export function formatMoney(n: number | string): string {
  return `$${Number(n).toFixed(2)}`;
}

export function calcAge(birthDate: string | null | undefined): number | null {
  if (!birthDate) return null;
  const birth = new Date(`${birthDate}T12:00:00${EC_OFFSET}`);
  const now = new Date();
  let age = now.getFullYear() - birth.getFullYear();
  const m = now.getMonth() - birth.getMonth();
  if (m < 0 || (m === 0 && now.getDate() < birth.getDate())) age--;
  return age;
}

// ---------- Etiquetas y estilos de estado ----------
export const APPT_STATUS_LABELS: Record<AppointmentStatus, string> = {
  solicitada: 'Solicitada',
  por_confirmar: 'Por confirmar',
  confirmada: 'Confirmada',
  en_espera: 'En espera',
  en_consulta: 'En consulta',
  atendida: 'Atendida',
  cancelada: 'Cancelada',
  no_asistio: 'No asistió',
};

export const APPT_STATUS_BADGE: Record<AppointmentStatus, string> = {
  solicitada: 'bg-slate-100 text-slate-700',
  por_confirmar: 'bg-amber-100 text-amber-800',
  confirmada: 'bg-vitamed-100 text-vitamed-800',
  en_espera: 'bg-violet-100 text-violet-800',
  en_consulta: 'bg-blue-100 text-blue-800',
  atendida: 'bg-emerald-100 text-emerald-800',
  cancelada: 'bg-red-100 text-red-700',
  no_asistio: 'bg-orange-100 text-orange-800',
};

/** Espejo de la máquina de estados del servidor (lib/queries/appointments.ts). */
export const APPT_TRANSITIONS: Record<AppointmentStatus, AppointmentStatus[]> = {
  solicitada: ['por_confirmar', 'confirmada', 'cancelada'],
  por_confirmar: ['confirmada', 'cancelada'],
  confirmada: ['en_espera', 'cancelada', 'no_asistio'],
  en_espera: ['en_consulta', 'cancelada'],
  en_consulta: ['atendida'],
  atendida: [],
  cancelada: [],
  no_asistio: [],
};

export const APPT_ACTION_LABELS: Partial<Record<AppointmentStatus, string>> = {
  por_confirmar: 'Por confirmar',
  confirmada: 'Confirmar',
  en_espera: 'Llegó',
  en_consulta: 'En consulta',
  atendida: 'Atendida',
  cancelada: 'Cancelar',
  no_asistio: 'No asistió',
};

export const CONSULT_STATUS_LABELS: Record<ConsultationStatus, string> = {
  borrador: 'Borrador',
  cerrada: 'Cerrada',
  enmendada: 'Enmendada',
  anulada: 'Anulada',
};

export const CONSULT_STATUS_BADGE: Record<ConsultationStatus, string> = {
  borrador: 'bg-amber-100 text-amber-800',
  cerrada: 'bg-emerald-100 text-emerald-800',
  enmendada: 'bg-violet-100 text-violet-800',
  anulada: 'bg-red-100 text-red-700',
};

export const PAYMENT_METHOD_LABELS: Record<PaymentMethod, string> = {
  efectivo: 'Efectivo',
  transferencia: 'Transferencia',
  tarjeta: 'Tarjeta',
  cortesia: 'Cortesía',
  pendiente: 'Pendiente',
};

export const PAYMENT_STATUS_LABELS: Record<PaymentStatus, string> = {
  pagado: 'Pagado',
  pendiente: 'Pendiente',
  cortesia: 'Cortesía',
  anulado: 'Anulado',
};

export const PAYMENT_STATUS_BADGE: Record<PaymentStatus, string> = {
  pagado: 'bg-emerald-100 text-emerald-800',
  pendiente: 'bg-amber-100 text-amber-800',
  cortesia: 'bg-vitamed-100 text-vitamed-800',
  anulado: 'bg-red-100 text-red-700',
};

export const DOC_TYPE_LABELS: Record<DocumentType, string> = {
  certificado_medico: 'Certificado médico',
  reposo_medico: 'Reposo médico',
  constancia_asistencia: 'Constancia de asistencia',
  solicitud_examenes: 'Solicitud de exámenes',
  referencia_especialista: 'Referencia a especialista',
  informe_clinico: 'Informe clínico',
  consentimiento_informado: 'Consentimiento informado',
  consentimiento_datos: 'Consentimiento de datos (LOPDP)',
};

export const COMM_KIND_LABELS: Record<CommunicationKind, string> = {
  confirmacion: 'Confirmación de cita',
  recordatorio: 'Recordatorio',
  postconsulta: 'Seguimiento post-consulta',
  control: 'Aviso de control',
  pago: 'Recordatorio de pago',
  manual: 'Mensaje',
};

export const COMM_STATUS_LABELS: Record<CommunicationStatus, string> = {
  enviado: 'Enviado',
  respondido: 'Respondió',
  confirmado: 'Confirmó',
  sin_respuesta: 'Sin respuesta',
};

export const COMM_STATUS_BADGE: Record<CommunicationStatus, string> = {
  enviado: 'bg-slate-100 text-slate-700',
  respondido: 'bg-blue-100 text-blue-800',
  confirmado: 'bg-emerald-100 text-emerald-800',
  sin_respuesta: 'bg-amber-100 text-amber-800',
};
