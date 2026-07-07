'use client';

import { interpretBMI, type Sex } from '@/lib/bmi';

type Band = { label: string; rango: string; color: string; min: number; max: number };

const C = { low: '#e0a800', ok: '#22a06b', over: '#f08c00', obes: '#e03131' };

function adultBands(): Band[] {
  return [
    { label: 'Bajo peso', rango: '< 18.5', color: C.low, min: 0, max: 18.5 },
    { label: 'Normal', rango: '18.5 – 24.9', color: C.ok, min: 18.5, max: 25 },
    { label: 'Sobrepeso', rango: '25 – 29.9', color: C.over, min: 25, max: 30 },
    { label: 'Obesidad', rango: '≥ 30', color: C.obes, min: 30, max: 100 },
  ];
}

function childBands(cutoffs: { bmi: number; label: string }[]): Band[] {
  const [n2, p1, p2] = cutoffs.map((c) => c.bmi);
  return [
    { label: 'Delgadez', rango: `< ${n2} (−2DE)`, color: C.low, min: 0, max: n2 },
    { label: 'Normal', rango: `${n2} – ${p1}`, color: C.ok, min: n2, max: p1 },
    { label: 'Sobrepeso', rango: `${p1} – ${p2} (+1 a +2DE)`, color: C.over, min: p1, max: p2 },
    { label: 'Obesidad', rango: `≥ ${p2} (+2DE)`, color: C.obes, min: p2, max: 100 },
  ];
}

export default function BMIIndicator({
  bmi, ageYears, sex,
}: { bmi: number | null | undefined; ageYears: number | null | undefined; sex: Sex }) {
  const r = interpretBMI(bmi, ageYears, sex);
  if (!r) return null;

  if (r.scale === 'ninguna') {
    return (
      <div className="rounded-lg border border-vitamed-100 bg-vitamed-50 px-4 py-3 text-xs text-vitamed-600">
        IMC {r.bmi} — {r.detail}
      </div>
    );
  }

  const bands = r.scale === 'pediatrico' && r.cutoffs ? childBands(r.cutoffs) : adultBands();
  const activeIdx = bands.findIndex((b) => r.bmi >= b.min && r.bmi < b.max);
  const axisMin = Math.max(10, Math.floor((r.cutoffs?.[0]?.bmi ?? 18.5) - 4));
  const axisMax = Math.min(45, Math.ceil((r.cutoffs?.[r.cutoffs.length - 1]?.bmi ?? 40) + 5));
  const pct = (v: number) => Math.max(0, Math.min(100, ((v - axisMin) / (axisMax - axisMin)) * 100));

  return (
    <div className="rounded-xl border border-vitamed-100 bg-white p-4">
      <div className="mb-3 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <span className="inline-block h-3 w-3 rounded-full" style={{ background: r.color }} />
          <span className="text-sm font-semibold text-vitamed-900">IMC {r.bmi} · {r.label}</span>
        </div>
        <span className="text-[11px] text-vitamed-500">
          {r.scale === 'pediatrico' ? 'Escala pediátrica OMS (por edad y sexo)' : 'Escala adulto OMS'}
        </span>
      </div>
      <p className="mb-3 text-xs text-vitamed-600">{r.detail}</p>

      {/* Barra con bandas y marcador */}
      <div className="relative mb-1 h-3 w-full overflow-hidden rounded-full">
        {bands.map((b, i) => {
          const left = pct(Math.max(b.min, axisMin));
          const right = pct(Math.min(b.max, axisMax));
          return <span key={i} className="absolute top-0 h-full" style={{ left: `${left}%`, width: `${right - left}%`, background: b.color, opacity: 0.85 }} />;
        })}
        <span
          className="absolute top-[-2px] h-[calc(100%+4px)] w-0.5 bg-vitamed-950"
          style={{ left: `${pct(r.bmi)}%` }}
          title={`IMC ${r.bmi}`}
        />
      </div>
      <div className="relative mb-3 h-4 text-[9px] text-vitamed-500">
        {(r.cutoffs ?? []).map((c, i) => (
          <span key={i} className="absolute -translate-x-1/2" style={{ left: `${pct(c.bmi)}%` }}>{c.bmi}</span>
        ))}
      </div>

      {/* Tabla comparativa */}
      <table className="w-full text-xs">
        <tbody>
          {bands.map((b, i) => (
            <tr key={i} className={i === activeIdx ? 'font-semibold' : ''}>
              <td className="py-0.5">
                <span className="mr-1.5 inline-block h-2 w-2 rounded-full align-middle" style={{ background: b.color }} />
                {b.label}
                {i === activeIdx && <span className="ml-1 text-vitamed-600">◀ paciente</span>}
              </td>
              <td className="py-0.5 text-right tabular-nums text-vitamed-600">{b.rango}</td>
            </tr>
          ))}
        </tbody>
      </table>
      <p className="mt-2 text-[10px] text-vitamed-400">
        Referencia OMS. Apoyo clínico; la valoración final es del médico.
      </p>
    </div>
  );
}
