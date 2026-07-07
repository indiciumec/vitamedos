// lib/nutrition-ec.ts — Contenido de la guía de alimentación saludable para pacientes,
// basado en las Guías Alimentarias Basadas en Alimentos (GABA) del Ecuador — MSP / FAO.
// Fuentes: fao.org (GABA Ecuador), salud.gob.ec/guias-alimentarias-gabas, curso FAO Campus.
// Presentado como material EDUCATIVO de referencia; no sustituye la indicación médica.

/** La Cuchara Saludable: proporciones del plato diario (½ frutas/verduras, ¼ cereales, ¼ proteínas). */
export const CUCHARA = [
  {
    porcion: '½',
    grupo: 'Frutas y verduras',
    color: '#22a06b',
    detalle: 'La mitad del plato. Frescas, naturales y de temporada, en todas las comidas.',
  },
  {
    porcion: '¼',
    grupo: 'Cereales, tubérculos y plátanos',
    color: '#2f6fb0',
    detalle: 'Un cuarto del plato. De preferencia integrales o poco refinados.',
  },
  {
    porcion: '¼',
    grupo: 'Proteínas',
    color: '#7a4fb0',
    detalle: 'Un cuarto del plato. Lácteos, carnes, huevos y menestras (leguminosas).',
  },
] as const;

export const GRASAS_AZUCAR = 'Grasas saludables y azúcar: en muy poca cantidad, al cocinar.';

/** Los 11 mensajes clave de las GABA del Ecuador (MSP/FAO). */
export const MENSAJES_GABA: string[] = [
  'Comamos rico y sano: elijamos diariamente alimentos naturales y variados.',
  'Incluyamos alimentos de origen animal o menestras en el plato diario para formar y fortalecer el cuerpo.',
  'Para mejorar la digestión, consumamos verduras o frutas naturales en todas las comidas.',
  'Combinemos las menestras con algún cereal como arroz, maíz o quinua.',
  'Tomemos 8 vasos de agua segura durante el día para mantenernos hidratados.',
  'Protejamos nuestra salud: evitemos productos ultraprocesados, comida rápida y bebidas endulzadas.',
  'Al consumir menos azúcar, sal y grasas, evitamos la diabetes, la presión alta y la obesidad.',
  '¡En cuerpo sano, mente sana! Practiquemos al menos media hora diaria de la actividad física que más nos guste.',
  'Valoremos lo nuestro: aprovechemos los alimentos y sabores del Ecuador. ¡Cocinemos y disfrutemos en familia!',
  'De la mata a la olla: elijamos alimentos naturales de los productores locales.',
  'Informémonos: revisemos en la etiqueta los ingredientes, el semáforo nutricional y la fecha de caducidad.',
];

/** Ejemplos de alimentos ecuatorianos por grupo (ilustrativos). */
export const ALIMENTOS_EC = [
  {
    grupo: 'Frutas y verduras',
    ejemplos: 'Guineo, naranja, mandarina, papaya, piña, mango, maracuyá, tomate de árbol, mora, naranjilla, babaco; tomate, cebolla, zanahoria, brócoli, col, acelga, espinaca, zambo, zapallo, lechuga, remolacha.',
  },
  {
    grupo: 'Cereales, tubérculos y plátanos',
    ejemplos: 'Arroz, maíz, quinua, avena, cebada; papa, camote, yuca, melloco, oca, zanahoria blanca; plátano verde y maduro.',
  },
  {
    grupo: 'Proteínas',
    ejemplos: 'Pescado (corvina, atún, tilapia), mariscos, pollo, res, cerdo, huevos; menestras: fréjol, lenteja, arveja, garbanzo, haba, chochos; lácteos: leche, queso, yogur natural.',
  },
  {
    grupo: 'Grasas saludables (poca cantidad)',
    ejemplos: 'Aceite vegetal, aguacate, maní, nueces y semillas.',
  },
];

export const RECOMENDACIONES_GABA = [
  'Toma 8 vasos de agua segura al día.',
  'Come frutas o verduras en todas las comidas.',
  'Combina menestras con arroz, maíz o quinua.',
  'Reduce el azúcar, la sal y las grasas.',
  'Evita ultraprocesados, comida rápida y bebidas endulzadas.',
  'Haz al menos 30 minutos de actividad física al día.',
  'Prefiere alimentos frescos, locales y de temporada.',
  'Lee la etiqueta: revisa el semáforo nutricional y la fecha de caducidad.',
];

export const GABA_FUENTE =
  'Fuente: Guías Alimentarias Basadas en Alimentos (GABA) del Ecuador — Ministerio de Salud Pública y FAO.';
