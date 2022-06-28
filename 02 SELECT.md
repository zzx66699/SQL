# The SELECT Clause
AS: set the name of columns.
``` sql
USE crmreview;

SELECT id, 
       10 AS number,                                                                                # 一列叫做number 全是10
       gloss_qty + poster_qty + 100 AS qty,                                                         # 对原本序列的运算
       orders.*                                                                                     # orders这个table里的所有列 这点在多个表合并的时候很常用
FROM orders
```

# The DISTINCT operator
exclude duplicates.
``` sql    
SELECT DISTINCT total                                                                               # 只有unique的值
FROM orders
```

# The CASE WHEN ... THEN ... operator 条件
``` sql
SELECT CASE WHEN total_amount > 3000 THEN 'large'                                                   # 只有一次WHEN
            ELSE 'small' 
       END AS levels,                                                                               # 命名为levels
       
       CASE WHEN toal >= 2000 THEN 'at least 2000'                                                  # 好几次WHEN
            WHEN total < 2000 AND total >= 1000 TEHN 'between 1000 and 2000'                        # 两个条件用AND连结
            ELSE 'less than 1000' 
       END AS order_category,
FROM orders
```

# The RIGHT & LEFT operator 左右取值
``` sql
SELECT LEFT(name, 3)        # 取name这一列每一行值的前3个字符
FROM accounts;
```

# The STRPOS & POSITION operator 位置
返回在a里b的index：STRPOS(a,b) 或者 POSITION(B IN A)
``` sql
SELECT POSITION(' ' IN primary_poc) AS position     # 在primary_poc中空格的位置
FROM accounts;
```

# The TRIM operator 删去前后的空格
``` sql
SELECT TRIM('    EHUI&U2  ') AS result;
```

# The LOWER & UPPER operator 大小写
``` sql
SELECT LOWER(name)
FROM accounts;
```

# The LENGTH operator 长度
``` sql
SELECT LENGTH(website)
FROM accounts;
```

# The SUBSTR operator 截取一部分
SUBSTR(TEXT, START, LENGTH)
``` sql
SELECT SUBSTR('ZZX XIXI HAHA', 3,5) AS result;

---
result
X XIX
```

# EXERCISE
01  
What are the different channels used by account 1001?  
Your final table should have two columns: account name and channel 
``` sql
SELECT DISTINCT a.name account_name, w.channel channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE a.id = 1001;
```
