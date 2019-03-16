SET SEARCH_PATH TO parlgov;
DROP TABLE IF EXISTS q3 CASCADE;

DROP VIEW IF EXISTS WinningElections CASCADE;
DROP VIEW IF EXISTS Winners CASCADE;
DROP VIEW IF EXISTS NumElecWins CASCADE;
DROP VIEW IF EXISTS PartyNeverWon CASCADE;
DROP VIEW IF EXISTS PartyCounts CASCADE;
DROP VIEW IF EXISTS PartyCountsCountry CASCADE;
DROP VIEW IF EXISTS CountryAvg CASCADE;
DROP VIEW IF EXISTS DesiredParties CASCADE;
DROP VIEW IF EXISTS DesPartiesInfo CASCADE;
DROP VIEW IF EXISTS DesPartiesInfoFamily CASCADE;
DROP VIEW IF EXISTS MostRecDate CASCADE;
DROP VIEW IF EXISTS MostRecentWonElec CASCADE;
DROP VIEW IF EXISTS res CASCADE;


CREATE TABLE q3(
	countryName VARCHAR(100),
	partyName VARCHAR(100),
	partyFamily VARCHAR(100),
	wonElections INT,
	mostRecentlyWonElectionId INT,
	mostRecentlyWonElectionYear INT
);

CREATE VIEW WinningElections AS
	--returns the number of votes scored by the party who won the election with election id
	SELECT max(votes) maxvotes, election_id
	FROM election_result
	GROUP BY election_id;


CREATE VIEW Winners AS
	--returns the party id of the party who won the election with election_id on date election e_date
	SELECT WinningElections.election_id eid, party_id, election.e_date edate
	FROM WinningElections, election_result,election 

	WHERE WinningElections.election_id = election_result.election_id 
	and WinningElections.maxvotes = election_result.votes and
	WinningElections.election_id = election.id;


CREATE VIEW NumElecWins AS
	SELECT party_id, count(*) Ws
	FROM Winners
	GROUP BY party_id;


CREATE VIEW PartyNeverWon AS
	SELECT id as party_id, 0 as ws
	FROM party
	WHERE id not in (SELECT party_id FROM NumElecWins);


CREATE VIEW PartyCounts AS
	(SELECT * FROM PartyNeverWon) UNION (SELECT * FROM NumElecWins);


CREATE VIEW PartyCountsCountry AS 
	SELECT party_id, party.country_id, PartyCounts.ws
	FROM PartyCounts, party
	WHERE PartyCounts.party_id = party.id;


CREATE VIEW CountryAvg AS
	SELECT country_id, avg(ws) as ws
	FROM PartyCountsCountry
	GROUP BY country_id;


CREATE VIEW DesiredParties AS
	SELECT PartyCountsCountry.party_id, PartyCountsCountry.country_id, PartyCountsCountry.ws
	FROM PartyCountsCountry, CountryAvg
	WHERE PartyCountsCountry.country_id = CountryAvg.country_id and PartyCountsCountry.ws > 3*CountryAvg.ws;


CREATE VIEW DesPartiesInfo AS
	--returns all desired party information such as party name, party family etc.
	SELECT party.name ParName, DesiredParties.party_id party_id, country.name as country, DesiredParties.Ws
	FROM party, DesiredParties, country
	WHERE DesiredParties.party_id = party.id and party.country_id = country.id;


CREATE VIEW DesPartiesInfoFamily AS
	select DesPartiesInfo.ParName, DesPartiesInfo.party_id, DesPartiesInfo.country, party_family.family as Fam, DesPartiesInfo.Ws
	from DesPartiesInfo left join party_family on DesPartiesInfo.party_id = party_family.party_id;


CREATE VIEW MostRecDate AS
	--returns the date of the most recent election won by the winning party and the id of the party
	SELECT party_id, max(edate) mostrecdate
	FROM Winners
	GROUP BY party_id;


CREATE VIEW MostRecentWonElec AS
	SELECT Winners.party_id party_id, extract(year FROM Winners.edate)::int yer, Winners.eid
	FROM Winners, MostRecDate 
	WHERE Winners.party_id = MostRecDate.party_id and Winners.edate = MostRecDate.mostrecdate;


CREATE VIEW res AS
	SELECT DP.country countryName, DP.ParName partyName, DP.Fam partyFamily, DP.Ws wonElections, MR.eid mostRecentlyWonElectionId, MR.yer mostRecentlyWonElectionYear  
	FROM MostRecentWonElec MR, DesPartiesInfoFamily DP
	WHERE MR.party_id = DP.party_id;

insert into q3 (SELECT * FROM res)
