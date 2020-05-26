select * from Ort;
select * from Kunde ;
select * from Produkt;
select * from zeit ;
select * from verkauf;

/*
 * die Summe der verkauften Artikel für alle Kombinationen 
 * von Kundengruppe,Bundesland und Produktgruppe aus.
 */

select
	k_kundengruppe,
	o_bundesland,
	p_produktgruppe,
	sum(v_anzahl) as Anzahl
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
	v_kunden_id = k_id
group by cube(k_kundengruppe, o_bundesland,p_produktgruppe); 

/*
 * das Bundesland gruppiert wird nicht mit aus.
 */
select
	k_kundengruppe,
	o_bundesland,
	p_produktgruppe,
	sum(v_anzahl) as Anzahl
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
	v_kunden_id = k_id
group by cube(k_kundengruppe, o_bundesland,p_produktgruppe)
having not (not grouping(o_bundesland) = 0 and grouping (o_bundesland) = 1 and grouping (p_produktgruppe) = 1);