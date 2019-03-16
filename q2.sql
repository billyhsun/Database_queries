SET SEARCH_PATH TO parlgov;
DROP TABLE IF EXISTS q2 CASCADE;
DROP VIEW IF EXISTS last_20_years CASCADE;
DROP VIEW IF EXISTS cabinets CASCADE;
DROP VIEW IF EXISTS parties CASCADE;
DROP VIEW IF EXISTS every CASCADE;
DROP VIEW IF EXISTS failures CASCADE;
DROP VIEW IF EXISTS success CASCADE;
DROP VIEW IF EXISTS res CASCADE;


CREATE TABLE q2(
        countryName VARCHAR(50),
        partyName VARCHAR(50),
	partyFamily VARCHAR(50),
	stateMarket FLOAT
);

create view last_20_years as
	select cabinet_id, party_id, party.country_id
	from cabinet, cabinet_party, party
	where cabinet.id = cabinet_party.cabinet_id and date_part('year', cabinet.start_date) >= 1999 and party.country_id = cabinet.country_id;

create view parties as
	select party_id, country_id
	from last_20_years;

create view cabinets as
	select cabinet_id, country_id
	from last_20_years;

create view every as
	select cabinets.cabinet_id, parties.party_id, cabinets.country_id
	from cabinets, parties
	where cabinets.country_id = parties.country_id;

create view failures as 
	(select * from every) except (select * from last_20_years);

create view success as
	(select party_id, country_id from last_20_years) except (select party_id, country_id from failures);

create view res as
	select country.name as countryName, party.name as partyName, party_family.family as partyFamily, party_position.state_market as stateMarket
	from success, party, country, party_family, party_position
	where success.party_id = party.id and success.country_id = country.id and party_family.party_id = success.party_id and success.party_id = party_position.party_id;

INSERT into q2(select * from res);
 
