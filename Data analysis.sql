-- use sys; 
-- Table Creation for Orders Data:
-- creating the table here to fix the data type issue.

 CREATE TABLE orders (
   order_id INT AUTO_INCREMENT PRIMARY KEY,  -- Unique identifier for each order
    order_date DATETIME NOT NULL,             -- Date and time when the order was placed
    ship_mode VARCHAR(50),                    -- Shipping mode (e.g., Standard, Express)
	segment VARCHAR(50),                      -- Customer segment (e.g., Consumer, Corporate)
  country VARCHAR(100),                     -- Country of the customer
  city VARCHAR(100),                        -- City of the customer
     state VARCHAR(100),                       -- State or province of the customer
    postal_code VARCHAR(20),                  -- Postal or ZIP code
    region VARCHAR(50),                       -- Region (e.g., East, West)
    category VARCHAR(100),                    -- Product category (e.g., Technology, Furniture)
   sub_category VARCHAR(100),                -- Product sub-category (e.g., Phones, Chairs)
   product_id VARCHAR(100),                  -- Identifier for the product
   list_price DECIMAL(10,2),                 -- Cost price of the product
    quantity INT NOT NULL,                    -- Quantity of the product ordered
   discount_price DECIMAL(10, 2),            -- Discounted price applied to the order
  sale_price DECIMAL(10, 2) NOT NULL,       -- Sale price of the order
 profit DECIMAL(10, 2)                     -- Profit made from the order
 );

-- Top 10 Highest Reveue Generating Products 

select * from (select product_id, sum(sale_price), rank() over (order by sum(sale_price) desc) as rnk
  from orders group by 1) A where rnk < 11;
  

-- Top 5 Highest Selling Products in Each Region:

select * from 
(select region, product_id, sum(sale_price) as sales, rank() over (partition by region order by sum(sale_price) desc) as rnk
  from orders group by 1,2) A 
  where rnk < 6;

--  Month-over-Month Growth Comparison for 2022 and 2023:

SELECT DATE_FORMAT(order_date, "%M") AS formatted_date, 
sum(case when date_format(order_date,'%Y') ='2022' then sale_price else 0 end)as Sales_2022,
sum(case when date_format(order_date,'%Y') ='2023' then sale_price else 0 end)as Sales_2023
 FROM orders group by 1 ;
 
-- Highest Sales Month for Each Category:

with cte as (select category, date_format(order_date,'%y%m') as formatted_date, sum(sale_price) as sales from orders group by 1,2)
select * from (select *, rank() over(partition by category order by sales desc) as rnk from cte) as A where rnk =1;

-- Sub-category with the Highest Growth in Profit from 2022 to 2023:

with cte as (select sub_category, sum( case when date_format(order_date,'%Y') ='2022' then sale_price end) as sale_2022,
sum( case when date_format(order_date,'%Y') ='2023' then sale_price end) as sale_2023
 from orders group by 1)
 select * from (select sub_category, round((sale_2023 - sale_2022)/sale_2022 * 100,2) as growth, rank() over(order by (sale_2023 - sale_2022)/sale_2022 * 100 
 desc) as rnk from cte) as A
 where rnk =1;
 


