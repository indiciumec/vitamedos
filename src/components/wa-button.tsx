'use client';

import { waLink } from '@/lib/whatsapp';
import { logCommunicationAction } from '@/lib/actions';
import type { CommunicationKind } from '@/types/database.types';

type LogInfo = {
  patientId: string;
  kind: CommunicationKind;
  appointmentId?: string | null;
  consultationId?: string | null;
};

type Props = {
  phone: string | null | undefined;
  message?: string;
  label?: string;
  compact?: boolean;
  /** Si viene, registra el contacto en la bitácora (CRM) al abrir WhatsApp. */
  log?: LogInfo;
};

/** Botón pill verde WhatsApp. Retorna null si el número no es un celular EC válido. */
export default function WAButton({ phone, message, label, compact, log }: Props) {
  const href = waLink(phone, message);
  if (!href) return null;

  function handleClick(e: React.MouseEvent) {
    e.stopPropagation();
    if (log) {
      // Fire-and-forget: no bloquea la apertura de WhatsApp
      void logCommunicationAction({
        patient_id: log.patientId,
        kind: log.kind,
        message_snapshot: message ?? null,
        appointment_id: log.appointmentId ?? null,
        consultation_id: log.consultationId ?? null,
      });
    }
  }

  return (
    <a
      href={href}
      target="_blank"
      rel="noopener noreferrer"
      onClick={handleClick}
      className={`inline-flex items-center gap-1 rounded-full font-medium ${
        compact ? 'px-2.5 py-0.5 text-xs' : 'px-4 py-2 text-sm'
      }`}
      style={{ background: 'rgba(37,211,102,.14)', color: '#128c4b' }}
    >
      <svg viewBox="0 0 24 24" width={compact ? 12 : 15} height={compact ? 12 : 15} fill="currentColor" aria-hidden>
        <path d="M12 2a10 10 0 0 0-8.6 15.1L2 22l5-1.3A10 10 0 1 0 12 2Zm5.3 14.1c-.2.6-1.3 1.2-1.8 1.2-.5.1-1 .2-3.3-.7-2.8-1.1-4.6-4-4.7-4.2-.1-.2-1.1-1.5-1.1-2.9s.7-2 1-2.3c.2-.3.5-.3.7-.3h.5c.2 0 .4 0 .6.5s.8 1.9.8 2c.1.1.1.3 0 .5-.3.6-.7.9-.5 1.2.7 1.2 1.6 2 2.8 2.6.3.2.5.1.7-.1l.9-1c.2-.3.4-.2.7-.1l2.1 1c.3.2.5.2.6.4 0 .1 0 .7-.2 1.2Z" />
      </svg>
      {label ?? 'WhatsApp'}
    </a>
  );
}
