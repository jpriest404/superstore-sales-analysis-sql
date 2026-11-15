-- ================================================================
-- PROJECT 1 - SUPERSTORE: QUERIES (MASTER FILE)
-- Data: 6,500 order lines, 3,446 orders, 220 customers, 2021-2024.
-- ================================================================


-- ================================================================
-- SESSION 1 - First cuts (COMPLETE 2026-11-12)
-- Verified queries; Jack's results matched these exactly.
-- ================================================================

-- Q1 - How big is this dataset? Lines, orders, sales, profit.
-- 6,500 lines / 3,446 orders / $2,881,924.65 sales / $260,282.21 profit
SELECT COUNT(*) AS order_lines,
       COUNT(DISTINCT order_id) AS orders,
       ROUND(SUM(sales), 2) AS total_sales,
       ROUND(SUM(profit), 2) AS total_profit
FROM dbo.superstore_orders;

-- Q2 - Sales, profit, and margin by category.
-- Technology $1,742,101 / +$275,334 / 15.8% - Furniture $964,735 / -$31,701 / -3.29%
-- Headline: Technology earns more than the whole company keeps; Furniture eats the difference.
SELECT category,
       ROUND(SUM(sales), 2) AS total_sales,
       ROUND(SUM(profit), 2) AS total_profit,
       ROUND(100.0 * SUM(profit) / SUM(sales), 1) AS margin_pct
FROM dbo.superstore_orders
GROUP BY category
ORDER BY total_sales DESC;

-- Q3 - Profit by region. Central $68,262 / East $66,480 / South $63,707 / West $61,833.
-- All four profitable at ~9% margin - the Session 1 problem is categories, not regions.
SELECT region,
       ROUND(SUM(sales), 2) AS total_sales,
       ROUND(SUM(profit), 2) AS total_profit
FROM dbo.superstore_orders
GROUP BY region
ORDER BY total_profit DESC;

-- Q4 - Distinct customers by segment: Consumer 88, Home Office 73, Corporate 59 = 220.
-- Segments partition customers (a customer sits in exactly one segment).
SELECT segment, COUNT(DISTINCT customer_id) AS customers
FROM dbo.superstore_orders
GROUP BY segment;

-- Q5 - Top 10 products by sales.
-- #1 Office Copier 3000 ($519,757). Twist: #3 Conference Table ($401,498) LOSES $16,973,
-- and all four Furniture products in the top 10 lose money - margin problem, not demand.
SELECT TOP 10 product_name, category,
       ROUND(SUM(sales), 2) AS total_sales,
       ROUND(SUM(profit), 2) AS total_profit
FROM dbo.superstore_orders
GROUP BY product_name, category
ORDER BY total_sales DESC;

-- Follow-up (2026-11-12): Conference Table by discount level -
-- +$5,079 at 0% discount, loses money at EVERY discount level; ~3 of 4 lines discounted.
-- (Finding recorded from his session; query pattern: same as Q5 with a discount filter/grouping.)


-- ================================================================
-- REVIEW DRILLS -
-- ================================================================

-- DRILL 1 - NULLs & missing data (SQL Practice space Query Lab, SQLite, orders_dirty)
-- Find the NULLs by counting: COUNT(column) skips NULLs, COUNT(*) does not.
-- Result: 416 rows; discount present in only 369 - 47 NULL discounts.
SELECT COUNT(*) AS total_rows,
       COUNT(order_date) AS has_date,
       COUNT(customer_name) AS has_name,
       COUNT(segment) AS has_segment,
       COUNT(sales) AS has_sales,
       COUNT(discount) AS has_discount
FROM orders_dirty;

-- The trap: discount = 0 catches the 142 true zeros but silently misses the 47 NULLs.
SELECT COUNT(*) FROM orders_dirty WHERE discount = 0;        -- 142
SELECT COUNT(*) FROM orders_dirty WHERE discount IS NULL;    -- 47

