create extension postgis;
create database  cw3;

select * from airports;
select * from alaska;

select * from popp;
select * from majrivers;

--zad4
-- Wyznacz liczbę budynków (tabela: popp, atrybut: f_codedesc, reprezentowane, jako punkty) w odległości
-- mniejszej niż 1000 jednostek od głównych rzek. Budynki spełniające to zapisz do osobnej tabeli tableB.

select count(popp.f_codedesc) as budynki into tableB from majrivers, popp
where st_dwithin(popp.geom, majrivers.geom, 1000) and popp.f_codedesc='Building';

select * from tableb;

--zad5a
-- Utwórz tabelę o nazwie airportsNew. Z tabeli airports do zaimportuj nazwy lotnisk, ich geometrię, a także atrybut elev,
-- reprezentujący wysokość n.p.m.

select airports.name, airports.geom, airports.elev into table airportsNew
from airports;
select * from airportsnew;

--a) Znajdź lotnisko, które położone jest najbardziej na zachód i najbardziej na wschód.

select name from airportsNew as wschod order by st_ymin(geom) limit 1;
select name from airportsNew as zachod order by st_ymin(geom) desc limit 1;

--b) Do tabeli airportsNew dodaj nowy obiekt - lotnisko, które położone jest w punkcie środkowym drogi pomiędzy
-- lotniskami znalezionymi w punkcie a. Lotnisko nazwij airportB. Wysokość n.p.m. przyjmij dowolną.

insert into airportsNew values ('airportB', (select st_centroid (
    st_makeline ( (select geom from airportsNew where name = 'NIKOLSKI AS'),
                  (select geom from airportsNew where name = 'NOATAK')))), 300);

select * from airportsnew order by name;

--zad6
-- Wyznacz pole powierzchni obszaru, który oddalony jest mniej niż 1000 jednostek od najkrótszej
-- linii łączącej jezioro o nazwie ‘Iliamna Lake’ i lotnisko o nazwie „AMBLER”

select st_area(st_buffer(st_shortestline(airports.geom, lakes.geom), 1000)) as pole_obszaru
from airports, lakes where airports.name='AMBLER'and lakes.names='Iliamna Lake';


--zad7
-- Napisz zapytanie, które zwróci sumaryczne pole powierzchni poligonów reprezentujących
-- poszczególne typy drzew znajdujących się na obszarze tundry i bagien (swamps).

select * from swamp;
select * from tundra;
select * from trees;

select vegdesc as typ_drzewa, sum(st_area(trees.geom)) as pole from trees, tundra, swamp
where st_contains(tundra.geom, trees.geom) or st_contains(swamp.geom, trees.geom)
group by vegdesc;