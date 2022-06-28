# Create connection
![sql](https://user-images.githubusercontent.com/105503216/176116146-65f9a0ff-7b0e-4ffc-a4c9-c4a039de97f2.png)

# Create schema(database)
``` sql
CREATE SCHEMA CRM-review;
```
# Create table
## 本地文件中直接导入
![2](https://user-images.githubusercontent.com/105503216/176120993-f09c60cf-1bcf-4188-a939-ed23cd2b4e4d.png)
## 纯手动创建
``` sql
CREATE TABLE web_events (                      # table name是web_events
             id integer PRIMARY KEY,           #  列名, data type,  作为主键
             account_id integer,
             occurred_at timestamp,
             channel varchar(15)               # 长度为15个字节的可变长度且非Unicode的字符数据
);

INSERT INTO web_events VALUES (1, 1001, '2015-06-07 17:22:12', 'direct');    # 一行一行地插入
INSERT INTO web_events VALUES (2, 1001, '2015-02-03 14:03:12', 'direct');
```
## 从其他table中提取创建
``` sql
CREATE TABLE IF NOT EXISTS orders1 AS 
SELECT id, account_id 
FROM orders                              # 从orders这个table中提取所需列
WHERE gloss_qty > 10;
```

# Delete table
``` sql
DROP TABLE IF EXISTS web-events;

DROP TABLE IF EXISTS temp1, temp2;                # 删除多个table
```

# Update table
## 01 改变行
改变一行
``` sql
UPDATE orders1
SET account_id = 1000
WHERE id = 10;
```
改变多行  
![1](https://user-images.githubusercontent.com/105503216/176135969-c9ae2774-3cf0-4798-b761-d937da68503a.png)
使用别的表格中的数据
``` sql
UPDATE table1
JOIN table2
ON table1.id = table2.id
SET table1.income = table2.income,
table1.education = table2.education
```
## 02 删除行
``` sql
DELETE FROM orders1
WHERE id < 10;
```
## 03 插入新的行 在原table的下面插入另外一个table的值  
row增加 column不变  
必要条件：column数相同
``` sql
INSERT INTO table2                # 此时table1和table2都是5列
SELECT * FROM table1
WHERE customer_id < 100;
```
column列数不相同时 要选择对应的列    
输出结果除了对应的列 其余全是null
``` sql
INSERT INTO table2 (customer_name, city, country)     # 此时是3对3      
SELECT supplier_name, city, country
FROM table1
WHERE customer_id < 100;
```

## 04 加入新列
``` sql
ALTER TABLE table1
ADD birthday DATE;       # 插入一列叫birthday 数据类型是DATE
```
同时加入好几列
``` sql
ALTER TABLE table1
ADD HH_Pre_Tax_Income TEXT, 
ADD M_Edu_Level TEXT, 
ADD F_Edu_Level TEXT, 
ADD M_Occupation TEXT,
ADD F_Occupation TEXT;
```

## 05 删除列
``` sql
ALTER TABLE table1
DROP birthday;
```
同时删除多列
``` sql
ALTER TABLE table1
DROP birthday,
DROP total;
```
