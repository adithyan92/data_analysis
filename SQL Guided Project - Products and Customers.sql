-- Exploring the tables
select *
from customers
limit 10;

select * 
from offices
LIMIT 5;

SELECT 'Customers' AS table_name, 
       13 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Customers
  
UNION ALL

SELECT 'Products' AS table_name, 
       9 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Products

UNION ALL

SELECT 'ProductLines' AS table_name, 
       4 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM ProductLines

UNION ALL

SELECT 'Orders' AS table_name, 
       7 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Orders

UNION ALL

SELECT 'OrderDetails' AS table_name, 
       5 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM OrderDetails

UNION ALL

SELECT 'Payments' AS table_name, 
       4 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Payments

UNION ALL

SELECT 'Employees' AS table_name, 
       8 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Employees

UNION ALL

SELECT 'Offices' AS table_name, 
       9 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM Offices;
  
-- Finding out the high performing products which are running 
--low on stock

-- Creating ctes to be used in the final query
with 
ordercount as(
select od.productCode, sum(od.quantityordered) as total_ordered
from orderdetails od
join orders o
on o.orderNumber = od.orderNumber
and o.status = 'In Process'
group by od.productcode
),
top_products AS 
(select productCode, sum(quantityOrdered*priceEach) as product_performance
from orderdetails 
group by (productCode)
ORDER by (product_performance) DESC
limit 10),
low_stock as (
select p. productCode, round(oc.total_ordered/p.quantityInStock, 2) as order_stock_ratio
from products as p inner join 
ordercount as oc
on p.productCode = oc.productCode
order by (order_stock_ratio) DESC
limit 10)

-- joining the CTEs to find the low stock products which are in
--the high performance categories
select l.productCode, p.productName
from low_stock l join products p
on l.productCode = p.productCode
where l.productCode in (select productCode from top_products)

--Next step is to find the VIP and low engagement customers

-- Creating two CTEs with high performing and low performing customer
--numbers
with top_customers as 
(select o.customerNumber, sum(od.quantityOrdered*(od.priceEach - p.buyPrice)) as netProfit
from orders o
inner join orderdetails od
on o.orderNumber = od.orderNumber
inner join products p
on od.productCode = p.productCode
group by o.customerNumber
order by netProfit desc
limit 5), 
low_engagement as(select o.customerNumber, sum(od.quantityOrdered*(od.priceEach - p.buyPrice)) as netProfit
from orders o
inner join orderdetails od
on o.orderNumber = od.orderNumber
inner join products p
on od.productCode = p.productCode
group by o.customerNumber
order by netProfit ASC
limit 5)

-- Getting details of top 5 customers
select c.contactLastName, c.contactFirstName, c.city, c.state, tc.netProfit
from customers c JOIN
top_customers tc
on c.customerNumber = tc.customerNumber

-- Getting details of 5 least engaged customers
select c.contactLastName, c.contactFirstName, c.city, c.state, le.netProfit
from customers c JOIN
low_engagement le
on c.customerNumber = le.customerNumber


--Average customer profits

with customer_profits as (
  select o.customerNumber, sum(od.quantityOrdered*(od.priceEach - p.buyPrice)) as netProfit
  from orders o
  inner join orderdetails od on o.orderNumber = od.orderNumber
  inner join products p on od.productCode = p.productCode
  group by o.customerNumber)
  
  select avg(netProfit) from customer_profits
  
  
-- Q1) The products which were in urgent need of restocking would be those which have orders that are currently being 
-- processed in excess of the stock. So we took the products were the sum(quantityOrdered)/quantityInStock is highest.
-- In those we found the ones that overlap with the highest performing products. Hence, the results were:
-- S10_1949	1952 Alpine Renault 1300
-- S18_1749	1917 Grand Touring Sedan
-- S18_2238	1998 Chrysler Plymouth Prowler
-- These are the products which are currently the most in need of restocking.

-- Q2) The most engaged customers for the company are,
-- Freyre	Diego 	Madrid		326519.66
-- Nelson	Susan	San Rafael	CA	236769.39
-- Young	Jeff	NYC	NY	72370.09
-- Ferguson	Peter	Melbourne	Victoria	70311.07
-- Labrune	Janine 	Nantes		60875.3
-- Special discounts and offers for these people will incentivize them to purchase more 

-- The least engaged customers are,
-- Young	Mary	Glendale	CA	2610.87
-- Taylor	Leslie	Brickhaven	MA	6586.02
-- Ricotti	Franco	Milan		9532.93
-- Schmitt	Carine 	Nantes		10063.8
-- Smith	Thomas 	London		10868.04
-- Most of the least engaged customers seem to be from Europe. More advertisements and promotions in that area would be
-- good since there have been no new customers for a while. Average customer profit is a whopping 39039.5943877551. So,
-- getting more customers will be crucial for the company.

