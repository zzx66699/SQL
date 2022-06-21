-- SQL Basics
-- SQL JOINS
-- SQL AGGREGATIONS

-- some basic rules
-- SQL is NOT case sensitive
-- Two ways to comment
   -- use ctrl + /
   -- use /* .... */

-- SELECT FROM  

/* The following demonstrates the SELECT statement */   /* This is to add comment */
/*typical SQL block */
SELECT           /* variable names separated by ","      */
FROM             /* file names separated by ","          */
WHERE            /* logical conditions                   */ 
GROUP BY         /* do aagregation                       */
HAVING           /* logical conditions after aggregation */
ORDER BY         /* sort the table by variables          */     
LIMIT            /* limit the # of output                */     


SELECT id, occurred_at                -- columns / variables in "orders"
FROM orders                           -- table name
ORDER BY occurred_at DESC             -- must appear AFTER FROM and BEFORE LIMIT
LIMIT 15;                             -- limit the # of output

-- this is the same as
SELECT id, occurred_at                -- columns / variables in "orders"
FROM orders                           -- table name
ORDER BY 2 DESC             -- must appear AFTER FROM and BEFORE LIMIT
LIMIT 15; 

SELECT id, occurred_at,  total_amt_usd 
FROM orders
ORDER BY occurred_at, total_amt_usd DESC   -- order by 2 variables
LIMIT 20;

