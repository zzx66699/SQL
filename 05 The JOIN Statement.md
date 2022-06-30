# Chapter5 The JOIN Statement
## Inner JOIN 结果只会出现几个表共有的值
``` sql
SELECT *
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id;
```
Join more than 2 tables 多个table结合
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
多个join条件
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

## Cross JOIN
把表1中的每一行和表2中的每一行combine
``` sql
SELECT 
    c.first_name AS customer,
    p.name AS product
FROM customers c
CROSS JOIN products p
ORDER BY c.first_name
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
