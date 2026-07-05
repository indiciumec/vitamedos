-- ============================================================
-- 002_vademecum_ecuador.sql
-- Vademécum ampliado para práctica ambulatoria en Ecuador.
-- Fuentes: CNMB (CONASA), ARCSA y catálogos de farmacias ecuatorianas
-- (Fybeca, Pharmacys, Medicity, Cruz Azul). Generado el 2026-07-04.
--
-- IDEMPOTENTE: cada insert se protege con NOT EXISTS
-- (genérico + concentración para fármacos; fármaco + marca para marcas).
-- Los 8 fármacos del seed 001 no se duplican; solo reciben marcas nuevas.
--
-- NOTA CLÍNICA: dosis, frecuencias y duraciones son REFERENCIALES para
-- autocompletar; la prescripción final es responsabilidad del médico.
-- ============================================================

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Paracetamol', 'Analgésico y antipirético', 'Tableta', '500 mg', 'Oral', '20 tabletas', '1 tableta', 'Cada 8 horas', '3 días', 'Dolor leve a moderado y fiebre', 'No exceder 4 g al día, precaución en enfermedad hepática'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Paracetamol')
    and lower(coalesce(concentration, '')) = lower('500 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Umbral', 'Siegfried', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Paracetamol')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Umbral')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Analgan', 'Adium', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Paracetamol')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Analgan')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Tylenol', 'Johnson & Johnson', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Paracetamol')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Tylenol')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Paracetamol MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Paracetamol')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Paracetamol MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Paracetamol Genfar', 'Genfar', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Paracetamol')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Paracetamol Genfar')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Paracetamol + cafeína', 'Analgésico combinado', 'Tableta recubierta', '500 mg + 65 mg', 'Oral', '20 tabletas', '1 tableta', 'Cada 8 horas', '3 días', 'Cefalea y dolor leve a moderado', 'No combinar con otros productos con paracetamol, evitar exceso de cafeína'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Paracetamol + cafeína')
    and lower(coalesce(concentration, '')) = lower('500 mg + 65 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Finalin Forte', 'Prophar', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Paracetamol + cafeína')
  and lower(coalesce(d.concentration, '')) = lower('500 mg + 65 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Finalin Forte')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Umbral Forte', 'Siegfried', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Paracetamol + cafeína')
  and lower(coalesce(d.concentration, '')) = lower('500 mg + 65 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Umbral Forte')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Ibuprofeno', 'AINE', 'Tableta', '400 mg', 'Oral', '20 tabletas', '1 tableta', 'Cada 8 horas', '5 días', 'Dolor, inflamación y fiebre', 'Tomar con alimentos, evitar en gastritis y úlcera péptica'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Ibuprofeno')
    and lower(coalesce(concentration, '')) = lower('400 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Buprex', 'Life', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ibuprofeno')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Buprex')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Advil', 'Haleon', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ibuprofeno')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Advil')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Ibuprofeno MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ibuprofeno')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Ibuprofeno MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Ibuprofeno Genfar', 'Genfar', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ibuprofeno')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Ibuprofeno Genfar')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Naproxeno sódico', 'AINE', 'Tableta', '550 mg', 'Oral', '10 tabletas', '1 tableta', 'Cada 12 horas', '5 días', 'Dolor e inflamación musculoesquelética, dismenorrea', 'Tomar con alimentos, evitar en gastritis y enfermedad renal'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Naproxeno sódico')
    and lower(coalesce(concentration, '')) = lower('550 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Apronax', 'Bayer', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Naproxeno sódico')
  and lower(coalesce(d.concentration, '')) = lower('550 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Apronax')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Naproxeno Nifa', 'Nifa', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Naproxeno sódico')
  and lower(coalesce(d.concentration, '')) = lower('550 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Naproxeno Nifa')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Naproxeno MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Naproxeno sódico')
  and lower(coalesce(d.concentration, '')) = lower('550 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Naproxeno MK')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Diclofenaco', 'AINE', 'Tableta recubierta', '50 mg', 'Oral', '20 tabletas', '1 tableta', 'Cada 8 horas', '5 días', 'Dolor e inflamación, lumbalgia, traumatismos', 'Tomar con alimentos, evitar en úlcera péptica y riesgo cardiovascular'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Diclofenaco')
    and lower(coalesce(concentration, '')) = lower('50 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Cataflam', 'Novartis', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Diclofenaco')
  and lower(coalesce(d.concentration, '')) = lower('50 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Cataflam')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Voltaren', 'Novartis', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Diclofenaco')
  and lower(coalesce(d.concentration, '')) = lower('50 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Voltaren')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Diclofenaco La Santé', 'La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Diclofenaco')
  and lower(coalesce(d.concentration, '')) = lower('50 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Diclofenaco La Santé')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Diclofenaco MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Diclofenaco')
  and lower(coalesce(d.concentration, '')) = lower('50 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Diclofenaco MK')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Ketorolaco', 'AINE analgésico', 'Tableta', '10 mg', 'Oral', '10 tabletas', '1 tableta', 'Cada 8 horas', '3 días', 'Dolor agudo moderado a severo de corta duración', 'Máximo 5 días de uso, riesgo gastrointestinal y renal'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Ketorolaco')
    and lower(coalesce(concentration, '')) = lower('10 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Ketorolaco La Santé', 'La Santé', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ketorolaco')
  and lower(coalesce(d.concentration, '')) = lower('10 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Ketorolaco La Santé')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Ketorolaco MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ketorolaco')
  and lower(coalesce(d.concentration, '')) = lower('10 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Ketorolaco MK')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Meloxicam', 'AINE preferencial COX-2', 'Tableta', '15 mg', 'Oral', '10 tabletas', '1 tableta', 'Cada 24 horas', '7 días', 'Osteoartritis, artritis, dolor articular crónico', 'Tomar con alimentos, precaución en enfermedad renal'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Meloxicam')
    and lower(coalesce(concentration, '')) = lower('15 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Meloxicam MK', 'Tecnoquímicas', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Meloxicam')
  and lower(coalesce(d.concentration, '')) = lower('15 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Meloxicam MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Meloxicam La Santé', 'La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Meloxicam')
  and lower(coalesce(d.concentration, '')) = lower('15 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Meloxicam La Santé')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Meloxicam Medigener', 'Medigener', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Meloxicam')
  and lower(coalesce(d.concentration, '')) = lower('15 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Meloxicam Medigener')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Ácido acetilsalicílico', 'Analgésico, antipirético, AINE', 'Tableta', '500 mg', 'Oral', '20 tabletas', '1 tableta', 'Cada 8 horas', '3 días', 'Dolor leve, fiebre, cefalea', 'Evitar en niños con cuadros virales, gastritis y trastornos de coagulación'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Ácido acetilsalicílico')
    and lower(coalesce(concentration, '')) = lower('500 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Aspirina', 'Bayer', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ácido acetilsalicílico')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Aspirina')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Cafiaspirina', 'Bayer', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ácido acetilsalicílico')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Cafiaspirina')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Metamizol sódico', 'Analgésico y antipirético', 'Tableta', '500 mg', 'Oral', '10 tabletas', '1 a 2 tabletas', 'Cada 8 horas', '3 días', 'Dolor moderado a severo y fiebre resistente', 'Riesgo de agranulocitosis, evitar en alergia a pirazolonas'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Metamizol sódico')
    and lower(coalesce(concentration, '')) = lower('500 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Novalgina', 'Sanofi', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Metamizol sódico')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Novalgina')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Tramadol', 'Analgésico opioide', 'Cápsula', '50 mg', 'Oral', '10 cápsulas', '1 cápsula', 'Cada 8 horas', '5 días', 'Dolor moderado a severo', 'Puede causar somnolencia y náusea, no conducir, receta médica'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Tramadol')
    and lower(coalesce(concentration, '')) = lower('50 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Tramal', 'Grünenthal', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Tramadol')
  and lower(coalesce(d.concentration, '')) = lower('50 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Tramal')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Tramadol Genfar', 'Genfar', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Tramadol')
  and lower(coalesce(d.concentration, '')) = lower('50 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Tramadol Genfar')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Tramadol MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Tramadol')
  and lower(coalesce(d.concentration, '')) = lower('50 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Tramadol MK')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Tramadol + paracetamol', 'Analgésico opioide combinado', 'Tableta recubierta', '37.5 mg + 325 mg', 'Oral', '20 tabletas', '1 tableta', 'Cada 8 horas', '5 días', 'Dolor moderado a severo', 'Somnolencia, no combinar con alcohol, receta médica'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Tramadol + paracetamol')
    and lower(coalesce(concentration, '')) = lower('37.5 mg + 325 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Zaldiar', 'Grünenthal', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Tramadol + paracetamol')
  and lower(coalesce(d.concentration, '')) = lower('37.5 mg + 325 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Zaldiar')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Ketoprofeno', 'AINE', 'Tableta recubierta', '100 mg', 'Oral', '10 tabletas', '1 tableta', 'Cada 12 horas', '5 días', 'Dolor e inflamación musculoesquelética', 'Tomar con alimentos, evitar en úlcera péptica'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Ketoprofeno')
    and lower(coalesce(concentration, '')) = lower('100 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Profenid', 'Sanofi', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ketoprofeno')
  and lower(coalesce(d.concentration, '')) = lower('100 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Profenid')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Clonixinato de lisina', 'Analgésico AINE', 'Comprimido', '125 mg', 'Oral', '20 comprimidos', '1 comprimido', 'Cada 8 horas', '3 días', 'Dolor leve a moderado, cefalea, dismenorrea', 'Precaución en gastritis'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Clonixinato de lisina')
    and lower(coalesce(concentration, '')) = lower('125 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Dorixina', 'Megalabs', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Clonixinato de lisina')
  and lower(coalesce(d.concentration, '')) = lower('125 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Dorixina')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Celecoxib', 'AINE inhibidor COX-2', 'Cápsula', '200 mg', 'Oral', '10 cápsulas', '1 cápsula', 'Cada 24 horas', '7 días', 'Osteoartritis, artritis reumatoide, dolor agudo', 'Precaución en riesgo cardiovascular'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Celecoxib')
    and lower(coalesce(concentration, '')) = lower('200 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Celebrex', 'Pfizer', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Celecoxib')
  and lower(coalesce(d.concentration, '')) = lower('200 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Celebrex')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Celecoxib MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Celecoxib')
  and lower(coalesce(d.concentration, '')) = lower('200 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Celecoxib MK')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Etoricoxib', 'AINE inhibidor COX-2', 'Tableta recubierta', '90 mg', 'Oral', '7 tabletas', '1 tableta', 'Cada 24 horas', '7 días', 'Dolor e inflamación osteoarticular, gota aguda', 'Precaución en hipertensión y riesgo cardiovascular'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Etoricoxib')
    and lower(coalesce(concentration, '')) = lower('90 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Arcoxia', 'Organon', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Etoricoxib')
  and lower(coalesce(d.concentration, '')) = lower('90 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Arcoxia')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Etoricoxib MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Etoricoxib')
  and lower(coalesce(d.concentration, '')) = lower('90 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Etoricoxib MK')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Metocarbamol', 'Relajante muscular', 'Tableta', '750 mg', 'Oral', '20 tabletas', '1 tableta', 'Cada 8 horas', '5 días', 'Espasmo muscular, contracturas, lumbalgia', 'Puede causar somnolencia, no conducir'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Metocarbamol')
    and lower(coalesce(concentration, '')) = lower('750 mg')
);

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Tiocolchicósido', 'Relajante muscular', 'Tableta', '4 mg', 'Oral', '10 tabletas', '1 tableta', 'Cada 12 horas', '5 días', 'Contracturas musculares dolorosas de origen vertebral', 'No usar en embarazo ni lactancia, ciclos cortos'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Tiocolchicósido')
    and lower(coalesce(concentration, '')) = lower('4 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Conrelax', null, true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Tiocolchicósido')
  and lower(coalesce(d.concentration, '')) = lower('4 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Conrelax')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Tiocolchicósido La Santé', 'La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Tiocolchicósido')
  and lower(coalesce(d.concentration, '')) = lower('4 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Tiocolchicósido La Santé')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Tiocolfen', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Tiocolchicósido')
  and lower(coalesce(d.concentration, '')) = lower('4 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Tiocolfen')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Ciclobenzaprina', 'Relajante muscular', 'Comprimido', '10 mg', 'Oral', '10 comprimidos', '1 comprimido', 'Cada 12 horas', '7 días', 'Espasmo muscular asociado a dolor musculoesquelético agudo', 'Somnolencia y boca seca, evitar con alcohol'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Ciclobenzaprina')
    and lower(coalesce(concentration, '')) = lower('10 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Cicloter', null, true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ciclobenzaprina')
  and lower(coalesce(d.concentration, '')) = lower('10 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Cicloter')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Sumatriptán', 'Antimigrañoso triptán', 'Tableta recubierta', '50 mg', 'Oral', '2 tabletas', '1 tableta al inicio de la crisis', 'Repetir a las 2 horas si es necesario, máximo 300 mg al día', 'Según crisis', 'Crisis aguda de migraña con o sin aura', 'Contraindicado en cardiopatía isquémica e hipertensión no controlada'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Sumatriptán')
    and lower(coalesce(concentration, '')) = lower('50 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Imigran', 'GSK', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Sumatriptán')
  and lower(coalesce(d.concentration, '')) = lower('50 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Imigran')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Clonixinato de lisina + ergotamina', 'Antimigrañoso', 'Comprimido recubierto', '125 mg + 1 mg', 'Oral', '10 comprimidos', '1 comprimido al inicio de los síntomas', 'Repetir según indicación, máximo 6 mg de ergotamina al día', 'Según crisis', 'Crisis de migraña moderada a severa', 'Vasoconstricción por ergotamina, evitar en enfermedad coronaria e hipertensión severa'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Clonixinato de lisina + ergotamina')
    and lower(coalesce(concentration, '')) = lower('125 mg + 1 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Migradorixina', 'Megalabs', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Clonixinato de lisina + ergotamina')
  and lower(coalesce(d.concentration, '')) = lower('125 mg + 1 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Migradorixina')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Ibuprofeno + cafeína + ergotamina', 'Antimigrañoso combinado', 'Tableta', '400 mg + 100 mg + 1 mg', 'Oral', '20 tabletas', '1 tableta al inicio de la crisis', 'Repetir según indicación médica', 'Según crisis', 'Crisis de migraña', 'Evitar en enfermedad coronaria, hipertensión severa y gastritis'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Ibuprofeno + cafeína + ergotamina')
    and lower(coalesce(concentration, '')) = lower('400 mg + 100 mg + 1 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Buprex Migra', 'Life', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ibuprofeno + cafeína + ergotamina')
  and lower(coalesce(d.concentration, '')) = lower('400 mg + 100 mg + 1 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Buprex Migra')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Amoxicilina', 'Antibiótico penicilina', 'Cápsula', '500 mg', 'Oral', '21 cápsulas', '1 cápsula', 'Cada 8 horas', '7 días', 'Faringoamigdalitis, sinusitis, otitis media, infecciones respiratorias', 'Verificar alergia a penicilinas'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Amoxicilina')
    and lower(coalesce(concentration, '')) = lower('500 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Amoxil', 'GSK', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Amoxicilina')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Amoxil')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Grunamox', 'Grünenthal Ecuatoriana', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Amoxicilina')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Grunamox')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Amoxicilina MK', 'Tecnoquímicas MK', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Amoxicilina')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Amoxicilina MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Amoxicilina Mintlab', 'Mintlab', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Amoxicilina')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Amoxicilina Mintlab')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Amoxicilina + Ácido clavulánico', 'Antibiótico penicilina con inhibidor de betalactamasa', 'Tableta recubierta', '875/125 mg', 'Oral', '14 tabletas', '1 tableta', 'Cada 12 horas', '7 días', 'Sinusitis bacteriana, otitis media, infecciones respiratorias y de piel con sospecha de resistencia', 'Verificar alergia a penicilinas, tomar con alimentos por intolerancia digestiva'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Amoxicilina + Ácido clavulánico')
    and lower(coalesce(concentration, '')) = lower('875/125 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Augmentin', 'GSK', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Amoxicilina + Ácido clavulánico')
  and lower(coalesce(d.concentration, '')) = lower('875/125 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Augmentin')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Curam', 'Sandoz', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Amoxicilina + Ácido clavulánico')
  and lower(coalesce(d.concentration, '')) = lower('875/125 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Curam')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Amoxicilina + Ácido Clavulánico Nifa', 'Nifa', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Amoxicilina + Ácido clavulánico')
  and lower(coalesce(d.concentration, '')) = lower('875/125 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Amoxicilina + Ácido Clavulánico Nifa')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Azitromicina', 'Antibiótico macrólido', 'Tableta recubierta', '500 mg', 'Oral', '3 tabletas', '1 tableta', 'Cada 24 horas', '3 días', 'Infecciones respiratorias altas y bajas, faringitis en alérgicos a penicilina', 'Precaución con prolongación del QT'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Azitromicina')
    and lower(coalesce(concentration, '')) = lower('500 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Zitromax', 'Pfizer', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Azitromicina')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Zitromax')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Azitromicina La Santé', 'La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Azitromicina')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Azitromicina La Santé')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Azitromicina Medigener', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Azitromicina')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Azitromicina Medigener')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Azitromicina Mintlab', 'Mintlab', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Azitromicina')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Azitromicina Mintlab')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Claritromicina', 'Antibiótico macrólido', 'Tableta recubierta', '500 mg', 'Oral', '14 tabletas', '1 tableta', 'Cada 12 horas', '7 días', 'Infecciones respiratorias, erradicación de H. pylori en esquema triple', 'Evitar con insuficiencia renal grave, interacciones por CYP3A4'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Claritromicina')
    and lower(coalesce(concentration, '')) = lower('500 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Klaricid', 'Abbott', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Claritromicina')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Klaricid')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Claritromicina Medigener', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Claritromicina')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Claritromicina Medigener')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Claritromicina Genfar', 'Genfar', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Claritromicina')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Claritromicina Genfar')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Cefalexina', 'Antibiótico cefalosporina de primera generación', 'Cápsula', '500 mg', 'Oral', '28 cápsulas', '1 cápsula', 'Cada 6 horas', '7 días', 'Infecciones de piel y tejidos blandos, infecciones urinarias no complicadas', 'Precaución con alergia cruzada a penicilinas'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Cefalexina')
    and lower(coalesce(concentration, '')) = lower('500 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Cefrin', null, true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Cefalexina')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Cefrin')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Cefalexina La Santé', 'La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Cefalexina')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Cefalexina La Santé')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Cefalexina Nifa', 'Nifa', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Cefalexina')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Cefalexina Nifa')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Cefalexina Medigener', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Cefalexina')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Cefalexina Medigener')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Cefuroxima', 'Antibiótico cefalosporina de segunda generación', 'Tableta recubierta', '500 mg', 'Oral', '14 tabletas', '1 tableta', 'Cada 12 horas', '7 días', 'Sinusitis, otitis media, bronquitis, infecciones urinarias', 'Precaución con alergia cruzada a penicilinas, tomar con alimentos'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Cefuroxima')
    and lower(coalesce(concentration, '')) = lower('500 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Zinnat', 'GSK', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Cefuroxima')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Zinnat')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Cefur', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Cefuroxima')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Cefur')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Cefuroxima Nifa', 'Nifa', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Cefuroxima')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Cefuroxima Nifa')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Cefuroxima Labovida', 'Labovida', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Cefuroxima')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Cefuroxima Labovida')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Ciprofloxacino', 'Antibiótico fluoroquinolona', 'Tableta recubierta', '500 mg', 'Oral', '14 tabletas', '1 tableta', 'Cada 12 horas', '7 días', 'Infecciones urinarias complicadas, prostatitis, gastroenteritis bacteriana', 'Evitar en embarazo y menores de 18 años, riesgo de tendinopatía'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Ciprofloxacino')
    and lower(coalesce(concentration, '')) = lower('500 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Bactiflox', 'Acino Pharma', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ciprofloxacino')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Bactiflox')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Ciprofloxacina Nifa', 'Prophar', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ciprofloxacino')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Ciprofloxacina Nifa')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Ciprofloxacina Rocnarf', 'Rocnarf', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ciprofloxacino')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Ciprofloxacina Rocnarf')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Ciprofloxacina Medigener', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ciprofloxacino')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Ciprofloxacina Medigener')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Levofloxacino', 'Antibiótico fluoroquinolona', 'Tableta recubierta', '500 mg', 'Oral', '7 tabletas', '1 tableta', 'Cada 24 horas', '7 días', 'Neumonía adquirida en comunidad, sinusitis bacteriana, infecciones urinarias complicadas', 'Evitar en embarazo y menores de 18 años, riesgo de tendinopatía y prolongación del QT'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Levofloxacino')
    and lower(coalesce(concentration, '')) = lower('500 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Levofree', null, true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Levofloxacino')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Levofree')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Levocina', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Levofloxacino')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Levocina')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Lalevo', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Levofloxacino')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Lalevo')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Floxalev', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Levofloxacino')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Floxalev')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Levofloxacina Medigener', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Levofloxacino')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Levofloxacina Medigener')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Trimetoprim + Sulfametoxazol', 'Antibiótico sulfonamida combinada', 'Tableta', '160/800 mg', 'Oral', '14 tabletas', '1 tableta', 'Cada 12 horas', '7 días', 'Infecciones urinarias no complicadas, infecciones gastrointestinales', 'Verificar alergia a sulfas, mantener buena hidratación'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Trimetoprim + Sulfametoxazol')
    and lower(coalesce(concentration, '')) = lower('160/800 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Bactrim Forte', 'Roche', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Trimetoprim + Sulfametoxazol')
  and lower(coalesce(d.concentration, '')) = lower('160/800 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Bactrim Forte')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Bacterol', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Trimetoprim + Sulfametoxazol')
  and lower(coalesce(d.concentration, '')) = lower('160/800 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Bacterol')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Bitrim', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Trimetoprim + Sulfametoxazol')
  and lower(coalesce(d.concentration, '')) = lower('160/800 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Bitrim')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Trimetoprim Sulfa MK', 'Tecnoquímicas MK', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Trimetoprim + Sulfametoxazol')
  and lower(coalesce(d.concentration, '')) = lower('160/800 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Trimetoprim Sulfa MK')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Nitrofurantoína', 'Antibiótico antiséptico urinario', 'Cápsula', '100 mg', 'Oral', '20 cápsulas', '1 cápsula', 'Cada 6 horas', '5 días', 'Cistitis aguda no complicada en mujeres', 'Tomar con alimentos, evitar con depuración de creatinina menor a 30, puede teñir la orina'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Nitrofurantoína')
    and lower(coalesce(concentration, '')) = lower('100 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Urantoin', null, true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Nitrofurantoína')
  and lower(coalesce(d.concentration, '')) = lower('100 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Urantoin')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Nitrofurantoína MK', 'Tecnoquímicas MK', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Nitrofurantoína')
  and lower(coalesce(d.concentration, '')) = lower('100 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Nitrofurantoína MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Nifuryl Retard', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Nitrofurantoína')
  and lower(coalesce(d.concentration, '')) = lower('100 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Nifuryl Retard')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Urimax', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Nitrofurantoína')
  and lower(coalesce(d.concentration, '')) = lower('100 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Urimax')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Uribiol', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Nitrofurantoína')
  and lower(coalesce(d.concentration, '')) = lower('100 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Uribiol')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Doxiciclina', 'Antibiótico tetraciclina', 'Tableta', '100 mg', 'Oral', '14 tabletas', '1 tableta', 'Cada 12 horas', '7 días', 'Acné inflamatorio, infecciones respiratorias atípicas, enfermedades transmitidas por vectores', 'Evitar en embarazo y menores de 8 años, fotosensibilidad, tomar con abundante agua'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Doxiciclina')
    and lower(coalesce(concentration, '')) = lower('100 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Supramycina', 'Grünenthal', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Doxiciclina')
  and lower(coalesce(d.concentration, '')) = lower('100 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Supramycina')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Doxiciclina La Santé', 'La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Doxiciclina')
  and lower(coalesce(d.concentration, '')) = lower('100 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Doxiciclina La Santé')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Jeroma', 'Produderm', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Doxiciclina')
  and lower(coalesce(d.concentration, '')) = lower('100 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Jeroma')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Clindamicina', 'Antibiótico lincosamida', 'Cápsula', '300 mg', 'Oral', '21 cápsulas', '1 cápsula', 'Cada 8 horas', '7 días', 'Infecciones de piel y tejidos blandos, infecciones odontogénicas, alérgicos a penicilina', 'Riesgo de colitis por C. difficile, suspender si hay diarrea intensa'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Clindamicina')
    and lower(coalesce(concentration, '')) = lower('300 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Dalacin C', 'Pfizer', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Clindamicina')
  and lower(coalesce(d.concentration, '')) = lower('300 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Dalacin C')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Clindamicina MK', 'Tecnoquímicas MK', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Clindamicina')
  and lower(coalesce(d.concentration, '')) = lower('300 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Clindamicina MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Clindamicina La Santé', 'La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Clindamicina')
  and lower(coalesce(d.concentration, '')) = lower('300 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Clindamicina La Santé')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Metronidazol', 'Antibiótico y antiparasitario nitroimidazol', 'Tableta', '500 mg', 'Oral', '21 tabletas', '1 tableta', 'Cada 8 horas', '7 días', 'Amebiasis, giardiasis, vaginosis bacteriana, infecciones por anaerobios', 'No consumir alcohol durante el tratamiento y 48 horas después, sabor metálico frecuente'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Metronidazol')
    and lower(coalesce(concentration, '')) = lower('500 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Flagyl', 'Sanofi', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Metronidazol')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Flagyl')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Metronidazol MK', 'Tecnoquímicas MK', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Metronidazol')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Metronidazol MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Metronidazol Caplin', 'Caplin Point', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Metronidazol')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Metronidazol Caplin')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Tinidazol', 'Antiparasitario nitroimidazol', 'Tableta recubierta', '1 g', 'Oral', '2 tabletas', '2 tabletas juntas', 'Dosis única', '1 día', 'Tricomoniasis, giardiasis, amebiasis intestinal', 'No consumir alcohol durante el tratamiento y 72 horas después'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Tinidazol')
    and lower(coalesce(concentration, '')) = lower('1 g')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Fasigyn', 'Pfizer', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Tinidazol')
  and lower(coalesce(d.concentration, '')) = lower('1 g')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Fasigyn')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Tinidan', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Tinidazol')
  and lower(coalesce(d.concentration, '')) = lower('1 g')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Tinidan')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Tinidazol Genfar', 'Genfar', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Tinidazol')
  and lower(coalesce(d.concentration, '')) = lower('1 g')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Tinidazol Genfar')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Tinidazol MK', 'Tecnoquímicas MK', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Tinidazol')
  and lower(coalesce(d.concentration, '')) = lower('1 g')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Tinidazol MK')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Albendazol', 'Antiparasitario benzimidazol', 'Tableta masticable', '400 mg', 'Oral', '1 tableta', '1 tableta', 'Dosis única', '1 día', 'Desparasitación intestinal por helmintos, giardiasis con esquema de 5 días', 'Evitar en embarazo y menores de 2 años'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Albendazol')
    and lower(coalesce(concentration, '')) = lower('400 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Zentel', 'GSK', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Albendazol')
  and lower(coalesce(d.concentration, '')) = lower('400 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Zentel')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Albendazol MK', 'Tecnoquímicas MK', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Albendazol')
  and lower(coalesce(d.concentration, '')) = lower('400 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Albendazol MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Pazidol', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Albendazol')
  and lower(coalesce(d.concentration, '')) = lower('400 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Pazidol')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Ivermectina', 'Antiparasitario avermectina', 'Solución oral en gotas', '6 mg/ml (0.6%)', 'Oral', 'Frasco de 5 ml', '1 gota por kg de peso', 'Dosis única', '1 día', 'Escabiosis, pediculosis, estrongiloidiasis', 'Repetir a los 7 a 14 días en escabiosis, evitar en embarazo y menores de 15 kg'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Ivermectina')
    and lower(coalesce(concentration, '')) = lower('6 mg/ml (0.6%)')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Ivermin', 'Laboratorios Indunidas', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ivermectina')
  and lower(coalesce(d.concentration, '')) = lower('6 mg/ml (0.6%)')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Ivermin')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Iverox', 'Bassa', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ivermectina')
  and lower(coalesce(d.concentration, '')) = lower('6 mg/ml (0.6%)')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Iverox')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Nistatina', 'Antimicótico poliénico', 'Suspensión oral', '100000 UI/ml', 'Oral', 'Frasco de 120 ml', '1 ml aplicado en mucosa oral', 'Cada 6 horas', '7 a 14 días', 'Candidiasis oral en lactantes y adultos', 'Mantener en boca el mayor tiempo posible antes de tragar'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Nistatina')
    and lower(coalesce(concentration, '')) = lower('100000 UI/ml')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Acronistina', 'Acromax', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Nistatina')
  and lower(coalesce(d.concentration, '')) = lower('100000 UI/ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Acronistina')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Nistat', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Nistatina')
  and lower(coalesce(d.concentration, '')) = lower('100000 UI/ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Nistat')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Nistatina Kronos', 'Kronos', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Nistatina')
  and lower(coalesce(d.concentration, '')) = lower('100000 UI/ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Nistatina Kronos')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Fluconazol', 'Antimicótico triazol', 'Cápsula', '150 mg', 'Oral', '1 a 2 cápsulas', '1 cápsula', 'Dosis única semanal según indicación', '1 día en candidiasis vaginal', 'Candidiasis vaginal, candidiasis oral, onicomicosis con esquema semanal prolongado', 'Interacciones por CYP, precaución hepática en tratamientos prolongados'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Fluconazol')
    and lower(coalesce(concentration, '')) = lower('150 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Diflucan', 'Pfizer', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Fluconazol')
  and lower(coalesce(d.concentration, '')) = lower('150 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Diflucan')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Flucazol', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Fluconazol')
  and lower(coalesce(d.concentration, '')) = lower('150 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Flucazol')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Fluconazol La Santé', 'La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Fluconazol')
  and lower(coalesce(d.concentration, '')) = lower('150 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Fluconazol La Santé')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Fluconazol MK', 'Tecnoquímicas MK', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Fluconazol')
  and lower(coalesce(d.concentration, '')) = lower('150 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Fluconazol MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Fluconazol Medigener', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Fluconazol')
  and lower(coalesce(d.concentration, '')) = lower('150 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Fluconazol Medigener')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Ketoconazol', 'Antimicótico imidazol', 'Tableta', '200 mg', 'Oral', '10 tabletas', '1 tableta', 'Cada 24 horas', '10 días', 'Micosis cutáneas extensas cuando no hay alternativa tópica', 'Riesgo de hepatotoxicidad, evitar con alcohol, preferir alternativas más seguras vía oral'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Ketoconazol')
    and lower(coalesce(concentration, '')) = lower('200 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Ketocon', null, true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ketoconazol')
  and lower(coalesce(d.concentration, '')) = lower('200 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Ketocon')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Ketoconazol Mintlab', 'Mintlab', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ketoconazol')
  and lower(coalesce(d.concentration, '')) = lower('200 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Ketoconazol Mintlab')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Ketoconazol Nifa', 'Prophar', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ketoconazol')
  and lower(coalesce(d.concentration, '')) = lower('200 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Ketoconazol Nifa')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Clotrimazol', 'Antimicótico imidazol tópico', 'Crema', '1%', 'Tópica', 'Tubo de 20 g', 'Capa fina en zona afectada', '2 a 3 veces al día', '2 a 4 semanas', 'Tiña corporal, tiña del pie, candidiasis cutánea y vaginal', 'Continuar 1 a 2 semanas tras desaparecer las lesiones'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Clotrimazol')
    and lower(coalesce(concentration, '')) = lower('1%')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Canesten', 'Bayer', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Clotrimazol')
  and lower(coalesce(d.concentration, '')) = lower('1%')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Canesten')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Clotrimazol Mintlab', 'Mintlab', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Clotrimazol')
  and lower(coalesce(d.concentration, '')) = lower('1%')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Clotrimazol Mintlab')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Terbinafina', 'Antimicótico alilamina', 'Tableta', '250 mg', 'Oral', '28 tabletas', '1 tableta', 'Cada 24 horas', '6 a 12 semanas en onicomicosis', 'Onicomicosis, tiñas extensas resistentes a tratamiento tópico', 'Vigilar función hepática en tratamientos prolongados, evitar en embarazo'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Terbinafina')
    and lower(coalesce(concentration, '')) = lower('250 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Terbinafina MK', 'Tecnoquímicas MK', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Terbinafina')
  and lower(coalesce(d.concentration, '')) = lower('250 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Terbinafina MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Terbifung', 'Interpharm', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Terbinafina')
  and lower(coalesce(d.concentration, '')) = lower('250 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Terbifung')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Terbinafina Nifa', 'Nifa', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Terbinafina')
  and lower(coalesce(d.concentration, '')) = lower('250 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Terbinafina Nifa')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Terbilazar', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Terbinafina')
  and lower(coalesce(d.concentration, '')) = lower('250 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Terbilazar')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Aciclovir', 'Antiviral análogo de nucleósido', 'Tableta', '400 mg', 'Oral', '25 tabletas', '1 tableta', 'Cada 8 horas en herpes simple, 800 mg 5 veces al día en zóster', '7 días', 'Herpes simple labial y genital, herpes zóster, varicela en adultos', 'Mantener buena hidratación, iniciar en las primeras 72 horas del brote'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Aciclovir')
    and lower(coalesce(concentration, '')) = lower('400 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Eurovir', null, true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Aciclovir')
  and lower(coalesce(d.concentration, '')) = lower('400 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Eurovir')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Aciclovir Medigener', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Aciclovir')
  and lower(coalesce(d.concentration, '')) = lower('400 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Aciclovir Medigener')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Aciclovir Mintlab', 'Mintlab', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Aciclovir')
  and lower(coalesce(d.concentration, '')) = lower('400 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Aciclovir Mintlab')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Aciclovir Genamérica', 'Genamérica', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Aciclovir')
  and lower(coalesce(d.concentration, '')) = lower('400 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Aciclovir Genamérica')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Oseltamivir', 'Antiviral inhibidor de neuraminidasa', 'Cápsula', '75 mg', 'Oral', '10 cápsulas', '1 cápsula', 'Cada 12 horas', '5 días', 'Influenza A y B confirmada o sospechada en las primeras 48 horas', 'Mayor beneficio si se inicia en las primeras 48 horas, venta restringida con receta en Ecuador'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Oseltamivir')
    and lower(coalesce(concentration, '')) = lower('75 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Tamiflu', 'Roche', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Oseltamivir')
  and lower(coalesce(d.concentration, '')) = lower('75 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Tamiflu')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Inmunopul', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Oseltamivir')
  and lower(coalesce(d.concentration, '')) = lower('75 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Inmunopul')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Loratadina', 'Antihistamínico H1 de segunda generación', 'Tableta', '10 mg', 'Oral', '10 tabletas', '10 mg', 'Cada 24 horas', '7 a 14 días o mientras duren los síntomas', 'Rinitis alérgica, urticaria, prurito alérgico', 'Precaución en insuficiencia hepática severa'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Loratadina')
    and lower(coalesce(concentration, '')) = lower('10 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Clarityne', 'Bayer', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Loratadina')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Clarityne')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Loratadina MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Loratadina')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Loratadina MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Loratadina La Santé', 'La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Loratadina')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Loratadina La Santé')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Loratadina Medigener', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Loratadina')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Loratadina Medigener')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Desloratadina', 'Antihistamínico H1 de segunda generación', 'Tableta recubierta', '5 mg', 'Oral', '10 tabletas', '5 mg', 'Cada 24 horas', '7 a 14 días o mientras duren los síntomas', 'Rinitis alérgica, urticaria crónica', 'Ajustar en insuficiencia renal o hepática severa'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Desloratadina')
    and lower(coalesce(concentration, '')) = lower('5 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Desloratadina MK', 'Tecnoquímicas', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Desloratadina')
  and lower(coalesce(d.concentration, '')) = lower('5 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Desloratadina MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Desloran', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Desloratadina')
  and lower(coalesce(d.concentration, '')) = lower('5 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Desloran')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Desloratadina La Santé', 'La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Desloratadina')
  and lower(coalesce(d.concentration, '')) = lower('5 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Desloratadina La Santé')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Desloratadina Medigener', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Desloratadina')
  and lower(coalesce(d.concentration, '')) = lower('5 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Desloratadina Medigener')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Cetirizina', 'Antihistamínico H1 de segunda generación', 'Tableta', '10 mg', 'Oral', '10 tabletas', '10 mg', 'Cada 24 horas', '7 a 14 días o mientras duren los síntomas', 'Rinitis alérgica, conjuntivitis alérgica, urticaria', 'Puede causar somnolencia leve, precaución al conducir'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Cetirizina')
    and lower(coalesce(concentration, '')) = lower('10 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Zyrtec', 'UCB', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Cetirizina')
  and lower(coalesce(d.concentration, '')) = lower('10 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Zyrtec')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Cetirizina MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Cetirizina')
  and lower(coalesce(d.concentration, '')) = lower('10 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Cetirizina MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Cetirizina La Santé', 'La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Cetirizina')
  and lower(coalesce(d.concentration, '')) = lower('10 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Cetirizina La Santé')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Cetirizina Mintlab', 'Mintlab', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Cetirizina')
  and lower(coalesce(d.concentration, '')) = lower('10 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Cetirizina Mintlab')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Levocetirizina', 'Antihistamínico H1 de segunda generación', 'Tableta recubierta', '5 mg', 'Oral', '10 tabletas', '5 mg', 'Cada 24 horas, de preferencia en la noche', '7 a 14 días o mientras duren los síntomas', 'Rinitis alérgica, urticaria', 'Ajustar dosis en insuficiencia renal'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Levocetirizina')
    and lower(coalesce(concentration, '')) = lower('5 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Xuzal', 'UCB', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Levocetirizina')
  and lower(coalesce(d.concentration, '')) = lower('5 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Xuzal')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Levocet', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Levocetirizina')
  and lower(coalesce(d.concentration, '')) = lower('5 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Levocet')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Levocetirizina La Santé', 'La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Levocetirizina')
  and lower(coalesce(d.concentration, '')) = lower('5 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Levocetirizina La Santé')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Fexofenadina', 'Antihistamínico H1 de segunda generación', 'Tableta recubierta', '120 mg', 'Oral', '10 tabletas', '120 mg en rinitis, 180 mg en urticaria', 'Cada 24 horas', '7 a 14 días o mientras duren los síntomas', 'Rinitis alérgica, urticaria crónica idiopática', 'No tomar con jugos de frutas, reducen su absorción'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Fexofenadina')
    and lower(coalesce(concentration, '')) = lower('120 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Allegra', 'Sanofi', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Fexofenadina')
  and lower(coalesce(d.concentration, '')) = lower('120 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Allegra')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Alerfedine D', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Fexofenadina')
  and lower(coalesce(d.concentration, '')) = lower('120 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Alerfedine D')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Clorfenamina', 'Antihistamínico H1 de primera generación', 'Tableta', '4 mg', 'Oral', '20 tabletas', '4 mg', 'Cada 6 a 8 horas', '3 a 7 días', 'Rinitis alérgica, resfriado común, urticaria, reacciones alérgicas leves', 'Produce somnolencia marcada, evitar conducir y alcohol'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Clorfenamina')
    and lower(coalesce(concentration, '')) = lower('4 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Klorfexina', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Clorfenamina')
  and lower(coalesce(d.concentration, '')) = lower('4 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Klorfexina')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Ambroxol', 'Mucolítico expectorante', 'Jarabe', '30 mg/5 ml frasco 120 ml', 'Oral', '1 frasco', '30 mg (5 ml adultos)', 'Cada 8 horas', '5 a 7 días', 'Tos productiva con secreciones espesas, bronquitis, procesos catarrales', 'Precaución en úlcera péptica activa'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Ambroxol')
    and lower(coalesce(concentration, '')) = lower('30 mg/5 ml frasco 120 ml')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Mucosolvan', 'Sanofi', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ambroxol')
  and lower(coalesce(d.concentration, '')) = lower('30 mg/5 ml frasco 120 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Mucosolvan')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Ambroxol MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ambroxol')
  and lower(coalesce(d.concentration, '')) = lower('30 mg/5 ml frasco 120 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Ambroxol MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Ambroxol La Santé', 'La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ambroxol')
  and lower(coalesce(d.concentration, '')) = lower('30 mg/5 ml frasco 120 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Ambroxol La Santé')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Solmux', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ambroxol')
  and lower(coalesce(d.concentration, '')) = lower('30 mg/5 ml frasco 120 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Solmux')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Bromhexina', 'Mucolítico expectorante', 'Jarabe', '8 mg/5 ml frasco 120 ml', 'Oral', '1 frasco', '8 mg (5 ml adultos)', 'Cada 8 horas', '5 a 7 días', 'Bronquitis aguda y crónica con secreciones espesas, traqueobronquitis', 'Precaución en úlcera gástrica'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Bromhexina')
    and lower(coalesce(concentration, '')) = lower('8 mg/5 ml frasco 120 ml')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Bisolvon', 'Boehringer Ingelheim', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Bromhexina')
  and lower(coalesce(d.concentration, '')) = lower('8 mg/5 ml frasco 120 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Bisolvon')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Bromhexina MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Bromhexina')
  and lower(coalesce(d.concentration, '')) = lower('8 mg/5 ml frasco 120 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Bromhexina MK')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Acetilcisteína', 'Mucolítico', 'Granulado o sobre efervescente', '600 mg', 'Oral', '10 a 20 sobres', '600 mg', 'Cada 24 horas', '5 a 10 días', 'Secreciones bronquiales espesas, bronquitis, sinusitis, EPOC', 'Precaución en asma bronquial y úlcera péptica'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Acetilcisteína')
    and lower(coalesce(concentration, '')) = lower('600 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Fluimucil', 'Zambon', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Acetilcisteína')
  and lower(coalesce(d.concentration, '')) = lower('600 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Fluimucil')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Fluidine', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Acetilcisteína')
  and lower(coalesce(d.concentration, '')) = lower('600 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Fluidine')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Extracto de hoja de hiedra (Hedera helix)', 'Expectorante mucolítico fitoterápico', 'Jarabe', '35 mg/5 ml frasco 100 ml', 'Oral', '1 frasco', '5 ml adultos, 2.5 ml preescolares', 'Cada 8 horas', '5 a 7 días', 'Tos con expectoración difícil, bronquitis con broncoespasmo leve', 'Contraindicado en embarazo y lactancia salvo criterio médico'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Extracto de hoja de hiedra (Hedera helix)')
    and lower(coalesce(concentration, '')) = lower('35 mg/5 ml frasco 100 ml')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Abrilar', 'Megalabs', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Extracto de hoja de hiedra (Hedera helix)')
  and lower(coalesce(d.concentration, '')) = lower('35 mg/5 ml frasco 100 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Abrilar')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Dextrometorfano', 'Antitusivo de acción central', 'Jarabe', '15 mg/5 ml frasco 120 ml', 'Oral', '1 frasco', '15 mg (5 ml adultos)', 'Cada 6 a 8 horas', '3 a 7 días', 'Tos seca irritativa no productiva', 'No usar con IMAO, no usar en tos productiva, puede causar somnolencia'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Dextrometorfano')
    and lower(coalesce(concentration, '')) = lower('15 mg/5 ml frasco 120 ml')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Atosyl', null, true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Dextrometorfano')
  and lower(coalesce(d.concentration, '')) = lower('15 mg/5 ml frasco 120 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Atosyl')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Notusin', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Dextrometorfano')
  and lower(coalesce(d.concentration, '')) = lower('15 mg/5 ml frasco 120 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Notusin')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Dextrin G', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Dextrometorfano')
  and lower(coalesce(d.concentration, '')) = lower('15 mg/5 ml frasco 120 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Dextrin G')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Tussolvina', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Dextrometorfano')
  and lower(coalesce(d.concentration, '')) = lower('15 mg/5 ml frasco 120 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Tussolvina')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Dextrometorfano Labovida', 'Labovida', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Dextrometorfano')
  and lower(coalesce(d.concentration, '')) = lower('15 mg/5 ml frasco 120 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Dextrometorfano Labovida')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Salbutamol', 'Broncodilatador beta-2 agonista de acción corta', 'Inhalador', '100 mcg/dosis', 'Inhalatoria', '1 inhalador de 200 dosis', '2 inhalaciones', 'Cada 4 a 6 horas según necesidad', 'Uso a demanda en crisis', 'Broncoespasmo en asma y EPOC, prevención de asma por ejercicio', 'Puede causar temblor y taquicardia, uso excesivo indica mal control del asma'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Salbutamol')
    and lower(coalesce(concentration, '')) = lower('100 mcg/dosis')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Ventolin', 'GSK', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Salbutamol')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Ventolin')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Bemin', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Salbutamol')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Bemin')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Bromuro de ipratropio', 'Broncodilatador anticolinérgico de acción corta', 'Inhalador de dosis medida', '20 mcg/dosis', 'Inhalatoria', '1 inhalador de 200 dosis', '2 inhalaciones', 'Cada 6 a 8 horas', 'Según evolución de la enfermedad de base', 'Broncoespasmo en EPOC, coadyuvante en asma', 'Precaución en glaucoma de ángulo estrecho e hipertrofia prostática'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Bromuro de ipratropio')
    and lower(coalesce(concentration, '')) = lower('20 mcg/dosis')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Atrovent', 'Boehringer Ingelheim', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Bromuro de ipratropio')
  and lower(coalesce(d.concentration, '')) = lower('20 mcg/dosis')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Atrovent')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Budesonida + formoterol', 'Corticoide inhalado con beta-2 de acción prolongada', 'Inhalador', '160/4.5 mcg por dosis', 'Inhalatoria', '1 inhalador', '1 a 2 inhalaciones', 'Cada 12 horas', 'Tratamiento de mantenimiento prolongado', 'Asma persistente, EPOC', 'Enjuagar la boca tras cada uso para evitar candidiasis oral, no suspender bruscamente'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Budesonida + formoterol')
    and lower(coalesce(concentration, '')) = lower('160/4.5 mcg por dosis')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Symbicort', 'AstraZeneca', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Budesonida + formoterol')
  and lower(coalesce(d.concentration, '')) = lower('160/4.5 mcg por dosis')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Symbicort')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Neumocort Plus', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Budesonida + formoterol')
  and lower(coalesce(d.concentration, '')) = lower('160/4.5 mcg por dosis')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Neumocort Plus')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Busterol', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Budesonida + formoterol')
  and lower(coalesce(d.concentration, '')) = lower('160/4.5 mcg por dosis')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Busterol')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Fluticasona nasal', 'Corticoide intranasal', 'Spray nasal', '27.5 mcg/disparo, 120 dosis', 'Intranasal', '1 frasco', '1 a 2 aplicaciones en cada fosa nasal', 'Cada 24 horas', '2 a 4 semanas o uso estacional', 'Rinitis alérgica estacional y perenne', 'Puede causar epistaxis, evitar uso prolongado sin control médico'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Fluticasona nasal')
    and lower(coalesce(concentration, '')) = lower('27.5 mcg/disparo, 120 dosis')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Avamys', 'GSK', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Fluticasona nasal')
  and lower(coalesce(d.concentration, '')) = lower('27.5 mcg/disparo, 120 dosis')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Avamys')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Flixonase', 'GSK', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Fluticasona nasal')
  and lower(coalesce(d.concentration, '')) = lower('27.5 mcg/disparo, 120 dosis')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Flixonase')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Mometasona nasal', 'Corticoide intranasal', 'Spray nasal', '50 mcg/disparo, 140 dosis', 'Intranasal', '1 frasco', '2 aplicaciones en cada fosa nasal', 'Cada 24 horas', '2 a 4 semanas o uso estacional', 'Rinitis alérgica, poliposis nasal', 'Puede causar epistaxis e irritación nasal'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Mometasona nasal')
    and lower(coalesce(concentration, '')) = lower('50 mcg/disparo, 140 dosis')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Nasonex', 'MSD', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Mometasona nasal')
  and lower(coalesce(d.concentration, '')) = lower('50 mcg/disparo, 140 dosis')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Nasonex')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Rinelon', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Mometasona nasal')
  and lower(coalesce(d.concentration, '')) = lower('50 mcg/disparo, 140 dosis')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Rinelon')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Montelukast', 'Antileucotrieno', 'Tableta recubierta', '10 mg (5 y 4 mg pediátricas)', 'Oral', '30 tabletas', '10 mg adultos, 5 mg niños de 6 a 14 años', 'Cada 24 horas en la noche', 'Tratamiento de mantenimiento prolongado', 'Asma leve a moderada, rinitis alérgica', 'Vigilar cambios de conducta o estado de ánimo'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Montelukast')
    and lower(coalesce(concentration, '')) = lower('10 mg (5 y 4 mg pediátricas)')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Singulair', 'MSD', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Montelukast')
  and lower(coalesce(d.concentration, '')) = lower('10 mg (5 y 4 mg pediátricas)')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Singulair')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Montelukast La Santé', 'La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Montelukast')
  and lower(coalesce(d.concentration, '')) = lower('10 mg (5 y 4 mg pediátricas)')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Montelukast La Santé')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Montelukast Medigener', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Montelukast')
  and lower(coalesce(d.concentration, '')) = lower('10 mg (5 y 4 mg pediátricas)')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Montelukast Medigener')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Asventol', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Montelukast')
  and lower(coalesce(d.concentration, '')) = lower('10 mg (5 y 4 mg pediátricas)')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Asventol')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Capturan', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Montelukast')
  and lower(coalesce(d.concentration, '')) = lower('10 mg (5 y 4 mg pediátricas)')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Capturan')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Oximetazolina', 'Descongestionante nasal', 'Spray nasal', '0.05% frasco 15 ml', 'Intranasal', '1 frasco', '2 a 3 aplicaciones en cada fosa nasal', 'Cada 12 horas', 'Máximo 3 a 5 días', 'Congestión nasal por resfriado, sinusitis o rinitis', 'No exceder 3 a 5 días por riesgo de rinitis de rebote, evitar en hipertensos no controlados'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Oximetazolina')
    and lower(coalesce(concentration, '')) = lower('0.05% frasco 15 ml')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Afrin', 'Bayer', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Oximetazolina')
  and lower(coalesce(d.concentration, '')) = lower('0.05% frasco 15 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Afrin')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Oximetazolina MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Oximetazolina')
  and lower(coalesce(d.concentration, '')) = lower('0.05% frasco 15 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Oximetazolina MK')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Prednisona', 'Corticoide sistémico', 'Tableta', '20 mg', 'Oral', '20 a 30 tabletas', '20 a 40 mg al día en ciclo corto', 'Cada 24 horas en la mañana', '5 a 7 días en ciclo corto', 'Exacerbación de asma, crisis alérgicas, procesos inflamatorios agudos', 'Tomar con alimentos, precaución en diabetes e hipertensión, no suspender bruscamente si el ciclo es prolongado'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Prednisona')
    and lower(coalesce(concentration, '')) = lower('20 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Meticorten', null, true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Prednisona')
  and lower(coalesce(d.concentration, '')) = lower('20 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Meticorten')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Presacor', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Prednisona')
  and lower(coalesce(d.concentration, '')) = lower('20 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Presacor')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Bersen', 'Sanfer', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Prednisona')
  and lower(coalesce(d.concentration, '')) = lower('20 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Bersen')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Prednisona Pharmabrand', 'Pharmabrand', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Prednisona')
  and lower(coalesce(d.concentration, '')) = lower('20 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Prednisona Pharmabrand')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Prednisolona', 'Corticoide sistémico', 'Tableta', '5 mg', 'Oral', '30 tabletas', '5 a 40 mg al día según severidad', 'Cada 24 horas en la mañana', '5 a 7 días en ciclo corto', 'Crisis asmática, reacciones alérgicas, laringitis en pediatría', 'Tomar con alimentos, precaución en diabetes e hipertensión'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Prednisolona')
    and lower(coalesce(concentration, '')) = lower('5 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Prednimax', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Prednisolona')
  and lower(coalesce(d.concentration, '')) = lower('5 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Prednimax')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Prednisolona Gutis', 'Gutis', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Prednisolona')
  and lower(coalesce(d.concentration, '')) = lower('5 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Prednisolona Gutis')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Paracetamol + fenilefrina + clorfenamina', 'Antigripal combinado', 'Tableta', '500 mg + 5 mg + 2 mg', 'Oral', 'Caja o sobres de 2 tabletas', '1 tableta', 'Cada 8 horas', '3 a 5 días', 'Alivio sintomático de gripe y resfriado con fiebre, congestión y rinorrea', 'No combinar con otros productos con paracetamol, produce somnolencia, precaución en hipertensos'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Paracetamol + fenilefrina + clorfenamina')
    and lower(coalesce(concentration, '')) = lower('500 mg + 5 mg + 2 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Panadol Antigripal', 'Haleon', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Paracetamol + fenilefrina + clorfenamina')
  and lower(coalesce(d.concentration, '')) = lower('500 mg + 5 mg + 2 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Panadol Antigripal')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Antigripal NF', 'Neofarmaco', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Paracetamol + fenilefrina + clorfenamina')
  and lower(coalesce(d.concentration, '')) = lower('500 mg + 5 mg + 2 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Antigripal NF')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Finalin Gripe', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Paracetamol + fenilefrina + clorfenamina')
  and lower(coalesce(d.concentration, '')) = lower('500 mg + 5 mg + 2 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Finalin Gripe')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Paracetamol + fenilefrina + dextrometorfano', 'Antigripal combinado con antitusivo', 'Tableta', '325 mg + 5 mg + 10 mg', 'Oral', 'Caja o sobres de 2 tabletas', '1 a 2 tabletas', 'Cada 8 horas', '3 a 5 días', 'Gripe y resfriado con tos seca, fiebre y congestión nasal', 'No combinar con otros productos con paracetamol, precaución en hipertensos, no usar con IMAO'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Paracetamol + fenilefrina + dextrometorfano')
    and lower(coalesce(concentration, '')) = lower('325 mg + 5 mg + 10 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Contrex', null, true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Paracetamol + fenilefrina + dextrometorfano')
  and lower(coalesce(d.concentration, '')) = lower('325 mg + 5 mg + 10 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Contrex')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Comtrex', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Paracetamol + fenilefrina + dextrometorfano')
  and lower(coalesce(d.concentration, '')) = lower('325 mg + 5 mg + 10 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Comtrex')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Omeprazol', 'Inhibidor de bomba de protones', 'Cápsula', '20 mg', 'Oral', '14-28 cápsulas', '20 mg', '1 vez al día en ayunas', '4-8 semanas', 'Enfermedad por reflujo gastroesofágico, gastritis, úlcera péptica, dispepsia', 'Tomar 30 minutos antes del desayuno, uso prolongado requiere evaluación médica'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Omeprazol')
    and lower(coalesce(concentration, '')) = lower('20 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Ulcozol', 'Bagó', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Omeprazol')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Ulcozol')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Gastec', 'Laboratorios Bernabó', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Omeprazol')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Gastec')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Omezol Fast', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Omeprazol')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Omezol Fast')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Omeprazol MK', 'Tecnoquímicas MK', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Omeprazol')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Omeprazol MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Omeprazol La Santé', 'La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Omeprazol')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Omeprazol La Santé')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Esomeprazol', 'Inhibidor de bomba de protones', 'Tableta o cápsula', '40 mg', 'Oral', '14-28 tabletas', '20-40 mg', '1 vez al día en ayunas', '4-8 semanas', 'Reflujo gastroesofágico, esofagitis erosiva, erradicación de H. pylori en esquema combinado', 'Tomar antes de la primera comida del día'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Esomeprazol')
    and lower(coalesce(concentration, '')) = lower('40 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Nexium', 'AstraZeneca', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Esomeprazol')
  and lower(coalesce(d.concentration, '')) = lower('40 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Nexium')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Esomeprazol La Santé', 'La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Esomeprazol')
  and lower(coalesce(d.concentration, '')) = lower('40 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Esomeprazol La Santé')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Esomeprazol Vida', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Esomeprazol')
  and lower(coalesce(d.concentration, '')) = lower('40 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Esomeprazol Vida')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Lansoprazol', 'Inhibidor de bomba de protones', 'Cápsula de liberación retardada', '30 mg', 'Oral', '14-28 cápsulas', '30 mg', '1 vez al día en ayunas', '4-8 semanas', 'Reflujo gastroesofágico, úlcera duodenal y gástrica', 'Tomar antes del desayuno'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Lansoprazol')
    and lower(coalesce(concentration, '')) = lower('30 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Lanzopral', 'Roemmers', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Lansoprazol')
  and lower(coalesce(d.concentration, '')) = lower('30 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Lanzopral')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Lansoprazol Nifa', 'Nifa', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Lansoprazol')
  and lower(coalesce(d.concentration, '')) = lower('30 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Lansoprazol Nifa')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Lansoprazol Medigener', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Lansoprazol')
  and lower(coalesce(d.concentration, '')) = lower('30 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Lansoprazol Medigener')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Pantoprazol', 'Inhibidor de bomba de protones', 'Tableta con recubrimiento entérico', '40 mg', 'Oral', '14-30 tabletas', '40 mg', '1 vez al día en ayunas', '4-8 semanas', 'Reflujo gastroesofágico, esofagitis, úlcera péptica', 'Menor interacción farmacológica que otros IBP, útil en polimedicados'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Pantoprazol')
    and lower(coalesce(concentration, '')) = lower('40 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Pantoprazol La Santé', 'La Santé', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Pantoprazol')
  and lower(coalesce(d.concentration, '')) = lower('40 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Pantoprazol La Santé')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Pantoprazol Medigener', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Pantoprazol')
  and lower(coalesce(d.concentration, '')) = lower('40 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Pantoprazol Medigener')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Famotidina', 'Antagonista H2', 'Tableta', '40 mg', 'Oral', '10-30 tabletas', '20-40 mg', '1 vez al día en la noche o cada 12 horas', '4-6 semanas', 'Acidez, dispepsia, úlcera péptica, alternativa a IBP', 'Reemplazó a la ranitidina tras su retiro del mercado ecuatoriano por ARCSA (2022)'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Famotidina')
    and lower(coalesce(concentration, '')) = lower('40 mg')
);

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Hidróxido de aluminio + magnesio + simeticona', 'Antiácido', 'Suspensión oral', 'Frasco 360 ml', 'Oral', '1 frasco de 360 ml', '1-2 cucharadas (10-20 ml)', '3-4 veces al día después de comidas y al acostarse', 'Uso sintomático según necesidad', 'Acidez, gastritis, dispepsia con distensión y flatulencia', 'No usar en insuficiencia renal, separar 2 horas de otros medicamentos'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Hidróxido de aluminio + magnesio + simeticona')
    and lower(coalesce(concentration, '')) = lower('Frasco 360 ml')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Mylanta', null, true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Hidróxido de aluminio + magnesio + simeticona')
  and lower(coalesce(d.concentration, '')) = lower('Frasco 360 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Mylanta')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Hidro Mag', 'Tecnoquímicas MK', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Hidróxido de aluminio + magnesio + simeticona')
  and lower(coalesce(d.concentration, '')) = lower('Frasco 360 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Hidro Mag')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Metoclopramida', 'Antiemético procinético', 'Tableta', '10 mg', 'Oral', '20-30 tabletas', '10 mg', 'Cada 8 horas, 30 minutos antes de comidas', 'Máximo 5 días', 'Náusea, vómito, gastroparesia, dispepsia con retardo de vaciamiento gástrico', 'Riesgo de efectos extrapiramidales, evitar en menores de 18 años y uso prolongado'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Metoclopramida')
    and lower(coalesce(concentration, '')) = lower('10 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Metoclox', null, true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Metoclopramida')
  and lower(coalesce(d.concentration, '')) = lower('10 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Metoclox')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Metoclopramida Mintlab', 'Mintlab', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Metoclopramida')
  and lower(coalesce(d.concentration, '')) = lower('10 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Metoclopramida Mintlab')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Ondansetrón', 'Antiemético antagonista 5-HT3', 'Tableta', '8 mg', 'Oral', '6-10 tabletas', '4-8 mg', 'Cada 8-12 horas', '1-3 días', 'Vómito agudo intenso, vómito asociado a gastroenteritis, quimioterapia o postoperatorio', 'Puede prolongar el intervalo QT, precaución con otros fármacos que lo prolonguen'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Ondansetrón')
    and lower(coalesce(concentration, '')) = lower('8 mg')
);

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Domperidona', 'Antiemético procinético', 'Tableta', '10 mg', 'Oral', '20-30 tabletas', '10 mg', 'Cada 8 horas antes de comidas', 'Máximo 1 semana', 'Náusea, vómito, distensión posprandial, reflujo', 'Riesgo cardíaco (QT) a dosis altas, no exceder 30 mg al día'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Domperidona')
    and lower(coalesce(concentration, '')) = lower('10 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Motilium', 'Janssen', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Domperidona')
  and lower(coalesce(d.concentration, '')) = lower('10 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Motilium')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Dosin', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Domperidona')
  and lower(coalesce(d.concentration, '')) = lower('10 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Dosin')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Butilescopolamina', 'Antiespasmódico anticolinérgico', 'Gragea', '10 mg', 'Oral', '20 grageas', '10-20 mg', 'Cada 8 horas', '2-3 días o según necesidad', 'Cólico y espasmo gastrointestinal, dolor abdominal tipo cólico, cólico biliar leve', 'Evitar en glaucoma, hipertrofia prostática y megacolon'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Butilescopolamina')
    and lower(coalesce(concentration, '')) = lower('10 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Buscapina', 'Boehringer Ingelheim', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Butilescopolamina')
  and lower(coalesce(d.concentration, '')) = lower('10 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Buscapina')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Buscapina Duo', 'Boehringer Ingelheim', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Butilescopolamina')
  and lower(coalesce(d.concentration, '')) = lower('10 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Buscapina Duo')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Buscapina Compositum', 'Boehringer Ingelheim', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Butilescopolamina')
  and lower(coalesce(d.concentration, '')) = lower('10 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Buscapina Compositum')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Loperamida', 'Antidiarreico inhibidor de la motilidad', 'Cápsula', '2 mg', 'Oral', '6-12 cápsulas', '4 mg inicial, luego 2 mg tras cada deposición líquida', 'Máximo 8 mg al día', 'Máximo 2 días', 'Diarrea aguda no complicada en adultos', 'No usar en diarrea con fiebre alta o sangre, no en niños pequeños'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Loperamida')
    and lower(coalesce(concentration, '')) = lower('2 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Velaral', null, true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Loperamida')
  and lower(coalesce(d.concentration, '')) = lower('2 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Velaral')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Sales de rehidratación oral', 'Solución de rehidratación oral', 'Solución oral o polvo en sobres', 'Frasco 500 ml o sobre para 1 litro', 'Oral', '1-2 frascos o 4-10 sobres', '50-100 ml/kg en 4 horas en deshidratación leve, o a libre demanda', 'Continuo mientras dure la diarrea', 'Hasta resolver la diarrea o el vómito', 'Prevención y tratamiento de deshidratación por diarrea y vómito', 'Preferir fórmulas de osmolaridad reducida OMS'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Sales de rehidratación oral')
    and lower(coalesce(concentration, '')) = lower('Frasco 500 ml o sobre para 1 litro')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Pedialyte', 'Abbott', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Sales de rehidratación oral')
  and lower(coalesce(d.concentration, '')) = lower('Frasco 500 ml o sobre para 1 litro')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Pedialyte')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Oralyte', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Sales de rehidratación oral')
  and lower(coalesce(d.concentration, '')) = lower('Frasco 500 ml o sobre para 1 litro')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Oralyte')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Hidraplus', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Sales de rehidratación oral')
  and lower(coalesce(d.concentration, '')) = lower('Frasco 500 ml o sobre para 1 litro')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Hidraplus')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Lactulosa', 'Laxante osmótico', 'Jarabe', '65 g/100 ml frasco 200 ml', 'Oral', '1 frasco de 200 ml', '15-30 ml', '1-2 veces al día', 'Uso continuo según respuesta', 'Estreñimiento crónico, encefalopatía hepática', 'Puede producir flatulencia y distensión los primeros días'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Lactulosa')
    and lower(coalesce(concentration, '')) = lower('65 g/100 ml frasco 200 ml')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Duphalac', 'Abbott', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Lactulosa')
  and lower(coalesce(d.concentration, '')) = lower('65 g/100 ml frasco 200 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Duphalac')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Lactulosa Mintlab', 'Mintlab', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Lactulosa')
  and lower(coalesce(d.concentration, '')) = lower('65 g/100 ml frasco 200 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Lactulosa Mintlab')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Bisacodilo', 'Laxante estimulante', 'Gragea con recubrimiento entérico', '5 mg', 'Oral', '10 grageas', '5-10 mg', '1 vez al día en la noche', 'Uso ocasional, máximo 5-7 días', 'Estreñimiento ocasional, preparación intestinal', 'No usar de forma crónica, no partir la gragea, evitar con leche o antiácidos'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Bisacodilo')
    and lower(coalesce(concentration, '')) = lower('5 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Dulcolax', null, true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Bisacodilo')
  and lower(coalesce(d.concentration, '')) = lower('5 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Dulcolax')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Polietilenglicol (macrogol 3350)', 'Laxante osmótico', 'Polvo para solución oral en sobres', '17 g por sobre', 'Oral', '7-10 sobres', '17 g disueltos en un vaso de agua', '1 vez al día', '2-4 semanas según respuesta', 'Estreñimiento crónico funcional', 'Efecto en 1-3 días, mantener buena hidratación'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Polietilenglicol (macrogol 3350)')
    and lower(coalesce(concentration, '')) = lower('17 g por sobre')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Neolax', 'GrupoFarma del Ecuador', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Polietilenglicol (macrogol 3350)')
  and lower(coalesce(d.concentration, '')) = lower('17 g por sobre')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Neolax')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Accualaxan', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Polietilenglicol (macrogol 3350)')
  and lower(coalesce(d.concentration, '')) = lower('17 g por sobre')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Accualaxan')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Nulytely', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Polietilenglicol (macrogol 3350)')
  and lower(coalesce(d.concentration, '')) = lower('17 g por sobre')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Nulytely')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Simeticona', 'Antiflatulento', 'Gotas orales', '40 mg/ml frasco 15 ml', 'Oral', '1 frasco de 15 ml', '40-80 mg (20-40 gotas)', 'Después de cada comida, 3-4 veces al día', 'Uso sintomático según necesidad', 'Meteorismo, flatulencia, distensión abdominal, cólico del lactante', 'Muy seguro, no se absorbe'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Simeticona')
    and lower(coalesce(concentration, '')) = lower('40 mg/ml frasco 15 ml')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Aero-Om', null, true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Simeticona')
  and lower(coalesce(d.concentration, '')) = lower('40 mg/ml frasco 15 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Aero-Om')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Simetidig', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Simeticona')
  and lower(coalesce(d.concentration, '')) = lower('40 mg/ml frasco 15 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Simetidig')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Digesta', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Simeticona')
  and lower(coalesce(d.concentration, '')) = lower('40 mg/ml frasco 15 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Digesta')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Saccharomyces boulardii', 'Probiótico antidiarreico', 'Cápsula o sobre liofilizado', '250 mg', 'Oral', '6-12 cápsulas o sobres', '250 mg', 'Cada 12-24 horas', '5-7 días', 'Diarrea aguda, coadyuvante en diarrea por antibióticos', 'No administrar en inmunosuprimidos ni pacientes con catéter venoso central'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Saccharomyces boulardii')
    and lower(coalesce(concentration, '')) = lower('250 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Floratil', null, true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Saccharomyces boulardii')
  and lower(coalesce(d.concentration, '')) = lower('250 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Floratil')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Esporas de Bacillus clausii', 'Probiótico', 'Suspensión oral en viales bebibles', '2 mil millones de esporas/5 ml', 'Oral', '10 viales de 5 ml', '1 vial (5 ml)', 'Cada 12-24 horas', '5-10 días', 'Restauración de flora intestinal en diarrea aguda y durante antibioticoterapia', 'Puede tomarse junto con antibióticos'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Esporas de Bacillus clausii')
    and lower(coalesce(concentration, '')) = lower('2 mil millones de esporas/5 ml')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Enterogermina', 'Sanofi', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Esporas de Bacillus clausii')
  and lower(coalesce(d.concentration, '')) = lower('2 mil millones de esporas/5 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Enterogermina')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Losartán', 'Antihipertensivo ARA-II', 'Tableta', '50 mg', 'Oral', '30 tabletas', '50-100 mg', 'Cada 24 horas', 'Uso crónico continuo', 'Hipertensión arterial, protección renal en diabetes', 'Evitar en embarazo, controlar potasio y función renal'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Losartán')
    and lower(coalesce(concentration, '')) = lower('50 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Cozaar', 'MSD', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Losartán')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Cozaar')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Angioten', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Losartán')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Angioten')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Losartán MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Losartán')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Losartán MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Losartán Medigener', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Losartán')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Losartán Medigener')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Valsartán', 'Antihipertensivo ARA-II', 'Tableta recubierta', '160 mg', 'Oral', '30 tabletas', '80-320 mg', 'Cada 24 horas', 'Uso crónico continuo', 'Hipertensión arterial, insuficiencia cardíaca', 'Evitar en embarazo, vigilar potasio'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Valsartán')
    and lower(coalesce(concentration, '')) = lower('160 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Diovan', 'Novartis', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Valsartán')
  and lower(coalesce(d.concentration, '')) = lower('160 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Diovan')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Valsartán MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Valsartán')
  and lower(coalesce(d.concentration, '')) = lower('160 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Valsartán MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Valsartán La Santé', 'Laboratorios La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Valsartán')
  and lower(coalesce(d.concentration, '')) = lower('160 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Valsartán La Santé')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Telmisartán', 'Antihipertensivo ARA-II', 'Tableta', '80 mg', 'Oral', '30 tabletas', '40-80 mg', 'Cada 24 horas', 'Uso crónico continuo', 'Hipertensión arterial', 'Evitar en embarazo y estenosis biliar'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Telmisartán')
    and lower(coalesce(concentration, '')) = lower('80 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Micardis', 'Boehringer Ingelheim', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Telmisartán')
  and lower(coalesce(d.concentration, '')) = lower('80 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Micardis')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Telmisartán La Santé', 'Laboratorios La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Telmisartán')
  and lower(coalesce(d.concentration, '')) = lower('80 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Telmisartán La Santé')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Enalapril', 'Antihipertensivo IECA', 'Tableta', '20 mg', 'Oral', '30 tabletas', '10-20 mg', 'Cada 12-24 horas', 'Uso crónico continuo', 'Hipertensión arterial, insuficiencia cardíaca', 'Tos seca frecuente, evitar en embarazo, riesgo de angioedema'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Enalapril')
    and lower(coalesce(concentration, '')) = lower('20 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Renitec', 'MSD', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Enalapril')
  and lower(coalesce(d.concentration, '')) = lower('20 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Renitec')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Enalapril MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Enalapril')
  and lower(coalesce(d.concentration, '')) = lower('20 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Enalapril MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Enalapril Genfar', 'Genfar', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Enalapril')
  and lower(coalesce(d.concentration, '')) = lower('20 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Enalapril Genfar')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Amlodipino', 'Antihipertensivo calcioantagonista', 'Tableta', '5 mg', 'Oral', '30 tabletas', '5-10 mg', 'Cada 24 horas', 'Uso crónico continuo', 'Hipertensión arterial, angina estable', 'Edema de tobillos frecuente, cefalea inicial'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Amlodipino')
    and lower(coalesce(concentration, '')) = lower('5 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Norvas', 'Pfizer', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Amlodipino')
  and lower(coalesce(d.concentration, '')) = lower('5 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Norvas')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Amlodipino MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Amlodipino')
  and lower(coalesce(d.concentration, '')) = lower('5 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Amlodipino MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Amlodipino La Santé', 'Laboratorios La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Amlodipino')
  and lower(coalesce(d.concentration, '')) = lower('5 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Amlodipino La Santé')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Nifedipino', 'Antihipertensivo calcioantagonista', 'Tableta de liberación prolongada', '30 mg', 'Oral', '30 tabletas', '30-60 mg', 'Cada 24 horas', 'Uso crónico continuo', 'Hipertensión arterial, angina', 'No usar formas de acción corta en crisis hipertensiva, rubor y edema'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Nifedipino')
    and lower(coalesce(concentration, '')) = lower('30 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Adalat OROS', 'Bayer', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Nifedipino')
  and lower(coalesce(d.concentration, '')) = lower('30 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Adalat OROS')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Nifedipino MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Nifedipino')
  and lower(coalesce(d.concentration, '')) = lower('30 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Nifedipino MK')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Atenolol', 'Betabloqueador cardioselectivo', 'Tableta', '50 mg', 'Oral', '28-30 tabletas', '50-100 mg', 'Cada 24 horas', 'Uso crónico continuo', 'Hipertensión arterial, angina, control de frecuencia', 'No suspender bruscamente, precaución en asma y bradicardia'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Atenolol')
    and lower(coalesce(concentration, '')) = lower('50 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Tenormin', 'AstraZeneca', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Atenolol')
  and lower(coalesce(d.concentration, '')) = lower('50 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Tenormin')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Atenolol MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Atenolol')
  and lower(coalesce(d.concentration, '')) = lower('50 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Atenolol MK')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Bisoprolol', 'Betabloqueador cardioselectivo', 'Tableta recubierta', '5 mg', 'Oral', '30 tabletas', '2.5-10 mg', 'Cada 24 horas', 'Uso crónico continuo', 'Hipertensión arterial, insuficiencia cardíaca, angina', 'No suspender bruscamente, vigilar bradicardia'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Bisoprolol')
    and lower(coalesce(concentration, '')) = lower('5 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Concor', 'Merck', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Bisoprolol')
  and lower(coalesce(d.concentration, '')) = lower('5 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Concor')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Bisoprolol MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Bisoprolol')
  and lower(coalesce(d.concentration, '')) = lower('5 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Bisoprolol MK')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Carvedilol', 'Betabloqueador no selectivo con acción alfa', 'Tableta', '25 mg', 'Oral', '30 tabletas', '6.25-25 mg', 'Cada 12 horas', 'Uso crónico continuo', 'Insuficiencia cardíaca, hipertensión arterial', 'Titular gradualmente, hipotensión ortostática, no suspender bruscamente'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Carvedilol')
    and lower(coalesce(concentration, '')) = lower('25 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Dilatrend', 'Roche', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Carvedilol')
  and lower(coalesce(d.concentration, '')) = lower('25 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Dilatrend')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Carvedil', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Carvedilol')
  and lower(coalesce(d.concentration, '')) = lower('25 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Carvedil')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Carvedilol MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Carvedilol')
  and lower(coalesce(d.concentration, '')) = lower('25 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Carvedilol MK')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Hidroclorotiazida', 'Diurético tiazídico', 'Tableta', '25 mg', 'Oral', '30 tabletas', '12.5-25 mg', 'Cada 24 horas en la mañana', 'Uso crónico continuo', 'Hipertensión arterial, edema leve', 'Vigilar potasio y sodio, puede elevar glucosa y ácido úrico'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Hidroclorotiazida')
    and lower(coalesce(concentration, '')) = lower('25 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Hidroclorotiazida MK', 'Tecnoquímicas', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Hidroclorotiazida')
  and lower(coalesce(d.concentration, '')) = lower('25 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Hidroclorotiazida MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Hidroclorotiazida La Santé', 'Laboratorios La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Hidroclorotiazida')
  and lower(coalesce(d.concentration, '')) = lower('25 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Hidroclorotiazida La Santé')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Furosemida', 'Diurético de asa', 'Tableta', '40 mg', 'Oral', '20-30 tabletas', '20-80 mg', 'Cada 24 horas en la mañana', 'Según evolución, uso crónico si es necesario', 'Edema por insuficiencia cardíaca, renal o hepática', 'Vigilar potasio y función renal, riesgo de deshidratación'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Furosemida')
    and lower(coalesce(concentration, '')) = lower('40 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Lasix', 'Sanofi', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Furosemida')
  and lower(coalesce(d.concentration, '')) = lower('40 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Lasix')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Furosemida MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Furosemida')
  and lower(coalesce(d.concentration, '')) = lower('40 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Furosemida MK')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Espironolactona', 'Diurético ahorrador de potasio', 'Tableta', '25 mg', 'Oral', '30 tabletas', '25-50 mg', 'Cada 24 horas', 'Uso crónico continuo', 'Insuficiencia cardíaca, hipertensión resistente, edema', 'Riesgo de hiperkalemia, ginecomastia, vigilar función renal'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Espironolactona')
    and lower(coalesce(concentration, '')) = lower('25 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Aldactone', 'Pfizer', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Espironolactona')
  and lower(coalesce(d.concentration, '')) = lower('25 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Aldactone')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Espironolactona MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Espironolactona')
  and lower(coalesce(d.concentration, '')) = lower('25 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Espironolactona MK')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Atorvastatina', 'Hipolipemiante estatina', 'Tableta recubierta', '20 mg', 'Oral', '30 tabletas', '10-80 mg', 'Cada 24 horas en la noche', 'Uso crónico continuo', 'Hipercolesterolemia, prevención cardiovascular', 'Vigilar transaminasas, suspender si mialgias intensas, evitar en embarazo'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Atorvastatina')
    and lower(coalesce(concentration, '')) = lower('20 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Lipitor', 'Pfizer', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Atorvastatina')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Lipitor')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Atorvastatina MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Atorvastatina')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Atorvastatina MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Atorvastatina La Santé', 'Laboratorios La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Atorvastatina')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Atorvastatina La Santé')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Atosyl', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Atorvastatina')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Atosyl')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Rosuvastatina', 'Hipolipemiante estatina', 'Tableta recubierta', '10 mg', 'Oral', '30 tabletas', '5-40 mg', 'Cada 24 horas', 'Uso crónico continuo', 'Hipercolesterolemia, prevención cardiovascular', 'Vigilar transaminasas y CK, evitar en embarazo'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Rosuvastatina')
    and lower(coalesce(concentration, '')) = lower('10 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Crestor', 'AstraZeneca', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Rosuvastatina')
  and lower(coalesce(d.concentration, '')) = lower('10 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Crestor')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Rosuvastatina La Santé', 'Laboratorios La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Rosuvastatina')
  and lower(coalesce(d.concentration, '')) = lower('10 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Rosuvastatina La Santé')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Rosuvastatina MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Rosuvastatina')
  and lower(coalesce(d.concentration, '')) = lower('10 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Rosuvastatina MK')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Simvastatina', 'Hipolipemiante estatina', 'Tableta recubierta', '20 mg', 'Oral', '30 tabletas', '10-40 mg', 'Cada 24 horas en la noche', 'Uso crónico continuo', 'Hipercolesterolemia', 'Interacciones con macrólidos y azoles, mialgias, evitar en embarazo'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Simvastatina')
    and lower(coalesce(concentration, '')) = lower('20 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Simvastatina MK', 'Tecnoquímicas', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Simvastatina')
  and lower(coalesce(d.concentration, '')) = lower('20 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Simvastatina MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Simvastatina La Santé', 'Laboratorios La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Simvastatina')
  and lower(coalesce(d.concentration, '')) = lower('20 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Simvastatina La Santé')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Gemfibrozilo', 'Hipolipemiante fibrato', 'Tableta recubierta', '600 mg', 'Oral', '30 tabletas', '600 mg', 'Cada 12 horas antes de comidas', 'Uso crónico continuo', 'Hipertrigliceridemia', 'No combinar con estatinas de rutina por riesgo de miopatía'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Gemfibrozilo')
    and lower(coalesce(concentration, '')) = lower('600 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Lopid', 'Pfizer', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Gemfibrozilo')
  and lower(coalesce(d.concentration, '')) = lower('600 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Lopid')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Gemfibrozilo MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Gemfibrozilo')
  and lower(coalesce(d.concentration, '')) = lower('600 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Gemfibrozilo MK')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Metformina', 'Antidiabético biguanida', 'Tableta recubierta', '850 mg', 'Oral', '30-60 tabletas', '500-1000 mg', 'Cada 8-12 horas con comidas', 'Uso crónico continuo', 'Diabetes mellitus tipo 2, primera línea', 'Suspender ante falla renal severa o contrastes yodados, molestias gastrointestinales iniciales'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Metformina')
    and lower(coalesce(concentration, '')) = lower('850 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Glucofage', 'Merck', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Metformina')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Glucofage')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Metformina MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Metformina')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Metformina MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Metformina Nifa', 'Nifa', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Metformina')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Metformina Nifa')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Glibenclamida', 'Antidiabético sulfonilurea', 'Tableta', '5 mg', 'Oral', '30 tabletas', '2.5-10 mg', 'Cada 12-24 horas antes de comidas', 'Uso crónico continuo', 'Diabetes mellitus tipo 2', 'Riesgo de hipoglucemia especialmente en adultos mayores'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Glibenclamida')
    and lower(coalesce(concentration, '')) = lower('5 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Glibenclamida MK', 'Tecnoquímicas', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Glibenclamida')
  and lower(coalesce(d.concentration, '')) = lower('5 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Glibenclamida MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Glibenclamida La Santé', 'Laboratorios La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Glibenclamida')
  and lower(coalesce(d.concentration, '')) = lower('5 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Glibenclamida La Santé')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Glimepirida', 'Antidiabético sulfonilurea', 'Tableta', '4 mg', 'Oral', '30 tabletas', '1-4 mg', 'Cada 24 horas con el desayuno', 'Uso crónico continuo', 'Diabetes mellitus tipo 2', 'Riesgo de hipoglucemia, precaución en insuficiencia renal'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Glimepirida')
    and lower(coalesce(concentration, '')) = lower('4 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Amaryl', 'Sanofi', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Glimepirida')
  and lower(coalesce(d.concentration, '')) = lower('4 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Amaryl')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Glimepirida MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Glimepirida')
  and lower(coalesce(d.concentration, '')) = lower('4 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Glimepirida MK')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Sitagliptina', 'Antidiabético inhibidor DPP-4', 'Tableta recubierta', '100 mg', 'Oral', '28 tabletas', '100 mg', 'Cada 24 horas', 'Uso crónico continuo', 'Diabetes mellitus tipo 2 sola o combinada con metformina', 'Ajustar dosis en insuficiencia renal, vigilar pancreatitis'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Sitagliptina')
    and lower(coalesce(concentration, '')) = lower('100 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Januvia', 'MSD', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Sitagliptina')
  and lower(coalesce(d.concentration, '')) = lower('100 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Januvia')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Janumet', 'MSD', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Sitagliptina')
  and lower(coalesce(d.concentration, '')) = lower('100 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Janumet')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Empagliflozina', 'Antidiabético inhibidor SGLT2', 'Tableta recubierta', '10 mg', 'Oral', '30 tabletas', '10-25 mg', 'Cada 24 horas en la mañana', 'Uso crónico continuo', 'Diabetes mellitus tipo 2, insuficiencia cardíaca, protección renal', 'Riesgo de infecciones genitourinarias, cetoacidosis euglucémica rara'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Empagliflozina')
    and lower(coalesce(concentration, '')) = lower('10 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Jardiance', 'Boehringer Ingelheim', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Empagliflozina')
  and lower(coalesce(d.concentration, '')) = lower('10 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Jardiance')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Jardiance Duo', 'Boehringer Ingelheim', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Empagliflozina')
  and lower(coalesce(d.concentration, '')) = lower('10 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Jardiance Duo')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Insulina humana NPH', 'Insulina de acción intermedia', 'Suspensión inyectable', '100 UI/ml frasco 10 ml', 'Subcutánea', '1 frasco de 10 ml', 'Según requerimiento individual, inicio 0.2 UI/kg/día', 'Cada 12-24 horas', 'Uso crónico continuo', 'Diabetes mellitus tipo 2 con falla a orales, diabetes tipo 1', 'Riesgo de hipoglucemia, rotar sitios de inyección, refrigerar'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Insulina humana NPH')
    and lower(coalesce(concentration, '')) = lower('100 UI/ml frasco 10 ml')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Humulin N', 'Eli Lilly', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Insulina humana NPH')
  and lower(coalesce(d.concentration, '')) = lower('100 UI/ml frasco 10 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Humulin N')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Insuman N', 'Sanofi', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Insulina humana NPH')
  and lower(coalesce(d.concentration, '')) = lower('100 UI/ml frasco 10 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Insuman N')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Insulina glargina', 'Insulina basal de acción prolongada', 'Solución inyectable', '100 UI/ml pluma 3 ml o frasco 10 ml', 'Subcutánea', '1 pluma prellenada o frasco', 'Según requerimiento individual, inicio 10 UI/día', 'Cada 24 horas a la misma hora', 'Uso crónico continuo', 'Diabetes mellitus tipo 2 y tipo 1 como insulina basal', 'Riesgo de hipoglucemia, no mezclar con otras insulinas'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Insulina glargina')
    and lower(coalesce(concentration, '')) = lower('100 UI/ml pluma 3 ml o frasco 10 ml')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Lantus', 'Sanofi', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Insulina glargina')
  and lower(coalesce(d.concentration, '')) = lower('100 UI/ml pluma 3 ml o frasco 10 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Lantus')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Lantus SoloStar', 'Sanofi', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Insulina glargina')
  and lower(coalesce(d.concentration, '')) = lower('100 UI/ml pluma 3 ml o frasco 10 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Lantus SoloStar')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Basaglar', 'Eli Lilly', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Insulina glargina')
  and lower(coalesce(d.concentration, '')) = lower('100 UI/ml pluma 3 ml o frasco 10 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Basaglar')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Ácido acetilsalicílico', 'Antiagregante plaquetario', 'Tableta recubierta entérica', '100 mg', 'Oral', '30 tabletas', '100 mg', 'Cada 24 horas con alimentos', 'Uso crónico continuo', 'Prevención secundaria cardiovascular y cerebrovascular', 'Riesgo de sangrado digestivo, suspender ante cirugía según indicación'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Ácido acetilsalicílico')
    and lower(coalesce(concentration, '')) = lower('100 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Cardioaspirina', 'Bayer', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ácido acetilsalicílico')
  and lower(coalesce(d.concentration, '')) = lower('100 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Cardioaspirina')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Aspirina', 'Bayer', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ácido acetilsalicílico')
  and lower(coalesce(d.concentration, '')) = lower('100 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Aspirina')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Clopidogrel', 'Antiagregante plaquetario', 'Tableta recubierta', '75 mg', 'Oral', '14-30 tabletas', '75 mg', 'Cada 24 horas', 'Uso crónico o mínimo 12 meses tras síndrome coronario según indicación', 'Síndrome coronario agudo, post stent, prevención de eventos aterotrombóticos', 'Riesgo de sangrado, no suspender sin indicación del cardiólogo'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Clopidogrel')
    and lower(coalesce(concentration, '')) = lower('75 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Plavix', 'Sanofi', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Clopidogrel')
  and lower(coalesce(d.concentration, '')) = lower('75 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Plavix')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Clopidogrel MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Clopidogrel')
  and lower(coalesce(d.concentration, '')) = lower('75 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Clopidogrel MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Clopidogrel La Santé', 'Laboratorios La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Clopidogrel')
  and lower(coalesce(d.concentration, '')) = lower('75 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Clopidogrel La Santé')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Levotiroxina', 'Hormona tiroidea', 'Tableta', '75 mcg', 'Oral', '50 tabletas', '25-150 mcg según TSH', 'Cada 24 horas en ayunas', 'Uso crónico continuo de por vida en la mayoría', 'Hipotiroidismo de cualquier etiología', 'Tomar en ayunas 30-60 minutos antes del desayuno, controlar TSH cada 6-12 semanas al ajustar'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Levotiroxina')
    and lower(coalesce(concentration, '')) = lower('75 mcg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Eutirox', 'Merck', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Levotiroxina')
  and lower(coalesce(d.concentration, '')) = lower('75 mcg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Eutirox')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Levotiroxina MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Levotiroxina')
  and lower(coalesce(d.concentration, '')) = lower('75 mcg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Levotiroxina MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Levotiroxina BKF', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Levotiroxina')
  and lower(coalesce(d.concentration, '')) = lower('75 mcg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Levotiroxina BKF')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Betametasona tópica', 'Corticoide tópico', 'Crema', '0.05%', 'Tópica', 'Tubo de 20-40 g', 'Aplicar capa fina en zona afectada', '2 veces al día', '7-14 días', 'Dermatitis, eccema, psoriasis, prurito inflamatorio', 'No usar en cara ni pliegues por tiempo prolongado, evitar en infecciones cutáneas no tratadas'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Betametasona tópica')
    and lower(coalesce(concentration, '')) = lower('0.05%')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Diprosone', 'Organon', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Betametasona tópica')
  and lower(coalesce(d.concentration, '')) = lower('0.05%')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Diprosone')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Betametasona MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Betametasona tópica')
  and lower(coalesce(d.concentration, '')) = lower('0.05%')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Betametasona MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Betametasona Mintlab', 'Mintlab', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Betametasona tópica')
  and lower(coalesce(d.concentration, '')) = lower('0.05%')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Betametasona Mintlab')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Clotrimazol + betametasona', 'Antimicótico con corticoide tópico', 'Crema', '1% + 0.05%', 'Tópica', 'Tubo de 15-30 g', 'Aplicar capa fina en zona afectada', '2 veces al día', '7-14 días', 'Micosis cutáneas con componente inflamatorio, intertrigo', 'No usar más de 2 semanas, evitar oclusión prolongada'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Clotrimazol + betametasona')
    and lower(coalesce(concentration, '')) = lower('1% + 0.05%')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Triderm', 'Organon', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Clotrimazol + betametasona')
  and lower(coalesce(d.concentration, '')) = lower('1% + 0.05%')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Triderm')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Clotrimazol + Betametasona Mintlab', 'Mintlab', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Clotrimazol + betametasona')
  and lower(coalesce(d.concentration, '')) = lower('1% + 0.05%')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Clotrimazol + Betametasona Mintlab')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Diprogenta', 'Organon', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Clotrimazol + betametasona')
  and lower(coalesce(d.concentration, '')) = lower('1% + 0.05%')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Diprogenta')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Terbinafina tópica', 'Antimicótico tópico', 'Crema', '1%', 'Tópica', 'Tubo de 15-30 g', 'Aplicar capa fina en zona afectada', '1-2 veces al día', '1-2 semanas', 'Tiña pedis, tiña corporal, tiña crural', 'Suspender si hay irritación intensa'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Terbinafina tópica')
    and lower(coalesce(concentration, '')) = lower('1%')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Lamisil', 'Haleon', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Terbinafina tópica')
  and lower(coalesce(d.concentration, '')) = lower('1%')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Lamisil')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Terbinafina MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Terbinafina tópica')
  and lower(coalesce(d.concentration, '')) = lower('1%')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Terbinafina MK')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Mupirocina', 'Antibiótico tópico', 'Ungüento', '2%', 'Tópica', 'Tubo de 15 g', 'Aplicar en lesión', '3 veces al día', '5-10 días', 'Impétigo, foliculitis, infecciones cutáneas bacterianas leves', 'Evitar contacto con ojos, no usar en áreas extensas'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Mupirocina')
    and lower(coalesce(concentration, '')) = lower('2%')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Bactroban', 'GSK', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Mupirocina')
  and lower(coalesce(d.concentration, '')) = lower('2%')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Bactroban')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Ácido fusídico', 'Antibiótico tópico', 'Crema', '2%', 'Tópica', 'Tubo de 15 g', 'Aplicar en lesión', '2-3 veces al día', '7 días', 'Impétigo, infecciones cutáneas por estafilococo y estreptococo', 'Uso prolongado favorece resistencia bacteriana'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Ácido fusídico')
    and lower(coalesce(concentration, '')) = lower('2%')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Fucidin', 'Leo Pharma', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ácido fusídico')
  and lower(coalesce(d.concentration, '')) = lower('2%')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Fucidin')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Tobramicina + dexametasona', 'Antibiótico con corticoide oftálmico', 'Suspensión oftálmica', '0.3% + 0.1% frasco 5 ml', 'Oftálmica', '1 frasco de 5 ml', '1-2 gotas en el ojo afectado', 'Cada 4-6 horas', '5-7 días', 'Conjuntivitis bacteriana con inflamación, blefaritis', 'No usar más de 7 días sin control, puede elevar presión intraocular'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Tobramicina + dexametasona')
    and lower(coalesce(concentration, '')) = lower('0.3% + 0.1% frasco 5 ml')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Trazidex Ofteno', 'Sophia', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Tobramicina + dexametasona')
  and lower(coalesce(d.concentration, '')) = lower('0.3% + 0.1% frasco 5 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Trazidex Ofteno')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Tobradex', 'Alcon', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Tobramicina + dexametasona')
  and lower(coalesce(d.concentration, '')) = lower('0.3% + 0.1% frasco 5 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Tobradex')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Xolof D', null, false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Tobramicina + dexametasona')
  and lower(coalesce(d.concentration, '')) = lower('0.3% + 0.1% frasco 5 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Xolof D')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Polimixina B + neomicina + hidrocortisona', 'Antibiótico con corticoide ótico', 'Gotas óticas', 'Frasco 10 ml', 'Ótica', '1 frasco de 10 ml', '3-4 gotas en el oído afectado', '3-4 veces al día', '7 días', 'Otitis externa aguda', 'Contraindicado si hay perforación timpánica'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Polimixina B + neomicina + hidrocortisona')
    and lower(coalesce(concentration, '')) = lower('Frasco 10 ml')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Otosporin', null, true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Polimixina B + neomicina + hidrocortisona')
  and lower(coalesce(d.concentration, '')) = lower('Frasco 10 ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Otosporin')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Clotrimazol vaginal', 'Antimicótico ginecológico', 'Óvulo vaginal', '500 mg', 'Vaginal', '1 óvulo dosis única', '1 óvulo intravaginal', 'Dosis única nocturna', '1 día (o 3 noches con 200 mg)', 'Candidiasis vulvovaginal', 'Evitar en primer trimestre de embarazo salvo indicación médica'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Clotrimazol vaginal')
    and lower(coalesce(concentration, '')) = lower('500 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Gyno-Canesten', 'Bayer', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Clotrimazol vaginal')
  and lower(coalesce(d.concentration, '')) = lower('500 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Gyno-Canesten')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Metronidazol + nistatina vaginal', 'Antiinfeccioso ginecológico combinado', 'Óvulo vaginal', '500 mg + 100000 UI', 'Vaginal', 'Caja de 10 óvulos', '1 óvulo intravaginal por la noche', '1 vez al día', '10 días', 'Vaginitis mixta, vaginosis bacteriana con candidiasis', 'Evitar alcohol durante el tratamiento'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Metronidazol + nistatina vaginal')
    and lower(coalesce(concentration, '')) = lower('500 mg + 100000 UI')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Flagystatin', 'Sanofi', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Metronidazol + nistatina vaginal')
  and lower(coalesce(d.concentration, '')) = lower('500 mg + 100000 UI')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Flagystatin')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Levonorgestrel + etinilestradiol', 'Anticonceptivo oral combinado', 'Gragea', '0.15 mg + 0.03 mg', 'Oral', 'Caja de 21 o 28 grageas', '1 gragea diaria', '1 vez al día a la misma hora', 'Ciclos continuos según esquema', 'Anticoncepción hormonal', 'Contraindicado en fumadoras mayores de 35 años, antecedente tromboembólico o migraña con aura'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Levonorgestrel + etinilestradiol')
    and lower(coalesce(concentration, '')) = lower('0.15 mg + 0.03 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Microgynon', 'Bayer', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Levonorgestrel + etinilestradiol')
  and lower(coalesce(d.concentration, '')) = lower('0.15 mg + 0.03 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Microgynon')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Nordette', 'Pfizer', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Levonorgestrel + etinilestradiol')
  and lower(coalesce(d.concentration, '')) = lower('0.15 mg + 0.03 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Nordette')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Drospirenona + etinilestradiol', 'Anticonceptivo oral combinado', 'Comprimido recubierto', '3 mg + 0.03 mg', 'Oral', 'Caja de 21 o 28 comprimidos', '1 comprimido diario', '1 vez al día a la misma hora', 'Ciclos continuos según esquema', 'Anticoncepción hormonal, acné leve asociado', 'Riesgo tromboembólico, vigilar potasio en insuficiencia renal'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Drospirenona + etinilestradiol')
    and lower(coalesce(concentration, '')) = lower('3 mg + 0.03 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Yasmín', 'Bayer', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Drospirenona + etinilestradiol')
  and lower(coalesce(d.concentration, '')) = lower('3 mg + 0.03 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Yasmín')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Yaz', 'Bayer', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Drospirenona + etinilestradiol')
  and lower(coalesce(d.concentration, '')) = lower('3 mg + 0.03 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Yaz')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Complejo B', 'Suplemento vitamínico', 'Tableta recubierta', 'B1 + B6 + B12', 'Oral', 'Caja de 30 tabletas', '1 tableta diaria', '1 vez al día', '30 días o según criterio médico', 'Neuropatías, astenia, suplementación vitamínica', 'Puede teñir la orina de amarillo intenso'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Complejo B')
    and lower(coalesce(concentration, '')) = lower('B1 + B6 + B12')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Neurobion', 'Procter & Gamble', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Complejo B')
  and lower(coalesce(d.concentration, '')) = lower('B1 + B6 + B12')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Neurobion')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Complejo B MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Complejo B')
  and lower(coalesce(d.concentration, '')) = lower('B1 + B6 + B12')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Complejo B MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Complejo B La Santé', 'La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Complejo B')
  and lower(coalesce(d.concentration, '')) = lower('B1 + B6 + B12')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Complejo B La Santé')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Sulfato ferroso', 'Antianémico oral', 'Tableta', '300 mg (60 mg hierro elemental)', 'Oral', 'Caja de 30 tabletas', '1 tableta con el estómago vacío o con jugo cítrico', '1-2 veces al día', '3-6 meses', 'Anemia ferropénica, suplementación en embarazo', 'Heces oscuras, tomar separado de lácteos y antiácidos'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Sulfato ferroso')
    and lower(coalesce(concentration, '')) = lower('300 mg (60 mg hierro elemental)')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Ferranina', null, true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Sulfato ferroso')
  and lower(coalesce(d.concentration, '')) = lower('300 mg (60 mg hierro elemental)')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Ferranina')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Fer-In-Sol', 'Mead Johnson', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Sulfato ferroso')
  and lower(coalesce(d.concentration, '')) = lower('300 mg (60 mg hierro elemental)')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Fer-In-Sol')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Ácido fólico', 'Vitamina antianémica', 'Tableta', '1 mg (o 5 mg)', 'Oral', 'Caja de 30 tabletas', '1 tableta diaria', '1 vez al día', 'Todo el embarazo o 3 meses preconcepcional', 'Prevención de defectos del tubo neural, anemia megaloblástica', null
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Ácido fólico')
    and lower(coalesce(concentration, '')) = lower('1 mg (o 5 mg)')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Ferranina Fol', null, true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ácido fólico')
  and lower(coalesce(d.concentration, '')) = lower('1 mg (o 5 mg)')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Ferranina Fol')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Ácido Fólico MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Ácido fólico')
  and lower(coalesce(d.concentration, '')) = lower('1 mg (o 5 mg)')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Ácido Fólico MK')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Calcio + vitamina D', 'Suplemento mineral', 'Tableta recubierta', '600 mg + 400 UI', 'Oral', 'Frasco de 30-60 tabletas', '1 tableta con alimentos', '1-2 veces al día', 'Uso prolongado según criterio médico', 'Osteoporosis, osteopenia, suplementación en embarazo y adulto mayor', 'Precaución en litiasis renal e hipercalcemia'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Calcio + vitamina D')
    and lower(coalesce(concentration, '')) = lower('600 mg + 400 UI')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Caltrate 600+D', 'Haleon', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Calcio + vitamina D')
  and lower(coalesce(d.concentration, '')) = lower('600 mg + 400 UI')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Caltrate 600+D')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Calcibon D', 'Procaps', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Calcio + vitamina D')
  and lower(coalesce(d.concentration, '')) = lower('600 mg + 400 UI')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Calcibon D')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Sulfato de zinc', 'Suplemento mineral', 'Jarabe', '20 mg/5 ml', 'Oral', 'Frasco de 100-120 ml', '20 mg en niños con diarrea, 10 mg en menores de 6 meses', '1 vez al día', '10-14 días', 'Coadyuvante en diarrea aguda infantil, deficiencia de zinc', 'Tomar alejado de hierro y calcio'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Sulfato de zinc')
    and lower(coalesce(concentration, '')) = lower('20 mg/5 ml')
);

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Alprazolam', 'Ansiolítico benzodiacepínico', 'Tableta', '0.5 mg', 'Oral', 'Caja de 30 tabletas', '0.25-0.5 mg', '2-3 veces al día', 'Corto plazo, 2-4 semanas con retiro gradual', 'Trastorno de ansiedad, crisis de pánico', 'Dependencia y sedación, no combinar con alcohol, receta especial de psicotrópicos'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Alprazolam')
    and lower(coalesce(concentration, '')) = lower('0.5 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Xanax', 'Pfizer', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Alprazolam')
  and lower(coalesce(d.concentration, '')) = lower('0.5 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Xanax')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Alprazolam MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Alprazolam')
  and lower(coalesce(d.concentration, '')) = lower('0.5 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Alprazolam MK')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Clonazepam', 'Ansiolítico y anticonvulsivante benzodiacepínico', 'Tableta', '2 mg', 'Oral', 'Caja de 30 tabletas', '0.5-2 mg', '1-2 veces al día', 'Corto a mediano plazo con retiro gradual', 'Trastorno de pánico, ansiedad, epilepsia', 'Dependencia, somnolencia, receta especial de psicotrópicos'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Clonazepam')
    and lower(coalesce(concentration, '')) = lower('2 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Rivotril', 'Roche', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Clonazepam')
  and lower(coalesce(d.concentration, '')) = lower('2 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Rivotril')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Clonazepam La Santé', 'La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Clonazepam')
  and lower(coalesce(d.concentration, '')) = lower('2 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Clonazepam La Santé')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Sertralina', 'Antidepresivo ISRS', 'Tableta recubierta', '50 mg', 'Oral', 'Caja de 14-30 tabletas', '50-100 mg', '1 vez al día por la mañana', 'Mínimo 6 meses tras remisión', 'Depresión, ansiedad generalizada, trastorno de pánico, TOC', 'Náusea inicial, no suspender bruscamente, vigilar ideación suicida al inicio en jóvenes'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Sertralina')
    and lower(coalesce(concentration, '')) = lower('50 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Altruline', 'Pfizer', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Sertralina')
  and lower(coalesce(d.concentration, '')) = lower('50 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Altruline')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Sertralina Pharmabrand', 'Pharmabrand', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Sertralina')
  and lower(coalesce(d.concentration, '')) = lower('50 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Sertralina Pharmabrand')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Sertralina MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Sertralina')
  and lower(coalesce(d.concentration, '')) = lower('50 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Sertralina MK')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Fluoxetina', 'Antidepresivo ISRS', 'Cápsula', '20 mg', 'Oral', 'Caja de 14-30 cápsulas', '20-40 mg', '1 vez al día por la mañana', 'Mínimo 6 meses tras remisión', 'Depresión, bulimia nerviosa, TOC', 'Insomnio inicial, interacciones por inhibición de CYP2D6'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Fluoxetina')
    and lower(coalesce(concentration, '')) = lower('20 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Prozac', 'Eli Lilly', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Fluoxetina')
  and lower(coalesce(d.concentration, '')) = lower('20 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Prozac')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Fluoxetina Genfar', 'Genfar', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Fluoxetina')
  and lower(coalesce(d.concentration, '')) = lower('20 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Fluoxetina Genfar')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Fluoxetina MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Fluoxetina')
  and lower(coalesce(d.concentration, '')) = lower('20 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Fluoxetina MK')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Escitalopram', 'Antidepresivo ISRS', 'Tableta recubierta', '10 mg', 'Oral', 'Caja de 14-28 tabletas', '10-20 mg', '1 vez al día', 'Mínimo 6 meses tras remisión', 'Depresión, ansiedad generalizada', 'Prolongación de QT a dosis altas, no suspender bruscamente'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Escitalopram')
    and lower(coalesce(concentration, '')) = lower('10 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Lexapro', 'Lundbeck', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Escitalopram')
  and lower(coalesce(d.concentration, '')) = lower('10 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Lexapro')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Escitalopram La Santé', 'La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Escitalopram')
  and lower(coalesce(d.concentration, '')) = lower('10 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Escitalopram La Santé')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Dexametasona', 'Corticoide sistémico', 'Tableta', '4 mg', 'Oral', 'Caja de 10-30 tabletas', '4-8 mg', '1 vez al día o dosis única', 'Ciclos cortos de 3-5 días', 'Procesos inflamatorios y alérgicos agudos, crup, exacerbación asmática', 'Hiperglucemia, evitar uso prolongado sin control, no suspender bruscamente tras ciclos largos'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Dexametasona')
    and lower(coalesce(concentration, '')) = lower('4 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Dexametasona MK', 'Tecnoquímicas', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Dexametasona')
  and lower(coalesce(d.concentration, '')) = lower('4 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Dexametasona MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Dexametasona La Santé', 'La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Dexametasona')
  and lower(coalesce(d.concentration, '')) = lower('4 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Dexametasona La Santé')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Betametasona inyectable', 'Corticoide sistémico de depósito', 'Suspensión inyectable', '5 mg + 2 mg por ml', 'Intramuscular', '1 ampolla de 1 ml', '1 ampolla IM profunda', 'Dosis única, repetible según criterio médico', 'Dosis única o cada 3-4 semanas', 'Cuadros alérgicos e inflamatorios agudos, artritis, dermatosis severas', 'No aplicar en infección activa no tratada, precaución en diabéticos'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Betametasona inyectable')
    and lower(coalesce(concentration, '')) = lower('5 mg + 2 mg por ml')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Diprospan', 'Organon', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Betametasona inyectable')
  and lower(coalesce(d.concentration, '')) = lower('5 mg + 2 mg por ml')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Diprospan')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Alopurinol', 'Hipouricemiante', 'Tableta', '300 mg', 'Oral', 'Caja de 30 tabletas', '100-300 mg', '1 vez al día después de comer', 'Tratamiento crónico continuo', 'Hiperuricemia, gota, prevención de litiasis por ácido úrico', 'No iniciar durante crisis aguda de gota, suspender si aparece rash cutáneo'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Alopurinol')
    and lower(coalesce(concentration, '')) = lower('300 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Alopurinol MK', 'Tecnoquímicas', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Alopurinol')
  and lower(coalesce(d.concentration, '')) = lower('300 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Alopurinol MK')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Alopurinol La Santé', 'La Santé', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Alopurinol')
  and lower(coalesce(d.concentration, '')) = lower('300 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Alopurinol La Santé')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Colchicina', 'Antigotoso', 'Tableta', '0.5 mg', 'Oral', 'Caja de 30 tabletas', '0.5-1 mg al inicio de la crisis, luego 0.5 mg', '1-3 veces al día', 'Hasta ceder la crisis, máximo pocos días', 'Crisis aguda de gota, profilaxis al iniciar alopurinol', 'Diarrea como signo de toxicidad, margen terapéutico estrecho, ajustar en insuficiencia renal'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Colchicina')
    and lower(coalesce(concentration, '')) = lower('0.5 mg')
);

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Betahistina', 'Antivertiginoso', 'Tableta', '24 mg', 'Oral', 'Caja de 20-30 tabletas', '8-16 mg (o 24 mg)', '2-3 veces al día (24 mg cada 12 horas)', '1-3 meses según evolución', 'Vértigo periférico, enfermedad de Ménière', 'Precaución en úlcera péptica y asma'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Betahistina')
    and lower(coalesce(concentration, '')) = lower('24 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Microser', null, true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Betahistina')
  and lower(coalesce(d.concentration, '')) = lower('24 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Microser')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Betaserc', 'Abbott', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Betahistina')
  and lower(coalesce(d.concentration, '')) = lower('24 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Betaserc')
  );

