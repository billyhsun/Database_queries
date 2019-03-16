SET search_path TO parlgov;
select * from q4
order by year desc, countryName desc, voteRange desc, partyName desc;
