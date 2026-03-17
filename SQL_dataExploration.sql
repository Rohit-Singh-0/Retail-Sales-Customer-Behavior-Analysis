-- ============================================================
-- Retail Sales & Customer Behavior Analysis
-- Dataset : UCI Online Retail (541,909 rows | cleaned: 392,692)
-- Author  : Rohit Kumar Singh
-- Tool    : MySQL 8.0+
-- ============================================================


-- ============================================================
-- SECTION 1 : BUSINESS KPI SNAPSHOT
-- ============================================================

-- 1. Core Business KPIs — single-query executive summary
SELECT
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    COUNT(DISTINCT CustomerID) AS unique_customers,
    COUNT(DISTINCT StockCode) AS unique_products,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(SUM(Revenue) / COUNT(DISTINCT InvoiceNo), 2) AS avg_order_value,
    ROUND(SUM(Revenue) / COUNT(DISTINCT CustomerID), 2) AS avg_revenue_per_customer
FROM invoices;


-- 2. Total Revenue
SELECT
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM invoices;


-- 3. Total Orders
SELECT
    COUNT(DISTINCT InvoiceNo) AS total_orders
FROM invoices;


-- 4. Total Unique Customers
SELECT
    COUNT(DISTINCT CustomerID) AS total_unique_customers
FROM invoices;


-- ============================================================
-- SECTION 2 : PRODUCT ANALYSIS
-- ============================================================

-- 5. Top 10 Products by Revenue
--    Upgraded: adds quantity context and avg unit price alongside revenue
SELECT
    Description,
    SUM(Quantity) AS total_units_sold,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(AVG(UnitPrice), 2) AS avg_unit_price,
    ROUND(SUM(Revenue) * 100 /
        SUM(SUM(Revenue)) OVER (), 2) AS revenue_share_pct
FROM invoices
GROUP BY Description
ORDER BY total_revenue DESC
LIMIT 10;


-- 6. Top 10 Products by Quantity Sold
--    Upgraded: adds revenue alongside volume to distinguish high-volume
--    low-margin products from high-revenue products
SELECT
    Description,
    SUM(Quantity)              AS total_units_sold,
    ROUND(SUM(Revenue), 2)     AS total_revenue,
    ROUND(AVG(UnitPrice), 2)   AS avg_unit_price
FROM invoices
GROUP BY Description
ORDER BY total_units_sold DESC
LIMIT 10;


-- 7. Products Sold Across the Most Countries
--    Useful for identifying globally popular SKUs
SELECT
    Description,
    COUNT(DISTINCT Country) AS countries_sold_in,
    SUM(Quantity) AS total_units_sold,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM invoices
GROUP BY Description
HAVING COUNT(DISTINCT Country) > 1
ORDER BY countries_sold_in DESC
LIMIT 15;


-- 8. Best-Selling Product in Each Country (Window Function)
--    Uses RANK() to find #1 SKU per market — strong window function showcase
SELECT
    Country,
    Description,
    total_units_sold
FROM (
    SELECT
        Country,
        Description,
        SUM(Quantity) AS total_units_sold,
        RANK() OVER (
            PARTITION BY Country
            ORDER BY SUM(Quantity) DESC
        ) AS rnk
    FROM invoices
    GROUP BY Country, Description
) ranked
WHERE rnk = 1
ORDER BY total_units_sold DESC;


-- ============================================================
-- SECTION 3 : REVENUE & GEOGRAPHIC ANALYSIS
-- ============================================================

-- 9. Revenue by Country with Contribution Percentage
--    CTE pre-aggregates order totals so avg order value is clean and correct
WITH order_totals AS (
    SELECT
        InvoiceNo,
        SUM(Revenue) AS order_value
    FROM invoices
    GROUP BY InvoiceNo
)
SELECT
    i.Country,
    COUNT(DISTINCT i.InvoiceNo)                          AS total_orders,
    ROUND(SUM(i.Revenue), 2)                             AS total_revenue,
    ROUND(AVG(o.order_value), 2)                         AS avg_order_value,
    ROUND(SUM(i.Revenue) * 100 /
        (SELECT SUM(Revenue) FROM invoices), 2)          AS revenue_share_pct
FROM invoices i
JOIN order_totals o ON i.InvoiceNo = o.InvoiceNo
GROUP BY i.Country
ORDER BY total_revenue DESC;


-- 10. Average Order Value
SELECT
    ROUND(SUM(Revenue) / COUNT(DISTINCT InvoiceNo), 2) AS avg_order_value
