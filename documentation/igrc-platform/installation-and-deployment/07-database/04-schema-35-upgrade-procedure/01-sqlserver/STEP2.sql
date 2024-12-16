/* 
COPYRIGHT BRAINWAVE, all rights reserved.
This computer program is protected by copyright law and international treaties.
Unauthorized duplication or distribution of this program, or any portion of it, may result in severe civil or criminal penalties, and will be prosecuted to the maximum extent possible under the law.

Usage: Execute the migration int to biging and save the results of queries in a file (so no real modification of the database in this first step) 

(c) Radiant Logic 2021

1) Powershell

To execute the commande in powershell use the following command syntax:

Invoke-Sqlcmd -InputFile <String> -ServerInstance <String> -database <database> -Username <String> -Password <String> -verbose 4>&1 > c:\temp\Step3_queries.sql

This requires the "SqlServer" powershell module

2) SQL Server management

To excute in SQL Server management studio directly please uncomment the folling block and replace the parameters between "<>" accordingly.
And save the results in a text file

*/
/* 
use "<DATABASE>" ;
execute as login='<USER>' ;
*/

GO
IF object_id('DropForeignKeysQueries') IS NOT NULL DROP FUNCTION DropForeignKeysQueries
 GO   

  /* SQL Server FUNCTION for upgrading from int to bigint
 deletes all ForeignKeys queries related to @TableName and the list of columns @Columns
- @TableName Table name
- @Columns columns to be migrated separated by cumma
*/ 

CREATE FUNCTION DropForeignKeysQueries ()
RETURNS @Queries TABLE (query VARCHAR(MAX))
BEGIN

declare @ForeignKeyName varchar(4000)
declare @ParentTableName varchar(4000)
declare @ParentTableSchema varchar(4000)
declare @TSQLDropFK varchar(max)

declare @schema varchar(max)

SET @schema = (select schema_name())

declare CursorFK cursor for 
select distinct fk.name ForeignKeyName, schema_name(t.schema_id) ParentTableSchema, t.name ParentTableName
from sys.foreign_keys fk  
 inner join sys.tables t on fk.parent_object_id=t.object_id
  inner join sys.foreign_key_columns fkc on fk.object_id=fkc.constraint_object_id
  inner join sys.columns c1 on c1.object_id=fkc.parent_object_id and c1.column_id=fkc.parent_column_id
  JOIN sys.types AS p ON c1.system_type_id = p.system_type_id
  where t.type_desc = 'USER_TABLE' 
  and p.name = 'int' 
  and schema_name(t.schema_id) = @schema  
  and (c1.name = 'crecorduid' or c1.name like '%fk' or c1.name in ('cforeignrecorduid','cobjectrecorduid','cobjectuid','coptionuid','crequestid','cworkrecuid'))
  
open CursorFK
fetch next from CursorFK into  @ForeignKeyName, @ParentTableSchema, @ParentTableName
while (@@FETCH_STATUS=0)
begin
 set @TSQLDropFK ='ALTER TABLE '+quotename(@ParentTableSchema)+'.'+quotename(@ParentTableName)+' DROP CONSTRAINT '+quotename(@ForeignKeyName)
 
  if DATALENGTH (@TSQLDropFK) > 0
   insert into @Queries values(@TSQLDropFK)

fetch next from CursorFK into  @ForeignKeyName, @ParentTableSchema, @ParentTableName
end
close CursorFK
deallocate CursorFK

RETURN
END
GO


IF object_id('CreateForeignKeysQueries') IS NOT NULL DROP FUNCTION CreateForeignKeysQueries
 GO   

 /* SQL Server FUNCTION for upgrading from int to bigint
 create all ForeignKeys queries related to @TableName and the list of columns @Columns
- @TableName Table name
- @Columns columns to be migrated separated by cumma
*/ 
CREATE FUNCTION CreateForeignKeysQueries ()
RETURNS @Queries TABLE (query VARCHAR(MAX))
BEGIN

