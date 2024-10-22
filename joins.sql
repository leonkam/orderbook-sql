-- Your name and cohort here

/*
Join Queries

REQUIREMENT - Use a multi-line comment to paste the first 5 or fewer results under your query
		     Also include the total records returned.
*/

USE orderbook_activity_db;

-- #1: Display the dateJoined and username for admin users.
select dateJoined, uname from user 
where userid in ( select userid from userroles u 
join `role` r on r.roleid = u.roleid 
where name = 'admin');
/* +---------------------+-------+
| dateJoined          | uname |
+---------------------+-------+
| 2023-02-14 13:13:28 | admin |
| 2023-04-01 13:13:28 | wiley |
| 2023-03-15 19:16:21 | alice |
+---------------------+-------+
3 rows in set (0.00 sec) */

-- #2: Display each absolute order net (share*price), status, symbol, trade date, and username.
-- Sort the results with largest the absolute order net (share*price) at the top.
-- Include only orders that were not canceled or partially canceled.
select uname, abs(sum(shares * price)) order_net, status, symbol, orderTime from user u
 join `order` o on u.userid = o.userid
 where status not in ('canceled_partial_fill', 'canceled')
  group by uname, symbol, status, orderTime
 order by order_net desc;
 /* +--------+-----------+--------------+--------+---------------------+
| uname  | order_net | status       | symbol | orderTime           |
+--------+-----------+--------------+--------+---------------------+
| kendra |  53654.00 | pending      | QQQ    | 2023-03-15 19:24:32 |
| alice  |  36573.00 | partial_fill | SPY    | 2023-03-15 19:24:21 |
| kendra |  27429.75 | filled       | SPY    | 2023-03-15 19:24:47 |
| robert |  24315.00 | pending      | NFLX   | 2023-03-15 19:21:12 |
| admin  |   3873.00 | partial_fill | WLY    | 2023-03-15 19:20:35 |
| james  |   3873.00 | pending      | WLY    | 2023-03-15 19:51:06 |
| robert |   3519.00 | filled       | AAPL   | 2023-03-15 19:23:22 |
| kendra |   3056.30 | filled       | GS     | 2023-03-15 19:22:25 |
| admin  |   2111.40 | filled       | AAPL   | 2023-03-15 19:23:47 |
| kendra |   1407.60 | filled       | AAPL   | 2023-03-15 19:23:35 |
| alice  |   1298.90 | filled       | A      | 2023-03-15 19:21:31 |
| james  |   1298.90 | filled       | A      | 2023-03-15 19:21:39 |
| alice  |    989.30 | filled       | TLT    | 2023-03-15 19:25:45 |
| james  |    989.30 | filled       | TLT    | 2023-03-15 19:25:29 |
| alice  |    649.45 | pending      | A      | 2023-03-15 20:09:51 |
| robert |    387.30 | filled       | WLY    | 2023-03-15 19:20:50 |
| alice  |    259.78 | pending      | A      | 2023-03-15 20:09:46 |
| alice  |    259.78 | pending      | A      | 2023-03-15 20:09:56 |
| alice  |    129.89 | pending      | A      | 2023-03-15 20:09:38 |
+--------+-----------+--------------+--------+---------------------+
19 rows in set (0.00 sec) */

-- #3: Display the orderid, symbol, status, order shares, filled shares, and price for orders with fills.
-- Note that filledShares are the opposite sign (+-) because they subtract from ordershares!se
select orderid, symbol, status, shares order_shares, -shares filled_shares, price from `order` 
where status in ('filled', 'partial_fill');

-- #4: Display all partial_fill orders and how many outstanding shares are left.
-- Also include the username, symbol, and orderid.
 select uname, symbol, orderid, abs(sum(shares)) from user u
  join `order` o on u.userid = o.userid 
 where status = 'partial_fill'
  group by uname, symbol, orderid;
  /* +-------+--------+---------+------------------+
| uname | symbol | orderid | abs(sum(shares)) |
+-------+--------+---------+------------------+
| admin | WLY    |       1 |              100 |
| alice | SPY    |      11 |              100 |
+-------+--------+---------+------------------+
2 rows in set (0.00 sec) */

-- #5: Display the orderid, symbol, status, order shares, filled shares, and price for orders with fills.
-- Also include the username, role, absolute net amount of shares filled, and absolute net order.
-- Sort by the absolute net order with the largest value at the top.
select uname, name role_name, orderid, symbol, status, shares order_shares, -shares filled_shares, 
abs(sum(shares)) abs_net_order, price from `order` o 
  join user u on u.userid = o.userid 
  join userroles ur on u.userid = ur.userid  
 join role r on r.roleid = ur.roleid  
