create database cw6;
create extension postgis;

create table obiekty(id int primary key, name varchar(20), geom geometry);
select * from obiekty;

insert into obiekty(id, name, geom) values(1, 'obiekt1', st_geomfromewkt('srid=0; compoundcurve(linestring(0 1, 1 1),
circularstring(1 1, 2 0, 3 1), circularstring(3 1, 4 2, 5 1),linestring(5 1, 6 1))'));

insert into obiekty(id, name, geom) values(2, 'obiekt2', st_geomfromewkt('srid=0; curvepolygon(compoundcurve(linestring(10 6, 14 6), circularstring(14 6, 16 4, 14 2),
circularstring(14 2, 12 0, 10 2), linestring(10 2, 10 6)), circularstring(11 2, 13 2, 11 2))'));

insert into obiekty(id, name, geom) values(3, 'obiekt3', st_geomfromewkt('srid=0; polygon((7 15, 10 17, 12 13, 7 15))'));

insert into obiekty(id, name, geom) values(4, 'obiekt4', st_geomfromewkt('srid=0; multilinestring((20 20, 25 25), (25 25, 27 24),
 (27 24, 25 22), (25 22, 26 21), (26 21, 22 19), (22 19, 20.5 19.5))'));
delete from obiekty where id=4;

insert into obiekty(id, name, geom) values(5, 'obiekt5', st_geomfromewkt('srid=0; multipoint((30 30 59),(38 32 234))'));

insert into obiekty(id, name, geom) values(6, 'obiekt6', st_geomfromewkt('srid=0; geometrycollection(linestring(1 1, 3 2),point(4 2))'));


--zad1 Wyznacz pole powierzchni bufora o wielkości 5 jednostek, który
-- został utworzony wokół najkrótszej linii łączącej obiekt 3 i 4.

select st_area(st_buffer(st_shortestline(obiekt3.geom, obiekt4.geom), 5)) from obiekty as obiekt3, obiekty as obiekt4
where obiekt3.name = 'obiekt3' and obiekt4.name = 'obiekt4';


--zad2 Zamień obiekt4 na poligon. Jaki warunek musi być spełniony,
-- aby można było wykonać to zadanie? Zapewnij te warunki.

select st_isclosed((st_dump(geom)).geom) from obiekty where name = 'obiekt4'; --stdump wyodrębnia komponenty geometrii

update obiekty set geom = st_makepolygon(st_lineMerge(st_collectionhomogenize(st_collect(geom, 'LINESTRING(20.5 19.5, 20 20)'))))
where name = 'obiekt4'; --collect dodaje brakujaca linie, collection jednolita kolekcja multigeometri, linemerge łaczy elementy multilinestringa

select st_geometrytype(obiekty.geom) from obiekty where obiekty.name = 'obiekt4'; --czy poligon


--zad3 W tabeli obiekty, jako obiekt7 zapisz obiekt złożony z obiektu 3 i obiektu 4.
insert into obiekty values (7, 'obiekt7', st_collect(
(select geom from obiekty where name = 'obiekt3'), (select geom from obiekty where name = 'obiekt4')));

select * from obiekty;

--zad4 Wyznacz pole powierzchni wszystkich buforów o wielkości 5 jednostek,
-- które zostały utworzone wokół obiektów nie zawierających łuków.
select sum(st_area(st_buffer(obiekty.geom, 5))) from obiekty
where st_hasarc(obiekty.geom) = false;






