USE DWProperty
GO

--DROP TABLE [Dim_Property]

if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'Dim_Property')
BEGIN
	CREATE TABLE [dbo].[Dim_Property](
		[PropertyID] [varchar](20) NOT NULL,
		[PropertyType] [varchar](50) NULL,
		[PropertyTenureType] [varchar](50) NULL,
		[PreviousTenureType] [varchar](50) NULL,
		[PropertyNumberOfFloors] [varchar](50) NULL,
		[PropertynumberOfUnits] [varchar](50) NULL,
		[PropertyYearOfCompletion] [varchar](50) NULL,
		[PropertyLatitude] [varchar](50) NULL,
		[PropertyLongitude] [varchar](50) NULL,
		[PropertyInPostalSector] [varchar](50) NULL,
		[PropertyInPostalDistrict] [varchar](50) NULL,
		[NumberOfBedroomsInTransactedUnit] [varchar](50) NULL,
		[SubzoneCode] [varchar](20) NULL,
		[LastTransactionDate] DATE NULL,
		[NumberofSchoolsWithin500Mts] INT NULL,
		[NumberOfMRTsWithin500Mts] INT NULL,
		[NumberOfBusStopsWithin500Mts] INT NULL,
		[TimeToRafflesByCarInSeconds] INT NULL,
		[TimeToRafflesByPublicTransportInSeconds] INT NULL,
		[TimeToAirportByCarInSeconds] INT NULL,
		[TimeToAirportByPublicTransportInSeconds] INT NULL,
		[ListBusStopNearby] VARCHAR(500) NULL,
		[ListMRTNearby] VARCHAR(250) NULL,
	CONSTRAINT [PK_Dim_Property] PRIMARY KEY CLUSTERED (
		[PropertyID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

	INSERT INTO [dbo].[Dim_Property]
			   ([PropertyID]
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
	SELECT P.[PropertyID]
		,CASE WHEN P.PropertyType in ('1','2','7') THEN 'Private'
			WHEN P.PropertyType = '4' THEN 'Public'
			ELSE 'Landed' -- PropertyType in (3,5,6)
		END AS [PropertyType]
		,P.[PropertyTenureType]
		,P.[PropertyNumberOfFloors]
		,P.[PropertynumberOfUnits]
		,P.[PropertyYearOfCompletion]
		,P.[PropertyLatitude]
		,P.[PropertyLongitude]
		,P.[PropertyInPostalSector]
		,P.[PropertyInPostalDistrict]
		,P.[NumberOfBedroomsInTransactedUnit]
		,SUB.SUBZONE_CODE
		,CONVERT(DATE,[LastTransactionDate]) as [LastTransactionDate]
	FROM STG_Property P JOIN STG_SUBZONE_DETAILS SUB ON P.SubzoneID = SUB.SUBZONE_ID

END
else
	print 'Table Dim_Property Exist Already !!!!'
GO


UPDATE STG_PropertySpatialMetricAssets SET PropertyID = REPLACE(PropertyID,'"','') 
										,[ListBusStopNearby] = SUBSTRING([ListBusStopNearby],2,LEN([ListBusStopNearby]))
										,[ListMRTNearby] = SUBSTRING([ListMRTNearby],2,LEN([ListMRTNearby]))
UPDATE [Dim_Property] SET [NumberofSchoolsWithin500Mts] = M.[NumberofSchoolsWithin500Mts]
           ,[NumberOfMRTsWithin500Mts]= M.[NumberOfMRTsWithin500Mts]
           ,[NumberOfBusStopsWithin500Mts]= M.[NumberOfBusStopsWithin500Mts]
           ,[TimeToRafflesByCarInSeconds]= M.[TimeToRafflesByCarInSeconds]
           ,[TimeToRafflesByPublicTransportInSeconds]= M.[TimeToRafflesByPublicTransportInSeconds]
           ,[TimeToAirportByCarInSeconds]= M.[TimeToAirportByCarInSeconds]
           ,[TimeToAirportByPublicTransportInSeconds]= M.[TimeToAirportByPublicTransportInSeconds]
		   ,[ListBusStopNearby] = M.ListBusStopNearby
		   ,[ListMRTNearby] = M.ListMRTNearby
FROM [Dim_Property] P JOIN STG_PropertySpatialMetricAssets M ON P.PropertyID = M.PropertyID

DELETE A
FROM [Dim_Property_AmenityNearby] A LEFT JOIN Dim_Property P ON A.PropertyID = P.PropertyID
WHERE P.PropertyID IS NULL

if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'Fact_PropertyRentals')
BEGIN
	CREATE TABLE [dbo].[Fact_PropertyRentals](
		[PropertyID] [varchar](20) NULL,
		[MonthlyRentAmount] numeric NULL,
		[TransactionDate] date NULL
	) ON [PRIMARY]

	INSERT INTO [dbo].[Fact_PropertyRentals]
           ([PropertyID]
           ,[MonthlyRentAmount]
           ,[TransactionDate])
	SELECT [PropertyID]
			   ,[MonthlyRentAmount]
			   ,[TransactionDate]
	FROM STG_RentalTransactions
END
else
	print 'Table Fact_PropertyRentals Exist Already !!!!'
GO



if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'Fact_PropertySales')
BEGIN
	CREATE TABLE [dbo].[Fact_PropertySales](
		[PropertyID] [varchar](20) NULL,
		[TransactedPricePerSqFt] numeric NULL,
		[TransactionType] [varchar](50) NULL,
		[TransactionDate] date NULL
	) ON [PRIMARY]

	INSERT INTO [dbo].[Fact_PropertySales]
			   ([PropertyID]
			   ,[TransactedPricePerSqFt]
			   ,[TransactionType]
			   ,[TransactionDate])
	SELECT [PropertyID]
			   ,[TransactedPricePerSqFt]
			   ,[TransactionType]
			   ,[TransactionDate]
	FROM STG_SalesTransactions
END
else
	print 'Table Fact_PropertySales Exist Already !!!!'
GO



if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'Dim_Amenity_Accessibility')
BEGIN
	CREATE TABLE [dbo].[Dim_Amenity_Accessibility](
		[ID] varchar(30) PRIMARY KEY NOT NULL,
		[NAME] [varchar](250) NULL,
		[Longitude] [varchar](50) NULL,
		[Latitude] [varchar](50) NULL,
		[ADDRESS] [varchar](250) NULL,
		[AmenityType] varchar(50) NULL,
		[SUBZONE_ID] [varchar](50) NULL,
		[POINT] geography NULL
	) ON [PRIMARY] 
	
	INSERT INTO [dbo].[Dim_Amenity_Accessibility]
           ([ID], [NAME]
           ,[Longitude]
           ,[Latitude]
           ,[ADDRESS]
           ,[AmenityType]
           ,[SUBZONE_ID])
	SELECT AccessibilityID, Name ,Longitude ,Latitude, Name, [Type] ,SubzoneID
	FROM STG_ACCESSIBILITY
	UNION
	SELECT AmenityID, NAME ,Longitude ,Latitude, [ADDRESS], AmenityType ,S.SUBZONE_ID
	FROM STG_AMENITY A JOIN STG_SUBZONE_DETAILS S ON A.SUBZONE_CODE = S.SUBZONE_CODE
END
else
	print 'Table Dim_Amenity_Accessibility Exist Already !!!!'
GO



if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'Dim_Date')
BEGIN
	CREATE TABLE [dbo].[Dim_Date](
		DateKey date NOT NULL,
		Day INT NULL,
		Month INT NULL,
		Year INT NULL,
	CONSTRAINT [PK_Dim_Date] PRIMARY KEY CLUSTERED (
		DateKey ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]

	INSERT INTO [Dim_Date](DateKey, [Day], [Month], [Year])
	SELECT DISTINCT TransactionDate, D, M, Y FROM (
	SELECT DISTINCT CONVERT(DATE,TransactionDate) TransactionDate, DAY(TransactionDate) D, MONTH(TransactionDate) M, YEAR(TransactionDate) Y
	FROM STG_SalesTransactions
	UNION 
	SELECT DISTINCT CONVERT(DATE,TransactionDate) TransactionDate, DAY(TransactionDate), MONTH(TransactionDate), YEAR(TransactionDate) 
	FROM STG_RentalTransactions) A ORDER BY TransactionDate
END
else
	print 'Table Dim_Date Exist Already !!!!'
GO





-- 289905 records, THE EXECUTION FOR BELOW PROCESS MAY TAKE MORE THAN 1 HOUR
/*
UPDATE [Dim_Amenity_Accessibility] set POINT = 'POINT('+ Longitude +' '+ Latitude +')'

TRUNCATE TABLE Dim_Property_AmenityNearby
DECLARE @propertyid varchar(50), @propertyLongtitude varchar(50), @propertyLatitude varchar(50),
		@g geography

DECLARE CUR_Property CURSOR FOR
SELECT propertyid, PropertyLongitude, PropertyLatitude
FROM Dim_Property

OPEN CUR_Property
FETCH NEXT FROM CUR_Property INTO @propertyid, @propertyLongtitude, @propertyLatitude

WHILE @@FETCH_STATUS = 0   
BEGIN   

	SELECT @g = 'POINT('+ @propertyLongtitude +' '+ @propertyLatitude +')'
	
	INSERT Dim_Property_AmenityNearby (PropertyID, AmenityID, Distance)
	SELECT propertyid, AmenityID, Distance
	FROM
	(SELECT @propertyid propertyid, ID AS AmenityID, POINT.STDistance(@g) Distance
	FROM [Dim_Amenity_Accessibility]
	WHERE POINT.STDistance(@g) IS NOT NULL AND POINT.STDistance(@g) < 500) t
	

    FETCH NEXT FROM CUR_Property INTO @propertyid, @propertyLongtitude, @propertyLatitude  
END   

CLOSE CUR_Property   
DEALLOCATE CUR_Property

*/


 

/************************Creating a Temp Table for Subzone Level Count : Amenity************************************/
begin
create table dbo.temp_cc ( SUBZONE_CODE varchar(10),No_Of_CC numeric)
insert into dbo.temp_cc select SUBZONE_CODE,COUNT(*) as No_Of_CC from dbo.STG_AMENITY_COMMUNITY_CLUB group by SUBZONE_CODE;
end

begin
create table dbo.temp_gyms ( SUBZONE_CODE varchar(10),No_Of_GYMS numeric)
insert into dbo.temp_gyms select SUBZONE_CODE,COUNT(*) as No_Of_Gyms from dbo.STG_AMENITY_GYMS group by SUBZONE_CODE;
end

begin
create table dbo.temp_hawker ( SUBZONE_CODE varchar(10),No_Of_HAWKER numeric)
insert into dbo.temp_hawker select SUBZONE_CODE,COUNT(*) as No_Of_Hawker from dbo.STG_AMENITY_HAWKER_CENTRE group by SUBZONE_CODE;
end

begin
create table dbo.temp_park ( SUBZONE_CODE varchar(10),No_Of_PARKS numeric)
insert into dbo.temp_park select SUBZONE_CODE,COUNT(*) as No_Of_Parks from dbo.STG_AMENITY_PARKS group by SUBZONE_CODE;
end

begin
create table dbo.temp_sports ( SUBZONE_CODE varchar(10),No_Of_SPORTS numeric)
insert into dbo.temp_sports select SUBZONE_CODE,COUNT(*) as No_Of_Sports from dbo.STG_AMENITY_SPORTS group by SUBZONE_CODE;
end

begin
create table dbo.temp_kinder ( SUBZONE_CODE varchar(10),No_Of_KINDER numeric)
insert into dbo.temp_kinder select SUBZONE_CODE,COUNT(*) as No_Of_Kinder from dbo.STG_AMENITY_KINDER group by SUBZONE_CODE;
end


/***********Creating Subzone wise Amenity DIM Table********************/
if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'DIM_AMENITY_INDEX')
begin
	create table dbo.DIM_AMENITY_INDEX(
		AMENITY_INDEX_KEY varchar(30) not null primary key,
		SUBZONE_CODE varchar(20) not null ,
		SUBZONE_NAME nvarchar(255) not null,
		PLAN_AREA_NAME nvarchar(255) not null,
		No_Of_CC numeric not null,
		No_Of_GYMS numeric not null,
		No_Of_HAWKER numeric not null,
		No_Of_PARKS numeric not null,
		No_Of_SPORTS numeric not null,
		No_Of_KINDER numeric not null,
		AMENITY_INDEX numeric null,
		AVG_AMENITY_INDEX as ((([No_Of_GYMS]*3)+([No_Of_PARKS]*3)+([No_Of_HAWKER]*2)+([No_Of_CC]*2)+([No_Of_SPORTS])+([No_Of_KINDER]))/12)
	);

	insert into DIM_AMENITY_INDEX ([AMENITY_INDEX_KEY],[SUBZONE_CODE],[SUBZONE_NAME],[PLAN_AREA_NAME],[No_Of_CC],[No_Of_GYMS],[No_Of_HAWKER],[No_Of_PARKS],[No_Of_SPORTS],[No_Of_KINDER])
	select 'AM-'+t1.SUBZONE_CODE,t1.SUBZONE_CODE,t1.SUBZONE_NAME,t1.PLN_AREA_NAME,isnull(t2.No_Of_CC,0) as No_Of_CC,isnull(t3.No_Of_GYMS,0) as No_Of_GYMS,isnull(t4.No_Of_HAWKER,0) as No_Of_HAWKER,isnull(t5.No_Of_PARKS,0) as No_Of_PARKS,isnull(t6.No_Of_SPORTS,0) as No_Of_SPORTS,isnull(t7.No_Of_KINDER,0) as No_Of_KINDER 
	from dbo.STG_SUBZONE_DETAILS as t1 left outer join dbo.temp_cc as t2 on t1.SUBZONE_CODE = t2.SUBZONE_CODE 
		left outer join dbo.temp_gyms as t3 on t1.SUBZONE_CODE = t3.SUBZONE_CODE 
		left outer join dbo.temp_hawker as t4 on t1.SUBZONE_CODE = t4.SUBZONE_CODE 
		left outer join dbo.temp_park as t5 on t1.SUBZONE_CODE = t5.SUBZONE_CODE
		left outer join dbo.temp_sports as t6 on t1.SUBZONE_CODE = t6.SUBZONE_CODE 
		left outer join dbo.temp_kinder as t7 on t1.SUBZONE_CODE = t7.SUBZONE_CODE;

