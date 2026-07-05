'use client';

import Link from 'next/link';
import { useRouter } from 'next/navigation';
import PatientSearchSelect from '@/components/PatientSearchSelect';

export default function PacientesPage() {
  const router = useRouter();

  return (
    <main className="mx-auto max-w-3xl p-8">
      <header className="mb-6 flex items-center justify-between">
        <h1 className="font-brand text-2xl font-semibold text-vitamed-900">Pacientes</h1>
        <Link
          href="/pacientes/nuevo"
          className="rounded-md bg-vitamed-500 px-4 py-2 text-sm font-medium text-white hover:bg-vitamed-600"
        >
          Nuevo paciente
        </Link>
      </header>

      <div className="rounded-xl border border-vitamed-100 bg-white p-6">
        <p className="mb-3 text-sm text-vitamed-600">
          Busca por cédula, nombre, apellido o teléfono.
        </p>
        <PatientSearchSelect
          autoFocus
          onSelect={(p) => p && router.push(`/pacientes/${p.id}`)}
        />
      </div>
    </main>
  );
}