FROM invoices;


-- 11. Top 10 Highest Value Individual Orders
SELECT
    InvoiceNo,
    CustomerID,
    Country,
    ROUND(SUM(Revenue), 2) AS order_value,
    COUNT(DISTINCT StockCode) AS unique_products
FROM invoices
GROUP BY InvoiceNo, CustomerID, Country
ORDER BY order_value DESC
LIMIT 10;


-- ============================================================
-- SECTION 4 : TIME-SERIES ANALYSIS
-- ============================================================

-- 12. Monthly Revenue Trend with Month-over-Month Growth
--    Upgraded: adds MoM growth % using LAG() window function
WITH monthly AS (
    SELECT
        Month,
        ROUND(SUM(Revenue), 2) AS monthly_revenue
    FROM invoices
    GROUP BY Month
)
SELECT
    Month,
    monthly_revenue,
    LAG(monthly_revenue) OVER (ORDER BY Month)  AS prev_month_revenue,
    ROUND(
        (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY Month))
        * 100.0 / LAG(monthly_revenue) OVER (ORDER BY Month),
    1) AS mom_growth_pct
FROM monthly
ORDER BY Month;


-- 13. Daily Revenue Trend
SELECT
    DATE(InvoiceDate) AS sale_date,
    ROUND(SUM(Revenue), 2) AS daily_revenue,
    COUNT(DISTINCT InvoiceNo) AS daily_orders
FROM invoices
GROUP BY sale_date
ORDER BY sale_date;


-- ============================================================
-- SECTION 5 : CUSTOMER BEHAVIOR ANALYSIS
-- ============================================================

-- 14. Top 10 Customers by Revenue
--    Upgraded: adds order count and avg order value per customer
SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(SUM(Revenue) / COUNT(DISTINCT InvoiceNo), 2)  AS avg_order_value,
    ROUND(SUM(Revenue) * 100 /
        (SELECT SUM(Revenue) FROM invoices), 2) AS revenue_share_pct
FROM invoices
GROUP BY CustomerID
ORDER BY total_revenue DESC
LIMIT 10;


-- 15. Customer Purchase Frequency
-- full result intentional: feeds Power BI frequency distribution chart
SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM invoices
GROUP BY CustomerID
ORDER BY total_orders DESC;


-- 16. Repeat Customers — customers with more than 1 order
SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM invoices
GROUP BY CustomerID
HAVING COUNT(DISTINCT InvoiceNo) > 1
ORDER BY total_orders DESC;


-- 17. Customer Revenue Segmentation — Pareto / Quintile Analysis
--    Core CLV insight: top 20% of customers by revenue
--    Requires MySQL 8.0+ for window functions
WITH customer_revenue AS (
    SELECT
        CustomerID,
        ROUND(SUM(Revenue), 2) AS total_revenue,
        COUNT(DISTINCT InvoiceNo) AS total_orders
    FROM invoices
    GROUP BY CustomerID
),
segmented AS (
    SELECT
        CustomerID,
        total_revenue,
        total_orders,
        NTILE(5) OVER (ORDER BY total_revenue DESC) AS quintile
    FROM customer_revenue
)
SELECT
    CASE quintile
        WHEN 1 THEN 'Top 20%'
        WHEN 2 THEN 'Q2'
        WHEN 3 THEN 'Q3'
        WHEN 4 THEN 'Q4'
        WHEN 5 THEN 'Bottom 20%'
    END AS customer_segment,
    COUNT(CustomerID) AS customer_count,
    ROUND(SUM(total_revenue), 2) AS segment_revenue,
    ROUND(SUM(total_revenue) * 100 /
        SUM(SUM(total_revenue)) OVER (), 2) AS revenue_share_pct,
    ROUND(AVG(total_orders), 1) AS avg_orders_per_customer
FROM segmented
GROUP BY quintile
ORDER BY quintile;


-- 18. Customer First Purchase Date — Cohort Entry Point
SELECT
    CustomerID,
    MIN(DATE(InvoiceDate)) AS first_purchase_date,
    MAX(DATE(InvoiceDate)) AS last_purchase_date,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(Revenue), 2) AS lifetime_revenue,
    DATEDIFF(
        MAX(DATE(InvoiceDate)),
        MIN(DATE(InvoiceDate))
    ) AS customer_lifespan_days
FROM invoices
GROUP BY CustomerID
ORDER BY first_purchase_date;