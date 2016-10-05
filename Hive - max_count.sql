
select a.id
from 
(select id, count(*) as freq1 
from hive_txns 
group by id) a 
join 
(select max(freq) as maxfreq from (select id, count(*) as freq 
from hive_txns 
group by id) b ) c
on (a.freq1 = c.maxfreq)
;