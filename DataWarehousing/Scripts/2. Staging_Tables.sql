USE [DWProperty]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'STG_Property')
	CREATE TABLE [dbo].[STG_Property](
		[PropertyID] [varchar](50) NULL,
		[PropertyType] [varchar](50) NULL,
		[PropertyTenureType] [varchar](50) NULL,
		[PropertyNumberOfFloors] [varchar](50) NULL,
		[PropertynumberOfUnits] [varchar](50) NULL,
		[PropertyYearOfCompletion] [varchar](50) NULL,
		[SubzoneID] [varchar](50) NULL,
		[PropertyLatitude] [varchar](50) NULL,
		[PropertyLongitude] [varchar](50) NULL,
		[PropertyInPostalSector] [varchar](50) NULL,
		[PropertyInPostalDistrict] [varchar](50) NULL,
		[NumberOfBedroomsInTransactedUnit] [varchar](50) NULL,
		[LastTransactionDate] VARCHAR(50) NULL,
	) ON [PRIMARY]
else
	print 'Table STG_Property Exist Already !!!!'
GO

SET ANSI_PADDING OFF
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'STG_RentalTransactions')
	CREATE TABLE [dbo].[STG_RentalTransactions](
		[PropertyID] [varchar](50) NULL,
		[MonthlyRentAmount] [varchar](50) NULL,
		[TransactionDate] [varchar](50) NULL
	) ON [PRIMARY]
else
	print 'Table STG_RentalTransactions Exist Already !!!!'
GO

SET ANSI_PADDING OFF
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'STG_SalesTransactions')
	CREATE TABLE [dbo].[STG_SalesTransactions](
		[PropertyID] [varchar](50) NULL,
		[TransactedPricePerSqFt] [varchar](50) NULL,
		[TransactionType] [varchar](50) NULL,
		[TransactionDate] [varchar](50) NULL
	) ON [PRIMARY]
else
	print 'Table STG_SalesTransactions Exist Already !!!!'
GO

SET ANSI_PADDING OFF
GO




SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'STG_ACCESSIBILITY')
	CREATE TABLE [dbo].[STG_ACCESSIBILITY](
		AccessibilityID [varchar](30) NULL,
		[Name] [varchar](50) NULL,
		[Type] [varchar](50) NULL,
		[Latitude] [varchar](50) NULL,
		[Longitude] [varchar](50) NULL,
		[SubzoneID] [varchar](50) NULL
	) ON [PRIMARY]
else
	print 'Table STG_ACCESSIBILITY Exist Already !!!!'
GO

SET ANSI_PADDING OFF
GO

TRUNCATE TABLE [STG_ACCESSIBILITY]
INSERT [STG_ACCESSIBILITY](AccessibilityID
		,Name
		,Type
		,Latitude
		,Longitude
		,SubzoneID)
SELECT 'T'+Id, POI_Name
		, POI_Type
		,POI_Latitude
		,POI_Longitude
		,POI_InSubzone
FROM RAW_PointOfInterests
WHERE POI_Type IN ('MRT', 'Bus Stop')


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'STG_PropertySpatialMetricAssets')
	CREATE TABLE [dbo].[STG_PropertySpatialMetricAssets](
		[PropertyID] [varchar](20) NULL,
		[NumberofSchoolsWithin500Mts] INT NULL,
		[NumberOfMRTsWithin500Mts] INT NULL,
		[NumberOfBusStopsWithin500Mts] INT NULL,
		[TimeToRafflesByCarInSeconds] INT NULL,
		[TimeToRafflesByPublicTransportInSeconds] INT NULL,
		[TimeToAirportByCarInSeconds] INT NULL,
		[TimeToAirportByPublicTransportInSeconds] INT NULL,
		[ListMRTNearby] VARCHAR(250) NULL,
		[ListBusStopNearby] VARCHAR(500) NULL
	) ON [PRIMARY]
else
	print 'Table STG_PropertySpatialMetricAssets Exist Already !!!!'
GO

SET ANSI_PADDING OFF
GO


/******************Inserting into Staging Tables************************/

TRUNCATE TABLE [STG_SalesTransactions]
INSERT [STG_SalesTransactions](PropertyID
	,TransactedPricePerSqFt
	,TransactionType
	,TransactionDate)
SELECT PropertyID
	,TransactedPricePerSqFt
	,TransactionType
	,TransactionDate
