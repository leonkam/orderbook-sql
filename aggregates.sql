-- Your name and cohort here

/*
Aggregate Queries

REQUIREMENT - Use a multi-line comment to paste the first 5 or fewer results under your query
		     THEN records returned. 
*/

USE orderbook_activity_db;

-- #1: How many users do we have?
select count(*) from user;

/* +----------+
| count(*) |
+----------+
|        7 |
+----------+
 */
 
-- #2: List the username, userid, and number of orders each user has placed.
select uname, u.userid, count(orderid) from User u
 join `order` o on u.userid = o.userid
 group by uname, u.userid; 
/* +--------+--------+----------------+
| uname  | userid | count(orderid) |
+--------+--------+----------------+
| admin  |      1 |              3 |
| james  |      3 |              3 |
| kendra |      4 |              5 |
| alice  |      5 |              8 |
| robert |      6 |              5 |
+--------+--------+----------------+
5 rows in set (0.00 sec) */


-- #3: List the username, symbol, and number of orders placed for each user and for each symbol. 
-- Sort results in alphabetical order by symbol.
select uname, symbol, count(orderid) from user u
 join `order` o on u.userid = o.userid
 group by symbol, uname
 order by symbol;
/* +--------+--------+----------------+
| uname  | symbol | count(orderid) |
+--------+--------+----------------+
| alice  | A      |              5 |
| james  | A      |              1 |
| robert | AAA    |              1 |
| admin  | AAPL   |              1 |
| kendra | AAPL   |              1 |
| robert | AAPL   |              1 |
| alice  | GOOG   |              1 |
| admin  | GS     |              1 |
| kendra | GS     |              1 |
| robert | MSFT   |              1 |
| robert | NFLX   |              1 |
| kendra | QQQ    |              2 |
| alice  | SPY    |              1 |
| kendra | SPY    |              1 |
| alice  | TLT    |              1 |
| james  | TLT    |              1 |
| admin  | WLY    |              1 |
| james  | WLY    |              1 |
| robert | WLY    |              1 |
+--------+--------+----------------+
19 rows in set (0.00 sec) */

-- #4: Perform the same query as the one above, but only include admin users.
select uname, symbol, count(orderid) from user u
 join `order` o on u.userid = o.userid
 where u.userid in 
 (select u.userid from user u 
 join userroles ur on u.userid = ur.userid 
 join role r on r.roleid = ur.roleid 
 where r.name = 'admin')
 group by symbol, uname
 order by symbol;
/* +-------+--------+----------------+
| uname | symbol | count(orderid) |
+-------+--------+----------------+
| alice | A      |              5 |
| admin | AAPL   |              1 |
| alice | GOOG   |              1 |
| admin | GS     |              1 |
| alice | SPY    |              1 |
| alice | TLT    |              1 |
| admin | WLY    |              1 |
+-------+--------+----------------+
7 rows in set (0.02 sec) */


-- #5: List the username and the average absolute net order amount for each user with an order.
-- Round the result to the nearest hundredth and use an alias (averageTradePrice).
-- Sort the results by averageTradePrice with the largest value at the top.
select u.uname, round(avg(shares * price), 2) averageTradePrice from user u
 join `order` o on u.userid = o.userid
 group by u.uname
 order by averageTradePrice desc;
 /* +--------+-------------------+
| uname  | averageTradePrice |
+--------+-------------------+
| admin  |          10774.87 |
| alice  |           6000.47 |
| james  |           1187.80 |
| robert |            536.92 |
| kendra |         -17109.53 |
+--------+-------------------+
5 rows in set (0.03 sec) */


-- #6: How many shares for each symbol does each user have?
-- Display the username and symbol with number of shares.
select u.uname, symbol, sum(shares) from user u
 join `order` o on u.userid = o.userid
 group by uname, symbol;
/* +--------+--------+-------------+
| uname  | symbol | sum(shares) |
+--------+--------+-------------+
| admin  | WLY    |         100 |
| admin  | GS     |         100 |
| admin  | AAPL   |         -15 |
| alice  | A      |          18 |
| alice  | SPY    |         100 |
| alice  | TLT    |         -10 |
| alice  | GOOG   |         100 |
| james  | A      |         -10 |
| james  | TLT    |          10 |
| james  | WLY    |         100 |
| kendra | GS     |         -10 |
| kendra | AAPL   |         -10 |
| kendra | QQQ    |        -200 |
| kendra | SPY    |         -75 |
| robert | WLY    |         -10 |
| robert | NFLX   |        -100 |
| robert | AAPL   |          25 |
| robert | AAA    |          10 |
| robert | MSFT   |         100 |
+--------+--------+-------------+
19 rows in set (0.00 sec) */
 
-- #7: What symbols have at least 3 orders?
select symbol, count(symbol) from `order`
 group by symbol
 having count(symbol) >= 3; 
/* +--------+---------------+
| symbol | count(symbol) |
+--------+---------------+
| A      |             6 |
| AAPL   |             3 |
| WLY    |             3 |
+--------+---------------+
3 rows in set (0.00 sec) */

-- #8: List all the symbols and absolute net fills that have fills exceeding $100.
-- Do not include the WLY symbol in the results.
-- Sort the results by highest net with the largest value at the top.
select symbol, abs(sum(shares * price)) abs_net_fills from `order` 
 where symbol != 'WLY' 
 group by symbol 
 having abs_net_fills > 100
 order by abs_net_fills desc ; 
/* +--------+-----------+
| symbol | net_fills |
+--------+-----------+
| QQQ    |  53654.00 |
| GS     |  27506.70 |
| NFLX   |  24315.00 |
| MSFT   |  23627.00 |
| GOOG   |  10082.00 |
| SPY    |   9143.25 |
| A      |   1039.12 |
| AAA    |    240.90 |
+--------+-----------+
8 rows in set (0.04 sec) */

-- #9: List the top five users with the greatest amount of outstanding orders.
-- Display the absolute amount filled, absolute amount ordered, and net outstanding.
-- Sort the results by the net outstanding amount with the largest value at the top.
select u.uname, count(orderid) outst, abs(sum(shares)) amount_fill  from user 
 join `order` o on u.userid = o.userid
where status in ('partial_fill', 'pending') 
group by u.uname
 order by outst desc
 limit 5;