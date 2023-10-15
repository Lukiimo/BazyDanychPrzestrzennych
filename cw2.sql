create database cw2;
create extension postgis;

create table budynki(id integer primary key not null, geometry geometry, name varchar(30));
create table drogi(id integer primary key not null, geometry geometry, name varchar(30));
create table punkty_info(id integer primary key not null, geometry geometry, name varchar(30));

--poligony
insert into budynki(id, geometry, name) values (1, ST_GeomFromText('POLYGON(( 8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4  ))',0), 'BuildingA');
insert into budynki(id, geometry, name) values (2, ST_GeomFromText('POLYGON(( 4 7, 6 7, 6 5, 4 5, 4 7 ))',0), 'BuildingB');
insert into budynki(id, geometry, name) values (3, ST_GeomFromText('POLYGON(( 3 8, 5 8, 5 6, 3 6, 3 8 ))',0), 'BuildingC');
insert into budynki(id, geometry, name) values (4, ST_GeomFromText('POLYGON((9 9, 10 9, 10 8, 9 8, 9 9 ))',0), 'BuildingD');
insert into budynki(id, geometry, name) values (5, ST_GeomFromText('POLYGON((1 2, 2 2, 2 1, 1 1, 1 2))',0), 'BuildingE');

--drogi
insert into drogi(id, geometry, name) values (1, ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)',0), 'RoadX');
insert into drogi(id, geometry, name) values (2, ST_GeomFromText('LINESTRING(7.5 10.5, 7.5 0)',0), 'RoadY');

--punkty
insert into punkty_info(id, geometry, name) values (1, ST_GeomFromText('POINT(1 3.5)',0), 'G');
insert into punkty_info(id, geometry, name) values (2, ST_GeomFromText('POINT(5.5 1.5)',0), 'H');
insert into punkty_info(id, geometry, name) values (3, ST_GeomFromText('POINT(9.5 6)',0), 'I');
insert into punkty_info(id, geometry, name) values (4, ST_GeomFromText('POINT(6.5 6)',0), 'J');
insert into punkty_info(id, geometry, name) values (5, ST_GeomFromText('POINT(6 9.5)',0), 'K');

--zad6A Wyznacz całkowitą długość dróg w analizowanym mieście

select sum(st_length(drogi.geometry)) from drogi;


--zad6B Wypisz geometrię (WKT), pole powierzchni oraz obwód poligonu reprezentującego budynek o nazwie BuildingA.

select st_asewkt(budynki.geometry) as geometria, st_area(budynki.geometry) as pole, st_perimeter(budynki.geometry) as obwod
from budynki where budynki.name='BuildingA';


--zad6C Wypisz nazwy i pola powierzchni wszystkich poligonów w warstwie budynki. Wyniki posortuj alfabetycznie.

select name as nazwa, st_area(budynki.geometry) as pole from budynki order by name;


--zad6D Wypisz nazwy i obwody 2 budynków o największej powierzchni.

select name, st_perimeter(budynki.geometry) from budynki order by st_area(budynki.geometry) desc limit 2;

--zad6E Wyznacz najkrótszą odległość między budynkiem BuildingC a punktem G.

select st_distance(budynki.geometry, punkty_info.geometry) as odleglosc
from budynki, punkty_info where budynki.name='BuildingC' and punkty_info.name='G';

--zad6F Wypisz pole powierzchni tej części budynku BuildingC, która znajduje się w odległości większej niż 0.5 od budynku BuildingB.

select st_area(st_difference((select budynki.geometry
from budynki where budynki.name = 'BuildingC'),
st_buffer((select budynki.geometry
from budynki where budynki.name = 'BuildingB'),0.5 ))) as Pole;


--zad6G Wybierz te budynki, których centroid (ST_Centroid) znajduje się powyżej drogi o nazwie RoadX.

select budynki.name from budynki, drogi where st_y(st_centroid(budynki.geometry)) > st_y(st_centroid(drogi.geometry)) and drogi.name = 'RoadX';
-- st_centroid(drogi.geometry bo droga musi byc punktem

--zad6H Oblicz pole powierzchni tych części budynku BuildingC i poligonu o współrzędnych (4 7, 6 7, 6 8, 4 8, 4 7),
-- które nie są wspólne dla tych dwóch obiektów.

select st_area(st_symdifference(st_geomfromtext( 'polygon((4 7, 6 7, 6 8, 4 8, 4 7))' ), geometry)) as Suma_pol_niewspolnych
from budynki where name = 'BuildingC';
--symdiffrence poligony niewspolne