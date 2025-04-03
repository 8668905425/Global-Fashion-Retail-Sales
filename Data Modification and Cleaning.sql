select * from customers
select * from discounts
select * from stores
select * from employees
select * from product
select * from transactions
-- Create the currency_exchange_avg table
CREATE TABLE currency_exchange_avg (
    currency_code VARCHAR(3) PRIMARY KEY,
    avg_rate_2023_2025 DECIMAL(10, 4)
);

-- Insert average exchange rates for 2023-2025 (placeholder values)
INSERT INTO currency_exchange_avg (currency_code, avg_rate_2023_2025)
VALUES 
    ('CNY', 7.2500),  -- Example: 1 USD = 7.25 CNY (avg 2023-2025)
    ('EUR', 0.9200),  -- Example: 1 USD = 0.92 EUR
    ('GBP', 0.8000),  -- Example: 1 USD = 0.80 GBP
    ('USD', 1.0000);  -- 1 USD = 1 USD

-- Verify the table
SELECT * FROM currency_exchange_avg;

-- (1)Duplicate Checks
-- Check for duplicate rows in transactions
SELECT Invoice_ID, Line, COUNT(*)
FROM transactions
GROUP BY Invoice_ID, Line
HAVING COUNT(*) > 1;
--  Check for duplicate customers
SELECT Customer_ID, COUNT(*)
FROM customers
GROUP BY Customer_ID
HAVING COUNT(*) > 1;
-- Check for duplicate discount rules
SELECT Start, "End", Category, Sub_Category, COUNT(*)
FROM discounts
GROUP BY Start, "End", Category, Sub_Category
HAVING COUNT(*) > 1;
--  Check for duplicate employees
SELECT Employee_ID, COUNT(*)
FROM employees
GROUP BY Employee_ID
HAVING COUNT(*) > 1;
-- Check for duplicate products
SELECT ID, COUNT(*)
FROM product
GROUP BY ID
HAVING COUNT(*) > 1;
--  Check for duplicate stores
SELECT Store_ID, COUNT(*)
FROM stores
GROUP BY Store_ID
HAVING COUNT(*) > 1;

-- (2)Column Additions
-- Add Year column to transactions
ALTER TABLE transactions ADD COLUMN Year INT;

--  Add Profit column to transactions
ALTER TABLE transactions ADD COLUMN Profit DECIMAL(10,2);

-- Add Profit_Flag column to transactions
ALTER TABLE transactions ADD COLUMN Profit_Flag VARCHAR(10);

-- (3) Data Cleaning
-- Replace NULL job titles with 'Unknown'
UPDATE customers
SET job_title = COALESCE(job_title, 'Unknown');

-- Replace NULL Sizes and Color with 'Unknown' in product
UPDATE product
SET Sizes = COALESCE(Sizes, 'Unknown'), Color = COALESCE(Color, 'Unknown');

--  Replace NULL Size and Color with 'Unknown' in transactions
UPDATE transactions
SET Size = COALESCE(Size, 'Unknown'), Color = COALESCE(Color, 'Unknown');

-- Replace NULL category and sub_category with 'Unknown' in discounts
UPDATE discounts
SET category = COALESCE(category, 'Unknown'), sub_category = COALESCE(sub_category, 'Unknown');

-- Clean Telephone to keep only numbers and '+'
UPDATE customers 
SET Telephone = REGEXP_REPLACE(Telephone, '[^0-9+]', '', 'g');

--  Clean ZIP_Code to keep only numbers
UPDATE stores 
SET ZIP_Code = REGEXP_REPLACE(ZIP_Code, '[^0-9]', '', 'g');

-- (4)Data Type Adjustments
-- Change Discount column type to numeric
ALTER TABLE Discounts
ALTER COLUMN Discount TYPE NUMERIC(5, 2);

-- (5) Data Updates and Calculations
-- Populate Year column from Date
UPDATE transactions 
SET Year = EXTRACT(YEAR FROM Date);
--Populate age column in customers
UPDATE customers 
SET Age = EXTRACT(YEAR FROM AGE(Date_Of_Birth)) 
WHERE Date_Of_Birth IS NOT NULL;

--  Convert discount to percentage
UPDATE discounts 
SET discount = (discount * 100);

--  Calculate Profit
UPDATE transactions t
SET Profit = t.Line_Total - (p.Production_Cost * t.Quantity * cea.avg_rate_2023_2025)
FROM product p, currency_exchange_avg cea
WHERE t.Product_ID = p.ID
  AND t.currency = cea.currency_code;

-- Set Profit_Flag based on Profit
UPDATE transactions 
SET Profit_Flag = CASE WHEN Profit < 0 THEN 'Negative' ELSE 'Positive' END;

-- (6)Analysis Queries
-- Count transactions by Profit_Flag
SELECT profit_flag, (COUNT(*)
FROM transactions 
GROUP BY profit_flag;

