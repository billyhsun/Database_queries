SET search_path TO parlgov;
select * from q1
order by countryId desc, alliedPartyId1 desc, alliedPartyId2 desc; 
