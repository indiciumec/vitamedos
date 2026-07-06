import { getCurrentProfile } from '@/lib/auth';
import { listInternalNotes } from '@/lib/queries/internal';
import PendientesClient from './PendientesClient';

export const dynamic = 'force-dynamic';

export default async function PendientesPage() {
  const profile = (await getCurrentProfile())!;
  const notes = await listInternalNotes().catch(() => null);

  return <PendientesClient notes={notes} role={profile.role} />;
}
