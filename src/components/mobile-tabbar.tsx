'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import type { UserRole } from '@/types/database.types';

type Tab = { href: string; label: string; icon: string; roles: UserRole[] };

// Máx. 5 tabs por rol (HIG). "Ajustes" entra para admin (que no ve Recetas).
const TABS: Tab[] = [
  { href: '/panel', label: 'Hoy', icon: '☀️', roles: ['medico', 'recepcion', 'admin', 'tecnico'] },
  { href: '/agenda', label: 'Agenda', icon: '📅', roles: ['medico', 'recepcion', 'admin'] },
  { href: '/pacientes', label: 'Pacientes', icon: '👤', roles: ['medico', 'recepcion', 'admin'] },
  { href: '/recetas', label: 'Recetas', icon: '📄', roles: ['medico'] },
  { href: '/caja', label: 'Caja', icon: '💵', roles: ['recepcion', 'admin'] },
  { href: '/configuracion', label: 'Ajustes', icon: '⚙️', roles: ['admin'] },
];

export default function MobileTabbar({ role }: { role: UserRole }) {
  const pathname = usePathname();
  const tabs = TABS.filter((t) => t.roles.includes(role)).slice(0, 5);
  if (tabs.length === 0) return null;

  return (
    <nav className="mobile-tabbar no-print">
      {tabs.map((t) => {
        const active = pathname.startsWith(t.href);
        return (
          <Link
            key={t.href}
            href={t.href}
            className="flex flex-1 flex-col items-center gap-0.5 py-2 text-[10px] font-medium"
            style={{ color: active ? 'var(--color-vitamed-600)' : '#6b7280' }}
          >
            <span className="text-lg leading-none" aria-hidden>{t.icon}</span>
            {t.label}
          </Link>
        );
      })}
    </nav>
  );
}
