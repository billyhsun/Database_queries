SET SEARCH_PATH TO parlgov;
DROP TABLE IF EXISTS q3 CASCADE;

DROP VIEW IF EXISTS WinningElections CASCADE;
DROP VIEW IF EXISTS Winners CASCADE;
DROP VIEW IF EXISTS NumElecWins CASCADE;
DROP VIEW IF EXISTS DesiredParties CASCADE;
DROP VIEW IF EXISTS DesPartiesInfo CASCADE;
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
	FROM WinningElections , election_result,election 

	WHERE WinningElections.election_id = election_result.election_id 
	and WinningElections.maxvotes = election_result.votes and
	WinningElections.election_id = election.id;

CREATE VIEW NumElecWins AS
	--returns the number of elections won by the party winners as well as their ids 
	SELECT party_id, count(*) Ws
	FROM Winners
	GROUP BY party_id;

CREATE VIEW DesiredParties AS
	-- returns the party ids and elections wins of the parties who won more than three times the average number of elections won by the partiesin the same country
	SELECT A1.party_id party_id, A1.Ws Wins
	FROM NumElecWins A1
	WHERE A1.Ws > (
		SELECT 3*AVG(coalesce(NumElecWins.Ws,0))
		FROM NumElecWins, party,country
		WHERE NumElecWins.party_id = party.id and party.country_id = country.id
		GROUP BY country.id);

CREATE VIEW DesPartiesInfo AS
	--returns all desired party information such as party name, party family etc.
	SELECT party.name ParName, DesiredParties.party_id party_id, country.name CName, party_family.family Fam, coalesce(Wins,0) Ws
	FROM party, DesiredParties, country, party_family
	WHERE DesiredParties.party_id = party.id and DesiredParties.party_id = party_family.party_id and country.id = party.country_id;


CREATE VIEW MostRecDate AS
	--returns the date of the most recent election won by the winning party and the id of the party
	SELECT party_id, max(edate) mostrecdate
	FROM Winners
	GROUP BY party_id;

CREATE VIEW MostRecentWonElec AS

	SELECT Winners.party_id party_id, extract(year FROM edate)::int yer, eid
	FROM Winners, MostRecDate 
	WHERE Winners.party_id = MostRecDate.party_id and edate = mostrecdate;


CREATE VIEW res AS
	SELECT DES.CName countryName, DES.ParName partyName, DES.Fam partyFamily, DES.Ws wonElections, MR.eid mostRecentlyWonElectionId, MR.yer mostRecentlyWonElectionYear  
	FROM MostRecentWonElec MR, DesPartiesInfo DES 
	WHERE DES.party_id = MR.party_id;

insert into q3 (SELECT * FROM res)
