// lib/validators.ts — Zod schemas para formularios y Server Actions
import { z } from 'zod';

// Cédula ecuatoriana: 10 dígitos con dígito verificador módulo 10
export function validateCedulaEC(cedula: string): boolean {
  if (!/^\d{10}$/.test(cedula)) return false;
  const provincia = parseInt(cedula.slice(0, 2), 10);
  if (provincia < 1 || (provincia > 24 && provincia !== 30)) return false;
  const digits = cedula.split('').map(Number);
  const verifier = digits.pop()!;
  const sum = digits.reduce((acc, d, i) => {
    let v = i % 2 === 0 ? d * 2 : d;
    if (v > 9) v -= 9;
    return acc + v;
  }, 0);
  return (10 - (sum % 10)) % 10 === verifier;
}

export const patientSchema = z.object({
  identification_type: z.enum(['cedula', 'pasaporte', 'ruc']),
  identification_number: z.string().min(5).max(20),
  first_name: z.string().min(2).max(80),
  last_name: z.string().min(2).max(80),
  birth_date: z.string().date().nullable().optional(),
  sex: z.enum(['M', 'F', 'O']).nullable().optional(),
  phone: z.string().max(20).nullable().optional(),
  whatsapp: z.string().max(20).nullable().optional(),
  email: z.string().email().nullable().optional().or(z.literal('')),
  address: z.string().max(200).nullable().optional(),
  sector: z.string().max(80).nullable().optional(),
  emergency_contact_name: z.string().max(120).nullable().optional(),
  emergency_contact_phone: z.string().max(20).nullable().optional(),
  allergies: z.string().max(1000).nullable().optional(),
  personal_history: z.string().max(4000).nullable().optional(),
  family_history: z.string().max(4000).nullable().optional(),
  current_medication: z.string().max(2000).nullable().optional(),
  notes: z.string().max(2000).nullable().optional(),
  data_consent_signed: z.boolean().default(false),
}).refine(
  (d) => d.identification_type !== 'cedula' || validateCedulaEC(d.identification_number),
  { message: 'Cédula ecuatoriana inválida', path: ['identification_number'] }
);

export const appointmentSchema = z.object({
  patient_id: z.string().uuid(),
  service_id: z.string().uuid().nullable().optional(),
  scheduled_at: z.string().datetime({ offset: true }),
  duration_min: z.number().int().min(5).max(240).default(30),
  reason: z.string().max(300).nullable().optional(),
  notes: z.string().max(500).nullable().optional(),
});

export const vitalSignsSchema = z.object({
  pa: z.string().regex(/^\d{2,3}\/\d{2,3}$/, 'Formato: 120/80').optional(),
  fc: z.number().min(20).max(250).optional(),
  fr: z.number().min(5).max(80).optional(),
  temp: z.number().min(30).max(45).optional(),
  spo2: z.number().min(50).max(100).optional(),
  peso: z.number().min(0.5).max(400).optional(),
  talla: z.number().min(30).max(250).optional(),
  imc: z.number().optional(),
}).partial();

export const consultationSchema = z.object({
  patient_id: z.string().uuid(),
  appointment_id: z.string().uuid().nullable().optional(),
  reason: z.string().min(2).max(500),
  current_illness: z.string().max(4000).nullable().optional(),
  vital_signs: vitalSignsSchema.default({}),
  physical_exam: z.string().max(4000).nullable().optional(),
  diagnosis_code: z.string().max(10).nullable().optional(),      // CIE-10
  diagnosis_text: z.string().max(500).nullable().optional(),
  treatment_plan: z.string().max(4000).nullable().optional(),
  recommendations: z.string().max(2000).nullable().optional(),
  requested_exams: z.string().max(2000).nullable().optional(),
  next_control_date: z.string().date().nullable().optional(),
});

// REGLA DCI: generic_name_snapshot obligatorio y no vacío
export const prescriptionItemSchema = z.object({
  drug_catalog_id: z.string().uuid().nullable().optional(),
  generic_name_snapshot: z.string().trim().min(2, 'DCI/genérico obligatorio'),
  concentration: z.string().max(50).nullable().optional(),
  pharmaceutical_form: z.string().max(50).nullable().optional(),
  route: z.string().max(30).nullable().optional(),
  quantity: z.string().max(50).nullable().optional(),
  dose: z.string().max(100).nullable().optional(),
  frequency: z.string().max(100).nullable().optional(),
  duration: z.string().max(100).nullable().optional(),
  instructions: z.string().max(500).nullable().optional(),
  optional_commercial_brand: z.string().max(150).nullable().optional(),
});

export const prescriptionSchema = z.object({
  patient_id: z.string().uuid(),
  consultation_id: z.string().uuid().nullable().optional(),
  diagnosis_code: z.string().max(10).nullable().optional(),
  diagnosis_text: z.string().max(500).nullable().optional(),
  items: z.array(prescriptionItemSchema).min(1, 'La receta requiere al menos un medicamento'),
});

export const paymentSchema = z.object({
  patient_id: z.string().uuid(),
  consultation_id: z.string().uuid().nullable().optional(),
  service_id: z.string().uuid().nullable().optional(),
  amount: z.number().min(0).max(10000),
  method: z.enum(['efectivo', 'transferencia', 'tarjeta', 'cortesia', 'pendiente']),
  status: z.enum(['pagado', 'pendiente', 'cortesia', 'anulado']).default('pagado'),
  notes: z.string().max(300).nullable().optional(),
});

export const documentSchema = z.object({
  doc_type: z.enum([
    'certificado_medico', 'reposo_medico', 'constancia_asistencia',
    'solicitud_examenes', 'referencia_especialista', 'informe_clinico',
    'consentimiento_informado', 'consentimiento_datos',
  ]),
  patient_id: z.string().uuid(),
  consultation_id: z.string().uuid().nullable().optional(),
  body_final: z.string().min(10).max(10000),
});

export type PatientInput = z.infer<typeof patientSchema>;
export type AppointmentInput = z.infer<typeof appointmentSchema>;
export type ConsultationInput = z.infer<typeof consultationSchema>;
export type PrescriptionInput = z.infer<typeof prescriptionSchema>;
export type PaymentInput = z.infer<typeof paymentSchema>;
export type DocumentInput = z.infer<typeof documentSchema>;
