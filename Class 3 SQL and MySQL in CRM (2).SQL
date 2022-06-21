--------------------------------------------
-- Lession 4  subqueries 
--------------------------------------------

-- Find the number of events in each day and each channel

SELECT DATE_TRUNC('day',occurred_at) AS day,
       channel, COUNT(*) as events
FROM web_events
GROUP BY 1,2
ORDER BY 3 DESC;

-- create a query that simply produces all the data from your 1st query
SELECT *
FROM (SELECT DATE_TRUNC('day',occurred_at) AS day,
           channel, COUNT(*) as events
     FROM web_events 
     GROUP BY 1,2
     ORDER BY 3 DESC) sub;

-- find the average number of events for each channel  
SELECT channel, AVG(events) AS average_events
FROM (SELECT DATE_TRUNC('day',occurred_at) AS day,
             channel, COUNT(*) as events
      FROM web_events 
      GROUP BY 1,2) sub
GROUP BY channel
ORDER BY 2 DESC;

-- use DATE_TRUNC to pull month info about 1st order ever placed in the orders data
SELECT DATE_TRUNC('month', MIN(occurred_at)) 
FROM orders;

-- then find out only the orders that occur in the previous step and compute the avg orders
SELECT AVG(standard_qty) AS avg_standard,
       AVG(gloss_qty) AS avg_gloss,
       AVG(poster_qty) AS avg_poster, 
       SUM(total_amt_usd) AS total_rev
FROM orders
WHERE DATE_TRUNC('month',occurred_at) =
     (SELECT DATE_TRUNC('month', min(occurred_at))
     FROM orders) ;

-------------------------
-- quiz
---------------------------
-- Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.

-- First, I wanted to find the total_amt_usd totals associated with each sales rep, and I also wanted the region in which they were located. The query below provided this information.
SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY 1,2
ORDER BY 3 DESC;

-- This is equivalent to the following, which, to me, is much clenaer

SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
FROM sales_reps s, accounts a, orders o, region r
WHERE (a.sales_rep_id = s.id) AND
      (o.account_id = a.id)   AND 
      (r.id = s.region_id)
GROUP BY 1,2
ORDER BY 3 DESC;

-- Pull the max for each region, and then use this to pull those rows
SELECT region_name, MAX(total_amt) total_amt
     FROM (SELECT s.name rep_name, r.name region_name, 
                  SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders o
             ON o.account_id = a.id
             JOIN region r
             ON r.id = s.region_id
             GROUP BY 1, 2) t1   -- t1 is subquery name or alias
     GROUP BY 1;
     
-- Essentially, this is a JOIN of these two tables, where the region and amount match.
SELECT t3.rep_name, t3.region_name, t3.total_amt
FROM (SELECT region_name, MAX(total_amt) total_amt
      FROM (SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders o
             ON o.account_id = a.id
             JOIN region r
             ON r.id = s.region_id
             GROUP BY 1, 2) t1
     GROUP BY 1) t2
JOIN (SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
     FROM sales_reps s
     JOIN accounts a
     ON a.sales_rep_id = s.id
     JOIN orders o
     ON o.account_id = a.id
     JOIN region r
     ON r.id = s.region_id
     GROUP BY 1,2
     ORDER BY 3 DESC) t3
ON t3.region_name = t2.region_name AND t3.total_amt = t2.total_amt;

-- For the region with the largest sales total_amt_usd, how many total orders were placed?
-- The first query I wrote was to pull the total_amt_usd for each region.
SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name;

-- Then we just want the region with the max amount from this table. There are two ways I considered getting this amount. One was to pull the max using a subquery. Another way is to order descending and just pull the top value.
SELECT MAX(total_amt)
FROM (SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM sales_reps s
             JOIN accounts a
             ON a.sales_rep_id = s.id
             JOIN orders o
             ON o.account_id = a.id
             JOIN region r
             ON r.id = s.region_id
             GROUP BY r.name) sub;
             
-- Finally, we want to pull the total orders for the region with this amount:
SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (
      SELECT MAX(total_amt)
      FROM (SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
              FROM sales_reps s
              JOIN accounts a
              ON a.sales_rep_id = s.id
              JOIN orders o
              ON o.account_id = a.id
              JOIN region r
              ON r.id = s.region_id
              GROUP BY r.name) sub);
              
-- This provides the Northeast with 2357 orders.

-- How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their lifetime as a customer?
-- First, we want to find the account that had the most standard_qty paper. The query here pulls that account, as well as the total amount:

