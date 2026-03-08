-- 1. Total Revenue Generated
select round(sum(revenue), 2) as Total_Revenue from invoices;

-- 2. Total Number of Orders
select count(distinct InvoiceNo) as Total_Orders from invoices;

-- 3. Total Number of Unique Customers
select count(distinct CustomerID) as Total_Unique_Customers from invoices;

-- 4. Top 10 Revenue Generating Products
select Description, round(sum(Revenue),2) as Revenue from invoices
group by Description
order by Revenue desc
limit 10;

-- 5. Most Frequently Purchased Products
SELECT Description,
       SUM(Quantity) AS Total_Quantity_Sold
FROM invoices
GROUP BY Description
ORDER BY Total_Quantity_Sold DESC
LIMIT 10;


-- 6. Revenue by Country
select Country, round(sum(Revenue), 2) as Revenue from invoices
group by Country
order by Revenue desc;


-- 7. Average Order Value
SELECT ROUND(AVG(order_value),2) AS Average_Order_Value
FROM (
        SELECT InvoiceNo,
               SUM(Revenue) AS order_value
        FROM invoices
        GROUP BY InvoiceNo
     ) t;

-- 8. Monthly Revenue Trend
select Month, round(sum(Revenue), 2) as Revenue from invoices
group by Month
order by Month;

-- 9. Number of Orders per Country
select Country, count(distinct InvoiceNo) as Orders from invoices
group by Country
order by Orders desc;

-- 10. Top 10 Customers by Revenue
select CustomerID, round(sum(Revenue), 2) as Revenue from invoices
group by CustomerID
order by Revenue desc
limit 10;

-- 11. Customer Purchase Frequency
select CustomerID, count(InvoiceNo) as Purchase_Frequency from invoices
group by CustomerID
order by Purchase_Frequency desc;

-- 12. Products Purchased in Multiple Countries
SELECT Description,
       COUNT(DISTINCT Country) AS Countries_Sold_In
FROM invoices
GROUP BY Description
HAVING COUNT(DISTINCT Country) > 1
ORDER BY Countries_Sold_In DESC;

-- 13. Daily Sales Trend
SELECT DATE(InvoiceDate) AS Date,
       ROUND(SUM(Revenue),2) AS Daily_Revenue
FROM invoices
GROUP BY Date
ORDER BY Date;

-- 14. Orders with Highest Value
SELECT InvoiceNo,
       ROUND(SUM(Revenue),2) AS Order_Value
FROM invoices
GROUP BY InvoiceNo
ORDER BY Order_Value DESC
LIMIT 10;


-- 15. Country Contribution Percentage
SELECT 
    Country,
    ROUND(SUM(Revenue),2) AS Revenue,
    ROUND(
        SUM(Revenue) * 100 /
        (SELECT SUM(Revenue) FROM invoices), 
    2) AS Revenue_Percentage
FROM invoices
GROUP BY Country
ORDER BY Revenue DESC;

-- 16. Repeat Customers
SELECT CustomerID,
       COUNT(DISTINCT InvoiceNo) AS Orders
FROM invoices
GROUP BY CustomerID
HAVING COUNT(DISTINCT InvoiceNo) > 1
ORDER BY Orders DESC;

-- 17. Customer First Purchase Date
SELECT CustomerID,
       MIN(InvoiceDate) AS First_Purchase_Date
FROM invoices
GROUP BY CustomerID
ORDER BY First_Purchase_Date;

-- 18. Best Selling Product in Each Country
SELECT Country, Description, Total_Quantity
FROM (
        SELECT 
            Country,
            Description,
            SUM(Quantity) AS Total_Quantity,
            RANK() OVER(
                PARTITION BY Country 
                ORDER BY SUM(Quantity) DESC
            ) AS rnk
        FROM invoices
        GROUP BY Country, Description
     ) t
WHERE rnk = 1;
