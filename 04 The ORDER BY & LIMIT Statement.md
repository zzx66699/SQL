# Chapter4 The ORDER BY & LIMIT Statement
## ORDER BY
ORDER BY: default in increasing order, use DESC to obtain descending order
``` sql
SELECT *
FROM customers
ORDER BY first_name DESC
```
Sort data by multiple columns. DESC can be used in any column
``` sql
SELECT *
FROM customers
ORDER BY state DESC, first_name
```
MySQL can sort data by columns not necessarily in SELECT clause(may be wrong in other database systems) or sort data by alias(in MySQL)
``` sql
SELECT first_name, last_name, 10 + 1 AS points
FROM customers
ORDER BY points, first_name
```
甚至可以用math expression来排序
``` sql
SELECT 10 AS number
FROM customers
ORDER BY number, quantity*number
```
## LIMIT
Use offset to obtain a certain range of data
``` sql
SELECT *
FROM customers
LIMIT 6, 3         # 前6位不要，从第7位开始，取3个值，getting records 7-9)
```
EXAMPLE:  
![image](https://user-images.githubusercontent.com/105503216/177524032-12f9cc7b-4766-425a-8e68-c3f3b9728cc5.png)
``` sql
SELECT 
    CASE
        WHEN COUNT(DISTINCT salary) = 1 THEN NULL  # NULL不要加''   
        ELSE
            (SELECT DISTINCT salary 
             FROM Employee
             ORDER BY salary DESC
             LIMIT 1,1)                            # 倒数第二大
    END AS SecondHighestSalary
FROM Employee;
```
