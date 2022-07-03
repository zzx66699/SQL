# Chapter8 Exercise汇总
## 1
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

## 2
Which accounts use facebook as a channel and contact more than 6 times?
``` sql
WITH sub AS
(SELECT a.name, COUNT(*) AS times
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
WHERE channel = 'facebook'
GROUP BY a.id)
SELECT name
FROM sub
WHERE times > 6;

# 更简单的方法
SELECT a.name
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
WHERE channel = 'facebook'
GROUP BY a.id
HAVING COUNT(*) > 6;         # HAVING可以直接筛选分组之后的 因为这里确实可以COUNT()
```

## 3
Provide the name of the sales_rep in each region with the largest total amount of total_amt_usd sales.
``` sql
USE crm_review;
WITH sub AS
(SELECT r.name AS region_name, s.name AS sales_rep, SUM(o.total_amt_usd) AS total_amount
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a 
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
GROUP BY region_name, sales_rep
ORDER BY region_name, total_amount DESC)
SELECT region_name, sales_rep, total_amount   # 这里的sales_rep和max(total_amount)能对应上是因为取的都是每一组的第一行 如果取第二行第三行就不行了
FROM sub
GROUP BY region_name
ORDER BY total_amount DESC;
```
更好的写法：使用ROW_NUMBER()
``` sql
WITH sub2 AS
(WITH sub AS
(SELECT r.name AS region_name, s.name AS sales_rep, SUM(o.total_amt_usd) AS total_amount
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a 
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
GROUP BY region_name, sales_rep
ORDER BY region_name, total_amount DESC)
SELECT *, ROW_NUMBER() OVER (PARTITION BY region_name ORDER BY total_amount DESC) AS ranks
FROM sub)                          # 这里不能直接在后面写WHERE ranks = 1 原因是sub中并没有ranks这一列 是取出来的才有ranks这列
SELECT region_name, sales_rep, total_amount
FROM sub2                          # 所以这里必须新建一个sub2 在sub2里取WHERE 
WHERE ranks = 1                    # 这样一来无论取第几名都可以了
ORDER BY total_amount DESC;
```

## 4
find the total amount for each individual order that was spent on standard and gloss paper in the orders table  
this should give a dollar amount for each order in the table
``` sql
SELECT id, standard_amt_usd + gloss_amt_usd AS total_amount
FROM orders;
```

## 5
For the region with the largest sales total_amt_usd, how many total orders were placed?
``` sql
SELECT r.name AS region_name, SUM(o.total_amt_usd) AS total_amount, COUNT(*) AS number_of_orders
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a 
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
```

## 6
For the account that purchased the most (in total over their lifetime as a customer) standard_qty paper,   
how many accounts still had more in total purchases?
``` sql
WITH sub AS                                       # sub是一个包含所有sum(total) 比standard_qty最大的那个account 大 的account和sum(total)
(SELECT a.name AS name, SUM(o.total) AS total     # 注意 这里如果写* 会出现有重复id的问题 在sub里面运行没问题 但是一旦要count 就会报错
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name 
HAVING SUM(o.total) >
(SELECT SUM(o.total)
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY SUM(o.standard_qty) DESC
LIMIT 1))
SELECT COUNT(*) AS number
FROM sub;
```

## 7
What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?  
``` sql
WITH sub AS
(SELECT SUM(total_amt_usd) AS amount
FROM orders
GROUP BY account_id
ORDER BY 1 DESC
LIMIT 10)
SELECT AVG(amount)
FROM sub;
```

## 8
What is the lifetime average amount spent in terms of total_amt_usd,   
including only the companies that spent more per order, on average, than the average of all orders.
``` sql
WITH sub AS
(SELECT AVG(total_amt_usd) AS total
FROM orders
GROUP BY account_id
HAVING AVG(total_amt_usd) >
(SELECT AVG(total_amt_usd)
FROM orders))
SELECT AVG(total) AS lifetime_average_amount
FROM sub;
```

## 9 
某网站包含两个表，Customers 表和 Orders 表。编写一个 SQL 查询，找出所有从不订购任何东西的客户。  
![image](https://user-images.githubusercontent.com/105503216/177033392-c474a683-2d4f-448a-ae97-af1a38040c5a.png)
``` sql
SELECT Name AS Customers
FROM Customers
WHERE Id NOT IN (SELECT CustomerId FROM Orders);
```
或者
``` sql
SELECT c.Name AS Customers
FROM Customers c
LEFT JOIN Orders o
ON o.CustomerId = c.Id
WHERE o.CustomerId IS NULL
```
![image](https://user-images.githubusercontent.com/105503216/177033404-6fa73126-9ea9-4cc1-963b-eb1a9fca49fb.png)

```