FROM RAW_SalesTransactions


TRUNCATE TABLE [STG_RentalTransactions]
INSERT [STG_RentalTransactions](PropertyID
	,MonthlyRentAmount
	,TransactionDate)
SELECT PropertyID
	,MonthlyRentAmount
	,TransactionDate
FROM RAW_RentalTransactions


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
WHERE rownumber = 1 AND s.[PropertyID] IS NULL )c -- 731220
ORDER BY [PropertyID]



TRUNCATE TABLE [STG_PropertySpatialMetricAssets]
INSERT INTO [STG_PropertySpatialMetricAssets](PropertyID
		,NumberofSchoolsWithin500Mts
		,NumberOfMRTsWithin500Mts
		,NumberOfBusStopsWithin500Mts
		,TimeToRafflesByCarInSeconds
		,TimeToRafflesByPublicTransportInSeconds
		,TimeToAirportByCarInSeconds
		,TimeToAirportByPublicTransportInSeconds
		,ListMRTNearby
		,ListBusStopNearby)
SELECT PropertyID
		,NumberofSchoolsWithin500Mts
		,NumberOfMRTsWithin500Mts
		,NumberOfBusStopsWithin500Mts
		,TimeToRafflesByCarInSeconds
		,TimeToRafflesByPublicTransportInSeconds
		,TimeToAirportByCarInSeconds
		,TimeToAirportByPublicTransportInSeconds
		,ListMRTNearby
		,ListBusStopNearby
FROM [RAW_PropertySpatialMetricAssets]



/******************Create Staging Table for community club - Amenity************************/
if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'STG_AMENITY_COMMUNITY_CLUB')
begin
CREATE TABLE [dbo].[STG_AMENITY_COMMUNITY_CLUB](
	[SHAPEID] [varchar](50) NULL,
	[X] [varchar](50) NULL,
	[Y] [varchar](50) NULL,
	OBJECTID [varchar](50) NULL,
	[CC_NAME] [varchar](50) NULL,
	[CC_DESCRIPTION] [varchar](50) NULL,
	[ADDRESS_FLOOR] [varchar](50) NULL,
	[ADDRESS_UNIT] [varchar](50) NULL,
	[ADDRESS_BLOCK] [varchar](50) NULL,
	[ADDRESS_BUNIT] [varchar](50) NULL,
	[ADDRESS] [varchar](50) NULL,
	[ADDRESS_POS] [varchar](100) NULL,
	[ADDRESS_TYPE] [varchar](50) NULL,
	[SUBZONE_NO] [varchar](50) NULL,
	[SUBZONE_CODE] [varchar](50) NULL,
	[SUBZONE_NAME] [varchar](50) NULL,
	[PLN_AREA_CODE] [varchar](50) NULL,
	[PLN_AREA_NAME] [varchar](50) NULL,
	[REGION_CODE] [varchar](max) NULL,
	[REGION_NAME] [varchar](50) NULL,
	) ON [PRIMARY]
	end
else
print 'Table STG_AMENITY_COMMUNITY_CLUB Exist Already !!!!'
GO
/******************Inserting into the Staging Table for community club - Amenity************************/
begin
TRUNCATE TABLE STG_AMENITY_COMMUNITY_CLUB
insert into dbo.STG_AMENITY_COMMUNITY_CLUB 
select shapeid,x,y,OBJECTID,NAME,descriptio,addressflo,addressuni,addressblo,addressbui,addressstr,addresspos,addresstyp,subzone_no,subzone_c,subzone_n,pln_area_c,pln_area_n,region_c,region_n 
from dbo.RAW_AMENITY_COMMUNITY_CLUB;
end


/******************Create Staging Table for Gyms - Amenity************************/
if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'STG_AMENITY_GYMS')
begin
CREATE TABLE [dbo].[STG_AMENITY_GYMS](
	[SHAPEID] [varchar](50) NULL,
	[X] [varchar](50) NULL,
	[Y] [varchar](50) NULL,
	OBJECTID [varchar](50) NULL,
	[GYM_NAME] [nvarchar](255) NULL,
	[ADDRESS_FLOOR] [varchar](50) NULL,
	[ADDRESS_UNIT] [varchar](50) NULL,
	[ADDRESS_BLOCK] [varchar](50) NULL,
	[ADDRESS_BUNIT] [nvarchar](255) NULL,
	[ADDRESS] [text] NULL,
	[ADDRESS_POS] [varchar](50) NULL,
	[SUBZONE_NO] [nvarchar](255) NULL,
	[SUBZONE_CODE] [nvarchar](255) NULL,
	[SUBZONE_NAME] [nvarchar](255) NULL,
	[PLN_AREA_CODE] [nvarchar](255) NULL,
	[PLN_AREA_NAME] [nvarchar](255) NULL,
	[REGION_CODE] [nvarchar](255) NULL,
	[REGION_NAME] [nvarchar](255) NULL,
	) ON [PRIMARY]
	end
