USE DWProperty
GO

truncate table RAW_SalesTransactions
truncate table RAW_rentalTransactions
------------------ INSERTING NEW RECORD INTO FACT TABLE WITH UPDATE SCD---------------
insert into RAW_SalesTransactions (PropertyID,PropertyType,PropertyTenureType,PropertyNumberOfFloors,PropertynumberOfUnits,
PropertyYearOfCompletion,PropertyInSubzone,PropertyLatitude,PropertyLongitude,PropertyInPostalSector,PropertyInPostalDistrict,
FloorNoOfTransactedUnit,NumberOfBedroomsInTransactedUnit,TransactedPricePerSqFt,TransactionType,TransactionDate)
values(999999,7,2,30,87,1993,69,1.29650389,103.8933927,43,15,10,NULL,3482,2,'05/01/14')
--------------------------- INSERT NEW DATA INTO STAGING TABLES ---------------------------
TRUNCATE TABLE STG_SalesTransactions 
TRUNCATE TABLE STG_RentalTransactions

INSERT INTO STG_SalesTransactions([PropertyID],[TransactedPricePerSqFt],[TransactionType],[TransactionDate]) 
SELECT [PropertyID],[TransactedPricePerSqFt],[TransactionType],[TransactionDate] FROM RAW_SalesTransactions
INSERT INTO STG_RentalTransactions([PropertyID],[MonthlyRentAmount],[TransactionDate]) 
SELECT [PropertyID],[MonthlyRentAmount],[TransactionDate] FROM RAW_RentalTransactions


TRUNCATE TABLE [STG_Property]
INSERT [STG_Property]
select *  from (
SELECT distinct [PropertyID] ,
		[PropertyType] ,
		CASE WHEN PropertyTenureType = '1' THEN 'Freehold'
			WHEN PropertyTenureType = '2' THEN 'Leasehold'
			ELSE 'Unknown'
		END AS [PropertyTenureType] ,
		[PropertyNumberOfFloors] ,
		[PropertynumberOfUnits] ,
		[PropertyYearOfCompletion] ,
		PropertyInSubzone ,
		[PropertyLatitude] ,
		[PropertyLongitude] ,
		[PropertyInPostalSector] ,
		[PropertyInPostalDistrict], 
		[NumberOfBedroomsInTransactedUnit],
		TransactionDate
FROM (SELECT *, ROW_NUMBER() OVER(PARTITION BY [PropertyID] ORDER BY TransactionDate DESC) AS rownumber FROM dbo.RAW_SalesTransactions) A
WHERE rownumber = 1
UNION
SELECT DISTINCT r.[PropertyID] ,
		r.[PropertyType] ,
		CASE WHEN r.PropertyTenureType = '1' THEN 'Freehold'
			WHEN r.PropertyTenureType = '2' THEN 'Leasehold'
			ELSE 'Unknown'
		END AS [PropertyTenureType] ,
		r.[PropertyNumberOfFloors] ,
		r.[PropertynumberOfUnits] ,
		r.[PropertyYearOfCompletion] ,
		r.PropertyInSubzone ,
		r.[PropertyLatitude] ,
		r.[PropertyLongitude] ,
		r.[PropertyInPostalSector] ,
		r.[PropertyInPostalDistrict] ,
		r.NoOfBedroomsInTransactedUnit,
		r.TransactionDate
FROM (SELECT *, ROW_NUMBER() OVER(PARTITION BY [PropertyID] ORDER BY TransactionDate DESC) AS rownumber 
		FROM dbo.RAW_rentalTransactions) r LEFT JOIN RAW_SalesTransactions s ON r.[PropertyID] = s.[PropertyID]
WHERE rownumber = 1 AND s.[PropertyID] IS NULL )c
ORDER BY [PropertyID]



--------------------------- 1.Update the list of property in Dim_Property ---------------------------
UPDATE S SET SubzoneID = SUB.SUBZONE_CODE
FROM [STG_Property] S JOIN DIM_SUBZONE SUB ON S.SubzoneID = SUB.SUBZONE_ID 

MERGE INTO [Dim_Property] AS T
USING [STG_Property] AS S
ON T.PropertyID = S.PropertyID
WHEN MATCHED AND T.[PropertyTenureType] != S.[PropertyTenureType] AND T.[LastTransactionDate] < CONVERT(DATE,S.[LastTransactionDate])
	THEN 
	UPDATE SET PreviousTenureType = T.[PropertyTenureType] ------> UPDATE SCD [PropertyTenureType]
		, [PropertyTenureType] = S.[PropertyTenureType]
		, [LastTransactionDate] = CONVERT(DATE,S.[LastTransactionDate])
WHEN NOT MATCHED THEN --------------> INSERT NEW PROPERTY INTO DIM_PROPERTY
    INSERT ([PropertyID]
           ,[PropertyType]
           ,[PropertyTenureType]
           ,[PropertyNumberOfFloors]
           ,[PropertynumberOfUnits]
           ,[PropertyYearOfCompletion]
           ,[PropertyLatitude]
           ,[PropertyLongitude]
           ,[PropertyInPostalSector]
           ,[PropertyInPostalDistrict]
           ,[NumberOfBedroomsInTransactedUnit]
           ,[SubzoneCode]
		   ,[LastTransactionDate])
	VALUES( S.[PropertyID]
      ,S.[PropertyType]
      ,S.[PropertyTenureType]
      ,S.[PropertyNumberOfFloors]
      ,S.[PropertynumberOfUnits]
      ,S.[PropertyYearOfCompletion]
	  ,S.[PropertyLatitude]
      ,S.[PropertyLongitude]
	  ,S.[PropertyInPostalSector]
      ,S.[PropertyInPostalDistrict]
	  ,S.NumberOfBedroomsInTransactedUnit
	  ,S.SubzoneID -- [SUBZONE_CODE]
	  ,CONVERT(DATE,S.[LastTransactionDate])); 


	 
