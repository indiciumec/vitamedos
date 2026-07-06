# Vitamed OS — Propuesta de mejora de flujo y pantallas
**Versión:** 1.0 · **Fecha:** 2026-07-06 · **Estado:** propuesta para decisión del owner

Documento de diseño para mejorar las pantallas de Vitamed sin romper el contrato de alcance
([VITAMED-OS-MASTER.md](VITAMED-OS-MASTER.md)). Todo lo marcado **[v0.1]** es pulido de UX sobre
los 6 módulos existentes y se puede hacer ya. Todo lo marcado **[v0.2]** implica capacidad nueva
y requiere decisión explícita antes de construirse.

Síntesis de dos líneas de investigación: (1) benchmark de flujo de productos de consultorio
(DoctorPad, Nimbo, Huli, Medesk, Doctoralia, AgendaPro, SimplePractice, Jane) y (2) UX de historia
clínica electrónica y trazabilidad (patrones de timeline, carga de documentación, nota SOAP,
lista de problemas, normativa MSP Ecuador).

---

## 1. Diagnóstico del flujo actual

El flujo rector **Agenda → Recepción → Paciente → Consulta → Receta/Documento → Caja → Seguimiento**
ya está completo y es correcto. Los puntos de fricción están en cómo se presenta la información,
no en la arquitectura:

| # | Fricción observada hoy | Impacto |
|---|---|---|
| 1 | La **ficha del paciente** muestra 3 listas separadas (consultas, recetas, documentos). El médico no ve la cronología unificada de "qué pasó con este paciente". | Alto |
| 2 | Durante la **consulta**, el médico no ve la consulta anterior ni la medicación vigente sin salir de la pantalla. Escribe "a ciegas". | Alto |
| 3 | No existe **lista de problemas** ni **medicación crónica activa** persistente: cada consulta repite el diagnóstico desde cero. | Alto |
| 4 | La nota de consulta es un formulario largo de campos sueltos; no hay **texto rápido / frases favoritas** → más tecleo. | Medio |
| 5 | El **panel del día** es informativo pero no es un "tablero de trabajo": no distingue quién está en sala, quién falta por atender. | Medio |
| 6 | El **seguimiento** depende de que el médico recuerde: no hay lista de "controles pendientes" ni "pacientes sin volver". | Medio |
| 7 | La **inmutabilidad y las enmiendas** existen en BD pero se comunican poco visualmente (badges pequeños). | Bajo |

---

## 2. Patrones ganadores (benchmark + literatura UX)

Lo que repiten los productos bien evaluados y la evidencia de usabilidad de EHR:

1. **Timeline unificado del paciente.** Una sola cronología inversa (lo más reciente arriba) que
   mezcla consultas, recetas, documentos, pagos y citas, con filtros por tipo. Reemplaza las
   pestañas-por-tipo, que obligan a reconstruir mentalmente la historia.
2. **Panel de contexto siempre visible en la consulta.** Columna lateral fija con alergias,
   problemas activos, medicación vigente y resumen de la última consulta. El médico documenta sin
   perder el contexto (reduce errores y "clic-fatiga").
3. **Reutilizar en vez de re-teclear.** "Copiar de consulta anterior", frases favoritas,
   plantillas de nota por motivo frecuente. La carga de documentación ("pajama time") es la queja
   #1 de los médicos con EHR.
4. **Problem list + medicación activa** como listas vivas del paciente, separadas del diagnóstico
   puntual de cada consulta. Es el corazón de la continuidad asistencial.
5. **Nota SOAP ligera.** Subjetivo / Objetivo / Evaluación (Dx) / Plan, pero sin obligar a llenar
   todo. Medicina general usa pocos campos; el resto sobra y molesta.
6. **Tablero del día accionable**, no solo informativo: estado de cada cita (en sala, en consulta,
   atendido) y el siguiente paso a un clic.
7. **Seguimiento proactivo**: lista de controles agendados que se acercan y pacientes que no
   vuelven hace X meses.
8. **Búsqueda global** (paciente por cédula/nombre desde cualquier pantalla, atajo de teclado).
9. **Acciones de un clic** en cada fila (llamar, WhatsApp, ver ficha) sin abrir menús.
10. **Feedback de estado claro**: guardado/borrador/cerrado siempre visibles, sin ambigüedad.

**Antipatrones a evitar** (críticas recurrentes en reviews): formularios de decenas de campos
obligatorios; enterrar la información clínica bajo pestañas; obligar a navegar fuera de la consulta
para ver el historial; recetas donde la marca comercial domina sobre el genérico (Vitamed ya lo
hace bien); y flujos que asumen recepcionista dedicada cuando el médico trabaja solo.

---

## 3. Normativa MSP Ecuador (mínimos a respetar)

Para un consultorio privado ambulatorio, lo esencial que la historia clínica debe contener y que
Vitamed ya cubre o debe garantizar:

- **Identificación del paciente** y datos de filiación — ✅ ya existe.
- **Motivo de consulta y enfermedad actual** — ✅ campos en consulta.
- **Diagnóstico codificado en CIE-10** — ✅ campo `diagnosis_code`; recomendable volverlo
  **buscador CIE-10** en vez de texto libre (ver §4.3).
- **Plan de tratamiento y prescripción con nombre genérico (DCI)** — ✅ regla DCI en 3 capas.
- **Consentimiento informado / de datos (LOPDP)** — ✅ flag + plantilla de documento.
- **Registro fechado e inalterable, con enmiendas trazables** — ✅ inmutabilidad + auditoría en BD.

