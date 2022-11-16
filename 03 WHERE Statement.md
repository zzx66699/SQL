# Chapter3 WHERE Statement
## 1. = & != 
select all the names that are not referred by the customer with id = 2  

``` sql
# 只要不是2都可以 就算是NULL也可以

SELECT name
FROM customer
WHERE referee_id != 2 OR referee_id IS NULL;
```

注意这里只能判断非NULL的值 会自动舍去NULL的值  
所以如果想要保留NULL的值 就要加上OR referee_id IS NULL

## 2. The IN & NOT IN operator 在一组值中的任意一个
``` sql
SELECT *
FROM products
WHERE quantity_in_stock IN (49, 38, 72)；
```
## 3. The AND & OR & NOT operater
``` sql
SELECT *
FROM table
WHERE order_id = 6 AND unit_price * quantity > 30
```
NOT: negate a condition 当要否定多个条件时记得（）
``` sql
SELECT *
FROM Customers
WHERE NOT (birth_date > '1990-01-01' OR points > 1000)     # 注意日期要加''
```
EXERCISE
``` sql
# find all the names that stars with 'C' or 'W'
# primary_poc contains 'ana' or 'Ana'
# but primary_poc doesn't contain 'eana'

SELECT *
FROM accounts
WHERE (name LIKE 'C%' OR name LIKE 'W%') AND                      # 注意多个并列条件的应用 xx和xx是并列
      (primary_poc LIKE '%ana%' OR primary_poc LIKE '%Ana%') AND
      primary_poc NOT LIKE '%eana%';
```

## Subqueries in WHERE statement
``` sql
# find products that are more expensive than LETTUCE(id=3)

USE sql_inventory;

SELECT product_id, name, unit_price
FROM products
WHERE unit_price > (SELECT unit_price FROM products WHERE product_id = 3);
```
EXERCISE1
``` sql
# in sql_hr database, find employees whose earn more than average

USE sql_hr;

SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);
```
![image](https://user-images.githubusercontent.com/105503216/176987175-149500fc-e2dd-4e11-8c26-74df0df7ba89.png)  

EXERCISE2
``` sql
# find out all the orders that occurs in the latest month and compute the average orders

SELECT AVG(total), AVG(total_amt_usd)
FROM orders
WHERE MONTH(occurred_at) = 
(SELECT MIN(MONTH(occurred_at))     # 注意MIN,MAX这种aggregation function不能直接放在where里面 必须用subquery
FROM orders);
```

EXERCISE3  
注意筛选出一列不在另一列中的行 也要用sub 不能直接列not in 列

``` sql
SELECT e.emp_no, m.emp_no AS manager
FROM dept_emp e
JOIN dept_manager m
ON e.dept_no = m.dept_no
WHERE e.emp_no NOT IN (SELECT emp_no FROM dept_manager)   # 千万不能WHERE e.emp_no NOT IN emp_no  
```

EXERCISE4  
<img width="647" alt="Screenshot 2022-09-25 at 4 26 07 PM" src="https://user-images.githubusercontent.com/105503216/192134739-53abca81-b447-4e3b-a4ef-bd946c017ddc.png">  

``` SQL
SELECT customer_id
FROM Customer 
GROUP BY customer_id
HAVING COUNT(DISTINCT product_key) = (SELECT COUNT(*) FROM Product)  # 在这里用distinct
```

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
GROUP BY channel, day) sub       # 子句中 每一行就是每一天
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
多个WITH之间加上, 且不重复使用WITH
``` sql
WITH table1 as (SELECT * FROM web_events),
     table2 as (SELECT * FROM accounts)
SELECT *
FROM table1
JOIN table2
ON table1.account_id = table2.id;
```



