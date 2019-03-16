SET search_path TO parlgov;

drop table if exists q6 cascade;
DROP TYPE IF EXISTS countryName CASCADE;
DROP VIEW IF EXISTS r0_2 CASCADE;
DROP VIEW IF EXISTS r2_4 CASCADE;
DROP VIEW IF EXISTS r4_6 CASCADE;
DROP VIEW IF EXISTS r6_8 CASCADE;
DROP VIEW IF EXISTS r8_10 CASCADE;
DROP VIEW IF EXISTS r02 CASCADE;
DROP VIEW IF EXISTS r24 CASCADE;
DROP VIEW IF EXISTS r46 CASCADE;
DROP VIEW IF EXISTS r68 CASCADE;
DROP VIEW IF EXISTS r810 CASCADE;
DROP VIEW IF EXISTS res CASCADE;


CREATE TABLE q6(
	countryName VARCHAR(50) references country(name),
	r0_2 INT,
	r2_4 INT,
	r4_6 INT,
	r6_8 INT,
	r8_10 INT
);


CREATE VIEW r02 AS 
	SELECT country.name as countryName, count(party.id) as party_count
        FROM (country 
	left join party on country.id = party.country_id)   
        join party_position on party.id = party_position.party_id
        WHERE left_right >= 0.0 AND left_right < 2.0
	GROUP BY country.name;

CREATE VIEW r24 AS 
	SELECT country.name as countryName, count(party.id) as party_count
        FROM (country 
	left join party on country.id = party.country_id)   
        join party_position on party.id = party_position.party_id
        WHERE left_right >= 2.0 AND left_right < 4.0
	GROUP BY country.name;

CREATE VIEW r46 AS 
	SELECT country.name as countryName, count(party.id) as party_count
        FROM (country 
	left join party on country.id = party.country_id)   
        join party_position on party.id = party_position.party_id
        WHERE left_right >= 4.0 AND left_right < 6.0
	GROUP BY country.name;

CREATE VIEW r68 AS 
	SELECT country.name as countryName, count(party.id) as party_count
        FROM (country 
	left join party on country.id = party.country_id)   
        join party_position on party.id = party_position.party_id
        WHERE left_right >= 6.0 AND left_right < 8.0
	GROUP BY country.name;

CREATE VIEW r810 AS 
	SELECT country.name as countryName, count(party.id) as party_count
        FROM (country 
	left join party on country.id = party.country_id)   
        join party_position on party.id = party_position.party_id
        WHERE left_right >= 8.0 AND left_right < 10.0
	GROUP BY country.name;

CREATE VIEW res AS
	SELECT temp.countryName, coalesce(temp.c02, 0) as r0_2,
	coalesce(temp.c24, 0) as r2_4, coalesce(temp.c46, 0) as r4_6,
	coalesce(temp.c68, 0) as r6_8, coalesce(temp.c810, 0) as r8_10
	from (
	SELECT r02.countryName as countryName, r02.party_count as c02, r24.party_count as c24, r46.party_count as c46, r68.party_count as c68, r810.party_count as c810
	FROM 
	(r02 full join r24
	on r02.countryName = r24.countryName

	full join r46
	on r02.countryName = r46.countryName

	full join r68
	on r02.countryName = r68.countryName

	full join r810
	on r02.countryName = r810.countryName)) as temp;

INSERT INTO q6 (SELECT * FROM res);






