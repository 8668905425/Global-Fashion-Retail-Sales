
# Global Fashion Retail Analytics SQL Project

## Dataset Overview
Welcome to the **Global Fashion Retail Analytics Dataset**—a synthetic yet powerful dataset simulating two years of transactional data for a multinational fashion retailer. Designed for advanced SQL analysis, this project dives into sales, profit, customer behavior, and operational efficiency across a global footprint.

- **Scale**: 4+ million sales records
- **Coverage**: 35 stores in 7 countries (🇺🇸 US, 🇨🇳 China, 🇩🇪 Germany, 🇬🇧 UK, 🇫🇷 France, 🇪🇸 Spain, 🇵🇹 Portugal)
- **Currencies**: USD, EUR, CNY, GBP
- **Purpose**: Privacy-safe, scalable, and intentionally complex for real-world analytics challenges

### Tables
1. **Transactions**: Sales records with `Invoice_ID`, `Line`, `Customer_ID`, `Product_ID`, `Profit`, `Year`, etc.
2. **Customers**: Demographics like `Customer_ID`, `Name`, `Age`, `Gender`, `Job_Title`.
3. **Discounts**: Campaign details with `Start`, `End`, `Discount`, `Category`.
4. **Employees**: Staff info with `Employee_ID`, `Store_ID`, `Position`.
5. **Product**: Items with `ID`, `Category`, `Sub_Category`, `Production_Cost`.
6. **Stores**: Locations with `Store_ID`, `City`, `Country`, `Latitude`, `Longitude`.
7. **Currency_Exchange_Avg**: Exchange rates with `currency_code`, `avg_rate_2023_2025`.

### Project Goals
This SQL project tackles advanced business questions to uncover insights for a global fashion retailer. From profit growth trends to customer segmentation, it’s built to sharpen your PostgreSQL skills while solving real-world problems.

### Key Features
- **Data Cleaning**: Handled duplicates, NULLs, and added calculated fields like `Profit` and `Year`.
- **Advanced SQL**: Uses joins, window functions, CTEs, and aggregations for deep analysis.
- **Business Focus**: Answers critical questions on profit, staffing, discounts, and more.

### Sample Questions Solved
- **Profit Growth**: "What is the year-over-year profit growth rate by city?"
- **Customer Behavior**: "Which customer groups drive repeat purchases?"
- **Operational Efficiency**: "How does sales per employee vary by city?"

### Getting Started
1. **Setup**: Clone this repo and import the SQL scripts into PostgreSQL.
2. **Schema**: Run `create_tables.sql` to build the database structure.
3. **Data**: Load sample data from CSVs or generate your own with the provided schema.
4. **Queries**: Explore `queries.sql` for ready-to-run analyses.

### Tools
- **Database**: PostgreSQL
- **Analysis**: SQL queries optimized for performance and insight

### Contributions
Feel free to fork, enhance queries, or suggest new analyses! This dataset is your playground for mastering SQL in a retail context.

---

**Unleash the power of data to dress the world in style!**
