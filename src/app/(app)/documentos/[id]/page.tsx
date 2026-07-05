import { notFound } from 'next/navigation';
import { getDocument, getPatientBasic, getProfileName } from '@/lib/queries/extra';
import { DOC_TYPE_LABELS, formatDate } from '@/lib/utils';
import { PrintButton, QR } from '@/components/PrintControls';

export const dynamic = 'force-dynamic';

export default async function DocumentoPrintPage({ params }: { params: { id: string } }) {
  const doc = await getDocument(params.id).catch(() => null);
  if (!doc) notFound();
  const [patient, doctorName] = await Promise.all([
    getPatientBasic(doc.patient_id),
    getProfileName(doc.issued_by),
  ]);
  if (!patient) notFound();

  return (
    <main className="p-8 print:p-0">
      <style>{`@page { size: A4 portrait; margin: 20mm; }`}</style>
      <PrintButton />

      <div className="mx-auto w-full max-w-[170mm] rounded-lg border border-vitamed-200 bg-white p-8 print:max-w-none print:rounded-none print:border-0 print:p-0">
        <header className="mb-6 flex items-start justify-between border-b-2 border-vitamed-500 pb-3">
          <div>
            <div className="font-brand text-xl font-bold text-vitamed-900">Vitamed</div>
            <div className="text-[11px] text-vitamed-600">Consultorio médico · Quito, Ecuador</div>
            <div className="text-[11px] text-vitamed-600">{doctorName}</div>
          </div>
          <div className="text-right">
            <div className="text-sm font-semibold uppercase text-vitamed-900">
              {DOC_TYPE_LABELS[doc.doc_type]}
            </div>
            <div className="text-[11px] text-vitamed-600">
              N.º {doc.document_number} · {formatDate(doc.issued_at)}
            </div>
          </div>
        </header>

        <section className="mb-4 text-sm">
          <span className="font-semibold">Paciente:</span> {patient.first_name} {patient.last_name}
          {' · '}
          <span className="font-semibold">CI:</span> {patient.identification_number}
          {patient.age != null && (
            <>
              {' · '}
              <span className="font-semibold">Edad:</span> {patient.age} años
            </>
          )}
        </section>

        <section className="mb-10 whitespace-pre-wrap text-sm leading-relaxed text-vitamed-950">
          {doc.body_final}
        </section>

        <footer className="flex items-end justify-between pt-12">
          <div className="text-center">
            <div className="w-56 border-t border-vitamed-900 pt-1 text-[12px] text-vitamed-900">
              {doctorName}
            </div>
            <div className="text-[10px] text-vitamed-600">Firma y sello</div>
          </div>
          <div className="text-center">
            <QR value={`vitamed:doc:${doc.qr_token}`} size={56} />
            <div className="mt-0.5 text-[9px] text-vitamed-500">Verificación</div>
          </div>
        </footer>
      </div>
    </main>
  );
}
