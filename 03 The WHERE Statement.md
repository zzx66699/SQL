# Chapter3 The WHERE Statement
## 等于某个值
``` sql
SELECT *
FROM table1
WHERE state = 'VA'
```

## The AND & OR & NOT operater
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

## The BETWEEN ... AND... operator
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

## The IN & NOT IN operator 在一组值中的任意一个
``` sql
SELECT *
FROM products
WHERE quantity_in_stock IN (49, 38, 72)；
```

## The LIKE & NOT LIKE operator 包含某个值
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


## The REGEXP operator 正则表达式
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

## The IS NULL & IS NOT NULL operator
``` sql
SELECT *
FROM Customers
WHERE phone IS NULL
```


