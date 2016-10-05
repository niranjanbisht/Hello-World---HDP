
CREATE EXTERNAL TABLE stocks( stock_exchange STRING, stock_symbol STRING, quote_date STRING, stock_price_open STRING,
     stock_price_high STRING , stock_price_low STRING, stock_price_close STRING, stock_volume STRING, stock_price_adj_close STRING)
 ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
 STORED AS TEXTFILE
 LOCATION '/dw/stocks';

 load data local inpath '/home/cloudera/test_dir/NYSE_stocks.tsv' into table stocks;
 

CREATE TABLE stocks_ctas
   ROW FORMAT SERDE "org.apache.hadoop.hive.serde2.columnar.ColumnarSerDe"
   STORED AS RCFile
   AS
SELECT *
FROM stocks
SORT BY stock_symbol, quote_date;




CREATE TABLE stocks_orc( stock_exchange STRING, stock_symbol STRING, quote_date STRING, stock_price_open STRING,
     stock_price_high STRING , stock_price_low STRING, stock_price_close STRING, stock_volume STRING, stock_price_adj_close STRING)
STORED AS orc; 


INSERT INTO TABLE stocks_orc SELECT * FROM stocks;



CREATE TABLE stocks_zip( stock_exchange STRING, stock_symbol STRING, quote_date STRING, stock_price_open STRING,
     stock_price_high STRING , stock_price_low STRING, stock_price_close STRING, stock_volume STRING, stock_price_adj_close STRING);
 
 
LOAD DATA LOCAL INPATH '/home/cloudera/test_dir/NYSE_stocks.tsv.gz' into table stocks_zip;


set hive.execution.engine = tez;

set hive.vectorized.execution.enabled = true;

set hive.optimize.sampling.orderby = true; 


hive.optimize.sampling.orderby.number
hive.optimize.sampling.orderby.percent

drop table stocks_copy;
create table stocks_copy
(
stock_exchange      string ,                                 
stock_symbol        string  ,                                
stock_price_open    string   ,                               
stock_price_high    string    ,                              
stock_price_low     string     ,                             
stock_price_close   string      ,                            
stock_volume        string       ,                           
stock_price_adj_close string  
) partitioned by (quote_date          string);



insert into table stocks_copy
partition(quote_date)
select 
stock_exchange      ,
stock_symbol        ,
stock_price_open    ,
stock_price_high    ,
stock_price_low     ,
stock_price_close   ,
stock_volume        ,
stock_price_adj_close,
substr(quote_date,1,7) from stocks;

----- Transactions

set hive.txn.manager=org.apache.hadoop.hive.ql.lockmgr.DbTxnManager;
set hive.support.concurrency=true;
set hive.enforce.bucketing=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.compactor.initiator.on=true;
set hive.compactor.worker.threads=2;


create table hive_txns (
  id                int,
  name              string
)
CLUSTERED BY (id) INTO 4 BUCKETS STORED AS ORC
TBLPROPERTIES ("transactional"="true");
