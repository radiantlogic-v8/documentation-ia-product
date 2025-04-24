/* 
COPYRIGHT BRAINWAVE, all rights reserved.
This computer program is protected by copyright law and international treaties.
Unauthorized duplication or distribution of this program, or any portion of it, may result in severe civil or criminal penalties, and will be prosecuted to the maximum extent possible under the law.

Usage: Upgrades The database schema from version Braille R1 to Curie R1

(c) Radiant Logic 2021

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
