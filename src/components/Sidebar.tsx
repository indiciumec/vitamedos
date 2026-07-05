'use client';

import Image from 'next/image';
import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';
import type { UserRole } from '@/types/database.types';

const NAV: { href: string; label: string; roles: UserRole[] }[] = [
  { href: '/panel', label: 'Panel', roles: ['medico', 'recepcion', 'admin', 'tecnico'] },
  { href: '/agenda', label: 'Agenda', roles: ['medico', 'recepcion', 'admin'] },
  { href: '/pacientes', label: 'Pacientes', roles: ['medico', 'recepcion', 'admin'] },
  { href: '/consulta', label: 'Consulta', roles: ['medico'] },
  { href: '/recetas', label: 'Recetas', roles: ['medico'] },
  { href: '/documentos', label: 'Documentos', roles: ['medico'] },
  { href: '/vademecum', label: 'Vademécum', roles: ['medico', 'admin'] },
  { href: '/caja', label: 'Caja', roles: ['medico', 'recepcion', 'admin'] },
  { href: '/configuracion', label: 'Ajustes', roles: ['medico', 'admin'] },
];

const ROLE_LABELS: Record<UserRole, string> = {
  medico: 'Médico',
  recepcion: 'Recepción',
  admin: 'Administración',
  tecnico: 'Técnico',
};

export default function Sidebar({ role, name }: { role: UserRole; name: string }) {
  const pathname = usePathname();
  const router = useRouter();

  async function handleLogout() {
    await createClient().auth.signOut();
    router.push('/login');
    router.refresh();
  }

  return (
    <aside className="no-print desktop-only flex w-56 shrink-0 flex-col border-r border-vitamed-100 bg-white">
      <div className="flex items-center gap-3 px-5 py-5">
        <Image src="/logo.svg" alt="Vitamed" width={36} height={36} />
        <div>
          <div className="font-brand text-lg font-semibold leading-tight text-vitamed-900">Vitamed</div>
          <div className="font-brand text-[11px] text-vitamed-400">Siempre Contigo</div>
        </div>
      </div>

      <nav className="flex-1 space-y-0.5 px-3">
        {NAV.filter((item) => item.roles.includes(role)).map((item) => {
          const active = pathname.startsWith(item.href);
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`block rounded-md px-3 py-2 text-sm font-medium transition-colors ${
                active
                  ? 'bg-vitamed-500 text-white'
                  : 'text-vitamed-800 hover:bg-vitamed-50'
              }`}
            >
              {item.label}
            </Link>
          );
        })}
      </nav>

      <div className="border-t border-vitamed-100 px-5 py-4">
        <div className="truncate text-sm font-medium text-vitamed-900">{name}</div>
        <div className="text-xs text-vitamed-500">{ROLE_LABELS[role]}</div>
        <button
          onClick={handleLogout}
          className="mt-2 text-xs text-vitamed-600 underline-offset-2 hover:underline"
        >
          Cerrar sesión
        </button>
      </div>
    </aside>
  );
}
