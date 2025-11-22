# Chapter2 SELECT Statement
## The SELECT clause
AS: set the name of columns; it is optional
``` sql
USE crmreview;

SELECT id, 
       10 AS numbers,                                   # A column called "number", all the values are 10
       gloss_qty + poster_qty + 100 AS qty,             # calculation
       orders.*                                         # all the columns in orders table. this is common when table join 
       COUNT(*)                                         # Count the total number of entries
       COUNT (CITY) AS total_city                       # Count the total number of city
       COUNT (DISTINCT CITY) AS total_unique_city       # Count the total number of unique city

FROM orders
```
-----
## The DISTINCT operator 
exclude duplicates  
``` sql
# What are the different channels used by account 1001?  
# Your final table should have two columns: account name and channel 

SELECT DISTINCT a.name account_name, w.channel channel     # remove duplicate for a.name and w.channel columns
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE a.id = 1001;
```
``` sql
SELECT 
       COUNT (CITY) AS total_city                       # Count the total number of city
       COUNT (DISTINCT CITY) AS total_unique_city       # Count the total number of unique city

FROM orders
```
-----
## The MOD() operator OR % 
It returns the remainder of a division calculation
``` sql
SELECT MOD(5,2);
---
# 1
```

``` sql
SELECT 4 % 2;

---
# 0
```
-----
## The LENGTH operator 
LENGTH() counts the number of bytes, while CHAR_LENGTH() counts the number of characters.  
For example, if a string contains 5 characters and each character takes 2 bytes (such as Chinese characters), then:
LENGTH() returns 10; CHAR_LENGTH() returns 5
Also, for strings that may contain special characters or multibyte characters, it is generally safer to use CHAR_LENGTH() because it measures actual characters, not bytes. 

``` sql
SELECT CHAR_LENGTH(website)
FROM accounts;
```

-------
## 4. 取整
ceil (value) 产生大于或等于指定值（value）的最小整数。  
floor（value）与 ceil（）相反，产生小于或等于指定值（value）的最小整数。

