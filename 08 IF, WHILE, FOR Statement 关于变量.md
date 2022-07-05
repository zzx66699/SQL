# Chapter8 IF, WHILE, FOR Statement
## 概念介绍：自定义变量
### 1.用户变量
声明和赋值：  
SET @变量名 = 值; 或 SET @变量名 := 值;  
SELECT @变量名 := 值;  
查看变量：  
SELECT @变量名  

EXAMPLE
``` sql
-- 声明两个用户变量 m和n 均赋值1
-- 把m和n相加并赋值给新的变量 sum 显示sum的值

SET @m=1;
SET @n=1;
SET @sum = @m + @n;
SELECT @sum;

---
2
```

### 2.局部变量
需要先声明再赋值 并且仅在定义它的BEGIN/END语句块中有效  
声明:  
DECLARE 变量名 类型 (DEFAULT值)  
赋值（主要用于改变原来的值）：  
SET 变量名 = 值; 或 SET 变量名 := 值;  
SELECT 变量名 := 值;  
SELECT 字段 into 变量名 FROM 表  
查看变量：  
SELECT 变量名  

EXAMPLE
``` sql
-- 声明两个局部变量 m和n 均赋值1
-- 把m和n相加并赋值给新的变量 sum 显示sum的值

DELIMITER $
DROP PROCEDURE IF EXSITS `sumint`$    # 这个是存储过程的名字 如果现在已经有了 就把它删掉重新来 注意这里是`
CREATE PROCEDURE sumint()             # 创建了一个对象/存储过程
BEGIN 
    DECLARE m INT DEFAULT 1;
    DECLARE n INT DEFAULT 1;
    DECLARE sum INT;
    SET sum = m + n;
    SELECT sum
END $
DELIMITER ;
CALL sumint()                         # 调用这个对象

---
2
```

## The IF operator
``` sql

```

## The WHILE operator
``` sql
-- 创建PROCEDURE 插入参数insertCount 数据类型为INT
-- 声明变量 total 和 i，DEFAULT值分别为0和1
-- 用WHILE进行求和运算

DELIMITER $
DROP PROCEDURE IF EXSITS `ex_while`$     
CREATE PROCEDURE ex_while(IN insertCount INT)   # 插入参数 相当于python里面的input()
BEGIN
    DECLARE total INT DEFAULT 0;
    DECLARE i INT DEFAULT 1;
    WHILE i <= insertCount DO
        SET total := total + i;
        SET i = i + 1;
	END WHILE;
    SELECT total;                               # 显示输出total的值
END $
DELIMITER ;
CALL ex_while(100);
```

在循环中加入判断条件  
不管insertcount是多少 只要i超过了11 就不执行了
``` sql
DELIMITER $
DROP PROCEDURE IF EXISTS `ex_while`$     
CREATE PROCEDURE ex_while(IN insertCount INT)   # 插入参数 相当于python里面的input()
BEGIN
    DECLARE total INT DEFAULT 0;
    DECLARE i INT DEFAULT 1;
    a: WHILE i <= insertCount DO                 # 取了个label a
        IF i = 11 THEN LEAVE a；                 # 不管insertcount是多少 只要i超过了11 就不执行了
        END IF;
    SET total := total + i;
    SET i = i + 1;
	END WHILE a;
    SELECT total;
END $
DELIMITER ;
CALL ex_while(100);
```
或者
``` sql
DELIMITER $
DROP PROCEDURE IF EXISTS 'ex_while'     
CREATE PROCEDURE ex_while(IN insertCount INT)   # 插入参数 相当于python里面的input()
BEGIN
    DECLARE total INT DEFAULT 0;
    DECLARE i INT DEFAULT 1;
    a: WHILE i <= insertCount DO                 # 取了个label a
        SET total := total + i;
        SET i = i + 1;
        IF i < 11 THEN ITERATE a;
        ELSE LEAVE a;
        END if;
	END WHILE a;
    SELECT total;
END $
DELIMITER ;
CALL ex_while(100);
```