end
else
	print 'Table DIM_AMENITY_INDEX Exist Already !!!!'
GO

/***********Inserting into Subzone wise Amenity DIM Table********************/

update dbo.DIM_AMENITY_INDEX set AMENITY_INDEX =
case
	when AVG_AMENITY_INDEX<=0.5 then 1
	when AVG_AMENITY_INDEX<=1 then 2
	when AVG_AMENITY_INDEX<=2 then 3
	when AVG_AMENITY_INDEX<=3 then 4
	else 5
END


/***********Temp Table dropping********************/
drop table dbo.temp_cc,dbo.temp_gyms,dbo.temp_park,dbo.temp_hawker,dbo.temp_sports,dbo.temp_kinder



/***********Creating Subzone wise Population Density DIM Table********************/

if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'DIM_POPULATION_DENSITY_INDEX')
begin
	create table dbo.DIM_POPULATION_DENSITY_INDEX(
		POPULATION_INDEX_KEY varchar(30) not null primary key,
		SUBZONE_NAME nvarchar(255) not null,
		PLAN_AREA_NAME nvarchar(255) not null,
		SUBZONE_CODE varchar(20) not null,
		TOTAL varchar(20) not null,
		YOUNGAGE_POPULATION varchar(20) not null,
		MIDDLEAGE_POPULATION varchar(20) not null,
		OLDAGE_POPULATION varchar(20) not null,
		POPULATION_DENSITY float not null,
		POPULATION_INDEX numeric null,
	 );

	insert into dbo.DIM_POPULATION_DENSITY_INDEX([POPULATION_INDEX_KEY],[SUBZONE_NAME],[PLAN_AREA_NAME],[SUBZONE_CODE],[TOTAL],[YOUNGAGE_POPULATION],[MIDDLEAGE_POPULATION],[OLDAGE_POPULATION],[POPULATION_DENSITY])
	select distinct 'POP-'+s.SUBZONE_CODE,p.[Subzone],p.PlanningArea,s.SUBZONE_CODE,p.Total,p.YoungAge_Population,p.MiddelAge_Population,p.OldAge_Population,convert(float,round(((convert(float,p.[Total]) / s.SHAPE_AREA)*1000000),3)) as population_density 
	from [STG_POPULATION_DENSITY] p join SUBZONE_WITH_SHAPEID s on p.[Subzone] = s.SUBZONE_NAME;
