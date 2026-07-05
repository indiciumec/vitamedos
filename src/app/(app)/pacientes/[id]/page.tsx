import Link from 'next/link';
import { notFound } from 'next/navigation';
import { getCurrentProfile } from '@/lib/auth';
import { getPatientClinical } from '@/lib/queries/patients';
import { getPatientConsultations } from '@/lib/queries/consultations';
import { getPatientBasic, getPatientPrescriptions } from '@/lib/queries/extra';
import { getPatientDocuments } from '@/lib/queries/documents';
import {
  CONSULT_STATUS_BADGE, CONSULT_STATUS_LABELS, DOC_TYPE_LABELS, calcAge, formatDate,
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

export default async function FichaPacientePage({ params }: { params: { id: string } }) {
  const profile = (await getCurrentProfile())!;
  const isMedico = profile.role === 'medico';

  if (isMedico) {
    const patient = await getPatientClinical(params.id).catch(() => null);
    if (!patient) notFound();

    const [consultas, recetas, docs] = await Promise.all([
      getPatientConsultations(patient.id).catch(() => []),
      getPatientPrescriptions(patient.id).catch(() => []),
      getPatientDocuments(patient.id).catch(() => []),
    ]);
    const age = calcAge(patient.birth_date);

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

          <div className="space-y-6 lg:col-span-2">
            <section className="rounded-xl border border-vitamed-100 bg-white">
              <h2 className="border-b border-vitamed-100 px-5 py-3 text-sm font-semibold text-vitamed-900">
                Historial de consultas
              </h2>
              {consultas.length === 0 ? (
                <p className="px-5 py-4 text-sm text-vitamed-500">Sin consultas registradas.</p>
              ) : (
                <ul className="divide-y divide-vitamed-50">
                  {consultas.map((c) => (
                    <li key={c.id}>
                      <Link href={`/consulta/${c.id}`} className="flex items-center gap-3 px-5 py-3 hover:bg-vitamed-50">
                        <span className="w-24 shrink-0 text-sm tabular-nums text-vitamed-600">
                          {formatDate(c.created_at)}
                        </span>
                        <span className="flex-1 truncate text-sm text-vitamed-900">
                          {c.reason ?? 'Consulta'}
                          {c.diagnosis_text && <span className="text-vitamed-500"> · {c.diagnosis_text}</span>}
                        </span>
                        <span className={`rounded-full px-2.5 py-0.5 text-xs font-medium ${CONSULT_STATUS_BADGE[c.status]}`}>
                          {CONSULT_STATUS_LABELS[c.status]}
                        </span>
                      </Link>
                    </li>
                  ))}
                </ul>
              )}
            </section>

            <section className="rounded-xl border border-vitamed-100 bg-white">
              <h2 className="border-b border-vitamed-100 px-5 py-3 text-sm font-semibold text-vitamed-900">
                Recetas
              </h2>
              {recetas.length === 0 ? (
                <p className="px-5 py-4 text-sm text-vitamed-500">Sin recetas emitidas.</p>
              ) : (
                <ul className="divide-y divide-vitamed-50">
                  {recetas.map((r) => (
                    <li key={r.id}>
                      <Link href={`/recetas/${r.id}`} className="flex items-center gap-3 px-5 py-3 hover:bg-vitamed-50">
                        <span className="w-24 shrink-0 text-sm tabular-nums text-vitamed-600">
                          {formatDate(r.issued_at)}
                        </span>
                        <span className="flex-1 truncate text-sm text-vitamed-900">
                          Receta #{r.prescription_number}
                          {r.diagnosis_text && <span className="text-vitamed-500"> · {r.diagnosis_text}</span>}
                        </span>
                        {r.status === 'anulada' && (
                          <span className="rounded-full bg-red-100 px-2.5 py-0.5 text-xs font-medium text-red-700">Anulada</span>
                        )}
                      </Link>
                    </li>
                  ))}
                </ul>
              )}
            </section>

            <section className="rounded-xl border border-vitamed-100 bg-white">
              <h2 className="border-b border-vitamed-100 px-5 py-3 text-sm font-semibold text-vitamed-900">
                Documentos
              </h2>
              {docs.length === 0 ? (
                <p className="px-5 py-4 text-sm text-vitamed-500">Sin documentos emitidos.</p>
              ) : (
                <ul className="divide-y divide-vitamed-50">
                  {docs.map((d) => (
                    <li key={d.id}>
                      <Link href={`/documentos/${d.id}`} className="flex items-center gap-3 px-5 py-3 hover:bg-vitamed-50">
                        <span className="w-24 shrink-0 text-sm tabular-nums text-vitamed-600">
                          {formatDate(d.issued_at)}
                        </span>
                        <span className="flex-1 truncate text-sm text-vitamed-900">
                          {DOC_TYPE_LABELS[d.doc_type]} · N.º {d.document_number}
                        </span>
                      </Link>
                    </li>
                  ))}
                </ul>
              )}
            </section>
          </div>
        </div>
      </main>
    );
  }

  // Recepción / admin: solo la vista básica (sin datos clínicos, LOPDP)
  const basic = await getPatientBasic(params.id);
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