SELECT a.name account_name, SUM(o.standard_qty) total_std, SUM(o.total) total
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
-- Now, I want to use this to pull all the accounts with more total sales:

SELECT a.name
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY 1
HAVING SUM(o.total) > (SELECT total 
                   FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                         FROM accounts a
                         JOIN orders o
                         ON o.account_id = a.id
                         GROUP BY 1
                         ORDER BY 2 DESC
                         LIMIT 1) sub);

-- This is now a list of all the accounts with more total orders. We can get the count with just another simple subquery.
SELECT COUNT(*)
FROM (SELECT a.name
       FROM orders o
       JOIN accounts a
       ON a.id = o.account_id
       GROUP BY 1
       HAVING SUM(o.total) > (SELECT total 
                   FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                         FROM accounts a
                         JOIN orders o
                         ON o.account_id = a.id
                         GROUP BY 1
                         ORDER BY 2 DESC
                         LIMIT 1) inner_tab)
             ) counter_tab;

-- For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?
-- Here, we first want to pull the customer with the most spent in lifetime value.

SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY 3 DESC
LIMIT 1;

-- Now, we want to look at the number of events on each channel this company had, which we can match with just the id.

SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id
                     FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
                           FROM orders o
                           JOIN accounts a
                           ON a.id = o.account_id
                           GROUP BY a.id, a.name
                           ORDER BY 3 DESC
                           LIMIT 1) inner_table)
GROUP BY 1, 2
ORDER BY 3 DESC;

-- I added an ORDER BY for no real reason, and the account name to assure I was only pulling from one account.
-- What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
-- First, we just want to find the top 10 accounts in terms of highest total_amt_usd.
SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY 3 DESC
LIMIT 10;

-- Now, we just want the average of these 10 amounts.
SELECT AVG(tot_spent)
FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
      FROM orders o
      JOIN accounts a
      ON a.id = o.account_id
      GROUP BY a.id, a.name
      ORDER BY 3 DESC
       LIMIT 10) temp;

-- What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, on average, than the average of all orders.
-- First, we want to pull the average of all accounts in terms of total_amt_usd:
SELECT AVG(o.total_amt_usd) avg_all
FROM orders o

-- Then, we want to only pull the accounts with more than this average amount.
SELECT o.account_id, AVG(o.total_amt_usd)
FROM orders o
GROUP BY 1
HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) avg_all
                               FROM orders o);
-- Finally, we just want the average of these values.
SELECT AVG(avg_amt)
FROM (SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
    FROM orders o
    GROUP BY 1
    HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) avg_all
                                   FROM orders o)) temp_table;

-------------
-- WITH statement to create temp tables
----------
-- find the avg for each day and channel
SELECT channel, AVG(events) AS average_events
FROM (SELECT DAY(occurred_at) AS day,
             channel, COUNT(*) as events
      FROM web_events 
      GROUP BY 1,2) sub
GROUP BY channel
ORDER BY 2 DESC;


-- use WITH 
WITH events AS (
          SELECT DATE_TRUNC('day',occurred_at) AS day, 
                        channel, COUNT(*) as events
          FROM web_events 
          GROUP BY 1,2)

SELECT channel, AVG(events) AS average_events
FROM events
GROUP BY channel
ORDER BY 2 DESC;

-- you can create >1 table with 1 "WITH"
WITH table1 AS (
          SELECT *
          FROM web_events),

     table2 AS (
          SELECT *
          FROM accounts)

SELECT *
FROM table1
JOIN table2
ON table1.account_id = table2.id;

-----------------------------------------
-- WITH quiz and soultion
-----------------------------------------
-- Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.

WITH t1 AS (
        SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
        FROM sales_reps s
        JOIN accounts a
        ON a.sales_rep_id = s.id
        JOIN orders o
        ON o.account_id = a.id
        JOIN region r
        ON r.id = s.region_id
        GROUP BY 1,2
        ORDER BY 3 DESC), 

   t2 AS (
       SELECT region_name, MAX(total_amt) total_amt
       FROM t1
       GROUP BY 1)
       
SELECT t1.rep_name, t1.region_name, t1.total_amt
FROM t1
JOIN t2
ON t1.region_name = t2.region_name AND t1.total_amt = t2.total_amt;

-- For the region with the largest sales total_amt_usd, how many total orders were placed?

WITH t1 AS (
        SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
        FROM sales_reps s
        JOIN accounts a
        ON a.sales_rep_id = s.id
        JOIN orders o
        ON o.account_id = a.id
        JOIN region r
        ON r.id = s.region_id
        GROUP BY r.name), 
   
    t2 AS (
       SELECT MAX(total_amt)
       FROM t1)
   
SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (SELECT * FROM t2);

-- For the account that purchased the most (in total over their lifetime as a customer) standard_qty paper, how many accounts still had more in total purchases?

WITH t1 AS (
        SELECT a.name account_name, SUM(o.standard_qty) total_std, SUM(o.total) total
        FROM accounts a
        JOIN orders o
        ON o.account_id = a.id
        GROUP BY 1
        ORDER BY 2 DESC
        LIMIT 1), 
  
     t2 AS (
       SELECT a.name
       FROM orders o
       JOIN accounts a
       ON a.id = o.account_id
       GROUP BY 1
       HAVING SUM(o.total) > (SELECT total FROM t1))
       
SELECT COUNT(*)
FROM t2;

-- For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?

WITH t1 AS (
        SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
        FROM orders o
        JOIN accounts a
        ON a.id = o.account_id
        GROUP BY a.id, a.name
        ORDER BY 3 DESC
        LIMIT 1)

SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id FROM t1)
GROUP BY 1, 2
ORDER BY 3 DESC;

-- What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?

WITH t1 AS (
        SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
        FROM orders o
        JOIN accounts a
        ON a.id = o.account_id
        GROUP BY a.id, a.name
        ORDER BY 3 DESC
        LIMIT 10)
        
SELECT AVG(tot_spent)
FROM t1;

-- What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, on average, than the average of all orders.

WITH t1 AS (
        SELECT AVG(o.total_amt_usd) avg_all
        FROM orders o
        JOIN accounts a
        ON a.id = o.account_id),
     t2 AS (
        SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
        FROM orders o
        GROUP BY 1
        HAVING AVG(o.total_amt_usd) > (SELECT * FROM t1))
SELECT AVG(avg_amt)
FROM t2;

----------------------
-- data cleaning
---------------------
SELECT first_name, last_name,
       LEFT(phone_number, 3) AS area_code,
       RIGHT(phone_number,8) AS phone_number_only,
       RIGHT(phone_number, LENGTH(phone_number)-4) AS phone_number_alt
FROM customer_data;

-- LEFT & RIGHT Quizzes
-- In the accounts table, there is a column holding the website for each company. The last three digits specify what type of web address they are using. A list of extensions (and pricing) is provided here. Pull these extensions and provide how many of each website type exist in the accounts table.
SELECT RIGHT(website, 3) AS domain, COUNT(*) num_companies
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;

-- There is much debate about how much the name (or even the first letter of a company name) matters. Use the accounts table to pull the first letter of each company name to see the distribution of company names that begin with each letter (or number).
SELECT LEFT(UPPER(name), 1) AS first_letter, COUNT(*) num_companies
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;

-- Use the accounts table and a CASE statement to create two groups: one group of company names that start with a number and a second group of those company names that start with a letter. What proportion of company names start with a letter?
SELECT SUM(num) AS nums, SUM(letter) AS letters
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') 
                       THEN 1 ELSE 0 END AS num, 
                   CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') 
                       THEN 0 ELSE 1 END AS letter
      FROM accounts) t1;

-- Consider vowels as a, e, i, o, and u. What proportion of company names start with a vowel, and what percent start with anything else?
SELECT SUM(vowel) AS vowels, SUM(other) AS others
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U') 
                        THEN 1 ELSE 0 END AS vowel, 
          CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U') 
                       THEN 0 ELSE 1 END AS other
         FROM accounts) t1;

----------------------------------------------------------------------------
-- data clearning with LEFT, RIGHT, LENGTH, STRPOS, POSITION, REPLACE
----------------------------------------------------------------------------
-- Use the accounts table to create first and last name columns 
-- that hold the first and last names for the primary_poc.
SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ') -1 ) first_name, 
       RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name
FROM accounts;

-- Now see if you can do the same thing for every rep name in the sales_reps table. 
-- Again provide first and last name columns.
SELECT LEFT(name, STRPOS(name, ' ') - 1) first_name, 
       RIGHT(name, LENGTH(name) - STRPOS(name, ' ')) last_name
FROM sales_reps;

-- create email address with first name.last name@company.com
SELECT REPLACE(primary_poc, ' ', '.')||'@'||REPLACE(name, ' ', '')||'.com'
FROM accounts
LIMIT 10;

