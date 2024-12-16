/* 
COPYRIGHT BRAINWAVE, all rights reserved.
This computer program is protected by copyright law and international treaties.
Unauthorized duplication or distribution of this program, or any portion of it, may result in severe civil or criminal penalties, and will be prosecuted to the maximum extent possible under the law.

Usage: Upgrades The database schema from version Braille R1 to schema 33

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
  cname                 VARCHAR(250),
  cbusinessdomain       VARCHAR(250),
  cdescription          VARCHAR(4000),
  cduedate              VARCHAR(15),
  CONSTRAINT mission_uid_pk PRIMARY KEY (crecorduid)
);


-- ENDPOINT table

GO
CREATE TABLE tendpoint (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL IDENTITY (1, 1) ,
  -- Object information
  cname                 VARCHAR(250)  NOT NULL,
  cdescription          VARCHAR(4000),
  cprovider             VARCHAR(100)  NOT NULL,
  cdefinition           VARCHAR(4000),
  CONSTRAINT endpoint_uid_pk PRIMARY KEY (crecorduid)
);


-- MISSIONWAVE table

GO
CREATE TABLE tmissionwave (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL IDENTITY (1, 1) ,
  -- Object information
  cname                 VARCHAR(250)  NOT NULL,
  cdescription          VARCHAR(4000),
  cendpointfk           INTEGER,
  ctimeslotfk           VARCHAR(64),
  ccreationdate         VARCHAR(15),
  chidden               CHAR(1)       NOT NULL,
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
  ctype                 VARCHAR(32)   NOT NULL,
  ckey                  VARCHAR(100)  NOT NULL,
  cvalue                VARCHAR(100),
  clabels               VARCHAR(4000),
  cmissionwavefk        INTEGER       NOT NULL,
  cavailable            CHAR(1)       NOT NULL,
  ccompleted            CHAR(1)       NOT NULL,
  CONSTRAINT missionwavestage_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT stage_wave_fk FOREIGN KEY (cmissionwavefk) REFERENCES tmissionwave(crecorduid) ON DELETE CASCADE ON UPDATE NO ACTION
);


-- SOFTWARE table

GO
CREATE TABLE tsoftware (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL IDENTITY (1, 1) ,
  -- Object information
  cname                 VARCHAR(250)  NOT NULL,
  cdescription          VARCHAR(4000),
  ccriticity            INTEGER,
  cfamily               VARCHAR(100),
  cmissionwavefk        INTEGER       NOT NULL,
  ctype                 CHAR(1)       NOT NULL,
  caddonname            VARCHAR(100),
  caddondisplayname     VARCHAR(250),
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
  ckey                  VARCHAR(250)  NOT NULL,
  cvalue                VARCHAR(1000),
  CONSTRAINT softwarevar_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT softwarevar_software_fk FOREIGN KEY (csoftwarefk) REFERENCES tsoftware(crecorduid) ON DELETE CASCADE ON UPDATE NO ACTION
);


-- UPLOADFILE table

GO
CREATE TABLE tuploadfile (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL IDENTITY (1, 1) ,
  -- Object information
  cinternalfilename     VARCHAR(1000) NOT NULL,
  cexternalfilename     VARCHAR(1000) NOT NULL,
  cdisplayname          VARCHAR(1000) NOT NULL,
  ctemporarypath        VARCHAR(1000) NOT NULL,
  cstatus               CHAR(1)       NOT NULL,
  csize                 INTEGER,
  clastmodified         VARCHAR(15),
  chashcode             VARCHAR(64),
  cissueddate           VARCHAR(15),
  cupdateddate          VARCHAR(15),
  cnode                 VARCHAR(250),
  cerrormessage         VARCHAR(1000),
  CONSTRAINT uploadfile_uid_pk PRIMARY KEY (crecorduid)
);


-- DATASOURCE table

GO
CREATE TABLE tdatasource (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL IDENTITY (1, 1) ,
  -- Object information
  cname                 VARCHAR(250)  NOT NULL,
  cdescription          VARCHAR(4000),
  csoftwarefk           INTEGER       NOT NULL,
  cendpointfk           INTEGER,
  ctype                 VARCHAR(15),
  cparsingoptions       VARCHAR(4000),
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
  cvalidationstatus     VARCHAR(25),
  cmessages             VARCHAR(MAX),
  CONSTRAINT datasourcefile_uid_pk PRIMARY KEY (crecorduid)
  
  
);


-- MAPPING table

GO
CREATE TABLE tmapping (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL IDENTITY (1, 1) ,
  -- Object information
  cname                 VARCHAR(250)  NOT NULL,
  cdatasourcefk         INTEGER       NOT NULL,
  centity               CHAR(1)       NOT NULL,
  CONSTRAINT mapping_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT mapping_datasource_fk FOREIGN KEY (cdatasourcefk) REFERENCES tdatasource(crecorduid) ON DELETE CASCADE ON UPDATE NO ACTION
);


-- MAPPINGCOMPUTED table

GO
CREATE TABLE tmappingcomputed (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL IDENTITY (1, 1) ,
  -- Object information
  cname                 VARCHAR(100)  NOT NULL,
  cmappingfk            INTEGER       NOT NULL,
  ctype                 CHAR(1)       NOT NULL,
  cmode                 CHAR(1)       NOT NULL,
  cexpression           VARCHAR(2000),
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
  centityattribute      VARCHAR(100)  NOT NULL,
  ctype                 CHAR(1)       NOT NULL,
  cmode                 CHAR(1)       NOT NULL,
  cdatasourceattribute  VARCHAR(100),
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
  cname                 VARCHAR(250)  NOT NULL,
  cexpression           VARCHAR(2000),
  CONSTRAINT mappingfilter_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT mappingfilter_mapping_fk FOREIGN KEY (cmappingfk) REFERENCES tmapping(crecorduid) ON DELETE CASCADE ON UPDATE NO ACTION
);


-- EXECPLANMONITOR table

GO
CREATE TABLE texecplanmonitor (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL IDENTITY (1, 1) ,
  -- Object information
  cstatus               CHAR(1)       NOT NULL,
  cprincipalname        VARCHAR(200)  NOT NULL,
  cmissionwavefk        INTEGER,
  csubmitdate           VARCHAR(15)   NOT NULL,
  ctimeslotfk           VARCHAR(64),
  ctaskid               VARCHAR(200),
  cstartdate            VARCHAR(15),
  cheartbeat            VARCHAR(15),
  ccompleteddate         VARCHAR(15),
  cphase                CHAR(1),
  cerrormessage         VARCHAR(2000),
  ccurrentfile          VARCHAR(2000),
  ccurrentsilo          VARCHAR(250),
  CONSTRAINT execplanmonitor_uid_pk PRIMARY KEY (crecorduid)
);



GO

UPDATE tproperties SET cvalue='33' WHERE cpropertiesuid='VERSION';
