USE master
GO

CREATE LOGIN [zharenko] WITH PASSWORD=N'****'
GO

USE sqldwschool
GO

CREATE SCHEMA [zharenko_schema]
GO

CREATE USER [zharenko] FOR LOGIN [zharenko] WITH DEFAULT_SCHEMA=[zharenko_schema]
GO

EXEC sp_addrolemember N'db_owner', N'zharenko'
GO

CREATE DATABASE SCOPED CREDENTIAL zharenko_sas
WITH 
	IDENTITY = '***', 
	SECRET = '*****'
GO

CREATE EXTERNAL DATA SOURCE zharenko_data_source  
WITH (   
      TYPE = HADOOP,  
      LOCATION = '*******',
      CREDENTIAL = zharenko_sas
    )  
GO

CREATE EXTERNAL FILE FORMAT [external_file_format_zharenko]
WITH (  
      FORMAT_TYPE = DELIMITEDTEXT,  
      FORMAT_OPTIONS (FIELD_TERMINATOR = N',', STRING_DELIMITER = N'"', FIRST_ROW = 2, USE_TYPE_DEFAULT = True)
	  )
GO


CREATE EXTERNAL TABLE [zharenko_schema].[external_table]
(   
	[VendorID] [int] NULL,
	[tpep_pickup_datetime] [datetime] NULL,
	[tpep_dropoff_datetime] [datetime] NULL,
	[passenger_count] [int] NULL,
	[trip_distance] [real] NULL,
	[RatecodeID] [int] NULL,
	[store_and_fwd_flag] [char](1) NULL,
	[PULocationID] [int] NULL,
	[DOLocationID] [int] NULL,
	[payment_type] [int] NULL,
	[fare_amount] [money] NULL,
	[extra] [money] NULL,
	[mta_tax] [money] NULL,
	[tip_amount] [money] NULL,
	[tolls_amount] [money] NULL,
	[improvement_surcharge] [money] NULL,
	[total_amount] [money] NULL,
	[congestion_surcharge] [money] NULL 
	)

WITH (
      LOCATION = N'yellow_tripdata_2020-01.csv',
      DATA_SOURCE = zharenko_data_source,
      FILE_FORMAT = external_file_format_zharenko
	  )
GO


CREATE TABLE [zharenko_schema].[fact_tripdata]
(   
	[VendorID] [int] NULL,
	[tpep_pickup_datetime] [datetime] NULL,
	[tpep_dropoff_datetime] [datetime] NULL,
	[passenger_count] [int] NULL,
	[trip_distance] [real] NULL,
	[RatecodeID] [int] NULL,
	[store_and_fwd_flag] [char](1) NULL,
	[PULocationID] [int] NULL,
	[DOLocationID] [int] NULL,
	[payment_type] [int] NULL,
	[fare_amount] [money] NULL,
	[extra] [money] NULL,
	[mta_tax] [money] NULL,
	[tip_amount] [money] NULL,
	[tolls_amount] [money] NULL,
	[improvement_surcharge] [money] NULL,
	[total_amount] [money] NULL,
	[congestion_surcharge] [money] NULL 
	)
WITH
(
	DISTRIBUTION = HASH ( [tpep_pickup_datetime] ),
	CLUSTERED COLUMNSTORE INDEX
)
GO


INSERT INTO [zharenko_schema].[fact_tripdata]
SELECT * FROM [zharenko_schema].[external_table]
GO

CREATE TABLE [zharenko_schema].[Vendor]
(
	[ID] [int] NULL,
	[Name] [varchar](100) NULL
)
WITH
(
	DISTRIBUTION = REPLICATE,
	CLUSTERED COLUMNSTORE INDEX
)
GO

CREATE TABLE [zharenko_schema].[RateCode]
(
	[ID] [int] NULL,
	[Name] [varchar](100) NULL
)
WITH
(
	DISTRIBUTION = REPLICATE,
	CLUSTERED COLUMNSTORE INDEX
)
GO


CREATE TABLE [zharenko_schema].[Payment_type]
(
	[ID] [int] NULL,
	[Name] [varchar](100) NULL
)
WITH
(
	DISTRIBUTION = REPLICATE,
	CLUSTERED COLUMNSTORE INDEX
)
GO