else
print 'Table STG_AMENITY_GYMS Exist Already !!!!'
GO
/******************Inserting into the Staging Table for Gyms - Amenity************************/
begin
TRUNCATE TABLE STG_AMENITY_GYMS
insert into dbo.STG_AMENITY_GYMS 
select shapeid,x,y,OBJECTID,NAME,addressflo,addressuni,addressblo,addressbui,addressstr,addresspos,subzone_no,subzone_c,subzone_n,pln_area_c,pln_area_n,region_c,region_n 
from dbo.RAW_AMENITY_GYMS;
end



/******************************************HAWKER CENTRE*************************************************/
/******************Create Staging Table for Hawker Centre - Amenity************************/
if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'STG_AMENITY_HAWKER_CENTRE')
begin
CREATE TABLE [dbo].[STG_AMENITY_HAWKER_CENTRE](
	[SHAPEID] [varchar](50) NULL,
	[X] [varchar](50) NULL,
	[Y] [varchar](50) NULL,
	OBJECTID [varchar](50) NULL,
	[HC_NAME] [varchar](50) NULL,
	[HC_DESCRIPTION] [varchar](50) NULL,
	[ADDRESS_FLOOR] [varchar](50) NULL,
	[ADDRESS_BLOCK] [varchar](50) NULL,
	[ADDRESS_UNIT] [varchar](50) NULL,
	[ADDRESS_BUNIT] [varchar](50) NULL,
	[ADDRESS] [varchar](50) NULL,
	[ADDRESS_POS] [varchar](50) NULL,
	[ADDRESS_TYPE] [varchar](50) NULL,
	[SUBZONE_NO] [varchar](50) NULL,
	[SUBZONE_CODE] [varchar](50) NULL,
	[SUBZONE_NAME] [varchar](50) NULL,
	[PLN_AREA_CODE] [varchar](50) NULL,
	[PLN_AREA_NAME] [varchar](50) NULL,
	[REGION_CODE] [varchar](50) NULL,
	[REGION_NAME] [varchar](50) NULL,
	) ON [PRIMARY]
	end
else
print 'Table STG_AMENITY_HAWKER_CENTRE Exist Already !!!!'
GO
/******************Inserting into the Staging Table for Hawker Centre - Amenity************************/
begin
TRUNCATE TABLE STG_AMENITY_HAWKER_CENTRE
insert into dbo.STG_AMENITY_HAWKER_CENTRE 
select shapeid,x,y,OBJECTID,NAME,descriptio,addressflo,addressuni,addressblo,addressbui,addressstr,addresspos,addresstyp,subzone_no,subzone_c,subzone_n,pln_area_c,pln_area_n,region_c,region_n 
from dbo.RAW_AMENITY_HAWKER_CENTRE;
end


/******************************************PARKS*************************************************/
/******************Create Staging Table for Parks-Amenity************************/

