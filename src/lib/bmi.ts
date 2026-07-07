// lib/bmi.ts — Interpretación del IMC según grupo etario.
// Adultos (≥19 años): categorías OMS fijas.
// Niños/adolescentes (5–19 años): z-score OMS "BMI-for-age" por método LMS.
//   z = ((IMC/M)^L − 1) / (L·S)   ·   IMC(z) = M·(1 + L·S·z)^(1/L)
// Parámetros LMS oficiales de la OMS (tablas expandidas 5–19, fila de año entero),
// verificados recalculando el IMC contra los valores tabulados.
// Fuentes: cdn.who.int/.../bmifa-boys-5-19years-z.pdf y bmifa-girls-5-19years-z.pdf
// Uso clínico: referencia de apoyo; la valoración final es del médico.

export type Sex = 'M' | 'F' | 'O' | null | undefined;

type LMS = { L: number; M: number; S: number };

const LMS_BOYS: Record<number, LMS> = {
  5: { L: -0.7387, M: 15.2641, S: 0.08390 }, 6: { L: -0.9921, M: 15.3062, S: 0.08682 },
  7: { L: -1.2460, M: 15.4832, S: 0.09068 }, 8: { L: -1.4629, M: 15.7368, S: 0.09526 },
  9: { L: -1.6318, M: 16.0490, S: 0.10038 }, 10: { L: -1.7407, M: 16.4433, S: 0.10566 },
  11: { L: -1.7862, M: 16.9392, S: 0.11070 }, 12: { L: -1.7751, M: 17.5334, S: 0.11522 },
  13: { L: -1.7168, M: 18.2330, S: 0.11898 }, 14: { L: -1.6211, M: 19.0050, S: 0.12191 },
  15: { L: -1.4961, M: 19.7744, S: 0.12412 }, 16: { L: -1.3529, M: 20.4951, S: 0.12579 },
  17: { L: -1.1962, M: 21.1423, S: 0.12715 }, 18: { L: -1.0260, M: 21.7077, S: 0.12836 },
  19: { L: -0.8419, M: 22.1883, S: 0.12948 },
};

const LMS_GIRLS: Record<number, LMS> = {
  5: { L: -0.8886, M: 15.2441, S: 0.09692 }, 6: { L: -1.0794, M: 15.2697, S: 0.10195 },
  7: { L: -1.2565, M: 15.4036, S: 0.10746 }, 8: { L: -1.3880, M: 15.6810, S: 0.11291 },
  9: { L: -1.4650, M: 16.0964, S: 0.11816 }, 10: { L: -1.4864, M: 16.6133, S: 0.12307 },
  11: { L: -1.4606, M: 17.2459, S: 0.12748 }, 12: { L: -1.4006, M: 17.9966, S: 0.13129 },
  13: { L: -1.3195, M: 18.8012, S: 0.13445 }, 14: { L: -1.2266, M: 19.5647, S: 0.13700 },
  15: { L: -1.1311, M: 20.2125, S: 0.13904 }, 16: { L: -1.0368, M: 20.7008, S: 0.14070 },
  17: { L: -0.9423, M: 21.0367, S: 0.14208 }, 18: { L: -0.8462, M: 21.2603, S: 0.14330 },
  19: { L: -0.7496, M: 21.4269, S: 0.14441 },
};

export type BMICategory =
  | 'delgadez_severa' | 'delgadez' | 'bajo_peso' | 'normal'
  | 'sobrepeso' | 'obesidad' | 'obesidad_1' | 'obesidad_2' | 'obesidad_3'
  | 'sin_referencia';

export type BMIResult = {
  bmi: number;
  category: BMICategory;
  label: string;
  color: string;
  detail: string;
  scale: 'adulto' | 'pediatrico' | 'ninguna';
  zscore?: number;
  ageYears?: number;
  /** Cortes de IMC (kg/m²) para el eje del gráfico, en orden ascendente. */
  cutoffs?: { bmi: number; label: string }[];
};

const COLORS = {
  delgadez: '#e0a800', bajo: '#e0a800', normal: '#22a06b',
  sobre: '#f08c00', obes: '#e03131', gris: '#868e96',
};

