import { redirect } from 'next/navigation';
import { getCurrentProfile } from '@/lib/auth';
import Sidebar from '@/components/Sidebar';

export default async function AppLayout({ children }: { children: React.ReactNode }) {
  const profile = await getCurrentProfile();
  if (!profile || !profile.is_active) redirect('/login');

  return (
    <div className="flex min-h-screen">
      <Sidebar role={profile.role} name={profile.full_name} />
      <div className="min-w-0 flex-1">{children}</div>
    </div>
  );
}
