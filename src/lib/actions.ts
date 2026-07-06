'use server';
// lib/actions.ts — wrappers seguros para invocar desde componentes cliente.
// Los errores lanzados por Server Actions se enmascaran en producción;
// aquí se convierten en resultados estructurados { ok, data | error }.
import { ZodError } from 'zod';
import * as patients from '@/lib/queries/patients';
import * as appointments from '@/lib/queries/appointments';
import * as consultations from '@/lib/queries/consultations';
import * as prescriptions from '@/lib/queries/prescriptions';
import * as documents from '@/lib/queries/documents';
import * as payments from '@/lib/queries/payments';
import * as extra from '@/lib/queries/extra';
import * as settings from '@/lib/queries/settings';
import * as communications from '@/lib/queries/communications';
import type { CommunicationInput } from '@/lib/queries/communications';
import * as internal from '@/lib/queries/internal';
import type { InternalNoteInput } from '@/lib/queries/internal';
import type { CommunicationStatus } from '@/types/database.types';
import type {
  AppointmentInput, ConsultationInput, DocumentInput, PatientInput, PaymentInput, PrescriptionInput,
} from '@/lib/validators';
import type { AppointmentStatus, DocumentTemplate, DrugCatalogItem, DocumentType, PaymentMethod } from '@/types/database.types';

export type ActionResult<T> =
  | { ok: true; data: T }
  | { ok: false; error: string };

async function safe<T>(fn: () => Promise<T>): Promise<ActionResult<T>> {
  try {
    return { ok: true, data: await fn() };
  } catch (e) {
    if (e instanceof ZodError) {
      const issue = e.issues[0];
      return { ok: false, error: `${issue.path.join('.')}: ${issue.message}` };
    }
    return { ok: false, error: e instanceof Error ? e.message : 'Error inesperado' };
  }
}

// ---------- Pacientes ----------
export async function searchPatientsAction(term: string) {
  return safe(() => patients.searchPatients(term));
}
export async function createPatientAction(input: PatientInput) {
  return safe(() => patients.createPatient(input));
}
export async function updatePatientAction(id: string, input: Partial<PatientInput>) {
  return safe(() => patients.updatePatient(id, input));
}

// ---------- Agenda ----------
export async function createAppointmentAction(input: AppointmentInput) {
  return safe(() => appointments.createAppointment(input));
}
export async function changeAppointmentStatusAction(id: string, next: AppointmentStatus) {
  return safe(() => appointments.changeAppointmentStatus(id, next));
}
export async function rescheduleAction(id: string, newISO: string, durationMin?: number) {
  return safe(() => appointments.reschedule(id, newISO, durationMin));
}

// ---------- Consulta ----------
export async function createDraftConsultationAction(input: ConsultationInput) {
  return safe(() => consultations.createDraftConsultation(input));
}
export async function updateDraftConsultationAction(id: string, input: Partial<ConsultationInput>) {
  return safe(() => consultations.updateDraftConsultation(id, input));
}
export async function closeConsultationAction(id: string) {
  return safe(() => consultations.closeConsultation(id));
}
export async function amendConsultationAction(originalId: string, input: ConsultationInput, note: string) {
  return safe(() => consultations.amendConsultation(originalId, input, note));
}

// ---------- Recetas / Vademécum ----------
export async function searchVademecumAction(term: string) {
  return safe(() => prescriptions.searchVademecum(term));
}
export async function issuePrescriptionAction(input: PrescriptionInput) {
  return safe(() => prescriptions.issuePrescription(input));
}
export async function voidPrescriptionAction(id: string) {
  return safe(() => prescriptions.voidPrescription(id));
}
export async function upsertDrugAction(drug: Partial<DrugCatalogItem> & { generic_name: string }) {
  return safe(() => prescriptions.upsertDrug(drug));
}
export async function addBrandAction(drugCatalogId: string, brandName: string, isPreferred = false) {
  return safe(() => prescriptions.addBrand(drugCatalogId, brandName, isPreferred));
}

// ---------- Documentos ----------
export async function getTemplatesAction(docType?: DocumentType) {
  return safe(() => documents.getTemplates(docType));
}
export async function resolveTemplateAction(templateId: string, vars: Record<string, string>) {
  return safe(() => documents.resolveTemplate(templateId, vars));
}
export async function issueDocumentAction(input: DocumentInput) {
  return safe(() => documents.issueDocument(input));
}
export async function upsertTemplateAction(
  tpl: Partial<DocumentTemplate> & Pick<DocumentTemplate, 'doc_type' | 'name' | 'body_template'>
) {
  return safe(() => extra.upsertTemplate(tpl));
}

// ---------- Comunicaciones (CRM WhatsApp) ----------
export async function logCommunicationAction(input: CommunicationInput) {
  return safe(() => communications.logCommunication(input));
}
export async function updateCommunicationStatusAction(id: string, status: CommunicationStatus) {
  return safe(() => communications.updateCommunicationStatus(id, status));
}

// ---------- Tablero interno (tareas + mensajes) ----------
export async function createInternalNoteAction(input: InternalNoteInput) {
  return safe(() => internal.createInternalNote(input));
}
export async function toggleTaskDoneAction(id: string, done: boolean) {
  return safe(() => internal.toggleTaskDone(id, done));
}
export async function deleteInternalNoteAction(id: string) {
  return safe(() => internal.deleteInternalNote(id));
}

// ---------- Perfil del consultorio ----------
export async function updateClinicSettingsAction(
  patch: Partial<Omit<import('@/types/database.types').ClinicSettings, 'id' | 'updated_at'>>
) {
  return safe(() => settings.updateClinicSettings(patch));
}

// ---------- Caja ----------
export async function registerPaymentAction(input: PaymentInput) {
  return safe(() => payments.registerPayment(input));
}
export async function settlePendingAction(paymentId: string, method: PaymentMethod) {
  return safe(() => payments.settlePending(paymentId, method));
}
