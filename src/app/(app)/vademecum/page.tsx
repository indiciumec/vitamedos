import { listDrugsWithBrands } from '@/lib/queries/extra';
import VademecumClient from './VademecumClient';

export const dynamic = 'force-dynamic';

export default async function VademecumPage() {
  const drugs = await listDrugsWithBrands().catch(() => []);
  return <VademecumClient drugs={drugs} />;
}
