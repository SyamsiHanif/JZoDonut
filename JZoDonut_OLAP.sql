CREATE DATABASE JZoDonut_OLAP

USE JZoDonut_OLAP

CREATE TABLE TimeDimension(
	TimeCode INT PRIMARY KEY IDENTITY(1,1),
	[Date] DATE,
	[Day] INT,
	[Month] INT,
	[Quarter] INT,
	[Year] INT
);

CREATE TABLE CustomerDimension(
	CustomerCode INT PRIMARY KEY IDENTITY(1,1),
	CustomerID CHAR(7),
	CustomerName VARCHAR(50),
	CustomerGender CHAR(1),
	CustomerAddress VARCHAR(100),
	ValidFrom DATETIME,
	ValidTo DATETIME
);

CREATE TABLE StaffDimension(
	StaffCode INT PRIMARY KEY IDENTITY(1,1),
	StaffID CHAR(7),
	StaffName VARCHAR(50),
	StaffGender CHAR(1),
	StaffAddress VARCHAR(100),
	ValidFrom DATETIME,
	ValidTo DATETIME
);

CREATE TABLE BenefitDimension(
	BenefitCode INT PRIMARY KEY IDENTITY(1,1),
	BenefitID CHAR(7),
	BenefitName VARCHAR(200),
	BenefitPrice INT,
	ValidFrom DATETIME,
	ValidTo DATETIME
);

CREATE TABLE DonutDimension(
	DonutCode INT PRIMARY KEY IDENTITY(1,1),
	DonutID CHAR(7),
	DonutName VARCHAR(100),
	DonutPrice INT,
	ValidFrom DATETIME,
	ValidTo DATETIME
);

CREATE TABLE ReviewDimension(
	ReviewCode INT PRIMARY KEY IDENTITY(1,1),
	ReviewID CHAR(7),
	ReviewContent VARCHAR(100)
);

CREATE TABLE VendorDimension(
	VendorCode INT PRIMARY KEY IDENTITY(1,1),
	VendorID CHAR(7),
	VendorName VARCHAR(50),
	VendorAddress VARCHAR(100),
	ValidFrom DATETIME,
	ValidTo DATETIME
);

CREATE TABLE MaterialDimension(
	MaterialCode INT PRIMARY KEY IDENTITY(1,1),
	MaterialID CHAR(7),
	MaterialName VARCHAR(100),
	MaterialPrice INT,
	ValidFrom DATETIME,
	ValidTo DATETIME
);

CREATE TABLE SalesFact(
	TimeCode INT,
	CustomerCode INT,
	StaffCode INT,
	DonutCode INT,
	TotalSalesEarnings BIGINT,
	TotalDonutSold BIGINT
);

CREATE TABLE PurchaseFact(
	TimeCode INT,
	StaffCode INT,
	VendorCode INT,
	MaterialCode INT,
	TotalPurchaseCost BIGINT,
	TotalMaterialPurchased BIGINT
);

CREATE TABLE SubscriptionFact(
	TimeCode INT,
	CustomerCode INT,
	StaffCode INT,
	BenefitCode INT,
	TotalSubscriptionEarning BIGINT,
	TotalSubscriber BIGINT
);

CREATE TABLE FeedbackFact(
	TimeCode INT,
	CustomerCode INT,
	ReviewCode INT,
	TotalFeedback BIGINT,
	TotalCustomerProvidingFeedback BIGINT
);

CREATE TABLE FilterTimeStamp(
	TableName VARCHAR(50),
	LastETL DATE
);

