select /*+ PARALLEL(v,8) */    
	substr(url,8,instr(substr(url,8,30),'/')), 
	count(*)     
from 
	uplink.txn_tbl v    
where 
	status = 'complete' and    
	url is not null and 
	url not in ('//',' ') and
	time = to_char('13-JUL-2004','DD-MON-YYYY')	  
group by 
	substr(url,8,instr(substr(url,8,30),'/')) 
having 
	count(*) > 1    
order by 
	count(*) desc