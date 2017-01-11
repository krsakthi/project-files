USE [DWProperty]
GO

/*************************************************** Insert the data from CSV files ********************************************************************/

DECLARE @sql varchar(max) = ''
DECLARE @FolderPath varchar(1000) = 'C:\Users\Sakthi\Desktop\FT08_DWH_CA_Project_Files\RAW_DATA_AND_ETL_SCRIPTS\RAWDATA\'

SET @sql = '
begin
TRUNCATE TABLE SUBZONE_WITH_SHAPEID
bulk insert [dbo].[SUBZONE_WITH_SHAPEID]
from ''' +@FolderPath+ 'temp-nodes.csv''
with
  (Firstrow = 2,
  Fieldterminator = '','', 
   RowTerminator = ''\n'')
end'

EXEC(@sql)

SET @sql = '
begin
	TRUNCATE TABLE RAW_SalesTransactions
	bulk insert [dbo].[RAW_SalesTransactions]
	from ''' +@FolderPath+ 'SalesTransactions.csv''
	with
	  (Firstrow = 2,
	  Fieldterminator = '','',
	   RowTerminator = ''\n'' )
end '

EXEC (@sql)

SET @sql = '
begin
	TRUNCATE TABLE RAW_RentalTransactions
	bulk insert [dbo].[RAW_RentalTransactions]
	from ''' +@FolderPath+ 'RentalTransactions.csv''
	with
	  (Firstrow = 2,
	  Fieldterminator = '','',
	   RowTerminator = ''\n'' )
end
'

EXEC (@sql)

SET @sql = '
begin
	TRUNCATE TABLE RAW_PropertySpatialMetricAssets
	bulk insert [dbo].[RAW_PropertySpatialMetricAssets]
	from ''' +@FolderPath+ 'PropertySpatialMetricAssets.csv''
	with
	  (Firstrow = 2,
	  FIELDTERMINATOR=''","'',
	   RowTerminator = ''\n'' )
end
'

EXEC (@sql)
SET @sql = '
begin
	TRUNCATE TABLE RAW_PointOfInterests
	bulk insert [dbo].[RAW_PointOfInterests]
	from ''' +@FolderPath+ 'PointOfInterests.csv''
	with
	  (Firstrow = 2,
	  Fieldterminator = '','',
	   RowTerminator = ''\n'' )
end
'

EXEC (@sql)



SET @sql='begin
TRUNCATE TABLE RAW_POPULATION_DENSITY
bulk insert [dbo].[RAW_POPULATION_DENSITY]
from '''+@FolderPath+'populationDensity.csv''
with
  (Firstrow = 2,
  Fieldterminator = '','',
   RowTerminator = ''\n'' )
end'

EXEC(@sql)
/******************Insert the data from raw Dengue cluster.csv file************************/

SET @sql='begin
	TRUNCATE TABLE RAW_DENGUE_CLUSTER
	bulk insert [dbo].[RAW_DENGUE_CLUSTER]
	from '''+@FolderPath+'Dengue_Cluster.csv''
	with
	(Firstrow = 2,
	Fieldterminator = '','',
	RowTerminator = ''\n'' )
	end'
EXEC(@sql)

/******************Insert the data from raw Dengue cluster.csv file************************/
SET @sql='begin
		TRUNCATE TABLE RAW_MALARIA_CLUSTER
		  bulk insert [dbo].[RAW_MALARIA_CLUSTER]
		  from '''+@FolderPath+'malaria.csv''
		  with
		  (Firstrow = 2,
		  Fieldterminator = '','',
		  RowTerminator = ''\n'' )
		  end'

EXEC(@sql)


/******************Insert the data from raw community club - singapore .csv file************************/
SET @sql = '
begin
TRUNCATE TABLE RAW_AMENITY_COMMUNITY_CLUB
bulk insert [dbo].[RAW_AMENITY_COMMUNITY_CLUB]
from ''' +@FolderPath+ 'CCWithSZnew.csv''
with
  (Firstrow = 2,
  Fieldterminator = '','',
   RowTerminator = ''\n'' )
end'
EXEC(@sql)

/******************Insert data from the raw gyms-singapore .csv file************************/
SET @sql = '
begin
TRUNCATE TABLE RAW_AMENITY_GYMS
bulk insert [dbo].[RAW_AMENITY_GYMS]
from ''' +@FolderPath+ 'GymsWithSZNew1.csv''
with
  (Firstrow = 2,
  Fieldterminator = '','',
   RowTerminator = ''\n'')