insert into public.drug_catalog
  (generic_name, therapeutic_class, pharmaceutical_form, concentration, route, usual_quantity, usual_dose, usual_frequency, usual_duration, usual_indications, warnings)
select 'Sildenafil', 'Inhibidor de fosfodiesterasa 5', 'Tableta recubierta', '50 mg', 'Oral', 'Caja de 1-4 tabletas', '50 mg, 30-60 minutos antes de la actividad sexual', 'Máximo 1 vez al día', 'Uso a demanda', 'Disfunción eréctil', 'Contraindicado con nitratos, precaución en cardiopatía isquémica e hipotensión'
where not exists (
  select 1 from public.drug_catalog
  where lower(generic_name) = lower('Sildenafil')
    and lower(coalesce(concentration, '')) = lower('50 mg')
);

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Viagra', 'Pfizer', true, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Sildenafil')
  and lower(coalesce(d.concentration, '')) = lower('50 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Viagra')
  );

insert into public.commercial_brands (drug_catalog_id, brand_name, laboratory, is_preferred, is_active)
select d.id, 'Sildenafil MK', 'Tecnoquímicas', false, true
from public.drug_catalog d
where lower(d.generic_name) = lower('Sildenafil')
  and lower(coalesce(d.concentration, '')) = lower('50 mg')
  and not exists (
    select 1 from public.commercial_brands cb
    where cb.drug_catalog_id = d.id and lower(cb.brand_name) = lower('Sildenafil MK')
  );

-- Total: 137 fármacos, 336 marcas comerciales.
