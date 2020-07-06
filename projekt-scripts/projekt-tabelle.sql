drop schema if exists public;
drop schema if exists pg_catalog;
drop schema if exists information_schema;

create schema dwh;
/*
drop table dwh.zeit;
drop table dwh.p_material;
drop table dwh.p_produkt;
drop table dwh.p_auftrag;
drop table dwh.dwh-fakt;
*/
create table dwh.zeit (
	z_id int primary key,
	z_datum date not null
);
-- Done
create table dwh.p_material(
	m_id int primary key,
	m_bezeichnung varchar(30) not null,
	m_kosten numeric (8,2) not null,
	m_lieferant varchar(30) not null,
	m_lieferant_filiale varchar(30) not null,
	m_lieferant_stadt varchar(30),
	m_lieferant_bundesland varchar(30)
);
-- Done
create table dwh.p_produkt (
	p_id int primary key,
	p_name varchar(30) not null,
	p_produktgruppe varchar(30),
	p_produktkategorie varchar(30)
);

create table dwh.p_auftrag (
	a_id int primary key,
	a_auftragseingang_zeit date not null,
	a_fertigsstellung_zeit date not null,
	a_angebotspreis numeric (6,2),
	a_kunde_name varchar(30) not null,
	a_kunde_id numeric,
	a_auftragsart varchar(30),
	a_auftragskategorie varchar(30)
);

create table dwh.dwh_fakt (
	d_auftrag_id int references dwh.p_auftrag(a_id),
	d_zeit_id int references dwh.zeit(z_id),
	d_material_anzahl integer,
	d_arbeitsschritte integer,
	d_arbeitskosten numeric (6,2),
	d_material_id int references dwh.p_material(m_id),
	d_produkt_id int references dwh.p_produkt(p_id),
	primary key (d_auftrag_id,d_zeit_id,d_material_id,d_produkt_id)
);