No hay obligación para un consultorio privado de usar los formularios hospitalarios (008 emergencia,
002 hospitalización). La estructura de nota tipo SOAP con CIE-10 es suficiente y estándar.

---

## 4. Mejoras concretas, pantalla por pantalla

### 4.1 Ficha del paciente → Timeline unificado **[v0.1]**
**Qué:** reemplazar las 3 listas separadas por una cronología única con chips de filtro
(Todo · Consultas · Recetas · Documentos · Pagos). Cada ítem: fecha, ícono de tipo, título,
badge de estado, y acción rápida (ver/imprimir).
**Por qué:** patrón #1. El médico entiende "la historia" de un vistazo.
**Esfuerzo:** medio. Requiere una query que una las 4 fuentes por fecha (ya existen todas las
lecturas; es agregarlas y ordenarlas). Sin cambios de BD.

### 4.2 Panel de contexto clínico en la consulta **[v0.1]**
**Qué:** columna lateral fija (colapsable en móvil) durante `consulta/nueva` y `consulta/[id]`
con: **alergias** (rojo), **última consulta** (motivo + Dx + fecha), **medicación activa** y
**problemas activos** (cuando existan, §4.4). Botón "Copiar de la anterior" que precarga
motivo/plan.
**Por qué:** patrones #2 y #3, los de mayor impacto clínico.
**Esfuerzo:** medio. La última consulta ya se puede leer; el resto entra cuando exista §4.4.

### 4.3 Nota de consulta: SOAP ligero + texto rápido **[v0.1]**
**Qué:** reagrupar los campos actuales bajo encabezados S/O/A/P (sin volverlos obligatorios) y
añadir **frases favoritas** por campo (guardar/insertar textos frecuentes) y un buscador CIE-10
para el diagnóstico.
**Por qué:** patrón #5 y reducción de tecleo (#3).
**Esfuerzo:** bajo para el reagrupado; medio para frases favoritas (tabla nueva pequeña) y
buscador CIE-10 (catálogo semilla).

### 4.4 Lista de problemas y medicación activa **[v0.2]**
**Qué:** dos listas vivas por paciente, editables desde la ficha y visibles en el panel de
contexto (§4.2). Un "problema" puede abrirse en una consulta y cerrarse en otra.
**Por qué:** patrón #4, base de la continuidad.
**Esfuerzo:** alto. Requiere 2 tablas nuevas + RLS + UI. **Decisión del owner** — es capacidad
nueva, no pulido.

### 4.5 Panel del día accionable **[v0.1]**
**Qué:** convertir el panel en tablero: agrupar las citas de hoy por estado (Por llegar · En sala ·
En consulta · Atendidos) con el botón de la siguiente transición en cada tarjeta, más los accesos
rápidos actuales. Mantiene los KPIs (citas, cobrado, borradores).
**Por qué:** patrón #6. Es el "home base" del día.
**Esfuerzo:** medio. La máquina de estados ya existe; es reorganizar la vista.

### 4.6 Seguimiento proactivo **[v0.1 parcial / v0.2 completo]**
**Qué [v0.1]:** sección "Controles próximos" en el panel, leyendo `next_control_date` de las
consultas, con botón WhatsApp de aviso de control (ya existe la plantilla).
**Qué [v0.2]:** lista de "pacientes sin volver hace N meses" y recordatorios de cumpleaños.
**Esfuerzo:** bajo el parcial; medio el completo.

### 4.7 Búsqueda global y atajos **[v0.1]**
**Qué:** buscador de paciente accesible desde el header en cualquier pantalla (atajo `/` o `Ctrl+K`),
reutilizando el componente `PatientSearchSelect` que ya existe.
**Por qué:** patrón #8.
**Esfuerzo:** bajo.

### 4.8 Lenguaje visual de trazabilidad **[v0.1]**
**Qué:** hacer más legibles los estados de consulta (borrador/cerrada/enmendada) con una franja de
color y, en enmiendas, un enlace visible "← versión anterior / versión corregida →". Nota discreta
de auditoría ("registrado el … · cerrado el …").
**Por qué:** patrón #10; refuerza el valor de cumplimiento sin abrumar.
**Esfuerzo:** bajo.

---

## 5. Priorización (impacto / esfuerzo)

**Hacer primero — alto impacto, esfuerzo bajo/medio [v0.1]:**
1. Timeline unificado del paciente (§4.1)
2. Panel de contexto en la consulta (§4.2)
3. Panel del día accionable (§4.5)
4. Nota SOAP ligero + frases favoritas + buscador CIE-10 (§4.3)
5. Controles próximos en el panel (§4.6 parcial)

**Rápidas de rematar [v0.1]:**
6. Búsqueda global / Ctrl+K (§4.7)
7. Lenguaje visual de trazabilidad (§4.8)

**Requieren decisión del owner [v0.2]:**
8. Lista de problemas + medicación activa (§4.4)
9. Seguimiento completo: pacientes inactivos, cumpleaños (§4.6 completo)
10. Sala de espera kanban (ya prevista como v0.2 en el máster)

---

## 6. Recomendación de ejecución

Empezar por el bloque 1-2-3 (timeline, panel de contexto, panel del día): son los tres que más
cambian la experiencia diaria de la doctora y ninguno toca el esquema de BD. Luego 4-5, y rematar
con 6-7. La §4.4 (lista de problemas) es la mejora clínica más profunda pero es la única del
bloque v0.1 que exige tablas nuevas: conviene decidirla aparte, idealmente tras 2-3 semanas de uso
real, cuando la doctora sepa si la necesita.
