'use client';

import { useRef, useState } from 'react';
import { useRouter } from 'next/navigation';
import { issuePrescriptionAction, searchVademecumAction } from '@/lib/actions';
import type { DrugWithBrands } from '@/lib/queries/prescriptions';
import type { PatientBasic } from '@/types/database.types';
import PatientSearchSelect from '@/components/PatientSearchSelect';

type Item = {
  drug_catalog_id: string | null;
  generic_name_snapshot: string;
  concentration: string;
  pharmaceutical_form: string;
  route: string;
  quantity: string;
  dose: string;
  frequency: string;
  duration: string;
  instructions: string;
  optional_commercial_brand: string;
  brands: string[]; // sugerencias de marca del vademécum
};

const emptyItem = (): Item => ({
  drug_catalog_id: null,
  generic_name_snapshot: '',
  concentration: '',
  pharmaceutical_form: '',
  route: '',
  quantity: '',
  dose: '',
  frequency: '',
  duration: '',
  instructions: '',
  optional_commercial_brand: '',
  brands: [],
});

const inputCls =
  'mt-1 w-full rounded-md border border-vitamed-200 px-3 py-2 text-sm focus:border-vitamed-500 focus:outline-none focus:ring-1 focus:ring-vitamed-500';

type Props = {
  preselectedPatient: PatientBasic | null;
  consultationId: string | null;
};

