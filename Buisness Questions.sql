------------------------------
--Profit Margins by Region--
------------------------------
--Which country and categories yield the highest profit margins, factoring in production costs, discounts?

SELECT 
    s.country,
    p.Category,
    AVG((t.Line_Total - (p.Production_Cost * t.Quantity)) / t.Line_Total) * 100 AS Profit_Margin_Percent,
    SUM(t.Line_Total - (p.Production_Cost * t.Quantity)) AS Total_Profit,
    AVG(p.Production_Cost) AS Avg_Production_Cost,
    AVG(t.Discount) AS Avg_Discount
FROM transactions t
JOIN stores s ON t.Store_ID = s.Store_ID
JOIN product p ON t.Product_ID = p.ID
GROUP BY s.country, p.Category
ORDER BY Profit_Margin_Percent DESC;
--------------------------------
--Employee Efficiency by Region--
--------------------------------
--How does sales per employee vary by city, and which staffing ratios drive higher transaction totals in the US vs. China?
SELECT 
    s.Country,
    COUNT(DISTINCT e.Employee_ID) AS Employee_Count,
    SUM(t.Line_Total) / COUNT(DISTINCT e.Employee_ID) AS Sales_Per_Employee,
    COUNT(DISTINCT e.Employee_ID) / COUNT(DISTINCT t.Store_ID) AS Staffing_Ratio,
    SUM(t.Invoice_Total) AS Total_Transaction_Amount
FROM transactions t
JOIN stores s ON t.Store_ID = s.Store_ID
JOIN employees e ON t.Employee_ID = e.Employee_ID
WHERE s.Country IN ('United States', '中国')
GROUP BY s.Country
ORDER BY Sales_Per_Employee DESC;
------------------------------------
--Customer Segments & Preferences--
------------------------------------
--Which customer groups (age, gender, occupation) drive repeat purchases, and how do their product preferences vary by country?
SELECT 
    c.Gender,
    CASE 
        WHEN c.Age < 25 THEN 'Under 25'
        WHEN c.Age BETWEEN 25 AND 40 THEN '25-40'
        ELSE 'Over 40'
    END AS Age_Group,
    c.Job_Title,
    s.Country,
    COUNT(DISTINCT t.Customer_ID) AS Repeat_Customers,
    p.Category,
    p.Color,
    p.Sizes,
    COUNT(t.Invoice_ID) AS Purchase_Count
FROM transactions t
JOIN customers c ON t.Customer_ID = c.Customer_ID
JOIN stores s ON t.Store_ID = s.Store_ID
JOIN product p ON t.Product_ID = p.ID
GROUP BY c.Gender, Age_Group, c.Job_Title, s.Country, p.Category, p.Color, p.Sizes
HAVING COUNT(t.Invoice_ID) > 1
ORDER BY Purchase_Count DESC;
-----------------------------
--ROI of Discount Campaigns--
-----------------------------
--– Which discount campaigns generate the highest ROI in terms of sales volume and revenue, and how does this differ by category?
SELECT 
    d.Description,
    d.Category,
    SUM(t.Line_Total) AS Revenue_With_Discount,
    SUM(t.Quantity) AS Sales_Volume,
    SUM(t.Profit) AS Total_Profit,
    (SUM(t.Profit) / NULLIF(SUM(t.Line_Total * d.Discount), 0)) AS ROI
FROM transactions t
JOIN discounts d ON t.Date BETWEEN d.Start AND d."End"
JOIN product p ON t.Product_ID = p.ID AND p.Category = d.Category
GROUP BY d.Description, d.Category
ORDER BY ROI DESC;
----------------------------
--Seasonal Sales Predictions--
----------------------------
--Can we predict seasonal sales trends by category using historical data and external factors like holidays?
SELECT 
    p.Category,
    t.Year,
    EXTRACT(MONTH FROM t.Date) AS Month,
    SUM(t.Line_Total) AS Monthly_Revenue,
    SUM(t.Quantity) AS Monthly_Volume,
    COUNT(DISTINCT t.Invoice_ID) AS Transaction_Count,
    CASE 
        WHEN EXTRACT(MONTH FROM t.Date) IN (11, 12) THEN 'Holiday Season'
        ELSE 'Regular Season'
    END AS Season_Type
