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

## 10
交换性别 f变成m m变成f
``` sql
# IF 语句
UPDATE Salary
SET sex = IF(sex = 'f','m','f');

# CASE WHEN语句
UPDATE Salary
SET sex = 
	CASE sex 
		WHEN 'm' THEN 'f'
		ELSE 'm' END;
```

## 11
编写一个 SQL 删除语句来 删除 所有重复的电子邮件，只保留一个id最小的唯一电子邮件
``` sql
# 写法1
DELETE FROM Person
WHERE id NOT IN (
    SELECT * 
    FROM (
        SELECT MIN(id) AS id
        FROM Person
        GROUP BY email
        ) a
);
```
注意：MYSQL不给update to a table when you are also using that same table in an inner select as your update criteria.  
所以必须再SELECT一次

## 12
![image](https://user-images.githubusercontent.com/105503216/177291384-8d48f5ea-e6b4-4fef-8cff-eefd95eeb711.png)
![image](https://user-images.githubusercontent.com/105503216/177291456-991a8d37-ae50-407f-8363-cf5bed6204b9.png)

``` sql
WITH sub1 AS
(SELECT caller_id AS id, duration
FROM Calls
UNION ALL
SELECT callee_id AS id, duration
FROM Calls
)
SELECT 
    c.name AS country
FROM sub1
JOIN Person p
ON sub1.id = p.id
JOIN Country c
ON c.country_code = LEFT(p.phone_number,3) 
GROUP BY c.name
HAVING AVG(duration) > (SELECT AVG(duration) FROM Calls)
```

## 13
![image](https://user-images.githubusercontent.com/105503216/177466738-e55666cc-9eeb-4591-806b-2b98787c7e58.png)
![image](https://user-images.githubusercontent.com/105503216/177466764-c0f77aff-b979-47c0-962a-a2996ffab907.png)
![image](https://user-images.githubusercontent.com/105503216/177466780-7923fd9b-7656-4352-b517-91e387b9b6e8.png)
``` sql
-- 方法1 LEFT JOIN 合并
-- 注意SQL里面没有全连接
SELECT e.employee_id
FROM Employees e
LEFT JOIN Salaries s USING (employee_id)
WHERE s.salary IS NULL

UNION

SELECT s.employee_id
FROM Salaries s
LEFT JOIN Employees e USING (employee_id)
WHERE e.name is NULL

ORDER BY employee_id

-- 方法2 WHERE IN
SELECT employee_id
FROM Employees 
WHERE employee_id NOT IN (SELECT employee_id FROM Salaries)

UNION

SELECT employee_id
FROM Salaries
WHERE employee_id NOT IN (SELECT employee_id FROM Employees)

ORDER BY employee_id
```

## 14
![image](https://user-images.githubusercontent.com/105503216/177469684-37fbda74-159c-4915-b8f8-42df8ce84ddb.png)
``` sql
SELECT product_id, 'store1' AS store, store1 AS price
FROM Products
WHERE store1 IS NOT NULL
UNION
SELECT product_id, 'store2' AS store, store2 AS price
FROM Products
WHERE store2 IS NOT NULL
UNION
SELECT product_id, 'store3' AS store, store3 AS price
FROM Products
WHERE store3 IS NOT NULL
```

## 15
![image](https://user-images.githubusercontent.com/105503216/177519237-27da39fc-19f5-463f-84fa-2c1a3463af59.png)
``` sql
# for odds
SELECT s1.id, 
    CASE 
        WHEN MOD((SELECT COUNT(*) FROM Seat),2)=1 AND    # 这里注意下表述 不可以直接写MOD(COUNT(*),2) 因为后面的WHERE已经改变了序列
            s1.id = (SELECT COUNT(*) FROM Seat) THEN 
	    	s1.student
        ELSE s2.student
    END AS student
FROM Seat s1
LEFT JOIN Seat s2
ON s1.id = s2.id - 1
WHERE MOD(s1.id,2) = 1

UNION

# for even
SELECT s1.id, s2.student AS student
FROM Seat s1
JOIN Seat s2
ON s1.id = s2.id + 1
WHERE MOD(s1.id,2) = 0
ORDER BY id

-- 当用WHERE分类再用UNION合并的写法成立时 可以考虑一下CASE WHEN ... THEN ... 有相同的效应
-- 而且不是一定要JOIN 才可以取另外一个表的值
SELECT s1.id, 
    CASE 
        WHEN MOD(s1.id,2) = 0 THEN 
            (SELECT s2.student FROM Seat s2 WHERE s2.id = s1.id - 1)
        WHEN MOD(s1.id,2)=1 AND s1.id = (SELECT MAX(id) FROM Seat) THEN 
            s1.student
        ELSE (SELECT s2.student FROM Seat s2 WHERE s2.id = s1.id + 1)
    END AS student
FROM Seat s1
ORDER BY s1.id;
```

## 16
现在运营想要了解2021年8月份所有练习过题目的总用户数和练习过题目的总次数，请取出相应结果  
![image](https://user-images.githubusercontent.com/105503216/177784030-7a78b82b-46d9-42d7-8788-6e92e603d6b0.png)  
``` sql
SELECT 
    COUNT(DISTINCT device_id) AS did_cnt,   # 注意以下DISTINCT的应用
    COUNT(*) AS question_cnt
FROM question_practice_detail
WHERE date BETWEEN '2021-08-01' AND '2021-08-31';
```

## 17
现在运营想要分别查看学校为山东大学或者性别为男性的用户的device_id、gender、age和gpa数据，请取出相应结果，结果不去重，先输出学校为山东大学再输出性别为男生的信息
``` sql
SELECT device_id, gender, age, gpa
FROM user_profile
WHERE university = '山东大学'
UNION ALL
SELECT device_id, gender, age, gpa
FROM user_profile
WHERE gender = 'male'
```

## 关于日期
### 1.日期间隔
<img width="576" alt="截屏2022-07-08 下午9 11 36" src="https://user-images.githubusercontent.com/105503216/177998662-ddb1f4aa-be33-4a35-b7ee-873e2e08e57f.png">. 

``` sql
SELECT w1.id
FROM Weather w1
JOIN Weather w2
ON DATEDIFF(w1.recordDate, w2.recordDate) = 1.  # 关于日期的间隔 使用DATEDIFF 不要直接使用数字 + 几
WHERE w1.Temperature > w2.Temperature

# 也可以使用DATE_ADD
SELECT w1.id
FROM Weather w1
JOIN Weather w2
ON W1.recordDate = DATE_ADD(W2.recordDate, interval 1 day) 
WHERE w1.Temperature > w2.Temperature
```

### 2.留存率
<img width="636" alt="image" src="https://user-images.githubusercontent.com/105503216/178090821-2a6d2cef-6777-4b70-b28b-365d81add1ca.png">

``` sql
WITH sub1 AS (
SELECT COUNT(DISTINCT device_id, date) AS number1
FROM question_practice_detail
),                        		# 这里要用逗号隔开 且不能再加上WITH
sub2 AS (
SELECT COUNT(DISTINCT q1.device_id, q1.date) AS number2
FROM question_practice_detail q1
JOIN question_practice_detail q2
ON DATEDIFF(q2.date, q1.date) = 1 AND
    q1.device_id = q2.device_id
)
SELECT number2 / number1 AS avg_ret 	# 注意这里一定要是columns的名字 不能是sub的名字
FROM sub1, sub2;    			# 从两个sub中取columns
```

### 3.xx天内的活跃用户
<img width="666" alt="image" src="https://user-images.githubusercontent.com/105503216/178098927-00fd1849-4bf5-4b18-835f-181bedcf4373.png">

``` sql
WITH sub1 AS(
SELECT date AS Date, 
	COUNT(DISTINCT user_id) AS 活跃用户数     # 每日的活跃用户数 是group_by日期之后 count(distinct user_id)
FROM active
GROUP BY date
) ,
sub2 AS (
SELECT a1.date AS Date, 
	COUNT(DISTINCT a1.user_id) AS 活跃30天留存用户数
FROM active a1
JOIN active a2
ON a1.user_id = a2.user_id AND
	DATEDIFF(a2.date, a1.date) < 30 AND     # 注意这里小于30
    DATEDIFF(a2.date, a1.date) > 0          # 这里一定要大于0 不然在改日期之前的也会被取到
GROUP BY a1.date
)
SELECT sub1.Date AS Date, 
sub1.活跃用户数,
CASE WHEN sub2.活跃30天留存用户数 IS NULL THEN 0
	ELSE 活跃30天留存用户数
END AS 活跃30天留存用户数
FROM sub1
LEFT JOIN sub2
ON sub1.Date = sub2.Date
```
