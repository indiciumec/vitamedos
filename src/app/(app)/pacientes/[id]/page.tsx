import Link from 'next/link';
import { notFound } from 'next/navigation';
import { getCurrentProfile } from '@/lib/auth';
import { getPatientClinical } from '@/lib/queries/patients';
import { getPatientConsultations } from '@/lib/queries/consultations';
import { getPatientBasic, getPatientPayments, getPatientPrescriptions } from '@/lib/queries/extra';
import { getPatientDocuments } from '@/lib/queries/documents';
import { getPatientCommunications } from '@/lib/queries/communications';
import PatientTimeline, { type TimelineItem } from '@/components/PatientTimeline';
import {
  COMM_KIND_LABELS, CONSULT_STATUS_BADGE, CONSULT_STATUS_LABELS, DOC_TYPE_LABELS,
  PAYMENT_METHOD_LABELS, PAYMENT_STATUS_BADGE, PAYMENT_STATUS_LABELS,
  calcAge, formatDate, formatMoney,
} from '@/lib/utils';

export const dynamic = 'force-dynamic';

function Row({ label, value }: { label: string; value: React.ReactNode }) {
  if (value == null || value === '') return null;
  return (
    <div>
      <dt className="text-xs font-medium uppercase tracking-wide text-vitamed-500">{label}</dt>
      <dd className="text-sm text-vitamed-900">{value}</dd>
    </div>
  );
}

