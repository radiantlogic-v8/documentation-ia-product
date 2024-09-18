/* 
COPYRIGHT BRAINWAVE, all rights reserved.
This computer program is protected by copyright law and international treaties.
Unauthorized duplication or distribution of this program, or any portion of it, may result in severe civil or criminal penalties, and will be prosecuted to the maximum extent possible under the law.

Usage: Upgrades The database schema from version Ader R1 to Curie R1

(c) Brainwave 2021

1) Powershell

To execute the commande in powershell use the following command syntax:

Invoke-Sqlcmd -InputFile <String> -ServerInstance <String> -database <database> -Username <String> -Password <String>

This requires the "SqlServer" powershell module

2) SQL Server management

To excute in SQL Server management studio directly please uncomment the folling block and replace the parameters between "<>" accordingly.

*/
/* 
use "<DATABASE>" ;
execute as login='<USER>' ;
*/

-- Upgrade script to version 32
-- --------


GO
ALTER TABLE tmetadatavalue ADD cvalue3string         NVARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue4string         NVARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue5string         NVARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue6string         NVARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue7string         NVARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue8string         NVARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue9string         NVARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue10string        NVARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue11string        NVARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue12string        NVARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue13string        NVARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue14string        NVARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue15string        NVARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue16string        NVARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue17string        NVARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue18string        NVARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue19string        NVARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue20string        NVARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue3integer        INTEGER;
GO
ALTER TABLE tmetadatavalue ADD cvalue4integer        INTEGER;
GO
ALTER TABLE tmetadatavalue ADD cvalue5integer        INTEGER;
GO
ALTER TABLE tmetadatavalue ADD cvalue6integer        INTEGER;
GO
ALTER TABLE tmetadatavalue ADD cvalue7integer        INTEGER;
GO
ALTER TABLE tmetadatavalue ADD cvalue8integer        INTEGER;
GO
ALTER TABLE tmetadatavalue ADD cvalue9integer        INTEGER;
GO
ALTER TABLE tmetadatavalue ADD cvalue10integer       INTEGER;
GO
ALTER TABLE tmetadatavalue ADD cvalue11integer       INTEGER;
GO
ALTER TABLE tmetadatavalue ADD cvalue12integer       INTEGER;
GO
ALTER TABLE tmetadatavalue ADD cvalue13integer       INTEGER;
GO
ALTER TABLE tmetadatavalue ADD cvalue14integer       INTEGER;
GO
ALTER TABLE tmetadatavalue ADD cvalue15integer       INTEGER;
GO
ALTER TABLE tmetadatavalue ADD cvalue16integer       INTEGER;
GO
ALTER TABLE tmetadatavalue ADD cvalue17integer       INTEGER;
GO
ALTER TABLE tmetadatavalue ADD cvalue18integer       INTEGER;
GO
ALTER TABLE tmetadatavalue ADD cvalue19integer       INTEGER;
GO
ALTER TABLE tmetadatavalue ADD cvalue20integer       INTEGER;

GO
ALTER TABLE timportmetadatavalue ADD cvalue3string         NVARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue4string         NVARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue5string         NVARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue6string         NVARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue7string         NVARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue8string         NVARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue9string         NVARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue10string        NVARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue11string        NVARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue12string        NVARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue13string        NVARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue14string        NVARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue15string        NVARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue16string        NVARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue17string        NVARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue18string        NVARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue19string        NVARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue20string        NVARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue3integer        INTEGER;
GO
ALTER TABLE timportmetadatavalue ADD cvalue4integer        INTEGER;
GO
ALTER TABLE timportmetadatavalue ADD cvalue5integer        INTEGER;
GO
ALTER TABLE timportmetadatavalue ADD cvalue6integer        INTEGER;
GO
ALTER TABLE timportmetadatavalue ADD cvalue7integer        INTEGER;
GO
ALTER TABLE timportmetadatavalue ADD cvalue8integer        INTEGER;
GO
ALTER TABLE timportmetadatavalue ADD cvalue9integer        INTEGER;
GO
ALTER TABLE timportmetadatavalue ADD cvalue10integer       INTEGER;
GO
ALTER TABLE timportmetadatavalue ADD cvalue11integer       INTEGER;
GO
ALTER TABLE timportmetadatavalue ADD cvalue12integer       INTEGER;
GO
ALTER TABLE timportmetadatavalue ADD cvalue13integer       INTEGER;
GO
ALTER TABLE timportmetadatavalue ADD cvalue14integer       INTEGER;
GO
ALTER TABLE timportmetadatavalue ADD cvalue15integer       INTEGER;
GO
ALTER TABLE timportmetadatavalue ADD cvalue16integer       INTEGER;
GO
ALTER TABLE timportmetadatavalue ADD cvalue17integer       INTEGER;
GO
ALTER TABLE timportmetadatavalue ADD cvalue18integer       INTEGER;
GO
ALTER TABLE timportmetadatavalue ADD cvalue19integer       INTEGER;
GO
ALTER TABLE timportmetadatavalue ADD cvalue20integer       INTEGER;

