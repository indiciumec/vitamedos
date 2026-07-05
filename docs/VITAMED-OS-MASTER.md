# Vitamed OS — Documento Maestro del Proyecto
**Versión:** 1.0 · **Fecha:** 2026-07-04 · **Owner:** Indicium S.A.
**Estado:** Schema SQL + capa TS entregados · Frontend pendiente
---
## 1. Contexto
Sistema médico propio para el consultorio Vitamed (unipersonal, Quito), motivado por el alza de DoctorPad ($20 → $55/mes). El ROI directo ($660/año) no justifica el desarrollo; la justificación real es **producto comercial de Indicium para consultorios pequeños en Ecuador**, con Vitamed como cliente cero y ambiente de validación (patrón Agmatice/Tecnopalm).
**Flujo rector:** Agenda → Recepción → Paciente → Consulta → Receta/Documento → Caja → Seguimiento.
---
## 2. Decisiones estratégicas tomadas
| # | Decisión | Razón |
|---|---|---|
| 1 | Stack: Next.js 14 + Supabase (descartado NestJS/FastAPI) | Stack dominado por Indicium; RLS, Auth+2FA, Storage y audit en una sola pieza |
| 2 | MVP recortado a 6 módulos (no 14 pantallas) | 3 semanas realistas vs. 4-6 optimistas |
| 3 | Regla DCI en 3 capas: Zod → Server Action → CHECK en BD | Imposible emitir receta sin genérico desde ningún punto de entrada |
| 4 | Consultas cerradas inmutables vía trigger; corrección = enmienda vinculada | Cumplimiento de auditoría clínica sin edición de registros |
| 5 | Snapshot de alergias en cada receta emitida | La receta refleja lo conocido al momento de emitir |
| 6 | Recepción consume vista `patients_basic` (sin columnas clínicas) | LOPDP: separación datos administrativos / datos de salud |
| 7 | Auditoría por triggers en 7 tablas + log de lectura de historia clínica | Trazabilidad completa desde día uno, sin costo de desarrollo posterior |
| 8 | Signos vitales como JSONB en `consultations` | Tabla aparte es overhead para consultorio unipersonal |
| 9 | Exportar TODO de DoctorPad antes de cancelar | Riesgo de bloqueo de datos por el proveedor |
| 10 | Facturación SRI, portal paciente, campañas: diferidos indefinidamente | No bloquean la salida de DoctorPad |
---
## 3. Alcance
### 3.1 MVP v0.1 (~3 semanas)
| Módulo | Contenido |
|---|---|
| Pacientes | Ficha única, búsqueda trigram (<10 seg), consentimiento LOPDP |
| Agenda | Vista día/semana, máquina de estados, anti-solapamiento |
| Consulta | Borrador → cierre inmutable → enmienda; CIE-10, signos vitales, IMC auto |
| Receta + Vademécum | DCI obligatorio, marca opcional separada, autocompletar, QR token |
| Documentos | Plantillas con placeholders {{clave}}, numeración secuencial |
| Caja | Pago/pendiente/cortesía, cierre diario por método (TZ -05:00) |
Transversal: Auth con roles (medico/recepcion/admin/tecnico), RLS completa, auditoría automática, 2FA para médico y admin.
### 3.2 v0.2
Sala de espera kanban · Adjuntos clínicos (Storage privado + signed URLs 15 min) · Panel diario · Auditoría visible en UI · WhatsApp manual con plantillas.
### 3.3 Diferido indefinidamente
Facturación electrónica SRI · Portal paciente · Campañas · Insumos · Telemedicina · Multi-sede.
### 3.4 Fase comercial (según validación)
Multi-médico, multi-consultorio, planes de suscripción, onboarding, métricas SaaS. Sinergia: alianza LOPDP con Dr. Chasillacta como argumento de venta.
---
## 4. Arquitectura
```
Next.js 14 (App Router, TS strict, Tailwind)
│
├── middleware.ts ── refresh sesión + guard rutas por rol
├── Server Actions (lib/queries/*) ── requireRole() + Zod
│
└── Supabase
    ├── Auth (email+pass, MFA TOTP para medico/admin)
    ├── Postgres 15 + RLS por rol
    │   ├── Triggers: auditoría (7 tablas), inmutabilidad, updated_at
    │   └── Funciones: current_role(), patient_age(), log_clinical_access()
    └── Storage (v0.2): bucket privado clinical-files
```
**Defensa en profundidad:** cada regla crítica vive en BD (trigger/check/RLS) + Server Action (requireRole/Zod) + UI. La BD es la última línea, no la única.
---
## 5. Modelo de datos (resumen)
**13 tablas:** profiles · patients · services · appointments · consultations · drug_catalog · commercial_brands · prescriptions · prescription_items · document_templates · medical_documents · payments · audit_logs.
**1 vista:** patients_basic (recepción). **Seed:** 8 fármacos + marcas, 3 servicios.
### Matriz de permisos (RLS)
| Recurso | Médico | Recepción | Admin | Técnico |
|---|---|---|---|---|
| Pacientes (completo) | RW | — (solo vista basic RW) | R | — |
| Agenda | RW | RW | RW | — |
| Consultas | RW | — | — | — |
| Recetas | RW | — | — | — |
| Vademécum | RW | — | RW | — |
| Documentos | RW | — | plantillas | — |
| Caja | R | RW | RW | — |
| Auditoría | — | — | R | infra |
### Reglas de integridad en BD
1. `prescription_items.generic_name_snapshot` NOT NULL + CHECK no-vacío (DCI).
2. Trigger `block_closed_consultation_edit`: consulta cerrada/anulada solo transiciona a `enmendada` con vínculo.
3. Triggers de auditoría en tablas sensibles (INSERT/UPDATE/DELETE) + `log_clinical_access()` para lecturas.
4. `audit_logs`: escritura solo vía trigger SECURITY DEFINER; lectura solo admin.
---
## 6. Capa TypeScript (entregada)
```
src/
├── types/database.types.ts      # Tipos 1:1 con schema + Database<supabase-js>
├── middleware.ts                # Sesión + ROUTE_ROLES por prefijo
└── lib/
    ├── supabase/{client,server}.ts   # @supabase/ssr
    ├── auth.ts                       # getCurrentProfile, requireRole
    ├── validators.ts                 # Zod + validador cédula EC (módulo 10)
    └── queries/                      # Server Actions
        ├── patients.ts        # búsqueda unificada, ficha con log de acceso
        ├── appointments.ts    # transiciones válidas + anti-solapamiento
        ├── consultations.ts   # draft → close → amend
        ├── prescriptions.ts   # issuePrescription (snapshot alergias), vademécum
        ├── documents.ts       # resolveTemplate + issueDocument
        └── payments.ts        # registerPayment, settlePending, getDailyCash
```
**Deuda técnica conocida:** rollback manual en `issuePrescription` → migrar a función Postgres transaccional cuando toque.
---
## 7. Riesgos
| Riesgo | Impacto | Mitigación |
|---|---|---|
| Bus factor 1 (David) sobre operación clínica materna | Alto | Backups automáticos + plan B documentado ("volver a papel un día") |
| DoctorPad bloquea exportación | Alto | Exportar antes de cancelar; primer sprint si hay fricción |
| Scope creep hacia las 14 pantallas del doc original | Medio | Este documento es el contrato de alcance; v0.2 solo tras uso real |
| Datos reales en desarrollo | Alto (LOPDP) | Ambiente dev con datos sintéticos; prod separado |
| Service role key expuesta | Crítico | Solo anon key + RLS en frontend; regla escrita en schema |
---
## 8. Criterios de éxito MVP
- Consulta completa sin papel.
- Paciente encontrado en <10 segundos.
- Receta emitida en <1 minuto, genérico visualmente dominante, marca separada.
- Certificado desde plantilla sin escribir de cero.
- Cierre de caja diario claro: pagado / pendiente / método.
- Todo respaldado y auditado sin acción manual.
---
## 9. Ejecución
### Inmediato
1. **Exportar datos de DoctorPad** (pacientes, historias, adjuntos) — bloqueante.
2. Crear proyecto Supabase → correr `001_vitamed_mvp_schema.sql`.
3. Crear usuario médico en Auth + insertar en `profiles` (rol `medico`) + activar MFA.
4. `create-next-app` + copiar `src/` + `npm i @supabase/supabase-js @supabase/ssr zod`.
### Sprint 1 (sem. 1-2): Consulta + Receta
Pantalla de consulta (borrador/cierre) · emisión de receta con autocompletar vademécum · impresión A5 con QR · CRUD vademécum.
### Sprint 2 (sem. 2-3): Pacientes + Agenda
Búsqueda + ficha + historial · agenda día/semana con estados · script de importación CSV desde export DoctorPad.
### Sprint 3 (sem. 3): Caja + salida
Registro de pagos + cierre diario · plantillas de documentos iniciales · piloto en paralelo con DoctorPad 2 semanas → cancelar suscripción.
### Operación
Backups: PITR (Supabase Pro) o pg_dump diario cifrado a R2 · retención 7d/4s/6m · prueba de restauración mensual.
---
## 10. Modelo de negocio futuro (referencia)
- **Cliente cero:** Vitamed (gratis, validación).
- **Target:** consultorios unipersonales/pequeños Ecuador, precio ancla vs. DoctorPad ($55/mes) → posicionar $25-35/mes.
- **Diferenciadores:** DCI nativo, LOPDP desde diseño (alianza Chasillacta), exportación de datos garantizada (el dolor que motivó este proyecto).
- **Regla de pricing Indicium:** costos de cómputo/infra como línea explícita, COGS ≤20-30% del revenue.
- **Gate de decisión:** no invertir en multi-tenant hasta que Vitamed opere 3 meses estable y existan ≥2 prospectos con intención de pago.
