# Chapter10 SUM判断
## 01
<img width="495" alt="image" src="https://user-images.githubusercontent.com/105503216/178263367-bce590bc-0496-4afb-a459-be41cce7016d.png">  

``` sql
WITH sub1 AS(
SELECT u.user_id AS buyer_id, COUNT(*) AS orders_in_2019    # 有些user可能在2019年没有作为买家 在这里会直接被删去
FROM Users u
JOIN Orders o
ON u.user_id = o.buyer_id
WHERE YEAR(o.order_date) = 2019 
GROUP BY buyer_id)

SELECT u.user_id AS buyer_id,                              # 所以需要在这个表中进行一个合并
    u.join_date,
    IFNULL(orders_in_2019,0) AS orders_in_2019
FROM Users u
LEFT JOIN sub1 
ON u.user_id = sub1.buyer_id;
```  

更方便的做法  

``` sql
select 
	user_id buyer_id, 
	join_date,
	sum(if(year(order_date)='2019',1,0)) orders_in_2019     # 使用SUM()函数就可以直接判断了 而不像WHERE要舍去
from users u
left join orders o
on u.user_id = o.buyer_id
group by user_id
```

## 02
<img width="678" alt="image" src="https://user-images.githubusercontent.com/105503216/178999046-ce3c40b2-d0ba-4f60-bda6-baea01d9cb96.png">

``` sql
SELECT u.device_id,
    u.university,
    SUM(IF(MONTH(q.date)=8,1,0)) AS question_cnt,  # 这个不能放在WHERE里 否则会把没在8月份做题的人都删去了
    SUM(IF(q.result='right' AND MONTH(q.date)=8,1,0)) AS right_question_cnt
FROM user_profile u
LEFT JOIN question_practice_detail q
ON u.device_id = q.device_id
WHERE u.university = '复旦大学'  # 注意WHERE一定要在JOIN之后 所有不是复旦的都不要
GROUP BY u.device_id;
```

## 03
现在有一个table记录了用户的购买行为 其中可能会有重复购买  
现在要求每一个产品的复购率 = 重复购买的人数 / 购买的总人数

``` sql
SELECT product_id, SUM(if_repurchase) / COUNT(*)
FROM
(SELECT uid, product_id, 
	CASE WHEN COUNT(*) THEN 1 ELSE 0 END AS if_repurchase
FROM table1
GROUP BY uid, product_id) sub1
GROUP BY product_id
```

按照人和产品分组  
判断每一个人是不是重复购买的 如果是 就写1 不是写0 得出来一个人和产品不重复的表  
再按照产品分组
很容易求出每个产品有多少个人购买 以及有多少人重复购买  
