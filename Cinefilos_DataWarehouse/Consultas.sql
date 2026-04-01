--1. Ingresos por País y Películas por Sección

--Requerimiento: "¿Qué países generan los mayores ingresos por venta de boletos y cuántas películas presentaron en cada sección?"
SELECT
    geo.pais_sede_desc,
    pel.nombre_seccion,
    SUM(f.ingresos_totales) AS ingresos_generados,
    COUNT(DISTINCT pel.llave_pelicula) AS total_peliculas_unicas
FROM
    fact_ventas AS f
JOIN
    dim_geografia AS geo ON f.llave_geografia = geo.llave_geografia
JOIN
    dim_pelicula AS pel ON f.llave_pelicula = pel.llave_pelicula
GROUP BY
    geo.pais_sede_desc,
    pel.nombre_seccion
ORDER BY
    ingresos_generados DESC;

--2. Picos de Venta por Evento y Lugar

--Requerimiento: "¿Qué eventos registraron las mayores ventas por lugar y en qué fechas ocurrieron esos picos de venta?"
SELECT
    evt.nombre_evento,
    geo.lugar_cine_desc,
    t.dia_descripcion,
    t.mes_descripcion,
    SUM(f.ingresos_totales) AS ventas_en_pico
FROM
    fact_ventas AS f
JOIN
    dim_evento AS evt ON f.llave_evento = evt.llave_evento
JOIN
    dim_geografia AS geo ON f.llave_geografia = geo.llave_geografia
JOIN
    dim_tiempo AS t ON f.llave_tiempo = t.llave_tiempo
GROUP BY
    evt.nombre_evento,
    geo.lugar_cine_desc,
    t.dia_descripcion,
    t.mes_descripcion
ORDER BY
    ventas_en_pico DESC
LIMIT 10; 

--3. Comparativa de Ventas (Premier Universal vs. Latinoamericana)

--Requerimiento: "¿Cómo se comparan las ventas entre las películas tipo premier (universales) y las premier latinoamericanas a lo largo del festival?"
SELECT
    t.dia_descripcion,
    evt.nombre_evento,
    SUM(f.ingresos_totales) AS ventas_comparativas
FROM
    fact_ventas AS f
JOIN
    dim_evento AS evt ON f.llave_evento = evt.llave_evento
JOIN
    dim_tiempo AS t ON f.llave_tiempo = t.llave_tiempo
WHERE
    evt.nombre_evento IN ('Premier Universal', 'Premier Latinoamericana')
GROUP BY
    t.dia_descripcion,
    evt.nombre_evento
ORDER BY
    t.dia_descripcion,
    ventas_comparativas DESC;

--4. Ganancias por Lugar y Evolución de Ventas
--Este requerimiento tiene dos partes.

--Requerimiento (Parte A): "¿Qué lugares (salas/teatros) acumulan las mayores ganancias...?"
-- Parte A: Ranking de ganancias por sala
SELECT
    geo.lugar_cine_desc,
    geo.sala_id,
    SUM(f.ganancias_totales) AS total_ganancias
FROM
    fact_ventas AS f
JOIN
    dim_geografia AS geo ON f.llave_geografia = geo.llave_geografia
GROUP BY
    geo.lugar_cine_desc,
    geo.sala_id
ORDER BY
    total_ganancias DESC;
-- Requerimiento (Parte B): "...y cómo han evolucionado sus ventas por periodo (dia/mes/edición)?
-- Parte B: Evolución de ventas por lugar y tiempo
SELECT
    geo.lugar_cine_desc,
    t.edicion_festival_descripcion,
    t.mes_descripcion,
    t.dia_descripcion,
    SUM(f.ingresos_totales) AS ventas_evolucion
FROM
    fact_ventas AS f
JOIN
    dim_tiempo AS t ON f.llave_tiempo = t.llave_tiempo
JOIN
    dim_geografia AS geo ON f.llave_geografia = geo.llave_geografia
GROUP BY
    -- El ROLLUP crea los subtotales automáticamente
    ROLLUP (geo.lugar_cine_desc, t.edicion_festival_descripcion, t.mes_descripcion, t.dia_descripcion)
ORDER BY
    geo.lugar_cine_desc,
    t.edicion_festival_descripcion,
    t.mes_descripcion,
    t.dia_descripcion;

--5. Películas Más Vendidas por Contexto

--Requerimiento: "¿Qué películas son las más vendidas y en qué países, secciones y lugares concentran sus mejores resultados?"
SELECT
    pel.titulo_pelicula,
    geo.pais_sede_desc,
    pel.nombre_seccion,
    geo.lugar_cine_desc,
    SUM(f.boletos_vendidos) AS total_boletos
FROM
    fact_ventas AS f
JOIN
    dim_pelicula AS pel ON f.llave_pelicula = pel.llave_pelicula
JOIN
    dim_geografia AS geo ON f.llave_geografia = geo.llave_geografia
GROUP BY
    pel.titulo_pelicula,
    geo.pais_sede_desc,
    pel.nombre_seccion,
    geo.lugar_cine_desc
ORDER BY
    total_boletos DESC
LIMIT 10; 

-- 6. Rentabilidad por Sección

--Requerimiento: "¿Cuáles son las tendencias de ventas por sección (por ejemplo: documental, ficción, animación, premier) y qué secciones muestran mejor rentabilidad?"
SELECT
    pel.nombre_seccion,
    SUM(f.ingresos_totales) AS ventas_totales,
    SUM(f.ganancias_totales) AS rentabilidad_total,
    -- Calculamos un margen de rentabilidad
    (SUM(f.ganancias_totales) / SUM(f.ingresos_totales)) * 100 AS margen_porcentual
FROM
    fact_ventas AS f
JOIN
    dim_pelicula AS pel ON f.llave_pelicula = pel.llave_pelicula
GROUP BY
    pel.nombre_seccion
ORDER BY
    rentabilidad_total DESC;