export default function PrescriptionComposer({ preselectedPatient, consultationId }: Props) {
  const router = useRouter();
  const [patient, setPatient] = useState<PatientBasic | null>(preselectedPatient);
  const [diagnosisCode, setDiagnosisCode] = useState('');
  const [diagnosisText, setDiagnosisText] = useState('');
  const [items, setItems] = useState<Item[]>([emptyItem()]);
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  // Autocompletar por ítem
  const [acIndex, setAcIndex] = useState<number | null>(null);
  const [acResults, setAcResults] = useState<DrugWithBrands[]>([]);
  const acTimer = useRef<ReturnType<typeof setTimeout>>();

  const setItem = (i: number, patch: Partial<Item>) =>
    setItems((prev) => prev.map((it, idx) => (idx === i ? { ...it, ...patch } : it)));

  function onGenericChange(i: number, value: string) {
    setItem(i, { generic_name_snapshot: value, drug_catalog_id: null });
    clearTimeout(acTimer.current);
    if (value.trim().length < 2) {
      setAcResults([]);
      setAcIndex(null);
      return;
    }
    acTimer.current = setTimeout(async () => {
      const res = await searchVademecumAction(value);
      if (res.ok) {
        setAcResults(res.data);
        setAcIndex(i);
      }
    }, 250);
  }

  function pickDrug(i: number, d: DrugWithBrands) {
    const preferred = d.brands.find((b) => b.is_preferred && b.is_active);
    setItem(i, {
      drug_catalog_id: d.id,
      generic_name_snapshot: d.generic_name,
      concentration: d.concentration ?? '',
      pharmaceutical_form: d.pharmaceutical_form ?? '',
      route: d.route ?? '',
      quantity: d.usual_quantity ?? '',
      dose: d.usual_dose ?? '',
      frequency: d.usual_frequency ?? '',
      duration: d.usual_duration ?? '',
      instructions: d.usual_indications ?? '',
      optional_commercial_brand: preferred?.brand_name ?? '',
      brands: d.brands.filter((b) => b.is_active).map((b) => b.brand_name),
    });
    setAcIndex(null);
    setAcResults([]);
  }

  async function handleIssue() {
    if (!patient) {
      setError('Selecciona un paciente');
      return;
    }
    setError(null);
    setSaving(true);
    const nn = (v: string) => (v.trim() === '' ? null : v.trim());
    const res = await issuePrescriptionAction({
      patient_id: patient.id,
      consultation_id: consultationId,
      diagnosis_code: nn(diagnosisCode),
      diagnosis_text: nn(diagnosisText),
      items: items.map((it) => ({
        drug_catalog_id: it.drug_catalog_id,
        generic_name_snapshot: it.generic_name_snapshot.trim(),
        concentration: nn(it.concentration),
        pharmaceutical_form: nn(it.pharmaceutical_form),
        route: nn(it.route),
        quantity: nn(it.quantity),
        dose: nn(it.dose),
        frequency: nn(it.frequency),
        duration: nn(it.duration),
        instructions: nn(it.instructions),
        optional_commercial_brand: nn(it.optional_commercial_brand),
      })),
    });
    setSaving(false);
    if (!res.ok) {
      setError(res.error);
      return;
    }
    router.push(`/recetas/${res.data.id}`);
  }

  return (
    <div className="space-y-6">
      <section className="rounded-xl border border-vitamed-100 bg-white p-6">
        <span className="text-sm font-medium text-vitamed-900">Paciente *</span>
        <div className="mt-1">
          <PatientSearchSelect selected={patient} onSelect={(p) => setPatient(p ?? null)} />
        </div>
        <div className="mt-4 grid gap-4 sm:grid-cols-[140px_1fr]">
          <label className="block">
            <span className="text-sm font-medium text-vitamed-900">CIE-10</span>
            <input value={diagnosisCode} onChange={(e) => setDiagnosisCode(e.target.value)} className={inputCls} />
          </label>
          <label className="block">
            <span className="text-sm font-medium text-vitamed-900">Diagnóstico</span>
            <input value={diagnosisText} onChange={(e) => setDiagnosisText(e.target.value)} className={inputCls} />
          </label>
        </div>
      </section>

      {items.map((it, i) => (
        <section key={i} className="rounded-xl border border-vitamed-100 bg-white p-6">
          <div className="mb-4 flex items-center justify-between">
            <h2 className="text-sm font-semibold text-vitamed-900">Medicamento {i + 1}</h2>
            {items.length > 1 && (
              <button
                type="button"
                onClick={() => setItems((prev) => prev.filter((_, idx) => idx !== i))}
                className="text-xs text-red-600 hover:underline"
              >
                Quitar
              </button>
            )}
          </div>

          <div className="relative mb-4">
            <label className="block">
              <span className="text-sm font-medium text-vitamed-900">
                Genérico (DCI) * <span className="font-normal text-vitamed-500">— obligatorio</span>
              </span>
              <input
                value={it.generic_name_snapshot}
                onChange={(e) => onGenericChange(i, e.target.value)}
                onBlur={() => setTimeout(() => setAcIndex(null), 150)}
                placeholder="Escribe 2+ letras para buscar en el vademécum…"
                className={`${inputCls} font-medium`}
              />
            </label>
            {acIndex === i && acResults.length > 0 && (
              <ul className="absolute z-20 mt-1 max-h-56 w-full overflow-auto rounded-md border border-vitamed-100 bg-white shadow-lg">
                {acResults.map((d) => (
                  <li key={d.id}>
                    <button
                      type="button"
                      onMouseDown={() => pickDrug(i, d)}
                      className="w-full px-3 py-2 text-left hover:bg-vitamed-50"
                    >
                      <span className="text-sm font-medium text-vitamed-900">{d.generic_name}</span>
                      <span className="text-xs text-vitamed-600">
                        {' '}{d.concentration ?? ''} {d.pharmaceutical_form ?? ''}
                        {d.brands.length > 0 && ` · ${d.brands.map((b) => b.brand_name).join(', ')}`}
                      </span>
                    </button>
                  </li>
                ))}
              </ul>
            )}
          </div>

          <div className="grid gap-4 sm:grid-cols-3 lg:grid-cols-4">
            <label className="block">
              <span className="text-sm font-medium text-vitamed-900">Concentración</span>
              <input value={it.concentration} onChange={(e) => setItem(i, { concentration: e.target.value })} className={inputCls} />
            </label>
            <label className="block">
              <span className="text-sm font-medium text-vitamed-900">Forma</span>
              <input value={it.pharmaceutical_form} onChange={(e) => setItem(i, { pharmaceutical_form: e.target.value })} className={inputCls} />
            </label>
            <label className="block">
              <span className="text-sm font-medium text-vitamed-900">Vía</span>
              <input value={it.route} onChange={(e) => setItem(i, { route: e.target.value })} className={inputCls} />
            </label>
            <label className="block">
              <span className="text-sm font-medium text-vitamed-900">Cantidad</span>
              <input value={it.quantity} onChange={(e) => setItem(i, { quantity: e.target.value })} className={inputCls} />
            </label>
            <label className="block">
              <span className="text-sm font-medium text-vitamed-900">Dosis</span>
              <input value={it.dose} onChange={(e) => setItem(i, { dose: e.target.value })} className={inputCls} />
            </label>
            <label className="block">
              <span className="text-sm font-medium text-vitamed-900">Frecuencia</span>
              <input value={it.frequency} onChange={(e) => setItem(i, { frequency: e.target.value })} className={inputCls} />
            </label>
            <label className="block">
              <span className="text-sm font-medium text-vitamed-900">Duración</span>
              <input value={it.duration} onChange={(e) => setItem(i, { duration: e.target.value })} className={inputCls} />
            </label>
            <label className="block">
              <span className="text-sm font-medium text-vitamed-900">
                Marca <span className="font-normal text-vitamed-500">(opcional)</span>
              </span>
              <input
                value={it.optional_commercial_brand}
                onChange={(e) => setItem(i, { optional_commercial_brand: e.target.value })}
                list={`brands-${i}`}
                className={inputCls}
              />
              <datalist id={`brands-${i}`}>
                {it.brands.map((b) => <option key={b} value={b} />)}
              </datalist>
            </label>
            <label className="block sm:col-span-3 lg:col-span-4">
              <span className="text-sm font-medium text-vitamed-900">Indicaciones</span>
              <input value={it.instructions} onChange={(e) => setItem(i, { instructions: e.target.value })} className={inputCls} />
            </label>
          </div>
        </section>
      ))}

      <button
        type="button"
        onClick={() => setItems((prev) => [...prev, emptyItem()])}
        className="rounded-md border border-dashed border-vitamed-300 px-4 py-2 text-sm text-vitamed-700 hover:bg-vitamed-50"
      >
        + Agregar medicamento
      </button>

      {error && <p className="text-sm text-red-600">{error}</p>}

      <div>
        <button
          onClick={handleIssue}
          disabled={saving || !patient || items.some((it) => it.generic_name_snapshot.trim().length < 2)}
          className="rounded-md bg-vitamed-500 px-6 py-2.5 text-sm font-medium text-white hover:bg-vitamed-600 disabled:opacity-50"
        >
          {saving ? 'Emitiendo…' : 'Emitir receta'}
        </button>
      </div>
    </div>
  );
}
