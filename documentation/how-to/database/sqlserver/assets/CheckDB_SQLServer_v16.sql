----------------------------------------------------------
-- CheckDB_SQLServer V18
-- 
-- Copyright Identity Analytics
-- Modified : may 2023
-- add number of index per table
-- Prerequisites : admin account
-- Parameters : line 12 "use databasename", line 18 & 19 : dbname and dbschema
----------------------------------------------------------

-- Ensure a USE <databasename> statement has been executed first

use "test";     -- !REPLACE databasename
GO
DECLARE @dbname VARCHAR(50);
DECLARE @dbschema NVARCHAR(50);
DECLARE @SQLString NVARCHAR(500);

set @dbname = 'test';     -- !REPLACE dbname
set @dbschema = 'igrc';   -- !REPLACE dbschema


-- Some informations on database

select upper(name) as [DBNAME],
recovery_model_desc as [RecoveryModel],
PageDetection=(case Page_verify_option_desc
when 'CHECKSUM' then 'CHECKSUM'
else page_verify_option_desc +': Warning: Microsoft recommends to use Checksum' end),
AutoShrink=(case is_auto_shrink_on
when 0 then 'OFF' 
else 'ON: Warning---AutoShrink cause severe performance issue, if not application requirement, please turn it OFF' end),
DBOWNER=(Case owner_sid
when suser_sid('sa') then 'SA'
else suser_sname(owner_sid)+': It is recommended to change the dbowner to SA' end),
'SQL'+substring(@@version,22,4) as SQLVersion,
CompatibilityLevel=(case when compatibility_level = 130 then 'SQL2016'
when compatibility_level = 120 then 'SQL2014'
when compatibility_level = 110 then 'SQL2012'
when compatibility_level=100 then 'SQL2008'
when compatibility_level=90 then 'SQL2005'
when compatibility_level=80 then 'SQL2000' end),
AutoUpdateStats=(case is_auto_update_stats_on
when 0 then 'OFF'
else 'ON: Its recommended to turn it off and schedule a weekly\daily job' end),
Log_reuse_wait_desc as [WhyLogCanNotBeReUsed],
collation_name as [character_set]
from sys.databases where name=@dbname


-- Size of the database
DECLARE @Kb float
DECLARE @PageSize float
DECLARE @SQL varchar(2000)
DECLARE @nbportal1 integer
DECLARE @tblVar TABLE (ResultingCount int)

--INSERT INTO @tblVar 

SET @SQLSTRING = 'SELECT COUNT(1) from ' + @dbschema + '.timportlog where cportal=1';
INSERT INTO @tblVar Exec (@SQLSTRING);

SELECT @nbportal1 = (SELECT ResultingCount from @tblVar);
SELECT @Kb = 1024.0
SELECT @PageSize=v.low/@Kb FROM master..spt_values v WHERE v.number=1 AND v.type='E'

IF OBJECT_ID('tempdb.dbo.#FileSize') IS NOT NULL
	DROP TABLE #FileSize
CREATE TABLE #FileSize (
	DatabaseName sysname,
	FileName sysname,
	FileSize int,
	FileGroupName sysname,
	LogicalName sysname
)

IF OBJECT_ID('tempdb.dbo.#FileStats') IS NOT NULL
	DROP TABLE #FileStats
CREATE TABLE #FileStats (
	FileID int,
	FileGroup int,
	TotalExtents int,
	UsedExtents int,
	LogicalName sysname,
	FileName nchar(520)
)

IF OBJECT_ID('tempdb.dbo.#LogSpace') IS NOT NULL
	DROP TABLE #LogSpace
CREATE TABLE #LogSpace (
	DatabaseName sysname,
	LogSize float,
	SpaceUsedPercent float,
	Status bit
)

INSERT #LogSpace EXEC ('DBCC sqlperf(logspace)')

DECLARE @DatabaseName sysname

DECLARE cur_Databases CURSOR FAST_FORWARD FOR
	SELECT DatabaseName = [name] FROM master.dbo.sysdatabases where name=@dbname ORDER BY DatabaseName
OPEN cur_Databases
FETCH NEXT FROM cur_Databases INTO @DatabaseName
WHILE @@FETCH_STATUS = 0
  BEGIN
	SET @SQL = '
USE [' + @DatabaseName + '];
DBCC showfilestats;
INSERT #FileSize (DatabaseName, FileName, FileSize, FileGroupName, LogicalName)
SELECT ''' +@DatabaseName + ''', filename, size, ISNULL(FILEGROUP_NAME(groupid),''LOG''), [name]
 FROM dbo.sysfiles sf;