## 5. The CASE operator 条件
``` sql
SELECT 
  CASE 
    WHEN total_amount > 3000 THEN 'large'                                                   # 只有一次WHEN
    ELSE 'small' 
    END AS levels,                                                                               # 命名为levels
  CASE 
    WHEN toal >= 2000 THEN 'at least 2000'                                                  # 好几次WHEN
    WHEN total < 2000 AND total >= 1000 TEHN 'between 1000 and 2000'                        # 两个条件用AND连结
    ELSE 'less than 1000' 
    END AS order_category,
FROM orders
```
EXAMPLE:  
![image](https://user-images.githubusercontent.com/105503216/177506029-3b84789c-d5f6-459e-a9a4-4105d4b73419.png)
``` sql
SELECT id,
    CASE 
        WHEN p_id IS NULL THEN 'Root'
        WHEN id IN (SELECT p_id FROM tree) THEN 'Inner'
        ELSE 'Leaf'
    END AS Type
FROM tree
```
EXERCISE1: SUM()和CASE WHEN ... THEN ... ELSE... END 可以嵌套起来用
![image](https://user-images.githubusercontent.com/105503216/178178936-aab0f0c2-8089-4bb4-b3b2-d5ad0f5191c6.png)
``` sql
SELECT stock_name,
    SUM(CASE WHEN operation = 'Buy' THEN price * -1           # 在group的情况下 对operation这列的每一个值进行判定 并且直接输出
        ELSE price END) AS capital_gain_loss                  # 注意下 END是CASE WHEN 这个句式的结束语
FROM Stocks
GROUP BY stock_name;
```

## 6. The RIGHT & LEFT operator 左右取值
``` sql
SELECT LEFT(name, 3)        # 取name这一列每一行值的前3个字符
FROM accounts;
```
由于出来的是字符串 所以即使看起来是数字也要加''
``` sql
SELECT a.name, 
       CASE WHEN LEFT(a.name,1) IN ('1','2','3','4','5','6','7','8','9','0') THEN 'number'
            ELSE 'letter'
       END AS group
FROM accounts;
```

## 7. The STRPOS & POSITION operator 位置
返回在a里b的index：STRPOS(a,b) 或者 POSITION(B IN A)
``` sql
SELECT POSITION(' ' IN primary_poc) AS position     # 在primary_poc中空格的位置
FROM accounts;
```
EXERCISE
``` sql
# Use the account table to create first and last name columns of primary_poc

SELECT LEFT(primary_poc, POSITION(' ' IN primary_poc)-1) AS first_name,
       RIGHT(primary_poc, LENGTH(primary_poc)-POSITION(' ' IN primary_poc)) AS last_name
FROM accounts;
```

## 8. The TRIM operator 删去前后的空格
``` sql
SELECT TRIM('    EHUI&U2  ') AS result;
```

sometimes the value may include blank  
we need to return this values  
so add 'WHERE TRIM() = XX' help us to return all the values  

## 9. The LOWER & UPPER operator 大小写
``` sql
SELECT LOWER(name)
FROM accounts;
```


## 11. The SUBSTR operator 截取一部分
SUBSTR(TEXT, START, LENGTH)
``` sql
SELECT SUBSTR('ZZX XIXI HAHA', 3,5) AS result;

---
result
X XIX
```
如果不加LENGTH 默认取到结尾
``` sql
SELECT SUBSTR('ASDFGH',2);

---
SDFGH
```

## 12. The ROUND operator 保留几位小数
ROUND(xx,几位数)

## 13. The REPLACE operator 代替
用b替换a：REPLACE(TEXT,A,B)
``` sql
SELECT REPLACE('ZZX','X','Z') AS result;

---
result
ZZZ
```
常用于删去某个值 譬如空格
``` sql
SELECT REPLACE(name, ' ','') AS result
FROM account;
```
EXERCISE:  
求给定字段 Target_string在原字符串 All_string里的出现次数   

``` sql
SELECT (LENGTH(All_string) - LENGTH(REPLACE(All_string, Target_string, ''))) / LENGTH(Target_string) AS cnt
FROM table
```

## 14. The CONCAT operator 连接
``` sql
SELECT CONCAT('Z','Z','X') AS result;

---
result
ZZX    
```

EXERCISE: Find which route is most popular with different user types 

``` SQL
SELECT 
    usertype,
    CONCAT(start_station_name,"to", end_station_name) AS route,
    COUNT(*) num_trips,
    ROUND(AVG(tripduration/60),2) AS avg_duration
FROM `bigquery-public-data.new_york_citibike.citibike_trips` 
GROUP BY usertype, start_station_name, end_station_name
ORDER BY num_trips DESC
LIMIT 5
```
<img width="659" alt="image" src="https://user-images.githubusercontent.com/105503216/202638413-a04d33dd-af81-4da2-ae5a-154ab1c12109.png">

### 14.1 GROUP_CONCAT 分组连接  
GROUP_CONCAT(要连接的那一列 ORDER BY 按照什么列连接 SEPARATOR '连接符')  
![image](https://user-images.githubusercontent.com/105503216/177463689-66c091ef-dc9d-4bea-9577-45a5252e1a99.png)
![image](https://user-images.githubusercontent.com/105503216/177463716-a3f33d4f-047f-44de-9f66-70a2f75341ba.png)
![image](https://user-images.githubusercontent.com/105503216/177463776-44d0cc9a-3444-491e-90fc-3dc6e355914b.png)
``` sql
SELECT sell_date,
    COUNT(DISTINCT product) AS num_sold, 
    GROUP_CONCAT(DISTINCT product ORDER BY product separator ',') AS products  # separator ',' 指用','连接
FROM Activities
GROUP BY sell_date
ORDER BY sell_date;
```

## 15. The substring_index() operator 按某种方法分割 然后取数
substring_index(str,delim,count)  
str:要处理的字符串 delim:分隔符   
count:计数 正数就是从左往右数第n个分隔符左边的所有内容 负数就是从右往左数第n个分隔符右边的所有内容   
<img width="705" alt="image" src="https://user-images.githubusercontent.com/105503216/178988136-bb81eec3-93fa-4458-88bd-42d08cb6b4ea.png">  
``` sql
# 直接分割
SELECT substring_index(profile, ',',-1) AS gender, COUNT(*)
FROM user_submit
GROUP BY substring_index(profile, ',',-1);

# 比较笨的方法
SELECT gender, COUNT(*) AS number
FROM (
SELECT 
    CASE WHEN profile LIKE '%female' THEN 'female'
        ELSE 'male' END 
    AS gender
FROM user_submit
) sub1
GROUP BY gender;
```
注意：通过重复的substring_index(substring_index(),)可以提取出中间的字符串


## 17. The IFNULL operation
![image](https://user-images.githubusercontent.com/105503216/178181864-5776e10e-0854-4a03-ae7f-db9aa14e1ea9.png)
![image](https://user-images.githubusercontent.com/105503216/178181878-9a44b59f-e582-4433-ae4a-4b1fd6906e67.png)
``` sql
SELECT u.name, IFNULL(SUM(r.distance),0) AS travelled_distance
FROM Users u
LEFT JOIN Rides r        # 左合并会产生0的问题
ON u.id = r.user_id
GROUP BY u.id
ORDER BY travelled_distance DESC, u.name;
```
注意在做除法时 如果分母为0 会自动记为null 此时就可以用ifnull

``` sql
SELECT IFNULL(SUM(if_payment)/SUM(if_refund),0) AS refund_rate;
```

## 18. The LEAD & LAG operator 关于延后和提前
LAG(要延后的那一列, 延后的个数) OVER (ORDER BY 要根据什么排列)
``` sql
# 延后joindate那一列

SELECT LAG(JoiningDate,1) OVER (ORDER BY JoiningDate) AS EndDate
FROM employee;
```
![图片1](https://user-images.githubusercontent.com/105503216/176591920-dd07fae2-f1ee-4b9e-a40b-48a667310390.png)  
延后补齐的东西默认为null，但是也可以自己设置
``` sql
SELECT *, LAG(JoiningDate, 1, ‘1999-09-01’) OVER (ORDER BY JoiningDate) AS EndDate
FROM employee;
```
还有延后两个的 如果只写一个补齐的值 那么两个位置都是那个值
``` sql
SELECT *, LAG(JoiningDate, 2, ‘1999-09-01’) OVER (ORDER BY JoiningDate) AS EndDate
FROM employee;
```
![图片2](https://user-images.githubusercontent.com/105503216/176592475-7d71949d-aa1a-4348-8c53-2bb882959efd.png)  
lead同理  
![图片3](https://user-images.githubusercontent.com/105503216/176592545-8e4b2d63-30e7-4350-9986-5bc4fa2b294b.png)  
还可以和PARTITION BY结合进行分组延后
``` sql
# in each year, lag 1 in QuarterSales, fill null with 0 

SELECT *, LAG(NextQuarterSales, 1, 0) OVER (PARTITION  BY Year ORDER BY Year, Quarter) AS LastQuarterSales
FROM ProductSales
ORDER BY Year, Quarter;
```
![图片4](https://user-images.githubusercontent.com/105503216/176593369-5e499468-5b81-40c9-83ee-c117cf2f1372.png)  
![图片5](https://user-images.githubusercontent.com/105503216/176593406-671fbb90-9f61-4253-9a04-77f961279439.png)    

EXERCISE1  
筛选出连续出现至少三次的数字  
find all numbers that appear at least three times consecutively.  

``` sql
SELECT DISTINCT num AS ConsecutiveNums
FROM
    (SELECT num, 
        LAG(num,1) OVER (ORDER BY id) AS num1,
        LAG(num,2) OVER (ORDER BY id) AS num2
    FROM Logs) sub1
WHERE num = num1 AND num = num2
```

EXERCISE2  
Consecutive Available Seats  
<img width="624" alt="image" src="https://user-images.githubusercontent.com/105503216/191894371-d10eea2c-2c23-449c-b9f8-cada657bb3f8.png">  

``` SQL
SELECT seat_id
FROM 
(SELECT seat_id, free, 
    LAG(free,1) OVER (ORDER BY seat_id) AS free1,
    LEAD(free,1) OVER (ORDER BY seat_id) AS free2
FROM Cinema) sub1
WHERE free = 1 AND (free1 = 1 OR free2 = 1)
ORDER BY seat_id
```


## 19. The CAST operator
CAST is used to change the column to another datatype  

### 19.1 Transfer into FLOAT

``` SQL
SELECT 
    CAST(purchase_amount AS FLOAT64) AS amount
FROM dataset
```

### 19.2 Transfer into DATE datatype
<img width="435" alt="image" src="https://user-images.githubusercontent.com/105503216/201454683-3ec06616-53c5-4544-a1f9-713f79eb2a60.png">

### 19.3 Converting a date to a datetime
Datetime values have the format of YYYY-MM-DD hh: mm: ss format.

``` SQL
SELECT CAST(MyDate AS DATETIME)
FROM Mytable
```

### 19.4 Converting a date to a string

``` sql
SELECT CAST(MyDate AS STRING) FROM MyTable
```

## 20. COALESCE 

```
COALESE(a, b)
```
return a, if a is null then b 

```SQL
SELECT COALESCE(product, product_code)
FROM `customer_data.customer_purchase ` 
```

## 21. EXTRACT
The purpose of the EXTRACT command in a query is to extract a part from a given date.   
The EXTRACT command can extract any part from a date/time value.   

``` SQL
SELECT 
  Date,
  EXTRACT(YEAR FROM Date) AS year,
  EXTRACT(MONTH FROM Date) AS month
FROM `acoustic-env-366213.avocado.avocado_table` 
```
<img width="401" alt="image" src="https://user-images.githubusercontent.com/105503216/203071004-082bc039-f3fb-42f4-afb8-f8c921aeb25b.png">


