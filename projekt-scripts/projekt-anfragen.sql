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
4.Geben Sie Entlang der Dimension Auftrag mit den Dimensionselementen
Auftragskategorie und Auftragsart die Kosten für die Arbeitsleistung aus. D.h. Kosten für Wartung, Kontrolle, Reparatur, Bau jeweils einzeln, dann die Summen je
Auftragskategorie (also Summe für Service und Produktion) und dann die
Gesamtsumme über alle Aufträge.
*/


/*
5.Für die folgenden Anfragen können Sie eine Sicht definieren, um einfachere Select-
Anweisungen erstellen zu können.
*/


/*
6.Berechnen Sie für jeden Auftrag seinen Prozentualen Anteil am Gesamtumsatz im Jahr.
Der Gesamtumsatz soll sich aus den Kosten der Einzelnen Arbeitsschritte und den
Kosten der verbauten Materialen berechnen.
*/

/*
7.Geben Sie die Namen der 3 Kunden aus, die im laufenden Jahr den meisten Umsatz
erzeugt haben.
*/

/*
8.Berechnen Sie den gleitenden Durchschnitt der Arbeitskosten für 5 Tage für die
Auftragsart „Wartung“.
*/


/*
Könnte man materialisierte Sichten nutzen, um die Effizienz der Anfragen zu verbessern?
*/