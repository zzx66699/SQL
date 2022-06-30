# Chapter3 The WHERE Statement
## 等于某个值
``` sql
SELECT *
FROM table1
WHERE state = 'VA'
```

## 日期要加''
``` sql
SELECT *
FROM table1
WHERE birth_date > '1999-09-07'
```

## The AND & OR & NOT operater
WHERE order_id = 6 AND unit_price * quantity > 30
在两个中间 BETWEEN 是大于等于和小于等于
WHERE points BETWEEN 1000 AND 3000 这个是inclusive的，前后都包含
时间的表达 WHERE w.occurred_at BETWEEN '01-01-2015' AND '01-01-2016' 到凌晨0点
IN 是在一组值中的任意一个
WHERE state IN (‘VA’,’FL’,’GA’)
