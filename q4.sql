SET SEARCH_PATH TO parlgov;

DROP TABLE IF EXISTS q4 CASCADE;
DROP VIEW IF EXISTS elections_and_results CASCADE;
DROP VIEW IF EXISTS average_percentages CASCADE;
DROP VIEW IF EXISTS description CASCADE;
DROP VIEW IF EXISTS res CASCADE;

create table q4(
	year INT,
	countryName VARCHAR(50),
	voteRange VARCHAR(20),
	partyName VARCHAR(100)
);


create view elections_and_results as
	SELECT election.country_id, election_result.party_id, 
	extract(year from election.e_date) as year, 
	(cast(election_result.votes as decimal) * 100 / election.votes_valid) as percentage

	FROM election join election_result on election.id = election_result.election_id
	WHERE extract(year from election.e_date) >= 1996 and 
	extract(year from election.e_date) <= 2016 and
	election_result.votes is not null and
	election.votes_valid is not null;


create view average_percentages as
	SELECT country_id, party_id, year, avg(percentage) as avg_percent
	FROM elections_and_results
	GROUP BY country_id, party_id, year
	ORDER BY avg(percentage) DESC;


create view description as
	SELECT year, country_id,   
	CASE 
		when avg_percent > 0 and avg_percent <= 5 then '(0-5]'
		when avg_percent > 5 and avg_percent <= 10 then '(5-10]'
		when avg_percent > 10 and avg_percent <= 20 then '(10-20]'
		when avg_percent > 20 and avg_percent <= 30 then '(20-30]'
		when avg_percent > 30 and avg_percent <= 40 then '(30-40]'
		when avg_percent > 40 then '(40-100]'
	end as VoteRange, party_id 

	FROM average_percentages
	ORDER BY year, country_id;


create view res as
	SELECT description.year as year, country.name as countryName, 
	description.voterange as voteRange, party.name_short as partyName
	FROM (description join country on description.country_id = country.id)
	join party on description.party_id = party.id;


insert into q4 (SELECT * FROM res)
