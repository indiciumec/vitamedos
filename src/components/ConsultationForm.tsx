'use client';

import { useMemo, useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import {
  amendConsultationAction, closeConsultationAction,
  createDraftConsultationAction, updateDraftConsultationAction,
} from '@/lib/actions';
import type { ConsultationInput } from '@/lib/validators';
import type { ClinicSettings, Consultation, Patient, VitalSigns } from '@/types/database.types';
import { CONSULT_STATUS_BADGE, CONSULT_STATUS_LABELS, formatDate, todayEC } from '@/lib/utils';
import { WA_TEMPLATES } from '@/lib/whatsapp';
import WAButton from '@/components/wa-button';

type Props = {
  patient: Patient;
  consultation?: Consultation;
  appointmentId?: string | null;
  clinic?: ClinicSettings | null;
};

const inputCls =
  'mt-1 w-full rounded-md border border-vitamed-200 px-3 py-2 text-sm focus:border-vitamed-500 focus:outline-none focus:ring-1 focus:ring-vitamed-500 disabled:bg-vitamed-50 disabled:text-vitamed-700';

function Field({ label, children, className }: { label: string; children: React.ReactNode; className?: string }) {
  return (
    <label className={`block ${className ?? ''}`}>
      <span className="text-sm font-medium text-vitamed-900">{label}</span>
      {children}
    </label>
  );
}

export default function ConsultationForm({ patient, consultation, appointmentId, clinic }: Props) {
  const router = useRouter();
  const editable = !consultation || consultation.status === 'borrador';
  const vs0 = (consultation?.vital_signs ?? {}) as VitalSigns;

  const [f, setF] = useState({
    reason: consultation?.reason ?? '',
    current_illness: consultation?.current_illness ?? '',
    physical_exam: consultation?.physical_exam ?? '',
    diagnosis_code: consultation?.diagnosis_code ?? '',
    diagnosis_text: consultation?.diagnosis_text ?? '',
    treatment_plan: consultation?.treatment_plan ?? '',
    recommendations: consultation?.recommendations ?? '',
    requested_exams: consultation?.requested_exams ?? '',
    next_control_date: consultation?.next_control_date ?? '',
  });
  const [vs, setVs] = useState({
    pa: vs0.pa ?? '',
    fc: vs0.fc?.toString() ?? '',
    fr: vs0.fr?.toString() ?? '',
    temp: vs0.temp?.toString() ?? '',
    spo2: vs0.spo2?.toString() ?? '',
    peso: vs0.peso?.toString() ?? '',
    talla: vs0.talla?.toString() ?? '',
  });
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [amendNote, setAmendNote] = useState('');
  const [showAmend, setShowAmend] = useState(false);

  const set = (k: string) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) =>
    setF((p) => ({ ...p, [k]: e.target.value }));
  const setV = (k: string) => (e: React.ChangeEvent<HTMLInputElement>) =>
    setVs((p) => ({ ...p, [k]: e.target.value }));

  const imc = useMemo(() => {
    const peso = parseFloat(vs.peso);
    const talla = parseFloat(vs.talla);
    if (!peso || !talla) return null;
    return Math.round((peso / Math.pow(talla / 100, 2)) * 10) / 10;
  }, [vs.peso, vs.talla]);

  const nn = (v: string) => (v.trim() === '' ? null : v.trim());
  const num = (v: string) => (v.trim() === '' ? undefined : parseFloat(v));

  function buildInput(): ConsultationInput {
    const vitals: VitalSigns = {
      ...(vs.pa.trim() ? { pa: vs.pa.trim() } : {}),
      ...(num(vs.fc) !== undefined ? { fc: num(vs.fc) } : {}),
      ...(num(vs.fr) !== undefined ? { fr: num(vs.fr) } : {}),
      ...(num(vs.temp) !== undefined ? { temp: num(vs.temp) } : {}),
      ...(num(vs.spo2) !== undefined ? { spo2: num(vs.spo2) } : {}),
      ...(num(vs.peso) !== undefined ? { peso: num(vs.peso) } : {}),
      ...(num(vs.talla) !== undefined ? { talla: num(vs.talla) } : {}),
      ...(imc != null ? { imc } : {}),
    };
    return {
      patient_id: patient.id,
      appointment_id: consultation?.appointment_id ?? appointmentId ?? null,
      reason: f.reason.trim(),
      current_illness: nn(f.current_illness),
      vital_signs: vitals,
      physical_exam: nn(f.physical_exam),
      diagnosis_code: nn(f.diagnosis_code),
      diagnosis_text: nn(f.diagnosis_text),
      treatment_plan: nn(f.treatment_plan),
      recommendations: nn(f.recommendations),
      requested_exams: nn(f.requested_exams),
      next_control_date: nn(f.next_control_date),
    };
  }

  async function handleSave() {
    setError(null);
    setSaving(true);
    const input = buildInput();
    const res = consultation
      ? await updateDraftConsultationAction(consultation.id, input)
      : await createDraftConsultationAction(input);
    setSaving(false);
    if (!res.ok) {
      setError(res.error);
      return;
    }
    if (!consultation) {
      router.push(`/consulta/${res.data.id}`);
    }
    router.refresh();
  }

  async function handleClose() {
    if (!consultation) return;
    if (!window.confirm('Al cerrar, la consulta queda INMUTABLE. Solo podrá corregirse mediante enmienda. ¿Cerrar?')) return;
    setError(null);
    setSaving(true);
    // Guarda los últimos cambios antes de cerrar
    const up = await updateDraftConsultationAction(consultation.id, buildInput());
    if (!up.ok) {
      setSaving(false);
      setError(up.error);
      return;
    }
    const res = await closeConsultationAction(consultation.id);
    setSaving(false);
    if (!res.ok) {
      setError(res.error);
      return;
    }
    router.refresh();
  }

  async function handleAmend() {
    if (!consultation) return;
    if (amendNote.trim().length < 5) {
      setError('Describe el motivo de la enmienda (mínimo 5 caracteres).');
      return;
    }
    setError(null);
    setSaving(true);
    const res = await amendConsultationAction(consultation.id, buildInput(), amendNote.trim());
    setSaving(false);
    if (!res.ok) {
      setError(res.error);
      return;
    }
    router.push(`/consulta/${res.data.id}`);
    router.refresh();
  }

  const dis = !editable;

  return (
    <div className="space-y-6">
      {consultation && (
        <div className="flex flex-wrap items-center gap-3">
          <span className={`rounded-full px-3 py-1 text-xs font-medium ${CONSULT_STATUS_BADGE[consultation.status]}`}>
            {CONSULT_STATUS_LABELS[consultation.status]}
          </span>
          {consultation.closed_at && (
            <span className="text-xs text-vitamed-600">Cerrada el {formatDate(consultation.closed_at)}</span>
          )}
          {consultation.status === 'enmendada' && consultation.amended_by_id && (
            <Link href={`/consulta/${consultation.amended_by_id}`} className="text-xs text-vitamed-600 underline">
              Ver enmienda →
            </Link>
          )}
          {consultation.status === 'enmendada' && consultation.amendment_note && (
            <span className="text-xs text-vitamed-600">Nota: {consultation.amendment_note}</span>
          )}
          {consultation.status !== 'borrador' && (
            <span className="ml-auto flex gap-2">
              <Link
                href={`/recetas/nueva?paciente=${patient.id}&consulta=${consultation.id}`}
                className="rounded-md bg-vitamed-500 px-3 py-1.5 text-xs font-medium text-white hover:bg-vitamed-600"
              >
                Emitir receta
              </Link>
              <Link
                href={`/documentos?paciente=${patient.id}&consulta=${consultation.id}`}
                className="rounded-md border border-vitamed-300 bg-white px-3 py-1.5 text-xs font-medium text-vitamed-800 hover:bg-vitamed-50"
              >
                Emitir documento
              </Link>
            </span>
          )}
        </div>
      )}

      <section className="rounded-xl border border-vitamed-100 bg-white p-6">
        <h2 className="mb-4 text-sm font-semibold text-vitamed-900">Motivo y enfermedad actual</h2>
        <div className="space-y-4">
          <Field label="Motivo de consulta *">
            <input required disabled={dis} value={f.reason} onChange={set('reason')} className={inputCls} />
          </Field>
          <Field label="Enfermedad actual">
            <textarea rows={3} disabled={dis} value={f.current_illness} onChange={set('current_illness')} className={inputCls} />
          </Field>
        </div>
      </section>

      <section className="rounded-xl border border-vitamed-100 bg-white p-6">
        <h2 className="mb-4 text-sm font-semibold text-vitamed-900">Signos vitales</h2>
        <div className="grid grid-cols-2 gap-4 sm:grid-cols-4 lg:grid-cols-8">
          <Field label="PA">
            <input disabled={dis} placeholder="120/80" value={vs.pa} onChange={setV('pa')} className={inputCls} />
          </Field>
          <Field label="FC">
            <input disabled={dis} type="number" value={vs.fc} onChange={setV('fc')} className={inputCls} />
          </Field>
          <Field label="FR">
            <input disabled={dis} type="number" value={vs.fr} onChange={setV('fr')} className={inputCls} />
          </Field>
          <Field label="Temp °C">
            <input disabled={dis} type="number" step="0.1" value={vs.temp} onChange={setV('temp')} className={inputCls} />
          </Field>
          <Field label="SpO2 %">
            <input disabled={dis} type="number" value={vs.spo2} onChange={setV('spo2')} className={inputCls} />
          </Field>
          <Field label="Peso kg">
            <input disabled={dis} type="number" step="0.1" value={vs.peso} onChange={setV('peso')} className={inputCls} />
          </Field>
          <Field label="Talla cm">
            <input disabled={dis} type="number" step="0.1" value={vs.talla} onChange={setV('talla')} className={inputCls} />
          </Field>
          <div className="block">
            <span className="text-sm font-medium text-vitamed-900">IMC</span>
            <div className="mt-1 rounded-md bg-vitamed-50 px-3 py-2 text-sm font-semibold text-vitamed-900">
              {imc ?? '—'}
            </div>
          </div>
        </div>
      </section>

      <section className="rounded-xl border border-vitamed-100 bg-white p-6">
        <h2 className="mb-4 text-sm font-semibold text-vitamed-900">Examen y diagnóstico</h2>
        <div className="space-y-4">
          <Field label="Examen físico">
            <textarea rows={3} disabled={dis} value={f.physical_exam} onChange={set('physical_exam')} className={inputCls} />
          </Field>
          <div className="grid gap-4 sm:grid-cols-[140px_1fr]">
            <Field label="CIE-10">
              <input disabled={dis} placeholder="J00" value={f.diagnosis_code} onChange={set('diagnosis_code')} className={inputCls} />
            </Field>
            <Field label="Diagnóstico">
              <input disabled={dis} value={f.diagnosis_text} onChange={set('diagnosis_text')} className={inputCls} />
            </Field>
          </div>
        </div>
      </section>

      <section className="rounded-xl border border-vitamed-100 bg-white p-6">
        <h2 className="mb-4 text-sm font-semibold text-vitamed-900">Plan</h2>
        <div className="grid gap-4 sm:grid-cols-2">
          <Field label="Plan de tratamiento">
            <textarea rows={3} disabled={dis} value={f.treatment_plan} onChange={set('treatment_plan')} className={inputCls} />
          </Field>
          <Field label="Recomendaciones">
            <textarea rows={3} disabled={dis} value={f.recommendations} onChange={set('recommendations')} className={inputCls} />
          </Field>
          <Field label="Exámenes solicitados">
            <textarea rows={2} disabled={dis} value={f.requested_exams} onChange={set('requested_exams')} className={inputCls} />
          </Field>
          <Field label="Próximo control">
            <input type="date" disabled={dis} value={f.next_control_date} onChange={set('next_control_date')} className={inputCls} />
          </Field>
        </div>
      </section>

      {error && <p className="text-sm text-red-600">{error}</p>}

      {editable ? (
        <div className="flex flex-wrap gap-3">
          <button
            onClick={handleSave}
            disabled={saving || f.reason.trim().length < 2}
            className="rounded-md border border-vitamed-300 bg-white px-5 py-2 text-sm font-medium text-vitamed-800 hover:bg-vitamed-50 disabled:opacity-50"
          >
            {saving ? 'Guardando…' : consultation ? 'Guardar cambios' : 'Guardar borrador'}
          </button>
          {consultation && (
            <button
              onClick={handleClose}
              disabled={saving}
              className="rounded-md bg-vitamed-500 px-5 py-2 text-sm font-medium text-white hover:bg-vitamed-600 disabled:opacity-50"
            >
              Cerrar consulta
            </button>
          )}
        </div>
      ) : consultation?.status === 'cerrada' ? (
        <div className="space-y-4">
          {/* Contacto rápido post-consulta (solo mensajes informativos) */}
          <div className="flex flex-wrap items-center gap-2 rounded-xl border border-vitamed-100 bg-white p-4">
            <WAButton
              phone={patient.whatsapp ?? patient.phone}
              label="Seguimiento"
              message={WA_TEMPLATES.postconsulta({
                clinica: clinic?.clinic_name ?? 'Vitamed',
                nombre: patient.first_name,
              })}
            />
            {f.next_control_date && (
              <WAButton
                phone={patient.whatsapp ?? patient.phone}
                label="Aviso de control"
                message={WA_TEMPLATES.control({
                  clinica: clinic?.clinic_name ?? 'Vitamed',
                  nombre: patient.first_name,
                  dias: Math.max(
                    0,
                    Math.ceil(
                      (new Date(`${f.next_control_date}T12:00:00-05:00`).getTime() -
                        new Date(`${todayEC()}T12:00:00-05:00`).getTime()) /
                        86400000
                    )
                  ),
                })}
              />
            )}
          </div>

          <div className="rounded-xl border border-vitamed-100 bg-white p-6">
          {!showAmend ? (
            <button
              onClick={() => setShowAmend(true)}
              className="rounded-md border border-vitamed-300 px-5 py-2 text-sm font-medium text-vitamed-800 hover:bg-vitamed-50"
            >
              Crear enmienda
            </button>
          ) : (
            <div className="space-y-3">
              <p className="text-sm text-vitamed-700">
                La enmienda crea una nueva consulta vinculada (editable) y marca esta como enmendada. El registro original no se modifica.
              </p>
              <Field label="Motivo de la enmienda *">
                <textarea rows={2} value={amendNote} onChange={(e) => setAmendNote(e.target.value)} className={inputCls} />
              </Field>
              <div className="flex gap-3">
                <button
                  onClick={handleAmend}
                  disabled={saving}
                  className="rounded-md bg-vitamed-500 px-5 py-2 text-sm font-medium text-white hover:bg-vitamed-600 disabled:opacity-50"
                >
                  {saving ? 'Creando…' : 'Crear enmienda'}
                </button>
                <button
                  onClick={() => setShowAmend(false)}
                  className="rounded-md border border-vitamed-200 px-5 py-2 text-sm text-vitamed-800 hover:bg-vitamed-50"
                >
                  Cancelar
                </button>
              </div>
            </div>
          )}
          </div>
        </div>
      ) : null}
    </div>
  );
}
