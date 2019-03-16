SET SEARCH_PATH TO parlgov;

DROP TABLE IF EXISTS q5 CASCADE;
DROP VIEW IF EXISTS part_ratio CASCADE;
DROP VIEW IF EXISTS years_pairs CASCADE;
DROP VIEW IF EXISTS included CASCADE;
DROP VIEW IF EXISTS res CASCADE;

create table q5(
	countryName VARCHAR(50),
	year INT,
	participationRatio REAL
);


create view part_ratio as
	SELECT country_id, year, avg(participation_ratio) as avg_part_ratio
	FROM
		(SELECT country_id, extract(year from e_date) as year,
		id as election_id, votes_cast, electorate as total_votes, 
		(cast(votes_cast as decimal) / electorate) as participation_ratio
		FROM election
		WHERE extract(year from e_date) >= 2001 and extract(year from e_date) <= 2016 and
		votes_cast is not NULL and electorate is not NULL)
	as p_ratio
	
	GROUP BY country_id, year
	ORDER BY country_id;


create view years_pairs as
	SELECT p1.country_id, p1.year as year1, p2.year as year2, p1.avg_part_ratio as ratio1,
	p2.avg_part_ratio as ratio2
	FROM part_ratio p1 join part_ratio p2 on p1.country_id = p2.country_id
	WHERE p1.year < p2.year;


create view included as
	SELECT country_id, year, avg_part_ratio 
	FROM part_ratio
	WHERE country_id NOT IN (
		SELECT distinct country_id
		FROM years_pairs 
		WHERE ratio1 > ratio2);


create view res as
	SELECT country.name as countryName, year, avg_part_ratio as participationRatio
	FROM included join country on included.country_id = country.id;


insert into q5 (SELECT * FROM res)