'

	INSERT #FileStats EXECUTE (@SQL)
	FETCH NEXT FROM cur_Databases INTO @DatabaseName
  END

CLOSE cur_Databases
DEALLOCATE cur_Databases

SELECT
	DatabaseName = fsi.DatabaseName,
	FileGroupName = fsi.FileGroupName,
	LogicalName = RTRIM(fsi.LogicalName),
	FileName = RTRIM(fsi.FileName),
	FileSize = CAST(fsi.FileSize*@PageSize/@Kb as decimal(15,2)),
	UsedSpace = CAST(ISNULL((fs.UsedExtents*@PageSize*8.0/@Kb), fsi.FileSize*@PageSize/@Kb * ls.SpaceUsedPercent/100.0) as decimal(15,2)),
	FreeSpace = CAST(ISNULL(((fsi.FileSize - UsedExtents*8.0)*@PageSize/@Kb), (100.0-ls.SpaceUsedPercent)/100.0 * fsi.FileSize*@PageSize/@Kb) as decimal(15,2)),
	[FreeSpace %] = CAST(ISNULL(((fsi.FileSize - UsedExtents*8.0) / fsi.FileSize * 100.0), 100-ls.SpaceUsedPercent) as decimal(15,2)),
	'Maxsize' = ( CASE max_size WHEN - 1 THEN N'Unlimited' ELSE CONVERT(NVARCHAR(15), CONVERT(BIGINT, max_size) * 8) + N' KB' END ),
	'Growth' = ( CASE is_percent_growth WHEN 1 THEN CONVERT(NVARCHAR(15), growth) + N'%' ELSE CONVERT(NVARCHAR(15), CONVERT(BIGINT, growth) * 8 ) + N' KB' END )
 FROM #FileSize fsi
 LEFT JOIN #FileStats fs
	ON fs.FileName = fsi.FileName
 LEFT JOIN #LogSpace ls
	ON ls.DatabaseName = fsi.DatabaseName
 INNER JOIN sys.master_files mf
	ON mf.name = RTRIM(fsi.LogicalName)
 ORDER BY 1,3

 
-- Information on tempdb database

SELECT physical_name AS FileName, name AS Name, 
   size*1.0/128 AS CurrentFileSizeinMB,
   CASE max_size 
       WHEN 0 THEN 'Autogrowth is off.'
       WHEN -1 THEN 'Autogrowth is on.'
       ELSE 'Log file grows to a maximum size of 2 TB.'
   END,
   growth AS 'GrowthValue',
   'GrowthIncrement' = 
       CASE
           WHEN growth = 0 THEN 'Size is fixed.'
           WHEN growth > 0 AND is_percent_growth = 0 
               THEN 'Growth value is in 8-KB pages.'
           ELSE 'Growth value is a percentage.'
       END
FROM tempdb.sys.database_files;

-- Total TEMPDB Size (Mb)
SELECT SUM(size)/128 AS [Total tempdb size (MB)]
FROM tempdb.sys.database_files;

-- TEMPDB Freespace 
SELECT SUM(unallocated_extent_page_count) AS [free_pages]
,(SUM(unallocated_extent_page_count) * 1.0 / 128) AS [free_space_MB]
FROM sys.dm_db_file_space_usage;


 
-- List of parameters of database
select * FROM sys.configurations
select * from sys.dm_os_sys_info



-- Add statistics informations in using DBCC SQLPERF
-- Transaction log for all the database
DBCC SQLPERF (LOGSPACE)

-- SQL Server Thread management
DBCC SQLPERF (UMSSTATS)

-- wait types for SQL Server resources
DBCC SQLPERF (WAITSTATS)
 
-- outstanding SQL Server reads and writes
DBCC SQLPERF (IOSTATS)

-- Read-ahead activity
DBCC SQLPERF (RASTATS)

-- IO, CPU, memory usage per SQL server thread
DBCC SQLPERF (THREADS)


-- Information concerning iGRC Schema

-- # number of index per table including uk and pk

SELECT 
     count(ind.name) nb_index,t.name
FROM 
     sys.indexes ind 
INNER JOIN 
     sys.tables t ON ind.object_id = t.object_id 
GROUP BY 
     t.name
ORDER BY 1 DESC;


