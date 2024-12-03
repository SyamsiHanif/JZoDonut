-- CustomerDimension
SELECT
	CustomerID,
	CustomerName,
	CustomerGender,
	CustomerAddress
FROM [JZoDonut]..MsCustomer

SELECT * FROM [JZoDonut_OLAP]..CustomerDimension

-- StaffDimension
SELECT
	StaffID,
	StaffName,
	StaffGender,
	StaffAddress
FROM [JZoDonut]..MsStaff

SELECT * FROM [JZoDonut_OLAP]..StaffDimension

-- BenefitDimension
SELECT
	BenefitID,
	BenefitName,
	BenefitPrice
FROM [JZoDonut]..MsBenefit

SELECT * FROM [JZoDonut_OLAP]..BenefitDimension

-- DonutDimension
SELECT
	DonutID,
	DonutName,
	DonutPrice
FROM [JZoDonut]..MsDonut

SELECT * FROM [JZoDonut_OLAP]..DonutDimension

-- ReviewDimension
SELECT
	ReviewID,
	ReviewContent
FROM [JZoDonut]..MsReview

SELECT * FROM [JZoDonut_OLAP]..ReviewDimension

-- VendorDimension
SELECT
	VendorID,
	VendorName,
	VendorAddress
FROM [JZoDonut]..MsVendor

SELECT * FROM [JZoDonut_OLAP]..VendorDimension

-- MaterialDimension
SELECT
	MaterialID,
	MaterialName,
	MaterialPrice
FROM [JZoDonut]..MsMaterial

SELECT * FROM [JZoDonut_OLAP]..MaterialDimension

-- TimeDimension
IF EXISTS (
	SELECT LastETL
	FROM [JZoDonut_OLAP]..FilterTimeStamp
)
	BEGIN
		SELECT
			AllDate.Date,
			DAY(AllDate.Date) AS [Day],
			MONTH(AllDate.Date) AS [Month],
			DATEPART(QUARTER, AllDate.Date) AS [Quarter],
			YEAR(AllDate.Date) AS [Year]
		FROM (
			SELECT DISTINCT SalesDate AS [Date]
			FROM [JZoDonut]..TrSalesHeader
			UNION
			SELECT DISTINCT PurchaseDate AS [Date]
			FROM [JZoDonut]..TrPurchaseHeader
			UNION
			SELECT DISTINCT SubscriptionStartDate AS [Date]
			FROM [JZoDonut]..TrSubscriptionHeader
			UNION
			SELECT DISTINCT FeedbackDate AS [Date]
			FROM [JZoDonut]..TrFeedbackHeader
		) AS AllDate, [JZoDonut_OLAP]..FilterTimeStamp
		WHERE AllDate.Date > LastETL
		AND TableName = 'TimeDimension'
	END
ELSE
	BEGIN
		SELECT
			AllDate.Date,
			DAY(AllDate.Date) AS [Day],
			MONTH(AllDate.Date) AS [Month],
			DATEPART(QUARTER, AllDate.Date) AS [Quarter],
			YEAR(AllDate.Date) AS [Year]
		FROM (
			SELECT DISTINCT SalesDate AS [Date]
			FROM [JZoDonut]..TrSalesHeader
			UNION
			SELECT DISTINCT PurchaseDate AS [Date]
			FROM [JZoDonut]..TrPurchaseHeader
			UNION
			SELECT DISTINCT SubscriptionStartDate AS [Date]
			FROM [JZoDonut]..TrSubscriptionHeader
			UNION
			SELECT DISTINCT FeedbackDate AS [Date]
			FROM [JZoDonut]..TrFeedbackHeader
		) AS AllDate
	END;

-- Update & Insert FilterTimeStamp
IF EXISTS (
	SELECT LastETL
	FROM [JZoDonut_OLAP]..FilterTimeStamp
	WHERE TableName = 'TimeDimension'
)
	BEGIN
		UPDATE [JZoDonut_OLAP]..FilterTimeStamp
		SET LastETL = GETDATE()
		WHERE TableName = 'TimeDimension'
	END
ELSE
	BEGIN
		INSERT INTO [JZoDonut_OLAP]..FilterTimeStamp
		VALUES ('TimeDimension', GETDATE())
	END;

SELECT * FROM [JZoDonut_OLAP]..FilterTimeStamp
SELECT * FROM [JZoDonut_OLAP]..TimeDimension

DELETE FROM [JZoDonut_OLAP]..FilterTimeStamp
DELETE FROM [JZoDonut_OLAP]..TimeDimension

