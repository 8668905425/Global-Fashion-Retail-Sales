-----------------------------------------------
--Yearly Profit Growth Rate and Trend Analysis
-----------------------------------------------
--What is the year-over-year profit growth rate by city, and how does the trend indicate financial stability across categories?
WITH ProfitByCityYear AS (
    SELECT 
        s.City,
        t.Year,
        SUM(t.Profit) AS Total_Profit
    FROM transactions t
    JOIN stores s ON t.Store_ID = s.Store_ID
    GROUP BY s.City, t.Year
),
YoYProfit AS (
    SELECT 
        City,
        Year,
        Total_Profit,
        LAG(Total_Profit) OVER (PARTITION BY City ORDER BY Year) AS Prev_Year_Profit
    FROM ProfitByCityYear
)
SELECT 
    City,
    Year,
    Total_Profit,
    Prev_Year_Profit,
    CASE 
        WHEN Prev_Year_Profit IS NOT NULL AND Prev_Year_Profit != 0
        THEN ROUND(((Total_Profit - Prev_Year_Profit) / Prev_Year_Profit) * 100, 2)
        ELSE NULL
    END AS YoY_Profit_Growth_Rate
FROM YoYProfit
ORDER BY City, Year;
------------------------------------------------------
--Profit Forecast for Next Year Using Moving Average
------------------------------------------------------
--What’s the predicted profit for the next year by category and region based on a 3-year moving average, adjusted for discount trends?
WITH YearlyData AS (
    SELECT 
        t.Year,
        s.City,
        p.Category,
        SUM(t.Profit) AS Total_Profit,
        AVG(t.Discount) AS Avg_Discount
    FROM transactions t
    JOIN stores s ON t.Store_ID = s.Store_ID
    JOIN product p ON t.Product_ID = p.ID
    GROUP BY t.Year, s.City, p.Category
),
MovingAvg AS (
    SELECT 
        Year,
        City,
        Category,
        Total_Profit,
        Avg_Discount,
        AVG(Total_Profit) OVER (
            PARTITION BY City, Category 
            ORDER BY Year 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS Three_Year_Moving_Avg,
        AVG(Avg_Discount) OVER (
            PARTITION BY City, Category 
            ORDER BY Year 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS Avg_Discount_Trend
    FROM YearlyData
)
SELECT 
    City,
    Category,
    MAX(Year) + 1 AS Forecast_Year,
    ROUND(Three_Year_Moving_Avg * (1 - Avg_Discount_Trend), 2) AS Forecasted_Profit
FROM MovingAvg
WHERE Year = (SELECT MAX(Year) FROM YearlyData)
GROUP BY City, Category, Three_Year_Moving_Avg, Avg_Discount_Trend
ORDER BY Forecasted_Profit DESC;
-------------------------------------------------
--Cumulative Profit Contribution by Top Products
-------------------------------------------------
--How much cumulative profit do the top 10 products contribute year-over-year, and what’s their share in total profit by region?
WITH ProductProfit AS (
    SELECT 
        EXTRACT(YEAR FROM t.Date) AS Year,
        s.city,
        p.ID AS Product_ID,
        p.Category,
        SUM(t.Profit) AS Product_Profit,
        SUM(SUM(t.Profit)) OVER (PARTITION BY EXTRACT(YEAR FROM t.Date), s.city) AS Total_city_Profit
    FROM transactions t
    JOIN stores s ON t.Store_ID = s.Store_ID
    JOIN product p ON t.Product_ID = p.ID
    GROUP BY EXTRACT(YEAR FROM t.Date), s.city, p.ID, p.Category
),
RankedProducts AS (
    SELECT 
        Year,
        city,
        Product_ID,
        Category,
        Product_Profit,
        Total_city_Profit,
        RANK() OVER (PARTITION BY Year, city ORDER BY Product_Profit DESC) AS Profit_Rank
    FROM ProductProfit
)
SELECT 
    Year,
    city,
    STRING_AGG(
        CASE WHEN Profit_Rank <= 10 THEN Product_ID::TEXT END, 
        ', '
    ) AS Top_10_Products,
    SUM(CASE WHEN Profit_Rank <= 10 THEN Product_Profit ELSE 0 END) AS Top_10_Profit,
    Total_city_Profit,
    ROUND((SUM(CASE WHEN Profit_Rank <= 10 THEN Product_Profit ELSE 0 END) / Total_city_Profit) * 100, 2) AS Top_10_Profit_Share
FROM RankedProducts
GROUP BY Year, city, Total_city_Profit
ORDER BY Year, city;
--------------------------------------------
--Profit Volatility by Country and Category
---------------------------------------------
--Which countries and product categories show the highest profit volatility year-over-year, and how does this impact financial planning?"
WITH YearlyProfit AS (
    SELECT 
        EXTRACT(YEAR FROM t.Date) AS Year,
        s.Country,
        p.Category,
        SUM(t.Profit) AS Total_Profit
    FROM transactions t
    JOIN stores s ON t.Store_ID = s.Store_ID
    JOIN product p ON t.Product_ID = p.ID
    GROUP BY EXTRACT(YEAR FROM t.Date), s.Country, p.Category
),
ProfitStats AS (
    SELECT 
        Country,
        Category,
        AVG(Total_Profit) AS Avg_Profit,
        STDDEV(Total_Profit) AS Profit_StdDev,
        (STDDEV(Total_Profit) / NULLIF(AVG(Total_Profit), 0)) * 100 AS Volatility_Percent
    FROM YearlyProfit
    GROUP BY Country, Category
)
SELECT 
    Country,
    Category,
    Avg_Profit,
    Profit_StdDev,
    Volatility_Percent
FROM ProfitStats
ORDER BY Volatility_Percent DESC;
----------------------------------------
--Break-Even Analysis by Store and Year
----------------------------------------
--Which stores achieved break-even or profit each year, considering fixed costs per employee and production costs, and how does this trend predict future viability?"
WITH StoreProfit AS (
    SELECT 
        EXTRACT(YEAR FROM t.Date) AS Year,
        s.Store_ID,
        s.Country,
        SUM(t.Profit) AS Total_Profit,
        COUNT(DISTINCT e.Employee_ID) AS Employee_Count,
        SUM(p.Production_Cost * t.Quantity) AS Total_Production_Cost
    FROM transactions t
    JOIN stores s ON t.Store_ID = s.Store_ID
    JOIN employees e ON t.Employee_ID = e.Employee_ID
    JOIN product p ON t.Product_ID = p.ID
    GROUP BY EXTRACT(YEAR FROM t.Date), s.Store_ID, s.Country
),
BreakEven AS (
    SELECT 
        Year,
        Store_ID,
        Country,
        Total_Profit,
        Total_Production_Cost,
        Employee_Count * 50000 AS Fixed_Cost_Per_Year, -- Assuming $50,000/employee/year
        (Total_Profit - (Total_Production_Cost + (Employee_Count * 50000))) AS Net_Profit_After_Fixed,
        CASE 
            WHEN (Total_Profit - (Total_Production_Cost + (Employee_Count * 50000))) > 0 THEN 'Profitable'
            WHEN (Total_Profit - (Total_Production_Cost + (Employee_Count * 50000))) = 0 THEN 'Break-Even'
            ELSE 'Loss'
        END AS Financial_Status
    FROM StoreProfit
)
SELECT 
    Year,
    Store_ID,
    Country,
    Total_Profit,
    Total_Production_Cost,
    Fixed_Cost_Per_Year,
    Net_Profit_After_Fixed,
    Financial_Status,
    RANK() OVER (PARTITION BY Store_ID ORDER BY Year) AS Year_Rank
FROM BreakEven
ORDER BY Country, Store_ID, Year;














































select distinct currency from transactions






























































