📊 Create Data Warehouse Project
This project demonstrates the end-to-end process of building a modern data warehouse from scratch using dimensional modeling techniques. It encompasses data ingestion, transformation, and modeling to facilitate efficient analytical querying and reporting.
github.com
github.com

🧱 Project Architecture
The data warehouse is structured following the Medallion Architecture, comprising three layers:
github.com

Bronze Layer: Raw data ingestion from source systems (e.g., ERP, CRM) into the staging area.

Silver Layer: Data cleansing, standardization, and transformation processes to prepare data for analysis.

Gold Layer: Business-ready data modeled into a star schema, optimized for reporting and analytics.
github.com

📁 Repository Structure
graphql
Copy
Edit
create-datawarehouse-project/
├── datasets/           # Raw datasets (e.g., ERP and CRM data)
├── docs/               # Documentation and architectural diagrams
├── scripts/            # SQL scripts for view creation and procedures
├── LICENSE             # MIT License
└── README.md           # Project overview and instructions
🚀 Getting Started
Prerequisites
SQL Server (or any compatible RDBMS)

SQL Server Management Studio (SSMS)

Basic understanding of SQL and data warehousing concepts
github.com

Setup Instructions
Clone the Repository:

bash
Copy
Edit
git clone https://github.com/ShibilPM/create-datawarehouse-project.git
cd create-datawarehouse-project
Import Datasets:

Navigate to the datasets/ directory.

Use SQL Server's import wizard or scripts to load the ERP and CRM CSV files into corresponding staging tables.

Execute SQL Scripts:

Open the scripts in the scripts/ directory using SSMS.

Run the scripts in the following order:

create_views.sql – Creates views for dim_customers, dim_products, and fact_sales.

create_views_with_timer.sql – Creates a stored procedure to generate views and log execution time.

Verify Views:

Ensure that the views are correctly created in the gold schema.

Query the views to validate data integrity and relationships.

🧾 Features
Dimensional Modeling: Implements star schema with fact and dimension tables.

Surrogate Keys: Utilizes ROW_NUMBER() for generating surrogate keys in dimensions.

Data Enrichment: Combines data from multiple sources to enrich customer and product information.

Performance Logging: Includes a stored procedure to log the time taken for view creation.
github.com

📊 Sample Views
gold.dim_customers
Contains enriched customer information with attributes like name, country, gender, and birth date.

gold.dim_products
Holds product details including category, subcategory, cost, and product line.

gold.fact_sales
Captures sales transactions linking customers and products, along with sales metrics.

🛠️ Technologies Used
SQL Server

T-SQL

Dimensional Modeling Techniques

Medallion Architecture
github.com
justb.dk
+2
github.com
+2
github.com
+2

📄 License
This project is licensed under the MIT License. See the LICENSE file for details.

🤝 Contributing
Contributions are welcome! Please fork the repository and submit a pull request for any enhancements or bug fixes.

📬 Contact
For questions or suggestions, please open an issue in the repository or contact ShibilPM.

Feel free to customize this README.md further to align with your project's specifics and updates.
