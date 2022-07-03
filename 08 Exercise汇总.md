# Chapter8 Exercise汇总
![image](https://user-images.githubusercontent.com/105503216/177029181-41ac7e54-c868-4655-85a1-cc0e0155c34f.png)
``` sql
SELECT CONCAT(LOWER(LEFT(primary_poc, 1)), 
			  UPPER(RIGHT(LEFT(primary_poc, POSITION(' 'IN primary_poc)-1),1)),
              LOWER(LEFT(RIGHT(primary_poc, LENGTH(primary_poc)-POSITION(' ' IN primary_poc)),1)),
              UPPER(RIGHT(primary_poc,1)),
              LENGTH(LEFT(primary_poc, POSITION(' 'IN primary_poc)-1)),
              LENGTH(RIGHT(primary_poc, LENGTH(primary_poc)-POSITION(' ' IN primary_poc))),
              UPPER(REPLACE(name,' ',''))) AS password
FROM accounts;

# 对于这种复杂的，且反复要用到某个求出来的变量的情况，可以用subqueries
WITH sub AS
(SELECT LEFT(primary_poc, POSITION(' 'IN primary_poc)-1) AS first_name,
		RIGHT(primary_poc, LENGTH(primary_poc)-POSITION(' ' IN primary_poc)) AS last_name,
        REPLACE(name, ' ','') AS company_name
FROM accounts)
SELECT CONCAT(LOWER(LEFT(first_name, 1)),
              UPPER(RIGHT(first_name, 1)),
              LOWER(LEFT(last_name, 1)),
              UPPER(RIGHT(last_name, 1)),
              LENGTH(first_name),
              LENGTH(last_name),
              UPPER(company_name)) AS password
FROM sub;
```
