SET SEARCH_PATH TO parlgov;

DROP TABLE IF EXISTS q1 cascade;
DROP VIEW IF EXISTS election_info CASCADE;
DROP VIEW IF EXISTS party_alliances CASCADE;
DROP VIEW IF EXISTS country_party_counts CASCADE;
DROP VIEW IF EXISTS country_elections CASCADE;
DROP VIEW IF EXISTS res CASCADE;


CREATE TABLE q1(
	countryId INT,
        alliedPartyId1 INT,
        alliedPartyId2 INT
);

create view election_info as
	select election_result.id, election_result.party_id as party_id, election.country_id as country_id, election_result.election_id as election_id, election_result.alliance_id as alliance_id
	from country, election, election_result
	where country.id = election.country_id and election_result.election_id = election.id;

create view party_alliances as 
	select party_id, country_id, election_id, coalesce(alliance_id, id) as aid
	from election_info;

create view country_party_counts as
	select pa_1.party_id as alliedPartyId1, pa_2.party_id as alliedPartyId2, pa_2.country_id as countryId, count(*) as allycounts
	from party_alliances pa_1, party_alliances pa_2
	where pa_1.aid = pa_2.aid and pa_1.election_id = pa_2.election_id and pa_1.country_id = pa_2.country_id and pa_1.party_id < pa_2.party_id
	group by pa_1.party_id, pa_2.party_id, pa_2.country_id;

create view country_elections as
	select country_id, count(*) as electioncount
	from election
	group by country_id;

create view res as
	select distinct countryId, alliedPartyId1, alliedPartyId2
	from country_party_counts, country_elections
 	where country_party_counts.countryId = country_elections.country_id and country_party_counts.allycounts >= 0.3*country_elections.electioncount;

	
INSERT into q1(select * from res);