export default async function FichaPacientePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const profile = (await getCurrentProfile())!;
  const isMedico = profile.role === 'medico';

  if (isMedico) {
    const patient = await getPatientClinical(id).catch(() => null);
    if (!patient) notFound();

    const [consultas, recetas, docs, pagos, comunicaciones] = await Promise.all([
      getPatientConsultations(patient.id).catch(() => []),
      getPatientPrescriptions(patient.id).catch(() => []),
      getPatientDocuments(patient.id).catch(() => []),
      getPatientPayments(patient.id).catch(() => []),
      getPatientCommunications(patient.id).catch(() => []),
    ]);
    const age = calcAge(patient.birth_date);

    // Cronología unificada (§4.1): todo lo del paciente en una sola línea de tiempo
    const timeline: TimelineItem[] = [
      ...consultas.map((c): TimelineItem => ({
        id: c.id,
        type: 'consulta',
        date: c.created_at,
        title: c.reason ?? 'Consulta',
        subtitle: c.diagnosis_text,
        badge: CONSULT_STATUS_LABELS[c.status],
        badgeClass: CONSULT_STATUS_BADGE[c.status],
        href: `/consulta/${c.id}`,
      })),
      ...recetas.map((r): TimelineItem => ({
        id: r.id,
        type: 'receta',
        date: r.issued_at,
        title: `Receta #${r.prescription_number}`,
        subtitle: r.diagnosis_text,
        badge: r.status === 'anulada' ? 'Anulada' : null,
        badgeClass: 'bg-red-100 text-red-700',
        href: `/recetas/${r.id}`,
      })),
      ...docs.map((d): TimelineItem => ({
        id: d.id,
        type: 'documento',
        date: d.issued_at,
        title: `${DOC_TYPE_LABELS[d.doc_type]} · N.º ${d.document_number}`,
        href: `/documentos/${d.id}`,
      })),
      ...pagos.map((p): TimelineItem => ({
        id: p.id,
        type: 'pago',
        date: p.created_at,
        title: `${formatMoney(p.amount)} · ${PAYMENT_METHOD_LABELS[p.method]}`,
        subtitle: p.notes,
        badge: PAYMENT_STATUS_LABELS[p.status],
        badgeClass: PAYMENT_STATUS_BADGE[p.status],
      })),
      ...comunicaciones.map((m): TimelineItem => ({
        id: m.id,
        type: 'comunicacion',
        date: m.created_at,
        title: COMM_KIND_LABELS[m.kind],
        subtitle: m.message_snapshot,
      })),
    ].sort((a, b) => (a.date < b.date ? 1 : -1));

    return (
      <main className="mx-auto max-w-5xl p-8">
        <header className="mb-6 flex flex-wrap items-start justify-between gap-4">
          <div>
            <h1 className="font-brand text-2xl font-semibold text-vitamed-900">
              {patient.first_name} {patient.last_name}
            </h1>
            <p className="text-sm text-vitamed-600">
              {patient.identification_number}
              {age != null && ` · ${age} años`}
              {patient.sex && ` · ${patient.sex}`}
              {patient.phone && ` · ${patient.phone}`}
            </p>
            {!patient.data_consent_signed && (
              <p className="mt-1 text-xs font-medium text-amber-700">
                ⚠ Consentimiento LOPDP pendiente de firma
              </p>
            )}
          </div>
          <div className="flex flex-wrap gap-2">
            <Link href={`/consulta/nueva?paciente=${patient.id}`} className="rounded-md bg-vitamed-500 px-4 py-2 text-sm font-medium text-white hover:bg-vitamed-600">
              Nueva consulta
            </Link>
            <Link href={`/recetas/nueva?paciente=${patient.id}`} className="rounded-md border border-vitamed-300 bg-white px-4 py-2 text-sm font-medium text-vitamed-800 hover:bg-vitamed-50">
              Receta
            </Link>
            <Link href={`/documentos?paciente=${patient.id}`} className="rounded-md border border-vitamed-300 bg-white px-4 py-2 text-sm font-medium text-vitamed-800 hover:bg-vitamed-50">
              Documento
            </Link>
            <Link href={`/pacientes/${patient.id}/editar`} className="rounded-md border border-vitamed-300 bg-white px-4 py-2 text-sm font-medium text-vitamed-800 hover:bg-vitamed-50">
              Editar
            </Link>
          </div>
        </header>

        {patient.allergies && (
          <div className="mb-6 rounded-lg border border-red-200 bg-red-50 px-4 py-3">
            <span className="text-sm font-semibold text-red-800">Alergias: </span>
            <span className="text-sm text-red-800">{patient.allergies}</span>
          </div>
        )}

        <div className="grid gap-6 lg:grid-cols-3">
          <section className="rounded-xl border border-vitamed-100 bg-white p-5 lg:col-span-1">
            <h2 className="mb-3 text-sm font-semibold text-vitamed-900">Datos</h2>
            <dl className="space-y-3">
              <Row label="Nacimiento" value={patient.birth_date ? formatDate(patient.birth_date) : null} />
              <Row label="Correo" value={patient.email} />
              <Row label="WhatsApp" value={patient.whatsapp} />
              <Row label="Dirección" value={patient.address} />
              <Row label="Sector" value={patient.sector} />
              <Row
                label="Emergencia"
                value={patient.emergency_contact_name && `${patient.emergency_contact_name} ${patient.emergency_contact_phone ?? ''}`}
              />
              <Row label="Antecedentes personales" value={patient.personal_history} />
              <Row label="Antecedentes familiares" value={patient.family_history} />
              <Row label="Medicación actual" value={patient.current_medication} />
              <Row label="Notas" value={patient.notes} />
            </dl>
          </section>

          <div className="lg:col-span-2">
            <PatientTimeline items={timeline} />
          </div>
        </div>
      </main>
    );
  }

  // Recepción / admin: solo la vista básica (sin datos clínicos, LOPDP)
  const basic = await getPatientBasic(id);
  if (!basic) notFound();

  return (
    <main className="mx-auto max-w-3xl p-8">
      <header className="mb-6 flex items-start justify-between gap-4">
        <div>
          <h1 className="font-brand text-2xl font-semibold text-vitamed-900">
            {basic.first_name} {basic.last_name}
          </h1>
          <p className="text-sm text-vitamed-600">
            {basic.identification_number}
            {basic.age != null && ` · ${basic.age} años`}
          </p>
        </div>
        <div className="flex gap-2">
          <Link href={`/agenda?paciente=${basic.id}`} className="rounded-md bg-vitamed-500 px-4 py-2 text-sm font-medium text-white hover:bg-vitamed-600">
            Agendar cita
          </Link>
          {profile.role === 'recepcion' && (
            <Link href={`/pacientes/${basic.id}/editar`} className="rounded-md border border-vitamed-300 bg-white px-4 py-2 text-sm font-medium text-vitamed-800 hover:bg-vitamed-50">
              Editar
            </Link>
          )}
        </div>
      </header>

      <section className="rounded-xl border border-vitamed-100 bg-white p-5">
        <h2 className="mb-3 text-sm font-semibold text-vitamed-900">Datos de contacto</h2>
        <dl className="grid gap-3 sm:grid-cols-2">
          <Row label="Teléfono" value={basic.phone} />
          <Row label="WhatsApp" value={basic.whatsapp} />
          <Row label="Correo" value={basic.email} />
          <Row label="Dirección" value={basic.address} />
          <Row label="Sector" value={basic.sector} />
          <Row label="Nacimiento" value={basic.birth_date ? formatDate(basic.birth_date) : null} />
          <Row
            label="Emergencia"
            value={basic.emergency_contact_name && `${basic.emergency_contact_name} ${basic.emergency_contact_phone ?? ''}`}
          />
          <Row label="Consentimiento LOPDP" value={basic.data_consent_signed ? 'Firmado' : 'Pendiente'} />
        </dl>
      </section>
    </main>
  );
}
