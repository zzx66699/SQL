# Chapter7 Other Statements
## 1. Temporary table 
 A temporary table is a database table that is created and exists temporarily on a database server.  
 
### 1.1 WITH clause
```sql
WITH sub AS(
  SELECT COUNT(*) AS total_events,
       channel
  FROM web_events
  GROUP BY channel, LEFT(occurred_at, 10))

SELECT channel, AVG(total_events)
FROM sub
GROUP BY channel;
```

多个WITH之间加上, 且不重复使用WITH

``` sql
WITH table1 AS 
  (SELECT * FROM web_events),
     table2 AS 
  (SELECT * FROM accounts)
     
SELECT *
FROM table1
JOIN table2
ON table1.account_id = table2.id;
```

## 2. UNION