--------------------------- 2. Insert data into 2 Fact tables ---------------------------
MERGE INTO Fact_PropertySales AS T
USING STG_SalesTransactions AS S
ON T.PropertyID = S.PropertyID AND T.[TransactionDate] = convert(date,S.TransactionDate)
WHEN NOT MATCHED THEN
    INSERT ([PropertyID]
           ,[TransactedPricePerSqFt]
           ,[TransactionType]
           ,[TransactionDate])
	VALUES(S.[PropertyID]
           ,S.[TransactedPricePerSqFt]
		   ,S.[TransactionType]
           ,S.[TransactionDate]); 


MERGE INTO Fact_PropertyRentals AS T
USING STG_RentalTransactions AS R
ON T.PropertyID = R.PropertyID AND T.[TransactionDate] = CONVERT(DATE,R.TransactionDate)
WHEN NOT MATCHED THEN
    INSERT ([PropertyID]
           ,[MonthlyRentAmount]
           ,[TransactionDate])
	VALUES(R.[PropertyID]
           ,R.[MonthlyRentAmount]
           ,R.[TransactionDate]); 



		   
--------------------------- 3. Update Average Sales Price for Subzone which the new property transaction belongs to ---------------------------
SELECT [SubzoneCode],TransactionYear,PropertyType, Avg_Transaction_Price_PerSqFt , DateKey
	INTO tmpTable
from
(
select p.[SubzoneCode],year(TransactionDate) as TransactionYear, 'Private' as PropertyType, CONVERT(DATE,DATEADD(yy, DATEDIFF(yy, 0, TransactionDate), 0)) DateKey,
AVG(convert(FLOAT,TransactedPricePerSqFt)) as Avg_Transaction_Price_PerSqFt 
from dbo.[Fact_PropertySales] T 
	JOIN [Dim_Property] P ON T.PropertyID = P.PropertyID
where PropertyType ='Private' group by [SubzoneCode],year(TransactionDate), CONVERT(DATE,DATEADD(yy, DATEDIFF(yy, 0, TransactionDate), 0)) 
union
select p.[SubzoneCode],year(TransactionDate) as TransactionYear, 'Public' as PropertyType,CONVERT(DATE,DATEADD(yy, DATEDIFF(yy, 0, TransactionDate), 0)) DateKey,
AVG(convert(FLOAT,TransactedPricePerSqFt)) as Avg_Transaction_Price_PerSqFt 
from dbo.[Fact_PropertySales] T 
	JOIN [Dim_Property] P ON T.PropertyID = P.PropertyID
where PropertyType ='Public' group by [SubzoneCode],year(TransactionDate), CONVERT(DATE,DATEADD(yy, DATEDIFF(yy, 0, TransactionDate), 0)) 
union
select p.[SubzoneCode],year(TransactionDate) as TransactionYear, 'Landed' as PropertyType,CONVERT(DATE,DATEADD(yy, DATEDIFF(yy, 0, TransactionDate), 0)) DateKey,
AVG(convert(FLOAT,TransactedPricePerSqFt)) as Avg_Transaction_Price_PerSqFt
from dbo.[Fact_PropertySales] T 
	JOIN [Dim_Property] P ON T.PropertyID = P.PropertyID
where PropertyType ='Landed' group by [SubzoneCode],year(TransactionDate), CONVERT(DATE,DATEADD(yy, DATEDIFF(yy, 0, TransactionDate), 0)) 
   ) a order by TransactionYear, [SubzoneCode] desc


MERGE INTO FACT_SUBZONE_TRANSACTION AS T
USING tmpTable AS R -- summarized transaction at subzone level
ON T.SUBZONE_CODE = R.[SubzoneCode] 
	AND T.TRANSACTION_YEAR = R.TransactionYear 
	AND T.PROPERTY_TYPE = R.PropertyType
WHEN MATCHED THEN -- Exist one record for this subzone in the same year period and same property type
	UPDATE SET AVG_TRANSACTION_PSF = R.Avg_Transaction_Price_PerSqFt
WHEN NOT MATCHED THEN -- Insert new record for one subzone with new year period or new property type
    INSERT ([SUBZONE_CODE]
           ,[TRANSACTION_YEAR]
           ,[PROPERTY_TYPE]
           ,[AVG_TRANSACTION_PSF]
           ,[DateKey])
	VALUES(R.[SubzoneCode]
			,R.TransactionYear
			,R.PropertyType
			,R.Avg_Transaction_Price_PerSqFt
			,R.DateKey); 

DROP TABLE tmpTable

/*
use DWProperty
go
delete from STG_SalesTransactions where TransactedPricePerSqFt='3482';
*/
/*
use DWProperty
go
select * from dim_property;
*/


select PropertyID,propertytype,PropertyTenureType,PreviousTenureType,LastTransactionDate
from Dim_Property where PropertyID='999999'
