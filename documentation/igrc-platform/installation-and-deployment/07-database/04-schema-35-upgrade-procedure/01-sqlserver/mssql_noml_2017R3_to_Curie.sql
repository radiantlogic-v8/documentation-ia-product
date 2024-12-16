/* 
COPYRIGHT BRAINWAVE, all rights reserved.
This computer program is protected by copyright law and international treaties.
Unauthorized duplication or distribution of this program, or any portion of it, may result in severe civil or criminal penalties, and will be prosecuted to the maximum extent possible under the law.

Usage: Upgrades The database schema from version 2017 R3 to Curie R1

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

-- Upgrade script to version 31
-- --------

-- Upgrade database from version 30 to version 31

-- add progress status in timportlog to follow the fine grained operation and prevent from starting the same one a second time
GO
ALTER TABLE timportlog ADD cprogressstatus          VARCHAR(64);
GO
ALTER TABLE timportlog ADD clastprogressdate        VARCHAR(15);
GO
ALTER TABLE timportlog ADD clastprogressday         INTEGER;

-- expand reason in exception table
GO
ALTER TABLE texception ALTER COLUMN creason VARCHAR(4000);



-- expand reason in exception portal table
GO
ALTER TABLE tportalexception ALTER COLUMN creason VARCHAR(4000);



-- add columns in ticketlog to handle the on-hold feature
GO
ALTER TABLE tticketlog ADD cnbreleasedsubproc       INTEGER;
GO
ALTER TABLE tticketlog ADD cnbonholdsubproc         INTEGER;
GO
ALTER TABLE tticketlog ADD cnbcandidates            INTEGER;
GO
ALTER TABLE tticketlog ADD ccandidatefullnames      VARCHAR(4000);

-- add columns to handle 
GO
CREATE INDEX idx_account_sid ON taccount(csid);

-- indexes to speed up the search in history for account at collect time
GO
CREATE INDEX idx_repository_repotype ON trepository(crepositorytype, ctimeslotfk, crecorduid);
GO
CREATE INDEX idx_account_guidrepo on taccount (cguid,crepositoryfk,caccountuid);

-- indexes to speed up the renew of reconciliation review tickets
GO
CREATE INDEX idx_ticketreview_creviewtype ON tticketreview(creviewtype);

GO
CREATE INDEX idx_ppermissionlink_parentp on tportalpermissionlink (cparentpermissionfk,cpermissionfk);

-- add missing import table acl changes
-- taclaccount, taclgroup, tfsrightgroup, tportalaclaccount, tportalaclgroup, tportalfsrightgroup
GO
ALTER TABLE timportaclaccount ALTER COLUMN caction VARCHAR(40);


GO
ALTER TABLE timportaclgroup ALTER COLUMN caction VARCHAR(40);



GO
ALTER TABLE tticketaction ADD creviewerfk           INTEGER;
GO
ALTER TABLE tticketaction ADD crevieweruid          VARCHAR(64);
GO
ALTER TABLE tticketaction ADD creviewerfullname     VARCHAR(96);
GO
ALTER TABLE tticketaction ADD caccountablefk        INTEGER;
GO
ALTER TABLE tticketaction ADD caccountableuid       VARCHAR(64);
GO
ALTER TABLE tticketaction ADD caccountablefullname  VARCHAR(96);
GO
ALTER TABLE tticketaction ADD ccategory             VARCHAR(250);
GO
ALTER TABLE tticketaction ADD cworkloadtime         INTEGER;

GO
ALTER TABLE tticketreview DROP CONSTRAINT ticketreview_type_ck;
GO
ALTER TABLE tticketreview ADD cmetadatauid          VARCHAR(64);
GO
ALTER TABLE tticketreview ADD cparentgroupuid       VARCHAR(64);
GO
ALTER TABLE tticketreview ADD cparentpermuid        VARCHAR(64);
GO
ALTER TABLE tticketreview ADD cactorfk              INTEGER;
GO
ALTER TABLE tticketreview ADD cactoruid             VARCHAR(64);
GO
ALTER TABLE tticketreview ADD cactorfullname        VARCHAR(96);
GO
ALTER TABLE tticketreview ADD caccountablefk        INTEGER;
GO
ALTER TABLE tticketreview ADD caccountableuid       VARCHAR(64);
GO
ALTER TABLE tticketreview ADD caccountablefullname  VARCHAR(96);
GO
ALTER TABLE tticketreview ADD cactiondate           VARCHAR(15);
GO
ALTER TABLE tticketreview ADD cactionday            INTEGER;
GO
ALTER TABLE tticketreview ADD cvalidfromdate        VARCHAR(15);
GO
ALTER TABLE tticketreview ADD cvalidfromday         INTEGER;
GO
ALTER TABLE tticketreview ADD cvalidtodate          VARCHAR(15);
GO
ALTER TABLE tticketreview ADD cvalidtoday           INTEGER;

UPDATE tticketaction SET creviewerfk=cactorfk, crevieweruid=cactoruid, creviewerfullname=cactorfullname, caccountablefk=cactorfk, caccountableuid=cactoruid, caccountablefullname=cactorfullname WHERE cdelegateeuid IS NULL;
UPDATE tticketaction SET creviewerfk=cdelegateefk, crevieweruid=cdelegateeuid, creviewerfullname=cdelegateefullname, caccountablefk=cactorfk, caccountableuid=cactoruid, caccountablefullname=cactorfullname WHERE cdelegateeuid IS NOT NULL;

-- METADATAREVIEW table
GO
CREATE TABLE tmetadatareview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  cmetadatafk           INTEGER       NOT NULL,
  CONSTRAINT metadatareview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

GO
ALTER TABLE tmetadata ADD csubkey VARCHAR(64);
GO
ALTER TABLE tmetadata ADD cmastermetadatafk INTEGER;
GO
ALTER TABLE tmetadata ADD ccharacteristic CHAR(1);
GO
ALTER TABLE tmetadata ADD cactorfk INTEGER;
GO
ALTER TABLE tmetadata ADD cactoruid VARCHAR(64);
GO
ALTER TABLE tmetadata ADD cactorfullname VARCHAR(96);
GO
ALTER TABLE tmetadata ADD CONSTRAINT metadata_charact_ck CHECK (ccharacteristic IN ('0', '1'));
GO
ALTER TABLE tmetadata DROP CONSTRAINT metadata_origin_ck;
GO
ALTER TABLE tmetadata DROP CONSTRAINT metadata_boolean_ck;

-- METADATA table

GO
CREATE TABLE tmetadatavalue (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL    IDENTITY (1, 1)  ,
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object permanent key
  cmetadatafk           INTEGER       NOT NULL,
  -- Object information
  cvalue1string         VARCHAR(300),
  cvalue2string         VARCHAR(300),
  cvalue1integer        INTEGER,
  cvalue2integer        INTEGER,
  cvalue1double         FLOAT,
  cvalue2double         FLOAT,
  cvalue1date           VARCHAR(15),
  cvalue1day            INTEGER,
  cvalue2date           VARCHAR(15),
  cvalue2day            INTEGER,
  cvalueboolean         CHAR(1),
  cvalueorganisationuid VARCHAR(64),
  cvalueorganisationfk  INTEGER,
  cvalueidentityuid     VARCHAR(64),
  cvalueidentityfk      INTEGER,
  cvaluerepositoryuid   VARCHAR(64),
  cvaluerepositoryfk    INTEGER,
  cvaluegroupuid        VARCHAR(64),
  cvaluegroupfk         INTEGER,
  cvalueaccountuid      VARCHAR(64),
  cvalueaccountfk       INTEGER,
  cvalueperimeteruid    VARCHAR(64),
  cvalueperimeterfk     INTEGER,
  cvaluepermissionuid   VARCHAR(64),
  cvaluepermissionfk    INTEGER,
  cvalueapplicationuid  VARCHAR(64),
  cvalueapplicationfk   INTEGER,
  cvalueassetuid        VARCHAR(64),
  cvalueassetfk         INTEGER,
  cdetails              VARCHAR(MAX),
  CONSTRAINT metadatavalue_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT metadatavalue_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT metadatavalue_boolean_ck CHECK (cvalueboolean IN ('0', '1'))
);




GO
DROP INDEX tmetadata.idx_metadata_value1string;
GO
DROP INDEX tmetadata.idx_metadata_value2string;
GO
DROP INDEX tmetadata.idx_metadata_value1integer;
GO
DROP INDEX tmetadata.idx_metadata_value2integer;
GO
DROP INDEX tmetadata.idx_metadata_value1double;
GO
DROP INDEX tmetadata.idx_metadata_value2double;
GO
DROP INDEX tmetadata.idx_metadata_value1date;
GO
DROP INDEX tmetadata.idx_metadata_value1day;
GO
DROP INDEX tmetadata.idx_metadata_value2date;
GO
DROP INDEX tmetadata.idx_metadata_value2day;
GO
DROP INDEX tmetadata.idx_metadata_valueboolean;


GO
CREATE INDEX idx_metadatav_value1string ON tmetadatavalue(cmetadatafk,cvalue1string);
GO
CREATE INDEX idx_metadatav_value2string ON tmetadatavalue(cmetadatafk,cvalue2string);
GO
CREATE INDEX idx_metadatav_value1integer ON tmetadatavalue(cmetadatafk,cvalue1integer);
GO
CREATE INDEX idx_metadatav_value2integer ON tmetadatavalue(cmetadatafk,cvalue2integer);
GO
CREATE INDEX idx_metadatav_value1double ON tmetadatavalue(cmetadatafk,cvalue1double);
GO
CREATE INDEX idx_metadatav_value2double ON tmetadatavalue(cmetadatafk,cvalue2double);
GO
CREATE INDEX idx_metadatav_value1date ON tmetadatavalue(cmetadatafk,cvalue1date);
GO
CREATE INDEX idx_metadatav_value1day ON tmetadatavalue(cmetadatafk,cvalue1day);
GO
CREATE INDEX idx_metadatav_value2date ON tmetadatavalue(cmetadatafk,cvalue2date);
GO
CREATE INDEX idx_metadatav_value2day ON tmetadatavalue(cmetadatafk,cvalue2day);
GO
CREATE INDEX idx_metadatav_valueboolean ON tmetadatavalue(cmetadatafk,cvalueboolean);
GO
CREATE INDEX idx_metadatav_organisation ON tmetadatavalue(cmetadatafk,cvalueorganisationfk);
GO
CREATE INDEX idx_metadatav_identity ON tmetadatavalue(cmetadatafk,cvalueidentityfk);
GO
CREATE INDEX idx_metadatav_repository ON tmetadatavalue(cmetadatafk,cvaluerepositoryfk);
GO
CREATE INDEX idx_metadatav_group ON tmetadatavalue(cmetadatafk,cvaluegroupfk);
GO
CREATE INDEX idx_metadatav_account ON tmetadatavalue(cmetadatafk,cvalueaccountfk);
GO
CREATE INDEX idx_metadatav_perimeter ON tmetadatavalue(cmetadatafk,cvalueperimeterfk);
GO
CREATE INDEX idx_metadatav_permission ON tmetadatavalue(cmetadatafk,cvaluepermissionfk);
GO
CREATE INDEX idx_metadatav_application ON tmetadatavalue(cmetadatafk,cvalueapplicationfk);
GO
CREATE INDEX idx_metadatav_asset ON tmetadatavalue(cmetadatafk,cvalueassetfk);

GO
ALTER TABLE timportmetadata ADD csubkey VARCHAR(64);
GO
ALTER TABLE timportmetadata ADD cmastermetadatafk VARCHAR(64);
GO
ALTER TABLE timportmetadata ADD ccharacteristic CHAR(1);
GO
ALTER TABLE timportmetadata ADD CONSTRAINT importmetadata_charact_ck CHECK (ccharacteristic IN ('0', '1'));
GO
ALTER TABLE timportmetadata DROP CONSTRAINT importmetadata_origin_ck;
GO
ALTER TABLE timportmetadata DROP CONSTRAINT importmetadata_boolean_ck;

-- IMPORTMETADATA table
GO
CREATE TABLE timportmetadatavalue (
  -- Sandbox (part of the primary key)
  cimportlogfk          VARCHAR(64)   NOT NULL,
  -- Object permanent key
  cmetadatauid          VARCHAR(64)   NOT NULL,
  -- Object information
  csilofk               VARCHAR(64),
  cvalue1string         VARCHAR(300),
  cvalue2string         VARCHAR(300),
  cvalue1integer        INTEGER,
  cvalue2integer        INTEGER,
  cvalue1double         FLOAT,
  cvalue2double         FLOAT,
  cvalue1date           VARCHAR(15),
  cvalue1day            INTEGER,
  cvalue2date           VARCHAR(15),
  cvalue2day            INTEGER,
  cvalueboolean         CHAR(1),
  cvalueorganisationfk  VARCHAR(64),
  cvalueidentityfk      VARCHAR(64),
  cvaluerepositoryfk    VARCHAR(64),
  cvaluegroupfk         VARCHAR(64),
  cvalueaccountfk       VARCHAR(64),
  cvalueperimeterfk     VARCHAR(64),
  cvaluepermissionfk    VARCHAR(64),
  cvalueapplicationfk   VARCHAR(64),
  cvalueassetfk         VARCHAR(64),
  cdetails              VARCHAR(MAX),
  CONSTRAINT importmetadatav_importlog_fk FOREIGN KEY (cimportlogfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT importmetadatav_boolean_ck CHECK (cvalueboolean IN ('0', '1'))
);

-- PORTALMETADATAREVIEW table
GO
CREATE TABLE tportalmetadatareview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  cmetadatafk           INTEGER       NOT NULL,
  CONSTRAINT pmetadatareview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

GO
ALTER TABLE tportalmetadata ADD csubkey VARCHAR(64);
GO
ALTER TABLE tportalmetadata ADD cmastermetadatafk INTEGER;
GO
ALTER TABLE tportalmetadata ADD ccharacteristic CHAR(1);
GO
ALTER TABLE tportalmetadata ADD cactorfk INTEGER;
GO
ALTER TABLE tportalmetadata ADD cactoruid VARCHAR(64);
GO
ALTER TABLE tportalmetadata ADD cactorfullname VARCHAR(96);
GO
ALTER TABLE tportalmetadata ADD CONSTRAINT pmetadata_charact_ck CHECK (ccharacteristic IN ('0', '1'));
GO
ALTER TABLE tportalmetadata DROP CONSTRAINT pmetadata_origin_ck;
GO
ALTER TABLE tportalmetadata DROP CONSTRAINT pmetadata_boolean_ck;

GO
CREATE TABLE tportalmetadatavalue (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL,
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object permanent key
  cmetadatafk           INTEGER       NOT NULL,
  -- Object information
  cvalue1string         VARCHAR(300),
  cvalue2string         VARCHAR(300),
  cvalue1integer        INTEGER,
  cvalue2integer        INTEGER,
  cvalue1double         FLOAT,
  cvalue2double         FLOAT,
  cvalue1date           VARCHAR(15),
  cvalue1day            INTEGER,
  cvalue2date           VARCHAR(15),
  cvalue2day            INTEGER,
  cvalueboolean         CHAR(1),
  cvalueorganisationuid VARCHAR(64),
  cvalueorganisationfk  INTEGER,
  cvalueidentityuid     VARCHAR(64),
  cvalueidentityfk      INTEGER,
  cvaluerepositoryuid   VARCHAR(64),
  cvaluerepositoryfk    INTEGER,
  cvaluegroupuid        VARCHAR(64),
  cvaluegroupfk         INTEGER,
  cvalueaccountuid      VARCHAR(64),
  cvalueaccountfk       INTEGER,
  cvalueperimeteruid    VARCHAR(64),
  cvalueperimeterfk     INTEGER,
  cvaluepermissionuid   VARCHAR(64),
  cvaluepermissionfk    INTEGER,
  cvalueapplicationuid  VARCHAR(64),
  cvalueapplicationfk   INTEGER,
  cvalueassetuid        VARCHAR(64),
  cvalueassetfk         INTEGER,
  cdetails              VARCHAR(MAX),
  CONSTRAINT pmetadatavalue_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT pmetadatavalue_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT pmetadatavalue_boolean_ck CHECK (cvalueboolean IN ('0', '1'))
);

-- ACCOUNTGROUPREVIEW table
GO
CREATE TABLE taccountgroupreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  caccountgroupfk       INTEGER       NOT NULL,
  CONSTRAINT accountgroupreview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- PORTALACCOUNTGROUPREVIEW table
GO
CREATE TABLE tportalaccountgroupreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  caccountgroupfk       INTEGER       NOT NULL,
  CONSTRAINT paccountgroupreview_ts_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- GROUPLINKREVIEW table
GO
CREATE TABLE tgrouplinkreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  cgrouplinkfk          INTEGER       NOT NULL,
  CONSTRAINT grouplinkreview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- PORTALGROUPLINKREVIEW table
GO
CREATE TABLE tportalgrouplinkreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  cgrouplinkfk              INTEGER       NOT NULL,
  CONSTRAINT pgrouplinkreview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- PERMLINKREVIEW table
GO
CREATE TABLE tpermlinkreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  cpermlinkfk           INTEGER       NOT NULL,
  CONSTRAINT permlinkreview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- PortalPERMLINKREVIEW table
GO
CREATE TABLE tportalpermlinkreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  cpermlinkfk           INTEGER       NOT NULL,
  CONSTRAINT ppermlinkreview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- RAWPERMLINKREVIEW table
GO
CREATE TABLE trawpermlinkreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  crawpermlinkfk         INTEGER       NOT NULL,
  CONSTRAINT rawpermlinkreview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- PORTALRAWPERMLINKREVIEW table
GO
CREATE TABLE tportalrawpermlinkreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  crawpermlinkfk         INTEGER       NOT NULL,
  CONSTRAINT prawpermlinkreview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- RAWRIGHTREVIEW table
GO
CREATE TABLE trawrightreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  crawrightfk           INTEGER       NOT NULL,
  CONSTRAINT rawrightreview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- PORTALRAWRIGHTREVIEW table
GO
CREATE TABLE tportalrawrightreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  crawrightfk           INTEGER       NOT NULL,
  CONSTRAINT prawrightreview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- RAWRIGHTGROUPREVIEW table
GO
CREATE TABLE trawrightgroupreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  crawrightgroupfk      INTEGER       NOT NULL,
  CONSTRAINT rawrightgrpreview_ts_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- PORTALRAWRIGHTGROUPREVIEW table
GO
CREATE TABLE tportalrawrightgroupreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  crawrightgroupfk      INTEGER       NOT NULL,
  CONSTRAINT prawrightgrpreview_ts_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- PERMGROUP review table
GO
CREATE TABLE tpermgroupreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  cgroupfk              INTEGER       NOT NULL,
  cpermissionfk         INTEGER       NOT NULL,
  CONSTRAINT permgroupreview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- PortalPERMGROUP review table
GO
CREATE TABLE tportalpermgroupreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  cgroupfk              INTEGER       NOT NULL,
  cpermissionfk         INTEGER       NOT NULL,
  CONSTRAINT ppermgroupreview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);



GO
DROP INDEX tportalmetadata.idx_pmetadata_value1string;
GO
DROP INDEX tportalmetadata.idx_pmetadata_value2string;
GO
DROP INDEX tportalmetadata.idx_pmetadata_value1integer;
GO
DROP INDEX tportalmetadata.idx_pmetadata_value2integer;
GO
DROP INDEX tportalmetadata.idx_pmetadata_value1double;
GO
DROP INDEX tportalmetadata.idx_pmetadata_value2double;
GO
DROP INDEX tportalmetadata.idx_pmetadata_value1date;
GO
DROP INDEX tportalmetadata.idx_pmetadata_value1day;
GO
DROP INDEX tportalmetadata.idx_pmetadata_value2date;
GO
DROP INDEX tportalmetadata.idx_pmetadata_value2day;
GO
DROP INDEX tportalmetadata.idx_pmetadata_valueboolean;


GO
CREATE INDEX idx_pmetadatav_value1string ON tportalmetadatavalue(cmetadatafk,cvalue1string);
GO
CREATE INDEX idx_pmetadatav_value2string ON tportalmetadatavalue(cmetadatafk,cvalue2string);
GO
CREATE INDEX idx_pmetadatav_value1integer ON tportalmetadatavalue(cmetadatafk,cvalue1integer);
GO
CREATE INDEX idx_pmetadatav_value2integer ON tportalmetadatavalue(cmetadatafk,cvalue2integer);
GO
CREATE INDEX idx_pmetadatav_value1double ON tportalmetadatavalue(cmetadatafk,cvalue1double);
GO
CREATE INDEX idx_pmetadatav_value2double ON tportalmetadatavalue(cmetadatafk,cvalue2double);
GO
CREATE INDEX idx_pmetadatav_value1date ON tportalmetadatavalue(cmetadatafk,cvalue1date);
GO
CREATE INDEX idx_pmetadatav_value1day ON tportalmetadatavalue(cmetadatafk,cvalue1day);
GO
CREATE INDEX idx_pmetadatav_value2date ON tportalmetadatavalue(cmetadatafk,cvalue2date);
GO
CREATE INDEX idx_pmetadatav_value2day ON tportalmetadatavalue(cmetadatafk,cvalue2day);
GO
CREATE INDEX idx_pmetadatav_valueboolean ON tportalmetadatavalue(cmetadatafk,cvalueboolean);
GO
CREATE INDEX idx_pmetadatav_organisation ON tportalmetadatavalue(cmetadatafk,cvalueorganisationfk);
GO
CREATE INDEX idx_pmetadatav_identity ON tportalmetadatavalue(cmetadatafk,cvalueidentityfk);
GO
CREATE INDEX idx_pmetadatav_repository ON tportalmetadatavalue(cmetadatafk,cvaluerepositoryfk);
GO
CREATE INDEX idx_pmetadatav_group ON tportalmetadatavalue(cmetadatafk,cvaluegroupfk);
GO
CREATE INDEX idx_pmetadatav_account ON tportalmetadatavalue(cmetadatafk,cvalueaccountfk);
GO
CREATE INDEX idx_pmetadatav_perimeter ON tportalmetadatavalue(cmetadatafk,cvalueperimeterfk);
GO
CREATE INDEX idx_pmetadatav_permission ON tportalmetadatavalue(cmetadatafk,cvaluepermissionfk);
GO
CREATE INDEX idx_pmetadatav_application ON tportalmetadatavalue(cmetadatafk,cvalueapplicationfk);
GO
CREATE INDEX idx_pmetadatav_asset ON tportalmetadatavalue(cmetadatafk,cvalueassetfk);

GO
CREATE INDEX idx_metadatarev_timeslot ON tmetadatareview(ctimeslotfk);
GO
CREATE INDEX idx_metadatarev_ticket ON tmetadatareview(cticketreviewfk);
GO
CREATE INDEX idx_metadatarev ON tmetadatareview(cmetadatafk);

GO
CREATE INDEX idx_pmetadatarev_timeslot ON tportalmetadatareview(ctimeslotfk);
GO
CREATE INDEX idx_pmetadatarev_ticket ON tportalmetadatareview(cticketreviewfk);
GO
CREATE INDEX idx_pmetadatarev ON tportalmetadatareview(cmetadatafk);

GO
INSERT INTO tmetadatavalue(ctimeslotfk,cmetadatafk,cvalue1string,cvalue2string,cvalue1integer,cvalue2integer,cvalue1double,cvalue2double,cvalue1date,cvalue1day,cvalue2date,cvalue2day,cvalueboolean,cdetails)
	SELECT ctimeslotfk,crecorduid,cvalue1string,cvalue2string,cvalue1integer,cvalue2integer,cvalue1double,cvalue2double,cvalue1date,cvalue1day,cvalue2date,cvalue2day,cvalueboolean,cdetails
	FROM tmetadata;

GO
ALTER TABLE tmetadata DROP COLUMN cvalue1string;
GO
ALTER TABLE tmetadata DROP COLUMN cvalue2string;
GO
ALTER TABLE tmetadata DROP COLUMN cvalue1integer;
GO
ALTER TABLE tmetadata DROP COLUMN cvalue2integer;
GO
ALTER TABLE tmetadata DROP COLUMN cvalue1double;
GO
ALTER TABLE tmetadata DROP COLUMN cvalue2double;
GO
ALTER TABLE tmetadata DROP COLUMN cvalue1date;
GO
ALTER TABLE tmetadata DROP COLUMN cvalue1day;
GO
ALTER TABLE tmetadata DROP COLUMN cvalue2date;
GO
ALTER TABLE tmetadata DROP COLUMN cvalue2day;
GO
ALTER TABLE tmetadata DROP COLUMN cvalueboolean;
GO
ALTER TABLE tmetadata DROP COLUMN cdetails;

GO
INSERT INTO tportalmetadatavalue(crecorduid,ctimeslotfk,cmetadatafk,cvalue1string,cvalue2string,cvalue1integer,cvalue2integer,cvalue1double,cvalue2double,cvalue1date,cvalue1day,cvalue2date,cvalue2day,cvalueboolean,cdetails)
	SELECT mv.crecorduid,mv.ctimeslotfk,pm.crecorduid,mv.cvalue1string,mv.cvalue2string,mv.cvalue1integer,mv.cvalue2integer,mv.cvalue1double,mv.cvalue2double,mv.cvalue1date,mv.cvalue1day,mv.cvalue2date,mv.cvalue2day,mv.cvalueboolean,mv.cdetails
	FROM tmetadatavalue mv INNER JOIN tportalmetadata pm ON mv.cmetadatafk=pm.crecorduid;

GO
ALTER TABLE tportalmetadata DROP COLUMN cvalue1string;
GO
ALTER TABLE tportalmetadata DROP COLUMN cvalue2string;
GO
ALTER TABLE tportalmetadata DROP COLUMN cvalue1integer;
GO
ALTER TABLE tportalmetadata DROP COLUMN cvalue2integer;
GO
ALTER TABLE tportalmetadata DROP COLUMN cvalue1double;
GO
ALTER TABLE tportalmetadata DROP COLUMN cvalue2double;
GO
ALTER TABLE tportalmetadata DROP COLUMN cvalue1date;
GO
ALTER TABLE tportalmetadata DROP COLUMN cvalue1day;
GO
ALTER TABLE tportalmetadata DROP COLUMN cvalue2date;
GO
ALTER TABLE tportalmetadata DROP COLUMN cvalue2day;
GO
ALTER TABLE tportalmetadata DROP COLUMN cvalueboolean;
GO
ALTER TABLE tportalmetadata DROP COLUMN cdetails;

GO
ALTER TABLE timportmetadata DROP COLUMN cvalue1string;
GO
ALTER TABLE timportmetadata DROP COLUMN cvalue2string;
GO
ALTER TABLE timportmetadata DROP COLUMN cvalue1integer;
GO
ALTER TABLE timportmetadata DROP COLUMN cvalue2integer;
GO
ALTER TABLE timportmetadata DROP COLUMN cvalue1double;
GO
ALTER TABLE timportmetadata DROP COLUMN cvalue2double;
GO
ALTER TABLE timportmetadata DROP COLUMN cvalue1date;
GO
ALTER TABLE timportmetadata DROP COLUMN cvalue1day;
GO
ALTER TABLE timportmetadata DROP COLUMN cvalue2date;
GO
ALTER TABLE timportmetadata DROP COLUMN cvalue2day;
GO
ALTER TABLE timportmetadata DROP COLUMN cvalueboolean;
GO
ALTER TABLE timportmetadata DROP COLUMN cdetails;


GO
CREATE TABLE tmetadatalink (
  crecorduid            INTEGER       NOT NULL IDENTITY (1, 1),
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  cparentmetadatafk     INTEGER       NOT NULL,
  cchildmetadatafk      INTEGER       NOT NULL,
  clevel                INTEGER       NOT NULL,
  CONSTRAINT metadatalink_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT metadatalink_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT metadatalink_uk UNIQUE (ctimeslotfk, cparentmetadatafk, cchildmetadatafk)
);


GO
CREATE INDEX idx_metadatalink_parent ON tmetadatalink(cparentmetadatafk);
GO
CREATE INDEX idx_metadatalink_child ON tmetadatalink(cchildmetadatafk);

GO
CREATE TABLE tportalmetadatalink (
  crecorduid            INTEGER       NOT NULL,
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  cparentmetadatafk     INTEGER       NOT NULL,
  cchildmetadatafk      INTEGER       NOT NULL,
  clevel                INTEGER       NOT NULL,
  CONSTRAINT pmetadatalink_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT pmetadatalink_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT pmetadatalink_uk UNIQUE (ctimeslotfk, cparentmetadatafk, cchildmetadatafk)
);

GO
CREATE INDEX idx_pmetadatalink_parent ON tportalmetadatalink(cparentmetadatafk);
GO
CREATE INDEX idx_pmetadatalink_child ON tportalmetadatalink(cchildmetadatafk);

-- RAW RIGHT GROUPS


GO
CREATE TABLE trawrightgroup (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL IDENTITY (1, 1) ,
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object permanent key
  crawrightgroupuid     VARCHAR(64)   NOT NULL,
  -- Object information
  crepositoryfk         INTEGER       NOT NULL,
  cgroupfk              INTEGER       NOT NULL,
  cpermissionfk         INTEGER       NOT NULL,
  cperimeterfk          INTEGER,
  crighttype            VARCHAR(32),
  cdisplayname          VARCHAR(250),
  cnegative             CHAR(1)       NOT NULL,
  cdefault              CHAR(1),
  ccontext              VARCHAR(250), -- small to be indexable on SQLServer
  ccustom1              VARCHAR(1000),
  ccustom2              VARCHAR(1000),
  ccustom3              VARCHAR(1000),
  ccustom4              VARCHAR(1000),
  ccustom5              VARCHAR(1000),
  ccustom6              VARCHAR(1000),
  ccustom7              VARCHAR(1000),
  ccustom8              VARCHAR(1000),
  ccustom9              VARCHAR(1000),
  CONSTRAINT rawrightgroup_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT rawrightgroup_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  
  CONSTRAINT rawrightgroup_uid_uk UNIQUE (ctimeslotfk, crawrightgroupuid),
  CONSTRAINT rawrightgroup_negative_ck CHECK (cnegative IN ('0', '1')),
  CONSTRAINT rawrightgroup_default_ck CHECK (cdefault IN ('0', '1'))
);


GO
CREATE INDEX idx_rawrightgroup_uids ON trawrightgroup(cgroupfk, cpermissionfk, cperimeterfk, cnegative);

GO
CREATE TABLE timportrawrightgroup (
  -- Sandbox (part of the primary key)
  cimportlogfk          VARCHAR(64)   NOT NULL,
  -- Object permanent key
  crawrightgroupuid     VARCHAR(64)   NOT NULL,
  -- Object information
  csilofk               VARCHAR(64),
  crepositoryfk         VARCHAR(64)   NOT NULL,
  cgroupfk              VARCHAR(64)   NOT NULL,
  cpermissionfk         VARCHAR(64)   NOT NULL,
  cperimeterfk          VARCHAR(64),
  crighttype            VARCHAR(32),
  cdisplayname          VARCHAR(250),
  cnegative             CHAR(1)       NOT NULL,
  cdefault              CHAR(1),
  ccontext              VARCHAR(250), -- small to be indexable on SQLServer
  ccustom1              VARCHAR(1000),
  ccustom2              VARCHAR(1000),
  ccustom3              VARCHAR(1000),
  ccustom4              VARCHAR(1000),
  ccustom5              VARCHAR(1000),
  ccustom6              VARCHAR(1000),
  ccustom7              VARCHAR(1000),
  ccustom8              VARCHAR(1000),
  ccustom9              VARCHAR(1000),
  CONSTRAINT imprawrightgrp_uid_pk PRIMARY KEY (crawrightgroupuid, cimportlogfk),
  CONSTRAINT imprawrightgrp_uids_uk UNIQUE (cgroupfk, cpermissionfk, cperimeterfk, cnegative, cimportlogfk),
  CONSTRAINT imprawrightgrp_importlog_fk FOREIGN KEY (cimportlogfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT imprawrightgrp_negative_ck CHECK (cnegative IN ('0', '1')),
  CONSTRAINT imprawrightgrp_default_ck CHECK (cdefault IN ('0', '1'))
);

GO
CREATE TABLE tportalrawrightgroup (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL,
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object permanent key
  crawrightgroupuid     VARCHAR(64)   NOT NULL,
  -- Object information
  crepositoryfk         INTEGER       NOT NULL,
  cgroupfk              INTEGER       NOT NULL,
  cpermissionfk         INTEGER       NOT NULL,
  cperimeterfk          INTEGER,
  crighttype            VARCHAR(32),
  cdisplayname          VARCHAR(250),
  cnegative             CHAR(1)       NOT NULL,
  cdefault              CHAR(1),
  ccontext              VARCHAR(250), -- small to be indexable on SQLServer
  ccustom1              VARCHAR(1000),
  ccustom2              VARCHAR(1000),
  ccustom3              VARCHAR(1000),
  ccustom4              VARCHAR(1000),
  ccustom5              VARCHAR(1000),
  ccustom6              VARCHAR(1000),
  ccustom7              VARCHAR(1000),
  ccustom8              VARCHAR(1000),
  ccustom9              VARCHAR(1000),
  CONSTRAINT prwrightgrp_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT prwrightgrp_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  
  CONSTRAINT prwrightgrp_uid_uk UNIQUE (ctimeslotfk, crawrightgroupuid),
  CONSTRAINT prwrightgrp_negative_ck CHECK (cnegative IN ('0', '1')),
  CONSTRAINT prawrightgrp_default_ck CHECK (cdefault IN ('0', '1'))
);

GO
CREATE INDEX idx_prwrightgrp_uids ON tportalrawrightgroup(cgroupfk, cpermissionfk, cperimeterfk, cnegative);

-- create index on right type in account raw group rights
GO
CREATE INDEX idx_rawrightgrp_type ON trawrightgroup(crighttype);
GO
CREATE INDEX idx_prawrightgrp_type ON tportalrawrightgroup(crighttype);

-- create index on default flag in account raw group rights
GO
CREATE INDEX idx_rawrightgrp_default ON trawrightgroup(cdefault);
GO
CREATE INDEX idx_prawrightgrp_default ON tportalrawrightgroup(cdefault);

-- create index on right context in account raw group rights
GO
CREATE INDEX idx_rawrightgrp_context ON trawrightgroup(ccontext);
GO
CREATE INDEX idx_prawrightgrp_context ON tportalrawrightgroup(ccontext);

-- remove type constraint on ACL
GO
ALTER TABLE timportaclaccount DROP CONSTRAINT importaclaccount_type_ck;
GO
ALTER TABLE timportaclgroup DROP CONSTRAINT importaclgroup_type_ck;
GO
ALTER TABLE taclaccount DROP CONSTRAINT aclaccount_type_ck;
GO
ALTER TABLE taclgroup DROP CONSTRAINT aclgroup_type_ck;
GO
ALTER TABLE tportalaclaccount DROP CONSTRAINT paclaccount_type_ck;
GO
ALTER TABLE tportalaclgroup DROP CONSTRAINT paclgroup_type_ck;

-- add read write and control booleans on all tables containing basic column
GO
ALTER TABLE taclaccount         ADD cread         VARCHAR(1);
GO
ALTER TABLE taclaccount         ADD cwrite        VARCHAR(1);
GO
ALTER TABLE taclaccount         ADD ccontrol      VARCHAR(1);

GO
ALTER TABLE taclaccount         ADD CONSTRAINT aclaccount_read_ck CHECK (cread IN ('0', '1'));
GO
ALTER TABLE taclaccount         ADD CONSTRAINT aclaccount_write_ck CHECK (cwrite IN ('0', '1'));
GO
ALTER TABLE taclaccount         ADD CONSTRAINT aclaccount_control_ck CHECK (ccontrol IN ('0', '1'));

GO
ALTER TABLE taclgroup           ADD cread         VARCHAR(1);
GO
ALTER TABLE taclgroup           ADD cwrite        VARCHAR(1);
GO
ALTER TABLE taclgroup           ADD ccontrol      VARCHAR(1);

GO
ALTER TABLE taclgroup           ADD CONSTRAINT aclgroup_read_ck CHECK (cread IN ('0', '1'));
GO
ALTER TABLE taclgroup           ADD CONSTRAINT aclgroup_write_ck CHECK (cwrite IN ('0', '1'));
GO
ALTER TABLE taclgroup           ADD CONSTRAINT aclgroup_control_ck CHECK (ccontrol IN ('0', '1'));

GO
ALTER TABLE tportalaclaccount   ADD cread         VARCHAR(1);
GO
ALTER TABLE tportalaclaccount   ADD cwrite        VARCHAR(1);
GO
ALTER TABLE tportalaclaccount   ADD ccontrol      VARCHAR(1);

GO
ALTER TABLE tportalaclaccount   ADD CONSTRAINT paclaccount_read_ck CHECK (cread IN ('0', '1'));
GO
ALTER TABLE tportalaclaccount   ADD CONSTRAINT paclaccount_write_ck CHECK (cwrite IN ('0', '1'));
GO
ALTER TABLE tportalaclaccount   ADD CONSTRAINT paclaccount_control_ck CHECK (ccontrol IN ('0', '1'));

GO
ALTER TABLE tportalaclgroup     ADD cread         VARCHAR(1);
GO
ALTER TABLE tportalaclgroup     ADD cwrite        VARCHAR(1);
GO
ALTER TABLE tportalaclgroup     ADD ccontrol      VARCHAR(1);

GO
ALTER TABLE tportalaclgroup     ADD CONSTRAINT paclgroup_read_ck CHECK (cread IN ('0', '1'));
GO
ALTER TABLE tportalaclgroup     ADD CONSTRAINT paclgroup_write_ck CHECK (cwrite IN ('0', '1'));
GO
ALTER TABLE tportalaclgroup     ADD CONSTRAINT paclgroup_control_ck CHECK (ccontrol IN ('0', '1'));

GO
ALTER TABLE tfsrightgroup       ADD cread         VARCHAR(1);
GO
ALTER TABLE tfsrightgroup       ADD cwrite        VARCHAR(1);
GO
ALTER TABLE tfsrightgroup       ADD ccontrol      VARCHAR(1);

GO
ALTER TABLE tfsrightgroup       ADD CONSTRAINT fsrightgroup_read_ck CHECK (cread IN ('0', '1'));
GO
ALTER TABLE tfsrightgroup       ADD CONSTRAINT fsrightgroup_write_ck CHECK (cwrite IN ('0', '1'));
GO
ALTER TABLE tfsrightgroup       ADD CONSTRAINT fsrightgroup_control_ck CHECK (ccontrol IN ('0', '1'));

GO
ALTER TABLE tportalfsrightgroup ADD cread         VARCHAR(1);
GO
ALTER TABLE tportalfsrightgroup ADD cwrite        VARCHAR(1);
GO
ALTER TABLE tportalfsrightgroup ADD ccontrol      VARCHAR(1);

GO
ALTER TABLE tportalfsrightgroup ADD CONSTRAINT pfsrightgroup_read_ck CHECK (cread IN ('0', '1'));
GO
ALTER TABLE tportalfsrightgroup ADD CONSTRAINT pfsrightgroup_write_ck CHECK (cwrite IN ('0', '1'));
GO
ALTER TABLE tportalfsrightgroup ADD CONSTRAINT pfsrightgroup_control_ck CHECK (ccontrol IN ('0', '1'));

GO
DROP VIEW vfsaggregatedright;
GO
CREATE VIEW vfsaggregatedright AS
   SELECT R.ctimeslotfk, R.caction, R.cbasic, R.corder, R.cread, R.cwrite, R.ccontrol, A.caccountfk, R.cpermissionfk
    FROM  tfsrightgroup R
    INNER JOIN tvaccountgroup A ON R.cgroupfk = A.cparentvgroupfk ;

GO
DROP VIEW vportalfsaggregatedright;
GO
CREATE VIEW vportalfsaggregatedright AS
   SELECT R.ctimeslotfk, R.caction,R.cbasic, R.corder, R.cread, R.cwrite, R.ccontrol, A.caccountfk, R.cpermissionfk
    FROM  tportalfsrightgroup R
    INNER JOIN tportalvaccountgroup A ON R.cgroupfk = A.cparentvgroupfk ;

GO
CREATE INDEX idx_aclaccount_read ON taclaccount(cread);
GO
CREATE INDEX idx_aclaccount_write ON taclaccount(cwrite);
GO
CREATE INDEX idx_aclaccount_control ON taclaccount(ccontrol);

GO
CREATE INDEX idx_paclaccount_read ON tportalaclaccount(cread);
GO
CREATE INDEX idx_paclaccount_write ON tportalaclaccount(cwrite);
GO
CREATE INDEX idx_paclaccount_control ON tportalaclaccount(ccontrol);

GO
CREATE INDEX idx_aclgroup_read ON taclgroup(cread);
GO
CREATE INDEX idx_aclgroup_write ON taclgroup(cwrite);
GO
CREATE INDEX idx_aclgroup_control ON taclgroup(ccontrol);

GO
CREATE INDEX idx_paclgroup_read ON tportalaclgroup(cread);
GO
CREATE INDEX idx_paclgroup_write ON tportalaclgroup(cwrite);
GO
CREATE INDEX idx_paclgroup_control ON tportalaclgroup(ccontrol);

GO
CREATE INDEX idx_fsrightgroup_read ON tfsrightgroup(cread);
GO
CREATE INDEX idx_fsrightgroup_write ON tfsrightgroup(cwrite);
GO
CREATE INDEX idx_fsrightgroup_control ON tfsrightgroup(ccontrol);

GO
CREATE INDEX idx_pfsrightgroup_read ON tportalfsrightgroup(cread);
GO
CREATE INDEX idx_pfsrightgroup_write ON tportalfsrightgroup(cwrite);
GO
CREATE INDEX idx_pfsrightgroup_control ON tportalfsrightgroup(ccontrol);

GO
ALTER TABLE tcompliancereport DROP CONSTRAINT compliancereport_cstatus_ck;

-- Upgrade script to version 32
-- --------


GO
ALTER TABLE tmetadatavalue ADD cvalue3string         VARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue4string         VARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue5string         VARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue6string         VARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue7string         VARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue8string         VARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue9string         VARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue10string        VARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue11string        VARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue12string        VARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue13string        VARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue14string        VARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue15string        VARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue16string        VARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue17string        VARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue18string        VARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue19string        VARCHAR(2000);
GO
ALTER TABLE tmetadatavalue ADD cvalue20string        VARCHAR(2000);
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
ALTER TABLE timportmetadatavalue ADD cvalue3string         VARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue4string         VARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue5string         VARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue6string         VARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue7string         VARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue8string         VARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue9string         VARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue10string        VARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue11string        VARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue12string        VARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue13string        VARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue14string        VARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue15string        VARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue16string        VARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue17string        VARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue18string        VARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue19string        VARCHAR(2000);
GO
ALTER TABLE timportmetadatavalue ADD cvalue20string        VARCHAR(2000);
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
ALTER TABLE tportalmetadatavalue ADD cvalue3string         VARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue4string         VARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue5string         VARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue6string         VARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue7string         VARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue8string         VARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue9string         VARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue10string        VARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue11string        VARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue12string        VARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue13string        VARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue14string        VARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue15string        VARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue16string        VARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue17string        VARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue18string        VARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue19string        VARCHAR(2000);
GO
ALTER TABLE tportalmetadatavalue ADD cvalue20string        VARCHAR(2000);
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
ALTER TABLE tactivitypair ALTER COLUMN coperator VARCHAR(16);



GO
ALTER TABLE timportactivitypair ALTER COLUMN coperator VARCHAR(16);



GO
ALTER TABLE tportalactivitypair ALTER COLUMN coperator VARCHAR(16);




GO
CREATE TABLE tuservariable (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  IDENTITY (1, 1)  ,
  cowneruid             VARCHAR(250)  NOT NULL,
  cname                 VARCHAR(250)  NOT NULL,
  ccontent              VARCHAR(MAX),
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
ALTER TABLE tmanager ADD cindirect                       CHAR(1);

GO
ALTER TABLE tmanagerrule ADD cmanagedidentityfk          INTEGER;

GO
ALTER TABLE timportmanagerrule ADD cmanagedidentityfk    VARCHAR(64);


GO
ALTER TABLE timportmanager ADD cmanagedidentityfk        VARCHAR(64);
GO
ALTER TABLE timportmanager ADD cindirect                 CHAR(1);

GO
ALTER TABLE tportalmanager ADD cmanagedidentityfk        INTEGER;
GO
ALTER TABLE tportalmanager ADD cindirect                 CHAR(1);

GO
ALTER TABLE tportalmanagerrule ADD cmanagedidentityfk    INTEGER;

GO
CREATE INDEX idx_managerrule_mngdidnt ON tmanagerrule(cmanagedidentityfk);

-- IDNTMANAGERREVIEW table
GO
CREATE TABLE tidntmanagerreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
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
  ctimeslotfk           VARCHAR(64)   NOT NULL,
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
ALTER TABLE tuserdata ALTER COLUMN cbody VARCHAR(MAX);
  GO
ALTER TABLE tcampaignvariables ALTER COLUMN cvariables VARCHAR(MAX);
  
  
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
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cconfitemuid          VARCHAR(64)   NOT NULL,
  cfamily               VARCHAR(100)  NOT NULL,
  ctype                 VARCHAR(100)  NOT NULL,
  cenvironment          VARCHAR(100),
  ccode                 VARCHAR(1000) NOT NULL,
  cdisplayname          VARCHAR(1000),
  cdescription          VARCHAR(4000),
  cdn                   VARCHAR(500),
  ccanonicalname        VARCHAR(500),
  ccountrycode          VARCHAR(20),
  cruntimename          VARCHAR(100),
  cruntimeversion       VARCHAR(100),
  cdnsname              VARCHAR(150),
  cipv4address          VARCHAR(15),
  cipv6address          VARCHAR(50),
  cenabled              CHAR(1),
  cstate                VARCHAR(50),
  carch                 VARCHAR(50),
  cnbcputhreads         INTEGER,
  cmemorysize           INTEGER,
  callocatedstorage     INTEGER,
  cstorageencrypted     CHAR(1),
  curn                  VARCHAR(200),
  ccriticalobject        CHAR(1),
  ccreationdate         VARCHAR(15),
  ccreationday          INTEGER,
  cmodifydate           VARCHAR(15),
  cmodifyday            INTEGER,
  cpasswordnotrequired  CHAR(1),
  cpasswordneverexpires CHAR(1),
  cpasswordexpired      CHAR(1),
  clogoncount           INTEGER,
  clastlogondate        VARCHAR(15),
  clastlogonday         INTEGER,
  cbadlogoncount        INTEGER,
  clastbadpassworddate  VARCHAR(15),
  clastbadpasswordday   INTEGER,
  cpasswordlastsetdate  VARCHAR(15),
  cpasswordlastsetday   INTEGER,
  cdetails              VARCHAR(MAX),
  caddress              VARCHAR(1000),
  clocationfk           BIGINT,
  cimportaction         CHAR(1)       NOT NULL,
  cdeletedaction        CHAR(1),
  CONSTRAINT confitem_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT confitem_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT confitem_uid_uk UNIQUE (ctimeslotfk, cconfitemuid)
);



GO
CREATE TABLE tconfitemlink (
  -- Database primary key
  crecorduid            BIGINT NOT NULL IDENTITY (1, 1),
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cconfitemlinkuid      VARCHAR(64)   NOT NULL,
  corigin               CHAR(1)       NOT NULL,
  cjointypes            VARCHAR(32)   NOT NULL,
  csemantic             VARCHAR(1000),
  cdescription          VARCHAR(4000),
  cindirect             CHAR(1)       NOT NULL,
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
  cimportlogfk          VARCHAR(64)   NOT NULL,
  -- Object information
  cconfitemuid          VARCHAR(64)   NOT NULL,
  csilofk               VARCHAR(64),
  cfamily               VARCHAR(100)  NOT NULL,
  ctype                 VARCHAR(100)  NOT NULL,
  cenvironment          VARCHAR(100),
  ccode                 VARCHAR(1000) NOT NULL,
  cdisplayname          VARCHAR(1000),
  cdescription          VARCHAR(4000),
  cdn                   VARCHAR(500),
  ccanonicalname        VARCHAR(500),
  ccountrycode          VARCHAR(20),
  cruntimename          VARCHAR(100),
  cruntimeversion       VARCHAR(100),
  cdnsname              VARCHAR(150),
  cipv4address          VARCHAR(15),
  cipv6address          VARCHAR(50),
  cenabled              CHAR(1),
  cstate                VARCHAR(50),
  carch                 VARCHAR(50),
  cnbcputhreads         INTEGER,
  cmemorysize           INTEGER,
  callocatedstorage     INTEGER,
  cstorageencrypted     CHAR(1),
  curn                  VARCHAR(200),
  ccriticalobject        CHAR(1),
  ccreationdate         VARCHAR(15),
  ccreationday          INTEGER,
  cmodifydate           VARCHAR(15),
  cmodifyday            INTEGER,
  cpasswordnotrequired  CHAR(1),
  cpasswordneverexpires CHAR(1),
  cpasswordexpired      CHAR(1),
  clogoncount           INTEGER,
  clastlogondate        VARCHAR(15),
  clastlogonday         INTEGER,
  cbadlogoncount        INTEGER,
  clastbadpassworddate  VARCHAR(15),
  clastbadpasswordday   INTEGER,
  cpasswordlastsetdate  VARCHAR(15),
  cpasswordlastsetday   INTEGER,
  cdetails              VARCHAR(MAX),
  caddress              VARCHAR(1000),
  clocationuid          VARCHAR(64),
  cimportaction         CHAR(1)       NOT NULL,
  CONSTRAINT importconfitem_uid_pk PRIMARY KEY (cconfitemuid, cimportlogfk),
  CONSTRAINT importconfitem_timeslot_fk FOREIGN KEY (cimportlogfk) REFERENCES timportlog(cimportloguid)
);

GO
CREATE TABLE timportconfitemlink (
  cimportlogfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cconfitemlinkuid      VARCHAR(64)   NOT NULL,
  csilofk               VARCHAR(64),
  corigin               CHAR(1)       NOT NULL,
  cjointypes            VARCHAR(32)   NOT NULL,
  csemantic             VARCHAR(1000),
  cdescription          VARCHAR(4000),
  csourceconfitemfk     VARCHAR(64),
  csourcerepofk         VARCHAR(64),
  csourceapplifk        VARCHAR(64),
  csourceaccountfk      VARCHAR(64),
  csourceidentityfk     VARCHAR(64),
  csourceorgfk          VARCHAR(64),
  ctargetconfitemfk     VARCHAR(64),
  ctargetrepofk         VARCHAR(64),
  ctargetapplifk        VARCHAR(64),
  ctargetaccountfk      VARCHAR(64),
  ctargetidentityfk     VARCHAR(64),
  ctargetorgfk          VARCHAR(64),
  CONSTRAINT importconfitemlink_uid_pk PRIMARY KEY (cconfitemlinkuid, cimportlogfk),
  CONSTRAINT importconfitemlink_timeslot_fk FOREIGN KEY (cimportlogfk) REFERENCES timportlog(cimportloguid)
);

GO
CREATE TABLE tportalconfitem (
  -- Database primary key
  crecorduid            BIGINT NOT NULL,
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cconfitemuid          VARCHAR(64)   NOT NULL,
  cfamily               VARCHAR(100)  NOT NULL,
  ctype                 VARCHAR(100)  NOT NULL,
  cenvironment          VARCHAR(100),
  ccode                 VARCHAR(1000) NOT NULL,
  cdisplayname          VARCHAR(1000),
  cdescription          VARCHAR(4000),
  cdn                   VARCHAR(500),
  ccanonicalname        VARCHAR(500),
  ccountrycode          VARCHAR(20),
  cruntimename          VARCHAR(100),
  cruntimeversion       VARCHAR(100),
  cdnsname              VARCHAR(150),
  cipv4address          VARCHAR(15),
  cipv6address          VARCHAR(50),
  cenabled              CHAR(1),
  cstate                VARCHAR(50),
  carch                 VARCHAR(50),
  cnbcputhreads         INTEGER,
  cmemorysize           INTEGER,
  callocatedstorage     INTEGER,
  cstorageencrypted     CHAR(1),
  curn                  VARCHAR(200),
  ccriticalobject        CHAR(1),
  ccreationdate         VARCHAR(15),
  ccreationday          INTEGER,
  cmodifydate           VARCHAR(15),
  cmodifyday            INTEGER,
  cpasswordnotrequired  CHAR(1),
  cpasswordneverexpires CHAR(1),
  cpasswordexpired      CHAR(1),
  clogoncount           INTEGER,
  clastlogondate        VARCHAR(15),
  clastlogonday         INTEGER,
  cbadlogoncount        INTEGER,
  clastbadpassworddate  VARCHAR(15),
  clastbadpasswordday   INTEGER,
  cpasswordlastsetdate  VARCHAR(15),
  cpasswordlastsetday   INTEGER,
  cdetails              VARCHAR(MAX),
  caddress              VARCHAR(1000),
  clocationfk           BIGINT,
  cimportaction         CHAR(1)       NOT NULL,
  cdeletedaction        CHAR(1),
  CONSTRAINT pconfitem_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT pconfitem_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT pconfitem_uid_uk UNIQUE (ctimeslotfk, cconfitemuid)
);

GO
CREATE TABLE tportalconfitemlink (
  -- Database primary key
  crecorduid            BIGINT NOT NULL,
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cconfitemlinkuid      VARCHAR(64)   NOT NULL,
  corigin               CHAR(1)       NOT NULL,
  cjointypes            VARCHAR(32)   NOT NULL,
  csemantic             VARCHAR(1000),
  cdescription          VARCHAR(4000),
  cindirect             CHAR(1)       NOT NULL,
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
ALTER TABLE tmetadatavalue ADD cvalueconfitemuid VARCHAR(64);
GO
ALTER TABLE tmetadatavalue ADD cvalueconfitemfk BIGINT;

GO
ALTER TABLE tmetadata ADD csearchlogfk BIGINT;
GO
ALTER TABLE tmetadata ADD csearchloguid VARCHAR(250);
GO
ALTER TABLE tmetadatavalue ADD cvaluesearchlogfk BIGINT;
GO
ALTER TABLE tmetadatavalue ADD cvaluesearchloguid VARCHAR(250);

GO
CREATE INDEX idx_metadata_confitem ON tmetadata(cconfitemfk);
GO
CREATE INDEX idx_metadatav_confitem ON tmetadatavalue(cmetadatafk,cvalueconfitemfk);

GO
CREATE INDEX idx_metadata_searchlog ON tmetadata(csearchlogfk);
GO
CREATE INDEX idx_metadatav_searchlog ON tmetadatavalue(cmetadatafk,cvaluesearchlogfk);

GO
ALTER TABLE timportmetadata ADD cconfitemfk VARCHAR(64);
GO
ALTER TABLE timportmetadatavalue ADD cvalueconfitemfk VARCHAR(64);

GO
ALTER TABLE tportalmetadata ADD cconfitemfk BIGINT;
GO
ALTER TABLE tportalmetadatavalue ADD cvalueconfitemuid VARCHAR(64);
GO
ALTER TABLE tportalmetadatavalue ADD cvalueconfitemfk BIGINT;

GO
ALTER TABLE tportalmetadata ADD csearchlogfk BIGINT;
GO
ALTER TABLE tportalmetadata ADD csearchloguid VARCHAR(250);
GO
ALTER TABLE tportalmetadatavalue ADD cvaluesearchlogfk BIGINT;
GO
ALTER TABLE tportalmetadatavalue ADD cvaluesearchloguid VARCHAR(250);

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
  cname                 VARCHAR(250) NOT NULL,
  cdescription          VARCHAR(4000),
  cdeadline             VARCHAR(15),
  CONSTRAINT pamprogram_uid_pk PRIMARY KEY (crecorduid)
);



GO
CREATE TABLE tpamscope (
  -- Database primary key
  crecorduid            BIGINT NOT NULL IDENTITY (1, 1),
  -- Object information
  cprogramfk            BIGINT NOT NULL,
  cname                 VARCHAR(250) NOT NULL,
  cdescription          VARCHAR(4000),
  cstartdate            VARCHAR(15),
  cdeadline             VARCHAR(15),
  cstatus               VARCHAR(100),
  ctimeslotuid          VARCHAR(64),
  cimportance           INTEGER,
  crequestoruid         VARCHAR(64),
  crequestorfullname    VARCHAR(250),
  CONSTRAINT pamscope_uid_pk PRIMARY KEY (crecorduid)
);



GO
CREATE TABLE tpamscopeincl (
  -- Database primary key
  crecorduid            BIGINT NOT NULL IDENTITY (1, 1),
  -- Object information
  cscopefk              BIGINT NOT NULL,
  ctype                 CHAR(1)       NOT NULL,
  ctitle                VARCHAR(1000) NOT NULL,
  cruleid               VARCHAR(250),
  capplications         VARCHAR(MAX),
  cconfitems            VARCHAR(MAX),
  crepositories         VARCHAR(MAX),
  CONSTRAINT pamscopeincl_uid_pk PRIMARY KEY (crecorduid)
);



GO
CREATE TABLE tpammilestone (
  -- Database primary key
  crecorduid            BIGINT NOT NULL IDENTITY (1, 1),
  -- Object information
  cprogramfk            BIGINT,
  cscopefk              BIGINT,
  cname                 VARCHAR(250),
  cdeadline             VARCHAR(15),
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
  ctimeslotfk           VARCHAR(64)   NOT NULL,
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
  ctimeslotfk           VARCHAR(64)   NOT NULL,
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
  ctimeslotfk           VARCHAR(64)   NOT NULL,
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
  ctimeslotfk           VARCHAR(64)   NOT NULL,
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
