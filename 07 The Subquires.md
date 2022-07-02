# Chapter7 The Subquires
## Subqueries in WHERE statement
``` sql
# find products that are more expensive than LETTUCE(id=3)

USE sql_inventory;

SELECT product_id, name, unit_price
FROM products
WHERE unit_price > (SELECT unit_price FROM products WHERE product_id = 3);
```
EXERCISE
``` sql
# in sql_hr database, find employees whose earn more than average

USE sql_hr;

SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);
```
![image](https://user-images.githubusercontent.com/105503216/176987175-149500fc-e2dd-4e11-8c26-74df0df7ba89.png)

## Subqueires in SELECT statement
按列来看 前面几列已经列好了  
需要对应着前面几列每一行的值 来生成后面的列每一行的值  

EXERCISE1  
![image](https://user-images.githubusercontent.com/105503216/176984376-433c81f3-c434-4f1b-bf2e-ce2d226120b3.png)  
其中表invoices是  
![image](https://user-images.githubusercontent.com/105503216/176984413-2e9205c3-aace-4b25-859c-51b947faa42b.png)  

``` sql
SELECT invoice_id, invoice_total,
       (SELECT AVG(invoice_total) FROM invoices) AS invoice_average,   # 子句返回的是一个数
       invoice_total - (SELECT invoice_average) AS difference          # (SELECT invoice_average)就是把这个整个作为一个子句
FROM invoices;

# 相当于
SELECT invoice_id, invoice_total,
       (SELECT AVG(invoice_total) FROM invoices) AS invoice_average,   
       invoice_total - (SELECT AVG(invoice_total) FROM invoices) AS difference         
FROM invoices;
```
**特别注意**  
1.由于AVG()是聚合函数 所以如果直接使用AVG会只输出一行
``` sql
SELECT invoice_id, invoice_total,
       AVG(invoice_total) AS invoice_average
FROM invoices;
```
![image](https://user-images.githubusercontent.com/105503216/176984889-b8f56a50-f749-4230-9983-87cf1459c81c.png)  
此时可以使用GROUP BY来进行分组 但非常麻烦  
2.在表达式中不可以使用列的别名 所以以下是错误的
``` sql
SELECT invoice_id, invoice_total,
       (SELECT AVG(invoice_total) FROM invoices) AS invoice_average,   
       invoice_total - invoice_average AS difference         
FROM invoices;
```
3.(SELECT invoice_average)就好了   
(SELECT invoice_average FROM invoices)会报错  
原话是：invoice_average是一个列名  
(invoice_average)是一个子句  
在前面加上SELECT就好 (SELECT invoice_average)

EXERCISE2  
![image](https://user-images.githubusercontent.com/105503216/176983376-db301420-2678-4552-a306-7e334b318efd.png)  
表client表是  
![image](https://user-images.githubusercontent.com/105503216/176984049-b71f1ebd-21e8-4663-8959-03c337cb4d58.png)  
``` sql
# 求出client这个表里每个client的total_sales，所有clients的total_sales均值，以及他们的差

SELECT client_id, name, 
       SUM(invoice_total) AS total_invoice,
       (SELECT AVG(invoice_total) FROM invoices) AS average,
       SUM(invoice_total) - (SELECT(average)) AS difference
FROM clients 
LEFT JOIN invoices using (client_id)
GROUP BY client_id
ORDER BY client_id;
```
![image](https://user-images.githubusercontent.com/105503216/176984057-627bb133-c486-4643-9884-e61e014695a8.png)  
Code in the video  
``` sql
USE sql_invoicing;

SELECT
    c.client_id,
    name,
    (SELECT SUM(invoice_total)                            # 这一步很奇怪
	FROM invoices
        WHERE client_id = c.client_id) AS total_sales,
    (SELECT AVG(invoice_total) FROM invoices) AS average,
    (SELECT total_sales - average) AS difference          # 主要注意这种两个subquery的写法
FROM clients c
```
**特别注意**   
以下代码错误 是因为SUM(invoice_total)和SUM(payment_total)本身不是子句  
所以无法通过加（SELECT ）转化成子句
``` sql
SELECT 'First half of 2019' AS data_range, 
        SUM(invoice_total) AS total_sales,
        SUM(payment_total) AS total_payments,
        (SELECT total_sales - total_payments) AS what_we_expect   
FROM invoices
WHERE invoice_date BETWEEN '2019-01-01' AND '2019-06-30';
```

## Subqueries in FROM statement
``` sql
# Find the average number of events for each channel per day. 
# 每个channel，说明各个channel是分开的。
# 每天平均的event数量，说明要用总的event数量/DISTINCT的天数

USE crmreview;

SELECT channel, AVG(total_events) AS average_events
FROM (
SELECT COUNT(*) AS total_events, 
       LEFT(occurred_at, 10) AS day, 
       channel   
FROM web_events
GROUP BY account_id, day) sub       # 子句中 每一行就是每一天
GROUP BY channel;

# 也可以使用WITH语句 写法相似
WITH sub AS(
SELECT COUNT(*) AS total_events,
       channel
FROM web_events
GROUP BY channel, LEFT(occurred_at, 10))
SELECT channel, AVG(total_events)
FROM sub
GROUP BY channel;
```

## The WITH operation
``` sql
WITH table1 as (SELECT * FROM web_events),
     table2 as (SELECT * FROM accounts)
SELECT *
FROM table1
JOIN table2
ON table1.account_id = table2.id;
```

