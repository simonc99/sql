select person_id_key,cnt from (select person_id_key,count(*) cnt
from cwise.ddtb_gmdsummperson
group by person_id_key)
where cnt > 1
/
