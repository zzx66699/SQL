# 创建connection
![sql](https://user-images.githubusercontent.com/105503216/176116146-65f9a0ff-7b0e-4ffc-a4c9-c4a039de97f2.png)

# 创建schema(database)
``` sql
CREATE SCHEMA CRM-review;
```
# 创建table
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
CREATE TABLE orders1 AS 
SELECT id, account_id 
FROM orders                              # 从orders这个table中提取所需列
WHERE gloss_qty > 10;
```

# 删除table
``` sql
DROP TABLE web-events;

DROP TABLE temp1, temp2;                # 删除多个table
```

# update table
