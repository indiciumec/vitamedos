import Link from 'next/link';
import { listMyDrafts } from '@/lib/queries/extra';
import { formatDate } from '@/lib/utils';
import ConsultaLauncher from './ConsultaLauncher';

export const dynamic = 'force-dynamic';

export default async function ConsultaPage() {
  const borradores = await listMyDrafts().catch(() => []);

  return (
    <main className="mx-auto max-w-3xl p-8">
      <h1 className="mb-6 font-brand text-2xl font-semibold text-vitamed-900">Consulta</h1>

      <div className="mb-6 rounded-xl border border-vitamed-100 bg-white p-6">
        <p className="mb-3 text-sm text-vitamed-600">
          Busca al paciente para iniciar una nueva consulta.
        </p>
        <ConsultaLauncher />
      </div>

      {borradores.length > 0 && (
        <section className="rounded-xl border border-vitamed-100 bg-white">
          <h2 className="border-b border-vitamed-100 px-5 py-3 text-sm font-semibold text-vitamed-900">
            Borradores abiertos
          </h2>
          <ul className="divide-y divide-vitamed-50">
            {borradores.map((c) => (
              <li key={c.id}>
                <Link href={`/consulta/${c.id}`} className="flex items-center gap-3 px-5 py-3 hover:bg-vitamed-50">
                  <span className="w-24 shrink-0 text-sm tabular-nums text-vitamed-600">
                    {formatDate(c.created_at)}
                  </span>
                  <span className="flex-1 truncate text-sm text-vitamed-900">
                    {c.patient.first_name} {c.patient.last_name}
                    {c.reason && <span className="text-vitamed-500"> · {c.reason}</span>}
                  </span>
                  <span className="rounded-full bg-amber-100 px-2.5 py-0.5 text-xs font-medium text-amber-800">
                    Borrador
                  </span>
                </Link>
              </li>
            ))}
          </ul>
        </section>
      )}
    </main>
  );
}
