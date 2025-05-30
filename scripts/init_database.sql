/*
========================================================
Create Database and schemas
========================================================
Script Purpose:
	Create a new database named 'DataWarehouse' after checking if it already exists.
	If the database exists, it is droped and recreated. 
	The script sets up three schemas within the database: bronze, silver and gold

Warning:
	Running this script will drop the enitire 'DataWarehouse' database if exists.
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END
GO

-- Create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

--Create schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