FROM transactions t
JOIN product p ON t.Product_ID = p.ID
GROUP BY p.Category, t.Year, EXTRACT(MONTH FROM t.Date)
ORDER BY p.Category, t.Year, Month;
---------------------------------
--Pricing Strategies & Behavior--
---------------------------------
--How do pricing strategies (unit vs. discounted price) influence customer behavior in high-traffic stores?
SELECT 
    s.City,
    t.Unit_Price,
    t.Discount,
    AVG(t.Line_Total / t.Quantity) AS Avg_Discounted_Price,
    SUM(t.Quantity) AS Total_Quantity_Sold,
    COUNT(DISTINCT t.Customer_ID) AS Unique_Customers
FROM transactions t
JOIN stores s ON t.Store_ID = s.Store_ID
WHERE s.Store_ID IN (1, 8) -- High-traffic: New York, Guangzhou
GROUP BY s.City, t.Unit_Price, t.Discount
ORDER BY Total_Quantity_Sold DESC;
--------------------------------
--Product Performance Analysis--
--------------------------------
--Which underperforming products should be phased out, and which high-demand items should be prioritized regionally?
SELECT 
    s.City,
    p.Category,
    p.Sub_Category,
    p.ID AS Product_ID,
    SUM(t.Quantity) AS Total_Sold,
    SUM(t.Profit) AS Total_Profit,
    AVG(t.Discount) AS Avg_Discount_Reliance
FROM transactions t
JOIN product p ON t.Product_ID = p.ID
JOIN stores s ON t.Store_ID = s.Store_ID
GROUP BY s.City, p.Category, p.Sub_Category, p.ID
ORDER BY Total_Profit ASC;
-------------------------------
--Proximity & Sales Correlation--
-------------------------------
--Do neighboring stores (e.g., New York vs. LA) show a sales correlation, and how can we use this for targeted marketing?
SELECT 
    s1.City AS City_1,
    s2.City AS City_2,
    SUM(t1.Line_Total) AS Revenue_City_1,
    SUM(t2.Line_Total) AS Revenue_City_2,
    ABS(s1.Latitude - s2.Latitude) + ABS(s1.Longitude - s2.Longitude) AS Distance,
    CORR(t1.Line_Total, t2.Line_Total) AS Sales_Correlation
FROM transactions t1
JOIN stores s1 ON t1.Store_ID = s1.Store_ID
JOIN transactions t2 ON t1.Date = t2.Date
JOIN stores s2 ON t2.Store_ID = s2.Store_ID
WHERE s1.Store_ID < s2.Store_ID -- Avoid self-join duplicates
GROUP BY s1.City, s2.City, s1.Latitude, s1.Longitude, s2.Latitude, s2.Longitude
ORDER BY Distance ASC;
----------------------------------
--Payment Methods & Invoice Totals--
----------------------------------
--How do cash vs. credit payments impact average invoice totals across countries, and how can we boost high-value transactions?
SELECT 
    s.Country,
    t.Payment_Method,
    AVG(t.Invoice_Total) AS Avg_Invoice_Total,
    SUM(t.Invoice_Total) AS Total_Revenue,
    COUNT(t.Invoice_ID) AS Transaction_Count
FROM transactions t
JOIN stores s ON t.Store_ID = s.Store_ID
GROUP BY s.Country, t.Payment_Method
ORDER BY Avg_Invoice_Total DESC;

-----------------------------------
--Demographics & Sales Conversion--
-----------------------------------
--How do customer demographics and store-level factors influence sales conversion rates, and how can we model this for optimization?
SELECT 
    s.City,
    s.Number_of_Employees,
    c.Gender,
    CASE 
        WHEN c.Age < 25 THEN 'Under 25'
        WHEN c.Age BETWEEN 25 AND 40 THEN '25-40'
        ELSE 'Over 40'
    END AS Age_Group,
    COUNT(DISTINCT t.Invoice_ID) / COUNT(DISTINCT t.Customer_ID) AS Conversion_Rate,
    SUM(t.Line_Total) AS Total_Revenue
FROM transactions t
JOIN customers c ON t.Customer_ID = c.Customer_ID
JOIN stores s ON t.Store_ID = s.Store_ID
GROUP BY s.City, s.Number_of_Employees, c.Gender, Age_Group
ORDER BY Conversion_Rate DESC;