declare @ForeignKeyID int
declare @ForeignKeyName varchar(4000)
declare @ParentTableName varchar(4000)
declare @ParentColumn varchar(4000)
declare @ReferencedTable varchar(4000)
declare @ReferencedColumn varchar(4000)
declare @StrParentColumn varchar(max)
declare @StrReferencedColumn varchar(max)
declare @ParentTableSchema varchar(4000)
declare @ReferencedTableSchema varchar(4000)
declare @TSQLCreationFK varchar(max)

declare @schema varchar(max)

SET @schema = (select schema_name())

--Written by Percy Reyes www.percyreyes.com
declare CursorFK cursor for 
select distinct fk.object_id--, name, object_name( parent_object_id) 
from sys.foreign_keys fk
  inner join sys.foreign_key_columns fkc on fk.object_id=fkc.constraint_object_id
  inner join sys.columns c1 on c1.object_id=fkc.parent_object_id and c1.column_id=fkc.parent_column_id   
  inner join sys.tables t1 on t1.object_id=fkc.parent_object_id
  JOIN sys.types AS p ON c1.system_type_id = p.system_type_id
  where t1.type_desc = 'USER_TABLE' 
  and p.name = 'int' 
  and schema_name(t1.schema_id) = @schema  
  and (c1.name = 'crecorduid' or c1.name like '%fk' or c1.name in ('cforeignrecorduid','cobjectrecorduid','cobjectuid','coptionuid','crequestid','cworkrecuid'))

open CursorFK
fetch next from CursorFK into @ForeignKeyID
while (@@FETCH_STATUS=0)
begin
 set @StrParentColumn=''
 set @StrReferencedColumn=''
 declare CursorFKDetails cursor for
  select  fk.name ForeignKeyName, schema_name(t1.schema_id) ParentTableSchema,
  object_name(fkc.parent_object_id) ParentTable, c1.name ParentColumn,schema_name(t2.schema_id) ReferencedTableSchema,
   object_name(fkc.referenced_object_id) ReferencedTable,c2.name ReferencedColumn
  from --sys.tables t inner join 
  sys.foreign_keys fk 
  inner join sys.foreign_key_columns fkc on fk.object_id=fkc.constraint_object_id
  inner join sys.columns c1 on c1.object_id=fkc.parent_object_id and c1.column_id=fkc.parent_column_id 
  inner join sys.columns c2 on c2.object_id=fkc.referenced_object_id and c2.column_id=fkc.referenced_column_id 
  inner join sys.tables t1 on t1.object_id=fkc.parent_object_id 
  inner join sys.tables t2 on t2.object_id=fkc.referenced_object_id 
  where fk.object_id=@ForeignKeyID  
 open CursorFKDetails
 fetch next from CursorFKDetails into  @ForeignKeyName, @ParentTableSchema, @ParentTableName, @ParentColumn, @ReferencedTableSchema, @ReferencedTable, @ReferencedColumn
 while (@@FETCH_STATUS=0)
 begin    
  set @StrParentColumn=@StrParentColumn + ', ' + quotename(@ParentColumn)
  set @StrReferencedColumn=@StrReferencedColumn + ', ' + quotename(@ReferencedColumn)
  
     fetch next from CursorFKDetails into  @ForeignKeyName, @ParentTableSchema, @ParentTableName, @ParentColumn, @ReferencedTableSchema, @ReferencedTable, @ReferencedColumn
 end
 close CursorFKDetails
 deallocate CursorFKDetails

 set @StrParentColumn=substring(@StrParentColumn,2,len(@StrParentColumn)-1)
 set @StrReferencedColumn=substring(@StrReferencedColumn,2,len(@StrReferencedColumn)-1)
 set @TSQLCreationFK='ALTER TABLE '+quotename(@ParentTableSchema)+'.'+quotename(@ParentTableName)+' ADD CONSTRAINT '+quotename(@ForeignKeyName)
 + ' FOREIGN KEY('+ltrim(@StrParentColumn)+') REFERENCES '+quotename(@ReferencedTableSchema)+'.'+quotename(@ReferencedTable)+' ('+ltrim(@StrReferencedColumn)+') ' 
 
 if DATALENGTH (@TSQLCreationFK) > 0
  insert into @Queries values(@TSQLCreationFK)