GO
ALTER TABLE tportalmetadatavalue ADD cvalue3string         NVARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue4string         NVARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue5string         NVARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue6string         NVARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue7string         NVARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue8string         NVARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue9string         NVARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue10string        NVARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue11string        NVARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue12string        NVARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue13string        NVARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue14string        NVARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue15string        NVARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue16string        NVARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue17string        NVARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue18string        NVARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue19string        NVARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue20string        NVARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue3integer        INTEGER;
GO
ALTER TABLE tportalmetadatavalue ADD cvalue4integer        INTEGER;
GO
ALTER TABLE tportalmetadatavalue ADD cvalue5integer        INTEGER;
GO
ALTER TABLE tportalmetadatavalue ADD cvalue6integer        INTEGER;
GO
ALTER TABLE tportalmetadatavalue ADD cvalue7integer        INTEGER;
GO
ALTER TABLE tportalmetadatavalue ADD cvalue8integer        INTEGER;
GO
ALTER TABLE tportalmetadatavalue ADD cvalue9integer        INTEGER;
GO
ALTER TABLE tportalmetadatavalue ADD cvalue10integer       INTEGER;
GO
ALTER TABLE tportalmetadatavalue ADD cvalue11integer       INTEGER;
GO
ALTER TABLE tportalmetadatavalue ADD cvalue12integer       INTEGER;
GO
ALTER TABLE tportalmetadatavalue ADD cvalue13integer       INTEGER;
GO
ALTER TABLE tportalmetadatavalue ADD cvalue14integer       INTEGER;
GO
ALTER TABLE tportalmetadatavalue ADD cvalue15integer       INTEGER;
GO
ALTER TABLE tportalmetadatavalue ADD cvalue16integer       INTEGER;
GO
ALTER TABLE tportalmetadatavalue ADD cvalue17integer       INTEGER;
GO
ALTER TABLE tportalmetadatavalue ADD cvalue18integer       INTEGER;
GO
ALTER TABLE tportalmetadatavalue ADD cvalue19integer       INTEGER;
GO
ALTER TABLE tportalmetadatavalue ADD cvalue20integer       INTEGER;

GO
CREATE INDEX idx_metadata_key ON tmetadata(ckey);
GO
CREATE INDEX idx_metadata_subkey ON tmetadata(csubkey);
GO
CREATE INDEX idx_pmetadata_key ON tportalmetadata(ckey);
GO
CREATE INDEX idx_pmetadata_subkey ON tportalmetadata(csubkey);

GO
ALTER TABLE tactivitypair ALTER COLUMN coperator NVARCHAR(16);



GO
ALTER TABLE timportactivitypair ALTER COLUMN coperator NVARCHAR(16);



GO
ALTER TABLE tportalactivitypair ALTER COLUMN coperator NVARCHAR(16);




GO
CREATE TABLE tuservariable (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  IDENTITY (1, 1)  ,
  cowneruid             NVARCHAR(250)  NOT NULL,
  cname                 NVARCHAR(250)  NOT NULL,
  ccontent              NVARCHAR(MAX),
  CONSTRAINT uservariable_uid_pk PRIMARY KEY (crecorduid)
);


GO
CREATE INDEX idx_uservariable_key ON tuservariable(cowneruid, cname);

GO
ALTER TABLE timportmanagerrule DROP CONSTRAINT importmanagerrule_target_ck;
GO
ALTER TABLE tmanagerrule DROP CONSTRAINT managerrule_target_ck;
GO
ALTER TABLE tportalmanagerrule DROP CONSTRAINT pmanagerrule_target_ck;

GO
ALTER TABLE tmanager ADD cmanagedidentityfk              INTEGER;
GO
ALTER TABLE tmanager ADD cindirect                       NVARCHAR(1);

GO
ALTER TABLE tmanagerrule ADD cmanagedidentityfk          INTEGER;

GO
ALTER TABLE timportmanagerrule ADD cmanagedidentityfk    NVARCHAR(64);


GO
ALTER TABLE timportmanager ADD cmanagedidentityfk        NVARCHAR(64);
GO
ALTER TABLE timportmanager ADD cindirect                 NVARCHAR(1);

GO
ALTER TABLE tportalmanager ADD cmanagedidentityfk        INTEGER;
GO
ALTER TABLE tportalmanager ADD cindirect                 NVARCHAR(1);

GO
ALTER TABLE tportalmanagerrule ADD cmanagedidentityfk    INTEGER;

GO
CREATE INDEX idx_managerrule_mngdidnt ON tmanagerrule(cmanagedidentityfk);