end'
EXEC(@sql)


/******************Insert data from the raw HawkerCentre-singapore .csv file************************/
SET @sql = '
begin
TRUNCATE TABLE RAW_AMENITY_HAWKER_CENTRE
bulk insert [dbo].[RAW_AMENITY_HAWKER_CENTRE]
from ''' +@FolderPath+ 'Hawker-CentreWithSZNew.csv''
with
  (Firstrow = 2,
  Fieldterminator = '','',
   RowTerminator = ''\n'')
end'
EXEC(@sql)


/******************Insert data from the raw SportsCentre-singapore .csv file************************/
SET @sql = '
begin
TRUNCATE TABLE RAW_AMENITY_SPORTS
bulk insert [dbo].[RAW_AMENITY_SPORTS]
from ''' +@FolderPath+ 'SportswithSZNew1.csv''
with
  (Firstrow = 2,
  Fieldterminator = '','',
   RowTerminator = ''\n'')
end'
EXEC(@sql)


/******************Insert data from the raw Parks-singapore .csv file************************/
SET @sql = '
begin
TRUNCATE TABLE RAW_AMENITY_PARKS
bulk insert [dbo].[RAW_AMENITY_PARKS]
from ''' +@FolderPath+ 'ParksWithSZNew1.csv''
with
  (Firstrow = 2,
  Fieldterminator = '','',
   RowTerminator = ''\n''
   )
end'
EXEC(@sql)


/******************Insert data from the raw KinderGarten-singapore .csv file************************/
SET @sql = '
begin
TRUNCATE TABLE RAW_AMENITY_KINDER
bulk insert [dbo].[RAW_AMENITY_KINDER]
from ''' +@FolderPath+ 'KinderWithSZNew1.csv''
with
  (Firstrow = 2,
  Fieldterminator = '','',
   RowTerminator = ''\n'' )
end'
EXEC(@sql)

/******************Insert data from the raw Subzone .csv file************************/

SET @sql = '
begin
TRUNCATE TABLE STG_SUBZONE_DETAILS
bulk insert [dbo].[STG_SUBZONE_DETAILS]
from ''' +@FolderPath+ 'Subzones.csv''
with
  (Firstrow = 2,
  Fieldterminator = '','',
   RowTerminator = ''\n'' )
end'

EXEC(@sql)


/******************RAW_CRIMERECORDEDBYNPCS ************************/
SET @sql = '
begin
TRUNCATE TABLE RAW_CRIME_RECORDED_BY_NPCS
bulk insert [dbo].[RAW_CRIME_RECORDED_BY_NPCS]
from ''' +@FolderPath+ 'CrimeInNPC.csv''
with
  (Firstrow = 2,
  Fieldterminator = '','',
   RowTerminator = ''\n'' )
end'
EXEC(@sql)


/******************RAW_INTERSECTDATA ************************/ 
SET @sql = '
begin
TRUNCATE TABLE RAW_INTERSECT_DATA
bulk insert [dbo].[RAW_INTERSECT_DATA]
from ''' +@FolderPath+ 'Intersectdata.csv''
with
  (Firstrow = 2,
  Fieldterminator = '','',
   RowTerminator = ''\n'' )
end'
EXEC(@sql)



if not exists(select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'dbo' and t.name = 'Dim_Property_AmenityNearby')
BEGIN
	CREATE TABLE [dbo].Dim_Property_AmenityNearby(
		[PropertyID] [varchar](20) NOT NULL,
		[AmenityID] [varchar](30) NOT NULL,
		[Distance] INT NULL
	) ON [PRIMARY]

	SET @sql = '
	begin
	bulk insert [dbo].[Dim_Property_AmenityNearby]
	from ''' +@FolderPath+ 'AmenityAccessibilityNearby.csv''
	with
	  (Firstrow = 2,
	  Fieldterminator = '','',
	   RowTerminator = ''\n'' )
	end'
	EXEC(@sql)
END