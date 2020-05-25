select * from Ort;
select * from Kunde ;
select * from Produkt;
select * from zeit ;
select * from verkauf;

select * from zeit where z_id = (select min(z_id) from zeit) or z_id = (select max(z_id) from zeit);

SELECT * FROM produkt WHERE P_PRODUKTGRUPPE='bier';

SELECT extract( YEAR FROM now());
SELECT extract(YEAR FROM z_datum) FROM zeit;

select * from produkt where p_bezeichnung = 'keo';

/* 
 * Umsatz in Schmalkalden berechnen 
 * */
select 
	k_name,
	k_kundengruppe,
	z_datum,
	v_anzahl*p_verkaufspreis as umsatz
from 
	ort,
	kunde,
	produkt,
	zeit,
	verkauf
where 
	o_stadt = 'schmalkalden' and
	v_ort_id = o_id and
	v_produkt_id = p_id and
	v_kunden_id = k_id and
	v_zeit_id = z_id;

select 
	k_name,
	o_stadt ,
	z_datum,
	v_anzahl*p_verkaufspreis as umsatz
from 
	ort,
	kunde,
	produkt,
	zeit,
	verkauf
where 
	v_ort_id = o_id and
	v_produkt_id = p_id and
	v_kunden_id = k_id and
	v_zeit_id = z_id;

/*
 * Umsatz durch Region summiert
 */
select 
	o_stadt,
	sum(v_anzahl*p_verkaufspreis) as sum_umsatz
from 
	ort,
	kunde,
	produkt,
	zeit,
	verkauf
where 
	v_ort_id = o_id and
	v_produkt_id = p_id and
	v_kunden_id = k_id and
	v_zeit_id = z_id
group by o_stadt;	
	
/*
 * Umsatz jedes Kunden der Filiale in Schmalkalden
 */
select 
	k_name,
	k_kundengruppe,
	sum(v_anzahl*p_verkaufspreis) as sum_umsatz
from 
	ort,
	kunde,
	produkt,
	zeit,
	verkauf
where 
	o_stadt = 'schmalkalden' and
	v_ort_id = o_id and
	v_produkt_id = p_id and
	v_kunden_id = k_id and
	v_zeit_id = z_id
group by k_name, k_kundengruppe;

/*
 * Namen des Kunden,der meisten Umsatz gebracht hat
 */
select * from (select 
		k_name,
		k_kundengruppe,
		sum(v_anzahl*p_verkaufspreis) as sum_umsatz
	from 
		ort,
		kunde,
		produkt,
		zeit,
		verkauf
	where 
		o_stadt = 'schmalkalden' and
		v_ort_id = o_id and
		v_produkt_id = p_id and
		v_kunden_id = k_id and
		v_zeit_id = z_id
	group by k_name, k_kundengruppe) a where sum_umsatz =(select max(sum_umsatz) from 
		(select 
			k_name,
			k_kundengruppe,
			sum(v_anzahl*p_verkaufspreis) as sum_umsatz
		from 
			ort,
			kunde,
			produkt,
			zeit,
			verkauf
		where 
			o_stadt = 'schmalkalden' and
			v_ort_id = o_id and
			v_produkt_id = p_id and
			v_kunden_id = k_id and
			v_zeit_id = z_id
		group by k_name, k_kundengruppe) b); 
