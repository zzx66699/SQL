CREATE TABLE web_events (
             id integer PRIMARY KEY,
             account_id integer,
             occurred_at timestamp,
             channel varchar(15)
              );
INSERT INTO web_events VALUES (1,1001,'2015-10-06 17:13:58','direct');
INSERT INTO web_events VALUES (2,1001,'2015-11-05 03:08:26','direct');
INSERT INTO web_events VALUES (3,1001,'2015-12-04 03:57:24','direct');
INSERT INTO web_events VALUES (4,1001,'2016-01-02 00:55:03','direct');
INSERT INTO web_events VALUES (5,1001,'2016-02-01 19:02:33','direct');
INSERT INTO web_events VALUES (6,1001,'2016-03-02 15:15:22','direct');
INSERT INTO web_events VALUES (7,1001,'2016-04-01 10:58:55','direct');
INSERT INTO web_events VALUES (8,1001,'2016-05-01 15:26:44','direct');
INSERT INTO web_events VALUES (9,1001,'2016-05-31 20:53:47','direct');
INSERT INTO web_events VALUES (10,1001,'2016-06-30 12:09:45','direct');
INSERT INTO web_events VALUES (11,1001,'2016-07-30 03:06:26','direct');
INSERT INTO web_events VALUES (12,1001,'2016-08-28 06:42:42','direct');
INSERT INTO web_events VALUES (13,1001,'2016-09-26 23:14:59','direct');
INSERT INTO web_events VALUES (14,1001,'2016-10-26 20:21:09','direct');

CREATE TABLE orders (
             id integer,
             account_id integer,
             occurred_at timestamp,
             standard_qty integer,
             gloss_qty integer,
             poster_qty integer,
             total integer,
             standard_amt_usd numeric(10,2),
             gloss_amt_usd numeric(10,2),
             poster_amt_usd numeric(10,2),
             total_amt_usd numeric(10,2)
);
INSERT INTO orders VALUES (1,1001,'2015-10-06 17:31:14',123,22,24,169,613.77,164.78,194.88,973.43);
INSERT INTO orders VALUES (2,1001,'2015-11-05 03:34:33',190,41,57,288,948.1,307.09,462.84,1718.03);
INSERT INTO orders VALUES (3,1001,'2015-12-04 04:21:55',85,47,0,132,424.15,352.03,0,776.18);
INSERT INTO orders VALUES (4,1001,'2016-01-02 01:18:24',144,32,0,176,718.56,239.68,0,958.24);
INSERT INTO orders VALUES (5,1001,'2016-02-01 19:27:27',108,29,28,165,538.92,217.21,227.36,983.49);
INSERT INTO orders VALUES (6,1001,'2016-03-02 15:29:32',103,24,46,173,513.97,179.76,373.52,1067.25);
INSERT INTO orders VALUES (7,1001,'2016-04-01 11:20:18',101,33,92,226,503.99,247.17,747.04,1498.2);
INSERT INTO orders VALUES (8,1001,'2016-05-01 15:55:51',95,47,151,293,474.05,352.03,1226.12,2052.2);
INSERT INTO orders VALUES (9,1001,'2016-05-31 21:22:48',91,16,22,129,454.09,119.84,178.64,752.57);
INSERT INTO orders VALUES (10,1001,'2016-06-30 12:32:05',94,46,8,148,469.06,344.54,64.96,878.56);
INSERT INTO orders VALUES (11,1001,'2016-07-30 03:26:30',101,36,0,137,503.99,269.64,0,773.63);
INSERT INTO orders VALUES (12,1001,'2016-08-28 07:13:39',124,33,39,196,618.76,247.17,316.68,1182.61);
INSERT INTO orders VALUES (13,1001,'2016-09-26 23:28:25',104,10,44,158,518.96,74.9,357.28,951.14);
INSERT INTO orders VALUES (14,1001,'2016-10-26 20:31:30',97,143,54,294,484.03,1071.07,438.48,1993.58);
INSERT INTO orders VALUES (15,1001,'2016-11-25 23:21:32',127,39,44,210,633.73,292.11,357.28,1283.12);
INSERT INTO orders VALUES (16,1001,'2016-12-24 05:53:13',123,127,19,269,613.77,951.23,154.28,1719.28);
INSERT INTO orders VALUES (17,1011,'2016-12-21 10:59:34',527,14,0,541,2629.73,104.86,0,2734.59);
INSERT INTO orders VALUES (18,1021,'2015-10-12 02:21:56',516,23,0,539,2574.84,172.27,0,2747.11);
INSERT INTO orders VALUES (19,1021,'2015-11-11 07:37:01',497,61,0,558,2480.03,456.89,0,2936.92);
INSERT INTO orders VALUES (20,1021,'2015-12-11 16:53:18',483,0,21,504,2410.17,0,170.52,2580.69);
INSERT INTO orders VALUES (21,1021,'2016-01-10 09:29:45',535,0,34,569,2669.65,0,276.08,2945.73);
INSERT INTO orders VALUES (22,1021,'2016-02-09 00:50:46',502,4,9,515,2504.98,29.96,73.08,2608.02);
INSERT INTO orders VALUES (23,1021,'2016-03-10 00:38:52',555,19,4,578,2769.45,142.31,32.48,2944.24);
INSERT INTO orders VALUES (24,1031,'2016-12-25 03:54:27',1148,0,215,1363,5728.52,0,1745.8,7474.32);
INSERT INTO orders VALUES (25,1041,'2016-10-14 23:54:21',298,28,69,395,1487.02,209.72,560.28,2257.02);

#-------------------------------------------

CREATE TABLE orders1 AS 
SELECT  id, account_id, occurred_at, standard_qty, total, standard_qty/total*100 AS standard_pct
FROM orders;

CREATE TABLE orders2  AS  
SELECT  *
FROM orders ;
------------------
-- UPDATE TABLE
UPDATE orders1 
SET account_id = 10001, standard_qty = standard_qty*10
WHERE id = 10;

UPDATE orders1 
SET account_id = 10001, standard_qty = standard_qty*10
WHERE id < 100 AND standard_qty < 990 ;

--------------------
-- DELETE rows
-----------------
DELETE FROM orders1
WHERE id <10;

----------------
-- DELETE TABLE
----------------
DROP TABLE orders1;

DROP TABLE orders1, orders2;

