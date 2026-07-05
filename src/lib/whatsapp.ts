// lib/whatsapp.ts — enlaces wa.me (sin Cloud API).
// REGLA: mensajes informativos únicamente; NUNCA diagnóstico ni medicación por chat.

/**
 * Normaliza un número ecuatoriano a E.164 sin '+':
 *  '0991234567'  -> '593991234567'
 *  '099 123 4567'-> '593991234567'
 *  '+593991234567' / '593991234567' -> '593991234567'
 * Retorna null si no es un celular ecuatoriano válido (09XXXXXXXX ó 5939XXXXXXXX).
 */
export function toE164EC(phone: string | null | undefined): string | null {
  if (!phone) return null;
  const digits = phone.replace(/\D/g, '');
  if (/^09\d{8}$/.test(digits)) return `593${digits.slice(1)}`;
  if (/^5939\d{8}$/.test(digits)) return digits;
  return null;
}

export function waLink(phone: string | null | undefined, message?: string): string | null {
  const e164 = toE164EC(phone);
  if (!e164) return null;
  const text = message ? `?text=${encodeURIComponent(message)}` : '';
  return `https://wa.me/${e164}${text}`;
}

type TplArgs = {
  clinica: string;
  nombre?: string;
  fecha?: string;
  hora?: string;
  dias?: number;
};

export const WA_TEMPLATES = {
  confirmacion: ({ clinica, nombre, fecha, hora }: TplArgs) =>
    `Hola ${nombre ?? ''}, le saludamos de ${clinica}. Le recordamos su cita el ${fecha} a las ${hora}. ` +
    `Responda 1 para confirmar o 2 para reagendar. ¡Gracias!`,

  recordatorio: ({ clinica, nombre, hora }: TplArgs) =>
    `Hola ${nombre ?? ''}, le saludamos de ${clinica}. Le recordamos su cita de HOY a las ${hora}. Le esperamos.`,

  postconsulta: ({ clinica, nombre }: TplArgs) =>
    `Hola ${nombre ?? ''}, gracias por su visita a ${clinica}. ` +
    `Recuerde seguir las indicaciones de su receta. Si tiene alguna molestia inusual, contáctenos por este medio.`,

  control: ({ clinica, nombre, dias }: TplArgs) =>
    `Hola ${nombre ?? ''}, le saludamos de ${clinica}. ` +
    `Su control está sugerido en ${dias ?? '—'} día(s). Escríbanos para agendar su cita. ¡Gracias!`,
} as const;