fetch next from CursorFK into @ForeignKeyID 
end
close CursorFK
deallocate CursorFK

RETURN
END
GO

/* SQL Server Stored procedures for upgrading from int to bigint
 deletes all indexes and constraints related to @TableName and the list of columns @Columns
- @TableName Table name
- @Columns columns to be migrated separated by cumma
*/ 
IF object_id('DropIndexesAndConstraints') IS NOT NULL DROP FUNCTION DropIndexesAndConstraints
 GO   

CREATE FUNCTION DropIndexesAndConstraints ()
RETURNS @Queries TABLE (query VARCHAR(MAX))
BEGIN

DECLARE @TableName VARCHAR(256)
DECLARE @SchemaName VARCHAR(256)
DECLARE @IndexName VARCHAR(256)
DECLARE @TSQLDropIndex VARCHAR(MAX)
DECLARE @IsPrimaryKey int
DECLARE @IsUniqueConstraint int

declare @schema varchar(max)

SET @schema = (select schema_name())

DECLARE CursorIndexes CURSOR FOR
 SELECT distinct schema_name(t.schema_id), t.name,  i.name , i.is_primary_key, i.is_unique_constraint
 FROM sys.indexes i
 INNER JOIN sys.tables t ON t.object_id= i.object_id
 inner join sys.index_columns ixc on i.object_id=ixc.object_id and i.index_id= ixc.index_id
 inner join sys.columns col on ixc.object_id =col.object_id  and ixc.column_id=col.column_id
 JOIN sys.types AS p ON col.system_type_id = p.system_type_id
 WHERE i.type>0 and t.is_ms_shipped=0 and t.type_desc = 'USER_TABLE' 
  and p.name = 'int' 
  and schema_name(t.schema_id) = @schema
  and (col.name = 'crecorduid' or col.name like '%fk' or col.name in ('cforeignrecorduid','cobjectrecorduid','cobjectuid','coptionuid','crequestid','cworkrecuid'))


OPEN CursorIndexes
FETCH NEXT FROM CursorIndexes INTO @SchemaName,@TableName,@IndexName,@IsPrimaryKey,@IsUniqueConstraint

WHILE @@fetch_status = 0
BEGIN
 if (@IsPrimaryKey=0 and @IsUniqueConstraint=0)
	SET @TSQLDropIndex = 'DROP INDEX '+QUOTENAME(@SchemaName)+ '.' + QUOTENAME(@TableName) + '.' +QUOTENAME(@IndexName)
 else
	SET @TSQLDropIndex = 'ALTER TABLE '+QUOTENAME(@SchemaName)+ '.' + QUOTENAME(@TableName) + ' DROP CONSTRAINT ' +QUOTENAME(@IndexName)

 if DATALENGTH (@TSQLDropIndex) > 0
  insert into @Queries values(@TSQLDropIndex)
  

 FETCH NEXT FROM CursorIndexes INTO @SchemaName,@TableName,@IndexName,@IsPrimaryKey,@IsUniqueConstraint
END

CLOSE CursorIndexes
DEALLOCATE CursorIndexes 

RETURN 
END
GO

/* SQL Server Stored procedures for upgrading from int to bigint
 restore (create) all indexes and constraints related to @TableName and the list of columns @Columns
- @TableName Table name
- @Columns columns to be migrated separated by cumma
*/ 
IF object_id('CreateIndexesAndConstraints') IS NOT NULL DROP FUNCTION CreateIndexesAndConstraints
 GO   

CREATE FUNCTION CreateIndexesAndConstraints ()
RETURNS @Queries TABLE (query VARCHAR(MAX))
BEGIN

