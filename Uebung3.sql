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
group by 
	rollup(p_produktkategorie,p_produktgruppe),
	rollup(  extract(month from z_datum),
	extract(year from z_datum));
having not (grouping(extract(month from z_datum)) = 1);

/* 
 * OLAP
*/
CREATE VIEW tagesumsatz AS 
	SELECT 
		p_produktgruppe,
		z_datum,
		SUM(v_anzahl*p_verkaufspreis) AS umsatz 
	FROM 
		verkauf,
		zeit,
		produkt
	WHERE v_zeit_id =z_id
	AND v_produkt_id=p_id
	GROUP BY p_produktgruppe,z_datum;
	
select * from tagesumsatz;

/*
 * MOTIVATION - OVER zu nutzen
 */

SELECT 
	z_datum, 
	Umsatz,
	GesamtUmsatz AS JahresGesamt,
	100*Umsatz/GesamtUmsatz AS Anteil 
FROM 
	TagesUmsatz,
	(SELECT 
		SUM(Umsatz) AS GesamtUmsatz 
	FROM TagesUmsatz
	WHERE p_produktgruppe = 'wein'
	AND EXTRACT(YEAR FROM Z_Datum ) = 2008 ) Gesamt
WHERE 
	p_produktgruppe = 'wein' 
	AND EXTRACT (YEAR FROM Z_Datum ) = 2008;

/*
 * die Anteile der Tagesumsätze an den Monatsumsätzen bezogen auf die Produktgruppe
 */
select 
	p_produktgruppe,
	z_datum,
	umsatz,
	100*umsatz/sum(umsatz) over(partition by extract(month from z_datum), p_produktgruppe) as monat_anteil,
	sum(umsatz) over(partition by extract(month from z_datum), p_produktgruppe) as gesamt_umsatz
from tagesumsatz;

/*
 * der prozentualer Anteil der Tagesumsätze an den jeweiligen Mo- natsumsätzen für das Jahr 2008.
 */

select 
	p_produktgruppe,
	z_datum,
	umsatz,
	100*umsatz/sum(umsatz) over(partition by extract(month from z_datum), p_produktgruppe) as monat_anteil,
	sum(umsatz) over(partition by extract(month from z_datum), p_produktgruppe) as gesamt_umsatz
from tagesumsatz
where 
	extract(year from z_datum) = 2008;
/*
 * Datum, Umsatz und die kumulierte Umsatzzahlen pro Monat.
 */

select 
	z_datum,
	p_produktgruppe,
	umsatz,
	sum(umsatz) over (order by z_datum) as kumulierte_summe,
	sum(umsatz) over (partition by extract(month from z_datum) order by z_datum) as monat_summe
from tagesumsatz;

select * from tagesumsatz;

/*
 * Ranking nach Umsatz
 */
select
	z_datum,
	umsatz,
	rank() over(order by umsatz desc ) as rang
from tageumsatz;

select max(umsatz) from tagesumsatz;

/*
 * Top 3 der Tage mit den höchsten Umsatzzahlen pro Jahr für die Produktgrup- pe ’Wein’
 */
select 
	taba.z_datum,
	taba.top_jahr
from
	(select 
		z_datum,
		umsatz,
		rank() over(
			partition by extract(year from z_datum)
			order by umsatz desc
		) as top_jahr
	from tagesumsatz 
	where p_produktgruppe = 'wein'
	) taba
where taba.top_jahr <= 3
order by taba.top_jahr;