function lmsFor(table: Record<number, LMS>, age: number): LMS {
  const a = Math.max(5, Math.min(19, age));
  const lo = Math.floor(a), hi = Math.ceil(a);
  if (lo === hi) return table[lo];
  const t = (a - lo) / (hi - lo);
  const L = table[lo].L + (table[hi].L - table[lo].L) * t;
  const M = table[lo].M + (table[hi].M - table[lo].M) * t;
  const S = table[lo].S + (table[hi].S - table[lo].S) * t;
  return { L, M, S };
}

const zToBMI = ({ L, M, S }: LMS, z: number) => M * Math.pow(1 + L * S * z, 1 / L);
const bmiToZ = ({ L, M, S }: LMS, bmi: number) => (Math.pow(bmi / M, L) - 1) / (L * S);

function classifyAdult(bmi: number): BMIResult {
  let category: BMICategory, label: string, color: string, detail: string;
  if (bmi < 18.5) { category = 'bajo_peso'; label = 'Bajo peso'; color = COLORS.bajo; detail = 'IMC menor a 18.5'; }
  else if (bmi < 25) { category = 'normal'; label = 'Peso normal'; color = COLORS.normal; detail = 'IMC 18.5 – 24.9'; }
  else if (bmi < 30) { category = 'sobrepeso'; label = 'Sobrepeso'; color = COLORS.sobre; detail = 'IMC 25 – 29.9'; }
  else if (bmi < 35) { category = 'obesidad_1'; label = 'Obesidad grado I'; color = COLORS.obes; detail = 'IMC 30 – 34.9'; }
  else if (bmi < 40) { category = 'obesidad_2'; label = 'Obesidad grado II'; color = COLORS.obes; detail = 'IMC 35 – 39.9'; }
  else { category = 'obesidad_3'; label = 'Obesidad grado III'; color = COLORS.obes; detail = 'IMC ≥ 40'; }
  return {
    bmi, category, label, color, detail, scale: 'adulto',
    cutoffs: [
      { bmi: 18.5, label: '18.5' }, { bmi: 25, label: '25' },
      { bmi: 30, label: '30' }, { bmi: 40, label: '40' },
    ],
  };
}

function classifyChild(bmi: number, age: number, sex: Sex): BMIResult {
  const table = sex === 'F' ? LMS_GIRLS : LMS_BOYS;
  const lms = lmsFor(table, age);
  const z = bmiToZ(lms, bmi);
  let category: BMICategory, label: string, color: string;
  if (z < -3) { category = 'delgadez_severa'; label = 'Delgadez severa'; color = COLORS.obes; }
  else if (z < -2) { category = 'delgadez'; label = 'Delgadez'; color = COLORS.delgadez; }
  else if (z <= 1) { category = 'normal'; label = 'Normal'; color = COLORS.normal; }
  else if (z <= 2) { category = 'sobrepeso'; label = 'Sobrepeso'; color = COLORS.sobre; }
  else { category = 'obesidad'; label = 'Obesidad'; color = COLORS.obes; }
  return {
    bmi, category, label, color, scale: 'pediatrico', zscore: z, ageYears: age,
    detail: `z-score OMS ${z >= 0 ? '+' : ''}${z.toFixed(1)} DE (${sex === 'F' ? 'niñas' : 'niños'}, ${Math.floor(age)} años)`,
    cutoffs: [
      { bmi: +zToBMI(lms, -2).toFixed(1), label: '−2DE' },
      { bmi: +zToBMI(lms, 1).toFixed(1), label: '+1DE' },
      { bmi: +zToBMI(lms, 2).toFixed(1), label: '+2DE' },
    ],
  };
}

/**
 * Interpreta el IMC según edad y sexo.
 * @param bmi kg/m²  @param ageYears edad en años (float)  @param sex 'M'|'F'
 */
export function interpretBMI(bmi: number | null | undefined, ageYears: number | null | undefined, sex: Sex): BMIResult | null {
  if (!bmi || bmi <= 0) return null;
  if (ageYears != null && ageYears >= 5 && ageYears < 19) return classifyChild(bmi, ageYears, sex);
  if (ageYears != null && ageYears < 5) {
    return {
      bmi, category: 'sin_referencia', label: 'Menor de 5 años', color: COLORS.gris, scale: 'ninguna',
      detail: 'La OMS usa otra referencia (0–5 años); interpretar con las curvas de crecimiento correspondientes.',
    };
  }
  return classifyAdult(bmi); // ≥19 o edad desconocida → escala adulto
}