where status in ('filled', 'partial_fill') 
 group by uname, status, symbol, orderid, name
 order by abs_net_order desc ;
/* +--------+-----------+---------+--------+--------------+--------------+---------------+---------------+--------+
| uname  | role_name | orderid | symbol | status       | order_shares | filled_shares | abs_net_order | price  |
+--------+-----------+---------+--------+--------------+--------------+---------------+---------------+--------+
| admin  | admin     |       1 | WLY    | partial_fill |          100 |          -100 |           100 |  38.73 |
| alice  | admin     |      11 | SPY    | partial_fill |          100 |          -100 |           100 | 365.73 |
| kendra | user      |      14 | SPY    | filled       |          -75 |            75 |            75 | 365.73 |
| robert | user      |       8 | AAPL   | filled       |           25 |           -25 |            25 | 140.76 |
| admin  | admin     |      10 | AAPL   | filled       |          -15 |            15 |            15 | 140.76 |
| robert | user      |       2 | WLY    | filled       |          -10 |            10 |            10 |  38.73 |
| alice  | admin     |       4 | A      | filled       |           10 |           -10 |            10 | 129.89 |
| james  | user      |       5 | A      | filled       |          -10 |            10 |            10 | 129.89 |
| kendra | user      |       7 | GS     | filled       |          -10 |            10 |            10 | 305.63 |
| kendra | user      |       9 | AAPL   | filled       |          -10 |            10 |            10 | 140.76 |
| james  | user      |      15 | TLT    | filled       |           10 |           -10 |            10 |  98.93 |
| alice  | admin     |      16 | TLT    | filled       |          -10 |            10 |            10 |  98.93 |
+--------+-----------+---------+--------+--------------+--------------+---------------+---------------+--------+
12 rows in set (0.00 sec) */

-- #6: Display the username and user role for users who have not placed an order.
select uname, name role_name from user u
  join userroles ur on u.userid = ur.userid  
 join role r on r.roleid = ur.roleid 
where u.userid  in (select o.userid from `order` o);
/* +-------+-----------+
| uname | role_name |
+-------+-----------+
| sam   | user      |
| wiley | admin     |
+-------+-----------+
2 rows in set (0.03 sec) */

-- #7: Display orderid, username, role, symbol, price, and number of shares for orders with no fills.
select orderid, uname, name role_name, symbol, price, shares from `order` o 
  join user u on u.userid = o.userid 
  join userroles ur on u.userid = ur.userid  
 join role r on r.roleid = ur.roleid  
 where status in ('canceled', 'pending');
/* +---------+--------+-----------+--------+--------+--------+
| orderid | uname  | role_name | symbol | price  | shares |
+---------+--------+-----------+--------+--------+--------+
|       3 | robert | user      | NFLX   | 243.15 |   -100 |
|      12 | kendra | user      | QQQ    | 268.27 |   -100 |
|      13 | kendra | user      | QQQ    | 268.27 |   -100 |
|      17 | robert | user      | AAA    |  24.09 |     10 |
|      18 | robert | user      | MSFT   | 236.27 |    100 |
|      19 | alice  | admin     | GOOG   | 100.82 |    100 |
|      20 | james  | user      | WLY    |  38.73 |    100 |
|      21 | alice  | admin     | A      | 129.89 |     -1 |
|      22 | alice  | admin     | A      | 129.89 |      2 |
|      23 | alice  | admin     | A      | 129.89 |      5 |
|      24 | alice  | admin     | A      | 129.89 |      2 |
+---------+--------+-----------+--------+--------+--------+
11 rows in set (0.00 sec) */

-- #8: Display the symbol, username, role, and number of filled shares where the order symbol is WLY.
-- Include all orders, even if the order has no fills.
select symbol, uname, name role_name, shares from `order` o 
  join user u on u.userid = o.userid 
  join userroles ur on u.userid = ur.userid  
 join role r on r.roleid = ur.roleid  
 where symbol = 'WLY';
/* +--------+--------+-----------+--------+
| symbol | uname  | role_name | shares |
+--------+--------+-----------+--------+
| WLY    | admin  | admin     |    100 |
| WLY    | robert | user      |    -10 |
| WLY    | james  | user      |    100 |
+--------+--------+-----------+--------+
3 rows in set (0.00 sec) */


