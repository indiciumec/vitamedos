'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { createPatientAction, updatePatientAction } from '@/lib/actions';
import type { PatientInput } from '@/lib/validators';

type Props = {
  /** Si viene, es edición. */
  patientId?: string;
  initial?: Partial<PatientInput>;
  /** El rol medico ve y edita los campos clínicos. */
  showClinical: boolean;
};

const inputCls =
  'mt-1 w-full rounded-md border border-vitamed-200 px-3 py-2 text-sm focus:border-vitamed-500 focus:outline-none focus:ring-1 focus:ring-vitamed-500';

function Field({ label, children, className }: { label: string; children: React.ReactNode; className?: string }) {
  return (
    <label className={`block ${className ?? ''}`}>
      <span className="text-sm font-medium text-vitamed-900">{label}</span>
      {children}
    </label>
  );
}

export default function PatientForm({ patientId, initial, showClinical }: Props) {
  const router = useRouter();
  const [f, setF] = useState<Record<string, string>>({
    identification_type: (initial?.identification_type as string) ?? 'cedula',
    identification_number: initial?.identification_number ?? '',
    first_name: initial?.first_name ?? '',
    last_name: initial?.last_name ?? '',
    birth_date: initial?.birth_date ?? '',
    sex: (initial?.sex as string) ?? '',
    phone: initial?.phone ?? '',
    whatsapp: initial?.whatsapp ?? '',
    email: initial?.email ?? '',
    address: initial?.address ?? '',
    sector: initial?.sector ?? '',
    emergency_contact_name: initial?.emergency_contact_name ?? '',
    emergency_contact_phone: initial?.emergency_contact_phone ?? '',
    allergies: initial?.allergies ?? '',
    personal_history: initial?.personal_history ?? '',
    family_history: initial?.family_history ?? '',
    current_medication: initial?.current_medication ?? '',
    notes: initial?.notes ?? '',
  });
  const [consent, setConsent] = useState(initial?.data_consent_signed ?? false);
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  const set = (k: string) => (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) =>
    setF((prev) => ({ ...prev, [k]: e.target.value }));

  const nn = (v: string) => (v.trim() === '' ? null : v.trim());

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setSaving(true);

    const input = {
      identification_type: f.identification_type as PatientInput['identification_type'],
      identification_number: f.identification_number.trim(),
      first_name: f.first_name.trim(),
      last_name: f.last_name.trim(),
      birth_date: nn(f.birth_date),
      sex: (nn(f.sex) as PatientInput['sex']) ?? null,
      phone: nn(f.phone),
      whatsapp: nn(f.whatsapp),
      email: nn(f.email),
      address: nn(f.address),
      sector: nn(f.sector),
      emergency_contact_name: nn(f.emergency_contact_name),
      emergency_contact_phone: nn(f.emergency_contact_phone),
      ...(showClinical
        ? {
            allergies: nn(f.allergies),
            personal_history: nn(f.personal_history),
            family_history: nn(f.family_history),
            current_medication: nn(f.current_medication),
            notes: nn(f.notes),
          }
        : {}),
      data_consent_signed: consent,
    } as PatientInput;

    const res = patientId
      ? await updatePatientAction(patientId, input)
      : await createPatientAction(input);

    setSaving(false);
    if (!res.ok) {
      setError(res.error);
      return;
    }
    router.push(`/pacientes/${res.data.id}`);
    router.refresh();
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <section className="rounded-xl border border-vitamed-100 bg-white p-6">
        <h2 className="mb-4 text-sm font-semibold text-vitamed-900">Identificación</h2>
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          <Field label="Tipo">
            <select value={f.identification_type} onChange={set('identification_type')} className={inputCls}>
              <option value="cedula">Cédula</option>
              <option value="pasaporte">Pasaporte</option>
              <option value="ruc">RUC</option>
            </select>
          </Field>
          <Field label="Número *">
            <input required value={f.identification_number} onChange={set('identification_number')} className={inputCls} />
          </Field>
          <Field label="Nombres *">
            <input required value={f.first_name} onChange={set('first_name')} className={inputCls} />
          </Field>
          <Field label="Apellidos *">
            <input required value={f.last_name} onChange={set('last_name')} className={inputCls} />
          </Field>
          <Field label="Fecha de nacimiento">
            <input type="date" value={f.birth_date} onChange={set('birth_date')} className={inputCls} />
          </Field>
          <Field label="Sexo">
            <select value={f.sex} onChange={set('sex')} className={inputCls}>
              <option value="">—</option>
              <option value="F">Femenino</option>
              <option value="M">Masculino</option>
              <option value="O">Otro</option>
            </select>
          </Field>
          <Field label="Teléfono">
            <input value={f.phone} onChange={set('phone')} className={inputCls} />
          </Field>
          <Field label="WhatsApp">
            <input value={f.whatsapp} onChange={set('whatsapp')} className={inputCls} />
          </Field>
          <Field label="Correo" className="sm:col-span-2">
            <input type="email" value={f.email} onChange={set('email')} className={inputCls} />
          </Field>
          <Field label="Dirección" className="sm:col-span-2">
            <input value={f.address} onChange={set('address')} className={inputCls} />
          </Field>
          <Field label="Sector">
            <input value={f.sector} onChange={set('sector')} className={inputCls} />
          </Field>
          <Field label="Contacto de emergencia">
            <input value={f.emergency_contact_name} onChange={set('emergency_contact_name')} className={inputCls} />
          </Field>
          <Field label="Teléfono de emergencia">
            <input value={f.emergency_contact_phone} onChange={set('emergency_contact_phone')} className={inputCls} />
          </Field>
        </div>
      </section>

      {showClinical && (
        <section className="rounded-xl border border-vitamed-100 bg-white p-6">
          <h2 className="mb-4 text-sm font-semibold text-vitamed-900">Antecedentes clínicos</h2>
          <div className="grid gap-4 sm:grid-cols-2">
            <Field label="Alergias" className="sm:col-span-2">
              <textarea rows={2} value={f.allergies} onChange={set('allergies')} className={inputCls} />
            </Field>
            <Field label="Antecedentes personales">
              <textarea rows={3} value={f.personal_history} onChange={set('personal_history')} className={inputCls} />
            </Field>
            <Field label="Antecedentes familiares">
              <textarea rows={3} value={f.family_history} onChange={set('family_history')} className={inputCls} />
            </Field>
            <Field label="Medicación actual">
              <textarea rows={2} value={f.current_medication} onChange={set('current_medication')} className={inputCls} />
            </Field>
            <Field label="Notas">
              <textarea rows={2} value={f.notes} onChange={set('notes')} className={inputCls} />
            </Field>
          </div>
        </section>
      )}

      <section className="rounded-xl border border-vitamed-100 bg-white p-6">
        <label className="flex items-start gap-3">
          <input
            type="checkbox"
            checked={consent}
            onChange={(e) => setConsent(e.target.checked)}
            className="mt-0.5 h-4 w-4 accent-vitamed-500"
          />
          <span className="text-sm text-vitamed-800">
            El paciente firmó el consentimiento de tratamiento de datos personales (LOPDP).
          </span>
        </label>
      </section>

      {error && <p className="text-sm text-red-600">{error}</p>}

      <div className="flex gap-3">
        <button
          type="submit"
          disabled={saving}
          className="rounded-md bg-vitamed-500 px-5 py-2 text-sm font-medium text-white hover:bg-vitamed-600 disabled:opacity-50"
        >
          {saving ? 'Guardando…' : patientId ? 'Guardar cambios' : 'Crear paciente'}
        </button>
        <button
          type="button"
          onClick={() => router.back()}
          className="rounded-md border border-vitamed-200 px-5 py-2 text-sm font-medium text-vitamed-800 hover:bg-vitamed-50"
        >
          Cancelar
        </button>
      </div>
    </form>
  );
}
