import { getContactQueue, listRecentCommunications } from '@/lib/queries/communications';
import { getClinicSettings } from '@/lib/queries/settings';
import ContactosClient from './ContactosClient';

export const dynamic = 'force-dynamic';

export default async function ContactosPage() {
  const [queue, recent, clinic] = await Promise.all([
    getContactQueue().catch(() => null),
    listRecentCommunications().catch(() => []),
    getClinicSettings().catch(() => null),
  ]);

  return (
    <ContactosClient
      queue={queue}
      recent={recent}
      clinicName={clinic?.clinic_name ?? 'Vitamed'}
    />
  );
}
