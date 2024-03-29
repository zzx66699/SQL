# Chapter4 GROUP BY Statement 

## 1. The GROUP BY statement
注意group_by是可以用select里面的alias的！！！！  
只有where不可以！！  
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

### COUNT(a)在a的值为null的时候会算0  
<img width="476" alt="image" src="https://user-images.githubusercontent.com/105503216/180939647-ffd67d2d-e039-46a7-ad31-b2e2dd9709b1.png">    
求每一个product有多少订单  

``` sql
SELECT prod_name, COUNT(order_num) AS orders    # 一定要COUNT那一列 而不能用* 
FROM Products p
LEFT JOIN OrderItems o
ON p.prod_id = o.prod_id
GROUP BY prod_name       # 不能用id
ORDER BY prod_name;
```

###  COUNT() GROUP BY A 在A里有null值的时候会计算null值的个数
``` python
SELECT c.name AS source, COUNT(*) AS cnt
FROM order_info o
LEFT JOIN client c
ON o.client_id = c.id
GROUP BY source
ORDER BY source;
```
<img width="522" alt="image" src="https://user-images.githubusercontent.com/105503216/182996257-8b7b6c41-59cf-4a32-a30d-267d5e25b89e.png">  
所以一般用IFNULL(c.name, 'xx')转化成对应量

### SUM(a)在a的值为null的时候会当成0自动略过 
如果有其他数据 null那一列当作0 正常输出sum的值    
如果没有其他数据 那么输出null  
<img width="209" alt="截屏2022-07-26 下午3 02 42" src="https://user-images.githubusercontent.com/105503216/180944312-1e070b86-1bab-4f28-8332-4bfc456da368.png">

``` sql
SELECT difficult_level, SUM(question_id)
FROM question_detail
GROUP BY difficult_level;
```
<img width="224" alt="image" src="https://user-images.githubusercontent.com/105503216/180944398-9a48bb29-43e1-42eb-ad6f-85901cb29d48.png">  



