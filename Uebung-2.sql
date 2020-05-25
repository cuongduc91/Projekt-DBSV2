select * from Ort;
select * from Kunde ;
select * from Produkt;
select * from zeit ;
select * from verkauf;


select
	o_stadt,
	extract(month from z_datum) as monat,
	sum(v_anzahl) as einheiten,
	sum(v_anzahl*p_verkaufspreis) as umsatz
from
	verkauf v ,
	zeit z ,
	produkt p ,
	ort o 
where
	v_zeit_id = z_id and 
	v_produkt_id = p_id and 
	v_ort_id = o_id and 
	extract(year from z_datum) between 2008 and 2011 and 
	o_bundesland in ('sachsen-anhalt', 'thüringen') and 
	p_produktgruppe in ('wein','bier')
group by o_stadt, monat;

/*
	der Gesamtumsatz je Produktgruppe und Jahr.
*/
select distinct(p_produktgruppe) as unique_name from produkt p;

select
	p_produktgruppe,
	extract(year from Z_Datum) as year,
	sum(v_anzahl*p_verkaufspreis) as umsatz
from
	verkauf v ,
	zeit z ,
	produkt p ,
	ort o 
where
	v_zeit_id = z_id and 
	v_produkt_id = p_id and 
	v_ort_id = o_id and 
	extract(year from z_datum) between 2008 and 2011 and 
	p_produktgruppe in (select distinct(p_produktgruppe) as unique_name from produkt p)
group by p_produktgruppe, year;

select
	p_produktgruppe,
	sum(v_anzahl*p_verkaufspreis) as umsatz
from
	verkauf v ,
	zeit z ,
	produkt p ,
	ort o 
where
	v_zeit_id = z_id and 
	v_produkt_id = p_id and 
	v_ort_id = o_id and 
	extract(year from z_datum) between 2008 and 2011 and 
	p_produktgruppe in (select distinct(p_produktgruppe) as unique_name from produkt p)
group by p_produktgruppe;

/*
	der Gesamtumsatz je Produktgruppe und Jahr auf Thüringen.
*/
select
	p_produktgruppe,
	extract(year from Z_Datum) as year,
	o_bundesland ,
	sum(v_anzahl*p_verkaufspreis) as umsatz
from
	verkauf v ,
	zeit z ,
	produkt p ,
	ort o 
where
	v_zeit_id = z_id and 
	v_produkt_id = p_id and 
	v_ort_id = o_id and 
	extract(year from z_datum) between 2008 and 2011 and 
	p_produktgruppe in (select distinct(p_produktgruppe) as unique_name from produkt p) and 
	o_bundesland = 'thüringen'
	group by p_produktgruppe, year, o_bundesland ;
	
/*
	die Umsätze pro Filiale und Produktgruppe
*/

select
	o_filiale,
	p_produktgruppe,
	o_bundesland ,
	sum(v_anzahl*p_verkaufspreis) as umsatz
from
	verkauf v ,
	zeit z ,
	produkt p ,
	ort o 
where
	v_zeit_id = z_id and 
	v_produkt_id = p_id and 
	v_ort_id = o_id and
	p_produktgruppe in (select distinct(p_produktgruppe) as unique_name from produkt p)
group by o_filiale, p_produktgruppe, o_bundesland ;


select
	o_filiale,
	sum(v_anzahl*p_verkaufspreis) as umsatz
from
	verkauf v ,
	zeit z ,
	produkt p ,
	ort o 
where
	v_zeit_id = z_id and 
	v_produkt_id = p_id and 
	v_ort_id = o_id
group by o_filiale;

/*
 * die Umsätze pro Produktgruppe und Jahr mit Hilfe des CUBE
 */
select
	COALESCE(p_produktgruppe, 'Alle Produkte') p_produktgruppe,
	extract(year from Z_Datum) as year,
	sum(v_anzahl*p_verkaufspreis) as umsatz
from
	verkauf v ,
	zeit z ,
	produkt p ,
	ort o 
where
	v_zeit_id = z_id and 
	v_produkt_id = p_id and 
	v_ort_id = o_id and 
	extract(year from z_datum) between 2008 and 2011 and 
	p_produktgruppe in (select distinct(p_produktgruppe) as unique_name from produkt p)
group by cube(p_produktgruppe,year);
/*
 * keine Zeilen vorkommen, die den Umsatz pro Jahr ausgeben.
 */
select
	COALESCE(p_produktgruppe, 'Alle Produkte') p_produktgruppe,
	extract(year from z_datum) as year,
	sum(v_anzahl*p_verkaufspreis) as umsatz
from
	verkauf v ,
	zeit z ,
	produkt p ,
	ort o 
where
	v_zeit_id = z_id and 
	v_produkt_id = p_id and 
	v_ort_id = o_id and 
	extract(year from z_datum) between 2008 and 2011 and 
	p_produktgruppe in (select distinct(p_produktgruppe) as unique_name from produkt p)
group by cube(p_produktgruppe,year)
having not grouping(extract(year from z_datum))=1;

/*
 * die Umsätze pro Kunde und Vertriebskanal mit den CUBE-Operator.
 */
select
	k_name,
	o_filiale,
	--(sum(v_anzahl*p_verkaufspreis) >= 100) as umsatz
	sum(v_anzahl*p_verkaufspreis) as umsatz
from
	verkauf v ,
	zeit z ,
	produkt p ,
	ort o, 
	kunde k
where
	v_zeit_id = z_id and 
	v_produkt_id = p_id and 
	v_ort_id = o_id and
	v_kunden_id  = k_id 
group by cube(k_name, o_filiale)
having sum(v_anzahl*p_verkaufspreis) >= 100;

/*
 * ROLL-UP
 */
select * from Ort;
select * from Kunde ;
select * from Produkt;
select * from zeit ;
select * from verkauf;

/*
 * der Umsatz für die Dimensionselemente Produktkategorie und Produktgruppe
 */
select 
	p_produktgruppe, 
	p_produktkategorie,
	sum(v_anzahl*p_verkaufspreis) as umsatz
from
	verkauf v ,
	zeit z ,
	produkt p ,
	ort o, 
	kunde k
where
	v_zeit_id = z_id and 
	v_produkt_id = p_id and 
	v_ort_id = o_id and
	v_kunden_id  = k_id 
group by rollup(
	p_produktgruppe,
	p_produktkategorie);

/*
 * der Umsatz mit Hilfe von ROLLUP über die Dimensionen Produkt und Zeit
 */

select 
	p_produktgruppe, 
	p_produktkategorie, 
	extract(month from z_datum) as monat,
	extract(year from z_datum) as year,
	sum(v_anzahl*p_verkaufspreis) as umsatz
from
	verkauf v ,
	zeit z ,
	produkt p ,
	ort o, 
	kunde k
where
	v_zeit_id = z_id and 
	v_produkt_id = p_id and 
	v_ort_id = o_id and
	v_kunden_id  = k_id 
group by rollup(
	p_produktgruppe,
	p_produktkategorie,
	extract(month from z_datum),
	extract(year from z_datum));
	
select 
	p_produktgruppe, 
	p_produktkategorie, 
	extract(month from z_datum) as monat,
	extract(year from z_datum) as year,
	sum(v_anzahl*p_verkaufspreis) as umsatz
from
	verkauf v ,
	zeit z ,
	produkt p ,
	ort o, 
	kunde k
where
	v_zeit_id = z_id and 
	v_produkt_id = p_id and 
	v_ort_id = o_id and
	v_kunden_id  = k_id 
group by cube(
	p_produktgruppe,
	p_produktkategorie,
	extract(month from z_datum),
	extract(year from z_datum));