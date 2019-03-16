SET search_path TO parlgov;
select * from q3
order by countryName, wonElections, partyName DESC;
 
