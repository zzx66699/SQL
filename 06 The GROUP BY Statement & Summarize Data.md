# Chapter6 The GROUP BY Statement & Summarize data
## The aggregation function 数数最大最小求和平均值方差标准差等
Only executed on non-NULL values, ignore NULL values
``` sql
SELECT COUNT(DISTINCT client_id) AS total_clients,      # 使用DISTINCT去remove duplicates
       MAX(), MIN(), 
       SUM(), 
       AVG(), 
       VAR(), STD()
FROM accounts;
```
注意sql中没有中位数median的函数  
EXERCISE  
得到以下表格  
![image](https://user-images.githubusercontent.com/105503216/176908062-83291e93-b0fd-4209-8e98-e1c607bac33b.png)
``` sql
SELECT 'First half of 2019' AS data_range, 
        SUM(invoice_total) AS total_sales,
        SUM(payment_total) AS total_payments,
        SUM(invoice_total) - SUM(payment_total) AS what_we_expect   # 注意这里不能用alias
FROM invoices
WHERE invoice_date BETWEEN '2019-01-01' AND '2019-06-30'
UNION
SELECT 'Second half of 2019' AS data_range, 
        SUM(invoice_total) AS total_sales,
        SUM(payment_total) AS total_payments,
        SUM(invoice_total) - SUM(payment_total) AS what_we_expect   
FROM invoices
WHERE invoice_date BETWEEN '2019-07-01' AND '2019-12-31'
UNION
SELECT 'Total' AS data_range, 
        SUM(invoice_total) AS total_sales,
        SUM(payment_total) AS total_payments,
        SUM(invoice_total) - SUM(payment_total) AS what_we_expect  
FROM invoices
WHERE invoice_date BETWEEN '2019-01-01' AND '2019-12-31';
``` 

## The GROUP BY statement
GROUP BY clause is after FROM and WHERE, before ORDER BY
``` sql
SELECT
    client_id,
    SUM(invoice_total) AS total_sales
FROM invoices
WHERE invoice_date >= '2019-07-01'
GROUP BY client_id
ORDER BY total_sales DESC                # 注意这里是可以用alias的
```
Multiple columns grouping example
``` sql
SELECT
    state,
    city,
    SUM(invoice_total) AS total_sales
FROM invoices i
JOIN clients USING (client_id)
GROUP BY state, city
```

## The HAVING statement
HAVING clause used after GROUP BY clause as a selecting condition  
HAVING clause filters data after grouping, WHERE clause filters data before grouping
``` sql
SELECT
    client_id,
    SUM(invoice_total) AS total_sales
FROM invoices
GROUP BY client_id
HAVING total_sales > 500
```
Conditions can be one or more, but the columns must be in SELECT clause(different from WHERE clause)
``` sql
SELECT
    client_id,
    SUM(invoice_total) AS total_sales,
    COUNT(*) AS number_of_invoice
FROM invoices
GROUP BY client_id
HAVING total_sales > 500 AND number_of_invoice > 5
```

## The WITH ROLLUP operator 最后一行求一个汇总 
**注意必须要求有GROUP BY**
WITH ROLLUP: One extra rows to summarize the entire results set
``` sql
USE sql_invoicing;

SELECT
    client_id,
    SUM(invoice_total) AS total_sales
FROM invoices i
GROUP BY client_id WITH ROLLUP
```
![image](https://user-images.githubusercontent.com/105503216/176917838-fc024c08-8693-43a4-a5c3-6d05e7aef7d0.png)  
多个columns的分组
``` sql
USE sql_invoicing;
SELECT
    state,
    city,
    SUM(invoice_total) AS total_sales
FROM invoices i
JOIN clients c USING (client_id)
GROUP BY state,city WITH ROLLUP      # 写在多个分组的最后 只要写一次就可以了
```
![image](https://user-images.githubusercontent.com/105503216/176918218-6400a158-1299-4ae6-91cc-f5fe320af08d.png)  

## The SUM...OVER... operator 累加求和
Cum(ulative) sum 不断地累计求和  
如果不使用OVER就只会有一行总和
``` sql
# calculate the cum sum of standard_qty
# from the oldest to newest

SELECT SUM(standard_qty) OVER (ORDER BY occurred_at) AS cum_sum
FROM orders;
```
![图片2](https://user-images.githubusercontent.com/105503216/176368932-1a0c54d4-dc9a-4a71-a60e-0ba808b20ad0.png)  

## The NTILE operator 几等分点 结果是组别数
``` sql
SELECT account_id, occurred_at, standard_qty, 
       NTILE(4) OVER (ORDER BY standard_qty) AS quartile,         # 根据standard_qty从小到大排序分组
       NTILE(5) OVER (ORDER BY standard_qty) AS quintile,
       NTILE(2) OVER (ORDER BY standard_qty) AS median,
       NTILE(100) OVER (ORDER BY standard_qty) AS percentile
FROM orders；

# 也可以把(ORDER BY standard_qty)直接赋值alias代替
SELECT account_id, occurred_at, standard_qty, 
       NTILE(4) OVER a AS quartile,
       NTILE(5) OVER a AS quintile,
       NTILE(2) OVER a AS median,
       NTILE(100) OVER a AS percentile
FROM orders
WINDOW a AS (ORDER BY standard_qty);
```
![1](https://user-images.githubusercontent.com/105503216/176344637-6020c4aa-4e85-4879-8a0f-ed4ea70b6bf9.png)  
是奇数个的话，小的那一半比较多
``` sql
SELECT *, NTILE(2) OVER (ORDER BY stateid) AS median
FROM state;
```
![图片3](https://user-images.githubusercontent.com/105503216/176370045-53f954ad-0770-470a-9626-d19ee79ff1e7.png)  
如何得到NTILE之后具体的值 譬如standard_qty每分位上的数具体是多少
``` sql
WITH event AS
(SELECT account_id, occurred_at, standard_qty, 
       NTILE(2) OVER (ORDER BY standard_qty) AS median
FROM orders)

SELECT DISTINCT median, MAX(standard_qty)
FROM event
GROUP BY median
ORDER BY median
```
![图片5](https://user-images.githubusercontent.com/105503216/176373692-40443b75-2718-4733-afa4-2f8657653699.png)


## The ROW_NUMBER & RANK & DENSE_RANK operator 排序\排名
row_number仅仅是从1-n的列一下行名 不会有重复的
``` sql
SELECT account_id, occurred_at, ROW_NUMBER() OVER (ORDER BY occurred_at) AS rownumber
FROM orders
ORDER BY occurred_at;
```
![图片6](https://user-images.githubusercontent.com/105503216/176376186-92e58f96-b8e2-459c-b322-97ac2496e656.png)  
RANK是在按照数值排名  
如果是相同的值，会显示同样的排名，但是后面的rank会skip
``` sql
# for each account, sales rank for each order

SELECT id, account_id, total, RANK() OVER (PARTITION BY account_id ORDER BY total DESC) AS ranking
FROM orders
ORDER BY account_id, total DESC;
```
![图片8](https://user-images.githubusercontent.com/105503216/176385928-ec3f3659-5ea7-432f-9594-f58f2da569fb.png)  
而DENSE_RANK不会skip掉前面并列的
``` sql
#????
```

## The PARTITION BY operation 分组进行
NTILE结合PARTITION BY, 在每一个组里分成12345份
``` sql
# get quartile of standard_qty for each account
# the columns should be account_id, occured_at, standard_qty, quartile rank

SELECT account_id, occured_at, standard_qty, 
       NTILE(4) OVER (PARTITION BY account_id ORDER BY standard_qty) AS standard_qty_quartile  # 先按照account_id分组 在每一组里 顺序是按照standard_qty从小到大来的
FROM orders
ORDER BY account_id, standard_qty;                                                             # 这是在显示的时候
```
![图片4](https://user-images.githubusercontent.com/105503216/176373858-09af4116-89fe-46e8-a634-59ab2005e2ec.png)
