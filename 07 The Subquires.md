# Chapter7 The Subquires
## Subqueires in SELECT
按列来看 前面几列已经列好了  
需要对应着前面几列每一行的值 来生成后面的列每一行的值
EXERCISE1  
![image](https://user-images.githubusercontent.com/105503216/176983376-db301420-2678-4552-a306-7e334b318efd.png)  
其中client表是  
![image](https://user-images.githubusercontent.com/105503216/176984049-b71f1ebd-21e8-4663-8959-03c337cb4d58.png)  
表invoices是  
![image](https://user-images.githubusercontent.com/105503216/176984413-2e9205c3-aace-4b25-859c-51b947faa42b.png)
``` sql
# 对于client这个表，求出每个client的total_sales，所有clientd的total_sales均值，以及他们的差

SELECT client_id, 
       name, 
	(SELECT SUM(invoice_total) 
        FROM invoices i
        WHERE i.client_id = c.client_id) AS total_sales,      # 这里是给这个子句一个alias
       (SELECT AVG(invoice_total) FROM invoices) AS average,
	(SELECT total_sales - average) AS difference
FROM clients c;
```
![image](https://user-images.githubusercontent.com/105503216/176984057-627bb133-c486-4643-9884-e61e014695a8.png)  
EXERCISE2  
![image](https://user-images.githubusercontent.com/105503216/176984376-433c81f3-c434-4f1b-bf2e-ce2d226120b3.png)  
``` sql

```