if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'STG_AMENITY_PARKS')
begin
CREATE TABLE [dbo].[STG_AMENITY_PARKS](
	[SHAPEID] [nvarchar](255) NULL,
	[X] [varchar](50) NULL,
	[Y] [varchar](50) NULL,
	OBJECTID [varchar](50) NULL,
	[PARK_NAME] [nvarchar](255) NULL,
	[PARK_DESCRIPTION] [nvarchar](max) NULL,
	[ADDRESS_FLOOR] [nvarchar](255) NULL,
	[ADDRESS_UNIT] [nvarchar](255) NULL,
	[ADDRESS_BLOCK] [nvarchar](255) NULL,
	[ADDRESS_BUNIT] [nvarchar](255) NULL,
	[ADDRESS_POS] [varchar](50) NULL,
	[SUBZONE_NO] [nvarchar](255) NULL,
	[SUBZONE_CODE] [nvarchar](255) NULL,
	[SUBZONE_NAME] [nvarchar](255) NULL,
	[PLN_AREA_CODE] [nvarchar](255) NULL,
	[PLN_AREA_NAME] [nvarchar](255) NULL,
	[REGION_CODE] [nvarchar](255) NULL,
	[REGION_NAME] [nvarchar](255) NULL,
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

	end
else
print 'Table STG_AMENITY_PARKS Exist Already !!!!'
GO
/******************Inserting into the Staging Table for Parks - Amenity************************/
begin
TRUNCATE TABLE STG_AMENITY_PARKS
insert into dbo.STG_AMENITY_PARKS 
select shapeid,x,y,OBJECTID,NAME,descriptio,addressflo,addressuni,addressblo,addressbui,addresspos,subzone_no,subzone_c,subzone_n,pln_area_c,pln_area_n,region_c,region_n 
from dbo.RAW_AMENITY_PARKS;
end


/******************************************SPORTS FIELD*************************************************/

/******************Create Staging Table for Sports Field-Amenity************************/

if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'STG_AMENITY_SPORTS')
begin
CREATE TABLE [dbo].[STG_AMENITY_SPORTS](
	[SHAPEID] [nvarchar](255) NULL,
	[X] [varchar](50) NULL,
	[Y] [varchar](50) NULL,
	OBJECTID [varchar](50) NULL,
	[NAME] [nvarchar](255) NULL,
	[ADDRESS_FLOOR] [nvarchar](255) NULL,
	[ADDRESS_UNIT] [nvarchar](255) NULL,
	[ADDRESS_BLOCK] [nvarchar](255) NULL,
	[ADDRESS_BUNIT] [nvarchar](255) NULL,
	[ADDRESS] [nvarchar](255) NULL,
	[ADDRESS_POS] [varchar](50) NULL,
	[SUBZONE_NO] [varchar](50) NULL,
	[SUBZONE_CODE] [nvarchar](255) NULL,
	[SUBZONE_NAME] [nvarchar](255) NULL,
	[PLN_AREA_CODE] [nvarchar](255) NULL,
	[PLN_AREA_NAME] [nvarchar](255) NULL,
	[REGION_CODE] [nvarchar](255) NULL,
	[REGION_NAME] [nvarchar](255) NULL,
	) ON [PRIMARY]

	end
else
print 'Table STG_AMENITY_SPORTS Exist Already !!!!'
GO
/******************Inserting into the Staging Table for Sports Field - Amenity************************/
begin
TRUNCATE TABLE STG_AMENITY_SPORTS
insert into dbo.STG_AMENITY_SPORTS 
select shapeid,x,y,OBJECTID,NAME,addressflo,addressuni,addressblo,addressbui,addressstr,addresspos,subzone_no,subzone_c,subzone_n,pln_area_c,pln_area_n,region_c,region_n 
from dbo.RAW_AMENITY_SPORTS;
end


/******************************************KINDER GARTEN*************************************************/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
/******************Create Staging Table for KinderGarten-Amenity************************/
if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'STG_AMENITY_KINDER')
begin
CREATE TABLE [dbo].[STG_AMENITY_KINDER](
	[SHAPEID] [float] NULL,
	[X] [float] NULL,
	[Y] [float] NULL,
	OBJECTID [varchar](50) NULL,
	[NAME] [nvarchar](255) NULL,
	[DESCRIPTION] [nvarchar](255) NULL,
	[ADDRESS_FLOOR] [nvarchar](255) NULL,
	[ADDRESS_UNIT] [nvarchar](255) NULL,
	[ADDRESS_BLOCK] [nvarchar](255) NULL,
	[ADDRESS_BUNIT] [nvarchar](255) NULL,
	[ADDRESS] [nvarchar](255) NULL,
	[ADDRESS_POS] [float] NULL,
	[ADDRESS_TYPE] [nvarchar](255) NULL,
	[SUBZONE_NO] [float] NULL,
	[SUBZONE_CODE] [nvarchar](255) NULL,
	[SUBZONE_NAME] [nvarchar](255) NULL,
	[PLN_AREA_CODE] [nvarchar](255) NULL,
	[PLN_AREA_NAME] [nvarchar](255) NULL,
	[REGION_CODE] [nvarchar](255) NULL,
	[REGION_NAME] [nvarchar](255) NULL,
	) ON [PRIMARY]

	end
else
print 'Table STG_AMENITY_KINDER Exist Already !!!!'
GO


