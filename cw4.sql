create database cw4;
create extension postgis;
select * from t2019_kar_buildings;

--zad1
-- Znajdź budynki, które zostały wybudowane lub wyremontowane na przestrzeni roku (zmiana
-- pomiędzy 2018 a 2019).
select * from nowebudynki;

create table nowebudynki as
select bud2019.gid, bud2019.polygon_id, bud2019.name, bud2019.type, bud2019.height, bud2019.geom
from t2019_kar_buildings as bud2019
left join t2018_kar_buildings as bud2018 on bud2019.polygon_id = bud2018.polygon_id
where bud2018.gid is null
   or bud2018.type <> bud2019.type --nie rowne
   or bud2018.height <> bud2019.height
   or st_equals(bud2018.geom, bud2019.geom) = false;


--zad2
--Znajdź ile nowych POI pojawiło się w promieniu 500 m od wyremontowanych lub
--wybudowanych budynków, które znalezione zostały w zadaniu 1. Policz je wg ich kategorii.
select * from T2019_KAR_POI_TABLE;

create table POI as select POI2019.type, count(*) as liczba
from t2019_kar_poi_table as POI2019
where  exists (select 1 from nowebudynki
    where st_dwithin(nowebudynki.geom, POI2019.geom, 500))
group by POI2019.type;

select * from POI;


--zad3
--Utwórz nową tabelę o nazwie ‘streets_reprojected’, która zawierać będzie dane z tabeli
--T2019_KAR_STREETS przetransformowane do układu współrzędnych DHDN.Berlin/Cassini.
select * from T2019_KAR_STREETS;

create table streets_reprojected as
select gid, link_id, st_name, ref_in_id, nref_in_id, func_class, speed_Cat,
       fr_speed_l, to_speed_l, dir_travel, st_setsrid(geom, 3068) as geom
from T2019_KAR_STREETS;

select * from streets_reprojected;

select st_transform(geom, 3068) from T2019_KAR_STREETS;
select geom from t2019_kar_streets;
select ST_SRID(geom) from streets_reprojected;
drop table streets_reprojected;


--zad4
-- Stwórz tabelę o nazwie ‘input_points’ i dodaj do niej dwa rekordy o geometrii punktowej. Przyjmij układ współrzędnych GPS
-- Użyj następujących współrzędnych:
-- X Y
-- 8.36093 49.03174
-- 8.39876 49.00644

create table input_points (	p_id int primary key, geom geometry(POINT, 4326) );
insert into input_points (p_id, geom) values
	(1, st_geomfromtext('POINT(8.36093 49.03174)', 4326)),
	(2, st_geomfromtext('POINT(8.39876 49.00644)', 4326));


select * from input_points;


--zad5
--Zaktualizuj dane w tabeli ‘input_points’ tak, aby punkty te były w układzie współrzędnych
--DHDN.Berlin/Cassini. Wyświetl współrzędne za pomocą funkcji ST_AsText().

alter table input_points alter column geom type geometry(Point, 3068) using st_setsrid(geom, 3068);

update input_points set geom = st_transform(geom, 3068);

select p_id, st_astext(geom) as geom_text from input_points;


--zad6
--Znajdź wszystkie skrzyżowania, które znajdują się w odległości 200 m od linii zbudowanej
--z punktów w tabeli ‘input_points’. Wykorzystaj tabelę T2019_STREET_NODE. Dokonaj reprojekcji geometrii,
-- aby była zgodna z resztą tabel. Znajdź skrzyżowania w odległości 200 m od linii zbudowanej z punktów

create table skrzyzowania as select t2019_kar_street_node.*
from t2019_kar_street_node
join ( select st_makeline(geom order by p_id) as linia from input_points) as linia_geom
on st_dwithin(st_setsrid(t2019_kar_street_node.geom, 3068), linia_geom.linia, 200);

select * from skrzyzowania;
select ST_SRID(geom) from skrzyzowania;


--zad7
-- Policz jak wiele sklepów sportowych (‘Sporting Goods Store’ - tabela POIs)
-- znajduje się w odległości 300 m od parków (LAND_USE_A).  distinct = statement is used to return only distinct (different) values.

select count(distinct (POI.geom)) from T2019_KAR_POI_TABLE as POI, T2019_KAR_LAND_USE_A as park
where POI.type = 'Sporting Goods Store'
and st_dwithin(park.geom, poi.geom, 300)
and park.type = 'Park (City/County)';

--zad8
-- Znajdź punkty przecięcia torów kolejowych (RAILWAYS) z ciekami (WATER_LINES).
-- Zapisz znalezioną geometric do osobnej tabeli o nazwie ‘T2019_KAR_BRIDGES’.

create table T2019_KAR_BRIDGES as (
	select distinct (st_intersection( railways.geom, water_lines.geom))
	from t2019_kar_water_lines as water_lines, t2019_kar_railways as railways);


select * from T2019_KAR_BRIDGES;