select /*+ PARALLEL(v,8) */    
	substr(url,8,instr(substr(url,8,45),'/')), 
	count(*)     
from 
	uplink.txn_tbl v    
where 
	status = 'complete' and    
	url is not null and 
	url not in ('//',' ') and
	trunc(time) = to_char('24-JUL-2004','DD-MON-YYYY')	  
group by 
	substr(url,8,instr(substr(url,8,45),'/')) 
order by 
	count(*) desc