SELECT id, occurred_at,  total_amt_usd
FROM orders
ORDER BY 2, 3 DESC                         -- can use numbers (order of appearance in SELECT
LIMIT 20;


--  Write a query to return the 10 earliest orders in the orders table. Include the id, occurred_at, and 
--  total_amt_usd.      /* select several lines and Ctrl + / to comment */

SELECT id, occurred_at, total_amt_usd
FROM orders
ORDER BY occurred_at
LIMIT 10;

-- Write a query to return the top 5 orders in terms of largest total_amt_usd. Include the id, account_id, and total_amt_usd.

SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC 
LIMIT 5;

-- Write a query to return the lowest 20 orders in terms of smallest total_amt_usd. Include the id, account_id, and total_amt_usd.

SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY total_amt_usd
LIMIT 20;

-- Write a query that displays the order ID, account ID, and total dollar amount for all the orders, sorted first by the account ID (in ascending order), and then by the total dollar amount (in descending order).

SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY account_id, total_amt_usd DESC;

-- Now write a query that again displays order ID, account ID, and total dollar amount for each order, but this time sorted first by total dollar amount (in descending order), and then by account ID (in ascending order).

SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC, account_id;


-- Compare the results of these two queries above. How are the results different when you switch the column you sort on first?
-- In query #1, all of the orders for each account ID are grouped together, and then within each of those groupings, the orders appear from the greatest order amount to the least. In query #2, since you sorted by the total dollar amount first, the orders appear from greatest to least regardless of which account ID they were from. Then they are sorted by account ID next. (The secondary sorting by account ID is difficult to see here, since only if there were two orders with equal total dollar amounts would there need to be any sorting by account ID.)

-------------------------------------------------------------------------------------------------------------
-- WHERE 
-------------------------------------------------------------------------------------------------------------

-- Using the WHERE statement, we can display subsets of tables based on conditions that must be met. You can also think of the WHERE command as filtering the data.

-- Common symbols used in WHERE statements include:
-- > (greater than)
-- < (less than)
-- >= (greater than or equal to)
-- <= (less than or equal to)
-- = (equal to)
-- != (not equal to)

-- Pulls the first 5 rows and all columns from the orders table 
-- that have a dollar amount of gloss_amt_usd >= 1000.
SELECT *
FROM orders
WHERE gloss_amt_usd >= 1000
LIMIT 5;

-- Pulls the first 10 rows and all columns from the orders table
-- that have a total_amt_usd less than 500.
SELECT *
FROM orders
WHERE total_amt_usd < 500
LIMIT 10;

-- Pulls the 10 rows and all columns from the orders table
-- that have the largest total_amt_usd and that are less than 500.
SELECT *
FROM orders
WHERE total_amt_usd < 500
ORDER BY total_amt_usd DESC
LIMIT 10;

-------------------------------------------------------------------------------------------------------------
-- WHERE statement with non-numeric data
-------------------------------------------------------------------------------------------------------------

-- The WHERE statement can also be used with non-numeric data. We can use the = and != operators here. You need to be sure to use single quotes (just be careful if you have quotes in the original text) with the text data, not double quotes. Commonly when we are using WHERE with non-numeric data fields, we use the LIKE, NOT, or IN operators.  

-- Filter the accounts table to include the company name, website, and the primary point of contact (primary_poc) just for the Exxon Mobil company in the accounts table.

SELECT name, website, primary_poc
FROM accounts
WHERE name = 'Exxon Mobil';

SELECT name, website, primary_poc
FROM accounts
WHERE name != 'Exxon Mobil'
LIMIT 15;

SELECT name, website, primary_poc
FROM accounts
WHERE name IN ('Exxon Mobil', 'Walmart', 'Apple');

SELECT name, website, primary_poc
FROM accounts
WHERE name NOT IN ('Exxon Mobil', 'Walmart', 'Apple')
LIMIT 15;

SELECT name, website, primary_poc, sales_rep_id
FROM accounts
WHERE name NOT IN ('Exxon Mobil', 'Walmart', 'Apple') AND sales_rep_id >1100
LIMIT 15;

SELECT *
FROM accounts
WHERE name NOT IN ('Exxon Mobil', 'Walmart', 'Apple') and sales_rep_id >1100
LIMIT 15;


/* -------------------------------------------------------------------------------------------------------- */
/*             Derived Columns                                                                           */
/* --------------------------------------------------------------------------------------------------------*/

-- * (Multiplication)
-- + (Addition)
-- - (Subtraction)
-- / (Division)

-- Consider this example:

SELECT id, (standard_amt_usd/total_amt_usd)*100 AS std_percent, total_amt_usd
FROM orders
LIMIT 10;

-- Here we divide the standard paper dollar amount by the total order amount to find the standard paper percent for the order, and use the AS keyword to name this new column "std_percent." You can run this query on the next page if you'd like, to see the output.

-- Create a column that divides the standard_amt_usd by the standard_qty to find the unit price for standard paper for each order. Limit the results to the first 10 orders, and include the id and account_id fields.

SELECT id, 
       account_id, 
       standard_amt_usd/standard_qty AS standard_price
FROM orders
LIMIT 10;

-- Write a query that finds the percentage of revenue that comes from poster paper for each order. You will need to use only the columns that end with _usd. (Try to do this without using the total column.) Display the id and account_id fields also.

SELECT id, 
       account_id, 
       poster_amt_usd / total*100 AS poster_pct
FROM orders
LIMIT 10;

SELECT id, account_id, 
   poster_amt_usd/(standard_amt_usd + gloss_amt_usd + poster_amt_usd) AS post_per
FROM orders
LIMIT 10;

/* ---------------------------------------------------------------------------------------------------------
Introduction to Logical Operators
-----------------------------------------------------------------------------------------------------------*/

-- Logical Operators include:

-- LIKE
-- This allows you to perform operations similar to using WHERE and =, but for cases when you might not know exactly what you are looking for.

-- The LIKE operator is extremely useful for working with text. You will use LIKE within a WHERE clause. The LIKE operator is frequently used with % (wild key). 
-- Use the accounts table to find
--     All the companies whose names start with 'C'.
SELECT name
FROM accounts
WHERE name LIKE 'C%';

--     All companies whose names contain the string 'one' somewhere in the name.
SELECT name
FROM accounts
WHERE name LIKE '%one%';

--     All companies whose names end with 's'.
SELECT name
FROM accounts
WHERE name LIKE '%s';

-- IN and NOT operators
-- This allows you to perform operations similar to using WHERE and =, but for more than one condition.

-- The IN operator is useful for working with both numeric and text columns. This operator allows you to use an =, but for more than one item of that particular column. We can check one, two or many column values for which we want to pull data, but all within the same query. In the upcoming concepts, you will see the OR operator that would also allow us to perform these tasks, but the IN operator is a cleaner way to write these queries.

-- In most SQL environments, although not in our Udacity's classroom, you can use single or double quotation marks - and you may NEED to use double quotation marks if you have an apostrophe within the text you are attempting to pull.

-- In our Udacity SQL workspaces, note you can include an apostrophe by putting two single quotes together. For example, Macy's in our workspace would be 'Macy''s'.

-- NOT
-- This is used with IN and LIKE to select all of the rows NOT LIKE or NOT IN a certain condition.
-- The NOT operator is an extremely useful operator for working with the previous two operators we introduced: IN and LIKE. By specifying NOT LIKE or NOT IN, we can grab all of the rows that do not meet a particular criteria.
-- Questions using IN operator
-- 1. Use the accounts table to find the account name, primary_poc, and sales_rep_id for Walmart, Target, and Nordstrom.

SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name IN ('Walmart', 'Target', 'Nordstrom');

-- Use the web_events table to find all info for individuals contacted via organic or adwords channel
SELECT *
FROM web_events
WHERE channel IN ('organic', 'adwords');

-- Use the web_events table to find all info for individuals not contacted via organic or adwords channel
SELECT *
FROM web_events
WHERE channel NOT IN ('organic', 'adwords');

-- All the companies whose names do not start with 'C'.
SELECT name
FROM accounts
WHERE name NOT LIKE 'C%';

-- All the companies whose names start with 'C'.
SELECT name
FROM accounts
WHERE name LIKE 'C%';

-- All companies whose names do not contain the string 'one' somewhere in the name.
SELECT name
FROM accounts
WHERE name NOT LIKE '%one%';

-- 3. All companies whose names do not end with 's'.
SELECT name
FROM accounts
WHERE name NOT LIKE '%s';

-- AND & BETWEEN
-- These allow you to combine operations where all combined conditions must be true.
-- The AND operator is used within a WHERE statement to consider more than one logical clause at a time. Each time you link a new statement with an AND, you will need to specify the column you are interested in looking at. You may link as many statements as you would like to consider at the same time. This operator works with all of the operations we have seen so far including arithmetic operators (+, *, -, /). LIKE, IN, and NOT logic can also be linked together using the AND operator.

-- BETWEEN Operator
-- Sometimes we can make a cleaner statement using BETWEEN than we can using AND. Particularly this is true when we are using the same column for different parts of our AND statement. In the previous video, we probably should have used BETWEEN.

WHERE column >= 6 AND column <= 10

-- or equivalently:
WHERE column BETWEEN 6 AND 10

-- Questions using AND and BETWEEN operators
--a query that returns all the orders where the standard_qty is > 1000, the poster_qty is 0,
-- and the gloss_qty is 0.
SELECT *
FROM orders
WHERE standard_qty > 1000 AND poster_qty = 0 AND gloss_qty = 0;

-- or
SELECT *
FROM orders
WHERE (standard_qty > 1000) and (poster_qty + gloss_qty) = 0;

-- all the companies whose names do not start with 'C' and do end with 's'.
SELECT name
FROM accounts
WHERE name NOT LIKE 'C%' AND name LIKE '%s';

-- From the orders table, find all gloss_qty between 24 and 29
SELECT occurred_at, gloss_qty 
FROM orders
WHERE gloss_qty BETWEEN 24 AND 29;   --inclusive

-- Use the web_events table to find all info regarding individuals contacted 
-- via the organic or adwords channels, and started their account at any point 
-- in 2016, sorted from newest to oldest.
SELECT *
FROM web_events
WHERE channel IN ('organic', 'adwords') AND occurred_at BETWEEN '2016-01-01' AND '2017-01-01'
ORDER BY occurred_at DESC;

-- or
SELECT *
FROM web_events
WHERE channel IN ('organic', 'adwords') AND (DATE_PART('year', occurred_at) = 2016)
ORDER BY occurred_at DESC;

-- OR
-- This allow you to combine operations where at least one of the combined conditions must be true.

-- Similar to the AND operator, the OR operator can combine multiple statements. Each time you link a new statement with an OR, you will need to specify the column you are interested in looking at. You may link as many statements as you would like to consider at the same time. This operator works with all of the operations we have seen so far including arithmetic operators (+, *, -, /), LIKE, IN, NOT, AND, and BETWEEN logic can all be linked together using the OR operator.

-- When combining multiple of these operations, we frequently might need to use parentheses to assure that logic we want to perform is being executed correctly. The video below shows an example of one of these situations.

-- Questions using the OR operator
-- 1. Find list of orders ids where either gloss_qty or poster_qty is greater than 4000. Only include the id field in the resulting table.
SELECT id
FROM orders
WHERE gloss_qty > 4000 OR poster_qty > 4000;

-- Write a query that returns a list of orders where the standard_qty is zero and either the gloss_qty or poster_qty is over 1000.

SELECT *
FROM orders
WHERE standard_qty = 0 AND (gloss_qty > 1000 OR poster_qty > 1000);

-- Find all the company names that start with a 'C' or 'W', 
-- and the primary contact contains 'ana' or 'Ana', 
-- but it doesn't contain 'eana'.
SELECT *
FROM accounts
WHERE (name LIKE 'C%' OR name LIKE 'W%') 
           AND ((primary_poc LIKE '%ana%' OR primary_poc LIKE '%Ana%') 
           AND primary_poc NOT LIKE '%eana%');
           
           
--  SQL JOIN: working with multiple tables
SELECT orders.*     -- select all columns from orders
FROM orders         -- source table or the 1st table 
JOIN accounts       -- a retlational table or the 2nd table
ON orders.account_id = accounts.id;   -- the relations between the two tables

-- only select 2 columns
SELECT accounts.name, orders.occurred_at
FROM orders
JOIN accounts
ON orders.account_id = accounts.id;

-- This is equivalent to 
SELECT orders.*
FROM orders, accounts
WHERE orders.account_id = accounts.id;

-- select all columns from 1st table
SELECT *
FROM orders
JOIN accounts
ON orders.account_id = accounts.id;

SELECT orders.*
FROM orders
JOIN accounts
ON orders.account_id = accounts.id;

-- Questions
-- 1. SELECT all columns from accounts and orders tables
SELECT orders.*, accounts.*
FROM accounts
JOIN orders
ON accounts.id = orders.account_id;

-- Using alias
SELECT b.*, a.*
FROM accounts a
JOIN orders b
ON a.id = b.account_id;

-- This is equivalent to:

SELECT b.*, a.*
FROM accounts a, orders b
WHERE a.id = b.account_id;

-- Try pulling standard_qty, gloss_qty, and poster_qty from the orders table, and the website and the primary_poc from the accounts table.
SELECT orders.standard_qty, orders.gloss_qty, 
       orders.poster_qty,  accounts.website, 
       accounts.primary_poc
FROM orders
JOIN accounts
ON orders.account_id = accounts.id；

-- it is more convenient to use alias
SELECT a.standard_qty, a.gloss_qty, a.poster_qty, 
       b.website, b.primary_poc
FROM orders a
JOIN accounts b
ON a.account_id = b.id


-- Join > 2 tables
SELECT *
FROM web_events
JOIN accounts
ON web_events.account_id = accounts.id
JOIN orders
ON accounts.id = orders.account_id;

SELECT *
FROM web_events, accounts, orders
WHERE web_events.account_id = accounts.id 
      AND accounts.id = orders.account_id;


-- Alternatively, we can create a SELECT statement that could pull specific columns from any of the three tables. Again, our JOIN holds a table, and ON is a link for our PK to equal the FK.

-- To pull specific columns, the SELECT statement will need to specify the table that you are wishing to pull the column from, as well as the column name. We could pull only three columns in the above by changing the select statement to the below, but maintaining the rest of the JOIN information:

SELECT web_events.channel, accounts.name, orders.total

-- We could continue this same process to link all of the tables if we wanted. For efficiency reasons, we probably don't want to do this unless we actually need information from all of the tables.

-- alias

-- When we JOIN tables together, it is nice to give each table an alias. Frequently an alias is just the first letter of the table name. 

-- Example:
FROM tablename t1
JOIN tablename2 t2;

-- Questions
-- Provide a table for all web_events associated with account name of Walmart. There should be three columns. Be sure to include the primary_poc, time of the event, and the channel for each event. Additionally, you might choose to add a fourth column to assure only Walmart events were chosen.

SELECT a.primary_poc, w.occurred_at, w.channel, a.name
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
WHERE a.name = 'Walmart';

-- Provide a table that provides the region for each sales_rep along with their associated accounts. 
-- Your final table should include 3 columns: region name, sales rep name, and account name. 
-- Sort the accounts alphabetically (A-Z) according to account name.

SELECT r.name region, s.name rep, a.name account
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
ORDER BY a.name;

-- Provide the name for each region for every order, as well as the account name
-- and the unit price they paid (total_amt_usd/total) for the order. 
-- Your final table should have 3 columns: region name, account name, and unit price.
-- A few accounts have 0 for total, so I divided by (total + 0.01) to assure not dividing by zero.

SELECT r.name region, a.name account, 
       o.total_amt_usd/(o.total + 0.01) AS unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id;

-- or, equivalently,
SELECT r.name region, a.name account, 
       o.total_amt_usd/(o.total + 0.01) AS unit_price
FROM region r, sales_reps s, accounts a, orders o
WHERE (s.region_id = r.id) AND (a.sales_rep_id = s.id) AND (o.account_id = a.id);

-- QUESTIONS

-- Provide a table that provides the region for each sales_rep along with their associated accounts. This time only for the Midwest region. Your final table should include three columns: the region name, the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) according to account name.

