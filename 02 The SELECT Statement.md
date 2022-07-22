# Chapter2 The SELECT Statement
## The SELECT clause
AS: set the name of columns
``` sql
USE crmreview;

SELECT id, 
       10 AS numbers,                                                 # 一列叫做number 全是10
       gloss_qty + poster_qty + 100 AS qty,                           # 对原本序列的运算
       orders.*                                                       # orders这个table里的所有列 这点在多个表合并的时候很常用
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
DISTINCT 意味着后面的所有东西都相同才会被舍去  
<img width="79" alt="截屏2022-07-09 上午11 42 44" src="https://user-images.githubusercontent.com/105503216/178090289-c2bcd942-8a86-4b2f-9420-9bb97c52d78b.png">  
``` sql
SELECT DISTINCT id, year  # DISCTINCT只能使用一次
FROM try;
```
<img width="85" alt="image" src="https://user-images.githubusercontent.com/105503216/178090383-e8677b8e-cb89-4bf0-8219-730655378b05.png">

## The MOD() operator 或者 % 求余数
``` sql
SELECT MOD(5,2);

---
1
```

``` sql
SELECT 4 % 2;

---
0
```

## 取整
ceil (value) 产生大于或等于指定值（value）的最小整数。  
floor（value）与 ceil（）相反，产生小于或等于指定值（value）的最小整数。

## The CASE WHEN ... THEN ... END operator 条件
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

## The RIGHT & LEFT operator 左右取值
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
关于名字 first_name和last_name
``` sql
SELECT LEFT(primary_poc, STRPOS(primary_poc,' ')-1) AS 'first_name',
       RIGHT(primary_poc, LENGTH(primary_poc)-STRPOS(primary_poc, ' ')) AS 'last_name'
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
如果不加LENGTH 默认取到结尾
``` sql
SELECT SUBSTR('ASDFGH',2);

---
SDFGH
```

## The ROUND operator 保留几位小数
ROUND(xx,几位数)

## The REPLACE operator 代替
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

## The CONCAT operator 连结
``` sql
SELECT CONCAT('Z','Z','X') AS result;

---
result
ZZX    
```
GROUP_CONCAT 分组连接  
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

## The substring_index() operator 按某种方法分割 然后取数
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
UNION之后可以直接排序 把两个一起排序
``` sql
SELECT e.employee_id AS employee_id
FROM Employees e
LEFT JOIN Salaries s USING (employee_id)
WHERE s.salary IS NULL

UNION 

SELECT s.employee_id AS employee_id
FROM Employees e
RIGHT JOIN Salaries s USING (employee_id)
WHERE e.name IS NULL

ORDER BY employee_id;
```

## The IFNULL operation
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

## The LEAD & LAG operator 关于延后和提前
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