-- list of indexes

   SET NOCOUNT ON;
   SET DEADLOCK_PRIORITY LOW;
   ---
   SELECT s.[Schema]          AS [Schema],
          s.[Object Name]     AS [Object Name],
          s.[Object Type]     AS [Object Type],
          s.[Index]           AS [Index],
          s.[Fill Factor]     AS [Fill Factor],
          s.[Index Type]      AS [Index Type],
          s.[Primary Key]     AS [Primary Key],
          s.[Is Unique]       AS [Is Unique],
          ISNULL(s.[1], '')   AS [Column #1],
          ISNULL(s.[2], '')   AS [Column #2],
          ISNULL(s.[3], '')   AS [Column #3],
          ISNULL(s.[4], '')   AS [Column #4],
          ISNULL(s.[5], '')   AS [Column #5],
          ISNULL(s.[6], '')   AS [Column #6],
          ISNULL(s.[7], '')   AS [Column #7],
          ISNULL(s.[8], '')   AS [Column #8],
          ISNULL(s.[9], '')   AS [Column #9],      
          ISNULL(s.[10], '')  AS [Column #10],
          CASE ISNULL(s.[11], 'No more columns')
            WHEN 'No more columns'  THEN ''
            ELSE                         'Yes'
          END                    AS [More columns]  
   FROM (SELECT ss.name                    AS [Schema],
                so.name                    AS [Object Name],
                CASE so.type
                   WHEN 'U'  THEN 'Table'
                   WHEN 'V'  THEN 'View'
                   WHEN 'IT' THEN 'Internal table'
                   WHEN 'TF' THEN 'Table function'
                   ELSE           so.Type
                END                        AS [Object Type] ,  
                ISNULL(si.name, '')        AS [Index],
                ISNULL(sc.name, '') +
                CASE ic.is_included_column
                   WHEN 1   THEN '(inc)'
                   ELSE CASE ic.is_descending_key
                          WHEN 0 THEN '(+)'
                          ELSE        '(-)'
                        END                        
                END                        AS [ColumnName],    
                si.fill_factor             AS [Fill Factor],
                si.type_desc               AS [Index Type],
                CASE si.is_primary_key
                   WHEN 1    THEN 'Yes'
                   ELSE           ''
                END                        AS [Primary Key],
                CASE si.is_unique_constraint
                   WHEN 1    THEN 'Yes'
                   ELSE           ''
                END                        AS [Is Unique],
                ic.index_column_id         AS [IndexPosition]
         FROM sys.objects             so  
         INNER JOIN sys.schemas       ss  ON ss.schema_id = so.schema_id
         INNER JOIN sys.indexes       si  ON si.object_id = so.object_id
                                         AND si.is_hypothetical = 0  
         LEFT  JOIN sys.index_columns ic  ON ic.object_id = si.object_id
                                         AND ic.index_id  = si.index_id
         LEFT  JOIN sys.columns       sc  ON sc.column_id = ic.column_id
                                         AND sc.object_id = ic.object_id
		  WHERE ss.name=@dbschema) idx
   PIVOT (MIN(ColumnName)
          FOR IndexPosition IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11]) ) S;  
  		  
-- Fragmentation index
SELECT dbschemas.[name] as 'Schema',
dbtables.[name] as 'Table',
dbindexes.[name] as 'Index',
indexstats.avg_fragmentation_in_percent,
indexstats.page_count
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
AND indexstats.index_id = dbindexes.index_id
WHERE indexstats.database_id = DB_ID()
ORDER BY indexstats.avg_fragmentation_in_percent desc		  
		  
-- Count number of records and size of each table (including indexes)

SELECT
    t.[Name] AS TableName,
    p.[rows] AS [RowCount],
    SUM(a.total_pages) * 8 AS TotalSpaceKB,
    SUM(a.used_pages) * 8 AS UsedSpaceKB
FROM sys.tables t
INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE t.is_ms_shipped = 0 
    AND i.OBJECT_ID > 255
GROUP BY t.[Name], p.[Rows]
ORDER BY t.[Name];



-- Average Size of one timeslot in portal tables

create table #TSSpaceUSed (
TableName sysname, nbrows BIGINT, TotalSpaceKB BIGINT, UsedSpaceKB BIGINT);

INSERT INTO #TSSpaceUSed SELECT
    t.[Name] AS TableName,
    p.[rows] AS [RowCount],
    SUM(a.total_pages) * 8 AS TotalSpaceKB,
    SUM(a.used_pages) * 8 AS UsedSpaceKB
FROM sys.tables t
INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE t.is_ms_shipped = 0 
    AND i.OBJECT_ID > 255
	AND t.name like 'tportal%'
GROUP BY t.[Name], p.[Rows]
ORDER BY t.[Name];

 
select 'Average Size of one timeslot in tportal tables (Total Space MB) : ', SUM(TotalSpaceKB)/1024/@nbportal1 FROM #TSSpaceUSed;



-- Size of each index

SELECT
    i.[name] AS IndexName,
    t.[name] AS TableName,
    SUM(s.[used_page_count]) * 8 AS IndexSizeKB
FROM sys.dm_db_partition_stats AS s
INNER JOIN sys.indexes AS i ON s.[object_id] = i.[object_id]
    AND s.[index_id] = i.[index_id]
INNER JOIN sys.tables t ON t.OBJECT_ID = i.object_id
GROUP BY i.[name], t.[name]
ORDER BY i.[name], t.[name];	

-- List views

SELECT *  
  FROM information_schema.views;


-- List the contents of tproperties table
SET @SQLString = 'select * from ' + @dbschema + '.tproperties';
EXECUTE sp_executesql @SQLString;


-- List the contents of timportlog table
SET @SQLString = 'select * from ' + @dbschema + '.timportlog order by cproductversion';
EXECUTE sp_executesql @SQLString;


-- Count number of records per timeslot for control tables 

SET @SQLString = 'select count(*) as "Control Log",cimportdate as "Import date" from ' + @dbschema + '.tcontrollog join ' + @dbschema + '.timportlog on ctimeslotfk=cimportloguid group by cimportdate order by cimportdate';
EXECUTE sp_executesql @SQLString;

SET @SQLString = 'select count(*) as "Control Results" from ' + @dbschema + '.tcontrolresult';
EXECUTE sp_executesql @SQLString;

SET @SQLString = 'select count(d.crecorduid) as "Control Discrepancy", l.ctimeslotfk from ' + @dbschema + '.tcontroldiscrepancy d
	inner join ' + @dbschema + '.tcontrollog l on d.ccontrollogfk=l.crecorduid
	group by l.ctimeslotfk;'
EXECUTE sp_executesql @SQLString;

SET @SQLString = 'select count(r.crecorduid) as "Control Root Cause", l.ctimeslotfk from ' + @dbschema + '.tcontrolrootcause r
	inner join ' + @dbschema + '.tcontroldiscrepancy d on r.ccontroldiscrepancyfk=d.crecorduid
	inner join ' + @dbschema + '.tcontrollog l on d.ccontrollogfk=l.crecorduid
	group by l.ctimeslotfk;'
EXECUTE sp_executesql @SQLString;
 
-- Allow to know the datatype of columns
SELECT * FROM INFORMATION_SCHEMA.COLUMNS;


-- Check max crecorduid 
SELECT TABLE_NAME,TABLE_SCHEMA
INTO #TableList 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE column_name = 'crecorduid' AND TABLE_NAME not like 'tportal%' AND TABLE_NAME not like 'vportal%';

CREATE TABLE #TempResult (TableName VARCHAR(100), MaxCRecorduid BIGINT)

DECLARE @TableName      VARCHAR(100)
        ,@TableSchema   VARCHAR(100)
DECLARE @SqlQuery   NVARCHAR(MAX)

WHILE(EXISTS(SELECT TOP(1) * FROM #TableList))
BEGIN
    SELECT TOP(1) @TableName = TABLE_NAME, @TableSchema = TABLE_SCHEMA FROM #TableList
    DELETE #TableList WHERE TABLE_NAME = @TableName

    SET @TableName = @TableSchema +'.'+ @TableName
    SET @SqlQuery = 'SELECT '''+@TableName+''' AS ''TableName'', MAX(crecorduid) AS MaxDate FROM '+ @TableName
    INSERT INTO #TempResult
    EXECUTE sp_executesql @SqlQuery
END


-- Sort to display
SELECT * from #TempResult order by 2 desc;

-- Drop temporary tables
DROP TABLE #TableList
DROP TABLE #TempResult;
DROP TABLE #TSSpaceUSed;


-- Last date updated statistics
SELECT t.name TableName, s.[name] StatName, STATS_DATE(t.object_id,s.[stats_id]) LastUpdated 
FROM sys.[stats] AS s
JOIN sys.[tables] AS t
    ON [s].[object_id] = [t].[object_id]
WHERE t.type = 'u';



--------------------------------------------------------
--
-- Count number of records per timeslot tables - portal tables 
--------------------------------------------------------------


SELECT TABLE_NAME,TABLE_SCHEMA
INTO #TableList2 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE column_name = 'ctimeslotfk' AND TABLE_NAME like 'tportal%' AND TABLE_NAME not like 'vportal%';

CREATE TABLE #TempResult2 (TableName VARCHAR(100), nbrecords BIGINT, ctimeslotfk VARCHAR(100));


WHILE(EXISTS(SELECT TOP(1) * FROM #TableList2))
BEGIN
    SELECT TOP(1) @TableName = TABLE_NAME, @TableSchema = TABLE_SCHEMA FROM #TableList2 order by 1
    DELETE #TableList2 WHERE TABLE_NAME = @TableName

    SET @TableName = @TableSchema +'.'+ @TableName
    SET @SqlQuery = 'SELECT '''+ @TableName+''', COUNT(*), ctimeslotfk FROM '+ @TableName + ' group by ctimeslotfk order by ctimeslotfk;' 
    INSERT INTO #TempResult2
    EXECUTE sp_executesql @SqlQuery
END

-- Sort to display
SELECT * from #TempResult2;

-- Drop temporary tables
DROP TABLE #TableList2;
DROP TABLE #TempResult2;

------------------------------------------------------------
--
-- Count number of records per timeslot - historical tables 
------------------------------------------------------------


SELECT TABLE_NAME,TABLE_SCHEMA
INTO #TableList4 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE column_name = 'ctimeslotfk' AND TABLE_NAME not like 'tportal%' AND TABLE_NAME not like 'vportal%' AND TABLE_NAME not like 'timport%';

CREATE TABLE #TempResult4 (TableName VARCHAR(100), nbrecords BIGINT, ctimeslotfk VARCHAR(100));


WHILE(EXISTS(SELECT TOP(1) * FROM #TableList4))
BEGIN
    SELECT TOP(1) @TableName = TABLE_NAME, @TableSchema = TABLE_SCHEMA FROM #TableList4 order by 1
    DELETE #TableList4 WHERE TABLE_NAME = @TableName

    SET @TableName = @TableSchema +'.'+ @TableName
    SET @SqlQuery = 'SELECT '''+ @TableName+''', COUNT(*), ctimeslotfk FROM '+ @TableName + ' group by ctimeslotfk order by ctimeslotfk;' 
    INSERT INTO #TempResult4
    EXECUTE sp_executesql @SqlQuery
END

-- Sort to display
SELECT * from #TempResult4;

-- Drop temporary tables
DROP TABLE #TableList4;
DROP TABLE #TempResult4;



--------------------------------------------------------
--
-- Count number of records per timeslot in the import tables 
--------------------------------------------------------

SELECT TABLE_NAME,TABLE_SCHEMA
INTO #TableList3 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE COLUMN_NAME = 'cimportlogfk' and TABLE_NAME like 'timport%' ;

CREATE TABLE #TempResult3 (TableName VARCHAR(100), nbrecords BIGINT, cimportlogfk VARCHAR(100));

WHILE(EXISTS(SELECT TOP(1) * FROM #TableList3))
BEGIN
    SELECT TOP(1) @TableName = TABLE_NAME, @TableSchema = TABLE_SCHEMA FROM #TableList3 order by 1
    DELETE #TableList3 WHERE TABLE_NAME = @TableName

    SET @TableName = @TableSchema +'.'+ @TableName
    SET @SqlQuery = 'SELECT '''+ @TableName+''', COUNT(*), cimportlogfk FROM '+ @TableName + ' group by cimportlogfk order by cimportlogfk;' 
    INSERT INTO #TempResult3
    EXECUTE sp_executesql @SqlQuery
END

-- Sort to display
SELECT * from #TempResult3;

drop table #TableList3 ;
drop table #TempResult3 ;


--------------------------------------------------------
--
-- List all unused indexes based on statistics 
--------------------------------------------------------
SELECT
    objects.name AS Table_name,
    indexes.name AS Index_name,
    dm_db_index_usage_stats.user_seeks,
    dm_db_index_usage_stats.user_scans,
    dm_db_index_usage_stats.user_updates
FROM
    sys.dm_db_index_usage_stats
    INNER JOIN sys.objects ON dm_db_index_usage_stats.OBJECT_ID = objects.OBJECT_ID
    INNER JOIN sys.indexes ON indexes.index_id = dm_db_index_usage_stats.index_id AND dm_db_index_usage_stats.OBJECT_ID = indexes.OBJECT_ID
WHERE
    dm_db_index_usage_stats.user_lookups = 0
    AND
    dm_db_index_usage_stats.user_seeks = 0
    AND
    dm_db_index_usage_stats.user_scans = 0
ORDER BY
    dm_db_index_usage_stats.user_updates DESC;

--------------------------------------------------------
--
-- All locks currently held in an instance 
--------------------------------------------------------

GO  
EXEC sp_lock;  
GO  


--------------------------------------------------------
-- END 
--------------------------------------------------------