-- Dirty casing splits a GROUP BY: mixed case gave 4 variants per segment instead of 3.
-- Fix in the query: TRIM for stray spaces + UPPER/LOWER to force one case.
SELECT UPPER(TRIM(segment)) AS segment_clean, COUNT(*) AS rows_n
FROM orders_dirty
GROUP BY UPPER(TRIM(segment))
ORDER BY segment_clean;

-- DRILL 2 - Filtering & dates (SQL Server)
-- Sales by year - all four rows matched the verified figures exactly.
SELECT YEAR(order_date) AS order_year,
       COUNT(*) AS order_lines,
       SUM(sales) AS total_sales
FROM dbo.superstore_orders
GROUP BY YEAR(order_date)
ORDER BY order_year;

-- Q4-only across all years (WHERE filters before grouping).
SELECT YEAR(order_date) AS order_year,
       COUNT(*) AS order_lines,
       SUM(sales) AS q4_sales
FROM dbo.superstore_orders
WHERE MONTH(order_date) IN (10, 11, 12)
GROUP BY YEAR(order_date)
ORDER BY order_year;

-- Furniture by year (corrected version): loses money ALL four years
-- (-$6,495 / -$8,435 / -$8,781 / -$7,991) while sales rise ~51%.
-- First attempt summed SALES under a "profit" label - caught, fixed, re-run.
-- Lesson of the day, twice: verify what you actually summed or counted.
SELECT YEAR(order_date) AS order_year,
       COUNT(*) AS order_lines,
       ROUND(SUM(sales), 2) AS total_sales,
       ROUND(SUM(profit), 2) AS total_profit,
       ROUND(SUM(profit) / COUNT(*), 2) AS profit_per_line,
       ROUND(100 * SUM(profit) / SUM(sales), 2) AS profit_margin_pct
FROM dbo.superstore_orders
WHERE category = 'Furniture'
GROUP BY YEAR(order_date)
ORDER BY order_year;


-- ================================================================
-- SESSION 2 - Filtering and grouping (COMPLETE 2026-11-13)
-- ================================================================

