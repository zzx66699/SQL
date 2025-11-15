## 1. = & != 

``` sql
# select all the names that are not referred by the customer with id = 2

SELECT name
FROM customer
WHERE referee_id != 2 OR referee_id IS NULL; # = or != only check the non-null values. 
```
--------------------------
## 2. IN & NOT IN operator 
``` sql
SELECT *
FROM products
WHERE quantity_in_stock IN (49, 38, 72)；
```
--------------------------
## 3. AND & OR & NOT operater
``` sql
SELECT *
FROM table
WHERE order_id = 6 AND unit_price * quantity > 30
```

``` sql
SELECT *
FROM Customers
WHERE NOT (birth_date > '1990-01-01' OR points > 1000)  # add''for date
```
### EXERCISE
``` sql
# find all the names that stars with 'C' or 'W'
# primary_poc contains 'ana' or 'Ana'
# but primary_poc doesn't contain 'eana'

SELECT *
FROM accounts
WHERE
	(name LIKE 'C%' OR name LIKE 'W%') AND                      
	(primary_poc LIKE '%ana%' OR primary_poc LIKE '%Ana%') AND
	primary_poc NOT LIKE '%eana%';
```
