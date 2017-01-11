IF NOT EXISTS (SELECT name FROM master.sys.databases WHERE name = N'DWProperty')
	CREATE DATABASE [DWProperty]
GO

USE [DWProperty]
GO


/****** Object:  Table [dbo].[SalesTransactions]    Script Date: 9/20/2016 12:37:20 PM ******/

if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'SUBZONE_WITH_SHAPEID')
begin
CREATE TABLE [dbo].[SUBZONE_WITH_SHAPEID](
	[SHAPE_ID] [varchar](50) NULL,
	[X] [varchar](50) NULL,
	[Y] [varchar](50) NULL,
	[PATH] [float](50) NULL,
	[OBJECT_ID] [varchar](50) NULL,
	[SUBZONE_ID] [varchar](50) NULL,
	[SUBZONE_NAME] [varchar](50) NULL,
	[SUBZONE_CODE] [varchar](50) NULL,
	[CA_IND] [varchar](50) NULL,
	[PLN_AREA_NAME] [varchar](50) NULL,
	[PLN_AREA_CODE] [varchar](50) NULL,
	[REGION_NAME] [varchar](50) NULL,
	[REGION_CODE] [varchar](50) NULL,
	[INC_CRC] [varchar](50) NULL,
	[X_ADDR] [varchar](50) NULL,
	[Y_ADDR] [varchar](50) NULL,
	[SHAPE_LENGTH] [varchar](50) NULL,
	[SHAPE_AREA] [float](50) NULL
) ON [PRIMARY]
end
else
print 'Table SUBZONE_WITH_SHAPEID Exist Already !!!!'
GO

/****** Object:  Table [dbo].[RAW_SalesTransactions]   ******/

if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'RAW_SalesTransactions')
	CREATE TABLE [dbo].[RAW_SalesTransactions](
	[Id] [varchar](50) NULL,
	[PropertyID] [varchar](50) NULL,
	[PropertyType] [varchar](50) NULL,
	[PropertyTenureType] [varchar](50) NULL,
	[PropertyNumberOfFloors] [varchar](50) NULL,
	[PropertynumberOfUnits] [varchar](50) NULL,
	[PropertyYearOfCompletion] [varchar](50) NULL,
	[PropertyInSubzone] [varchar](50) NULL,
	[PropertyLatitude] [varchar](50) NULL,
	[PropertyLongitude] [varchar](50) NULL,
	[PropertyInPostalSector] [varchar](50) NULL,
	[PropertyInPostalDistrict] [varchar](50) NULL,
	[FloorNoOfTransactedUnit] [varchar](50) NULL,
	[NumberOfBedroomsInTransactedUnit] [varchar](50) NULL,
	[TransactedPricePerSqFt] [varchar](50) NULL,
	[TransactionType] [varchar](50) NULL,
	[TransactionDate] [varchar](50) NULL
) ON [PRIMARY]
else
	print 'Table RAW_SalesTransactions Exist Already !!!!'
GO


/****** Object:  Table [dbo].[RAW_RentalTransactions]    ******/

if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'RAW_RentalTransactions')
	CREATE TABLE [dbo].[RAW_RentalTransactions](
		[Id] [varchar](50) NULL,
		[PropertyID] [varchar](50) NULL,
		[PropertyType] [varchar](50) NULL,
		[PropertyTenureType] [varchar](50) NULL,
		[PropertyNumberOfFloors] [varchar](50) NULL,
		[PropertynumberOfUnits] [varchar](50) NULL,
		[PropertyYearOfCompletion] [varchar](50) NULL,
		[PropertyInSubzone] [varchar](50) NULL,
		[PropertyLatitude] [varchar](50) NULL,
		[PropertyLongitude] [varchar](50) NULL,
		[PropertyInPostalSector] [varchar](50) NULL,
		[PropertyInPostalDistrict] [varchar](50) NULL,
		[TransactedUnitAreaInSqFtLowerBound] [varchar](50) NULL,
		[TransactedUnitAreaInSqFtUpperBound] [varchar](50) NULL,
		[NoOfBedroomsInTransactedUnit] [varchar](50) NULL,
		[MonthlyRentAmount] [varchar](50) NULL,
		[TransactionDate] [varchar](50) NULL
	) ON [PRIMARY]
else
	print 'Table RAW_RentalTransactions Exist Already !!!!'
GO

/****** Object:  Table [dbo].[RAW_PropertySpatialMetricAssets]     ******/

