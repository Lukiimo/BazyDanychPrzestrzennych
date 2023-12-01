create database cw8;
create extension postgis;
create extension postgis_raster;

--zad 6. Utwórz nową tabelę o nazwie uk_lake_district, gdzie zaimportujesz mapy rastrowe z
-- punktu 1., które zostaną przycięte do granic parku narodowego Lake District.
select * from parkinarodowe;

select st_srid(geom) from parkinarodowe;

create table uk_lake_district as
select st_clip(rast, geom, true)
from  uk_250k, parkinarodowe
where st_intersects(uk_250k.rast, parkinarodowe.geom) and parkinarodowe.gid  = 1;


--zad 7. Wyeksportuj wyniki do pliku GeoTIFF.
create table exporttmp as
select lo_from_bytea(0, st_asgdalraster(st_union(st_clip), 'GTiff',  ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])) as loid
from uk_lake_district;

select  lo_export(loid, 'D:\Semestr V\Bazy danych Przestrzennych\cw8\export.tiff') from exporttmp;


--zad 10. Policz indeks NDWI (to inny indeks niż NDVI) oraz przytnij wyniki do granic Lake District.
create table green as SELECT ST_Union(ST_SetBandNodataValue(rast, NULL), 'MAX') rast
                      FROM (SELECT rast FROM public.sentinel2_band3_1
                        UNION ALL
                         SELECT rast FROM public.sentinel2_band3_2) foo;

create table nirr as SELECT ST_Union(ST_SetBandNodataValue(rast, NULL), 'MAX') rast
                      FROM (SELECT rast FROM public.sentinel2_band8_1
                        UNION ALL
                         SELECT rast FROM public.sentinel2_band8_2) foo;


WITH r1 AS (
(SELECT ST_Union(ST_Clip(a.rast, ST_Transform(b.geom, 32630), true)) as rast
			FROM public.green AS a, public.parkinarodowe AS b
			WHERE ST_Intersects(a.rast, ST_Transform(b.geom, 32630)) AND b.gid=1))
,
r2 AS (
(SELECT ST_Union(ST_Clip(a.rast, ST_Transform(b.geom, 32630), true)) as rast
	FROM public.nirr AS a, public.parkinarodowe AS b
	WHERE ST_Intersects(a.rast, ST_Transform(b.geom, 32630)) AND b.gid=1))

SELECT ST_MapAlgebra(r1.rast, r2.rast, '([rast1.val]-[rast2.val])/([rast1.val]+[rast2.val])::float', '32BF') AS rast
INTO lake_district_ndwi FROM r1, r2;


--zad 11. Wyeksportuj obliczony i przycięty wskaźnik NDWI do GeoTIFF.
create table exporttmp2 as
select lo_from_bytea(0, st_asgdalraster(st_union(rast), 'GTiff',  ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])) as loid
from lake_district_ndwi;

select  lo_export(loid, 'D:\Semestr V\Bazy danych Przestrzennych\cw8\export2.tiff') from exporttmp2;