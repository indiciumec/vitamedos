'use client';

import { useMemo, useState } from 'react';
import { useRouter } from 'next/navigation';
import { updateClinicSettingsAction } from '@/lib/actions';
import { toE164EC } from '@/lib/whatsapp';
import type { ClinicSettings } from '@/types/database.types';

const inputCls =
  'mt-1 w-full rounded-md border border-vitamed-200 px-3 py-2 text-sm focus:border-vitamed-500 focus:outline-none focus:ring-1 focus:ring-vitamed-500';

function Field({ label, children, className }: { label: string; children: React.ReactNode; className?: string }) {
  return (
    <label className={`block ${className ?? ''}`}>
      <span className="text-sm font-medium text-vitamed-900">{label}</span>
      {children}
    </label>
  );
}

export default function SettingsForm({ initial }: { initial: ClinicSettings }) {
  const router = useRouter();
  const [f, setF] = useState({
    clinic_name: initial.clinic_name ?? 'Vitamed',
    professional_name: initial.professional_name ?? '',
    professional_title: initial.professional_title ?? 'Medicina General',
    license_number: initial.license_number ?? '',
    address: initial.address ?? '',
    phone: initial.phone ?? '',
    whatsapp: initial.whatsapp ?? '',
    email: initial.email ?? '',
  });
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const set = (k: keyof typeof f) => (e: React.ChangeEvent<HTMLInputElement>) => {
    setSaved(false);
    setF((p) => ({ ...p, [k]: e.target.value }));
  };

  // Validación en vivo del WhatsApp (formato Ecuador)
  const waE164 = useMemo(() => toE164EC(f.whatsapp), [f.whatsapp]);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setSaving(true);
    const nn = (v: string) => (v.trim() === '' ? null : v.trim());
    const res = await updateClinicSettingsAction({
      clinic_name: f.clinic_name.trim() || 'Vitamed',
      professional_name: nn(f.professional_name),
      professional_title: nn(f.professional_title),
      license_number: nn(f.license_number),
      address: nn(f.address),
      phone: nn(f.phone),
      whatsapp: nn(f.whatsapp),
      email: nn(f.email),
    });
    setSaving(false);
    if (!res.ok) {
      setError(res.error);
      return;
    }
    setSaved(true);
    router.refresh();
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <section className="rounded-xl border border-vitamed-100 bg-white p-6">
        <h2 className="mb-4 text-sm font-semibold text-vitamed-900">Datos del consultorio</h2>
        <div className="grid gap-4 sm:grid-cols-2">
          <Field label="Nombre del consultorio *">
            <input required value={f.clinic_name} onChange={set('clinic_name')} className={inputCls} />
          </Field>
          <Field label="Profesional">
            <input value={f.professional_name} onChange={set('professional_name')} placeholder="Dra. Nombre Apellido" className={inputCls} />
          </Field>
          <Field label="Especialidad / título">
            <input value={f.professional_title} onChange={set('professional_title')} className={inputCls} />
          </Field>
          <Field label="Registro profesional (ACESS/Senescyt)">
            <input value={f.license_number} onChange={set('license_number')} className={inputCls} />
          </Field>
          <Field label="Dirección" className="sm:col-span-2">
            <input value={f.address} onChange={set('address')} className={inputCls} />
          </Field>
          <Field label="Teléfono">
            <input value={f.phone} onChange={set('phone')} className={inputCls} />
          </Field>
          <Field label="WhatsApp">
            <input
              value={f.whatsapp}
              onChange={set('whatsapp')}
              placeholder="09XXXXXXXX"
              className={`${inputCls} ${f.whatsapp && !waE164 ? 'border-red-400' : ''}`}
            />
            {f.whatsapp && (
              waE164 ? (
                <span className="mt-1 block text-xs text-emerald-700">✓ wa.me/{waE164}</span>
              ) : (
                <span className="mt-1 block text-xs text-red-600">
                  Formato inválido — usa 09XXXXXXXX (celular Ecuador)
                </span>
              )
            )}
          </Field>
          <Field label="Correo" className="sm:col-span-2">
            <input type="email" value={f.email} onChange={set('email')} className={inputCls} />
          </Field>
        </div>
      </section>

      {/* Preview del membrete en vivo */}
      <section className="rounded-xl border border-vitamed-100 bg-white p-6">
        <h2 className="mb-4 text-sm font-semibold text-vitamed-900">Vista previa del membrete</h2>
        <div className="rx-sheet rounded-lg border border-vitamed-200 p-4">
          <div className="flex items-start justify-between border-b-2 border-vitamed-500 pb-2">
            <div>
              <div className="font-brand text-lg font-bold text-vitamed-900">{f.clinic_name || 'Vitamed'}</div>
              {f.professional_name && (
                <div className="text-[11px] text-vitamed-600">
                  {f.professional_name}
                  {f.professional_title && ` · ${f.professional_title}`}
                </div>
              )}
              {f.license_number && (
                <div className="text-[11px] text-vitamed-600">Reg. {f.license_number}</div>
              )}
            </div>
            <div className="text-right text-[11px] text-vitamed-600">
              <div>RECETA N.º 000</div>
            </div>
          </div>
          <div className="py-6 text-center text-xs text-vitamed-300">— contenido de la receta —</div>
          <div className="flex items-end justify-between border-t border-dotted border-vitamed-200 pt-2">
            <div className="text-center">
              <div className="w-36 border-t border-vitamed-900 pt-0.5 text-[10px] text-vitamed-900">
                {f.professional_name || 'Firma'}
              </div>
            </div>
            <div className="text-right text-[10px] text-vitamed-600">
              {[f.address, f.phone].filter(Boolean).join(' · ')}
            </div>
          </div>
        </div>
      </section>

      {error && <p className="text-sm text-red-600">{error}</p>}

      <button
        type="submit"
        disabled={saving}
        className="rounded-md bg-vitamed-500 px-6 py-2.5 text-sm font-medium text-white hover:bg-vitamed-600 disabled:opacity-50"
      >
        {saving ? 'Guardando…' : saved ? 'Guardado ✓' : 'Guardar cambios'}
      </button>
    </form>
  );
}
