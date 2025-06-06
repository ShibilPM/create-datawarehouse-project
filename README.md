# 📊 Create Data Warehouse Project

This project demonstrates the end-to-end process of building a modern data warehouse from scratch using dimensional modeling techniques.  
It encompasses data ingestion, transformation, and modeling to facilitate efficient analytical querying and reporting.

---

## 🧱 Project Architecture

The data warehouse is structured following the **Medallion Architecture**, comprising three layers:

- **Bronze Layer**: Raw data ingestion from source systems (e.g., ERP, CRM) into the staging area.
- **Silver Layer**: Data cleansing, standardization, and transformation processes to prepare data for analysis.
- **Gold Layer**: Business-ready data modeled into a star schema, optimized for reporting and analytics.

---

## 🚀 Getting Started

### Prerequisites

- SQL Server (or any compatible RDBMS)
- SQL Server Management Studio (SSMS)
- Basic understanding of SQL and data warehousing concepts

---

## 🧾 Features

- **Dimensional Modeling**: Implements star schema with fact and dimension tables.
- **Surrogate Keys**: Utilizes `ROW_NUMBER()` for generating surrogate keys in dimensions.
- **Data Enrichment**: Combines data from multiple sources to enrich customer and product information.
- **Performance Logging**: Includes a stored procedure to log the time taken for view creation.

---

## 📊 Sample Views

### `gold.dim_customers`
Contains enriched customer information with attributes like name, country, gender, and birth date.

### `gold.dim_products`
Holds product details including category, subcategory, cost, and product line.

### `gold.fact_sales`
Captures sales transactions linking customers and products, along with sales metrics.

---

## 🛠️ Technologies Used

- SQL Server
- T-SQL
- Dimensional Modeling Techniques

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.

---

## 🤝 Contributing

Contributions are welcome!  
Please fork the repository and submit a pull request for any enhancements or bug fixes.

---

## 📬 Contact

For questions or suggestions, please open an issue in the repository or contact [ShibilPM](https://github.com/ShibilPM).