-- SalesFact
IF EXISTS (
	SELECT LastETL
	FROM [JZoDonut_OLAP]..FilterTimeStamp
	WHERE TableName = 'SalesFact'
)
	BEGIN
		SELECT
			TimeCode,
			CustomerCode,
			StaffCode,
			DonutCode,
			SUM(md.DonutPrice * Quantity) AS TotalSalesEarnings,
			SUM(Quantity) AS TotalDonutSold
		FROM
			[JZoDonut]..TrSalesHeader trh
			JOIN [JZoDonut]..TrSalesDetail trd
			ON trh.SalesID = trd.SalesID
			JOIN [JZoDonut]..MsDonut md
			ON trd.DonutID = md.DonutID

			JOIN [JZoDonut_OLAP]..TimeDimension td
			ON trh.SalesDate = td.Date
			JOIN [JZoDonut_OLAP]..CustomerDimension cd
			ON trh.CustomerID = cd.CustomerID
			JOIN [JZoDonut_OLAP]..StaffDimension sd
			ON trh.StaffID = sd.StaffID
			JOIN [JZoDonut_OLAP]..DonutDimension dd
			ON trd.DonutID = dd.DonutID
		WHERE trh.SalesDate > (
			SELECT LastETL
			FROM [JZoDonut_OLAP]..FilterTimeStamp
			WHERE TableName = 'SalesFact'
		)
		GROUP BY TimeCode, CustomerCode, StaffCode, DonutCode
	END
ELSE
	BEGIN
		SELECT
			TimeCode,
			CustomerCode,
			StaffCode,
			DonutCode,
			SUM(md.DonutPrice * Quantity) AS TotalSalesEarnings,
			SUM(Quantity) AS TotalDonutSold
		FROM
			[JZoDonut]..TrSalesHeader trh
			JOIN [JZoDonut]..TrSalesDetail trd
			ON trh.SalesID = trd.SalesID
			JOIN [JZoDonut]..MsDonut md
			ON trd.DonutID = md.DonutID

			JOIN [JZoDonut_OLAP]..TimeDimension td
			ON trh.SalesDate = td.Date
			JOIN [JZoDonut_OLAP]..CustomerDimension cd
			ON trh.CustomerID = cd.CustomerID
			JOIN [JZoDonut_OLAP]..StaffDimension sd
			ON trh.StaffID = sd.StaffID
			JOIN [JZoDonut_OLAP]..DonutDimension dd
			ON trd.DonutID = dd.DonutID
		GROUP BY TimeCode, CustomerCode, StaffCode, DonutCode
	END;

-- Update & Insert FilterTimeStamp
IF EXISTS (
	SELECT LastETL
	FROM [JZoDonut_OLAP]..FilterTimeStamp
	WHERE TableName = 'SalesFact'
)
	BEGIN
		UPDATE [JZoDonut_OLAP]..FilterTimeStamp
		SET LastETL = GETDATE()
		WHERE TableName = 'SalesFact'
	END
ELSE
	BEGIN
		INSERT INTO [JZoDonut_OLAP]..FilterTimeStamp
		VALUES ('SalesFact', GETDATE())
	END;

SELECT * FROM [JZoDonut_OLAP]..FilterTimeStamp
SELECT * FROM [JZoDonut_OLAP]..SalesFact

-- PurchaseFact
IF EXISTS (
	SELECT LastETL
	FROM [JZoDonut_OLAP]..FilterTimeStamp
	WHERE TableName = 'PurchaseFact'
)
	BEGIN
		SELECT
			TimeCode,
			StaffCode,
			VendorCode,
			MaterialCode,
			SUM(mm.MaterialPrice* Quantity) AS TotalPurchaseCost,
			SUM(Quantity) AS TotalMaterialPurchased
		FROM
			[JZoDonut]..TrPurchaseHeader tph
			JOIN [JZoDonut]..TrPurchaseDetail tpd
			ON tph.PurchaseID = tpd.PurchaseID
			JOIN [JZoDonut]..MsMaterial mm 
			ON tpd.MaterialID = mm.MaterialID

			JOIN [JZoDonut_OLAP]..TimeDimension td
			ON tph.PurchaseDate = td.Date
			JOIN [JZoDonut_OLAP]..StaffDimension sd
			ON tph.StaffID = sd.StaffID
			JOIN [JZoDonut_OLAP]..VendorDimension vd
			ON tph.VendorID = vd.VendorID
			JOIN [JZoDonut_OLAP]..MaterialDimension md
			ON tpd.MaterialID = md.MaterialID
		WHERE tph.PurchaseDate > (
			SELECT LastETL
			FROM [JZoDonut_OLAP]..FilterTimeStamp
			WHERE TableName = 'PurchaseFact'
		)
		GROUP BY TimeCode, StaffCode, VendorCode, MaterialCode
	END
