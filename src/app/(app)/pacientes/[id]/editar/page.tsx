import { notFound } from 'next/navigation';
import { getCurrentProfile } from '@/lib/auth';
import { getPatientClinical } from '@/lib/queries/patients';
import { getPatientBasic } from '@/lib/queries/extra';
import PatientForm from '@/components/PatientForm';
import type { PatientInput } from '@/lib/validators';

export const dynamic = 'force-dynamic';

export default async function EditarPacientePage({ params }: { params: { id: string } }) {
  const profile = (await getCurrentProfile())!;
  const isMedico = profile.role === 'medico';

  const patient = isMedico
    ? await getPatientClinical(params.id).catch(() => null)
    : await getPatientBasic(params.id);
  if (!patient) notFound();

  return (
    <main className="mx-auto max-w-4xl p-8">
      <h1 className="mb-6 font-brand text-2xl font-semibold text-vitamed-900">
        Editar paciente — {patient.first_name} {patient.last_name}
      </h1>
      <PatientForm
        patientId={params.id}
        initial={patient as Partial<PatientInput>}
        showClinical={isMedico}
      />
    </main>
  );
}