declare @TableName varchar(100)
declare @SchemaName varchar(100)
declare @IndexName varchar(256)
declare @ColumnName varchar(100)
declare @is_unique varchar(100)
declare @IndexTypeDesc varchar(100)
declare @FileGroupName varchar(100)
declare @is_disabled varchar(100)
declare @IndexOptions varchar(max)
declare @IndexColumnId int
declare @IsDescendingKey int 
declare @IsIncludedColumn int
declare @TSQLScripCreationIndex varchar(max)
declare @TSQLScripDisableIndex varchar(max)
DECLARE @IsPrimaryKey int
DECLARE @IsUniqueConstraint int
declare @is_unique_constraint varchar(100)
declare @is_primary_key varchar(100)

declare @schema varchar(max)

SET @schema = (select schema_name())

declare CursorIndex cursor for
 select distinct schema_name(t.schema_id) [schema_name], t.name, ix.name,
 case when ix.is_unique = 1 then 'UNIQUE ' else '' END 
 , ix.type_desc
 , ix.is_disabled 
 ,ix.is_primary_key,ix.is_unique_constraint
 from sys.tables t 
 inner join sys.indexes ix on t.object_id=ix.object_id
  inner join sys.index_columns ixc on ix.object_id=ixc.object_id and ix.index_id= ixc.index_id
  inner join sys.columns col on ixc.object_id =col.object_id  and ixc.column_id=col.column_id
  JOIN sys.types AS p ON col.system_type_id = p.system_type_id
 where ix.type>0 and t.type_desc = 'USER_TABLE' 
  and p.name = 'int' 
  and schema_name(t.schema_id) = @schema  
  and (col.name = 'crecorduid' or col.name like '%fk' or col.name in ('cforeignrecorduid','cobjectrecorduid','cobjectuid','coptionuid','crequestid','cworkrecuid'))
  and t.is_ms_shipped=0 and t.name<>'sysdiagrams'
order by schema_name(t.schema_id), t.name,ix.is_disabled, ix.is_unique_constraint

open CursorIndex
fetch next from CursorIndex into  @SchemaName, @TableName, @IndexName, @is_unique, @IndexTypeDesc, @is_disabled, @IsPrimaryKey, @IsUniqueConstraint