ELSE
	BEGIN
		SELECT
			TimeCode,
			StaffCode,
			VendorCode,
			MaterialCode,
			SUM(mm.MaterialPrice* Quantity) AS TotalPurchaseCost,
			SUM(Quantity) AS TotalMaterialPurchased
		FROM
			[JZoDonut]..TrPurchaseHeader tph
			JOIN [JZoDonut]..TrPurchaseDetail tpd
			ON tph.PurchaseID = tpd.PurchaseID
			JOIN [JZoDonut]..MsMaterial mm 
			ON tpd.MaterialID = mm.MaterialID

			JOIN [JZoDonut_OLAP]..TimeDimension td
			ON tph.PurchaseDate = td.Date
			JOIN [JZoDonut_OLAP]..StaffDimension sd
			ON tph.StaffID = sd.StaffID
			JOIN [JZoDonut_OLAP]..VendorDimension vd
			ON tph.VendorID = vd.VendorID
			JOIN [JZoDonut_OLAP]..MaterialDimension md
			ON tpd.MaterialID = md.MaterialID
		GROUP BY TimeCode, StaffCode, VendorCode, MaterialCode
	END

SELECT * FROM [JZoDonut_OLAP]..FilterTimeStamp
SELECT * FROM [JZoDonut_OLAP]..PurchaseFact
ORDER BY MaterialCode

-- Update & Insert FilterTimeStamp
IF EXISTS (
	SELECT LastETL
	FROM [JZoDonut_OLAP]..FilterTimeStamp
	WHERE TableName = 'PurchaseFact'
)
	BEGIN
		UPDATE [JZoDonut_OLAP]..FilterTimeStamp
		SET LastETL = GETDATE()
		WHERE TableName = 'PurchaseFact'
	END
ELSE
	BEGIN
		INSERT INTO [JZoDonut_OLAP]..FilterTimeStamp
		VALUES ('PurchaseFact', GETDATE())
	END;

SELECT * FROM [JZoDonut_OLAP]..FilterTimeStamp
SELECT * FROM [JZoDonut_OLAP]..PurchaseFact


-- Subscription Fact
SELECT
	TimeCode,
	CustomerCode,
	StaffCode,
	BenefitCode,
	SUM(bd.BenefitPrice) AS TotalSubscriptionEarning,
	COUNT(tsh.CustomerID) AS TotalSubscriber
FROM 
	[JZoDonut]..TrSubscriptionHeader tsh
	JOIN [JZoDonut]..TrSubscriptionDetail tsd
	ON tsh.SubscriptionID = tsd.SubscriptionID
	JOIN [JZoDonut]..MsBenefit mb
	ON tsd.BenefitID = mb.BenefitID

	JOIN [JZoDonut_OLAP]..TimeDimension td
	ON tsh.SubscriptionStartDate = td.Date
	JOIN [JZoDonut_OLAP]..CustomerDimension cd
	ON tsh.CustomerID = cd.CustomerID
	JOIN [JZoDonut_OLAP]..StaffDimension sd
	ON tsh.StaffID = sd.StaffID
	JOIN [JZoDonut_OLAP]..BenefitDimension bd
	ON tsd.BenefitID = bd.BenefitID
GROUP BY TimeCode, CustomerCode, StaffCode, BenefitCode



-- FeedbackFact
SELECT
	TimeCode,
	CustomerCode,
	ReviewCode,
	COUNT(tfh.FeedbackID)TotalFeedback,
	COUNT(DISTINCT mr.ReviewID) AS TotalCustomerProvidingFeedback
FROM 
	[JZoDonut]..TrFeedbackHeader tfh
	JOIN [JZoDonut]..TrFeedbackDetail tfd
	ON tfh.FeedbackID = tfh.FeedbackID
	JOIN [JZoDonut]..MsReview mr
	ON tfd.ReviewID = mr.ReviewID

	JOIN [JZoDonut_OLAP]..TimeDimension td
	ON tfh.FeedbackDate = td.Date
	JOIN [JZoDonut_OLAP]..CustomerDimension cd
	ON tfh.CustomerID = cd.CustomerID
	JOIN [JZoDonut_OLAP]..ReviewDimension rd
	ON tfd.ReviewID = rd.ReviewID
GROUP BY TimeCode, CustomerCode, ReviewCode;

SELECT
	tfh.CustomerID,
	COUNT(FeedbackID)TotalFeedback,
	COUNT(DISTINCT tfh.CustomerID) AS TotalCustomerProvidingFeedback
FROM 
	[JZoDonut]..TrFeedbackHeader tfh
	JOIN [JZoDonut]..MsCustomer mc
	ON tfh.CustomerID = tfh.CustomerID
GROUP BY tfh.CustomerID

SELECT * FROM 
[JZoDonut]..TrFeedbackHeader tfh
	JOIN [JZoDonut]..TrFeedbackDetail tfd
	ON tfh.FeedbackID = tfh.FeedbackID
	JOIN [JZoDonut]..MsReview mr
	ON tfd.ReviewID = mr.ReviewID