## 21. The BETWEEN ... AND... operator
在两个中间 BETWEEN 是大于等于 和 小于等于
``` sql
SELECT *
FROM table
WHERE points BETWEEN 1000 AND 3000；      # 这个是inclusive的，前后都包含
```
### 特别注意关于时间的表达 
**归根结底 所有纯的日期模式xxxx-xx-xx 事实上都是xxxx-xx-xx 00:00:00的缩写**  
所以  
如果原database是纯的日期模式xxxx-xx-xx  
应该只到2015-12-31 00:00:00
``` sql
SELECT *
FROM table
WHERE w.occurred_at BETWEEN '2015-01-01' AND '2015-12-31'；         # 到凌晨0点 这里指的是2015全年
```
但如果原database有了时间 就必须放到后一天 否则最后一天就没有了  
譬如'2015-12-31 13:01:02' 这个就不包含在 BETWEEN '2015-01-01' AND '2015-12-31' 中  
所以应该到2016-01-01 00:00:00
``` sql
SELECT *
FROM table
WHERE w.occurred_at BETWEEN '2015-01-01' AND '2016-01-01'；         # 到凌晨0点 这里指的是2015全年
```


## 23. EXISTS & NOT EXISTS
什么时候用EXISTS，什么时候用IN？  
当从表小时，IN查询的效率较高；先执行子查询，再带到外面去，子查询只需要执行一次。
当主表小时，EXISTS查询的效率较高；主查询有多少条数据，子查询就要执行多少次   

NOT IN 和 NOT EXISTS  
如果查询语句使用了not in 那么内外表都进行全表扫描，没有用到索引；  
而not extsts 的子查询依然能用到表上的索引。  
所以无论那个表大，用not exists都比not in要快。  

``` python
SELECT *
FROM employees
WHERE NOT EXISTS (SELECT emp_no 
                  FROM dept_emp 
                  WHERE employees.emp_no=dept_emp.emp_no)
```

                  
## 24. The LIKE & NOT LIKE operator 包含某个值
注意所有都不区分大小写
``` sql
SELECT *
FROM Customers
WHERE last_name LIKE 'b%' AND     # b开头
      fist_name LIKE '%a' AND     # a结尾
      name LIKE '%c%'；           # 包含c
```
_ indicates a single character 有几个_就代表有几个字符
``` sql
SELECT *
FROM Customers
WHERE last_name LIKE '_____y';
```
至少有x个字符 _和%一起使用
``` sql
SELECT *
FROM customers
WHERE last_name LIKE 'a__%';   # 以a开头且至少有三个字符
```
NOT LIKE: 不是 
``` sql
# 不以a开头

SELECT * 
FROM account 
WHERE last_name NOT LIKE 'a%'
```
EXAMPLE: 姓以xx开头
``` sql
SELECT *
FROM accounts
WHERE s.name LIKE '% K%'           # 注意这里有一个空格！！！表示姓！！
```


## 25. The REGEXP operator 正则表达式
``` sql
SELECT *
FROM Customers
WHERE last_name REGEXP '^b' AND     # b开头
      fist_name REGEXP 'a$' AND     # a结尾
      name REGEXP 'c'；             # 包含c
```
| searches for multiple words 表示xx或xx的条件
``` sql
SELECT *
FROM Customers
WHERE last_name REGEXP 'field$|^mac|rose'     
```
[] provides a option of a series of letters 只要包含一系列字符 不一定要完全一样  
其中try是  
![image](https://user-images.githubusercontent.com/105503216/176995411-dd4b5e99-b20a-4123-9183-e1408e926211.png)
``` sql
SELECT *
FROM try
WHERE characters REGEXP '[as]t';     # to include at or st
```
![image](https://user-images.githubusercontent.com/105503216/176995422-79c13137-ff7c-498d-9f15-130e80916354.png)  

[] can also represents a range of letters 从xx到xx的字符 依然是包含就可以
``` sql
SELECT *
FROM Customers
WHERE last_name REGEXP '[a-h]e' ;    # [a-h] represents letter a to h 可以是ae到he中的任意一个
```

## 26. The IS NULL & IS NOT NULL operator
``` sql
SELECT *
FROM Customers
WHERE phone IS NULL
```




