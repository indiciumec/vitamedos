import { getCurrentProfile } from '@/lib/auth';
import PatientForm from '@/components/PatientForm';

export default async function NuevoPacientePage() {
  const profile = (await getCurrentProfile())!;

  return (
    <main className="mx-auto max-w-4xl p-8">
      <h1 className="mb-6 font-brand text-2xl font-semibold text-vitamed-900">Nuevo paciente</h1>
      <PatientForm showClinical={profile.role === 'medico'} />
    </main>
  );
}