/******************Inserting into the Staging Table for Kinder Garten - Amenity************************/
begin
TRUNCATE TABLE STG_AMENITY_KINDER
DELETE FROM RAW_AMENITY_KINDER WHERE OBJECTID IN (86, 88,90,93,96) -- DELETE DUPLICATE DATA IN RAW

insert into dbo.STG_AMENITY_KINDER 
select shapeid,x,y,OBJECTID,NAME,descriptio,addressflo,addressuni,addressblo,addressbui,addressstr,addresspos,addresstyp,subzone_no,subzone_c,subzone_n,pln_area_c,pln_area_n,region_c,region_n 
from dbo.RAW_AMENITY_KINDER;
end



SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'STG_AMENITY')
	CREATE TABLE [dbo].[STG_AMENITY](
		AmenityID varchar(30) NOT NULL,
		[NAME] [varchar](250) NULL,
		[Longitude] [varchar](50) NULL,
		[Latitude] [varchar](50) NULL,
		[ADDRESS] [varchar](250) NULL,
		[AmenityType] varchar(50) null,
		[SUBZONE_CODE] [varchar](50) NULL
	) ON [PRIMARY] 
else
	print 'Table STG_AMENITY Exist Already !!!!'
GO

SET ANSI_PADDING OFF
GO


/******************Inserting into the [STG_AMENITY] ************************/
TRUNCATE TABLE [STG_AMENITY]
INSERT [STG_AMENITY](NAME,Longitude,Latitude,AmenityID,[ADDRESS],AmenityType,SUBZONE_CODE)
SELECT CC_NAME,X,Y,'CC'+OBJECTID
,ISNULL(REPLACE([ADDRESS_UNIT],'NULL', '')+' ','')+ISNULL(REPLACE([ADDRESS_BUNIT],'NULL', '')+' ','')+ISNULL(REPLACE(CONVERT(VARCHAR,[ADDRESS]),'NULL', '')+' ','')+ISNULL('#'+REPLACE([ADDRESS_FLOOR],'NULL', '')+' ','')+ISNULL('BLK'+REPLACE([ADDRESS_BLOCK],'NULL', '')+' ','')+ISNULL(REPLACE([ADDRESS_POS],'NULL', '')+' ','')
,'Community Club' AmenityType,SUBZONE_CODE
FROM STG_AMENITY_COMMUNITY_CLUB
UNION
SELECT GYM_NAME,X,Y,'GY'+OBJECTID
,ISNULL(REPLACE([ADDRESS_UNIT],'NULL', '')+' ','')+ISNULL(REPLACE([ADDRESS_BUNIT],'NULL', '')+' ','')+ISNULL(REPLACE(CONVERT(VARCHAR,[ADDRESS]),'NULL', '')+' ','')+ISNULL('#'+REPLACE([ADDRESS_FLOOR],'NULL', '')+' ','')+ISNULL('BLK'+REPLACE([ADDRESS_BLOCK],'NULL', '')+' ','')+ISNULL(REPLACE([ADDRESS_POS],'NULL', '')+' ','')
,'Gyms' AmenityType,SUBZONE_CODE
FROM STG_AMENITY_GYMS
UNION
SELECT HC_NAME,X,Y,'HC'+OBJECTID
,ISNULL(REPLACE([ADDRESS_UNIT],'NULL', '')+' ','')+ISNULL(REPLACE([ADDRESS_BUNIT],'NULL', '')+' ','')+ISNULL(REPLACE(CONVERT(VARCHAR,[ADDRESS]),'NULL', '')+' ','')+ISNULL('#'+REPLACE([ADDRESS_FLOOR],'NULL', '')+' ','')+ISNULL('BLK'+REPLACE([ADDRESS_BLOCK],'NULL', '')+' ','')+ISNULL(REPLACE([ADDRESS_POS],'NULL', '')+' ','')
,'Hawker Centre' AmenityType,SUBZONE_CODE
FROM STG_AMENITY_HAWKER_CENTRE
UNION
SELECT NAME,X,Y,'KG'+OBJECTID
,ISNULL(REPLACE([ADDRESS_UNIT],'NULL', '')+' ','')+ISNULL(REPLACE([ADDRESS_BUNIT],'NULL', '')+' ','')+ISNULL(REPLACE(CONVERT(VARCHAR,[ADDRESS]),'NULL', '')+' ','')+ISNULL('#'+REPLACE([ADDRESS_FLOOR],'NULL', '')+' ','')+ISNULL('BLK'+REPLACE([ADDRESS_BLOCK],'NULL', '')+' ','')+ISNULL(REPLACE([ADDRESS_POS],'NULL', '')+' ','')
,'Kinder garten' AmenityType,SUBZONE_CODE
FROM STG_AMENITY_KINDER
UNION
SELECT PARK_NAME,X,Y,'PA'+OBJECTID
,'' ,'Park' AmenityType,SUBZONE_CODE
FROM STG_AMENITY_PARKS
UNION
SELECT NAME,X,Y,'SP'+OBJECTID
,ISNULL(REPLACE([ADDRESS_UNIT],'NULL', '')+' ','')+ISNULL(REPLACE([ADDRESS_BUNIT],'NULL', '')+' ','')+ISNULL(REPLACE(CONVERT(VARCHAR,[ADDRESS]),'NULL', '')+' ','')+ISNULL('#'+REPLACE([ADDRESS_FLOOR],'NULL', '')+' ','')+ISNULL('BLK'+REPLACE([ADDRESS_BLOCK],'NULL', '')+' ','')+ISNULL(REPLACE([ADDRESS_POS],'NULL', '')+' ','')
,'Sport' AmenityType,SUBZONE_CODE
FROM STG_AMENITY_SPORTS



