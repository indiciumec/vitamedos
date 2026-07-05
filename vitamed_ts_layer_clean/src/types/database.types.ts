// ============================================================
// VITAMED OS — Tipos de base de datos
// Alineado 1:1 con 001_vitamed_mvp_schema.sql
// En producción: regenerar con `supabase gen types typescript --linked`
// ============================================================

// ---------- ENUMS ----------
export type UserRole = 'medico' | 'recepcion' | 'admin' | 'tecnico';

export type AppointmentStatus =
  | 'solicitada' | 'por_confirmar' | 'confirmada' | 'en_espera'
  | 'en_consulta' | 'atendida' | 'cancelada' | 'no_asistio';

export type ConsultationStatus = 'borrador' | 'cerrada' | 'enmendada' | 'anulada';

export type DocumentType =
  | 'certificado_medico' | 'reposo_medico' | 'constancia_asistencia'
  | 'solicitud_examenes' | 'referencia_especialista' | 'informe_clinico'
  | 'consentimiento_informado' | 'consentimiento_datos';

export type PaymentMethod = 'efectivo' | 'transferencia' | 'tarjeta' | 'cortesia' | 'pendiente';
export type PaymentStatus = 'pagado' | 'pendiente' | 'cortesia' | 'anulado';
export type IdentificationType = 'cedula' | 'pasaporte' | 'ruc';
export type Sex = 'M' | 'F' | 'O';
export type PrescriptionStatus = 'emitida' | 'anulada';

// ---------- SIGNOS VITALES (jsonb en consultations) ----------
export interface VitalSigns {
  pa?: string;        // presión arterial "120/80"
  fc?: number;        // frecuencia cardiaca
  fr?: number;        // frecuencia respiratoria
  temp?: number;      // °C
  spo2?: number;      // %
  peso?: number;      // kg
  talla?: number;     // cm
  imc?: number;       // calculado
}