-- create an initial password that can be chcanged after first logging in. 
-- The 1st password will be the 1st letter of the primary_poc's first name (lowercase)
-- then the last letter of their first name (lowercase), 
-- the first letter of their last name (lowercase), 
-- the last letter of their last name (lowercase), 
-- the number of letters in their first name, 
-- the number of letters in their last name, and then the name of the company 
-- they are working with, all capitalized with no spaces.

WITH names AS (
  SELECT 
     LEFT(primary_poc, STRPOS(primary_poc,' ')-1) AS first_name, 
     RIGHT(primary_poc, LENGTH(primary_poc)-STRPOS(primary_poc,' ')) AS last_name, 
     UPPER(REPLACE(name, ' ', '')) as company
FROM accounts)

SELECT LOWER(LEFT(first_name,1) || RIGHT(last_name,1) || LEFT(last_name,1) || RIGHT(first_name,1)) 
      || LENGTH(first_name) || LENGTH(last_name) || company  AS password
FROM names
LIMIT 10;

-- use CAST (::), substr
-- Date format in orig_date: '01/31/2014 08:00:00 AM +0000' 
-- We can use CAST or :: to convert into SQL date

SELECT CAST(RIGHT(LEFT(date,10),4)||'-'||LEFT(date,2)||'-' || RIGHT(LEFT(date,5),2) AS DATE) AS new_date
from sf_crime_data
limit 10;      

-- alternatively    

SELECT date orig_date, (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' || 
                        SUBSTR(date, 4, 2))::DATE AS new_date
FROM sf_crime_data;

---------------------------
-- WINDOWS function
--------------------------
-- cum sum
-- over each order by time

SELECT standard_qty, SUM(standard_qty) OVER (ORDER BY occurred_at) AS running_total
FROM orders;

-- over month: start from 1st order in each month
SELECT standard_qty, DATE_TRUNC('month', occurred_at) AS month,
       SUM(standard_qty) OVER (PARTITION BY DATE_TRUNC('month', occurred_at) 
                               ORDER BY occurred_at) AS running_total_by_month
FROM orders;

------------------------------------
-- ROW_NUMBER, RANK,  DENSE_RANK()
------------------------------------
-- add row no.
SELECT id, account_id, occurred_at,
       ROW_NUMBER() OVER(ORDER BY id) as row_num
FROM orders
--- sales rank by account_id
SELECT id,
       account_id,
       total,
       RANK() OVER (PARTITION BY account_id ORDER BY total DESC) AS total_rank
FROM orders

------------------------
SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK()        OVER (PARTITION BY account_id  ORDER BY DATE_TRUNC('month',occurred_at)) AS dense_rank,
       SUM(standard_qty)   OVER (PARTITION BY account_id  ORDER BY DATE_TRUNC('month',occurred_at)) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id  ORDER BY DATE_TRUNC('month',occurred_at)) AS count_std_qty,
       AVG(standard_qty)   OVER (PARTITION BY account_id  ORDER BY DATE_TRUNC('month',occurred_at)) AS avg_std_qty,
       MIN(standard_qty)   OVER (PARTITION BY account_id  ORDER BY DATE_TRUNC('month',occurred_at)) AS min_std_qty,
       MAX(standard_qty)   OVER (PARTITION BY account_id  ORDER BY DATE_TRUNC('month',occurred_at)) AS max_std_qty
FROM orders

SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK() OVER (PARTITION BY account_id        ) AS dense_rank,
       SUM(standard_qty) OVER (PARTITION BY account_id   ) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id ) AS count_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id   ) AS avg_std_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id   ) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id   ) AS max_std_qty
FROM orders