/******************Create Staging Table for Population-Density************************/
if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'STG_POPULATION_DENSITY')
begin
CREATE TABLE [dbo].[STG_POPULATION_DENSITY](
	[PlanningArea] [nvarchar](255) NULL,
	[Subzone] [nvarchar](255) NULL,
	[Total] [varchar](20) not null, 
	[YoungAge_Population] [varchar](20) NULL,
	[MiddelAge_Population] [varchar](20) NULL,
	[OldAge_Population] [varchar](20) NULL,
	) ON [PRIMARY]

	end
else
print 'Table STG_POPULATION_DENSITY Exist Already !!!!'
GO

/*********************Insert into Staging Population Table************************************/
begin
TRUNCATE TABLE [STG_POPULATION_DENSITY]
insert into [STG_POPULATION_DENSITY] 
select [PlanningArea],[Subzone],[Total], ([0 to 4]+[05 to 09]+[10 to 14]+[15 to 19]+[20 to 24]+[25 to 29]) as YoungAge_Population, ([30 to 34]+[35 to 39]+[40 to 44]+[45 to 49]+[50 to 54]+[55 to 59]) as MiddelAge_Population ,([60 to 64]+[65 to 69]+[70 to 74]+[75 to 79]+[80 to 84]+[85]) as OldAge_Population  
from [RAW_POPULATION_DENSITY];
end

/******************Create Staging Table for Dengue-Cluster************************/
if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'STG_DENGUE_CLUSTER')
begin
CREATE TABLE [dbo].[STG_DENGUE_CLUSTER](
	[SUBZONE_C] [nvarchar](255) not NULL,
	[OBJECTID_2] [nvarchar](255) not NULL,
	[CASE_SIZE] [nvarchar](255) not NULL,
	[NAME] [nvarchar](255) not NULL,
	[X_ADDR_2] [nvarchar](255) not NULL,
	[Y_ADDR_2] [nvarchar](255) not NULL,
	[SHAPE_Le_2] [nvarchar](255) not NULL,
	[SHAPE_Ar_2] [nvarchar](255) not NULL,
	[Area_Covered_Subzone] [nvarchar](255) not NULL,
	) ON [PRIMARY]
end
else
	print 'Table STG_DENGUE_CLUSTER Exist Already !!!!'
GO


/*********************Insert into Staging Dengue Table************************************/
begin 
TRUNCATE TABLE [STG_DENGUE_CLUSTER]
insert into [STG_DENGUE_CLUSTER]
Select [SUBZONE_C],[OBJECTID_2],[CASE_SIZE],[NAME],[X_ADDR_2],[Y_ADDR_2],[SHAPE_Le_2],[SHAPE_Ar_2],[area] as Area_Covered_Subzone 
from [RAW_DENGUE_CLUSTER];
end


/******************Create Staging Table for Malaria************************/

