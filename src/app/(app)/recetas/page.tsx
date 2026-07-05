import Link from 'next/link';
import { listRecentPrescriptions } from '@/lib/queries/extra';
import { formatDate } from '@/lib/utils';

export const dynamic = 'force-dynamic';

export default async function RecetasPage() {
  const recientes = await listRecentPrescriptions().catch(() => []);

  return (
    <main className="mx-auto max-w-3xl p-8">
      <header className="mb-6 flex items-center justify-between">
        <h1 className="font-brand text-2xl font-semibold text-vitamed-900">Recetas</h1>
        <Link
          href="/recetas/nueva"
          className="rounded-md bg-vitamed-500 px-4 py-2 text-sm font-medium text-white hover:bg-vitamed-600"
        >
          Nueva receta
        </Link>
      </header>

      <section className="rounded-xl border border-vitamed-100 bg-white">
        <h2 className="border-b border-vitamed-100 px-5 py-3 text-sm font-semibold text-vitamed-900">
          Emitidas recientemente
        </h2>
        {recientes.length === 0 ? (
          <p className="px-5 py-6 text-sm text-vitamed-500">Aún no hay recetas.</p>
        ) : (
          <ul className="divide-y divide-vitamed-50">
            {recientes.map((r) => (
              <li key={r.id}>
                <Link href={`/recetas/${r.id}`} className="flex items-center gap-3 px-5 py-3 hover:bg-vitamed-50">
                  <span className="w-24 shrink-0 text-sm tabular-nums text-vitamed-600">
                    {formatDate(r.issued_at)}
                  </span>
                  <span className="flex-1 truncate text-sm text-vitamed-900">
                    #{r.prescription_number} · {r.patient.first_name} {r.patient.last_name}
                    {r.diagnosis_text && <span className="text-vitamed-500"> · {r.diagnosis_text}</span>}
                  </span>
                  {r.status === 'anulada' && (
                    <span className="rounded-full bg-red-100 px-2.5 py-0.5 text-xs font-medium text-red-700">
                      Anulada
                    </span>
                  )}
                </Link>
              </li>
            ))}
          </ul>
        )}
      </section>
    </main>
  );
}
