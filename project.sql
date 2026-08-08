use project;
SELECT YEAR(order_date) AS Year,
    MONTH(order_date) AS Month, 
SUM(revenue) 	as Total_Rev, 
SUM(profit) 	as Total_Pft, 
COUNT(order_quantity) as Total_order 
from sales_data
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY Year, Month ASC;

# Which product categories generate the most revenue vs. the most profit (they may differ)?
SELECT product_category, 
SUM(revenue) as Total_Rev, 
SUM(profit) as Total_Pft
FROM sales_data
GROUP BY product_category
ORDER BY Total_Rev;

## What's the overall profit margin trend over time — is it improving or declining?
SELECT YEAR(order_date) as Year,
ROUND(AVG(profit_margin_num),2)
as AVG_margin_profit
FROM sales_data
GROUP BY Year;

## Which single products are the top 10 by revenue? By total units sold?
SELECT product, 
SUM(order_quantity) as Unit_Sold, 
SUM(revenue) as Total_Rev
FROM sales_data
GROUP BY product
ORDER BY Total_Rev DESC LIMIT 10;

## Is there a meaningful gender split in purchases by product category (e.g., do men and women favor different bike types)? ****
SELECT
customer_gender,
product_category,
COUNT(*) AS Order_Count,
SUM(order_quantity) AS Units_Sold,
SUM(revenue) AS Total_Rev
FROM sales_data
GROUP BY customer_gender, product_category
ORDER BY customer_gender, Total_Rev DESC;

## Rank states within each country by total sales. ****
SELECT country, state, 
SUM(revenue) AS Total_sales,
RANK() OVER(PARTITION BY country ORDER BY SUM(revenue) DESC) AS State_Rank
FROM sales_data
GROUP BY country, state
ORDER BY Total_sales DESC;

## Which products show a profit_loss = 'Loss' most often, and what do they have in common (category, price point, region)? ****
SELECT product, 
product_category, country, state,
COUNT(*) AS Loss_Count FROM sales_data
WHERE profit_loss = 'Loss'
GROUP BY product, product_category, country, state
ORDER BY Loss_Count DESC;


WITH yearly AS (
    SELECT
        YEAR(order_date) AS year,
        SUM(revenue) AS Total_Rev,
        SUM(profit) / SUM(revenue) * 100 AS Margin_Pct
    FROM sales_data
    GROUP BY YEAR(order_date)
)
SELECT
    year,
    Total_Rev,
    ROUND(Margin_Pct, 2) AS Margin_Pct,
    LAG(Total_Rev) OVER (ORDER BY year) AS Prev_Year_Rev,
    ROUND((Total_Rev - LAG(Total_Rev) OVER (ORDER BY year)) / LAG(Total_Rev) OVER (ORDER BY year) * 100, 2) AS Rev_Growth_Pct,
    ROUND(Margin_Pct - LAG(Margin_Pct) OVER (ORDER BY year), 2) AS Margin_Change_Pct
FROM yearly
ORDER BY year;

## Which combination of country + category + age_group generates the highest average profit margin (a cross-segment "sweet spot")? ****
SELECT
    country,
    product_category,
    age_group,
    COUNT(*) AS Order_Count,
    SUM(revenue) AS Total_Rev,
    ROUND(SUM(profit) / SUM(revenue) * 100, 2) AS Avg_Margin_Pct
FROM sales_data
GROUP BY country, product_category, age_group
HAVING Order_Count >= 30
ORDER BY Avg_Margin_Pct DESC
LIMIT 10;

SELECT * FROM sales_data;