end
else
	print 'Table DIM_POPULATION_DENSITY_INDEX Exist Already !!!!'
GO


--select * from dbo.DIM_POPULATION_DENSITY_INDEX


update dbo.DIM_POPULATION_DENSITY_INDEX set POPULATION_INDEX =
	case
		when POPULATION_DENSITY<=10000 then 1
		when POPULATION_DENSITY<=20000 then 2
		when POPULATION_DENSITY<=30000 then 3
		when POPULATION_DENSITY<=40000 then 4
		else 5
	end

/***********Creating Subzone wise Population Density DIM Table********************/

if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'DIM_HEALTH_INDEX')
begin
	create table dbo.DIM_HEALTH_INDEX(
		HEALTH_INDEX_KEY varchar(30) not null primary key,
		SUBZONE_CODE varchar(20) not null,
		SUBZONE_NAME nvarchar(255) not null,
		PLAN_AREA_NAME nvarchar(255) not null,
		DENGUE_INDEX float not null,
		MALARIA_INDEX float not null,
		HEALTH_INDEX numeric null,
		AVG_HEALTH_INDEX as (([DENGUE_INDEX] + [MALARIA_INDEX])/2)
	 );

	insert into DIM_HEALTH_INDEX([HEALTH_INDEX_KEY],[SUBZONE_CODE],[SUBZONE_NAME],[PLAN_AREA_NAME],[DENGUE_INDEX],[MALARIA_INDEX])
	select distinct 'HL-'+s.[SUBZONE_CODE],s.[SUBZONE_CODE],s.[SUBZONE_NAME],s.[PLN_AREA_NAME],isnull(s.[SHAPE_AREA]/d.[Area_Covered_Subzone],0) as DENGUE_INDEX,isnull(s.[SHAPE_AREA]/m.[Area_Covered_Subzone],0) as MALARIA_INDEX 
	from SUBZONE_WITH_SHAPEID s left outer join [STG_DENGUE_CLUSTER] d on s.[SUBZONE_CODE] = d.[SUBZONE_C] left outer join [RAW_MALARIA_CLUSTER] m on s.[SUBZONE_CODE] = m.[SUBZONE_C]

