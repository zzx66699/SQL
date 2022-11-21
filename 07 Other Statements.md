# Chapter7 Other Statements
## 1. Temporary table 
 A temporary table is a database table that is created and exists temporarily on a database server.  
 
### 1.1 WITH clause
```sql
WITH 
    sub AS (
        SELECT 
            COUNT(*) AS total_events,
            channel
        FROM 
            web_events
        GROUP BY 
            channel, 
            LEFT(occurred_at, 10)
    )

SELECT 
    channel, 
    AVG(total_events) AS avg_events
FROM 
    sub
GROUP BY 
    channel;
```

多个WITH之间加上, 且不重复使用WITH

``` sql
WITH 
    table1 AS (
        SELECT * 
        FROM 
            web_events
    ),
     table2 AS (
        SELECT * 
        FROM 
            accounts
    )
     
SELECT *
FROM 
    table1
JOIN
    table2
ON table1.account_id = table2.id;
```

## 2. UNION & UNION ALL 
UNION: 会删去重复的行   
UNION ALL: 不会删去重复的行  

### 2.1 UNION之后可以直接排序 把两个一起排序
``` sql
SELECT 
    e.employee_id AS employee_id
FROM 
    Employees e
LEFT JOIN Salaries s USING (employee_id)
WHERE
    s.salary IS NULL

UNION 

SELECT 
    s.employee_id AS employee_id
FROM 
    Employees e
RIGHT JOIN 
    Salaries s USING (employee_id)
WHERE 
    e.name IS NULL
ORDER BY 
    employee_id;
```

### 2.2 如果想分别排序 必须在外面套一层SELECT

``` sql
# order by不能直接出现在union的子句中，但是可以出现在子句的子句中。所以在外面再套一层
SELECT * 
FROM 
    (SELECT 
        exam_id AS tid, 
        COUNT(DISTINCT uid) AS uv, 
        COUNT(*) AS pv
    FROM 
        exam_record
    GROUP BY 
        exam_id
    ORDER BY 
        uv DESC, 
        pv DESC
    ) sub1

UNION ALL 

SELECT * 
FROM
    (SELECT 
        question_id AS tid, 
        COUNT(DISTINCT uid) AS uv, 
        COUNT(*) AS pv
    FROM 
        practice_record
    GROUP BY 
        question_id
    ORDER BY 
        uv DESC, 
        pv DESC
    ) sub1
```
