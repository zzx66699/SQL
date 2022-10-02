# Chapter5 The JOIN Statement
## Inner JOIN 结果只会出现几个表共有的值
``` sql
SELECT *
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id;
```

### Join more than 2 tables 多个table结合 
如果是一个表要个另一个表结合多次 记得把另外一个表的alias改了 就不会出现重复问题了！！！

``` sql
SELECT 
    o.order_id,
    o.order_date,
    c.first_name,
    c.last_name,
    os.name AS status
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_statuses os
    ON o.status = os.order_status_id
```

### 多个join条件
``` sql
SELECT *
FROM order_items oi
JOIN order_item_notes oin
    ON oi.order_id = oin.order_id AND 
       oi.product_id = oin.product_id
```

## Outer JOIN 左JOIN就出现左边表的所有值 没有的用NULL填补
LEFT (OUTER) JOIN RIGHT (OUTER) JOIN OUTER is optional
``` sql
SELECT
    c.customer_id,
    c.first_name,
    o.order_id
FROM customers c
LEFT JOIN orders o
    ON o.customer_id = c.customer_id
ORDER BY c.customer_id
```
## FULL JOIN 
连接表将包含的所有记录来自两个表，并使用NULL值作为两侧缺失匹配结果

``` sql
SELECT table1.column1, table2.column2
FROM table1
FULL JOIN table2
ON table1.common_field = table2.common_field;
```

注意很多版本里没有FULL JOIN这个表达  
可以用LEFT JOIN UNION RIGHT JOIN代替；

## 关于Inner JOIN 和 Outer JOIN的实例
account  
![4](https://user-images.githubusercontent.com/105503216/176695403-6ba0bd12-8a90-4963-b607-e38b99bc066f.png)  

orders
![5](https://user-images.githubusercontent.com/105503216/176695579-6dd21e33-665f-4225-959d-820d999360b9.png)  

Inner JOIN:
``` sql
SELECT * 
FROM account a
JOIN orders o
    ON a.id = o.account_id;
```
![1](https://user-images.githubusercontent.com/105503216/176692248-07bc1131-b1ed-4032-b32b-86be47b19338.png)  

Outer JOIN:
``` sql
SELECT * 
FROM account a
LEFT JOIN orders o                       # LEFT JOIN指的是保留FROM后面的table的所有量
         ON a.id = o.account_id;         # 左右和这里的xx=xx的顺序没有关系
```
![2](https://user-images.githubusercontent.com/105503216/176693381-d77abf06-ae42-4f08-8443-ba39f0d1b3d9.png)
``` sql
SELECT * 
FROM account a
RIGHT JOIN orders o
         ON a.id = o.account_id;
```
![3](https://user-images.githubusercontent.com/105503216/176694036-f61d502c-613e-421d-acd1-4c7d69dfebbe.png)

## Self JOIN
``` sql
# 在employees这个表中 有每个employee的代号、姓名、汇报的人的代号
# 通过汇报的人的代号 可以找出每个employee的汇报者（因为人和代号的对应关系是相同的）

SELECT e.employee_id
       e.first_name, e.last_name, 
       e.reports_to,
       m.first_name AS manager_first_name, m.last_name AS manager_last_name
FROM employee e
JOIN employee m
    ON e.reports_to = m.employee_id;
```

EXERCISE:  
<img width="632" alt="image" src="https://user-images.githubusercontent.com/105503216/193403402-6d2d39f1-96f7-462c-a7f2-c7e41b58cca0.png">

``` SQL
SELECT DISTINCT e1.employee_id
FROM Employees e1
JOIN Employees e2
ON e1.manager_id = e2.employee_id
JOIN Employees e3
ON e2.manager_id = e3.employee_id
WHERE e3.manager_id = 1 AND e1.employee_id != 1
```

## Cross JOIN 笛卡尔积
把表1中的每一行和表2中的每一行combine   

<img width="262" alt="image" src="https://user-images.githubusercontent.com/105503216/193438435-d98b49c4-4d62-49e9-ae6b-f266bdd3eca7.png">  

``` sql
SELECT *
FROM Students s
CROSS JOIN Subjects u
```

<img width="352" alt="image" src="https://user-images.githubusercontent.com/105503216/193438477-3f2cc22c-21ba-42e4-81db-a0655097328e.png">  



One of the most common use cases for self JOINs is in cases where two events occurred, one after another.   
在同一个表中 的两个时间 相距不超过xx天  
EXERCISE:
``` sql
# Find out 同一个account的orders that come within 28 days 一对一对的形式出现

 SELECT o1.id AS o1_id,
       o1.account_id AS o1_account_id,
       o1.occurred_at AS o1_occurred_at,
       o2.id AS o2_id,
       o2.account_id AS o2_account_id,
       o2.occurred_at AS o2_occurred_at
FROM orders o1
LEFT JOIN orders o2 
ON o1.account_id = o2.account_id
AND o2.occurred_at > o1.occurred_at
AND o2.occurred_at <= o1.occurred_at + INTERVAL '28 days'
ORDER BY o1.account_id, o1.occurred_at
```

## Join Across Databases 在不同的database之间合并
``` sql
# 从sql_inventory这个database中选出products这个table
# 从sql_store这个database中选出order_items这个table
# 通过id这一列合并到order_items里面去

USE sql_inventory;
SELECT *
FROM sql_store.order_items so
JOIN product p
    ON p.id = so.id;
```