if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'RAW_PropertySpatialMetricAssets')
	CREATE TABLE [dbo].[RAW_PropertySpatialMetricAssets](
		[PropertyID] [varchar](50) NULL,
		[NumberofSchoolsWithin500Mts] [varchar](50) NULL,
		[NumberOfMRTsWithin500Mts] [varchar](50) NULL,
		[NumberOfBusStopsWithin500Mts] [varchar](50) NULL,
		[TimeToRafflesByCarInSeconds] [varchar](50) NULL,
		[TimeToRafflesByPublicTransportInSeconds] [varchar](50) NULL,
		[TimeToAirportByCarInSeconds] [varchar](50) NULL,
		[TimeToAirportByPublicTransportInSeconds] [varchar](50) NULL,
		ListMRTNearby [varchar](250) NULL,
		ListBusStopNearby [varchar](500) NULL
	) ON [PRIMARY]
else
	print 'Table RAW_PropertySpatialMetricAssets Exist Already !!!!'
GO


/****** Object:  Table [dbo].[PointOfInterests]    ******/
if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'RAW_PointOfInterests')
	CREATE TABLE [dbo].[RAW_PointOfInterests](
		[Id] [varchar](50) NULL,
		[POI_Type] [varchar](50) NULL,
		[POI_Name] [varchar](50) NULL,
		[POI_InSubzone] [varchar](50) NULL,
		[POI_Latitude] [varchar](50) NULL,
		[POI_Longitude] [varchar](50) NULL,
		[POI_InPostalSector] [varchar](50) NULL,
		[POI_InPostalDistrict] [varchar](50) NULL
	) ON [PRIMARY]
else
	print 'Table RAW_PointOfInterests Exist Already !!!!'
GO


/******************Create Table to store the raw community club - singapore details************************/
if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'RAW_AMENITY_COMMUNITY_CLUB')
begin
CREATE TABLE [dbo].[RAW_AMENITY_COMMUNITY_CLUB](
	[shapeid] [varchar](50) NULL,
	[x] [varchar](50) NULL,
	[y] [varchar](50) NULL,
	[OBJECTID] [varchar](50) NULL,
	[ADDRESSBLO] [varchar](50) NULL,
	[ADDRESSBUI] [varchar](50) NULL,
	[ADDRESSPOS] [varchar](100) NULL,
	[ADDRESSSTR] [varchar](50) NULL,
	[ADDRESSTYP] [varchar](50) NULL,
	[DESCRIPTIO] [varchar](50) NULL,
	[LANDXADDRE] [varchar](50) NULL,
	[LANDYADDRE] [varchar](50) NULL,
	[NAME] [varchar](50) NULL,
	[ADDRESSFLO] [varchar](50) NULL,
	[ADDRESSUNI] [varchar](50) NULL,
	[SUBZONE_NO] [varchar](50) NULL,
	[SUBZONE_N] [varchar](50) NULL,
	[SUBZONE_C] [varchar](50) NULL,
	[CA_IND] [varchar](50) NULL,
	[PLN_AREA_N] [varchar](50) NULL,
	[PLN_AREA_C] [varchar](50) NULL,
	[REGION_N] [varchar](50) NULL,
	[REGION_C] [varchar](max) NULL
	) ON [PRIMARY]
	end
else
print 'Table RAW_AMENITY_COMMUNITY_CLUB Exist Already !!!!'

/******************Create Table to store the raw Gyms-singapore details************************/

if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'RAW_AMENITY_GYMS')
begin
CREATE TABLE [dbo].[RAW_AMENITY_GYMS](
	[ShapeId] [varchar](50) NULL,
	[x] [varchar](50) NULL,
	[y] [varchar](50) NULL,
	[OBJECTID] [varchar](50) NULL,
	[LANDYADDRE] [varchar](50) NULL,
	[LANDXADDRE] [varchar](50) NULL,
	[ADDRESSPOS] [varchar](50) NULL,
	[ADDRESSBUI] [nvarchar](255) NULL,
	[ADDRESSUNI] [varchar](50) NULL,
	[ADDRESSFLO] [varchar](50) NULL,
	[ADDRESSSTR] [text] NULL,
	[ADDRESSBLO] [varchar](50) NULL,
	[NAME] [nvarchar](255) NULL,
	[INC_CRC] [nvarchar](255) NULL,
	[SUBZONE_NO] [nvarchar](255) NULL,
	[SUBZONE_N] [nvarchar](255) NULL,
	[SUBZONE_C] [nvarchar](255) NULL,
	[CA_IND] [nvarchar](255) NULL,
	[PLN_AREA_N] [nvarchar](255) NULL,
	[PLN_AREA_C] [nvarchar](255) NULL,
	[REGION_N] [nvarchar](255) NULL,
	[REGION_C] [nvarchar](255) NULL
) ON [PRIMARY]
end
else
print 'Table RAW_AMENITY_GYMS Exist Already !!!!'
GO