// ---------- FILAS ----------
export interface Profile {
  id: string;
  full_name: string;
  role: UserRole;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface Patient {
  id: string;
  identification_type: IdentificationType;
  identification_number: string;
  first_name: string;
  last_name: string;
  birth_date: string | null;
  sex: Sex | null;
  phone: string | null;
  whatsapp: string | null;
  email: string | null;
  address: string | null;
  sector: string | null;
  emergency_contact_name: string | null;
  emergency_contact_phone: string | null;
  allergies: string | null;
  personal_history: string | null;
  family_history: string | null;
  current_medication: string | null;
  notes: string | null;
  data_consent_signed: boolean;
  data_consent_date: string | null;
  created_by: string | null;
  created_at: string;
  updated_at: string;
}

/** Vista patients_basic — lo único que consume el rol recepcion */
export type PatientBasic = Omit<
  Patient,
  'allergies' | 'personal_history' | 'family_history' | 'current_medication' | 'notes' | 'created_by' | 'updated_at'
> & { age: number | null };

export interface Service {
  id: string;
  name: string;
  price: number;
  duration_min: number;
  is_active: boolean;
  created_at: string;
}

export interface Appointment {
  id: string;
  patient_id: string;
  service_id: string | null;
  scheduled_at: string;
  duration_min: number;
  reason: string | null;
  status: AppointmentStatus;
  phone_snapshot: string | null;
  notes: string | null;
  created_by: string | null;
  created_at: string;
  updated_at: string;
}

export interface Consultation {
  id: string;
  patient_id: string;
  appointment_id: string | null;
  doctor_id: string;
  reason: string | null;
  current_illness: string | null;
  vital_signs: VitalSigns;
  physical_exam: string | null;
  diagnosis_code: string | null;
  diagnosis_text: string | null;
  treatment_plan: string | null;
  recommendations: string | null;
  requested_exams: string | null;
  next_control_date: string | null;
  status: ConsultationStatus;
  closed_at: string | null;
  amended_by_id: string | null;
  amendment_note: string | null;
  created_at: string;
  updated_at: string;
}

export interface DrugCatalogItem {
  id: string;
  generic_name: string;
  therapeutic_class: string | null;
  pharmaceutical_form: string | null;
  concentration: string | null;
  route: string | null;
  usual_quantity: string | null;
  usual_dose: string | null;
  usual_frequency: string | null;
  usual_duration: string | null;
  usual_indications: string | null;
  warnings: string | null;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface CommercialBrand {
  id: string;
  drug_catalog_id: string;
  brand_name: string;
  laboratory: string | null;
  notes: string | null;
  is_preferred: boolean;
  is_active: boolean;
}

export interface Prescription {
  id: string;
  prescription_number: number;
  patient_id: string;
  consultation_id: string | null;
  doctor_id: string;
  diagnosis_code: string | null;
  diagnosis_text: string | null;
  allergies_snapshot: string | null;
  status: PrescriptionStatus;
  qr_token: string;
  issued_at: string;
  created_at: string;
}

export interface PrescriptionItem {
  id: string;
  prescription_id: string;
  drug_catalog_id: string | null;
  generic_name_snapshot: string;          // REGLA DCI: nunca vacío
  concentration: string | null;
  pharmaceutical_form: string | null;
  route: string | null;
  quantity: string | null;
  dose: string | null;
  frequency: string | null;
  duration: string | null;
  instructions: string | null;
  optional_commercial_brand: string | null;
  created_at: string;
}

export interface DocumentTemplate {
  id: string;
  doc_type: DocumentType;
  name: string;
  body_template: string;
  is_active: boolean;
  created_at: string;
}

export interface MedicalDocument {
  id: string;
  document_number: number;
  doc_type: DocumentType;
  patient_id: string;
  consultation_id: string | null;
  issued_by: string;
  body_final: string;
  qr_token: string;
  issued_at: string;
}

export interface Payment {
  id: string;
  patient_id: string;
  consultation_id: string | null;
  service_id: string | null;
  amount: number;
  method: PaymentMethod;
  status: PaymentStatus;
  notes: string | null;
  paid_at: string | null;
  registered_by: string | null;
  created_at: string;
  updated_at: string;
}

export interface AuditLog {
  id: number;
  occurred_at: string;
  user_id: string | null;
  action: string;
  table_name: string;
  record_id: string | null;
  old_data: Record<string, unknown> | null;
  new_data: Record<string, unknown> | null;
}

// ---------- INSERTS (campos generados omitidos) ----------
export type PatientInsert = Omit<Patient, 'id' | 'created_at' | 'updated_at' | 'created_by'> & { id?: string };
export type AppointmentInsert = Omit<Appointment, 'id' | 'created_at' | 'updated_at' | 'created_by'> & { id?: string };
export type ConsultationInsert = Omit<Consultation, 'id' | 'created_at' | 'updated_at' | 'closed_at' | 'amended_by_id' | 'amendment_note'> & { id?: string };
export type PrescriptionItemInsert = Omit<PrescriptionItem, 'id' | 'prescription_id' | 'created_at'>;
export type PaymentInsert = Omit<Payment, 'id' | 'created_at' | 'updated_at' | 'registered_by'> & { id?: string };

// ---------- Database type para supabase-js ----------
export interface Database {
  public: {
    Tables: {
      profiles: { Row: Profile; Insert: Partial<Profile> & Pick<Profile, 'id' | 'full_name'>; Update: Partial<Profile> };
      patients: { Row: Patient; Insert: PatientInsert; Update: Partial<Patient> };
      services: { Row: Service; Insert: Partial<Service> & Pick<Service, 'name'>; Update: Partial<Service> };
      appointments: { Row: Appointment; Insert: AppointmentInsert; Update: Partial<Appointment> };
      consultations: { Row: Consultation; Insert: ConsultationInsert; Update: Partial<Consultation> };
      drug_catalog: { Row: DrugCatalogItem; Insert: Partial<DrugCatalogItem> & Pick<DrugCatalogItem, 'generic_name'>; Update: Partial<DrugCatalogItem> };
      commercial_brands: { Row: CommercialBrand; Insert: Omit<CommercialBrand, 'id'> & { id?: string }; Update: Partial<CommercialBrand> };
      prescriptions: { Row: Prescription; Insert: Partial<Prescription> & Pick<Prescription, 'patient_id' | 'doctor_id'>; Update: Partial<Prescription> };
      prescription_items: { Row: PrescriptionItem; Insert: PrescriptionItemInsert & { prescription_id: string }; Update: Partial<PrescriptionItem> };
      document_templates: { Row: DocumentTemplate; Insert: Partial<DocumentTemplate> & Pick<DocumentTemplate, 'doc_type' | 'name' | 'body_template'>; Update: Partial<DocumentTemplate> };
      medical_documents: { Row: MedicalDocument; Insert: Partial<MedicalDocument> & Pick<MedicalDocument, 'doc_type' | 'patient_id' | 'issued_by' | 'body_final'>; Update: Partial<MedicalDocument> };
      payments: { Row: Payment; Insert: PaymentInsert; Update: Partial<Payment> };
      audit_logs: { Row: AuditLog; Insert: never; Update: never };
    };
    Views: {
      patients_basic: { Row: PatientBasic };
    };
    Functions: {
      current_role: { Args: Record<string, never>; Returns: UserRole };
      patient_age: { Args: { p_birth: string }; Returns: number };
      log_clinical_access: { Args: { p_patient: string }; Returns: undefined };
    };
    Enums: {
      user_role: UserRole;
      appointment_status: AppointmentStatus;
      consultation_status: ConsultationStatus;
      document_type: DocumentType;
      payment_method: PaymentMethod;
      payment_status: PaymentStatus;
      identification_type: IdentificationType;
    };
  };
}
