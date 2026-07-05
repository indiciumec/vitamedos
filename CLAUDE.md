# Vitamed OS

Sistema médico para el consultorio Vitamed (Quito) y futuro producto comercial de Indicium para consultorios pequeños en Ecuador.

**Contrato de alcance:** [docs/VITAMED-OS-MASTER.md](docs/VITAMED-OS-MASTER.md) — leerlo antes de cualquier cambio de alcance. MVP = 6 módulos; nada fuera de v0.1 sin decisión explícita del owner.

## Stack
Next.js 14 (App Router, TypeScript strict, Tailwind) + Supabase (Auth con MFA TOTP, Postgres 15 con RLS, Storage en v0.2).

## Reglas innegociables
1. **DCI en 3 capas:** toda receta exige nombre genérico — Zod (validators) + Server Action + CHECK en BD. Nunca relajar una capa porque otra ya valida.
2. **Consultas cerradas son inmutables:** corrección solo vía enmienda vinculada (trigger `block_closed_consultation_edit`).
3. **Recepción nunca ve datos clínicos:** consume solo la vista `patients_basic` (LOPDP).
4. **Frontend solo con anon key + RLS.** La service role key jamás sale del entorno seguro.
5. **Datos reales solo en prod.** Desarrollo usa datos sintéticos (LOPDP).
6. Toda regla crítica vive en BD (trigger/check/RLS) + Server Action (requireRole/Zod) + UI.

## Estructura prevista
- `supabase/migrations/001_vitamed_mvp_schema.sql` — schema completo (13 tablas, vista patients_basic, triggers, RLS, seed).
- `src/types/database.types.ts` — tipos 1:1 con el schema.
- `src/lib/queries/*` — Server Actions por módulo (patients, appointments, consultations, prescriptions, documents, payments).
- `src/middleware.ts` — refresh de sesión + guard de rutas por rol (ROUTE_ROLES).

## Marca
- Paleta `vitamed` en Tailwind (derivada del logo): 500 `#1b9aaf` turquesa principal, 200 `#b3e9f0` celeste acento, 900 `#16455a` azul petróleo del wordmark. Usar siempre `vitamed-*`, no colores genéricos de Tailwind.
- Tipografía de marca: Quicksand (`font-brand`, var `--font-brand`) para wordmark y títulos; sans del sistema para el resto.
- Tagline: "Siempre Contigo".
- `public/logo.svg` es un placeholder vectorial aproximado — reemplazar por el arte oficial con el mismo nombre.

## Zona horaria
America/Guayaquil (UTC-05:00) — relevante para cierre de caja diario.
