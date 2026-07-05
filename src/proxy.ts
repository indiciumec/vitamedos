// proxy.ts (Next 16; antes middleware.ts) — refresh de sesión + protección de rutas por rol
import { createServerClient } from '@supabase/ssr';
import { NextResponse, type NextRequest } from 'next/server';
import type { Database, UserRole } from '@/types/database.types';

const PUBLIC_ROUTES = ['/login', '/auth'];

// Prefijos de ruta → roles permitidos
const ROUTE_ROLES: Record<string, UserRole[]> = {
  '/consulta': ['medico'],
  '/recetas': ['medico'],
  '/vademecum': ['medico', 'admin'],
  '/historia': ['medico'],
  '/caja': ['recepcion', 'admin', 'medico'], // medico solo lectura (RLS lo garantiza)
  '/auditoria': ['admin'],
  '/configuracion': ['medico', 'admin'],
};

export default async function proxy(request: NextRequest) {
  let response = NextResponse.next({ request });

  const supabase = createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll: () => request.cookies.getAll(),
        setAll: (cookiesToSet) => {
          cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value));
          response = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) =>
            response.cookies.set(name, value, options)
          );
        },
      },
    }
  );

  const { data: { user } } = await supabase.auth.getUser();
  const path = request.nextUrl.pathname;
  const isPublic = PUBLIC_ROUTES.some((r) => path.startsWith(r));

  if (!user && !isPublic) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  if (user) {
    const guarded = Object.entries(ROUTE_ROLES).find(([prefix]) => path.startsWith(prefix));
    if (guarded) {
      const { data: profile } = await supabase
        .from('profiles')
        .select('role, is_active')
        .eq('id', user.id)
        .single();

      if (!profile?.is_active || !guarded[1].includes(profile.role)) {
        return NextResponse.redirect(new URL('/panel', request.url));
      }
    }
  }

  return response;
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|ico)$).*)'],
};
