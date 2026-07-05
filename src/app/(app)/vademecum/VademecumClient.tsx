'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { addBrandAction, upsertDrugAction } from '@/lib/actions';
import type { DrugWithBrands } from '@/lib/queries/prescriptions';
import type { DrugCatalogItem } from '@/types/database.types';

const inputCls =
  'mt-1 w-full rounded-md border border-vitamed-200 px-3 py-2 text-sm focus:border-vitamed-500 focus:outline-none focus:ring-1 focus:ring-vitamed-500';

const EMPTY: Record<string, string> = {
  generic_name: '', therapeutic_class: '', concentration: '', pharmaceutical_form: '',
  route: '', usual_quantity: '', usual_dose: '', usual_frequency: '', usual_duration: '',
  usual_indications: '', warnings: '',
};

export default function VademecumClient({ drugs }: { drugs: DrugWithBrands[] }) {
  const router = useRouter();
  const [filter, setFilter] = useState('');
  const [editingId, setEditingId] = useState<string | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [f, setF] = useState(EMPTY);
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [brandInputs, setBrandInputs] = useState<Record<string, string>>({});

  const set = (k: string) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) =>
    setF((p) => ({ ...p, [k]: e.target.value }));

  function startNew() {
    setEditingId(null);
    setF(EMPTY);
    setShowForm(true);
  }

  function startEdit(d: DrugCatalogItem) {
    setEditingId(d.id);
    setF({
      generic_name: d.generic_name,
      therapeutic_class: d.therapeutic_class ?? '',
      concentration: d.concentration ?? '',
      pharmaceutical_form: d.pharmaceutical_form ?? '',
      route: d.route ?? '',
      usual_quantity: d.usual_quantity ?? '',
      usual_dose: d.usual_dose ?? '',
      usual_frequency: d.usual_frequency ?? '',
      usual_duration: d.usual_duration ?? '',
      usual_indications: d.usual_indications ?? '',
      warnings: d.warnings ?? '',
    });
    setShowForm(true);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  async function handleSave(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setSaving(true);
    const nn = (v: string) => (v.trim() === '' ? null : v.trim());
    const res = await upsertDrugAction({
      ...(editingId ? { id: editingId } : {}),
      generic_name: f.generic_name.trim(),
      therapeutic_class: nn(f.therapeutic_class),
      concentration: nn(f.concentration),
      pharmaceutical_form: nn(f.pharmaceutical_form),
      route: nn(f.route),
      usual_quantity: nn(f.usual_quantity),
      usual_dose: nn(f.usual_dose),
      usual_frequency: nn(f.usual_frequency),
      usual_duration: nn(f.usual_duration),
      usual_indications: nn(f.usual_indications),
      warnings: nn(f.warnings),
      is_active: true,
    });
    setSaving(false);
    if (!res.ok) {
      setError(res.error);
      return;
    }
    setShowForm(false);
    router.refresh();
  }

  async function handleAddBrand(drugId: string) {
    const name = (brandInputs[drugId] ?? '').trim();
    if (name.length < 2) return;
    const res = await addBrandAction(drugId, name);
    if (!res.ok) {
      setError(res.error);
      return;
    }
    setBrandInputs((p) => ({ ...p, [drugId]: '' }));
    router.refresh();
  }

  async function toggleActive(d: DrugCatalogItem) {
    const res = await upsertDrugAction({ id: d.id, generic_name: d.generic_name, is_active: !d.is_active });
    if (!res.ok) setError(res.error);
    else router.refresh();
  }

  const filtered = drugs.filter((d) =>
    d.generic_name.toLowerCase().includes(filter.toLowerCase()) ||
    (d.therapeutic_class ?? '').toLowerCase().includes(filter.toLowerCase())
  );

  return (
    <main className="mx-auto max-w-5xl p-8">
      <header className="mb-6 flex items-center justify-between">
        <h1 className="font-brand text-2xl font-semibold text-vitamed-900">Vademécum</h1>
        <button onClick={startNew} className="rounded-md bg-vitamed-500 px-4 py-2 text-sm font-medium text-white hover:bg-vitamed-600">
          Nuevo fármaco
        </button>
      </header>

      {error && <p className="mb-4 text-sm text-red-600">{error}</p>}

      {showForm && (
        <form onSubmit={handleSave} className="mb-6 rounded-xl border border-vitamed-100 bg-white p-6">
          <h2 className="mb-4 text-sm font-semibold text-vitamed-900">
            {editingId ? 'Editar fármaco' : 'Nuevo fármaco'}
          </h2>
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            <label className="block lg:col-span-2">
              <span className="text-sm font-medium text-vitamed-900">Genérico (DCI) *</span>
              <input required value={f.generic_name} onChange={set('generic_name')} className={inputCls} />
            </label>
            <label className="block">
              <span className="text-sm font-medium text-vitamed-900">Clase terapéutica</span>
              <input value={f.therapeutic_class} onChange={set('therapeutic_class')} className={inputCls} />
            </label>
            <label className="block">
              <span className="text-sm font-medium text-vitamed-900">Concentración</span>
              <input value={f.concentration} onChange={set('concentration')} className={inputCls} />
            </label>
            <label className="block">
              <span className="text-sm font-medium text-vitamed-900">Forma farmacéutica</span>
              <input value={f.pharmaceutical_form} onChange={set('pharmaceutical_form')} className={inputCls} />
            </label>
            <label className="block">
              <span className="text-sm font-medium text-vitamed-900">Vía</span>
              <input value={f.route} onChange={set('route')} className={inputCls} />
            </label>
            <label className="block">
              <span className="text-sm font-medium text-vitamed-900">Cantidad usual</span>
              <input value={f.usual_quantity} onChange={set('usual_quantity')} className={inputCls} />
            </label>
            <label className="block">
              <span className="text-sm font-medium text-vitamed-900">Dosis usual</span>
              <input value={f.usual_dose} onChange={set('usual_dose')} className={inputCls} />
            </label>
            <label className="block">
              <span className="text-sm font-medium text-vitamed-900">Frecuencia usual</span>
              <input value={f.usual_frequency} onChange={set('usual_frequency')} className={inputCls} />
            </label>
            <label className="block">
              <span className="text-sm font-medium text-vitamed-900">Duración usual</span>
              <input value={f.usual_duration} onChange={set('usual_duration')} className={inputCls} />
            </label>
            <label className="block lg:col-span-2">
              <span className="text-sm font-medium text-vitamed-900">Indicaciones usuales</span>
              <input value={f.usual_indications} onChange={set('usual_indications')} className={inputCls} />
            </label>
            <label className="block lg:col-span-3">
              <span className="text-sm font-medium text-vitamed-900">Advertencias</span>
              <input value={f.warnings} onChange={set('warnings')} className={inputCls} />
            </label>
          </div>
          <div className="mt-4 flex gap-3">
            <button type="submit" disabled={saving} className="rounded-md bg-vitamed-500 px-5 py-2 text-sm font-medium text-white hover:bg-vitamed-600 disabled:opacity-50">
              {saving ? 'Guardando…' : 'Guardar'}
            </button>
            <button type="button" onClick={() => setShowForm(false)} className="rounded-md border border-vitamed-200 px-5 py-2 text-sm text-vitamed-800 hover:bg-vitamed-50">
              Cancelar
            </button>
          </div>
        </form>
      )}

      <div className="mb-4">
        <input
          value={filter}
          onChange={(e) => setFilter(e.target.value)}
          placeholder="Filtrar por genérico o clase…"
          className="w-full max-w-sm rounded-md border border-vitamed-200 px-3 py-2 text-sm focus:border-vitamed-500 focus:outline-none focus:ring-1 focus:ring-vitamed-500"
        />
      </div>

      <div className="overflow-x-auto rounded-xl border border-vitamed-100 bg-white">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-vitamed-100 text-left text-xs uppercase tracking-wide text-vitamed-600">
              <th className="px-4 py-3">Genérico (DCI)</th>
              <th className="px-4 py-3">Presentación</th>
              <th className="px-4 py-3">Marcas</th>
              <th className="px-4 py-3">Estado</th>
              <th className="px-4 py-3"></th>
            </tr>
          </thead>
          <tbody className="divide-y divide-vitamed-50">
            {filtered.map((d) => (
              <tr key={d.id} className={d.is_active ? '' : 'opacity-50'}>
                <td className="px-4 py-3">
                  <div className="font-medium text-vitamed-900">{d.generic_name}</div>
                  {d.therapeutic_class && <div className="text-xs text-vitamed-500">{d.therapeutic_class}</div>}
                </td>
                <td className="px-4 py-3 text-vitamed-800">
                  {[d.concentration, d.pharmaceutical_form, d.route].filter(Boolean).join(' · ') || '—'}
                </td>
                <td className="px-4 py-3">
                  <div className="flex flex-wrap items-center gap-1.5">
                    {d.brands.filter((b) => b.is_active).map((b) => (
                      <span key={b.id} className={`rounded-full px-2 py-0.5 text-xs ${b.is_preferred ? 'bg-vitamed-100 font-medium text-vitamed-800' : 'bg-slate-100 text-slate-700'}`}>
                        {b.brand_name}
                      </span>
                    ))}
                    <span className="inline-flex items-center gap-1">
                      <input
                        value={brandInputs[d.id] ?? ''}
                        onChange={(e) => setBrandInputs((p) => ({ ...p, [d.id]: e.target.value }))}
                        onKeyDown={(e) => e.key === 'Enter' && handleAddBrand(d.id)}
                        placeholder="+ marca"
                        className="w-20 rounded border border-vitamed-200 px-1.5 py-0.5 text-xs focus:border-vitamed-500 focus:outline-none"
                      />
                    </span>
                  </div>
                </td>
                <td className="px-4 py-3">
                  <button onClick={() => toggleActive(d)} className="text-xs text-vitamed-600 hover:underline">
                    {d.is_active ? 'Activo' : 'Inactivo'}
                  </button>
                </td>
                <td className="px-4 py-3 text-right">
                  <button onClick={() => startEdit(d)} className="text-xs font-medium text-vitamed-600 hover:underline">
                    Editar
                  </button>
                </td>
              </tr>
            ))}
            {filtered.length === 0 && (
              <tr>
                <td colSpan={5} className="px-4 py-6 text-center text-vitamed-500">Sin fármacos.</td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </main>
  );
}
