/* 
1. Geben Sie für einen Auftrag den Namen des Kunden und alle Arbeitsschritte aus
*/

select
	a.a_id, a.a_kunde_name, d.d_arbeitsschritte
from
  dwh.dwh_fakt d,
  dwh.p_auftrag a
where
  	a.a_id = d.d_auftrag_id and 
  	a.a_id = 3043;

select * from dwh.dwh_fakt df where d_auftrag_id = 3043;
/*
2.Berechnen Sie die angefallenen Arbeitskosten pro Auftrag (ohne die Materialkosten).
Geben Sie den Namen des Kunden, die Auftragsnummer und die berechneten
Arbeitskosten aus.
*/
select 
	a.a_id, a.a_kunde_name, (d.d_arbeitsschritte*d.d_arbeitskosten) as arbeitskosten
from 
	dwh.dwh_fakt d,
	dwh.p_auftrag a
where
	a.a_id = d.d_auftrag_id;
	

/*
3.Geben Sie Aufträge aus, deren Angebotspreis kleiner ist als der Peris für die geleistete
Arbeit und die verwendeten Materialien. (D.h. Aufträge, die ein Verlust waren.)
*/

select 
	a.a_id, a.a_kunde_name, (d.d_arbeitsschritte*d.d_arbeitskosten + m.m_kosten) as echterPreis,a.a_angebotspreis
from 
	dwh.dwh_fakt d,
	dwh.p_auftrag a,
	dwh.p_material m
where
	a.a_id = d.d_auftrag_id and 
	m.m_id = d.d_material_id and 
	(d.d_arbeitsschritte*d.d_arbeitskosten + m.m_kosten) > a.a_angebotspreis;

/*
4.Geben Sie Entlang der Dimension Auftrag mit den Dimensionselementen Auftragskategorie und Auftragsart die Kosten für die Arbeitsleistung aus. 
D.h. Kosten für Wartung, Kontrolle, Reparatur, Bau jeweils einzeln, dann die Summen je
Auftragskategorie (also Summe für Service und Produktion) und dann die
Gesamtsumme über alle Aufträge.
*/
select 
	a.a_id, 
	a.a_kunde_name,
	a.a_auftragsart, 
	a.a_auftragskategorie, 
	(d.d_arbeitsschritte*d.d_arbeitskosten) as arbeitskosten ,
	(d.d_arbeitsschritte*d.d_arbeitskosten + m.m_kosten*d.d_material_anzahl ) as totalKosten
from 
	dwh.dwh_fakt d,
	dwh.p_auftrag a,
	dwh.p_material m
where
	a.a_id = d.d_auftrag_id and 
	m.m_id = d.d_material_id;


/*
5.Für die folgenden Anfragen können Sie eine Sicht definieren, um einfachere Select-
Anweisungen erstellen zu können.
*/
drop view dwh.p_tagesumsatz cascade;
create view dwh.p_tagesumsatz as 
	select 
		a.a_id,
		a.a_auftragsart, 
		a.a_auftragskategorie,
		z.z_datum,
		(d.d_arbeitsschritte*d.d_arbeitskosten + m.m_kosten*d.d_material_anzahl ) as totalKosten,
		sum(a.a_angebotspreis) as umsatz
	from 
		dwh.p_auftrag a,
		dwh.zeit z,
		dwh.dwh_fakt d,
		dwh.p_material m
	where 
		a.a_id = d.d_auftrag_id and 
		z.z_id = d.d_zeit_id and 
		m.m_id = d.d_material_id
	group by
		a.a_id,
		a.a_auftragsart, 
		a.a_auftragskategorie,
		totalKosten,
		z.z_datum;

select * from dwh.p_tagesumsatz order by a_id;

drop view dwh.p_umsatz_gewinn cascade;
create view dwh.p_umsatz_gewinn as 
	select 
		a_id,
		a_auftragsart,
		a_auftragskategorie,
		z_datum,
		totalkosten,
		(umsatz - totalkosten) as gewinn,
		umsatz
	from dwh.p_tagesumsatz;
select * from dwh.p_umsatz_gewinn order by a_id;

/*
6.Berechnen Sie für jeden Auftrag seinen Prozentualen Anteil am Gesamtumsatz im Jahr.
Der Gesamtumsatz soll sich aus den Kosten der Einzelnen Arbeitsschritte und den
Kosten der verbauten Materialen berechnen.
*/

--Prozentualen Anteil am Gesamtumsatz im Jahr mit der Dimesion Auftragskategorie
select 
	a_id,
	a_auftragskategorie,
	z_datum,
	umsatz,
	100*umsatz/sum(umsatz) over(partition by extract(year from z_datum), a_auftragskategorie) as jahr_anteil,
	sum(umsatz) over(partition by extract(year from z_datum), a_auftragskategorie) as gesamt_umsatz
from dwh.p_tagesumsatz order by a_id;
--Prozentualen Anteil am Gesamtumsatz im Jahr
select 
	a_id,
	a_auftragskategorie,
	z_datum,
	umsatz,
	100*umsatz/sum(umsatz) over(partition by extract(year from z_datum)) as jahr_anteil,
	sum(umsatz) over(partition by extract(year from z_datum)) as gesamt_umsatz
from dwh.p_tagesumsatz
order by a_id;
--Prozentualen Anteil am Gesamtumsatz im Jahr bei Gewinn
select 
	a_id,
	a_auftragskategorie,
	z_datum,
	umsatz,
	100*gewinn/sum(umsatz) over(partition by extract(year from z_datum)) as jahr_anteil,
	sum(umsatz) over(partition by extract(year from z_datum)) as gesamt_umsatz
from dwh.p_umsatz_gewinn
order by a_id;
/*
7.Geben Sie die Namen der 3 Kunden aus, die im laufenden Jahr den meisten Umsatz
erzeugt haben.
*/

select 
	a.a_id,
	a.a_kunde_name,
	b.umsatz,
	b.jahr,
	b.top_jahr
from 
	dwh.p_auftrag a,
	(select
		a_id,
		extract(year from z_datum) as jahr,
		umsatz,
		rank() over(partition by extract(year from z_datum) order by umsatz desc) as top_jahr
	from dwh.p_umsatz_gewinn) b
where 
	a.a_id = b.a_id and 
	b.top_jahr <= 3;

/*
8.Berechnen Sie den gleitenden Durchschnitt der Arbeitskosten für 5 Tage für die
Auftragsart „Wartung“.
*/

drop view dwh.p_wartung_auftrag;
create view dwh.p_wartung_auftrag as 
	select 
		cast(a.a_auftragseingang_zeit as DATE ) as eingang_date,
		cast(a.a_fertigsstellung_zeit as DATE ) as ausgang_date,
		(d.d_arbeitsschritte*d.d_arbeitskosten) as arbeitskosten
	from 
		dwh.dwh_fakt d,
		dwh.p_auftrag a
	where
		a.a_id = d.d_auftrag_id and
		a.a_auftragsart = 'Wartung';
select * from dwh.p_wartung_auftrag;

select 
	(5* taba.sumArbeitskosten / taba.sumDauertTage) as Arbeitskosten_5_Tage
from 
	(select 
		sum(arbeitskosten) as sumArbeitskosten,
		sum(ausgang_date - eingang_date) as sumDauertTage
	from dwh.p_wartung_auftrag) taba;
/*
Könnte man materialisierte Sichten nutzen, um die Effizienz der Anfragen zu verbessern?
*/