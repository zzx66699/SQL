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

## The IN operator 在一组值中的任意一个
``` sql
SELECT *
FROM products
WHERE quantity_in_stock IN (49, 38, 72)；
```

## The LIKE operator 包含某个值
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
WHERE last_name LIKE '_____y'
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
[] provides a option of a series of letters 一系列字符
``` sql
SELECT *
FROM Customers
WHERE last_name REGEXP '[gim]e'     # to match ge, ie, me
```
[] can also represents a range of letters 从xx到xx的字符
``` sql
SELECT *
FROM Customers
WHERE last_name REGEXP '[a-h]e'     # [a-h] represents letter a to h
```

## The IS NULL & IS NOT NULL operator
``` sql
SELECT *
FROM Customers
WHERE phone IS NULL
```

## 
