import { getClinicSettings } from '@/lib/queries/settings';
import { getPatientBasic } from '@/lib/queries/extra';
import { formatDateLong, todayEC } from '@/lib/utils';
import { PrintButton } from '@/components/PrintControls';
import {
  ALIMENTOS_EC, CUCHARA, GABA_FUENTE, GRASAS_AZUCAR, MENSAJES_GABA, RECOMENDACIONES_GABA,
} from '@/lib/nutrition-ec';

export const dynamic = 'force-dynamic';

export default async function GuiaNutricionPage({ searchParams }: { searchParams: Promise<{ paciente?: string }> }) {
  const sp = await searchParams;
  const [clinic, patient] = await Promise.all([
    getClinicSettings().catch(() => null),
    sp.paciente ? getPatientBasic(sp.paciente) : Promise.resolve(null),
  ]);

  return (
    <main className="p-8 print:p-0">
      <style>{`@page { size: A4 portrait; margin: 14mm; }`}</style>
      <PrintButton />

      <div className="mx-auto w-full max-w-[180mm] rounded-lg border border-vitamed-200 bg-white p-8 print:max-w-none print:rounded-none print:border-0 print:p-0">
        <header className="mb-5 flex items-start justify-between border-b-2 border-vitamed-500 pb-3">
          <div>
            <div className="font-brand text-xl font-bold text-vitamed-900">{clinic?.clinic_name ?? 'Vitamed'}</div>
            <div className="text-sm font-semibold text-vitamed-700">Guía de alimentación saludable</div>
          </div>
          <div className="text-right text-[11px] text-vitamed-600">
            {patient && <div className="font-medium text-vitamed-900">{patient.first_name} {patient.last_name}</div>}
            <div>{formatDateLong(todayEC())}</div>
          </div>
        </header>

        {/* La Cuchara Saludable */}
        <section className="mb-5">
          <h2 className="mb-2 text-sm font-bold uppercase tracking-wide text-vitamed-700">La Cuchara Saludable</h2>
          <p className="mb-3 text-[12px] text-vitamed-600">Así se arma un plato equilibrado cada día:</p>
          <div className="flex overflow-hidden rounded-lg border border-vitamed-100">
            {CUCHARA.map((c) => (
              <div key={c.grupo} className="flex flex-col p-3" style={{ background: `${c.color}14`, flexGrow: c.porcion === '½' ? 2 : 1, flexBasis: 0 }}>
                <span className="text-lg font-bold" style={{ color: c.color }}>{c.porcion}</span>
                <span className="text-[12px] font-semibold text-vitamed-900">{c.grupo}</span>
                <span className="text-[10px] text-vitamed-600">{c.detalle}</span>
              </div>
            ))}
          </div>
          <p className="mt-1.5 text-[10px] italic text-vitamed-500">{GRASAS_AZUCAR}</p>
        </section>

        {/* Alimentos ecuatorianos */}
        <section className="mb-5">
          <h2 className="mb-2 text-sm font-bold uppercase tracking-wide text-vitamed-700">Alimentos de nuestra tierra</h2>
          <table className="w-full text-[11px]">
            <tbody>
              {ALIMENTOS_EC.map((g) => (
                <tr key={g.grupo} className="border-b border-vitamed-50 align-top">
                  <td className="w-40 py-1.5 pr-3 font-semibold text-vitamed-900">{g.grupo}</td>
                  <td className="py-1.5 text-vitamed-700">{g.ejemplos}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </section>

        <div className="grid grid-cols-2 gap-5">
          {/* Recomendaciones */}
          <section>
            <h2 className="mb-2 text-sm font-bold uppercase tracking-wide text-vitamed-700">Recomendaciones</h2>
            <ul className="space-y-1 text-[11px] text-vitamed-800">
              {RECOMENDACIONES_GABA.map((r, i) => (
                <li key={i} className="flex gap-1.5"><span className="text-vitamed-500">✓</span>{r}</li>
              ))}
            </ul>
          </section>

          {/* Mensajes clave */}
          <section>
            <h2 className="mb-2 text-sm font-bold uppercase tracking-wide text-vitamed-700">Para recordar</h2>
            <ul className="space-y-1 text-[11px] text-vitamed-800">
              {MENSAJES_GABA.slice(0, 6).map((m, i) => (
                <li key={i} className="flex gap-1.5"><span className="text-vitamed-400">•</span>{m}</li>
              ))}
            </ul>
          </section>
        </div>

        <footer className="mt-6 border-t border-vitamed-100 pt-2 text-[9px] text-vitamed-500">
          {GABA_FUENTE} Material educativo; no reemplaza la indicación de su médico.
          {clinic?.phone && ` · ${clinic.clinic_name ?? 'Vitamed'}: ${clinic.phone}`}
        </footer>
      </div>
    </main>
  );
}
