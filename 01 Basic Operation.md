# Chapter1 Basic Operation
## Create connection
![sql](https://user-images.githubusercontent.com/105503216/176116146-65f9a0ff-7b0e-4ffc-a4c9-c4a039de97f2.png)

## Create schema(database)
``` sql
CREATE SCHEMA CRM_review;
```

## Create table
### 本地文件中直接导入  
![2](https://user-images.githubusercontent.com/105503216/176120993-f09c60cf-1bcf-4188-a939-ed23cd2b4e4d.png)
### 纯手动创建  
``` sql
CREATE TABLE web_events (id INTEGER AUTO_INCREMENT PRIMARY KEY,     # 列名, data type, 自动增量，作为主键
			 stu_num CHAR(11)                           # 数字形式表示文本内容  
                         account_id INTEGER NOT NULL,               # 非0
                         occurred_at TIMESTAMP,                     # 时间戳
                         channel VARCHAR(15)                        # 长度为15个字节的可变长度且非Unicode的字符数据
			 intro TEXT			            # 通常用于长段文字
);

INSERT INTO web_events VALUES (1, 1001, '2015-06-07 17:22:12', 'direct');    # 一行一行地插入
INSERT INTO web_events VALUES (2, 1001, '2015-02-03 14:03:12', 'direct');
```
### 从其他table中提取创建
可以通过此种方式完整copy  
需要注意的是 会ignore some attributes(Primary Key, Auto Increment) when copy
``` sql
CREATE TABLE orders_archived AS
SELECT * FROM orders
```
也可以只提取几列 或者是几列具有特定属性的几行
``` sql
CREATE TABLE IF NOT EXISTS orders1 AS 
SELECT id, account_id 
FROM orders                              # 从orders这个table中提取所需列
WHERE gloss_qty > 10;
```

## Delete table
``` sql
DROP TABLE IF EXISTS web-events;

DROP TABLE IF EXISTS temp1, temp2;                # 删除多个table
```
保留这个table以及列名 但是把所有量都删除 并且重置自增主键  
``` sql
TRUNCATE TABLE web_events;
```
![QQ图片20220701125011](https://user-images.githubusercontent.com/105503216/176825656-0f25c857-6593-4e49-993c-9ba04041ff63.jpg)


## Attributes 查看特征
如果设置了NN 那么在添加新行的时候 必须添加该列的数据 否则会报错  
![11](https://user-images.githubusercontent.com/60777462/167370604-d064914f-7570-425a-b2c2-5d211f343814.png)

## Update table
### 01 改变行
#### 改变一行
``` sql
UPDATE orders1
SET account_id = 1000
WHERE id = 10;
```
EXAMPLE: 性别互换
``` sql
UPDATE Salary
SET sex = 
	CASE sex 
		WHEN 'm' THEN 'f'
		ELSE 'm' END;
```
#### 改变多行  
MySQLWorkbench -> Preferences -> SQL editor(bottom) -> Untick safe update  
EXERCISE
``` sql
# 选择customers这个table中所有point大于3000的customers 
# 把他们在orders这个table中的comment改成golden customer

UPDATE orders
SET comment = 'golden customer'
WHERE customer_id IN              # 注意这里用的是IN哦 表示只要customer = 其中的任意一个值 就可以改变
(SELECT customer_id 
FROM customers
WHERE point > 3000)
```
#### 使用别的表格中的数据
``` sql
UPDATE table1
JOIN table2
ON table1.id = table2.id
SET table1.income = table2.income,
table1.education = table2.education；
```

### 02 删除行
``` sql
DELETE FROM orders1
WHERE id < 10;
```

### 03 插入新的行 
#### 在原table的下面插入另外一个table的值  
row增加 column不变  
必要条件：column数相同
``` sql
INSERT INTO table2                # 此时table1和table2都是5列
SELECT * FROM table1
WHERE customer_id < 100;
```
column列数不相同时 一定要选择对应的列 否则会报错
输出结果除了对应的列 其余全是null
``` sql
INSERT INTO table2 (customer_name, city, country)     # 此时是3对3      
SELECT supplier_name, city, country
FROM table1
WHERE customer_id < 100;
```
#### 手动加入新的值
当输入的值的数量 和 表实际的列的数量相同时 可以不写列名   
类似于创建表格时候的操作
``` sql
INSERT INTO web_events VALUES (1, 1001, '2015-06-07 17:22:12', 'direct'),
                              (2, 1001, '2015-02-03 14:03:12', 'direct');
``` 
当输入的值的数量 和 表实际的列的数量不同时 必须写上对应的列名  
没有写列名的部分只要不有 NOT NULL的特性 都会自动生成NULL值  
否则会报错
``` sql
INSERT INTO products (name, quantity_in_stock, unit_price)         # 对应列插入对应数值 如果不写就是直接一一对应
VALUES ('Product1', 10, 1.95),                                     # 这里可以不用一次次写INSERT INTO xx VALUES xx，直接，连接就可以了
       ('Product2', 11, 1.95),
       ('Product1', 12, 1.95)
```

### 04 加入新列
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

### 05 删除列
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

## The LAST_INSERT_ID() operator 返回上一个插入的ID  
当只插入一行时
``` sql
CREATE TABLE tbl (
    id INT AUTO_INCREMENT PRIMARY KEY,      # 这里标注了自动增量
    description VARCHAR(250) NOT NULL
);

INSERT INTO tbl(description)
VALUES('MySQL last_insert_id'); 

SELECT LAST_INSERT_ID() AS lastid；         # 注意这里不需要FROM

---
lastid
1                                           # 表明自动生产的ID是1
```
当同时插入多行时 返回的依然是插入的第一行的ID
``` sql
INSERT INTO tbl(description)
VALUES('record 1'),
      ('record 2'),
      ('record 3');

SELECT LAST_INSERT_ID() AS lastid;

---
lastid
2

# 继续操作
INSERT INTO tbl(description)
VALUES('record 1'),
      ('record 2'),
      ('record 3');

SELECT LAST_INSERT_ID() AS lastid;

---
lastid
5
```
注意以上的操作中的PRIMARY KEY都是通过AUTO INCREMENT自动生成的  
如果是手动加入的PRIMARY KEY 则无法获取到LAST_INSERT_ID()  
返回的结果会是之前自动生成的PRIMARY KEY
``` sql
INSERT INTO tbl VALUES (2,'ZZX'), (5, 'JXL'), (4, 'ZYW')
SELECT LAST_INSERT_ID() AS lastid;

---
lastid
5
```
