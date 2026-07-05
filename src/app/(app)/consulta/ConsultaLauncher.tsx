'use client';

import { useRouter } from 'next/navigation';
import PatientSearchSelect from '@/components/PatientSearchSelect';

export default function ConsultaLauncher() {
  const router = useRouter();
  return (
    <PatientSearchSelect
      autoFocus
      onSelect={(p) => p && router.push(`/consulta/nueva?paciente=${p.id}`)}
    />
  );
}