/******************Create Table to store the raw Hawker Centre-singapore details************************/
if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'RAW_AMENITY_HAWKER_CENTRE')
begin
CREATE TABLE [dbo].[RAW_AMENITY_HAWKER_CENTRE](
	[shapeid] [varchar](50) NULL,
	[x] [varchar](50) NULL,
	[y] [varchar](50) NULL,
	[OBJECTID] [varchar](50) NULL,
	[ADDRESSBLO] [varchar](50) NULL,
	[PHOTOURL] [varchar](50) NULL,
	[NAME] [varchar](50) NULL,
	[LANDYADDRE] [varchar](50) NULL,
	[LANDXADDRE] [varchar](50) NULL,
	[DESCRIPTIO] [varchar](50) NULL,
	[ADDRESSUNI] [varchar](50) NULL,
	[ADDRESSTYP] [varchar](50) NULL,
	[ADDRESSSTR] [varchar](50) NULL,
	[ADDRESSPOS] [varchar](50) NULL,
	[ADDRESSFLO] [varchar](50) NULL,
	[ADDRESSBUI] [varchar](50) NULL,
	[INC_CRC] [varchar](50) NULL,
	[OBJECTID_2] [varchar](50) NULL,
	[SUBZONE_NO] [varchar](50) NULL,
	[SUBZONE_N] [varchar](50) NULL,
	[SUBZONE_C] [varchar](50) NULL,
	[CA_IND] [varchar](50) NULL,
	[PLN_AREA_N] [varchar](50) NULL,
	[PLN_AREA_C] [varchar](50) NULL,
	[REGION_N] [varchar](50) NULL,
	[REGION_C] [varchar](50) NULL
) ON [PRIMARY]
end
else
print 'Table RAW_AMENITY_HAWKER_CENTRE Exists Already !!!!'
GO

/******************Create Table to store the raw Parks-singapore details************************/

if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'RAW_AMENITY_PARKS')
begin
CREATE TABLE [dbo].[RAW_AMENITY_PARKS](
	[shapeid] [nvarchar](255) NULL,
	[x] [varchar](50) NULL,
	[y] [varchar](50) NULL,
	[OBJECTID] [varchar](50) NULL,
	[LANDYADDRE] [varchar](50) NULL,
	[LANDXADDRE] [varchar](50) NULL,
	[ADDRESSPOS] [varchar](50) NULL,
	[PHOTOURL] [nvarchar](255) NULL,
	[NAME] [nvarchar](255) NULL,
	[DESCRIPTIO] [nvarchar](max) NULL,
	[ADDRESSUNI] [nvarchar](255) NULL,
	[ADDRESSFLO] [nvarchar](255) NULL,
	[ADDRESSBUI] [nvarchar](255) NULL,
	[ADDRESSBLO] [nvarchar](255) NULL,
	[OBJECTID_2] [nvarchar](255) NULL,
	[SUBZONE_NO] [nvarchar](255) NULL,
	[SUBZONE_N] [nvarchar](255) NULL,
	[SUBZONE_C] [nvarchar](255) NULL,
	[CA_IND] [nvarchar](255) NULL,
	[PLN_AREA_N] [nvarchar](255) NULL,
	[PLN_AREA_C] [nvarchar](255) NULL,
	[REGION_N] [nvarchar](255) NULL,
	[REGION_C] [nvarchar](255) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
end
else
print 'Table RAW_AMENITY_PARKS Exists Already !!!!'
go

/******************Create Table to store the raw SportsCentre-singapore details************************/


if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'RAW_AMENITY_SPORTS')
begin
CREATE TABLE [dbo].[RAW_AMENITY_SPORTS](
	[shapeid] [nvarchar](255) NULL,
	[x] [varchar](50) NULL,
	[y] [varchar](50) NULL,
	[OBJECTID] [varchar](50) NULL,
	[LANDYADDRE] [varchar](50) NULL,
	[LANDXADDRE] [varchar](50) NULL,
	[ADDRESSPOS] [varchar](50) NULL,
	[NAME] [nvarchar](255) NULL,
	[ADDRESSUNI] [nvarchar](255) NULL,
	[ADDRESSSTR] [nvarchar](255) NULL,
	[ADDRESSFLO] [nvarchar](255) NULL,
	[ADDRESSBUI] [nvarchar](255) NULL,
	[ADDRESSBLO] [nvarchar](255) NULL,
	[OBJECTID_2] [varchar](50) NULL,
	[SUBZONE_NO] [varchar](50) NULL,
	[SUBZONE_N] [nvarchar](255) NULL,
	[SUBZONE_C] [nvarchar](255) NULL,
	[CA_IND] [nvarchar](255) NULL,
	[PLN_AREA_N] [nvarchar](255) NULL,
	[PLN_AREA_C] [nvarchar](255) NULL,
	[REGION_N] [nvarchar](255) NULL,
	[REGION_C] [nvarchar](255) NULL
) ON [PRIMARY]

