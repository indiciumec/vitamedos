import { getCurrentProfile } from '@/lib/auth';
import { getTemplates } from '@/lib/queries/documents';
import { getPatientBasic, listRecentDocuments } from '@/lib/queries/extra';
import DocumentosClient from './DocumentosClient';

export const dynamic = 'force-dynamic';

type Search = { paciente?: string; consulta?: string };

export default async function DocumentosPage({ searchParams }: { searchParams: Search }) {
  const profile = (await getCurrentProfile())!;
  const [templates, recientes, preselected] = await Promise.all([
    getTemplates().catch(() => []),
    listRecentDocuments().catch(() => []),
    searchParams.paciente ? getPatientBasic(searchParams.paciente) : Promise.resolve(null),
  ]);

  return (
    <DocumentosClient
      doctorName={profile.full_name}
      templates={templates}
      recientes={recientes}
      preselectedPatient={preselected}
      consultationId={searchParams.consulta ?? null}
    />
  );
}
