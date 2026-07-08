import Link from 'next/link';
import { listPatients } from '@/lib/queries/extra';
import WAButton from '@/components/wa-button';

export const dynamic = 'force-dynamic';

type Search = { q?: string; page?: string };

export default async function PacientesPage({ searchParams }: { searchParams: Promise<Search> }) {
  const sp = await searchParams;
  const q = (sp.q ?? '').trim();
  const page = Math.max(1, parseInt(sp.page ?? '1', 10) || 1);
  const { rows, total, pageSize } = await listPatients({ page, q }).catch(() => ({
    rows: [], total: 0, pageSize: 25,
  }));
  const totalPages = Math.max(1, Math.ceil(total / pageSize));
  const qs = (p: number) => `?${q ? `q=${encodeURIComponent(q)}&` : ''}page=${p}`;

  return (
    <main className="mx-auto max-w-3xl p-8">
      <header className="mb-6 flex items-center justify-between gap-3">
        <div>
          <h1 className="font-brand text-2xl font-semibold text-vitamed-900">Pacientes</h1>
          <p className="text-sm text-vitamed-600">{total} paciente(s){q && ` · filtro "${q}"`}</p>
        </div>
        <Link
          href="/pacientes/nuevo"
          className="shrink-0 rounded-md bg-vitamed-500 px-4 py-2 text-sm font-medium text-white hover:bg-vitamed-600"
        >
          Nuevo paciente
        </Link>
      </header>

      {/* Búsqueda (GET, filtra el directorio) */}
      <form method="get" className="mb-4 flex gap-2">
        <input
          type="text"
          name="q"
          defaultValue={q}
          placeholder="Buscar por cédula, nombre o teléfono…"
          className="w-full rounded-md border border-vitamed-200 px-3 py-2 text-sm focus:border-vitamed-500 focus:outline-none focus:ring-1 focus:ring-vitamed-500"
        />
        <button type="submit" className="rounded-md bg-vitamed-500 px-4 py-2 text-sm font-medium text-white hover:bg-vitamed-600">
          Buscar
        </button>
        {q && (
          <Link href="/pacientes" className="rounded-md border border-vitamed-200 px-4 py-2 text-sm text-vitamed-800 hover:bg-vitamed-50">
            Limpiar
          </Link>
        )}
      </form>

      <div className="overflow-hidden rounded-xl border border-vitamed-100 bg-white">
        {rows.length === 0 ? (
          <p className="px-5 py-8 text-center text-sm text-vitamed-500">
            {q ? 'Sin resultados para el filtro.' : 'Aún no hay pacientes.'}
          </p>
        ) : (
          <ul className="divide-y divide-vitamed-50">
            {rows.map((p) => (
              <li key={p.id} className="flex items-center gap-3 px-4 py-3 hover:bg-vitamed-50">
                <Link href={`/pacientes/${p.id}`} className="min-w-0 flex-1">
                  <div className="truncate text-sm font-medium text-vitamed-900">
                    {p.last_name} {p.first_name}
                  </div>
                  <div className="truncate text-xs text-vitamed-600">
                    {p.identification_number}
                    {p.age != null && ` · ${p.age} años`}
                    {p.phone && ` · ${p.phone}`}
                  </div>
                </Link>
                <WAButton compact label="WA" phone={p.whatsapp ?? p.phone} log={{ patientId: p.id, kind: 'manual' }} />
              </li>
            ))}
          </ul>
        )}
      </div>

      {/* Paginación */}
      {totalPages > 1 && (
        <nav className="mt-4 flex items-center justify-between text-sm">
          {page > 1 ? (
            <Link href={qs(page - 1)} className="rounded-md border border-vitamed-200 px-3 py-1.5 text-vitamed-800 hover:bg-vitamed-50">← Anterior</Link>
          ) : <span />}
          <span className="text-vitamed-500">Página {page} de {totalPages}</span>
          {page < totalPages ? (
            <Link href={qs(page + 1)} className="rounded-md border border-vitamed-200 px-3 py-1.5 text-vitamed-800 hover:bg-vitamed-50">Siguiente →</Link>
          ) : <span />}
        </nav>
      )}
    </main>
  );
}
