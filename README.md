# Sales Data Cleaning, SQL Analysis & Power BI Dashboard

End-to-end sales analytics project: cleaned 113K+ raw sales records in Excel, analyzed them with SQL in MySQL (revenue trends, product performance, regional & demographic breakdowns), and built an interactive Power BI dashboard.

**Tools used:** Microsoft Excel 2019 · MySQL 8.0 · Power BI

**Dataset:** `sales_data.csv` — 113,036 rows of bike and accessory sales across multiple countries (2011–2016), with customer demographics, product details, order quantities, and financials (cost, profit, revenue).

**Workflow:** `Data Cleaning (Excel)` → `SQL Analysis (MySQL)` → `Power BI Dashboard`

**Key results:** $85M total revenue · 37.78% avg. profit margin · 1M units sold · $32M total profit · Bikes drive 72% of revenue.

---

## 1. Data Cleaning (Excel)

- Corrected inconsistent `Age_Group` labels with a nested `IFS`/`AND` formula (`age_grp` column)
- Removed 1,000 duplicate rows → 112,036 unique records remain
- Removed redundant `Day`, `Month`, `Year` columns in favor of the single `Date` column
- Confirmed no blank cells remain (`COUNTBLANK`)
- Sorted chronologically by date
- Validated data consistency: `Revenue = Cost + Profit`, `Cost = Unit Cost × Order Quantity`, no unit price below unit cost, no zero/negative order quantities
- Added two calculated columns: `profit_margin` (profit / revenue) and `profit_loss` (Profit / Loss flag)

---

## 2. SQL Analysis (MySQL)

### Importing the data

**Create the table**

```sql
use project;
create table sales_data
    (order_date date, customer_age int, age_group varchar(50),
    customer_gender varchar(5), country varchar(50),
    state varchar(50), product_category varchar(200),
    sub_category varchar(200), product varchar(200),
    order_quantity int, unit_cost int, unit_price int,
    profit int, cost int, revenue int,
    profit_margin varchar(10), profit_loss varchar(10));
```


**Load the CSV**

```sql
LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_data.csv'
INTO TABLE sales_data
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;
```


> The `product` column contains commas inside some values, so `OPTIONALLY ENCLOSED BY '"'` tells MySQL to treat a double-quoted field as a single value even if it contains commas — preventing those product names from being split across columns during import.

### Analytical queries

**A. Total revenue, profit, and order count by year and month**

```sql
SELECT YEAR(order_date) AS Year,
    MONTH(order_date) AS Month,
    SUM(revenue)  as Total_Rev,
    SUM(profit)   as Total_Pft,
    COUNT(order_quantity) as Total_order
from sales_data
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY Year, Month ASC;
```


**B. Revenue vs. profit by product category**

```sql
SELECT product_category,
SUM(revenue) as Total_Rev,
SUM(profit) as Total_Pft
FROM sales_data
GROUP BY product_category
ORDER BY Total_Rev;
```


**C. Profit margin trend over time**

```sql
SELECT YEAR(order_date) as Year,
ROUND(AVG(profit_margin_num),2) as AVG_margin_profit
FROM sales_data
GROUP BY Year;
```


**D. Top 10 products by revenue and units sold**

```sql
SELECT product,
SUM(order_quantity) as Unit_Sold,
SUM(revenue) as Total_Rev
FROM sales_data
GROUP BY product
ORDER BY Total_Rev DESC LIMIT 10;
```


**E. Gender split in purchases by product category**

```sql
SELECT
customer_gender,
product_category,
COUNT(*) AS Order_Count,
SUM(order_quantity) AS Units_Sold,
SUM(revenue) AS Total_Rev
FROM sales_data
GROUP BY customer_gender, product_category
ORDER BY customer_gender, Total_Rev DESC;
```


**F. Rank states within each country by total sales**

```sql
SELECT country, state,
SUM(revenue) AS Total_sales,
RANK() OVER(PARTITION BY country ORDER BY SUM(revenue) DESC) AS State_Rank
FROM sales_data
GROUP BY country, state
ORDER BY Total_sales DESC;
```


**G. Products most often sold at a loss**

```sql
SELECT product,
product_category, country, state,
COUNT(*) AS Loss_Count FROM sales_data
WHERE profit_loss = 'Loss'
GROUP BY product, product_category, country, state
ORDER BY Loss_Count DESC;
```


**H. Year-over-year growth in revenue and margin**

```sql
SELECT YEAR(order_date) AS Year,
    SUM(revenue) AS Total_Rev,
    ROUND(AVG(profit_margin_num),2) AS Avg_Margin,
    ROUND((SUM(revenue) - LAG(SUM(revenue)) OVER (ORDER BY YEAR(order_date)))
        / LAG(SUM(revenue)) OVER (ORDER BY YEAR(order_date)) * 100, 2) AS Revenue_Growth_Pct
FROM sales_data
GROUP BY YEAR(order_date)
ORDER BY Year;
```

**I. Highest-margin country + category + age_group combination**

```sql
SELECT country, product_category, age_group,
    ROUND(AVG(profit_margin_num),2) AS Avg_Margin,
    SUM(revenue) AS Total_Rev
FROM sales_data
GROUP BY country, product_category, age_group
ORDER BY Avg_Margin DESC
LIMIT 10;
```

---

## 3. Power BI Dashboard


**Includes:**
- Year selector (2011–2016) and slicers for Country, Age Group, and Gender
- KPI cards: Total Revenue, Avg. Order Value, Profit Margin %, Total Units Sold, Total Profit, Loss Transaction count
- Profit & Revenue Trends chart over time
- Donut chart: Revenue by Product Category (Bikes / Accessories / Clothing)
- Treemap: Revenue by Sub-Category
- Bar chart: Top 10 Products by Revenue

**Headline numbers (all years, all filters):** 85M total revenue · 37.78% profit margin · 1M units sold · 32M total profit · 58 loss transactions.

---

## Project Summary

| Phase | Tool | Outcome |
|---|---|---|
| Data Cleaning | Excel | 113,036 → 112,036 clean, validated rows; added `profit_margin` & `profit_loss` |
| SQL Analysis | MySQL | 9 queries covering time trends, category/product performance, gender split, regional ranking, loss analysis |
| Visualization | Power BI | Interactive dashboard with year/country/age/gender filters |