while (@@fetch_status=0)
begin
 declare @IndexColumns varchar(max)
 declare @IncludedColumns varchar(max)
 
 set @IndexColumns=''
 set @IncludedColumns=''
 
 declare CursorIndexColumn cursor for 
  select col.name, ixc.is_descending_key, ixc.is_included_column
  from sys.tables tb 
  inner join sys.indexes ix on tb.object_id=ix.object_id
  inner join sys.index_columns ixc on ix.object_id=ixc.object_id and ix.index_id= ixc.index_id
  inner join sys.columns col on ixc.object_id =col.object_id  and ixc.column_id=col.column_id
  where ix.type>0 --and (ix.is_primary_key=0 or ix.is_unique_constraint=0) 
  and schema_name(tb.schema_id)=@SchemaName and tb.name=@TableName and ix.name=@IndexName
  order by ixc.index_column_id
 
 open CursorIndexColumn 
 fetch next from CursorIndexColumn into  @ColumnName, @IsDescendingKey, @IsIncludedColumn
 
 while (@@fetch_status=0)
 begin
  if @IsIncludedColumn=0 
   set @IndexColumns=@IndexColumns + @ColumnName  + case when @IsDescendingKey=1  then ' DESC, ' else  ' ASC, ' end
  else 
   set @IncludedColumns=@IncludedColumns  + @ColumnName  +', ' 

  fetch next from CursorIndexColumn into @ColumnName, @IsDescendingKey, @IsIncludedColumn
 end

 close CursorIndexColumn
 deallocate CursorIndexColumn

 set @IndexColumns = substring(@IndexColumns, 1, len(@IndexColumns)-1)
 set @IncludedColumns = case when len(@IncludedColumns) >0 then substring(@IncludedColumns, 1, len(@IncludedColumns)-1) else '' end
 --  print @IndexColumns
 --  print @IncludedColumns

 set @TSQLScripCreationIndex =''
 set @TSQLScripDisableIndex =''
 
 set @is_unique_constraint = case when @IsUniqueConstraint = 1 then ' UNIQUE ' else '' END
 set @is_primary_key = case when @IsPrimaryKey = 1 then ' PRIMARY KEY ' else '' END

 if (@IsPrimaryKey=0 and @IsUniqueConstraint=0)
  set @TSQLScripCreationIndex='CREATE '+ @is_unique  +@IndexTypeDesc + ' INDEX ' +QUOTENAME(@IndexName)+' ON ' + QUOTENAME(@SchemaName) +'.'+ QUOTENAME(@TableName)+ '('+@IndexColumns+') '+ 
   case when len(@IncludedColumns)>0 then 'INCLUDE (' + @IncludedColumns+ ')' else '' end
 else
  set  @TSQLScripCreationIndex='ALTER TABLE '+  QUOTENAME(@SchemaName) +'.'+ QUOTENAME(@TableName)+ ' ADD CONSTRAINT ' +  QUOTENAME(@IndexName) + @is_unique_constraint + @is_primary_key + +@IndexTypeDesc +  '('+@IndexColumns+') '+ 
   case when len(@IncludedColumns)>0 then 'INCLUDE (' + @IncludedColumns+ ')' else '' end

 if @is_disabled=1 and @IsPrimaryKey=0 and @IsUniqueConstraint=0
  set  @TSQLScripDisableIndex=  'ALTER INDEX ' +QUOTENAME(@IndexName) + ' ON ' + QUOTENAME(@SchemaName) +'.'+ QUOTENAME(@TableName) + ' DISABLE'


 if DATALENGTH (@TSQLScripCreationIndex) > 0
  insert into @Queries values(@TSQLScripCreationIndex)  

 if DATALENGTH (@TSQLScripDisableIndex) > 0
  insert into @Queries values(@TSQLScripDisableIndex)  
   
 fetch next from CursorIndex into  @SchemaName, @TableName, @IndexName, @is_unique, @IndexTypeDesc, @is_disabled, @IsPrimaryKey, @IsUniqueConstraint

end
close CursorIndex
deallocate CursorIndex
 
 RETURN
END
GO


/* SQL Server Stored procedures for upgrading from int to bigint
 Main procedures to upgrade int recorduid columns to bigint 
*/ 
IF object_id('AlterIntColumns') IS NOT NULL DROP FUNCTION  AlterIntColumns
 GO   

CREATE FUNCTION  AlterIntColumns ()
RETURNS @AlterIntColumns TABLE (query VARCHAR(MAX))
AS
BEGIN

declare @TableName varchar(256)
DECLARE @SchemaName VARCHAR(256)
DECLARE @AlterQueries varchar(MAX)
 DECLARE @PrintQueries int  
 DECLARE @DropQueries varchar(MAX)
 DECLARE @CreateQueries varchar(MAX)
 declare @ColumnName varchar(256)
 declare @IsNullable int
 
 declare @schema varchar(max)

SET @schema = (select schema_name())
 
  -- list columns that should be migrated
 declare CursorColumnsToMigrate cursor for
 SELECT (T.name) AS Table_Name, schema_name(t.schema_id), C.name AS Column_Name, c.is_nullable
 FROM   sys.objects AS T 
       JOIN sys.columns AS C ON T.object_id = C.object_id
       JOIN sys.types AS P ON C.system_type_id = P.system_type_id
 WHERE  T.type_desc = 'USER_TABLE' and P.name = 'int' and schema_name(t.schema_id) = @schema and (C.name = 'crecorduid' or C.name like '%fk' or C.name in ('cforeignrecorduid','cobjectrecorduid','cobjectuid','coptionuid','crequestid','cworkrecuid'))
 open CursorColumnsToMigrate
 fetch next from CursorColumnsToMigrate into   @TableName, @SchemaName,@ColumnName, @IsNullable
 while (@@fetch_status=0) 
 begin    
  set @AlterQueries = 'ALTER TABLE ' +QUOTENAME(@SchemaName)+ '.' + QUOTENAME(@TableName) + ' ALTER COLUMN ' + QUOTENAME(@ColumnName) +' BIGINT ' + case when @IsNullable=0 then 'NOT NULL' else '' end
  insert into @AlterIntColumns values(@AlterQueries)
  set @AlterQueries = ''
  fetch next from CursorColumnsToMigrate into   @TableName, @SchemaName, @ColumnName, @IsNullable
 end 
 
 close CursorColumnsToMigrate
 deallocate CursorColumnsToMigrate 

 return
