import Link from 'next/link';
import { notFound } from 'next/navigation';
import { getPrescription } from '@/lib/queries/prescriptions';
import { getPatientBasic, getProfileName } from '@/lib/queries/extra';
import { getClinicSettings } from '@/lib/queries/settings';
import { formatDate } from '@/lib/utils';
import { PrintButton, QR } from '@/components/PrintControls';

export const dynamic = 'force-dynamic';

export default async function RecetaPrintPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const rx = await getPrescription(id).catch(() => null);
  if (!rx) notFound();
  const [patient, doctorName, clinic] = await Promise.all([
    getPatientBasic(rx.patient_id),
    getProfileName(rx.doctor_id),
    getClinicSettings().catch(() => null),
  ]);
  if (!patient) notFound();
  const professional = clinic?.professional_name ?? doctorName;

  return (
    <main className="p-8 print:p-0">
      <style>{`@page { size: A5 portrait; margin: 10mm; }`}</style>
      <div className="no-print mb-4 flex flex-wrap items-center gap-3">
        <PrintButton />
        <Link
          href={`/guias/nutricion?paciente=${rx.patient_id}`}
          className="rounded-md border border-vitamed-300 bg-white px-4 py-2 text-sm font-medium text-vitamed-800 hover:bg-vitamed-50"
        >
          + Guía de nutrición
        </Link>
      </div>

      {rx.status === 'anulada' && (
        <p className="no-print mb-4 rounded-md bg-red-50 px-4 py-2 text-sm font-medium text-red-700">
          Esta receta está ANULADA.
        </p>
      )}

      <div className="rx-sheet mx-auto w-full max-w-[148mm] rounded-lg border border-vitamed-200 bg-white p-6 print:max-w-none print:rounded-none print:border-0 print:p-0">
        {/* Encabezado — membrete desde clinic_settings */}
        <header className="mb-4 flex items-start justify-between border-b-2 border-vitamed-500 pb-3">
          <div>
            <div className="font-brand text-xl font-bold text-vitamed-900">{clinic?.clinic_name ?? 'Vitamed'}</div>
            <div className="text-[11px] text-vitamed-600">
              {professional}
              {clinic?.professional_title && ` · ${clinic.professional_title}`}
            </div>
            {clinic?.license_number && (
              <div className="text-[11px] text-vitamed-600">Reg. {clinic.license_number}</div>
            )}
          </div>
          <div className="text-right">
            <div className="text-sm font-semibold text-vitamed-900">RECETA N.º {rx.prescription_number}</div>
            <div className="text-[11px] text-vitamed-600">{formatDate(rx.issued_at)}</div>
          </div>
        </header>

        {/* Paciente */}
        <section className="mb-4 text-sm">
          <div className="flex flex-wrap gap-x-6 gap-y-0.5">
            <span><span className="font-semibold">Paciente:</span> {patient.first_name} {patient.last_name}</span>
            <span><span className="font-semibold">CI:</span> {patient.identification_number}</span>
            {patient.age != null && <span><span className="font-semibold">Edad:</span> {patient.age} años</span>}
          </div>
          {(rx.diagnosis_code || rx.diagnosis_text) && (
            <div className="mt-1 text-[13px]">
              <span className="font-semibold">Dx:</span> {rx.diagnosis_code} {rx.diagnosis_text}
            </div>
          )}
          {rx.allergies_snapshot && (
            <div className="mt-1 rounded bg-red-50 px-2 py-1 text-[12px] font-medium text-red-800 print:border print:border-red-300">
              Alergias: {rx.allergies_snapshot}
            </div>
          )}
        </section>

        {/* Medicamentos: genérico dominante, marca separada y menor */}
        <section className="mb-6">
          <h2 className="mb-2 text-xs font-bold uppercase tracking-wide text-vitamed-700">Rp/</h2>
          <ol className="space-y-3">
            {rx.items.map((it, i) => (
              <li key={it.id} className="border-b border-dotted border-vitamed-200 pb-2">
                <div className="text-[15px] font-bold uppercase text-vitamed-950">
                  {i + 1}. {it.generic_name_snapshot}
                  {it.concentration && <span className="font-semibold"> {it.concentration}</span>}
                  {it.pharmaceutical_form && (
                    <span className="text-[13px] font-normal"> · {it.pharmaceutical_form}</span>
                  )}
                  {it.quantity && <span className="text-[13px] font-normal"> · #{it.quantity}</span>}
                </div>
                {it.optional_commercial_brand && (
                  <div className="text-[11px] text-vitamed-600">
                    Marca sugerida (opcional): {it.optional_commercial_brand}
                  </div>
                )}
                <div className="mt-0.5 text-[13px] text-vitamed-900">
                  {[it.dose, it.route, it.frequency, it.duration].filter(Boolean).join(' · ')}
                </div>
                {it.instructions && (
                  <div className="text-[12px] italic text-vitamed-700">{it.instructions}</div>
                )}
              </li>
            ))}
          </ol>
        </section>

        {/* Pie: firma + dirección/teléfono + QR */}
        <footer className="flex items-end justify-between pt-8">
          <div className="text-center">
            <div className="w-48 border-t border-vitamed-900 pt-1 text-[12px] text-vitamed-900">
              {professional}
            </div>
            <div className="text-[10px] text-vitamed-600">Firma y sello</div>
            {(clinic?.address || clinic?.phone) && (
              <div className="mt-1 text-[9px] text-vitamed-500">
                {[clinic?.address, clinic?.phone].filter(Boolean).join(' · ')}
              </div>
            )}
          </div>
          <div className="text-center">
            <QR value={`vitamed:rx:${rx.qr_token}`} size={56} />
            <div className="mt-0.5 text-[9px] text-vitamed-500">Verificación</div>
          </div>
        </footer>
      </div>
    </main>
  );
}