if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'STG_MALARIA_CLUSTER')
begin
CREATE TABLE [dbo].[STG_MALARIA_CLUSTER](
	[SUBZONE_C] [nvarchar](255) not NULL,
	[OBJECTID_2] [nvarchar](255) not NULL,
	[ID][nvarchar](255) not NULL,
	[GRC][nvarchar](255) not NULL,
	[CONSTCY][nvarchar](255) not NULL,
	[REGIONAL_O][nvarchar](255) not NULL,
	[X_ADDR_2] [nvarchar](255) not NULL,
	[Y_ADDR_2] [nvarchar](255) not NULL,
	[SHAPE_Le_2] [nvarchar](255) not NULL,
	[SHAPE_Ar_2] [nvarchar](255) not NULL,
	[Area_Covered_Subzone] [nvarchar](255) not NULL,
	) ON [PRIMARY]
end
else
	print 'Table STG_MALARIA_CLUSTER Exist Already !!!!'
GO


/*********************Insert into Staging Malaria Table************************************/
begin
TRUNCATE TABLE [STG_MALARIA_CLUSTER]
insert into [STG_MALARIA_CLUSTER] 
select [SUBZONE_C],[OBJECTID_2],[ID],[GRC],[CONSTCY],[REGIONAL_O],[X_ADDR_2],[Y_ADDR_2],[SHAPE_Le_2],[SHAPE_Ar_2],[Area_Covered_Subzone] 
from [RAW_MALARIA_CLUSTER];
end




/******************Create Staging Table ************************/

if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'STG_CRIME_RECORDED_BY_NPCS')
begin
	CREATE TABLE [dbo].[STG_CRIME_RECORDED_BY_NPCS](
	[Year] [float] NULL,
	[NPC_Name] [nvarchar](255) NULL,
	[Offence] [nvarchar](255) NULL,
	[Number_Of_Cases] [float] NULL
	) ON [PRIMARY]	
end
else 
	print 'Table STG_CRIME_RECORDED_BY_NPCS Exist Already !!!!'
GO

TRUNCATE TABLE [STG_CRIME_RECORDED_BY_NPCS]
INSERT INTO [dbo].[STG_CRIME_RECORDED_BY_NPCS]
			   ([Year]
			   ,[NPC_Name]
			   ,[Offence]
			   ,[Number_Of_Cases])
	SELECT [Year]
		,NPC
		,Offence
		,NumberOfCases
	FROM dbo.RAW_CRIME_RECORDED_BY_NPCS

UPDATE STG_CRIME_RECORDED_BY_NPCS 
SET [Number_Of_Cases] = 0
WHERE [Number_Of_Cases] is NULL


if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'STG_INTERSECT_DATA')
begin	
	CREATE TABLE [dbo].[STG_INTERSECT_DATA](
		[NPC_Name] [nvarchar](255) NULL,
		Shape_Area_NPC [float] NULL,	
		[Subzone_No] [float] NULL,
		[Subzone_Name] [nvarchar](255) NULL,
		[Subzone_Code] [nvarchar](255) NULL,
		[Planning_Area_Name] [nvarchar](255) NULL,
		[Planning_Area_Code] [nvarchar](255) NULL,
		[Region_Name] [nvarchar](255) NULL,
		[Region_Code] [nvarchar](255) NULL,
		[Length_Of_Subzone] [float] NULL,
		[Shape_Area_Subzone] [float] NULL
	) ON [PRIMARY]
end
else
	print 'Table STG_INTERSECT_DATA Exist Already !!!!'
GO

TRUNCATE TABLE [STG_INTERSECT_DATA]
INSERT INTO [dbo].[STG_INTERSECT_DATA]
           ([NPC_Name]
           ,[Shape_Area_NPC]
           ,[Subzone_No]
           ,[Subzone_Name]
           ,[Subzone_Code]
           ,[Planning_Area_Name]
           ,[Planning_Area_Code]
           ,[Region_Name]
           ,[Region_Code]
           ,[Length_Of_Subzone]
           ,[Shape_Area_Subzone])
	SELECT [NPC_NAME]
		  ,[SHAPE_Area]    
		  ,[SUBZONE_NO]
		  ,[SUBZONE_N]
		  ,[SUBZONE_C] 
		  ,[PLN_AREA_N]
		  ,[PLN_AREA_C]
		  ,[REGION_N]
		  ,[REGION_C]
		  ,[SHAPE_Le_2]
		  ,[SHAPE_Ar_2]
	FROM dbo.[RAW_INTERSECT_DATA]

/***************************************************/









