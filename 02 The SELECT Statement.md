# Chapter2 The SELECT Statement
## The SELECT clause
AS: set the name of columns
``` sql
USE crmreview;

SELECT id, 
       10 AS numbers,                                                                 # 一列叫做number 全是10
       gloss_qty + poster_qty + 100 AS qty,                                          # 对原本序列的运算
       orders.*                                                                      # orders这个table里的所有列 这点在多个表合并的时候很常用
FROM orders
```

## The DISTINCT operator 非重复值
exclude duplicates  
``` sql
# What are the different channels used by account 1001?  
# Your final table should have two columns: account name and channel 

SELECT DISTINCT a.name account_name, w.channel channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE a.id = 1001;
```

## The CASE WHEN ... THEN ... operator 条件
``` sql
SELECT CASE WHEN total_amount > 3000 THEN 'large'                                                   # 只有一次WHEN
            ELSE 'small' 
       END AS levels,                                                                               # 命名为levels
       
       CASE WHEN toal >= 2000 THEN 'at least 2000'                                                  # 好几次WHEN
            WHEN total < 2000 AND total >= 1000 TEHN 'between 1000 and 2000'                        # 两个条件用AND连结
            ELSE 'less than 1000' 
       END AS order_category,
FROM orders
```

## The RIGHT & LEFT operator 左右取值
``` sql
SELECT LEFT(name, 3)        # 取name这一列每一行值的前3个字符
FROM accounts;
```

## The STRPOS & POSITION operator 位置
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

## The TRIM operator 删去前后的空格
``` sql
SELECT TRIM('    EHUI&U2  ') AS result;
```

## The LOWER & UPPER operator 大小写
``` sql
SELECT LOWER(name)
FROM accounts;
```

## The LENGTH operator 长度
``` sql
SELECT LENGTH(website)
FROM accounts;
```

## The SUBSTR operator 截取一部分
SUBSTR(TEXT, START, LENGTH)
``` sql
SELECT SUBSTR('ZZX XIXI HAHA', 3,5) AS result;

---
result
X XIX
```

## The REPLACE operator 代替
用b替换a：REPLACE(TEXT,A,B)
``` sql
SELECT REPLACE('ZZX','X','Z') AS result;

---
result
ZZZ
```

## The CONCAT & || operator 连结
``` sql
SELECT CONCAT('Z','Z','X') AS result;

---
result
ZZX    
```

## The UNION operator 两个表格行的合并
rbind合并两个select之后的table  
UNION（会删去重复的行）或者UNION ALL（这个不会删去重复的行）
``` sql
SELECT *
FROM web_events1

UNION ALL

SELECT *
FROM web_events2
```

## The aggregation function 数数最大最小求和平均值方差标准差等
```
SELECT COUNT(), 
       MAX(), MIN(), 
       SUM(), 
       AVG(), 
       VAR(), STD()
FROM accounts;
```
注意sql中没有中位数median的函数  

## The NTILE operator 几等分点 结果是组别数
``` sql
SELECT account_id, occurred_at, standard_qty, 
       NTILE(4) OVER (ORDER BY standard_qty) AS quartile,         # 根据standard_qty从小到大排序分组
       NTILE(5) OVER (ORDER BY standard_qty) AS quintile,
       NTILE(2) OVER (ORDER BY standard_qty) AS median,
       NTILE(100) OVER (ORDER BY standard_qty) AS percentile
FROM orders；

# 也可以把(ORDER BY standard_qty)直接赋值代替
SELECT account_id, occurred_at, standard_qty, 
       NTILE(4) OVER a AS quartile,
       NTILE(5) OVER a AS quintile,
       NTILE(2) OVER a AS median,
       NTILE(100) OVER a AS percentile
FROM orders
WINDOW a AS (ORDER BY standard_qty);
```
![1](https://user-images.githubusercontent.com/105503216/176344637-6020c4aa-4e85-4879-8a0f-ed4ea70b6bf9.png)

## The SUM...OVER... operator
Cum(ulative) sum 不断地累计求和
``` sql
# calculate the cum sum of standard_qty
# from the oldest to newest

SELECT SUM(standard_qty) OVER (ORDER BY occurred_at) AS cum_sum
FROM orders;
```

