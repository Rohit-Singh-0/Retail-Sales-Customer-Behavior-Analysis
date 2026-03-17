# Retail Sales & Customer Behavior Analysis

This project analyzes transactional retail data to identify revenue drivers, customer concentration, product performance, geographic contribution, and seasonality. It combines Python-based data cleaning and exploratory analysis, SQL business queries, and a Power BI dashboard to present stakeholder-friendly insights from raw invoice-level data.

## Project Overview

The analysis is built on the UCI Online Retail dataset and focuses on converting raw e-commerce transactions into an analysis-ready business dataset. The workflow removes invalid records, engineers revenue and monthly features, evaluates customer behavior, and packages findings into both technical and executive-facing outputs.

## Business Objectives

- Assess overall sales performance through core KPIs.
- Identify top-performing products and customers.
- Measure how revenue is distributed across customer segments.
- Understand geographic revenue concentration by country.
- Evaluate monthly sales trends and seasonality.
- Create assets suitable for portfolio review and business presentation.

## Dataset Summary

- Source dataset size: `541,909` invoice-line records
- Cleaned dataset size: `392,692` records
- Date range: `2010-12-01` to `2011-12-09`
- Granularity: one row per product line within an invoice

### Key Fields

- `InvoiceNo`
- `StockCode`
- `Description`
- `Quantity`
- `InvoiceDate`
- `UnitPrice`
- `CustomerID`
- `Country`
- `Revenue`
- `Month`

## Data Cleaning

The notebook creates an analysis-ready dataset using simple business rules:

- Removed rows with missing `CustomerID`
- Removed exact duplicate rows
- Removed cancelled invoices
- Removed rows with non-positive `Quantity`
- Removed rows with non-positive `UnitPrice`
- Converted `InvoiceDate` to datetime and `CustomerID` to integer
- Engineered `Revenue = Quantity x UnitPrice`
- Created a monthly period field for trend analysis

## Tools Used

- `Python`
- `Pandas`
- `Matplotlib`
- `Jupyter Notebook`
- `MySQL`
- `Power BI`

## Analysis Highlights

### KPI Snapshot

- Total Revenue: `8,887,208.89`
- Total Orders: `18,532`
- Unique Customers: `4,338`
- Unique Products: `3,665`
- Average Order Value: `479.56`
- Average Revenue per Customer: `2,048.69`
- Repeat Customer Rate: `65.58%`

### Key Insights

- Revenue is highly concentrated: the top `20%` of customers contribute `74.68%` of total revenue.
- Top-revenue customers also drive `59.73%` of repeat orders, showing strong dependence on a relatively small customer segment.
- The `United Kingdom` is the dominant market by revenue, contributing `7,285,024.64`.
- `PAPER CRAFT , LITTLE BIRDIE` is the top product by quantity sold.
- Monthly revenue rises sharply into late 2011, with `2011-11` as the strongest month in the cleaned dataset.
- December 2011 is a partial month and should not be compared directly with full months.

## Deliverables

- Jupyter analysis notebook with cleaning, KPI reporting, and visual exploration
- SQL script containing business questions and analytical queries
- Power BI dashboard for interactive reporting
- Executive PDF report for presentation-ready insights

## Repository Structure

```text
.
|-- input_data/
|   |-- data.csv
|   `-- cleaned_data.csv
|-- Retail Sales & Customer Behavior Analysis.ipynb
|-- SQL_dataExploration.sql
|-- retail_sales_dashboard.pbix
|-- Retail_Sales_Executive_Report.pdf
`-- README.md
```

## How to Use

### 1. Review the Notebook

Open [Retail Sales & Customer Behavior Analysis.ipynb](./Retail%20Sales%20%26%20Customer%20Behavior%20Analysis.ipynb) in Jupyter Notebook or VS Code to inspect the full Python workflow.

### 2. Run the SQL Analysis

Use [SQL_dataExploration.sql](./SQL_dataExploration.sql) against a MySQL table named `invoices` populated with the cleaned dataset.

### 3. Open the Dashboard

Use [retail_sales_dashboard.pbix](./retail_sales_dashboard.pbix) in Power BI Desktop to explore the interactive report.

### 4. Read the Executive Summary

Open [Retail_Sales_Executive_Report.pdf](./Retail_Sales_Executive_Report.pdf) for a presentation-ready business summary.

## Reproducing the Project

1. Load the raw dataset from `input_data/data.csv`.
2. Run the notebook cells to clean the data and generate `input_data/cleaned_data.csv`.
3. Optionally load the cleaned dataset into MySQL for SQL analysis.
4. Connect Power BI to the cleaned dataset or SQL output for dashboarding.

## Why This Project Matters

This project demonstrates end-to-end data analytics work: data cleaning, exploratory analysis, KPI design, customer segmentation, SQL reporting, and dashboard storytelling. It is suitable for showcasing practical data analyst skills on GitHub, in a portfolio, or during interviews.