END
GO

IF object_id('UpgradeIntToBigInt') IS NOT NULL DROP PROCEDURE UpgradeIntToBigInt
 GO   

CREATE PROCEDURE UpgradeIntToBigInt 
AS
BEGIN
	declare @query varchar(max)
	DECLARE @PrintQueries int
	set @PrintQueries = 1 -- 1 to print queries without executing them. 0 Else
	
	declare @T_CreateForeignKeysQueries TABLE (query VARCHAR(MAX))
	insert into @T_CreateForeignKeysQueries select * from CreateForeignKeysQueries()

	declare @T_CreateIndexesAndConstraints TABLE (query VARCHAR(MAX))
	insert into @T_CreateIndexesAndConstraints select * from CreateIndexesAndConstraints()

	-- DropForeignKeysQueries
	if @PrintQueries = 1
	       print '-- DROP FOREIGNKEYS'
	declare tables_cursor cursor for
	   select query from  DropForeignKeysQueries()
	open tables_cursor
	fetch next from tables_cursor into @query
	while @@FETCH_STATUS = 0
	begin
	   if @PrintQueries = 1
	    print @query
	  else
	   execute(@query)
	   
	  fetch next from tables_cursor INTO @query
	end
	close tables_cursor
	deallocate tables_cursor
	
	 -- DropIndexesAndConstraints
	 	-- DropForeignKeysQueries
	if @PrintQueries = 1
	       print '-- DROP INDEX AND CONSTRAINTS'

	declare tables_cursor cursor for
	   select query from  DropIndexesAndConstraints()
	open tables_cursor
	fetch next from tables_cursor into @query
	while @@FETCH_STATUS = 0
	begin
	   if @PrintQueries = 1
	    print @query
	  else
	   execute(@query)

	   fetch next from tables_cursor INTO @query
	end
	close tables_cursor
	deallocate tables_cursor
	

	--AlterIntColumns
		if @PrintQueries = 1
	       print '-- ALTER TABLE ALTER COLUMN'

	declare tables_cursor cursor for
	   select query from  AlterIntColumns()
	open tables_cursor
	fetch next from tables_cursor into @query
	while @@FETCH_STATUS = 0
	begin
	   if @PrintQueries = 1
	    print @query
	  else
	   execute(@query)

	   fetch next from tables_cursor INTO @query
	end
	close tables_cursor
	deallocate tables_cursor
	

		--CreateIndexesAndConstraints

	if @PrintQueries = 1
	   print '-- CREATE INDEX AND CONSTRAINTS'

	declare tables_cursor cursor for
	   select query from  @T_CreateIndexesAndConstraints
	open tables_cursor
	fetch next from tables_cursor into @query
	while @@FETCH_STATUS = 0
	begin
	   if @PrintQueries = 1
	    print @query
	   else
	    execute(@query)

	   fetch next from tables_cursor INTO @query
	end
	close tables_cursor
	deallocate tables_cursor
	
		--CreateForeignKeysQueries

     if @PrintQueries = 1
	   print '-- CREATE FOREIGNKEYS'

	declare tables_cursor cursor for
	   select query from  @T_CreateForeignKeysQueries
	open tables_cursor
	fetch next from tables_cursor into @query
	while @@FETCH_STATUS = 0
	begin
	   if @PrintQueries = 1
	    print @query
	  else
	   execute(@query)

	   fetch next from tables_cursor INTO @query
	end
	close tables_cursor
	deallocate tables_cursor
	

END
  GO  

EXECUTE UpgradeIntToBigInt 


