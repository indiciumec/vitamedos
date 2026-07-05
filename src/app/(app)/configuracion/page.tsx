import { getClinicSettings } from '@/lib/queries/settings';
import SettingsForm from '@/components/settings-form';

export const dynamic = 'force-dynamic';

export default async function ConfiguracionPage() {
  const settings = await getClinicSettings().catch(() => null);

  return (
    <main className="mx-auto max-w-3xl p-8">
      <h1 className="mb-6 font-brand text-2xl font-semibold text-vitamed-900">Ajustes del consultorio</h1>
      {settings ? (
        <SettingsForm initial={settings} />
      ) : (
        <p className="rounded-lg border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-800">
          No se pudo cargar el perfil del consultorio. Verifica que la migración{' '}
          <code>003_clinic_settings.sql</code> esté ejecutada en Supabase.
        </p>
      )}
    </main>
  );
}
