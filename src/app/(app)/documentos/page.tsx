import { getCurrentProfile } from '@/lib/auth';
import { getTemplates } from '@/lib/queries/documents';
import { getPatientBasic, listRecentDocuments } from '@/lib/queries/extra';
import DocumentosClient from './DocumentosClient';

export const dynamic = 'force-dynamic';

type Search = { paciente?: string; consulta?: string };

export default async function DocumentosPage({ searchParams }: { searchParams: Promise<Search> }) {
  const sp = await searchParams;
  const profile = (await getCurrentProfile())!;
  const [templates, recientes, preselected] = await Promise.all([
    getTemplates().catch(() => []),
    listRecentDocuments().catch(() => []),
    sp.paciente ? getPatientBasic(sp.paciente) : Promise.resolve(null),
  ]);

  return (
    <DocumentosClient
      doctorName={profile.full_name}
      templates={templates}
      recientes={recientes}
      preselectedPatient={preselected}
      consultationId={sp.consulta ?? null}
    />
  );
}