end
else
	print 'Table DIM_HEALTH_INDEX Exist Already !!!!'
GO


update dbo.DIM_HEALTH_INDEX set HEALTH_INDEX =
case
	when AVG_HEALTH_INDEX<=1 then 5
	when AVG_HEALTH_INDEX<=5 then 4
	when AVG_HEALTH_INDEX<=15 then 3
	when AVG_HEALTH_INDEX<=50 then 2
	else 1
end




if not exists(select * from sys.views t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'DIM_VIEW_SUBZONE_POPULATION')
begin
exec('create view DIM_VIEW_SUBZONE_POPULATION
AS
select distinct D.Subzone_Name,D.Subzone_Code, S.SHAPE_AREA as ''Total_Area'' ,P.Total as ''Total_Population''
from STG_INTERSECT_DATA D
	JOIN STG_POPULATION_DENSITY P ON rtrim(ltrim(D.Subzone_Name)) = rtrim(ltrim(UPPER(P.Subzone)))
	JOIN SUBZONE_WITH_SHAPEID S ON rtrim(ltrim(S.SUBZONE_CODE)) = rtrim(ltrim(D.Subzone_Code))')
end 
else
print 'View DIM_VIEW_SUBZONE_POPULATION Exist Already !!!!'
GO


if not exists(select * from sys.views t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'View_Subzone')
begin
execute('create  view [dbo].[View_Subzone] as  
	SELECT distinct crime_data.NPC_Name, P.Subzone_Code, crime_data.Number_Of_Cases, P.Total_Area,P.Total_Population
	from
	(select NPC_Name,sum(Number_Of_Cases) Number_Of_Cases 
	from STG_CRIME_RECORDED_BY_NPCS
	group by NPC_Name) crime_data
	JOIN STG_Intersect_Data D ON D.NPC_Name = crime_data.NPC_Name 
	JOIN DIM_VIEW_SUBZONE_POPULATION P ON D.Subzone_Code = P.Subzone_Code')
end 
else
print 'View View_Subzone Exist Already !!!!'
GO

/****** Object:  View [dbo].[View_Calculation_of_Density_And_Proportion]    Script Date: 19/9/2016 4:17:22 PM ******/
if not exists(select * from sys.views t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'View_Calculation_of_Density_And_Proportion')
begin
execute('create view [dbo].[View_Calculation_of_Density_And_Proportion] as select NPC_Name, Subzone_Code, Number_Of_Cases, Total_Area, Total_Population, 
[Total_Population]/[Total_Area] as ''Population_Density'', 
[Number_Of_Cases]/NULLIF([Total_Population], 0)  as ''Proportion_Of_Crime''
from View_Subzone')
end 
else
print 'View_Calculation_of_Density_And_Proportion Exist Already !!!!'
GO


/****** Object:  View [dbo].[View_Sum_Of_Proportion_Of_Crime_In_Each_Subzone]    Script Date: 19/9/2016 4:17:22 PM ******/
if not exists(select * from sys.views t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'View_Sum_Of_Proportion_Of_Crime_In_Each_Subzone')
begin
execute('create view [dbo].[View_Sum_Of_Proportion_Of_Crime_In_Each_Subzone] as 
	select Subzone_Code, sum(Proportion_Of_Crime) as ''Sum_Of_Proportion_Of_Crime_In_Each_Subzone''
	from View_Calculation_of_Density_And_Proportion
	group by Subzone_Code')
end 
else
print 'View_Sum_Of_Proportion_Of_Crime_In_Each_Subzone Exist Already !!!!'
GO


/****** Object:  View [dbo].[View_Sum_Of_Proportion_Of_Crime_In_Each_Subzone_Consolidated]    Script Date: 19/9/2016 4:17:22 PM ******/
if not exists(select * from sys.views t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'View_Sum_Of_Proportion_Of_Crime_In_Each_Subzone_Consolidated')
begin
execute('create view [dbo].[View_Sum_Of_Proportion_Of_Crime_In_Each_Subzone_Consolidated]
as
	SELECT view_Calculation_of_Density_And_Proportion.NPC_Name, 
		view_Calculation_of_Density_And_Proportion.Subzone_Code, 
		view_Calculation_of_Density_And_Proportion.Number_Of_Cases,
		view_Calculation_of_Density_And_Proportion.Total_Area,
		view_Calculation_of_Density_And_Proportion.Total_Population,
		view_Calculation_of_Density_And_Proportion.Population_Density,
		view_Calculation_of_Density_And_Proportion.Proportion_Of_Crime,
		view_Sum_Of_Proportion_Of_Crime_In_Each_Subzone.Sum_Of_Proportion_Of_Crime_In_Each_Subzone
	FROM view_Calculation_of_Density_And_Proportion
		INNER JOIN View_Sum_Of_Proportion_Of_Crime_In_Each_Subzone
			ON view_Calculation_of_Density_And_Proportion.Subzone_Code=View_Sum_Of_Proportion_Of_Crime_In_Each_Subzone.Subzone_Code')
end 
else
print 'View_Sum_Of_Proportion_Of_Crime_In_Each_Subzone_Consolidated Exist Already !!!!'
GO




/******CREATING and INSERTING SAFETY DIM ******/

if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'DIM_SAFETY')
BEGIN
	CREATE TABLE [dbo].[DIM_SAFETY](
		SAFETY_INDEX_KEY [varchar](30) NOT NULL PRIMARY KEY,
		[Subzone_Code] [nvarchar](30) NULL,
		[Total_Area] [float] NULL,
		[Total_Population] [varchar](50) NULL,
		[Population_Density] [float] NULL,
		[Crime_Index] [float] NULL,
		[Crime_Index_NOR] [float] NULL
	) ON [PRIMARY]

	insert into [DIM_SAFETY]
	SELECT DISTINCT 'SF-'+view_Sum_Of_Proportion_Of_Crime_In_Each_Subzone_Consolidated.Subzone_Code as Safety_key, view_Sum_Of_Proportion_Of_Crime_In_Each_Subzone_Consolidated.Subzone_Code,
		view_Sum_Of_Proportion_Of_Crime_In_Each_Subzone_Consolidated.Total_Area,
		view_Sum_Of_Proportion_Of_Crime_In_Each_Subzone_Consolidated.Total_Population,
		view_Sum_Of_Proportion_Of_Crime_In_Each_Subzone_Consolidated.Population_Density,
		ISNULL(Sum_Of_Proportion_Of_Crime_In_Each_Subzone/Population_Density,0) as CrimeIndex ,
		case
		when ISNULL(Sum_Of_Proportion_Of_Crime_In_Each_Subzone/Population_Density,0)<=100 then 1
		when ISNULL(Sum_Of_Proportion_Of_Crime_In_Each_Subzone/Population_Density,0)<=1000 then 2
		when ISNULL(Sum_Of_Proportion_Of_Crime_In_Each_Subzone/Population_Density,0)<=10000 then 3
		when ISNULL(Sum_Of_Proportion_Of_Crime_In_Each_Subzone/Population_Density,0)<=100000 then 4
		else 5
	    end
	FROM view_Sum_Of_Proportion_Of_Crime_In_Each_Subzone_Consolidated
END
else
	print 'Table DIM_SAFETY Exist Already !!!!'




if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'DIM_SUBZONE')
BEGIN
	CREATE TABLE [dbo].[DIM_SUBZONE](
		[SUBZONE_ID] [numeric](18, 0) NOT NULL,
		[SUBZONE_CODE] [varchar](20) NOT NULL PRIMARY KEY,
		[SUBZONE_NAME] [nvarchar](255) NULL,
		[PLN_AREA_ID] [numeric](18, 0) NULL,
		[PLN_AREA_CODE] [varchar](20) NULL,
		[PLN_AREA_NAME] [nvarchar](255) NULL,
		HEALTH_INDEX_KEY varchar(30) NULL,
		POPULATION_INDEX_KEY varchar(30) NULL,
		AMENITY_INDEX_KEY varchar(30) NULL,
		SAFETY_INDEX_KEY varchar(30) NULL
	) ON [PRIMARY]

	INSERT [DIM_SUBZONE](SUBZONE_ID
		,[SUBZONE_CODE]
		,[SUBZONE_NAME]
		,[PLN_AREA_ID]
		,[PLN_AREA_CODE]
		,[PLN_AREA_NAME], HEALTH_INDEX_KEY, POPULATION_INDEX_KEY, AMENITY_INDEX_KEY, SAFETY_INDEX_KEY)
	SELECT S.SUBZONE_ID, S.[SUBZONE_CODE]
		  ,S.[SUBZONE_NAME]
		  ,S.[PLN_AREA_ID]
		  ,S.[PLN_AREA_CODE]
		  ,S.[PLN_AREA_NAME], H.HEALTH_INDEX_KEY, P.POPULATION_INDEX_KEY, A.AMENITY_INDEX_KEY, C.SAFETY_INDEX_KEY
	FROM STG_SUBZONE_DETAILS S 
		LEFT JOIN DIM_POPULATION_DENSITY_INDEX P ON S.SUBZONE_CODE = P.SUBZONE_CODE
		LEFT JOIN DIM_HEALTH_INDEX H  ON S.SUBZONE_CODE = H.SUBZONE_CODE
		LEFT JOIN DIM_AMENITY_INDEX A ON S.SUBZONE_CODE = A.SUBZONE_CODE
		LEFT JOIN DIM_SAFETY C ON S.SUBZONE_CODE = C.SUBZONE_CODE
END
ELSE
	print 'Table DIM_SUBZONE Exist Already !!!!'



if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'FACT_SUBZONE_TRANSACTION')
BEGIN
	create table dbo.FACT_SUBZONE_TRANSACTION
	(SUBZONE_CODE varchar(20) not null,
	 TRANSACTION_YEAR INT NULL,
	 PROPERTY_TYPE varchar(30) NULL,
	 AVG_TRANSACTION_PSF float NULL,
	 DateKey DATE NULL
	 )

	 /***********Inserting into Subzone wise Amenity DIM Table********************/
	insert into FACT_SUBZONE_TRANSACTION
	select SUBZONE_CODE,TransactionYear,PropertyType, Avg_Transaction_Price_PerSqFt , DateKey
	from
	(
	select S.SUBZONE_CODE,year(TransactionDate) as TransactionYear, 'Private' as PropertyType, CONVERT(DATE,DATEADD(yy, DATEDIFF(yy, 0, TransactionDate), 0)) DateKey,
	AVG(convert(FLOAT,TransactedPricePerSqFt)) as Avg_Transaction_Price_PerSqFt 
	from dbo.STG_SalesTransactions T 
		JOIN STG_Property P ON T.PropertyID = P.PropertyID
		JOIN STG_SUBZONE_DETAILS S ON P.SubzoneID = S.SUBZONE_ID
	where PropertyType in (1,2,7) group by SUBZONE_CODE,year(TransactionDate), CONVERT(DATE,DATEADD(yy, DATEDIFF(yy, 0, TransactionDate), 0)) 
	union
	select S.SUBZONE_CODE,year(TransactionDate) as TransactionYear, 'Public' as PropertyType,CONVERT(DATE,DATEADD(yy, DATEDIFF(yy, 0, TransactionDate), 0)) DateKey,
	AVG(convert(FLOAT,TransactedPricePerSqFt)) as Avg_Transaction_Price_PerSqFt 
	from dbo.STG_SalesTransactions T 
		JOIN STG_Property P ON T.PropertyID = P.PropertyID
		JOIN STG_SUBZONE_DETAILS S ON P.SubzoneID = S.SUBZONE_ID
	where PropertyType = 4 group by SUBZONE_CODE,year(TransactionDate), CONVERT(DATE,DATEADD(yy, DATEDIFF(yy, 0, TransactionDate), 0)) 
	union
	select S.SUBZONE_CODE,year(TransactionDate) as TransactionYear, 'Landed' as PropertyType,CONVERT(DATE,DATEADD(yy, DATEDIFF(yy, 0, TransactionDate), 0)) DateKey,
	AVG(convert(FLOAT,TransactedPricePerSqFt)) as Avg_Transaction_Price_PerSqFt
	from dbo.STG_SalesTransactions T 
		JOIN STG_Property P ON T.PropertyID = P.PropertyID
		JOIN STG_SUBZONE_DETAILS S ON P.SubzoneID = S.SUBZONE_ID
	where PropertyType in (3,5,6) group by SUBZONE_CODE,year(TransactionDate), CONVERT(DATE,DATEADD(yy, DATEDIFF(yy, 0, TransactionDate), 0)) 
	   ) a order by TransactionYear, SUBZONE_CODE desc
END
ELSE
	print 'Table FACT_SUBZONE_TRANSACTION Exist Already !!!!'


/********************************* FOREIGN KEY *********************************/
if not exists(SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS 
WHERE CONSTRAINT_NAME='FK_Dim_Property_AmenityNearby_Dim_Amenity_Accessibility')
	ALTER TABLE [dbo].[Dim_Property_AmenityNearby]  ADD  CONSTRAINT [FK_Dim_Property_AmenityNearby_Dim_Amenity_Accessibility] FOREIGN KEY([AmenityID])
	REFERENCES [dbo].[Dim_Amenity_Accessibility] ([ID])
GO

if not exists(SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS 
WHERE CONSTRAINT_NAME='FK_Dim_Property_AmenityNearby_Dim_Property')
	ALTER TABLE [dbo].[Dim_Property_AmenityNearby]  ADD  CONSTRAINT [FK_Dim_Property_AmenityNearby_Dim_Property] FOREIGN KEY([PropertyID])
	REFERENCES [dbo].[Dim_Property] ([PropertyID])
GO

if not exists(SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS 
WHERE CONSTRAINT_NAME='FK_Fact_PropertySales_Dim_Property')
	ALTER TABLE [dbo].[Fact_PropertySales]  ADD  CONSTRAINT [FK_Fact_PropertySales_Dim_Property] FOREIGN KEY([PropertyID])
	REFERENCES [dbo].[Dim_Property] ([PropertyID])
GO

if not exists(SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS 
WHERE CONSTRAINT_NAME='FK_Fact_PropertySales_Dim_Date')
	ALTER TABLE [dbo].[Fact_PropertySales]  ADD  CONSTRAINT [FK_Fact_PropertySales_Dim_Date] FOREIGN KEY(TransactionDate)
	REFERENCES [dbo].[Dim_Date] (DateKey)
GO

if not exists(SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS 
WHERE CONSTRAINT_NAME='FK_Fact_PropertyRentals_Dim_Property')
	ALTER TABLE [dbo].[Fact_PropertyRentals]  ADD  CONSTRAINT [FK_Fact_PropertyRentals_Dim_Property] FOREIGN KEY([PropertyID])
	REFERENCES [dbo].[Dim_Property] ([PropertyID])
GO

if not exists(SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS 
WHERE CONSTRAINT_NAME='FK_Fact_PropertyRentals_Dim_Date')
	ALTER TABLE [dbo].[Fact_PropertyRentals]  ADD  CONSTRAINT [FK_Fact_PropertyRentals_Dim_Date] FOREIGN KEY(TransactionDate)
	REFERENCES [dbo].[Dim_Date] (DateKey)
GO

if not exists(SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS 
WHERE CONSTRAINT_NAME='FK_FACT_SUBZONE_TRANSACTION_Dim_Date')
	ALTER TABLE [dbo].[FACT_SUBZONE_TRANSACTION]  ADD  CONSTRAINT [FK_FACT_SUBZONE_TRANSACTION_Dim_Date] FOREIGN KEY(DateKey)
	REFERENCES [dbo].[Dim_Date] (DateKey)
GO

if not exists(SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS 
WHERE CONSTRAINT_NAME='FK_FACT_SUBZONE_TRANSACTION_DIM_SUBZONE')
	ALTER TABLE [dbo].[FACT_SUBZONE_TRANSACTION]  ADD  CONSTRAINT [FK_FACT_SUBZONE_TRANSACTION_DIM_SUBZONE] FOREIGN KEY(SUBZONE_CODE)
	REFERENCES [dbo].[DIM_SUBZONE] (SUBZONE_CODE)
GO

if not exists(SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS 
WHERE CONSTRAINT_NAME='FK_DIM_SUBZONE_DIM_HEALTH_INDEX')
	ALTER TABLE [dbo].[DIM_SUBZONE]  ADD  CONSTRAINT [FK_DIM_SUBZONE_DIM_HEALTH_INDEX] FOREIGN KEY(HEALTH_INDEX_KEY)
	REFERENCES [dbo].[DIM_HEALTH_INDEX] (HEALTH_INDEX_KEY)
GO

if not exists(SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS 
WHERE CONSTRAINT_NAME='FK_DIM_SUBZONE_DIM_POPULATION_DENSITY_INDEX')
	ALTER TABLE [dbo].[DIM_SUBZONE]  ADD  CONSTRAINT [FK_DIM_SUBZONE_DIM_POPULATION_DENSITY_INDEX] FOREIGN KEY(POPULATION_INDEX_KEY)
	REFERENCES [dbo].[DIM_POPULATION_DENSITY_INDEX] (POPULATION_INDEX_KEY)
GO

if not exists(SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS 
WHERE CONSTRAINT_NAME='FK_DIM_SUBZONE_DIM_AMENITY_INDEX')
	ALTER TABLE [dbo].[DIM_SUBZONE]  ADD  CONSTRAINT [FK_DIM_SUBZONE_DIM_AMENITY_INDEX] FOREIGN KEY(AMENITY_INDEX_KEY)
	REFERENCES [dbo].[DIM_AMENITY_INDEX] (AMENITY_INDEX_KEY)
GO

if not exists(SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS 
WHERE CONSTRAINT_NAME='FK_DIM_SUBZONE_DIM_SAFETY')
	ALTER TABLE [dbo].[DIM_SUBZONE]  ADD  CONSTRAINT [FK_DIM_SUBZONE_DIM_SAFETY] FOREIGN KEY(SAFETY_INDEX_KEY)
	REFERENCES [dbo].[DIM_SAFETY] (SAFETY_INDEX_KEY)
GO







