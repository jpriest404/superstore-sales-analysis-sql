# Superstore Sales Analysis: SQL (T-SQL)

A 15-question SQL analysis of the Superstore retail dataset, written in T-SQL (SQL Server), examining where the business makes money, where it loses money, and what drives the difference.

## Business questions answered

**Session 1: First cuts**

1. How large is the dataset: order lines, distinct orders, total sales, total profit?
2. What are sales, profit, and margin by category?
3. What is profit by region?
4. How many distinct customers are in each segment?
5. What are the top 10 products by sales, and are they profitable?

**Session 2: Filtering and grouping**

6. How many order lines in 2024 lost money, and what was the total loss?
7. What is the average discount by category?
8. What are sales by sub-category in the West region?
9. Which customers (name + segment) have more than 20 order lines?
10. For each ship mode: how many distinct orders, what average sales, and what total profit?

**Session 3: Dates and window functions**

11. What were monthly sales in 2024?
12. What was the month-over-month change in 2024 sales?
13. What is the running total of 2024 sales by month?
14. What is the best-selling sub-category within each region?
15. What is each category's share of total company sales?

## Key findings

- The dataset covers 6,500 order lines and 3,446 distinct orders from 2021–2024, totaling **$2,881,924.65 in sales** and **$260,282.21 in profit**.
- **Technology carries the business:** 60.45% of company sales ($1,742,101) at a 15.8% margin. Its profit ($275,334) exceeds the company's total profit, because Furniture's losses eat the difference.
- **Furniture's problem is margin, not demand.** Furniture is 33.48% of sales ($964,735) yet loses money: −$31,701, a −3.29% margin. Furniture products rank among the top sellers; the demand is there; the pricing and discounting are what fail.
- **Tables is the single largest leak.** Tables alone accounts for 65.63% of Furniture sales and loses −$26,617, which is 84% of Furniture's total loss. The Conference Table, the #3 product by sales overall ($401,498), loses money at every discount level and is profitable only at 0% discount.
- **Discounting tracks the losses.** Furniture's average discount is 19.2%, versus 10.1% for Office Supplies and 5.0% for Technology. The discount ranking is the profit ranking in reverse.
- **Growth is volume, not margin.** Sales grew about 49% from 2021 to 2024 ($565,913 to $845,844), while the overall profit margin stayed near 9% every year. In 2024, 344 order lines (about 18% of the year's lines) lost money, totaling −$14,845.
- Regions are not the problem: all four regions are profitable at roughly 9% margin, and sales split almost evenly across them (about 25% each).

## Skills and tools

- **SQL (T-SQL / SQL Server):** aggregations with `GROUP BY`, filtering with `WHERE` and `HAVING`, `COUNT(DISTINCT …)` for true order and customer counts, date functions (`YEAR`, `MONTH`), and conditional analysis by category, region, segment, and ship mode.
- **CTEs:** multi-step queries built as named stages (monthly totals first, then calculations on them).
- **Window functions:** `LAG()` for month-over-month change, `SUM() OVER (ORDER BY …)` for running totals, `RANK() OVER (PARTITION BY …)` for best-per-group rankings, and `SUM() OVER ()` for share-of-total percentages.
- **Tools:** SQL Server, Visual Studio Code.
- **Working method:** every query's results were checked against a known total (for example, monthly 2024 sales summing to the annual total, and ship-mode order counts summing to 3,446 distinct orders) before the result was accepted.

## Dataset

The public Superstore sample dataset, a widely used retail training dataset with order-level sales, profit, discount, category, region, and shipping fields. The analysis ran on a synthetic practice set built on the same schema: 6,500 order lines, 3,446 orders, 220 customers, dated 2021–2024. No real company or customer data is used.

## How the queries are organized

All 15 queries live in one file, `Project-1-Superstore-All-Queries.sql`, in question order:

- **Session 1 (Q1–Q5):** dataset size, category margins, regional profit, customers by segment, top products.
- **Session 2 (Q6–Q10):** money-losing lines, discount by category, regional sub-category detail, high-volume customers (`HAVING`), ship-mode performance.
- **Session 3 (Q11–Q15):** monthly trend, month-over-month change, running totals, best sub-category per region (`RANK()`), and category share of total sales.

Each query is preceded by the business question it answers and followed by the verified result.

## Author

John "Jack" Priest, operations leader transitioning into data analytics.

Portfolio: https://jpriest404.github.io
GitHub: https://github.com/jpriest404
