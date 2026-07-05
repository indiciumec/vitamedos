'use client';

import Link from 'next/link';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { issueDocumentAction, resolveTemplateAction, upsertTemplateAction } from '@/lib/actions';
import type { WithPatientName } from '@/lib/queries/extra';
import type { DocumentTemplate, DocumentType, MedicalDocument, PatientBasic } from '@/types/database.types';
import PatientSearchSelect from '@/components/PatientSearchSelect';
import { DOC_TYPE_LABELS, formatDate, formatDateLong, todayEC } from '@/lib/utils';

const inputCls =
  'mt-1 w-full rounded-md border border-vitamed-200 px-3 py-2 text-sm focus:border-vitamed-500 focus:outline-none focus:ring-1 focus:ring-vitamed-500';

type Props = {
  doctorName: string;
  templates: DocumentTemplate[];
  recientes: (MedicalDocument & WithPatientName)[];
  preselectedPatient: PatientBasic | null;
  consultationId: string | null;
};

export default function DocumentosClient({
  doctorName, templates, recientes, preselectedPatient, consultationId,
}: Props) {
  const router = useRouter();
  const [patient, setPatient] = useState<PatientBasic | null>(preselectedPatient);
  const [docType, setDocType] = useState<DocumentType>('certificado_medico');
  const [templateId, setTemplateId] = useState('');
  const [diagnostico, setDiagnostico] = useState('');
  const [diasReposo, setDiasReposo] = useState('');
  const [body, setBody] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  // Gestión de plantillas
  const [showTplForm, setShowTplForm] = useState(false);
  const [tplName, setTplName] = useState('');
  const [tplType, setTplType] = useState<DocumentType>('certificado_medico');
  const [tplBody, setTplBody] = useState('');

  const tplOptions = templates.filter((t) => t.doc_type === docType);

  async function handleResolve() {
    if (!templateId) return;
    if (!patient) {
      setError('Selecciona un paciente primero');
      return;
    }
    setError(null);
    setBusy(true);
    const res = await resolveTemplateAction(templateId, {
      paciente: `${patient.first_name} ${patient.last_name}`,
      cedula: patient.identification_number,
      edad: patient.age != null ? String(patient.age) : '—',
      fecha: formatDateLong(todayEC()),
      diagnostico: diagnostico.trim(),
      dias_reposo: diasReposo.trim(),
      medico: doctorName,
    });
    setBusy(false);
    if (!res.ok) {
      setError(res.error);
      return;
    }
    setBody(res.data);
  }

  async function handleIssue() {
    if (!patient) {
      setError('Selecciona un paciente');
      return;
    }
    setError(null);
    setBusy(true);
    const res = await issueDocumentAction({
      doc_type: docType,
      patient_id: patient.id,
      consultation_id: consultationId,
      body_final: body,
    });
    setBusy(false);
    if (!res.ok) {
      setError(res.error);
      return;
    }
    router.push(`/documentos/${res.data.id}`);
  }

  async function handleSaveTemplate(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setBusy(true);
    const res = await upsertTemplateAction({
      doc_type: tplType,
      name: tplName.trim(),
      body_template: tplBody,
      is_active: true,
    });
    setBusy(false);
    if (!res.ok) {
      setError(res.error);
      return;
    }
    setShowTplForm(false);
    setTplName('');
    setTplBody('');
    router.refresh();
  }

  return (
    <main className="mx-auto max-w-4xl p-8">
      <header className="mb-6 flex items-center justify-between">
        <h1 className="font-brand text-2xl font-semibold text-vitamed-900">Documentos</h1>
        <button
          onClick={() => setShowTplForm((v) => !v)}
          className="rounded-md border border-vitamed-300 bg-white px-4 py-2 text-sm font-medium text-vitamed-800 hover:bg-vitamed-50"
        >
          {showTplForm ? 'Cerrar plantillas' : 'Nueva plantilla'}
        </button>
      </header>

      {error && <p className="mb-4 text-sm text-red-600">{error}</p>}

      {showTplForm && (
        <form onSubmit={handleSaveTemplate} className="mb-6 rounded-xl border border-vitamed-100 bg-white p-6">
          <h2 className="mb-4 text-sm font-semibold text-vitamed-900">Nueva plantilla</h2>
          <div className="grid gap-4 sm:grid-cols-2">
            <label className="block">
              <span className="text-sm font-medium text-vitamed-900">Tipo</span>
              <select value={tplType} onChange={(e) => setTplType(e.target.value as DocumentType)} className={inputCls}>
                {Object.entries(DOC_TYPE_LABELS).map(([k, v]) => (
                  <option key={k} value={k}>{v}</option>
                ))}
              </select>
            </label>
            <label className="block">
              <span className="text-sm font-medium text-vitamed-900">Nombre *</span>
              <input required value={tplName} onChange={(e) => setTplName(e.target.value)} className={inputCls} />
            </label>
            <label className="block sm:col-span-2">
              <span className="text-sm font-medium text-vitamed-900">
                Cuerpo * <span className="font-normal text-vitamed-500">
                  — placeholders: {'{{paciente}} {{cedula}} {{edad}} {{fecha}} {{diagnostico}} {{dias_reposo}} {{medico}}'}
                </span>
              </span>
              <textarea required rows={8} value={tplBody} onChange={(e) => setTplBody(e.target.value)} className={`${inputCls} font-mono text-xs`} />
            </label>
          </div>
          <button type="submit" disabled={busy} className="mt-4 rounded-md bg-vitamed-500 px-5 py-2 text-sm font-medium text-white hover:bg-vitamed-600 disabled:opacity-50">
            Guardar plantilla
          </button>
        </form>
      )}

      <section className="mb-6 rounded-xl border border-vitamed-100 bg-white p-6">
        <h2 className="mb-4 text-sm font-semibold text-vitamed-900">Emitir documento</h2>

        <div className="mb-4">
          <span className="text-sm font-medium text-vitamed-900">Paciente *</span>
          <div className="mt-1">
            <PatientSearchSelect selected={patient} onSelect={(p) => setPatient(p ?? null)} />
          </div>
        </div>

        <div className="grid gap-4 sm:grid-cols-2">
          <label className="block">
            <span className="text-sm font-medium text-vitamed-900">Tipo de documento</span>
            <select
              value={docType}
              onChange={(e) => {
                setDocType(e.target.value as DocumentType);
                setTemplateId('');
              }}
              className={inputCls}
            >
              {Object.entries(DOC_TYPE_LABELS).map(([k, v]) => (
                <option key={k} value={k}>{v}</option>
              ))}
            </select>
          </label>
          <label className="block">
            <span className="text-sm font-medium text-vitamed-900">Plantilla</span>
            <select value={templateId} onChange={(e) => setTemplateId(e.target.value)} className={inputCls}>
              <option value="">— escribir desde cero —</option>
              {tplOptions.map((t) => (
                <option key={t.id} value={t.id}>{t.name}</option>
              ))}
            </select>
          </label>
          <label className="block">
            <span className="text-sm font-medium text-vitamed-900">Diagnóstico (para plantilla)</span>
            <input value={diagnostico} onChange={(e) => setDiagnostico(e.target.value)} className={inputCls} />
          </label>
          <label className="block">
            <span className="text-sm font-medium text-vitamed-900">Días de reposo (para plantilla)</span>
            <input value={diasReposo} onChange={(e) => setDiasReposo(e.target.value)} className={inputCls} />
          </label>
        </div>

        {templateId && (
          <button
            onClick={handleResolve}
            disabled={busy || !patient}
            className="mt-4 rounded-md border border-vitamed-300 px-4 py-2 text-sm font-medium text-vitamed-800 hover:bg-vitamed-50 disabled:opacity-50"
          >
            Aplicar plantilla
          </button>
        )}

        <label className="mt-4 block">
          <span className="text-sm font-medium text-vitamed-900">Texto final *</span>
          <textarea rows={10} value={body} onChange={(e) => setBody(e.target.value)} className={inputCls} />
        </label>

        <button
          onClick={handleIssue}
          disabled={busy || !patient || body.trim().length < 10}
          className="mt-4 rounded-md bg-vitamed-500 px-6 py-2.5 text-sm font-medium text-white hover:bg-vitamed-600 disabled:opacity-50"
        >
          {busy ? 'Emitiendo…' : 'Emitir documento'}
        </button>
      </section>

      <section className="rounded-xl border border-vitamed-100 bg-white">
        <h2 className="border-b border-vitamed-100 px-5 py-3 text-sm font-semibold text-vitamed-900">
          Emitidos recientemente
        </h2>
        {recientes.length === 0 ? (
          <p className="px-5 py-6 text-sm text-vitamed-500">Aún no hay documentos.</p>
        ) : (
          <ul className="divide-y divide-vitamed-50">
            {recientes.map((d) => (
              <li key={d.id}>
                <Link href={`/documentos/${d.id}`} className="flex items-center gap-3 px-5 py-3 hover:bg-vitamed-50">
                  <span className="w-24 shrink-0 text-sm tabular-nums text-vitamed-600">
                    {formatDate(d.issued_at)}
                  </span>
                  <span className="flex-1 truncate text-sm text-vitamed-900">
                    {DOC_TYPE_LABELS[d.doc_type]} N.º {d.document_number} · {d.patient.first_name} {d.patient.last_name}
                  </span>
                </Link>
              </li>
            ))}
          </ul>
        )}
      </section>
    </main>
  );
}
