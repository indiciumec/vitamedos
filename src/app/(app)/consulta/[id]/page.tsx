import Link from 'next/link';
import { notFound } from 'next/navigation';
import { getConsultation } from '@/lib/queries/extra';
import { getPatientClinical } from '@/lib/queries/patients';
import { calcAge, formatDate } from '@/lib/utils';
import ConsultationForm from '@/components/ConsultationForm';

export const dynamic = 'force-dynamic';

export default async function ConsultaDetallePage({ params }: { params: { id: string } }) {
  const consultation = await getConsultation(params.id).catch(() => null);
  if (!consultation) notFound();
  const patient = await getPatientClinical(consultation.patient_id).catch(() => null);
  if (!patient) notFound();
  const age = calcAge(patient.birth_date);

  return (
    <main className="mx-auto max-w-4xl p-8">
      <header className="mb-6">
        <h1 className="font-brand text-2xl font-semibold text-vitamed-900">
          Consulta · {formatDate(consultation.created_at)}
        </h1>
        <p className="text-sm text-vitamed-600">
          <Link href={`/pacientes/${patient.id}`} className="font-medium text-vitamed-800 hover:underline">
            {patient.first_name} {patient.last_name}
          </Link>
          {age != null && ` · ${age} años`} · {patient.identification_number}
        </p>
      </header>

      {patient.allergies && (
        <div className="mb-6 rounded-lg border border-red-200 bg-red-50 px-4 py-3">
          <span className="text-sm font-semibold text-red-800">Alergias: </span>
          <span className="text-sm text-red-800">{patient.allergies}</span>
        </div>
      )}

      <ConsultationForm patient={patient} consultation={consultation} />
    </main>
  );
}