end
else
print 'Table RAW_AMENITY_SPORTS Exists Already !!!!'
GO

/******************Create Table to store the raw Kindergarten-singapore details************************/


if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'RAW_AMENITY_KINDER')
begin
CREATE TABLE [dbo].[RAW_AMENITY_KINDER](
	[shapeid] [float] NULL,
	[x] [float] NULL,
	[y] [float] NULL,
	[OBJECTID] [float] NULL,
	[ADDRESSBLO] [nvarchar](255) NULL,
	[ADDRESSBUI] [nvarchar](255) NULL,
	[ADDRESSFLO] [nvarchar](255) NULL,
	[ADDRESSPOS] [float] NULL,
	[ADDRESSSTR] [nvarchar](255) NULL,
	[ADDRESSTYP] [nvarchar](255) NULL,
	[DESCRIPTIO] [nvarchar](255) NULL,
	[LANDXADDRE] [float] NULL,
	[LANDYADDRE] [float] NULL,
	[NAME] [nvarchar](255) NULL,
	[ADDRESSUNI] [nvarchar](255) NULL,
	[OBJECTID_2] [float] NULL,
	[SUBZONE_NO] [float] NULL,
	[SUBZONE_N] [nvarchar](255) NULL,
	[SUBZONE_C] [nvarchar](255) NULL,
	[CA_IND] [nvarchar](255) NULL,
	[PLN_AREA_N] [nvarchar](255) NULL,
	[PLN_AREA_C] [nvarchar](255) NULL,
	[REGION_N] [nvarchar](255) NULL,
	[REGION_C] [nvarchar](255) NULL
) ON [PRIMARY]
end
else
print 'Table RAW_AMENITY_KINDER Exists Already !!!!'
GO


/******************SUBZONES - FILE************************/

if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'STG_SUBZONE_DETAILS')
begin
CREATE TABLE [dbo].[STG_SUBZONE_DETAILS](
	[SUBZONE_ID] [NUMERIC] NULL,
	[SUBZONE_CODE] [varchar](20) NULL,
	[SUBZONE_NAME] [nvarchar](255) NULL,
	[PLN_AREA_ID] [NUMERIC] NULL,
	[PLN_AREA_CODE] [varchar](20) NULL,
	[PLN_AREA_NAME] [nvarchar](255) NULL,
	) ON [PRIMARY]
end
else
print 'Table STG_SUBZONE_DETAILS Exists Already !!!!'
GO


if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'RAW_POPULATION_DENSITY')
begin
CREATE TABLE [dbo].[RAW_POPULATION_DENSITY](
	[PlanningArea] [varchar](50) NULL,
	[Subzone] [varchar](50) NULL,
	[Total] [varchar](50) NULL,
	[0 to 4] [numeric] NULL,
	[05 to 09] [numeric] NULL,
	[10 to 14] [numeric] NULL,
	[15 to 19] [numeric] NULL,
	[20 to 24] [numeric] NULL,
	[25 to 29] [numeric] NULL,
	[30 to 34] [numeric] NULL,
	[35 to 39] [numeric] NULL,
	[40 to 44] [numeric] NULL,
	[45 to 49] [numeric] NULL,
	[50 to 54] [numeric] NULL,
	[55 to 59] [numeric] NULL,
	[60 to 64] [numeric] NULL,
	[65 to 69] [numeric] NULL,
	[70 to 74] [numeric] NULL,
	[75 to 79] [numeric] NULL,
	[80 to 84] [numeric] NULL,
	[85] [numeric] NULL
) ON [PRIMARY]
	end
