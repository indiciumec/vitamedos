import { getPatientBasic } from '@/lib/queries/extra';
import PrescriptionComposer from './PrescriptionComposer';

export const dynamic = 'force-dynamic';

type Search = { paciente?: string; consulta?: string };

export default async function NuevaRecetaPage({ searchParams }: { searchParams: Search }) {
  const preselected = searchParams.paciente
    ? await getPatientBasic(searchParams.paciente)
    : null;

  return (
    <main className="mx-auto max-w-4xl p-8">
      <h1 className="mb-6 font-brand text-2xl font-semibold text-vitamed-900">Nueva receta</h1>
      <PrescriptionComposer
        preselectedPatient={preselected}
        consultationId={searchParams.consulta ?? null}
      />
    </main>
  );
}