EXERCISE  
得到以下表格  
![image](https://user-images.githubusercontent.com/105503216/176908062-83291e93-b0fd-4209-8e98-e1c607bac33b.png)
``` sql
SELECT 'First half of 2019' AS data_range, 
        SUM(invoice_total) AS total_sales,
        SUM(payment_total) AS total_payments,
        SUM(invoice_total) - SUM(payment_total) AS what_we_expect   # 注意表达式中不能使用列的别名 
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

### 几个用法区分
1.如果a和b一一对应 group by a order by b b要么用聚合函数 要么group by a,b      
<img width="520" alt="image" src="https://user-images.githubusercontent.com/105503216/183277193-89a2dd0b-fefb-4073-b50f-d13964904ab2.png">  
或者  
<img width="273" alt="image" src="https://user-images.githubusercontent.com/105503216/183281489-0fdcc2cc-840f-4d9c-8ba2-d3c5f9e11439.png">  
千万不要select name ... group by id 这样很容易出错的




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

求平均数
``` sql
SELECT IFNULL(driver_id,'总体'), ROUND(AVG(grade),1) AS avg_grade  # 这里注意填充“总体”
FROM tb_get_car_order
WHERE driver_id IN 
(SELECT driver_id
FROM tb_get_car_order
WHERE DATE_FORMAT(finish_time, '%Y-%m') = '2021-10' AND
    start_time IS NULL)
GROUP BY driver_id WITH ROLLUP    # 都是前面平均数 最后也是自动求平均数
```
<img width="231" alt="image" src="https://user-images.githubusercontent.com/105503216/180734817-36e9017a-c953-46c9-b34c-d704121b7af9.png">  

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

### 可以使用SUM..OVER(... rows xx preceding) 来求前几列的sum值
 
``` SQL
SELECT dt, 
    ROUND(SUM(finish_num) OVER (ORDER BY dt rows 6 preceding) / 7,2) AS finish_num_7d,  
    ROUND(SUM(cancel_num) OVER (ORDER BY dt rows 6 preceding) / 7,2) AS cancel_num_7d
FROM
(SELECT DATE(order_time) AS dt,
COUNT(start_time) AS finish_num,
    COUNT(*) - COUNT(start_time) AS cancel_num
FROM tb_get_car_order
WHERE DATE(order_time) BETWEEN '2021-09-25' AND '2021-10-03'
GROUP BY dt) sub1
```

第一行是0，2到6行和真正能开始计算的第7行的值相同  
![image](https://user-images.githubusercontent.com/105503216/184602458-9a3aa43b-70dd-42aa-b52a-687835673326.png)
![image](https://user-images.githubusercontent.com/105503216/184602678-4289e408-b881-42e4-8dec-00ec09907b1c.png)

![image](https://user-images.githubusercontent.com/105503216/184602212-f6c23746-870b-437f-980b-2c12f2a2148e.png)  

``` SQL
SELECT *
FROM
(SELECT dt, 
    ROUND(SUM(finish_num) OVER (ORDER BY dt rows 6 preceding) / 7,2) AS finish_num_7d,
    ROUND(SUM(cancel_num) OVER (ORDER BY dt rows 6 preceding) / 7,2) AS cancel_num_7d
FROM
(SELECT DATE(order_time) AS dt,
COUNT(start_time) AS finish_num,
    COUNT(*) - COUNT(start_time) AS cancel_num
FROM tb_get_car_order
WHERE DATE(order_time) BETWEEN '2021-09-25' AND '2021-10-03'
GROUP BY dt) sub1) sub2
WHERE dt BETWEEN '2021-10-01' AND '2021-10-03'
ORDER BY dt
```

## 关于中位数
### 求位置  
<img width="357" alt="image" src="https://user-images.githubusercontent.com/105503216/183000192-247c1892-0e03-4f0d-99ff-746af3239e5f.png">
<img width="671" alt="image" src="https://user-images.githubusercontent.com/105503216/183000214-cafc6375-4691-439f-9eb9-7a433d3ae4f5.png">  
求位置比较简单 只需要考虑个数就可以  
奇数start和end相同 偶数不同  
ROUND()是四舍五入

``` SQL
SELECT job, 
    ROUND(COUNT(*) / 2) AS start,   # 自动五入进一个数
    ROUND((COUNT(*)+1) / 2) AS end
FROM grade
GROUP BY job
ORDER BY job
```

### 展开的数据 求具体是多少
一列数 从小到大排序 标号 中位数的序号一定处在数量/2 和数量/2+1 之间  
奇数个 比如5个 中位数3 序号在2.5和3.5之间   
偶数个 比如6个 中位数3、4 序号在3和4之间  

<img width="637" alt="image" src="https://user-images.githubusercontent.com/105503216/191709476-4e9a3eb8-6dff-48f0-b0a1-bed68b7a6c59.png">  

``` sql
SELECT id, company, salary
FROM 
(SELECT *, 
    ROW_NUMBER() OVER (PARTITION BY company ORDER BY salary) AS rk,
    COUNT() OVER (PARTITION BY company) AS ct   # 这一步出来的结果 所有company相同的是一个数
FROM Employee) sub1
WHERE rk >= ct/2 AND rk <= ct/2 + 1
```
<img width="233" alt="image" src="https://user-images.githubusercontent.com/105503216/191716404-9eba486f-f231-434b-a408-ca22e3b6ae98.png">


### 合并的数据求是哪个 
<img width="272" alt="image" src="https://user-images.githubusercontent.com/105503216/182999850-3f0c009d-6144-4280-ad47-8be6ee1a1c4d.png"><img width="660" alt="image" src="https://user-images.githubusercontent.com/105503216/182999948-5d66c896-56e8-4047-bec7-f10e88b65ec6.png">  
核心思想：当某一数的正序和逆序累计均大于整个序列的数字个数的一半即为中位数  
``` python
SELECT grade
FROM
(SELECT grade, 
     SUM(number) OVER () AS total,  # 不能直接sum 不然就只有一行了 也可以用sub求一个数
     SUM(number) OVER (ORDER BY grade) AS sum_nb, 
     SUM(number) OVER (ORDER BY grade DESC) AS sum_nb_desc
FROM class_grade) sub1
WHERE sum_nb >= total/2 AND sum_nb_desc >= half_total/2
ORDER BY grade;
```

### The NTILE operator 几等分点 结果是组别数
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
注意！如果列名要是rank，必须加上'rank'  
row_number仅仅是从1-n的列一下行名 不会有重复的
``` sql
SELECT account_id, occurred_at, ROW_NUMBER() OVER (ORDER BY occurred_at) AS rownumber
FROM orders
ORDER BY occurred_at;
```
![图片6](https://user-images.githubusercontent.com/105503216/176376186-92e58f96-b8e2-459c-b322-97ac2496e656.png)  
RANK是在按照数值排名  
1 2 2 4  

``` sql
# for each account, sales rank for each order

SELECT id, account_id, total, RANK() OVER (PARTITION BY account_id ORDER BY total DESC) AS ranking
FROM orders
ORDER BY account_id, total DESC;
```
![图片8](https://user-images.githubusercontent.com/105503216/176385928-ec3f3659-5ea7-432f-9594-f58f2da569fb.png)  
而DENSE_RANK不会skip掉前面并列的   
1 2 2 3  
<img width="535" alt="image" src="https://user-images.githubusercontent.com/105503216/182507605-9755320c-0380-4b84-bb63-7f646123f0a4.png">  


EXERCISE:  
<img width="687" alt="image" src="https://user-images.githubusercontent.com/105503216/181894055-ee260112-f71f-4af7-8102-ea9996393683.png">  
题目中给了很多排序条件，这些条件一定是写在rank的order by之后的，需要写三个：最大、最小、uid 所以思路就是先找到这三个分别是多少  

``` sql
SELECT tag AS tid, uid, rk AS ranking
FROM
(SELECT tag, uid, 
    RANK() OVER (PARTITION BY tag ORDER BY max_score DESC, min_score DESC, uid DESC) AS rk
FROM 
(SELECT tag, uid, MAX(score) AS max_score, MIN(score) AS min_score
FROM examination_info i
JOIN exam_record r
ON i.exam_id = r.exam_id
GROUP BY uid, tag) sub1) sub2
WHERE rk IN (1,2,3)
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

## 使用SUM计数来判断条件是否成立  
EXERCISE1: 筛选只在某个范围中出现的值 -- 既不在前面也不在后面   
<img width="516" alt="image" src="https://user-images.githubusercontent.com/105503216/178410766-5201c0b0-bf0b-45e2-9545-135851946688.png">  
Write an SQL query that reports the products that were only sold in the first quarter of 2019. That is, between 2019-01-01 and 2019-03-31 inclusive.  
Return the result table in any order.  

``` sql
SELECT p.product_id, p.product_name
FROM Product p
JOIN Sales s
ON p.product_id = s.product_id
GROUP BY p.product_id
HAVING SUM(s.sale_date < '2019-01-01')=0 AND      # 即没有在2019-01-01之前卖过
   SUM(s.sale_date > '2019-03-31')=0              # 也没有在2019-03-31之后卖过
```