------
-- use WINDOW alias
SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER   (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS count_total_amt_usd,
       AVG(total_amt_usd) OVER   (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER   (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS min_total_amt_usd,
       MAX(total_amt_usd) OVER   (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS max_total_amt_usd
FROM orders

--- use window alias, must be put after the main SQL syntax

SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd)   OVER   main_window AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER   main_window AS count_total_amt_usd,
       AVG(total_amt_usd)   OVER   main_window AS avg_total_amt_usd,
       MIN(total_amt_usd)   OVER   main_window AS min_total_amt_usd,
       MAX(total_amt_usd)   OVER   main_window AS max_total_amt_usd
FROM orders

WINDOW main_window AS (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at))

----------------------------------
-- LEAD and LAG
-----------------------------------
----------------------------------------------------
-- LAG and LEAD
----------------------------------------------------

SELECT *, 
       Lag(JoiningDate, 1) OVER (ORDER BY JoiningDate) AS EndDate
FROM Employee;

SELECT *, 
       LEAD(JoiningDate, 1) OVER (ORDER BY JoiningDate) AS EndDate
FROM Employee;


SELECT *, Lag(JoiningDate, 1,'1999-09-01') 
          OVER (ORDER BY JoiningDate) AS EndDate
FROM Employee;


SELECT *, Lead(JoiningDate, 1,'2018-01-01') 
          OVER (ORDER BY JoiningDate) AS EndDate
FROM Employee;

-------------------------------------------------------------

SELECT *, 
       Lag(JoiningDate, 2,'1999-09-01') 
       OVER (ORDER BY JoiningDate ASC) AS EndDate
FROM Employee;


SELECT Year, Quarter, Sales, 
       LAG(Sales, 1, 0) OVER (
       ORDER BY Year, Quarter) AS NextQuarterSales
FROM ProductSales;

SELECT Year, Quarter, Sales, 
       LAG(Sales, 1, 0) OVER (PARTITION BY Year
       ORDER BY Year, Quarter) AS NextQuarterSales
FROM ProductSales;

SELECT Year, Quarter, Sales, 
       LEAD(Sales, 1, 0) OVER (PARTITION BY Year
       ORDER BY Year, Quarter) AS NextQuarterSales
FROM ProductSales;


SELECT category_name, month, FORMAT(net_sales,'C','en-US') AS net_sales,
       NTILE(4) OVER (PARTITION BY category_name
                      ORDER BY net_sales DESC
                     ) AS net_sales_group
FROM vw_netsales_2017;


SELECT account_id,
       standard_sum,
       LAG(standard_sum)  OVER (ORDER BY standard_sum) AS lag,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) AS lead,
       standard_sum - LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag_difference,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) - standard_sum AS lead_difference
FROM (
      SELECT account_id,
             SUM(standard_qty) AS standard_sum
      FROM orders 
      GROUP BY 1
     ) sub

------
-- need to have "OVER (ORDER BY ...) 
SELECT occurred_at,
       total_amt_usd,
       LEAD(total_amt_usd) OVER (ORDER BY occurred_at) AS lead,
       LEAD(total_amt_usd) OVER (ORDER BY occurred_at) - total_amt_usd AS lead_difference
FROM orders;

--------------------------------------------------------------------------------
-- NTILE
--------------------------------------------------------------------------------

SELECT
       account_id,
       occurred_at,
       standard_qty,
       NTILE(4)   OVER (ORDER BY standard_qty) AS  quartile,
       NTILE(5)   OVER (ORDER BY standard_qty) AS  quintile,
       NTILE(2)   OVER (ORDER BY standard_qty) AS  median,
       NTILE(100) OVER (ORDER BY standard_qty) AS  percentile
 FROM orders 
 ORDER BY standard_qty DESC;
 


SELECT
     account_id,
     occurred_at,
     standard_qty,
     NTILE(4) OVER (PARTITION BY account_id ORDER BY standard_qty) AS standard_quartile,
     NTILE(5) OVER (PARTITION BY account_id ORDER BY standard_qty) AS standard_quintile,
     NTILE(2) OVER (PARTITION BY account_id ORDER BY standard_qty) AS standard_median,
     NTILE(100) OVER (PARTITION BY account_id ORDER BY standard_qty) AS standard_percentile
     
 FROM orders 
 ORDER BY account_id DESC, standard_quartile;



----------------------------
-- INEQUALITY Join
---------------------------
SELECT accounts.name as account_name,
       accounts.primary_poc as poc_name,
       sales_reps.name as sales_rep_name
  FROM accounts
  LEFT JOIN sales_reps
    ON accounts.sales_rep_id = sales_reps.id
   AND accounts.primary_poc < sales_reps.name
   
SELECT o1.id AS o1_id,
       o1.account_id AS o1_account_id,
       o1.occurred_at AS o1_occurred_at,
       o1.channel AS o1_channel,
       o2.id AS o2_id,
       o2.account_id AS o2_account_id,
       o2.occurred_at AS o2_occurred_at,
       o2.channel AS o2_channel
  FROM web_events o1
  LEFT JOIN web_events o2
   ON o1.id = o2.id
  AND o2.occurred_at > o1.occurred_at
  AND o2.occurred_at <= o1.occurred_at + INTERVAL '28 days'
ORDER BY o1.id, o1.occurred_at

-----
-- UNION
---

SELECT *
FROM accounts 
WHERE name = 'Walmart'
UNION ALL 
SELECT *
FROM accounts
WHERE name = 'Disney';

