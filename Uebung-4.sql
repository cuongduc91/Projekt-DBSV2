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

/*
 * die Summe der verkauften Artikel entlang 
 * der Dimension „Ort“ für Stadt, Bundesland und Land aus.
 */

select o_bundesland,o_stadt, p_produktgruppe, p_produktkategorie, sum (v_anzahl)
from  verkauf , ort  , produkt
where o_id =  v_ort_id  and v_produkt_id = p_id
group by rollup(o_bundesland,o_stadt,p_produktkategorie,p_produktgruppe );



select o_stadt,o_bundesland,o_land, sum (v_anzahl)
from  verkauf , ort  
where o_id =  v_ort_id 
group by rollup(o_land,o_bundesland,o_stadt)
having sum (v_anzahl) >50;



select o_stadt,o_bundesland,o_land, sum (v_anzahl)
from  verkauf , ort  
where o_id =  v_ort_id 
group by grouping sets((o_stadt),(o_land,o_bundesland));