-- IDNTMANAGERREVIEW table
GO
CREATE TABLE tidntmanagerreview (
  -- Archive information
  ctimeslotfk           NVARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  cmanagerfk            INTEGER       NOT NULL,
  CONSTRAINT idntmanagerreview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

GO
CREATE INDEX idx_manager_mngdident ON tmanager(cmanagedidentityfk);

GO
CREATE INDEX idx_pmanagerrule_mngdidnt ON tportalmanagerrule(cmanagedidentityfk);

-- IDNTMANAGERREVIEW table
GO
CREATE TABLE tportaltidntmanagerreview (
  -- Archive information
  ctimeslotfk           NVARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  cmanagerfk            INTEGER       NOT NULL,
  CONSTRAINT pidntmanagerrev_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

GO
CREATE INDEX idx_pmanager_mngdident ON tportalmanager(cmanagedidentityfk);

GO
CREATE INDEX idx_identmanagerrev_timeslot ON tidntmanagerreview(ctimeslotfk);
GO
CREATE INDEX idx_identmanagerrev_ticket ON tidntmanagerreview(cticketreviewfk);
GO
CREATE INDEX idx_identmanagerrev_manager ON tidntmanagerreview(cmanagerfk);

GO
CREATE INDEX idx_pidentmanagerrev_timeslot ON tportaltidntmanagerreview(ctimeslotfk);
GO
CREATE INDEX idx_pidentmanagerrev_ticket ON tportaltidntmanagerreview(cticketreviewfk);
GO
CREATE INDEX idx_pidentmanagerrev_manager ON tportaltidntmanagerreview(cmanagerfk);

-- DIRECT identity manager view
GO
CREATE VIEW vdirectidentitymanagers AS
  SELECT m.crecorduid,m.ctimeslotfk,m.corganisationfk,m.crepositoryfk,m.caccountfk,m.cgroupfk,m.cpermissionfk,m.capplicationfk,m.cassetfk,m.ccampaignfk,m.cmanagedidentityfk,m.cindirect,
  		 m.cexpertisedomainfk,m.cidentityfk,m.ccollected,m.cdelegation,m.cpriority,m.cstartdate,m.cstartday,m.cenddate,m.cendday,m.ccomment,m.cdelegationreason
  FROM tmanager m
  INNER JOIN tidentity i ON i.crecorduid = m.cmanagedidentityfk
  WHERE m.cindirect='0' OR m.cindirect IS NULL;

  -- DIRECT identity manager view
GO
CREATE VIEW vpdirectidentitymanagers AS
  SELECT m.crecorduid,m.ctimeslotfk,m.corganisationfk,m.crepositoryfk,m.caccountfk,m.cgroupfk,m.cpermissionfk,m.capplicationfk,m.cassetfk,m.ccampaignfk,m.cmanagedidentityfk,m.cindirect,
  		 m.cexpertisedomainfk,m.cidentityfk,m.ccollected,m.cdelegation,m.cpriority,m.cstartdate,m.cstartday,m.cenddate,m.cendday,m.ccomment,m.cdelegationreason
  FROM tportalmanager m
  INNER JOIN tportalidentity i ON i.crecorduid = m.cmanagedidentityfk
  WHERE m.cindirect='0' OR m.cindirect IS NULL;
  
  -- change exiting column type from varchar(max) to nvarchar(max)
  
  GO
ALTER TABLE tuserdata ALTER COLUMN cbody NVARCHAR(MAX);
  GO
ALTER TABLE tcampaignvariables ALTER COLUMN cvariables NVARCHAR(MAX);
  
  
GO
CREATE INDEX idx_user_data_uid ON tuserdata(cuuid);  

GO
CREATE INDEX idx_account_ident_ts ON taccount(cidentifier, ctimeslotfk);
GO
CREATE INDEX idx_paccount_ident_ts ON tportalaccount(cidentifier, ctimeslotfk);


GO

UPDATE tproperties SET cvalue='32' WHERE cpropertiesuid='VERSION';
-- Upgrade script to version 33
-- --------


-- MISSION table

GO
CREATE TABLE tmission (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL IDENTITY (1, 1),
  -- Object information
  cname                 NVARCHAR(250),
  cbusinessdomain       NVARCHAR(250),
  cdescription          NVARCHAR(4000),
  cduedate              NVARCHAR(15),
  CONSTRAINT mission_uid_pk PRIMARY KEY (crecorduid)
);


-- ENDPOINT table

GO
CREATE TABLE tendpoint (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL IDENTITY (1, 1) ,
  -- Object information
  cname                 NVARCHAR(250)  NOT NULL,
  cdescription          NVARCHAR(4000),
  cprovider             NVARCHAR(100)  NOT NULL,
  cdefinition           NVARCHAR(4000),
  CONSTRAINT endpoint_uid_pk PRIMARY KEY (crecorduid)
);


-- MISSIONWAVE table

GO
CREATE TABLE tmissionwave (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL IDENTITY (1, 1) ,
  -- Object information
  cname                 NVARCHAR(250)  NOT NULL,
  cdescription          NVARCHAR(4000),
  cendpointfk           INTEGER,
  ctimeslotfk           NVARCHAR(64),
  ccreationdate         NVARCHAR(15),
  chidden               NVARCHAR(1)       NOT NULL,
  CONSTRAINT missionwave_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT missionwave_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT missionwave_endpoint_fk FOREIGN KEY (cendpointfk) REFERENCES tendpoint(crecorduid) ON DELETE SET NULL ON UPDATE NO ACTION
);


-- MISSIONWAVESTAGE table

GO
CREATE TABLE tmissionwavestage (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL IDENTITY (1, 1) ,
  -- Object information
  corder                INTEGER       NOT NULL,
  ctype                 NVARCHAR(32)   NOT NULL,
  ckey                  NVARCHAR(100)  NOT NULL,
  cvalue                NVARCHAR(100),
  clabels               NVARCHAR(4000),
  cmissionwavefk        INTEGER       NOT NULL,
  cavailable            NVARCHAR(1)       NOT NULL,
  ccompleted            NVARCHAR(1)       NOT NULL,
  CONSTRAINT missionwavestage_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT stage_wave_fk FOREIGN KEY (cmissionwavefk) REFERENCES tmissionwave(crecorduid) ON DELETE CASCADE ON UPDATE NO ACTION
);


-- SOFTWARE table

GO
CREATE TABLE tsoftware (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL IDENTITY (1, 1) ,
  -- Object information
  cname                 NVARCHAR(250)  NOT NULL,
  cdescription          NVARCHAR(4000),
  ccriticity            INTEGER,
  cfamily               NVARCHAR(100),
  cmissionwavefk        INTEGER       NOT NULL,
  ctype                 NVARCHAR(1)       NOT NULL,
  caddonname            NVARCHAR(100),
  caddondisplayname     NVARCHAR(250),
  CONSTRAINT software_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT software_wave_fk FOREIGN KEY (cmissionwavefk) REFERENCES tmissionwave(crecorduid) ON DELETE CASCADE ON UPDATE NO ACTION
);


-- SOFTWAREVARIABLE table

GO
CREATE TABLE tsoftwarevariable (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL IDENTITY (1, 1) ,
  -- Object information
  csoftwarefk           INTEGER       NOT NULL,
  ckey                  NVARCHAR(250)  NOT NULL,
  cvalue                NVARCHAR(1000),
  CONSTRAINT softwarevar_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT softwarevar_software_fk FOREIGN KEY (csoftwarefk) REFERENCES tsoftware(crecorduid) ON DELETE CASCADE ON UPDATE NO ACTION
);


-- UPLOADFILE table

GO
CREATE TABLE tuploadfile (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL IDENTITY (1, 1) ,
  -- Object information
  cinternalfilename     NVARCHAR(1000) NOT NULL,
  cexternalfilename     NVARCHAR(1000) NOT NULL,
  cdisplayname          NVARCHAR(1000) NOT NULL,
  ctemporarypath        NVARCHAR(1000) NOT NULL,
  cstatus               NVARCHAR(1)       NOT NULL,
  csize                 INTEGER,
  clastmodified         NVARCHAR(15),
  chashcode             NVARCHAR(64),
  cissueddate           NVARCHAR(15),
  cupdateddate          NVARCHAR(15),
  cnode                 NVARCHAR(250),
  cerrormessage         NVARCHAR(1000),
  CONSTRAINT uploadfile_uid_pk PRIMARY KEY (crecorduid)
);


-- DATASOURCE table

GO
CREATE TABLE tdatasource (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL IDENTITY (1, 1) ,
  -- Object information
  cname                 NVARCHAR(250)  NOT NULL,
  cdescription          NVARCHAR(4000),
  csoftwarefk           INTEGER       NOT NULL,
  cendpointfk           INTEGER,
  ctype                 NVARCHAR(15),
  cparsingoptions       NVARCHAR(4000),
  CONSTRAINT datasource_uid_pk PRIMARY KEY (crecorduid)
  
  
);


-- DATASOURCEFILE table

GO
CREATE TABLE tdatasourcefile (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL IDENTITY (1, 1) ,
  -- Object information
  cdatasourcefk         INTEGER       NOT NULL,
  cuploadfilefk         INTEGER       NOT NULL,
  cvalidationstatus     NVARCHAR(25),
  cmessages             NVARCHAR(MAX),
  CONSTRAINT datasourcefile_uid_pk PRIMARY KEY (crecorduid)
  
  
);


-- MAPPING table

GO
CREATE TABLE tmapping (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL IDENTITY (1, 1) ,
  -- Object information
  cname                 NVARCHAR(250)  NOT NULL,
  cdatasourcefk         INTEGER       NOT NULL,
  centity               NVARCHAR(1)       NOT NULL,
  CONSTRAINT mapping_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT mapping_datasource_fk FOREIGN KEY (cdatasourcefk) REFERENCES tdatasource(crecorduid) ON DELETE CASCADE ON UPDATE NO ACTION
);


-- MAPPINGCOMPUTED table

GO
CREATE TABLE tmappingcomputed (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL IDENTITY (1, 1) ,
  -- Object information
  cname                 NVARCHAR(100)  NOT NULL,
  cmappingfk            INTEGER       NOT NULL,
  ctype                 NVARCHAR(1)       NOT NULL,
  cmode                 NVARCHAR(1)       NOT NULL,
  cexpression           NVARCHAR(2000),
  CONSTRAINT mappingcomputed_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT mappingcomp_mapping_fk FOREIGN KEY (cmappingfk) REFERENCES tmapping(crecorduid) ON DELETE CASCADE ON UPDATE NO ACTION
);


-- MAPPINGATTR table

GO
CREATE TABLE tmappingattr (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL IDENTITY (1, 1) ,
  -- Object information
  cmappingfk            INTEGER       NOT NULL,
  centityattribute      NVARCHAR(100)  NOT NULL,
  ctype                 NVARCHAR(1)       NOT NULL,
  cmode                 NVARCHAR(1)       NOT NULL,
  cdatasourceattribute  NVARCHAR(100),
  ccomputedattributefk  INTEGER,
  CONSTRAINT mappingattr_uid_pk PRIMARY KEY (crecorduid)
  
  
);


-- MAPPINGFILTER table

GO
CREATE TABLE tmappingfilter (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL IDENTITY (1, 1) ,
  -- Object information
  cmappingfk            INTEGER       NOT NULL,
  cname                 NVARCHAR(250)  NOT NULL,
  cexpression           NVARCHAR(2000),
  CONSTRAINT mappingfilter_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT mappingfilter_mapping_fk FOREIGN KEY (cmappingfk) REFERENCES tmapping(crecorduid) ON DELETE CASCADE ON UPDATE NO ACTION
);


-- EXECPLANMONITOR table

GO
CREATE TABLE texecplanmonitor (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL IDENTITY (1, 1) ,
  -- Object information
  cstatus               NVARCHAR(1)       NOT NULL,
  cprincipalname        NVARCHAR(200)  NOT NULL,
  cmissionwavefk        INTEGER,
  csubmitdate           NVARCHAR(15)   NOT NULL,
  ctimeslotfk           NVARCHAR(64),
  ctaskid               NVARCHAR(200),
  cstartdate            NVARCHAR(15),
  cheartbeat            NVARCHAR(15),
  ccompleteddate         NVARCHAR(15),
  cphase                NVARCHAR(1),
  cerrormessage         NVARCHAR(2000),
  ccurrentfile          NVARCHAR(2000),
  ccurrentsilo          NVARCHAR(250),
  CONSTRAINT execplanmonitor_uid_pk PRIMARY KEY (crecorduid)
);



GO

UPDATE tproperties SET cvalue='33' WHERE cpropertiesuid='VERSION';
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

declare CursorFK cursor for 
select distinct fk.name ForeignKeyName, schema_name(t.schema_id) ParentTableSchema, t.name ParentTableName
from sys.foreign_keys fk  
 inner join sys.tables t on fk.parent_object_id=t.object_id
  inner join sys.foreign_key_columns fkc on fk.object_id=fkc.constraint_object_id
  inner join sys.columns c1 on c1.object_id=fkc.parent_object_id and c1.column_id=fkc.parent_column_id
  JOIN sys.types AS p ON c1.system_type_id = p.system_type_id
  where t.type_desc = 'USER_TABLE' 
  and p.name = 'int' 
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

DECLARE CursorIndexes CURSOR FOR
 SELECT distinct schema_name(t.schema_id), t.name,  i.name , i.is_primary_key, i.is_unique_constraint
 FROM sys.indexes i
 INNER JOIN sys.tables t ON t.object_id= i.object_id
 inner join sys.index_columns ixc on i.object_id=ixc.object_id and i.index_id= ixc.index_id
 inner join sys.columns col on ixc.object_id =col.object_id  and ixc.column_id=col.column_id
 JOIN sys.types AS p ON col.system_type_id = p.system_type_id
 WHERE i.type>0 and t.is_ms_shipped=0 and t.type_desc = 'USER_TABLE' 
  and p.name = 'int' 
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
 
  -- list columns that should be migrated
 declare CursorColumnsToMigrate cursor for
 SELECT (T.name) AS Table_Name, schema_name(t.schema_id), C.name AS Column_Name, c.is_nullable
 FROM   sys.objects AS T 
       JOIN sys.columns AS C ON T.object_id = C.object_id
       JOIN sys.types AS P ON C.system_type_id = P.system_type_id
 WHERE  T.type_desc = 'USER_TABLE' and P.name = 'int' and (C.name = 'crecorduid' or C.name like '%fk' or C.name in ('cforeignrecorduid','cobjectrecorduid','cobjectuid','coptionuid','crequestid','cworkrecuid'))
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
	set @PrintQueries = 0 -- 1 to print queries without executing them. 0 Else
	
	declare @T_CreateForeignKeysQueries TABLE (query VARCHAR(MAX))
	insert into @T_CreateForeignKeysQueries select * from CreateForeignKeysQueries()

	declare @T_CreateIndexesAndConstraints TABLE (query VARCHAR(MAX))
	insert into @T_CreateIndexesAndConstraints select * from CreateIndexesAndConstraints()

	-- DropForeignKeysQueries
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
 -- Upgrade script to version 35
-- --------



GO
CREATE TABLE tconfitem (
  -- Database primary key
  crecorduid            BIGINT NOT NULL IDENTITY (1, 1),
  -- Archive information
  ctimeslotfk           NVARCHAR(64)   NOT NULL,
  -- Object information
  cconfitemuid          NVARCHAR(64)   NOT NULL,
  cfamily               NVARCHAR(100)  NOT NULL,
  ctype                 NVARCHAR(100)  NOT NULL,
  cenvironment          NVARCHAR(100),
  ccode                 NVARCHAR(1000) NOT NULL,
  cdisplayname          NVARCHAR(1000),
  cdescription          NVARCHAR(4000),
  cdn                   NVARCHAR(500),
  ccanonicalname        NVARCHAR(500),
  ccountrycode          NVARCHAR(20),
  cruntimename          NVARCHAR(100),
  cruntimeversion       NVARCHAR(100),
  cdnsname              NVARCHAR(150),
  cipv4address          NVARCHAR(15),
  cipv6address          NVARCHAR(50),
  cenabled              NVARCHAR(1),
  cstate                NVARCHAR(50),
  carch                 NVARCHAR(50),
  cnbcputhreads         INTEGER,
  cmemorysize           INTEGER,
  callocatedstorage     INTEGER,
  cstorageencrypted     NVARCHAR(1),
  curn                  NVARCHAR(200),
  ccriticalobject        NVARCHAR(1),
  ccreationdate         NVARCHAR(15),
  ccreationday          INTEGER,
  cmodifydate           NVARCHAR(15),
  cmodifyday            INTEGER,
  cpasswordnotrequired  NVARCHAR(1),
  cpasswordneverexpires NVARCHAR(1),
  cpasswordexpired      NVARCHAR(1),
  clogoncount           INTEGER,
  clastlogondate        NVARCHAR(15),
  clastlogonday         INTEGER,
  cbadlogoncount        INTEGER,
  clastbadpassworddate  NVARCHAR(15),
  clastbadpasswordday   INTEGER,
  cpasswordlastsetdate  NVARCHAR(15),
  cpasswordlastsetday   INTEGER,
  cdetails              NVARCHAR(MAX),
  caddress              NVARCHAR(1000),
  clocationfk           BIGINT,
  cimportaction         NVARCHAR(1)       NOT NULL,
  cdeletedaction        NVARCHAR(1),
  CONSTRAINT confitem_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT confitem_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT confitem_uid_uk UNIQUE (ctimeslotfk, cconfitemuid)
);



GO
CREATE TABLE tconfitemlink (
  -- Database primary key
  crecorduid            BIGINT NOT NULL IDENTITY (1, 1),
  -- Archive information
  ctimeslotfk           NVARCHAR(64)   NOT NULL,
  -- Object information
  cconfitemlinkuid      NVARCHAR(64)   NOT NULL,
  corigin               NVARCHAR(1)       NOT NULL,
  cjointypes            NVARCHAR(32)   NOT NULL,
  csemantic             NVARCHAR(1000),
  cdescription          NVARCHAR(4000),
  cindirect             NVARCHAR(1)       NOT NULL,
  csourceconfitemfk     BIGINT,
  csourcerepofk         BIGINT,
  csourceapplifk        BIGINT,
  csourceaccountfk      BIGINT,
  csourceidentityfk     BIGINT,
  csourceorgfk          BIGINT,
  ctargetconfitemfk     BIGINT,
  ctargetrepofk         BIGINT,
  ctargetapplifk        BIGINT,
  ctargetaccountfk      BIGINT,
  ctargetidentityfk     BIGINT,
  ctargetorgfk          BIGINT,
  CONSTRAINT confitemlink_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT confitemlink_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT confitemlink_uid_uk UNIQUE (ctimeslotfk, cconfitemlinkuid)
);


GO
CREATE TABLE timportconfitem (
  cimportlogfk          NVARCHAR(64)   NOT NULL,
  -- Object information
  cconfitemuid          NVARCHAR(64)   NOT NULL,
  csilofk               NVARCHAR(64),
  cfamily               NVARCHAR(100)  NOT NULL,
  ctype                 NVARCHAR(100)  NOT NULL,
  cenvironment          NVARCHAR(100),
  ccode                 NVARCHAR(1000) NOT NULL,
  cdisplayname          NVARCHAR(1000),
  cdescription          NVARCHAR(4000),
  cdn                   NVARCHAR(500),
  ccanonicalname        NVARCHAR(500),
  ccountrycode          NVARCHAR(20),
  cruntimename          NVARCHAR(100),
  cruntimeversion       NVARCHAR(100),
  cdnsname              NVARCHAR(150),
  cipv4address          NVARCHAR(15),
  cipv6address          NVARCHAR(50),
  cenabled              NVARCHAR(1),
  cstate                NVARCHAR(50),
  carch                 NVARCHAR(50),
  cnbcputhreads         INTEGER,
  cmemorysize           INTEGER,
  callocatedstorage     INTEGER,
  cstorageencrypted     NVARCHAR(1),
  curn                  NVARCHAR(200),
  ccriticalobject        NVARCHAR(1),
  ccreationdate         NVARCHAR(15),
  ccreationday          INTEGER,
  cmodifydate           NVARCHAR(15),
  cmodifyday            INTEGER,
  cpasswordnotrequired  NVARCHAR(1),
  cpasswordneverexpires NVARCHAR(1),
  cpasswordexpired      NVARCHAR(1),
  clogoncount           INTEGER,
  clastlogondate        NVARCHAR(15),
  clastlogonday         INTEGER,
  cbadlogoncount        INTEGER,
  clastbadpassworddate  NVARCHAR(15),
  clastbadpasswordday   INTEGER,
  cpasswordlastsetdate  NVARCHAR(15),
  cpasswordlastsetday   INTEGER,
  cdetails              NVARCHAR(MAX),
  caddress              NVARCHAR(1000),
  clocationuid          NVARCHAR(64),
  cimportaction         NVARCHAR(1)       NOT NULL,
  CONSTRAINT importconfitem_uid_pk PRIMARY KEY (cconfitemuid, cimportlogfk),
  CONSTRAINT importconfitem_timeslot_fk FOREIGN KEY (cimportlogfk) REFERENCES timportlog(cimportloguid)
);

GO
CREATE TABLE timportconfitemlink (
  cimportlogfk           NVARCHAR(64)   NOT NULL,
  -- Object information
  cconfitemlinkuid      NVARCHAR(64)   NOT NULL,
  csilofk               NVARCHAR(64),
  corigin               NVARCHAR(1)       NOT NULL,
  cjointypes            NVARCHAR(32)   NOT NULL,
  csemantic             NVARCHAR(1000),
  cdescription          NVARCHAR(4000),
  csourceconfitemfk     NVARCHAR(64),
  csourcerepofk         NVARCHAR(64),
  csourceapplifk        NVARCHAR(64),
  csourceaccountfk      NVARCHAR(64),
  csourceidentityfk     NVARCHAR(64),
  csourceorgfk          NVARCHAR(64),
  ctargetconfitemfk     NVARCHAR(64),
  ctargetrepofk         NVARCHAR(64),
  ctargetapplifk        NVARCHAR(64),
  ctargetaccountfk      NVARCHAR(64),
  ctargetidentityfk     NVARCHAR(64),
  ctargetorgfk          NVARCHAR(64),
  CONSTRAINT importconfitemlink_uid_pk PRIMARY KEY (cconfitemlinkuid, cimportlogfk),
  CONSTRAINT importconfitemlink_timeslot_fk FOREIGN KEY (cimportlogfk) REFERENCES timportlog(cimportloguid)
);

GO
CREATE TABLE tportalconfitem (
  -- Database primary key
  crecorduid            BIGINT NOT NULL,
  -- Archive information
  ctimeslotfk           NVARCHAR(64)   NOT NULL,
  -- Object information
  cconfitemuid          NVARCHAR(64)   NOT NULL,
  cfamily               NVARCHAR(100)  NOT NULL,
  ctype                 NVARCHAR(100)  NOT NULL,
  cenvironment          NVARCHAR(100),
  ccode                 NVARCHAR(1000) NOT NULL,
  cdisplayname          NVARCHAR(1000),
  cdescription          NVARCHAR(4000),
  cdn                   NVARCHAR(500),
  ccanonicalname        NVARCHAR(500),
  ccountrycode          NVARCHAR(20),
  cruntimename          NVARCHAR(100),
  cruntimeversion       NVARCHAR(100),
  cdnsname              NVARCHAR(150),
  cipv4address          NVARCHAR(15),
  cipv6address          NVARCHAR(50),
  cenabled              NVARCHAR(1),
  cstate                NVARCHAR(50),
  carch                 NVARCHAR(50),
  cnbcputhreads         INTEGER,
  cmemorysize           INTEGER,
  callocatedstorage     INTEGER,
  cstorageencrypted     NVARCHAR(1),
  curn                  NVARCHAR(200),
  ccriticalobject        NVARCHAR(1),
  ccreationdate         NVARCHAR(15),
  ccreationday          INTEGER,
  cmodifydate           NVARCHAR(15),
  cmodifyday            INTEGER,
  cpasswordnotrequired  NVARCHAR(1),
  cpasswordneverexpires NVARCHAR(1),
  cpasswordexpired      NVARCHAR(1),
  clogoncount           INTEGER,
  clastlogondate        NVARCHAR(15),
  clastlogonday         INTEGER,
  cbadlogoncount        INTEGER,
  clastbadpassworddate  NVARCHAR(15),
  clastbadpasswordday   INTEGER,
  cpasswordlastsetdate  NVARCHAR(15),
  cpasswordlastsetday   INTEGER,
  cdetails              NVARCHAR(MAX),
  caddress              NVARCHAR(1000),
  clocationfk           BIGINT,
  cimportaction         NVARCHAR(1)       NOT NULL,
  cdeletedaction        NVARCHAR(1),
  CONSTRAINT pconfitem_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT pconfitem_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT pconfitem_uid_uk UNIQUE (ctimeslotfk, cconfitemuid)
);

GO
CREATE TABLE tportalconfitemlink (
  -- Database primary key
  crecorduid            BIGINT NOT NULL,
  -- Archive information
  ctimeslotfk           NVARCHAR(64)   NOT NULL,
  -- Object information
  cconfitemlinkuid      NVARCHAR(64)   NOT NULL,
  corigin               NVARCHAR(1)       NOT NULL,
  cjointypes            NVARCHAR(32)   NOT NULL,
  csemantic             NVARCHAR(1000),
  cdescription          NVARCHAR(4000),
  cindirect             NVARCHAR(1)       NOT NULL,
  csourceconfitemfk     BIGINT,
  csourcerepofk         BIGINT,
  csourceapplifk        BIGINT,
  csourceaccountfk      BIGINT,
  csourceidentityfk     BIGINT,
  csourceorgfk          BIGINT,
  ctargetconfitemfk     BIGINT,
  ctargetrepofk         BIGINT,
  ctargetapplifk        BIGINT,
  ctargetaccountfk      BIGINT,
  ctargetidentityfk     BIGINT,
  ctargetorgfk          BIGINT,
  CONSTRAINT pconfitemlink_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT pconfitemlink_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT pconfitemlink_uid_uk UNIQUE (ctimeslotfk, cconfitemlinkuid)
);

GO
ALTER TABLE tmetadata ADD cconfitemfk BIGINT;
GO
ALTER TABLE tmetadatavalue ADD cvalueconfitemuid NVARCHAR(64);
GO
ALTER TABLE tmetadatavalue ADD cvalueconfitemfk BIGINT;

GO
ALTER TABLE tmetadata ADD csearchlogfk BIGINT;
GO
ALTER TABLE tmetadata ADD csearchloguid NVARCHAR(250);
GO
ALTER TABLE tmetadatavalue ADD cvaluesearchlogfk BIGINT;
GO
ALTER TABLE tmetadatavalue ADD cvaluesearchloguid NVARCHAR(250);

GO
CREATE INDEX idx_metadata_confitem ON tmetadata(cconfitemfk);
GO
CREATE INDEX idx_metadatav_confitem ON tmetadatavalue(cmetadatafk,cvalueconfitemfk);

GO
CREATE INDEX idx_metadata_searchlog ON tmetadata(csearchlogfk);
GO
CREATE INDEX idx_metadatav_searchlog ON tmetadatavalue(cmetadatafk,cvaluesearchlogfk);

GO
ALTER TABLE timportmetadata ADD cconfitemfk NVARCHAR(64);
GO
ALTER TABLE timportmetadatavalue ADD cvalueconfitemfk NVARCHAR(64);

GO
ALTER TABLE tportalmetadata ADD cconfitemfk BIGINT;
GO
ALTER TABLE tportalmetadatavalue ADD cvalueconfitemuid NVARCHAR(64);
GO
ALTER TABLE tportalmetadatavalue ADD cvalueconfitemfk BIGINT;

GO
ALTER TABLE tportalmetadata ADD csearchlogfk BIGINT;
GO
ALTER TABLE tportalmetadata ADD csearchloguid NVARCHAR(250);
GO
ALTER TABLE tportalmetadatavalue ADD cvaluesearchlogfk BIGINT;
GO
ALTER TABLE tportalmetadatavalue ADD cvaluesearchloguid NVARCHAR(250);

GO
CREATE INDEX idx_pmetadata_confitem ON tportalmetadata(cconfitemfk);
GO
CREATE INDEX idx_pmetadatav_confitem ON tportalmetadatavalue(cmetadatafk,cvalueconfitemfk);

GO
CREATE INDEX idx_pmetadata_searchlog ON tportalmetadata(csearchlogfk);
GO
CREATE INDEX idx_pmetadatav_searchlog ON tportalmetadatavalue(cmetadatafk,cvaluesearchlogfk);


GO
CREATE TABLE tpamprogram (
  -- Database primary key
  crecorduid            BIGINT NOT NULL IDENTITY (1, 1),
  -- Object information
  cname                 NVARCHAR(250) NOT NULL,
  cdescription          NVARCHAR(4000),
  cdeadline             NVARCHAR(15),
  CONSTRAINT pamprogram_uid_pk PRIMARY KEY (crecorduid)
);



GO
CREATE TABLE tpamscope (
  -- Database primary key
  crecorduid            BIGINT NOT NULL IDENTITY (1, 1),
  -- Object information
  cprogramfk            BIGINT NOT NULL,
  cname                 NVARCHAR(250) NOT NULL,
  cdescription          NVARCHAR(4000),
  cstartdate            NVARCHAR(15),
  cdeadline             NVARCHAR(15),
  cstatus               NVARCHAR(100),
  ctimeslotuid          NVARCHAR(64),
  cimportance           INTEGER,
  crequestoruid         NVARCHAR(64),
  crequestorfullname    NVARCHAR(250),
  CONSTRAINT pamscope_uid_pk PRIMARY KEY (crecorduid)
);



GO
CREATE TABLE tpamscopeincl (
  -- Database primary key
  crecorduid            BIGINT NOT NULL IDENTITY (1, 1),
  -- Object information
  cscopefk              BIGINT NOT NULL,
  ctype                 NVARCHAR(1)       NOT NULL,
  ctitle                NVARCHAR(1000) NOT NULL,
  cruleid               NVARCHAR(250),
  capplications         NVARCHAR(MAX),
  cconfitems            NVARCHAR(MAX),
  crepositories         NVARCHAR(MAX),
  CONSTRAINT pamscopeincl_uid_pk PRIMARY KEY (crecorduid)
);



GO
CREATE TABLE tpammilestone (
  -- Database primary key
  crecorduid            BIGINT NOT NULL IDENTITY (1, 1),
  -- Object information
  cprogramfk            BIGINT,
  cscopefk              BIGINT,
  cname                 NVARCHAR(250),
  cdeadline             NVARCHAR(15),
  CONSTRAINT pammilestone_uid_pk PRIMARY KEY (crecorduid)
);


GO
DROP VIEW vuprightgroup;
GO
DROP VIEW vdownrightgroup;

GO
CREATE VIEW vuprightgroup AS
    SELECT
      ctimeslotfk, crightgroupuid, crepositoryfk,
      cpermissionfk, cgroupfk, cperimeterfk, '1' as cfromgroup, '0' AS cindirect,
      cdisplayname, caction, climit, cinherited,
      crighttype, cdefault, ccontext,
      ccustom1, ccustom2, ccustom3, ccustom4, ccustom5, ccustom6, ccustom7, ccustom8, ccustom9
    FROM
      trightgroup
    WHERE cindirect = '0'
  UNION ALL
    SELECT DISTINCT
      A.ctimeslotfk, A.crightgroupuid, A.crepositoryfk,
      A.cpermissionfk, R.cparentgroupfk AS cgroupfk, A.cperimeterfk, '1' as cfromgroup, '1' AS cindirect,
      A.cdisplayname, A.caction, A.climit, A.cinherited,
      A.crighttype, A.cdefault, A.ccontext,
      A.ccustom1, A.ccustom2, A.ccustom3, A.ccustom4, A.ccustom5, A.ccustom6, A.ccustom7, A.ccustom8, A.ccustom9
    FROM
      trightgroup A
      INNER JOIN tgrouplink R ON R.cgroupfk = A.cgroupfk
    WHERE A.cindirect = '0';

GO
CREATE VIEW vdownrightgroup AS
    SELECT
      ctimeslotfk, crightgroupuid, crepositoryfk,
      cpermissionfk, cgroupfk, cperimeterfk, '1' as cfromgroup, cindirect,
      cdisplayname, caction, climit, cinherited,
      crighttype, cdefault, ccontext,
      ccustom1, ccustom2, ccustom3, ccustom4, ccustom5, ccustom6, ccustom7, ccustom8, ccustom9
    FROM
      trightgroup;

GO
DROP VIEW vportaluprightgroup;
GO
DROP VIEW vportaldownrightgroup;

GO
CREATE VIEW vportaluprightgroup AS
    SELECT
      ctimeslotfk, crightgroupuid, crepositoryfk,
      cpermissionfk, cgroupfk, cperimeterfk, '1' as cfromgroup, '0' AS cindirect,
      cdisplayname, caction, climit, cinherited,
      crighttype, cdefault, ccontext,
      ccustom1, ccustom2, ccustom3, ccustom4, ccustom5, ccustom6, ccustom7, ccustom8, ccustom9
    FROM
      tportalrightgroup
    WHERE cindirect = '0'
  UNION ALL
    SELECT DISTINCT
      A.ctimeslotfk, A.crightgroupuid, A.crepositoryfk,
      A.cpermissionfk, R.cparentgroupfk AS cgroupfk, A.cperimeterfk, '1' as cfromgroup, '1' AS cindirect,
      A.cdisplayname, A.caction, A.climit, A.cinherited,
      A.crighttype, A.cdefault, A.ccontext,
      A.ccustom1, A.ccustom2, A.ccustom3, A.ccustom4, A.ccustom5, A.ccustom6, A.ccustom7, A.ccustom8, A.ccustom9
    FROM
      tportalrightgroup A
      INNER JOIN tportalgrouplink R ON R.cgroupfk = A.cgroupfk
    WHERE A.cindirect = '0';

GO
CREATE VIEW vportaldownrightgroup AS
    SELECT
      ctimeslotfk, crightgroupuid, crepositoryfk,
      cpermissionfk, cgroupfk, cperimeterfk, '1' as cfromgroup, cindirect,
      cdisplayname, caction, climit, cinherited,
      crighttype, cdefault, ccontext,
      ccustom1, ccustom2, ccustom3, ccustom4, ccustom5, ccustom6, ccustom7, ccustom8, ccustom9
    FROM
      tportalrightgroup;

-- REVIEWACTOR table

GO
CREATE TABLE treviewactor (
  -- Database primary key
  crecorduid            BIGINT NOT NULL IDENTITY (1, 1),
  -- Archive information
  ctimeslotfk           NVARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       BIGINT NOT NULL,
  cactorfk            BIGINT NOT NULL,
  CONSTRAINT reviewactor_ts_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);



-- REVIEWACCOUNTABLE table

GO
CREATE TABLE treviewaccountable (
  -- Database primary key
  crecorduid            BIGINT NOT NULL IDENTITY (1, 1),
  -- Archive information
  ctimeslotfk           NVARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       BIGINT NOT NULL,
  caccountablefk            BIGINT NOT NULL,
  CONSTRAINT reviewaccountable_ts_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);


-- PORTALREVIEWACTOR table
GO
CREATE TABLE tportalreviewactor (
  -- Database primary key
  crecorduid            BIGINT NOT NULL,
  -- Archive information
  ctimeslotfk           NVARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       BIGINT NOT NULL,
  cactorfk            BIGINT NOT NULL,
  CONSTRAINT previewactor_ts_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- PortalREVIEWACCOUNTABLE table
GO
CREATE TABLE tportalreviewaccountable (
  -- Database primary key
  crecorduid            BIGINT NOT NULL,
  -- Archive information
  ctimeslotfk           NVARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       BIGINT NOT NULL,
  caccountablefk            BIGINT NOT NULL,
  CONSTRAINT previewaccountable_ts_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- delete cactorfk, caccountablefk from ttickerreview
GO
ALTER TABLE tticketreview DROP COLUMN cactorfk;

GO
ALTER TABLE tticketreview DROP COLUMN caccountablefk;

-- migrate actor accountable data to new tables
GO
INSERT INTO treviewactor (ctimeslotfk, cticketreviewfk, cactorfk)
	SELECT i.ctimeslotfk, t.crecorduid AS cticketreviewfk, i.crecorduid AS cactorfk FROM tticketreview t
	INNER JOIN tidentity i on i.cidentityuid=t.cactoruid;

GO
INSERT INTO treviewaccountable (ctimeslotfk, cticketreviewfk, caccountablefk) 
	SELECT i.ctimeslotfk, t.crecorduid AS cticketreviewfk, i.crecorduid AS caccountablefk FROM tticketreview t
	INNER JOIN tidentity i on i.cidentityuid=t.caccountableuid;

GO
INSERT INTO tportalreviewactor (crecorduid, ctimeslotfk, cticketreviewfk, cactorfk)
	SELECT crecorduid, ctimeslotfk, cticketreviewfk, cactorfk FROM treviewactor a
	INNER JOIN timportlog i on i.cimportloguid = a.ctimeslotfk
	where i.cportal='1';
	
GO
INSERT INTO tportalreviewaccountable (crecorduid, ctimeslotfk, cticketreviewfk, caccountablefk)
	SELECT crecorduid, ctimeslotfk, cticketreviewfk, caccountablefk FROM treviewaccountable a
	INNER JOIN timportlog i on i.cimportloguid = a.ctimeslotfk
	where i.cportal='1';

GO
IF NOT EXISTS (SELECT name FROM sysindexes WHERE name = 'idx_metadata_ts_master') CREATE INDEX idx_metadata_ts_master ON tmetadata(ctimeslotfk, cmastermetadatafk);
GO
IF NOT EXISTS (SELECT name FROM sysindexes WHERE name = 'idx_pmetadata_ts_master') CREATE INDEX idx_pmetadata_ts_master ON tportalmetadata(ctimeslotfk, cmastermetadatafk);

GO
CREATE INDEX idx_tr_actor_timeslot ON treviewactor(ctimeslotfk);
GO
CREATE INDEX idx_tr_actor_ticket ON treviewactor(cticketreviewfk);
GO
CREATE INDEX idx_tr_actor ON treviewactor(cactorfk);

GO
CREATE INDEX idx_ptr_actor_timeslot ON tportalreviewactor(ctimeslotfk);
GO
CREATE INDEX idx_ptr_actor_ticket ON tportalreviewactor(cticketreviewfk);
GO
CREATE INDEX idx_ptr_actor ON tportalreviewactor(cactorfk);

GO
CREATE INDEX idx_tr_accountable_timeslot ON treviewaccountable(ctimeslotfk);
GO
CREATE INDEX idx_tr_accountable_ticket ON treviewaccountable(cticketreviewfk);
GO
CREATE INDEX idx_tr_accountable ON treviewaccountable(caccountablefk);

GO
CREATE INDEX idx_ptr_accountable_timeslot ON tportalreviewaccountable(ctimeslotfk);
GO
CREATE INDEX idx_ptr_accountable_ticket ON tportalreviewaccountable(cticketreviewfk);
GO
CREATE INDEX idx_ptr_accountable ON tportalreviewaccountable(caccountablefk);

GO

UPDATE tproperties SET cvalue='35' WHERE cpropertiesuid='VERSION';