else
print 'Table RAW_POPULATION_DENSITY Exist Already !!!!'
GO

/****** Object:  Table [dbo].[Dengue_Cluster]    Script Date: 20-09-2016 03:16:32 PM ******/
if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'RAW_DENGUE_CLUSTER')
begin
CREATE TABLE [dbo].[RAW_DENGUE_CLUSTER](
	[SUBZONE_C] [varchar](50) NULL,
	[OBJECTID_2] [numeric] NULL,
	[CASE_SIZE] [numeric] NULL,
	[NAME] [varchar](50) NULL,
	[HYPERLINK] [varchar](50) NULL,
	[INC_CRC_2] [varchar](50) NULL,
	[FMEL_UPD_2] [varchar](50) NULL,
	[X_ADDR_2] [numeric] NULL,
	[Y_ADDR_2] [numeric] NULL,
	[SHAPE_Le_2] [numeric] NULL,
	[SHAPE_Ar_2] [numeric] NULL,
	[area] [numeric] NULL
) ON [PRIMARY]
	end
else
print 'Table RAW_DENGUE_CLUSTER Exist Already !!!!'
GO


/****** Object:  Table [dbo].[malaria]    Script Date: 20-09-2016 03:46:17 PM ******/
if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'RAW_MALARIA_CLUSTER')
begin
CREATE TABLE [dbo].[RAW_MALARIA_CLUSTER](
	[SUBZONE_C] [varchar](50) NULL,
	[OBJECTID_2] [numeric] NULL,
	[ID] [numeric] NULL,
	[GRC] [varchar](50) NULL,
	[CONSTCY] [varchar](50) NULL,
	[REGIONAL_O] [varchar](50) NULL,
	[INC_CRC_2] [varchar](50) NULL,
	[FMEL_UPD_2] [varchar](50) NULL,
	[X_ADDR_2] [numeric] NULL,
	[Y_ADDR_2] [numeric] NULL,
	[SHAPE_Le_2] [numeric] NULL,
	[SHAPE_Ar_2] [numeric] NULL,
	[Area_Covered_Subzone] [numeric] NULL
) ON [PRIMARY]
	end
else
print 'Table RAW_MALARIA_CLUSTER Exist Already !!!!'
GO


if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'RAW_CRIME_RECORDED_BY_NPCS')
begin
CREATE TABLE [dbo].[RAW_CRIME_RECORDED_BY_NPCS](
	[Year] [float] NULL,
	[Division] [nvarchar](255) NULL,
	[NPC] [nvarchar](255) NULL,
	[Offence] [nvarchar](255) NULL,
	[NumberOfCases] [float] NULL
) ON [PRIMARY]
	end
else
print 'Table RAW_CRIME_RECORDED_BY_NPCS Exist Already !!!!'
GO


if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'RAW_INTERSECT_DATA')
begin
CREATE TABLE [dbo].[RAW_INTERSECT_DATA](
	[OBJECTID] [float] NULL,
	[DIV] [nvarchar](255) NULL,
	[NPC_NAME] [nvarchar](255) NULL,
	[DIVISION] [nvarchar](255) NULL,
	[INC_CRC] [nvarchar](255) NULL,
	[FMEL_UPD_D] [datetime] NULL,
	[X_ADDR] [float] NULL,
	[Y_ADDR] [float] NULL,
	[SHAPE_Leng] [float] NULL,
	[SHAPE_Area] [float] NULL,
	[OBJECTID_2] [float] NULL,
	[SUBZONE_NO] [float] NULL,
	[SUBZONE_N] [nvarchar](255) NULL,
	[SUBZONE_C] [nvarchar](255) NULL,
	[CA_IND] [nvarchar](255) NULL,
	[PLN_AREA_N] [nvarchar](255) NULL,
	[PLN_AREA_C] [nvarchar](255) NULL,
	[REGION_N] [nvarchar](255) NULL,
	[REGION_C] [nvarchar](255) NULL,
	[INC_CRC_2] [nvarchar](255) NULL,
	[FMEL_UPD_2] [datetime] NULL,
	[X_ADDR_2] [float] NULL,
	[Y_ADDR_2] [float] NULL,
	[SHAPE_Le_2] [float] NULL,
	[SHAPE_Ar_2] [float] NULL
) ON [PRIMARY]
end
else
print 'Table RAW_INTERSECT_DATA Exist Already !!!!'
GO






