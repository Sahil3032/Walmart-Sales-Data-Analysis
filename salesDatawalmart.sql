CREATE DATABASE IF NOT EXISTS salesDataWalmart;
USE salesDataWalmart;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id varchar(30) not null primary key,
    branch varchar(5) not null,
    city varchar(30) not null,
    customer_type varchar(30) not null,
    gender varchar(10) not null,
    product_line varchar(100) not null,
    unit_price decimal(10,2) not null,
    quantity INT not null,
    VAT float(6,4) not null,
    total decimal(12,4) not null,
    date DATETIME not null,
    time TIME not null,
	payment_method varchar(15) not null,
    cogs decimal(10,2) not null,
    gross_margin_percentage float(11,9) not null,
    gross_income decimal(12,4) not null,
    rating float(3,1)
);

SELECT * FROM sales;

---------------------------- feature engineering-------------------------------

-- time_of the_day
alter table sales add column time_of_day VARCHAR(15);
UPDATE sales 
SET time_of_day = (
	CASE 
    	WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "MORNING"
        WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "AFTERNOON"
        ELSE "EVENING"
	 END
);

-- day_name
alter table sales add column day_name VARCHAR(10);
UPDATE sales
SET	day_name = ( dayname(date) );

-- month_name
alter table sales add column month_name varchar(10);
update sales
set month_name = monthname(date);

									-- Exploratory Data Analysis

									-- Generic Questions
# 1. How many unique cities does the data have? 
SELECT distinct(city) from sales;
select count(distinct(city)) from sales;

# 2. In which city is each branch?
select distinct city , branch from sales;

									-- Product Questions
# How many unique product lines does the data have?
select distinct(product_line) from sales;

# What is the most common payment method?
select payment_method, count(payment_method) as cnt from sales
group by payment_method 
order by cnt desc
limit 1;

# What is the most selling product line?
select product_line, count(product_line) as cnt from sales
group by product_line
order by cnt desc;

#. What is the total revenue by month?
select month_name, sum(total) as revenue from sales
group by month_name
order by revenue desc;

#. What month had the largest COGS?
select month_name, sum(cogs) as largest from sales
group by month_name
order by largest desc;

#. What product line had the largest revenue?
select product_line, sum(total) as largest from sales
group by product_line
order by largest desc;

#. What is the city with the largest revenue?
select city, branch, sum(total) as largest from sales
group by city, branch
order by largest desc;

#. What product line had the largest VAT?
select product_line, avg(VAT) as avg_tax from sales
group by product_line
order by avg_tax desc;

#. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
select product_line, total_sales, 
				(CASE
					WHEN total_sales >= avg(total_sales) THEN "Good"
					else "Bad"
				END) AS review
                            
from (
			SELECT product_line, sum(total) as total_sales from sales
			group by product_line
			order by total_sales desc)as avg_sales
group by product_line;

#. Which branch sold more products than average product sold?
SELECT branch, sum(quantity) as qty from sales
group by branch
having sum(quantity) > ( SELECT sum(quantity)/count(distinct branch) from sales )
;

#. What is the most common product line by gender?
select gender, product_line, count(product_line) as cnt from sales
group by gender, product_line
order by cnt desc;

#. What is the average rating of each product line?
select product_line , Round(avg(rating),2) as avg_rating from sales
group by product_line
order by avg_rating desc;

											-- Customers

# How many unique customer types does the data have?
SELECT DISTINCT customer_type FROM sales;

# How many unique payment methods does the data have?
SELECT DISTINCT payment FROM sales;

# What is the most common customer type?
SELECT customer_type, count(*) as count FROM sales
GROUP BY customer_type
ORDER BY count DESC;

# Which customer type buys the most?
SELECT customer_type, COUNT(*) FROM sales
GROUP BY customer_type;

# What is the gender of most of the customers?
SELECT gender, COUNT(*) as gender_cnt FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;

# What is the gender distribution per branch?
SELECT gender, COUNT(*) as gender_cnt FROM sales
WHERE branch = "C"
GROUP BY gender
ORDER BY gender_cnt DESC;
-- Gender per branch is more or less the same hence, I don't think has
-- an effect of the sales per branch and other factors.

# Which time of the day do customers give most ratings?
SELECT time_of_day,	AVG(rating) AS avg_rating FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Looks like time of the day does not really affect the rating, its
-- more or less the same rating each time of the day.alter

# Which time of the day do customers give most ratings per branch?
SELECT time_of_day, AVG(rating) AS avg_rating FROM sales
WHERE branch = "A"
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Branch A and C are doing well in ratings, branch B needs to do a 
-- little more to get better ratings.


# Which day fo the week has the best avg ratings?
SELECT day_name, AVG(rating) AS avg_rating FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;
-- Mon, Tue and Friday are the top best days for good ratings
-- why is that the case, how many sales are made on these days?

# Which day of the week has the best average ratings per branch?
SELECT 
	day_name,
	COUNT(day_name) total_sales
FROM sales
WHERE branch = "C"
GROUP BY day_name
ORDER BY total_sales DESC;

									-- Sales 

# Number of sales made in each time of the day per weekday 
SELECT time_of_day,	COUNT(*) AS total_sales FROM sales
WHERE day_name = "Sunday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;
-- Evenings experience most sales, the stores are 
-- filled during the evening hours

# Which of the customer types brings the most revenue?
SELECT customer_type, SUM(total) AS total_revenue FROM sales
GROUP BY customer_type
ORDER BY total_revenue;

# Which city has the largest tax/VAT percent?
SELECT city, ROUND(AVG(tax_pct), 2) AS avg_tax_pct FROM sales
GROUP BY city 
ORDER BY avg_tax_pct DESC;

# Which customer type pays the most in VAT?
SELECT customer_type, AVG(tax_pct) AS total_tax FROM sales
GROUP BY customer_type
ORDER BY total_tax;