-- Q6 - All order lines from 2024 with profit below 0: how many, what total loss?
-- Result: 344 lines, -$14,845.04 (about 18% of 2024's lines lost money)
SELECT
    COUNT(*) AS total,
    ROUND(SUM(profit), 2) AS total_loss
FROM
    dbo.superstore_orders
WHERE
    YEAR(order_date) = 2024 AND
    profit < 0;

-- Q7 - Avg discount by category. Highest discounted category.
-- Result: Furniture 0.1923, Office Supplies 0.1008, Technology 0.0499
-- The discount ranking is the profit ranking flipped.
SELECT
    category,
    ROUND(AVG(discount), 4) AS avg_discount
FROM
    dbo.superstore_orders
GROUP BY
    category
ORDER BY
    avg_discount DESC;

-- Q8 - Sales by sub-category in the West region only, highest first.
-- Result: 16 sub-categories; Tables #1 at $167,929.40
SELECT
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales
FROM
    dbo.superstore_orders
WHERE
    region = 'West'
GROUP BY
    sub_category
ORDER BY
    total_sales DESC;

-- Q9 - Customers (name + segment) with more than 20 order lines. (HAVING)
-- Result: 180 customers; top: Emma Kim (Consumer) 92 lines
-- Note: a name is not an ID - some names appear under two segments.
SELECT
    customer_name AS customer,
    segment,
    COUNT(*) AS total
FROM
    dbo.superstore_orders
GROUP BY
    customer_name, segment
HAVING
    COUNT(*) > 20
ORDER BY
    total DESC;

-- Q10 - For each ship mode: number of orders, average sales per line, total profit.
-- Result: Same Day 922 / $437.94 / $70,506.74; First Class 843 / $440.07 / $70,366.08;
--         Standard Class 805 / $446.73 / $61,272.62; Second Class 876 / $449.66 / $58,136.77
-- Distinct orders sum to exactly 3,446 (ship modes partition orders; categories do not).
SELECT
    ship_mode,
    COUNT(DISTINCT order_id) AS number_of_unique_orders,
    ROUND(AVG(sales), 2) AS avg_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM
    dbo.superstore_orders
GROUP BY
    ship_mode
ORDER BY
    total_profit DESC;


-- ================================================================
-- SESSION 3 - Dates and window functions 
-- Q11-Q13 complete 2026-11-13. Q14 paused mid-build the same evening
-- (checkpoint: two-CTE structure solved - grouped sales, then RANK -
-- remaining step is the outer filter, WHERE rnk = 1; resumes Sat 2026-11-14).
-- Q15 appended when completed.
-- ================================================================

-- Q11 - Monthly sales for 2024, in date order. (Jack's query)
-- Result: Jul is the trough ($45,548); Nov/Dec surge ($100,145 / $104,922);
-- the 12 months sum to the 2024 total, $845,844.15.
SELECT
    MONTH(order_date) AS month_ordered,
    ROUND(SUM(sales), 2) AS total_sales
FROM
    dbo.superstore_orders
WHERE
    YEAR(order_date) = 2024
GROUP BY
    MONTH(order_date)
ORDER BY
    month_ordered;

-- Q12 - Month-over-month change in 2024 sales, LAG() in a CTE. (Jack's query)
-- Result: Jan prev/change NULL (correct - no prior month). Biggest gain Nov +$42,883.20;
-- biggest drops Oct -$25,251.90 and Jul -$22,173.85; Aug rebounds +$23,864.75.
WITH monthly AS (
    SELECT
        MONTH(order_date) AS month_ordered,
        ROUND(SUM(sales), 2) AS total_sales
    FROM
        dbo.superstore_orders
    WHERE
        YEAR(order_date) = 2024
    GROUP BY
        MONTH(order_date)
)
SELECT month_ordered,
       total_sales,
       LAG(total_sales) OVER (ORDER BY month_ordered) AS prev_month_sales,
       total_sales - LAG(total_sales) OVER (ORDER BY month_ordered) AS mom_change
FROM monthly
ORDER BY month_ordered;

-- Q13 - Running total of sales through 2024, by month. (Jack's query - run as
-- an extension of Q12's output; running_total column shown.)
-- Result: December lands on $845,844.15 - exactly the 2024 total. Self-proving.
WITH monthly AS (
    SELECT
        MONTH(order_date) AS month_ordered,
        ROUND(SUM(sales), 2) AS total_sales
    FROM
        dbo.superstore_orders
    WHERE
        YEAR(order_date) = 2024
    GROUP BY
        MONTH(order_date)
)
SELECT month_ordered,
       total_sales,
       SUM(total_sales) OVER (ORDER BY month_ordered) AS running_total
FROM monthly
ORDER BY month_ordered;

-- Q14 - Best-selling sub-category within each region, RANK(). 
-- Result: Machines tops Central ($202,401.60), East ($202,429.80) and South
-- ($167,573.50); West is the exception - Tables #1 at $167,929.40, and West
-- Tables loses money (-$5,208.37 per Q8 follow-up): the West's best seller
-- is a money-loser.
WITH sales AS (
    SELECT
        region,
        sub_category,
        ROUND(SUM(sales), 2) AS total_sales
    FROM
        dbo.superstore_orders
    GROUP BY
        region, sub_category
),
ranked AS (
    SELECT
        region,
        sub_category,
        total_sales,
        RANK() OVER (PARTITION BY region ORDER BY total_sales DESC) AS rnk
    FROM
        sales
)
SELECT
    region,
    sub_category,
    total_sales
FROM
    ranked
WHERE rnk = 1;

-- Q15 - Each category's share of total company sales. 
-- Result: Technology 60.45% ($1,742,101.34), Furniture 33.48% ($964,735.00),
-- Office Supplies 6.08% ($175,088.30). Shares sum to 100.01% on rounding.
-- Story: Technology is three-fifths of the company; Furniture is a third of
-- sales and still loses money.
SELECT
    category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(sales) * 100.0 / SUM(SUM(sales)) OVER(), 2) AS share_company
FROM
    dbo.superstore_orders
GROUP BY
    category
ORDER BY
    category, share_company DESC;