SELECT r.name region, s.name rep, a.name account
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
WHERE r.name = 'Midwest'
ORDER BY a.name;

-- Provide a table that provides the region for each sales_rep along with their associated accounts. This time only for accounts where the sales rep has a first name starting with S and in the Midwest region. Your final table should include three columns: the region name, the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) according to account name.

SELECT r.name region, s.name rep, a.name account
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
WHERE r.name = 'Midwest' AND s.name LIKE 'S%'
ORDER BY a.name;

-- Provide a table that provides the region for each sales_rep along with their associated accounts. This time only for accounts where the sales rep has a last name starting with K and in the Midwest region. Your final table should include three columns: the region name, the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) according to account name.

SELECT r.name region, s.name rep, a.name account
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
WHERE r.name = 'Midwest' AND s.name LIKE '% K%'
ORDER BY a.name;

-- Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order. However, you should only provide the results if the standard order quantity exceeds 100. Your final table should have 3 columns: region name, account name, and unit price. In order to avoid a division by zero error, adding .01 to the denominator here is helpful total_amt_usd/(total+0.01).

SELECT r.name region, a.name account, o.total_amt_usd/(o.total + 0.01) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
WHERE o.standard_qty > 100;

-- Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order. However, you should only provide the results if the standard order quantity exceeds 100 and the poster order quantity exceeds 50. Your final table should have 3 columns: region name, account name, and unit price. Sort for the smallest unit price first. In order to avoid a division by zero error, adding .01 to the denominator here is helpful (total_amt_usd/(total+0.01).

SELECT r.name region, a.name account, o.total_amt_usd/(o.total + 0.01) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
WHERE o.standard_qty > 100 AND o.poster_qty > 50
ORDER BY unit_price;

-- Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order. However, you should only provide the results if the standard order quantity exceeds 100 and the poster order quantity exceeds 50. Your final table should have 3 columns: region name, account name, and unit price. Sort for the largest unit price first. In order to avoid a division by zero error, adding .01 to the denominator here is helpful (total_amt_usd/(total+0.01).

SELECT r.name region, a.name account, o.total_amt_usd/(o.total + 0.01) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
WHERE o.standard_qty > 100 AND o.poster_qty > 50
ORDER BY unit_price DESC;


-- What are the different channels used by account id 1001? Your final table should have only 2 columns: account name and the different channels. You can try SELECT DISTINCT to narrow down the results to only the unique values.
SELECT DISTINCT a.name, w.channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE a.id = '1001';

-- Find all the orders that occurred in 2015. Your final table should have 4 columns: occurred_at, account name, order total, and order total_amt_usd.
SELECT o.occurred_at, a.name, o.total, o.total_amt_usd
FROM accounts a
JOIN orders o
ON o.account_id = a.id
WHERE o.occurred_at BETWEEN '01-01-2015' AND '01-01-2016'
ORDER BY o.occurred_at DESC;

-------------------------------------------------
-- SQL Aggregations
-------------------------------------------------
-- main aggregation functions
-- count
SELECT COUNT(*) AS no_obs
FROM accounts;

SELECT COUNT(accounts.id) AS id_count
FROM accounts;

SELECT COUNT(primary_poc) AS primary_poc_count   -- exclude NULL
from accounts;

SELECT *
FROM accounts
WHERE primary_poc IS NULL;

-- SUM Questions and Solutions
-- Find the total amount of poster_qty paper, standard_qty paper, total $ amount of sales，
-- average price of standard paper in the orders table.

SELECT SUM(poster_qty) AS total_poster_sales，
       SUM(standard_qty) AS total_standard_sales，
       SUM(total_amt_usd) AS total_dollar_sales，
       SUM(standard_amt_usd)/SUM(standard_qty) AS standard_price_per_unit
FROM orders;

-- Find the total amount for each individual order that was spent on standard and gloss paper in the orders table. 
-- This should give a dollar amount for each order in the table.

SELECT id, standard_amt_usd + gloss_amt_usd AS total_standard_gloss
FROM orders;

--min, max, and avg

-- When was the earliest order ever placed? You only need to return the date.

SELECT MIN(occurred_at) 
FROM orders;

-- Try performing the same query as in question 1 without using an aggregation function.

SELECT occurred_at 
FROM orders 
ORDER BY occurred_at
LIMIT 1;

-- When did the most recent (latest) web_event occur?
SELECT MAX(occurred_at)
FROM web_events;

-- Try to perform the result of the previous query without using an aggregation function.
SELECT occurred_at
FROM web_events
ORDER BY occurred_at DESC
LIMIT 1;

-- Find the mean (AVERAGE) amount spent per order on each paper type, as well as the mean amount of each paper type purchased per order. Your final answer should have 6 values - one for each paper type for the average number of sales, as well as the average amount.

SELECT MAX(occurred_at)   AS last_order,    MIN(occurred_at) AS first_order,
       AVG(standard_qty)  AS mean_standard, AVG(gloss_qty)   AS mean_gloss, 
       AVG(poster_qty)    AS mean_poster,   AVG(standard_amt_usd) AS mean_standard_usd, 
       AVG(gloss_amt_usd) AS mean_gloss_usd, AVG(poster_amt_usd) AS mean_poster_usd
FROM orders;

--  how to calculate the MEDIAN. Though this is more advanced than what we have covered so far try finding - what is the MEDIAN total_usd spent on all orders? Note, this is more advanced than the topics we have covered thus far to build a general solution, but we can hard code a solution in the following way. 

SELECT *
FROM (SELECT total_amt_usd
      FROM orders
      ORDER BY total_amt_usd
      LIMIT 3457) AS Table1       -- There are 6,912 orders, so we limit to half (3457 or 3456)
ORDER BY total_amt_usd DESC       -- reverse the sorting 
LIMIT 2;

-- group by 
-- Which account (by name) placed the earliest order? Your solution should have the account name and the date of the order.
SELECT a.name, o.occurred_at
FROM accounts a
JOIN orders o
ON a.id = o.account_id
ORDER BY occurred_at
LIMIT 1;

-- Find the total sales in usd for each account. You should include two columns - the total sales for each company's orders in usd and the company name.
SELECT a.name, SUM(total_amt_usd) AS total_sales
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.name
ORDER BY a.name DESC;

-- Via what channel did the most recent (latest) web_event occur, which account was associated with this web_event? Your query should return only three values - the date, channel, and account name.
SELECT w.occurred_at, w.channel, a.name
FROM web_events w
JOIN accounts a
ON w.account_id = a.id 
ORDER BY w.occurred_at DESC;

-- Find the total number of times each type of channel from the web_events was used. Your final table should have two columns - the channel and the number of times the channel was used.
SELECT w.channel, COUNT(*)
FROM web_events w
GROUP BY w.channel;

-- Who was the primary contact associated with the earliest web_event?
SELECT a.primary_poc
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
ORDER BY w.occurred_at
LIMIT 1;

-- What was the smallest order placed by each account in terms of total usd. Provide only two columns - the account name and the total usd. Order from smallest dollar amounts to largest.
SELECT a.name, MIN(total_amt_usd) AS smallest_order
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY smallest_order;

-- Sort of strange we have a bunch of orders with no dollars. We might want to look into those.
-- Find the number of sales reps in each region. Your final table should have two columns - the region and the number of sales_reps. Order from fewest reps to most reps.

SELECT r.name, COUNT(*) AS num_reps
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
GROUP BY r.name
ORDER BY num_reps;

-- For each account, determine the average amount of each type of paper they purchased across their orders. 
-- Your result should have four columns - one for the account name and one for the average spent on each of the paper types.

SELECT a.name, AVG(o.standard_qty) avg_stand, AVG(o.gloss_qty) avg_gloss, AVG(o.poster_qty) avg_post
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name;

-- For each account, determine the average amount spent per order on each paper type. 
-- Your result should have four columns - one for the account name and one for the average amount spent on each paper type.

SELECT a.name, AVG(o.standard_amt_usd) AS avg_stand, 
               AVG(o.gloss_amt_usd) AS avg_gloss, 
               AVG(o.poster_amt_usd) avg_post
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY a.name;

-- Determine the number of times a particular channel was used in the web_events table for each sales rep. Your final table should have three columns - the name of the sales rep, the channel, and the number of occurrences. Order your table with the highest number of occurrences first.

SELECT s.name, w.channel, COUNT(*) num_events
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name, w.channel
ORDER BY num_events DESC;

-- Determine the number of times a particular channel was used in the web_events table for each region. Your final table should have three columns - the region name, the channel, and the number of occurrences. Order your table with the highest number of occurrences first.
SELECT r.name, w.channel, COUNT(*) AS num_events
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name, w.channel
ORDER BY num_events DESC;

-- Distinct

-- Use DISTINCT to test if there are any accounts associated with more than one region.

-- The below two queries have the same number of resulting rows (351), so we know that every account is associated with only one region. If each account was associated with more than one region, the first query should have returned more rows than the second query.

SELECT a.id AS "account id", r.id AS "region id", 
       a.name AS "account name", r.name AS "region name"
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON r.id = s.region_id;

SELECT DISTINCT id, name
FROM accounts;

SELECT DISTINCT a.id AS "account id", r.id AS "region id", 
       a.name AS "account name", r.name AS "region name"
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON r.id = s.region_id;

-- Have any sales reps worked on more than one account?

-- Actually all of the sales reps have worked on more than one account. The fewest number of accounts any sales rep works on is 3. There are 50 sales reps, and they all have more than one account. Using DISTINCT in the second query assures that all of the sales reps are accounted for in the first query.

SELECT s.id, s.name, COUNT(*) num_accounts
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
ORDER BY num_accounts;


SELECT DISTINCT id, name
FROM sales_reps;

-- HAVING clause

-- Questions: HAVING
-- How many of the sales reps have more than 5 accounts that they manage?
SELECT DISTINCT sales_rep_id, COUNT(sales_rep_id) AS num_accounts
FROM accounts
GROUP BY sales_rep_id
HAVING COUNT(sales_rep_id) > 5               -- cannot use the alias num_accounts
ORDER BY num_accounts DESC;
    
-- or 

SELECT s.id, s.name, COUNT(*) num_accounts
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
HAVING COUNT(*) > 5
ORDER BY num_accounts;

-- or use subquery
SELECT COUNT(*) num_reps_above5
FROM (SELECT s.id, s.name, COUNT(*) num_accounts
      FROM accounts a
      JOIN sales_reps s
      ON s.id = a.sales_rep_id
      GROUP BY s.id, s.name
      HAVING COUNT(*) > 5
      ORDER BY num_accounts
     ) AS Table1;

-- How many accounts have more than 20 orders?
SELECT a.id, a.name, COUNT(*) num_orders
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING COUNT(*) > 20
ORDER BY num_orders;

-- Which account has the most orders?
SELECT a.id, a.name, COUNT(*) num_orders
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY num_orders DESC
LIMIT 1;

-- Which accounts spent more than 30,000 usd total across all orders?
SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING SUM(o.total_amt_usd) > 30000
ORDER BY total_spent;

-- Which accounts spent less than 1,000 usd total across all orders?
SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING SUM(o.total_amt_usd) < 1000
ORDER BY total_spent;

-- Which account has spent the most with us?
SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY total_spent DESC
LIMIT 1;

-- Which account has spent the least with us?
SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY total_spent
LIMIT 1;

-- Which accounts used facebook as a channel to contact customers more than 6 times?
SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
HAVING COUNT(*) > 6 AND w.channel = 'facebook'
ORDER BY use_of_channel;

-- Which account used facebook most as a channel?
SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE w.channel = 'facebook'
GROUP BY a.id, a.name, w.channel
ORDER BY use_of_channel DESC
LIMIT 1;

-- Which channel was most frequently used by most accounts?
SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
ORDER BY use_of_channel DESC
LIMIT 10;

-- date functions
-- date_trunc, date_part

-- Find the sales in terms of total dollars for all orders in each year, ordered from greatest to least.  
 SELECT DATE_PART('year', occurred_at) ord_year,  SUM(total_amt_usd) total_spent
 FROM orders
 GROUP BY 1
 ORDER BY 2 DESC;

-- Which month did Parch & Posey have the greatest sales in terms of total dollars?  
SELECT DATE_PART('month', occurred_at) ord_month, SUM(total_amt_usd) total_spent
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC; 

-- Which year did Parch & Posey have the greatest sales in terms of total number of orders? A
SELECT DATE_PART('year', occurred_at) ord_year,  COUNT(*) total_sales
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

-- Which month did Parch & Posey have the greatest sales in terms of total number of orders? 
SELECT DATE_PART('month', occurred_at) ord_month, COUNT(*) total_sales
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC; 

-- In which month of which year did Walmart spend the most 
-- on gloss paper in terms of dollars?
SELECT DATE_TRUNC('month', o.occurred_at) AS ord_date, 
       SUM(o.gloss_amt_usd) AS tot_spent
FROM orders o 
JOIN accounts a
ON a.id = o.account_id
WHERE a.name = 'Walmart'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- CASE statement: "if...then..."
SELECT account_id, 
       CASE WHEN standard_qty = 0 OR standard_qty IS NULL THEN 0
            ELSE standard_amt_usd/standard_qty END AS unit_price
FROM orders
LIMIT 10;

------------------------------------------------------
-- CASE statement and AGGREGATION
------------------------------------------------------
-- Write a query to display for each order, the account ID, total amount of the order,
-- and the level of the order - ‘Large’ or ’Small’ - depending on if the order is 
-- $3000 or more, or smaller than $3000.
SELECT account_id, total_amt_usd,
       CASE WHEN total_amt_usd > 3000 THEN 'Large'
       ELSE 'Small' END AS order_level
FROM orders;

-- Write a query to display the number of orders in each of three categories, 
-- based on the total number of items in each order. The three categories are: 
-- 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'.
SELECT CASE WHEN total >= 2000 THEN 'At Least 2000'
            WHEN total >= 1000 AND total < 2000 THEN 'Between 1000 and 2000'
            ELSE 'Less than 1000' 
       END AS order_category,  -- "order_cateogry is the name given for the grouped      
       COUNT(*) AS order_count
FROM orders
GROUP BY 1;    -- GROUP BY "order_category"

-- We would like to understand 3 different levels of customers based on the amount associated with their purchases. The top level includes anyone with a Lifetime Value (total sales of all orders) greater than 200,000 usd. The second level is between 200,000 and 100,000 usd. The lowest level is anyone under 100,000 usd. Provide a table that includes the level associated with each account. You should provide the account name, the total sales of all orders for the customer, and the level. Order with the top spending customers listed first.

SELECT a.name, SUM(total_amt_usd) total_spent, 
     CASE WHEN SUM(total_amt_usd) > 200000 THEN 'top'
          WHEN  SUM(total_amt_usd) > 100000 THEN 'middle'
          ELSE 'low' 
     END AS customer_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id 
GROUP BY a.name
ORDER BY 2 DESC;

-- We would now like to perform a similar calculation to the first, but we want to obtain the total amount spent by customers only in 2016 and 2017. Keep the same levels as in the previous question. Order with the top spending customers listed first.
SELECT a.name, SUM(total_amt_usd) total_spent, 
     CASE WHEN SUM(total_amt_usd) > 200000 THEN 'top'
          WHEN  SUM(total_amt_usd) > 100000 THEN 'middle'
          ELSE 'low' 
     END AS customer_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
WHERE occurred_at > '2015-12-31' 
GROUP BY 1
ORDER BY 2 DESC;

-- We would like to identify top performing sales reps, which are sales reps associated with more than 200 orders. Create a table with the sales rep name, the total number of orders, and a column with top or not depending on if they have more than 200 orders. Place the top sales people first in your final table.
SELECT s.name, COUNT(*) num_ords,
     CASE WHEN COUNT(*) > 200 THEN 'top'
          ELSE 'not' 
     END AS sales_rep_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id 
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY 2 DESC;

-- The previous didn't account for the middle, nor the dollar amount associated with the sales. Management decides they want to see these characteristics represented as well. We would like to identify top performing sales reps, which are sales reps associated with more than 200 orders or more than 750000 in total sales. The middle group has any rep with more than 150 orders or 500000 in sales. Create a table with the sales rep name, the total number of orders, total sales across all orders, and a column with top, middle, or low depending on this criteria. Place the top sales people based on dollar amount of sales first in your final table. You might see a few upset sales people by this criteria!

SELECT s.name, COUNT(*), SUM(o.total_amt_usd) total_spent, 
     CASE WHEN COUNT(*) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'top'
          WHEN COUNT(*) > 150 OR SUM(o.total_amt_usd) > 500000 THEN 'middle'
          ELSE 'low' 
     END AS sales_rep_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id 
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY 3 DESC; 

