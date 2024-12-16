/* 
COPYRIGHT BRAINWAVE, all rights reserved.
This computer program is protected by copyright law and international treaties.
Unauthorized duplication or distribution of this program, or any portion of it, may result in severe civil or criminal penalties, and will be prosecuted to the maximum extent possible under the law.

Usage: Upgrades The database schema from version 2017 R3 to Curie R1

(c) Radiant Logic 2021

Usage
```
sqlplus <username>/<password>@<connect_identifier> @<Absolute Path to file>/oracle_XXXX_to_Curie.sql
```

where:
- `<username>` is the schema on which to execute the upgrade
- `<password>` is the users password
- `<connect_identifier>` is the Oracle Net database alias (@connect_identifier) of the database you want to connect to

For more information on SQLplus usage please refer to Oracle's documentation:
https://docs.oracle.com/cd/A97630_01/server.920/a90842/qstart.htm
*/

-- Upgrade script to version 31
-- --------

-- Upgrade database from version 30 to version 31

-- add progress status in timportlog to follow the fine grained operation and prevent from starting the same one a second time
ALTER TABLE timportlog ADD cprogressstatus          VARCHAR2(64 CHAR);
ALTER TABLE timportlog ADD clastprogressdate        VARCHAR(15);
ALTER TABLE timportlog ADD clastprogressday         INTEGER;

-- expand reason in exception table


ALTER TABLE texception MODIFY (creason VARCHAR2(4000 CHAR));

-- expand reason in exception portal table


ALTER TABLE tportalexception MODIFY (creason VARCHAR2(4000 CHAR));

-- add columns in ticketlog to handle the on-hold feature
ALTER TABLE tticketlog ADD cnbreleasedsubproc       INTEGER;
ALTER TABLE tticketlog ADD cnbonholdsubproc         INTEGER;
ALTER TABLE tticketlog ADD cnbcandidates            INTEGER;
ALTER TABLE tticketlog ADD ccandidatefullnames      VARCHAR2(4000 CHAR);

-- add columns to handle 
CREATE INDEX idx_account_sid ON taccount(csid);

-- indexes to speed up the search in history for account at collect time
CREATE INDEX idx_repository_repotype ON trepository(crepositorytype, ctimeslotfk, crecorduid);
CREATE INDEX idx_account_guidrepo on taccount (cguid,crepositoryfk,caccountuid);

-- indexes to speed up the renew of reconciliation review tickets
CREATE INDEX idx_ticketreview_creviewtype ON tticketreview(creviewtype);

CREATE INDEX idx_ppermissionlink_parentp on tportalpermissionlink (cparentpermissionfk,cpermissionfk);

-- add missing import table acl changes
-- taclaccount, taclgroup, tfsrightgroup, tportalaclaccount, tportalaclgroup, tportalfsrightgroup


ALTER TABLE timportaclaccount MODIFY (caction VARCHAR2(40 CHAR));


ALTER TABLE timportaclgroup MODIFY (caction VARCHAR2(40 CHAR));

ALTER TABLE tticketaction ADD creviewerfk           INTEGER;
ALTER TABLE tticketaction ADD crevieweruid          VARCHAR(64);
ALTER TABLE tticketaction ADD creviewerfullname     VARCHAR2(96 CHAR);
ALTER TABLE tticketaction ADD caccountablefk        INTEGER;
ALTER TABLE tticketaction ADD caccountableuid       VARCHAR(64);
ALTER TABLE tticketaction ADD caccountablefullname  VARCHAR2(96 CHAR);
ALTER TABLE tticketaction ADD ccategory             VARCHAR2(250 CHAR);
ALTER TABLE tticketaction ADD cworkloadtime         INTEGER;

ALTER TABLE tticketreview DROP CONSTRAINT ticketreview_type_ck;
ALTER TABLE tticketreview ADD cmetadatauid          VARCHAR(64);
ALTER TABLE tticketreview ADD cparentgroupuid       VARCHAR(64);
ALTER TABLE tticketreview ADD cparentpermuid        VARCHAR(64);
ALTER TABLE tticketreview ADD cactorfk              INTEGER;
ALTER TABLE tticketreview ADD cactoruid             VARCHAR(64);
ALTER TABLE tticketreview ADD cactorfullname        VARCHAR2(96 CHAR);
ALTER TABLE tticketreview ADD caccountablefk        INTEGER;
ALTER TABLE tticketreview ADD caccountableuid       VARCHAR(64);
ALTER TABLE tticketreview ADD caccountablefullname  VARCHAR2(96 CHAR);
ALTER TABLE tticketreview ADD cactiondate           VARCHAR(15);
ALTER TABLE tticketreview ADD cactionday            INTEGER;
ALTER TABLE tticketreview ADD cvalidfromdate        VARCHAR(15);
ALTER TABLE tticketreview ADD cvalidfromday         INTEGER;
ALTER TABLE tticketreview ADD cvalidtodate          VARCHAR(15);
ALTER TABLE tticketreview ADD cvalidtoday           INTEGER;

UPDATE tticketaction SET creviewerfk=cactorfk, crevieweruid=cactoruid, creviewerfullname=cactorfullname, caccountablefk=cactorfk, caccountableuid=cactoruid, caccountablefullname=cactorfullname WHERE cdelegateeuid IS NULL;
UPDATE tticketaction SET creviewerfk=cdelegateefk, crevieweruid=cdelegateeuid, creviewerfullname=cdelegateefullname, caccountablefk=cactorfk, caccountableuid=cactoruid, caccountablefullname=cactorfullname WHERE cdelegateeuid IS NOT NULL;

-- METADATAREVIEW table
CREATE TABLE tmetadatareview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  cmetadatafk           INTEGER       NOT NULL,
  CONSTRAINT metadatareview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

ALTER TABLE tmetadata ADD csubkey VARCHAR(64);
ALTER TABLE tmetadata ADD cmastermetadatafk INTEGER;
ALTER TABLE tmetadata ADD ccharacteristic CHAR(1);
ALTER TABLE tmetadata ADD cactorfk INTEGER;
ALTER TABLE tmetadata ADD cactoruid VARCHAR(64);
ALTER TABLE tmetadata ADD cactorfullname VARCHAR2(96 CHAR);
ALTER TABLE tmetadata ADD CONSTRAINT metadata_charact_ck CHECK (ccharacteristic IN ('0', '1'));
ALTER TABLE tmetadata DROP CONSTRAINT metadata_origin_ck;
ALTER TABLE tmetadata DROP CONSTRAINT metadata_boolean_ck;

-- METADATA table
CREATE SEQUENCE metadatavalue_sequence;
CREATE TABLE tmetadatavalue (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL      ,
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object permanent key
  cmetadatafk           INTEGER       NOT NULL,
  -- Object information
  cvalue1string         VARCHAR2(300 CHAR),
  cvalue2string         VARCHAR2(300 CHAR),
  cvalue1integer        INTEGER,
  cvalue2integer        INTEGER,
  cvalue1double         DOUBLE PRECISION,
  cvalue2double         DOUBLE PRECISION,
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
  cdetails              CLOB,
  CONSTRAINT metadatavalue_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT metadatavalue_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT metadatavalue_boolean_ck CHECK (cvalueboolean IN ('0', '1'))
);

CREATE OR REPLACE TRIGGER metadatavalue_uid_tr BEFORE INSERT ON tmetadatavalue
FOR EACH ROW
BEGIN
  IF :new.crecorduid IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'CRECORDUID cannot be specified for TMETADATAVALUE');
  ELSE
    SELECT metadatavalue_sequence.NEXTVAL
    INTO   :new.crecorduid
    FROM   dual;
  END IF;
END;
/



DROP INDEX idx_metadata_value1string;
DROP INDEX idx_metadata_value2string;
DROP INDEX idx_metadata_value1integer;
DROP INDEX idx_metadata_value2integer;
DROP INDEX idx_metadata_value1double;
DROP INDEX idx_metadata_value2double;
DROP INDEX idx_metadata_value1date;
DROP INDEX idx_metadata_value1day;
DROP INDEX idx_metadata_value2date;
DROP INDEX idx_metadata_value2day;
DROP INDEX idx_metadata_valueboolean;



CREATE INDEX idx_metadatav_value1string ON tmetadatavalue(cmetadatafk,cvalue1string);
CREATE INDEX idx_metadatav_value2string ON tmetadatavalue(cmetadatafk,cvalue2string);
CREATE INDEX idx_metadatav_value1integer ON tmetadatavalue(cmetadatafk,cvalue1integer);
CREATE INDEX idx_metadatav_value2integer ON tmetadatavalue(cmetadatafk,cvalue2integer);
CREATE INDEX idx_metadatav_value1double ON tmetadatavalue(cmetadatafk,cvalue1double);
CREATE INDEX idx_metadatav_value2double ON tmetadatavalue(cmetadatafk,cvalue2double);
CREATE INDEX idx_metadatav_value1date ON tmetadatavalue(cmetadatafk,cvalue1date);
CREATE INDEX idx_metadatav_value1day ON tmetadatavalue(cmetadatafk,cvalue1day);
CREATE INDEX idx_metadatav_value2date ON tmetadatavalue(cmetadatafk,cvalue2date);
CREATE INDEX idx_metadatav_value2day ON tmetadatavalue(cmetadatafk,cvalue2day);
CREATE INDEX idx_metadatav_valueboolean ON tmetadatavalue(cmetadatafk,cvalueboolean);
CREATE INDEX idx_metadatav_organisation ON tmetadatavalue(cmetadatafk,cvalueorganisationfk);
CREATE INDEX idx_metadatav_identity ON tmetadatavalue(cmetadatafk,cvalueidentityfk);
CREATE INDEX idx_metadatav_repository ON tmetadatavalue(cmetadatafk,cvaluerepositoryfk);
CREATE INDEX idx_metadatav_group ON tmetadatavalue(cmetadatafk,cvaluegroupfk);
CREATE INDEX idx_metadatav_account ON tmetadatavalue(cmetadatafk,cvalueaccountfk);
CREATE INDEX idx_metadatav_perimeter ON tmetadatavalue(cmetadatafk,cvalueperimeterfk);
CREATE INDEX idx_metadatav_permission ON tmetadatavalue(cmetadatafk,cvaluepermissionfk);
CREATE INDEX idx_metadatav_application ON tmetadatavalue(cmetadatafk,cvalueapplicationfk);
CREATE INDEX idx_metadatav_asset ON tmetadatavalue(cmetadatafk,cvalueassetfk);

ALTER TABLE timportmetadata ADD csubkey VARCHAR(64);
ALTER TABLE timportmetadata ADD cmastermetadatafk VARCHAR(64);
ALTER TABLE timportmetadata ADD ccharacteristic CHAR(1);
ALTER TABLE timportmetadata ADD CONSTRAINT importmetadata_charact_ck CHECK (ccharacteristic IN ('0', '1'));
ALTER TABLE timportmetadata DROP CONSTRAINT importmetadata_origin_ck;
ALTER TABLE timportmetadata DROP CONSTRAINT importmetadata_boolean_ck;

-- IMPORTMETADATA table
CREATE TABLE timportmetadatavalue (
  -- Sandbox (part of the primary key)
  cimportlogfk          VARCHAR(64)   NOT NULL,
  -- Object permanent key
  cmetadatauid          VARCHAR(64)   NOT NULL,
  -- Object information
  csilofk               VARCHAR(64),
  cvalue1string         VARCHAR2(300 CHAR),
  cvalue2string         VARCHAR2(300 CHAR),
  cvalue1integer        INTEGER,
  cvalue2integer        INTEGER,
  cvalue1double         DOUBLE PRECISION,
  cvalue2double         DOUBLE PRECISION,
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
  cdetails              CLOB,
  CONSTRAINT importmetadatav_importlog_fk FOREIGN KEY (cimportlogfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT importmetadatav_boolean_ck CHECK (cvalueboolean IN ('0', '1'))
);

-- PORTALMETADATAREVIEW table
CREATE TABLE tportalmetadatareview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  cmetadatafk           INTEGER       NOT NULL,
  CONSTRAINT pmetadatareview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

ALTER TABLE tportalmetadata ADD csubkey VARCHAR(64);
ALTER TABLE tportalmetadata ADD cmastermetadatafk INTEGER;
ALTER TABLE tportalmetadata ADD ccharacteristic CHAR(1);
ALTER TABLE tportalmetadata ADD cactorfk INTEGER;
ALTER TABLE tportalmetadata ADD cactoruid VARCHAR(64);
ALTER TABLE tportalmetadata ADD cactorfullname VARCHAR2(96 CHAR);
ALTER TABLE tportalmetadata ADD CONSTRAINT pmetadata_charact_ck CHECK (ccharacteristic IN ('0', '1'));
ALTER TABLE tportalmetadata DROP CONSTRAINT pmetadata_origin_ck;
ALTER TABLE tportalmetadata DROP CONSTRAINT pmetadata_boolean_ck;

CREATE TABLE tportalmetadatavalue (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL,
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object permanent key
  cmetadatafk           INTEGER       NOT NULL,
  -- Object information
  cvalue1string         VARCHAR2(300 CHAR),
  cvalue2string         VARCHAR2(300 CHAR),
  cvalue1integer        INTEGER,
  cvalue2integer        INTEGER,
  cvalue1double         DOUBLE PRECISION,
  cvalue2double         DOUBLE PRECISION,
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
  cdetails              CLOB,
  CONSTRAINT pmetadatavalue_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT pmetadatavalue_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT pmetadatavalue_boolean_ck CHECK (cvalueboolean IN ('0', '1'))
);

-- ACCOUNTGROUPREVIEW table
CREATE TABLE taccountgroupreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  caccountgroupfk       INTEGER       NOT NULL,
  CONSTRAINT accountgroupreview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- PORTALACCOUNTGROUPREVIEW table
CREATE TABLE tportalaccountgroupreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  caccountgroupfk       INTEGER       NOT NULL,
  CONSTRAINT paccountgroupreview_ts_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- GROUPLINKREVIEW table
CREATE TABLE tgrouplinkreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  cgrouplinkfk          INTEGER       NOT NULL,
  CONSTRAINT grouplinkreview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- PORTALGROUPLINKREVIEW table
CREATE TABLE tportalgrouplinkreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  cgrouplinkfk              INTEGER       NOT NULL,
  CONSTRAINT pgrouplinkreview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- PERMLINKREVIEW table
CREATE TABLE tpermlinkreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  cpermlinkfk           INTEGER       NOT NULL,
  CONSTRAINT permlinkreview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- PortalPERMLINKREVIEW table
CREATE TABLE tportalpermlinkreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  cpermlinkfk           INTEGER       NOT NULL,
  CONSTRAINT ppermlinkreview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- RAWPERMLINKREVIEW table
CREATE TABLE trawpermlinkreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  crawpermlinkfk         INTEGER       NOT NULL,
  CONSTRAINT rawpermlinkreview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- PORTALRAWPERMLINKREVIEW table
CREATE TABLE tportalrawpermlinkreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  crawpermlinkfk         INTEGER       NOT NULL,
  CONSTRAINT prawpermlinkreview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- RAWRIGHTREVIEW table
CREATE TABLE trawrightreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  crawrightfk           INTEGER       NOT NULL,
  CONSTRAINT rawrightreview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- PORTALRAWRIGHTREVIEW table
CREATE TABLE tportalrawrightreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  crawrightfk           INTEGER       NOT NULL,
  CONSTRAINT prawrightreview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- RAWRIGHTGROUPREVIEW table
CREATE TABLE trawrightgroupreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  crawrightgroupfk      INTEGER       NOT NULL,
  CONSTRAINT rawrightgrpreview_ts_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- PORTALRAWRIGHTGROUPREVIEW table
CREATE TABLE tportalrawrightgroupreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  crawrightgroupfk      INTEGER       NOT NULL,
  CONSTRAINT prawrightgrpreview_ts_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- PERMGROUP review table
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
CREATE TABLE tportalpermgroupreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  cgroupfk              INTEGER       NOT NULL,
  cpermissionfk         INTEGER       NOT NULL,
  CONSTRAINT ppermgroupreview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);


DROP INDEX idx_pmetadata_value1string;
DROP INDEX idx_pmetadata_value2string;
DROP INDEX idx_pmetadata_value1integer;
DROP INDEX idx_pmetadata_value2integer;
DROP INDEX idx_pmetadata_value1double;
DROP INDEX idx_pmetadata_value2double;
DROP INDEX idx_pmetadata_value1date;
DROP INDEX idx_pmetadata_value1day;
DROP INDEX idx_pmetadata_value2date;
DROP INDEX idx_pmetadata_value2day;
DROP INDEX idx_pmetadata_valueboolean;



CREATE INDEX idx_pmetadatav_value1string ON tportalmetadatavalue(cmetadatafk,cvalue1string);
CREATE INDEX idx_pmetadatav_value2string ON tportalmetadatavalue(cmetadatafk,cvalue2string);
CREATE INDEX idx_pmetadatav_value1integer ON tportalmetadatavalue(cmetadatafk,cvalue1integer);
CREATE INDEX idx_pmetadatav_value2integer ON tportalmetadatavalue(cmetadatafk,cvalue2integer);
CREATE INDEX idx_pmetadatav_value1double ON tportalmetadatavalue(cmetadatafk,cvalue1double);
CREATE INDEX idx_pmetadatav_value2double ON tportalmetadatavalue(cmetadatafk,cvalue2double);
CREATE INDEX idx_pmetadatav_value1date ON tportalmetadatavalue(cmetadatafk,cvalue1date);
CREATE INDEX idx_pmetadatav_value1day ON tportalmetadatavalue(cmetadatafk,cvalue1day);
CREATE INDEX idx_pmetadatav_value2date ON tportalmetadatavalue(cmetadatafk,cvalue2date);
CREATE INDEX idx_pmetadatav_value2day ON tportalmetadatavalue(cmetadatafk,cvalue2day);
CREATE INDEX idx_pmetadatav_valueboolean ON tportalmetadatavalue(cmetadatafk,cvalueboolean);
CREATE INDEX idx_pmetadatav_organisation ON tportalmetadatavalue(cmetadatafk,cvalueorganisationfk);
CREATE INDEX idx_pmetadatav_identity ON tportalmetadatavalue(cmetadatafk,cvalueidentityfk);
CREATE INDEX idx_pmetadatav_repository ON tportalmetadatavalue(cmetadatafk,cvaluerepositoryfk);
CREATE INDEX idx_pmetadatav_group ON tportalmetadatavalue(cmetadatafk,cvaluegroupfk);
CREATE INDEX idx_pmetadatav_account ON tportalmetadatavalue(cmetadatafk,cvalueaccountfk);
CREATE INDEX idx_pmetadatav_perimeter ON tportalmetadatavalue(cmetadatafk,cvalueperimeterfk);
CREATE INDEX idx_pmetadatav_permission ON tportalmetadatavalue(cmetadatafk,cvaluepermissionfk);
CREATE INDEX idx_pmetadatav_application ON tportalmetadatavalue(cmetadatafk,cvalueapplicationfk);
CREATE INDEX idx_pmetadatav_asset ON tportalmetadatavalue(cmetadatafk,cvalueassetfk);

CREATE INDEX idx_metadatarev_timeslot ON tmetadatareview(ctimeslotfk);
CREATE INDEX idx_metadatarev_ticket ON tmetadatareview(cticketreviewfk);
CREATE INDEX idx_metadatarev ON tmetadatareview(cmetadatafk);

CREATE INDEX idx_pmetadatarev_timeslot ON tportalmetadatareview(ctimeslotfk);
CREATE INDEX idx_pmetadatarev_ticket ON tportalmetadatareview(cticketreviewfk);
CREATE INDEX idx_pmetadatarev ON tportalmetadatareview(cmetadatafk);

INSERT INTO tmetadatavalue(ctimeslotfk,cmetadatafk,cvalue1string,cvalue2string,cvalue1integer,cvalue2integer,cvalue1double,cvalue2double,cvalue1date,cvalue1day,cvalue2date,cvalue2day,cvalueboolean,cdetails)
	SELECT ctimeslotfk,crecorduid,cvalue1string,cvalue2string,cvalue1integer,cvalue2integer,cvalue1double,cvalue2double,cvalue1date,cvalue1day,cvalue2date,cvalue2day,cvalueboolean,cdetails
	FROM tmetadata;

ALTER TABLE tmetadata DROP COLUMN cvalue1string;
ALTER TABLE tmetadata DROP COLUMN cvalue2string;
ALTER TABLE tmetadata DROP COLUMN cvalue1integer;
ALTER TABLE tmetadata DROP COLUMN cvalue2integer;
ALTER TABLE tmetadata DROP COLUMN cvalue1double;
ALTER TABLE tmetadata DROP COLUMN cvalue2double;
ALTER TABLE tmetadata DROP COLUMN cvalue1date;
ALTER TABLE tmetadata DROP COLUMN cvalue1day;
ALTER TABLE tmetadata DROP COLUMN cvalue2date;
ALTER TABLE tmetadata DROP COLUMN cvalue2day;
ALTER TABLE tmetadata DROP COLUMN cvalueboolean;
ALTER TABLE tmetadata DROP COLUMN cdetails;

INSERT INTO tportalmetadatavalue(crecorduid,ctimeslotfk,cmetadatafk,cvalue1string,cvalue2string,cvalue1integer,cvalue2integer,cvalue1double,cvalue2double,cvalue1date,cvalue1day,cvalue2date,cvalue2day,cvalueboolean,cdetails)
	SELECT mv.crecorduid,mv.ctimeslotfk,pm.crecorduid,mv.cvalue1string,mv.cvalue2string,mv.cvalue1integer,mv.cvalue2integer,mv.cvalue1double,mv.cvalue2double,mv.cvalue1date,mv.cvalue1day,mv.cvalue2date,mv.cvalue2day,mv.cvalueboolean,mv.cdetails
	FROM tmetadatavalue mv INNER JOIN tportalmetadata pm ON mv.cmetadatafk=pm.crecorduid;

ALTER TABLE tportalmetadata DROP COLUMN cvalue1string;
ALTER TABLE tportalmetadata DROP COLUMN cvalue2string;
ALTER TABLE tportalmetadata DROP COLUMN cvalue1integer;
ALTER TABLE tportalmetadata DROP COLUMN cvalue2integer;
ALTER TABLE tportalmetadata DROP COLUMN cvalue1double;
ALTER TABLE tportalmetadata DROP COLUMN cvalue2double;
ALTER TABLE tportalmetadata DROP COLUMN cvalue1date;
ALTER TABLE tportalmetadata DROP COLUMN cvalue1day;
ALTER TABLE tportalmetadata DROP COLUMN cvalue2date;
ALTER TABLE tportalmetadata DROP COLUMN cvalue2day;
ALTER TABLE tportalmetadata DROP COLUMN cvalueboolean;
ALTER TABLE tportalmetadata DROP COLUMN cdetails;

ALTER TABLE timportmetadata DROP COLUMN cvalue1string;
ALTER TABLE timportmetadata DROP COLUMN cvalue2string;
ALTER TABLE timportmetadata DROP COLUMN cvalue1integer;
ALTER TABLE timportmetadata DROP COLUMN cvalue2integer;
ALTER TABLE timportmetadata DROP COLUMN cvalue1double;
ALTER TABLE timportmetadata DROP COLUMN cvalue2double;
ALTER TABLE timportmetadata DROP COLUMN cvalue1date;
ALTER TABLE timportmetadata DROP COLUMN cvalue1day;
ALTER TABLE timportmetadata DROP COLUMN cvalue2date;
ALTER TABLE timportmetadata DROP COLUMN cvalue2day;
ALTER TABLE timportmetadata DROP COLUMN cvalueboolean;
ALTER TABLE timportmetadata DROP COLUMN cdetails;

CREATE SEQUENCE metadatalink_sequence;
CREATE TABLE tmetadatalink (
  crecorduid            INTEGER       NOT NULL ,
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  cparentmetadatafk     INTEGER       NOT NULL,
  cchildmetadatafk      INTEGER       NOT NULL,
  clevel                INTEGER       NOT NULL,
  CONSTRAINT metadatalink_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT metadatalink_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT metadatalink_uk UNIQUE (ctimeslotfk, cparentmetadatafk, cchildmetadatafk)
);

CREATE OR REPLACE TRIGGER metadatalink_uid_tr BEFORE INSERT ON tmetadatalink
FOR EACH ROW
BEGIN
  IF :new.crecorduid IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'CRECORDUID cannot be specified for TMETADATALINK');
  ELSE
    SELECT metadatalink_sequence.NEXTVAL
    INTO   :new.crecorduid
    FROM   dual;
  END IF;
END;
/


CREATE INDEX idx_metadatalink_parent ON tmetadatalink(cparentmetadatafk);
CREATE INDEX idx_metadatalink_child ON tmetadatalink(cchildmetadatafk);

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

CREATE INDEX idx_pmetadatalink_parent ON tportalmetadatalink(cparentmetadatafk);
CREATE INDEX idx_pmetadatalink_child ON tportalmetadatalink(cchildmetadatafk);

-- RAW RIGHT GROUPS

CREATE SEQUENCE rawrightgroup_sequence;
CREATE TABLE trawrightgroup (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  ,
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object permanent key
  crawrightgroupuid     VARCHAR(64)   NOT NULL,
  -- Object information
  crepositoryfk         INTEGER       NOT NULL,
  cgroupfk              INTEGER       NOT NULL,
  cpermissionfk         INTEGER       NOT NULL,
  cperimeterfk          INTEGER,
  crighttype            VARCHAR2(32 CHAR),
  cdisplayname          VARCHAR2(250 CHAR),
  cnegative             CHAR(1)       NOT NULL,
  cdefault              CHAR(1),
  ccontext              VARCHAR2(250 CHAR), -- small to be indexable on SQLServer
  ccustom1              VARCHAR2(1000 CHAR),
  ccustom2              VARCHAR2(1000 CHAR),
  ccustom3              VARCHAR2(1000 CHAR),
  ccustom4              VARCHAR2(1000 CHAR),
  ccustom5              VARCHAR2(1000 CHAR),
  ccustom6              VARCHAR2(1000 CHAR),
  ccustom7              VARCHAR2(1000 CHAR),
  ccustom8              VARCHAR2(1000 CHAR),
  ccustom9              VARCHAR2(1000 CHAR),
  CONSTRAINT rawrightgroup_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT rawrightgroup_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT rawrightgroup_uniqueness_uk UNIQUE (cgroupfk, cpermissionfk, cperimeterfk, cnegative),
  CONSTRAINT rawrightgroup_uid_uk UNIQUE (ctimeslotfk, crawrightgroupuid),
  CONSTRAINT rawrightgroup_negative_ck CHECK (cnegative IN ('0', '1')),
  CONSTRAINT rawrightgroup_default_ck CHECK (cdefault IN ('0', '1'))
);

CREATE OR REPLACE TRIGGER rawrightgroup_uid_tr BEFORE INSERT ON trawrightgroup
FOR EACH ROW
BEGIN
  IF :new.crecorduid IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'CRECORDUID cannot be specified for TRAWRIGHTGROUP');
  ELSE
    SELECT rawrightgroup_sequence.NEXTVAL
    INTO   :new.crecorduid
    FROM   dual;
  END IF;
END;
/




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
  crighttype            VARCHAR2(32 CHAR),
  cdisplayname          VARCHAR2(250 CHAR),
  cnegative             CHAR(1)       NOT NULL,
  cdefault              CHAR(1),
  ccontext              VARCHAR2(250 CHAR), -- small to be indexable on SQLServer
  ccustom1              VARCHAR2(1000 CHAR),
  ccustom2              VARCHAR2(1000 CHAR),
  ccustom3              VARCHAR2(1000 CHAR),
  ccustom4              VARCHAR2(1000 CHAR),
  ccustom5              VARCHAR2(1000 CHAR),
  ccustom6              VARCHAR2(1000 CHAR),
  ccustom7              VARCHAR2(1000 CHAR),
  ccustom8              VARCHAR2(1000 CHAR),
  ccustom9              VARCHAR2(1000 CHAR),
  CONSTRAINT imprawrightgrp_uid_pk PRIMARY KEY (crawrightgroupuid, cimportlogfk),
  CONSTRAINT imprawrightgrp_uids_uk UNIQUE (cgroupfk, cpermissionfk, cperimeterfk, cnegative, cimportlogfk),
  CONSTRAINT imprawrightgrp_importlog_fk FOREIGN KEY (cimportlogfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT imprawrightgrp_negative_ck CHECK (cnegative IN ('0', '1')),
  CONSTRAINT imprawrightgrp_default_ck CHECK (cdefault IN ('0', '1'))
);

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
  crighttype            VARCHAR2(32 CHAR),
  cdisplayname          VARCHAR2(250 CHAR),
  cnegative             CHAR(1)       NOT NULL,
  cdefault              CHAR(1),
  ccontext              VARCHAR2(250 CHAR), -- small to be indexable on SQLServer
  ccustom1              VARCHAR2(1000 CHAR),
  ccustom2              VARCHAR2(1000 CHAR),
  ccustom3              VARCHAR2(1000 CHAR),
  ccustom4              VARCHAR2(1000 CHAR),
  ccustom5              VARCHAR2(1000 CHAR),
  ccustom6              VARCHAR2(1000 CHAR),
  ccustom7              VARCHAR2(1000 CHAR),
  ccustom8              VARCHAR2(1000 CHAR),
  ccustom9              VARCHAR2(1000 CHAR),
  CONSTRAINT prwrightgrp_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT prwrightgrp_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT prwrightgrp_uniqueness_uk UNIQUE (cgroupfk, cpermissionfk, cperimeterfk, cnegative),
  CONSTRAINT prwrightgrp_uid_uk UNIQUE (ctimeslotfk, crawrightgroupuid),
  CONSTRAINT prwrightgrp_negative_ck CHECK (cnegative IN ('0', '1')),
  CONSTRAINT prawrightgrp_default_ck CHECK (cdefault IN ('0', '1'))
);



-- create index on right type in account raw group rights
CREATE INDEX idx_rawrightgrp_type ON trawrightgroup(crighttype);
CREATE INDEX idx_prawrightgrp_type ON tportalrawrightgroup(crighttype);

-- create index on default flag in account raw group rights
CREATE INDEX idx_rawrightgrp_default ON trawrightgroup(cdefault);
CREATE INDEX idx_prawrightgrp_default ON tportalrawrightgroup(cdefault);

-- create index on right context in account raw group rights
CREATE INDEX idx_rawrightgrp_context ON trawrightgroup(ccontext);
CREATE INDEX idx_prawrightgrp_context ON tportalrawrightgroup(ccontext);

-- remove type constraint on ACL
ALTER TABLE timportaclaccount DROP CONSTRAINT importaclaccount_type_ck;
ALTER TABLE timportaclgroup DROP CONSTRAINT importaclgroup_type_ck;
ALTER TABLE taclaccount DROP CONSTRAINT aclaccount_type_ck;
ALTER TABLE taclgroup DROP CONSTRAINT aclgroup_type_ck;
ALTER TABLE tportalaclaccount DROP CONSTRAINT paclaccount_type_ck;
ALTER TABLE tportalaclgroup DROP CONSTRAINT paclgroup_type_ck;

-- add read write and control booleans on all tables containing basic column
ALTER TABLE taclaccount         ADD cread         VARCHAR(1);
ALTER TABLE taclaccount         ADD cwrite        VARCHAR(1);
ALTER TABLE taclaccount         ADD ccontrol      VARCHAR(1);

ALTER TABLE taclaccount         ADD CONSTRAINT aclaccount_read_ck CHECK (cread IN ('0', '1'));
ALTER TABLE taclaccount         ADD CONSTRAINT aclaccount_write_ck CHECK (cwrite IN ('0', '1'));
ALTER TABLE taclaccount         ADD CONSTRAINT aclaccount_control_ck CHECK (ccontrol IN ('0', '1'));

ALTER TABLE taclgroup           ADD cread         VARCHAR(1);
ALTER TABLE taclgroup           ADD cwrite        VARCHAR(1);
ALTER TABLE taclgroup           ADD ccontrol      VARCHAR(1);

ALTER TABLE taclgroup           ADD CONSTRAINT aclgroup_read_ck CHECK (cread IN ('0', '1'));
ALTER TABLE taclgroup           ADD CONSTRAINT aclgroup_write_ck CHECK (cwrite IN ('0', '1'));
ALTER TABLE taclgroup           ADD CONSTRAINT aclgroup_control_ck CHECK (ccontrol IN ('0', '1'));

ALTER TABLE tportalaclaccount   ADD cread         VARCHAR(1);
ALTER TABLE tportalaclaccount   ADD cwrite        VARCHAR(1);
ALTER TABLE tportalaclaccount   ADD ccontrol      VARCHAR(1);

ALTER TABLE tportalaclaccount   ADD CONSTRAINT paclaccount_read_ck CHECK (cread IN ('0', '1'));
ALTER TABLE tportalaclaccount   ADD CONSTRAINT paclaccount_write_ck CHECK (cwrite IN ('0', '1'));
ALTER TABLE tportalaclaccount   ADD CONSTRAINT paclaccount_control_ck CHECK (ccontrol IN ('0', '1'));

ALTER TABLE tportalaclgroup     ADD cread         VARCHAR(1);
ALTER TABLE tportalaclgroup     ADD cwrite        VARCHAR(1);
ALTER TABLE tportalaclgroup     ADD ccontrol      VARCHAR(1);

ALTER TABLE tportalaclgroup     ADD CONSTRAINT paclgroup_read_ck CHECK (cread IN ('0', '1'));
ALTER TABLE tportalaclgroup     ADD CONSTRAINT paclgroup_write_ck CHECK (cwrite IN ('0', '1'));
ALTER TABLE tportalaclgroup     ADD CONSTRAINT paclgroup_control_ck CHECK (ccontrol IN ('0', '1'));

ALTER TABLE tfsrightgroup       ADD cread         VARCHAR(1);
ALTER TABLE tfsrightgroup       ADD cwrite        VARCHAR(1);
ALTER TABLE tfsrightgroup       ADD ccontrol      VARCHAR(1);

ALTER TABLE tfsrightgroup       ADD CONSTRAINT fsrightgroup_read_ck CHECK (cread IN ('0', '1'));
ALTER TABLE tfsrightgroup       ADD CONSTRAINT fsrightgroup_write_ck CHECK (cwrite IN ('0', '1'));
ALTER TABLE tfsrightgroup       ADD CONSTRAINT fsrightgroup_control_ck CHECK (ccontrol IN ('0', '1'));

ALTER TABLE tportalfsrightgroup ADD cread         VARCHAR(1);
ALTER TABLE tportalfsrightgroup ADD cwrite        VARCHAR(1);
ALTER TABLE tportalfsrightgroup ADD ccontrol      VARCHAR(1);

ALTER TABLE tportalfsrightgroup ADD CONSTRAINT pfsrightgroup_read_ck CHECK (cread IN ('0', '1'));
ALTER TABLE tportalfsrightgroup ADD CONSTRAINT pfsrightgroup_write_ck CHECK (cwrite IN ('0', '1'));
ALTER TABLE tportalfsrightgroup ADD CONSTRAINT pfsrightgroup_control_ck CHECK (ccontrol IN ('0', '1'));

DROP VIEW vfsaggregatedright;
CREATE VIEW vfsaggregatedright AS
   SELECT R.ctimeslotfk, R.caction, R.cbasic, R.corder, R.cread, R.cwrite, R.ccontrol, A.caccountfk, R.cpermissionfk
    FROM  tfsrightgroup R
    INNER JOIN tvaccountgroup A ON R.cgroupfk = A.cparentvgroupfk ;

DROP VIEW vportalfsaggregatedright;
CREATE VIEW vportalfsaggregatedright AS
   SELECT R.ctimeslotfk, R.caction,R.cbasic, R.corder, R.cread, R.cwrite, R.ccontrol, A.caccountfk, R.cpermissionfk
    FROM  tportalfsrightgroup R
    INNER JOIN tportalvaccountgroup A ON R.cgroupfk = A.cparentvgroupfk ;

CREATE INDEX idx_aclaccount_read ON taclaccount(cread);
CREATE INDEX idx_aclaccount_write ON taclaccount(cwrite);
CREATE INDEX idx_aclaccount_control ON taclaccount(ccontrol);

CREATE INDEX idx_paclaccount_read ON tportalaclaccount(cread);
CREATE INDEX idx_paclaccount_write ON tportalaclaccount(cwrite);
CREATE INDEX idx_paclaccount_control ON tportalaclaccount(ccontrol);

CREATE INDEX idx_aclgroup_read ON taclgroup(cread);
CREATE INDEX idx_aclgroup_write ON taclgroup(cwrite);
CREATE INDEX idx_aclgroup_control ON taclgroup(ccontrol);

CREATE INDEX idx_paclgroup_read ON tportalaclgroup(cread);
CREATE INDEX idx_paclgroup_write ON tportalaclgroup(cwrite);
CREATE INDEX idx_paclgroup_control ON tportalaclgroup(ccontrol);

CREATE INDEX idx_fsrightgroup_read ON tfsrightgroup(cread);
CREATE INDEX idx_fsrightgroup_write ON tfsrightgroup(cwrite);
CREATE INDEX idx_fsrightgroup_control ON tfsrightgroup(ccontrol);

CREATE INDEX idx_pfsrightgroup_read ON tportalfsrightgroup(cread);
CREATE INDEX idx_pfsrightgroup_write ON tportalfsrightgroup(cwrite);
CREATE INDEX idx_pfsrightgroup_control ON tportalfsrightgroup(ccontrol);

ALTER TABLE tcompliancereport DROP CONSTRAINT compliancereport_cstatus_ck;

-- Upgrade script to version 32
-- --------


ALTER TABLE tmetadatavalue ADD cvalue3string         VARCHAR2(2000 CHAR);
ALTER TABLE tmetadatavalue ADD cvalue4string         VARCHAR2(2000 CHAR);
ALTER TABLE tmetadatavalue ADD cvalue5string         VARCHAR2(2000 CHAR);
ALTER TABLE tmetadatavalue ADD cvalue6string         VARCHAR2(2000 CHAR);
ALTER TABLE tmetadatavalue ADD cvalue7string         VARCHAR2(2000 CHAR);
ALTER TABLE tmetadatavalue ADD cvalue8string         VARCHAR2(2000 CHAR);
ALTER TABLE tmetadatavalue ADD cvalue9string         VARCHAR2(2000 CHAR);
ALTER TABLE tmetadatavalue ADD cvalue10string        VARCHAR2(2000 CHAR);
ALTER TABLE tmetadatavalue ADD cvalue11string        VARCHAR2(2000 CHAR);
ALTER TABLE tmetadatavalue ADD cvalue12string        VARCHAR2(2000 CHAR);
ALTER TABLE tmetadatavalue ADD cvalue13string        VARCHAR2(2000 CHAR);
ALTER TABLE tmetadatavalue ADD cvalue14string        VARCHAR2(2000 CHAR);
ALTER TABLE tmetadatavalue ADD cvalue15string        VARCHAR2(2000 CHAR);
ALTER TABLE tmetadatavalue ADD cvalue16string        VARCHAR2(2000 CHAR);
ALTER TABLE tmetadatavalue ADD cvalue17string        VARCHAR2(2000 CHAR);
ALTER TABLE tmetadatavalue ADD cvalue18string        VARCHAR2(2000 CHAR);
ALTER TABLE tmetadatavalue ADD cvalue19string        VARCHAR2(2000 CHAR);
ALTER TABLE tmetadatavalue ADD cvalue20string        VARCHAR2(2000 CHAR);
ALTER TABLE tmetadatavalue ADD cvalue3integer        INTEGER;
ALTER TABLE tmetadatavalue ADD cvalue4integer        INTEGER;
ALTER TABLE tmetadatavalue ADD cvalue5integer        INTEGER;
ALTER TABLE tmetadatavalue ADD cvalue6integer        INTEGER;
ALTER TABLE tmetadatavalue ADD cvalue7integer        INTEGER;
ALTER TABLE tmetadatavalue ADD cvalue8integer        INTEGER;
ALTER TABLE tmetadatavalue ADD cvalue9integer        INTEGER;
ALTER TABLE tmetadatavalue ADD cvalue10integer       INTEGER;
ALTER TABLE tmetadatavalue ADD cvalue11integer       INTEGER;
ALTER TABLE tmetadatavalue ADD cvalue12integer       INTEGER;
ALTER TABLE tmetadatavalue ADD cvalue13integer       INTEGER;
ALTER TABLE tmetadatavalue ADD cvalue14integer       INTEGER;
ALTER TABLE tmetadatavalue ADD cvalue15integer       INTEGER;
ALTER TABLE tmetadatavalue ADD cvalue16integer       INTEGER;
ALTER TABLE tmetadatavalue ADD cvalue17integer       INTEGER;
ALTER TABLE tmetadatavalue ADD cvalue18integer       INTEGER;
ALTER TABLE tmetadatavalue ADD cvalue19integer       INTEGER;
ALTER TABLE tmetadatavalue ADD cvalue20integer       INTEGER;

ALTER TABLE timportmetadatavalue ADD cvalue3string         VARCHAR2(2000 CHAR);
ALTER TABLE timportmetadatavalue ADD cvalue4string         VARCHAR2(2000 CHAR);
ALTER TABLE timportmetadatavalue ADD cvalue5string         VARCHAR2(2000 CHAR);
ALTER TABLE timportmetadatavalue ADD cvalue6string         VARCHAR2(2000 CHAR);
ALTER TABLE timportmetadatavalue ADD cvalue7string         VARCHAR2(2000 CHAR);
ALTER TABLE timportmetadatavalue ADD cvalue8string         VARCHAR2(2000 CHAR);
ALTER TABLE timportmetadatavalue ADD cvalue9string         VARCHAR2(2000 CHAR);
ALTER TABLE timportmetadatavalue ADD cvalue10string        VARCHAR2(2000 CHAR);
ALTER TABLE timportmetadatavalue ADD cvalue11string        VARCHAR2(2000 CHAR);
ALTER TABLE timportmetadatavalue ADD cvalue12string        VARCHAR2(2000 CHAR);
ALTER TABLE timportmetadatavalue ADD cvalue13string        VARCHAR2(2000 CHAR);
ALTER TABLE timportmetadatavalue ADD cvalue14string        VARCHAR2(2000 CHAR);
ALTER TABLE timportmetadatavalue ADD cvalue15string        VARCHAR2(2000 CHAR);
ALTER TABLE timportmetadatavalue ADD cvalue16string        VARCHAR2(2000 CHAR);
ALTER TABLE timportmetadatavalue ADD cvalue17string        VARCHAR2(2000 CHAR);
ALTER TABLE timportmetadatavalue ADD cvalue18string        VARCHAR2(2000 CHAR);
ALTER TABLE timportmetadatavalue ADD cvalue19string        VARCHAR2(2000 CHAR);
ALTER TABLE timportmetadatavalue ADD cvalue20string        VARCHAR2(2000 CHAR);
ALTER TABLE timportmetadatavalue ADD cvalue3integer        INTEGER;
ALTER TABLE timportmetadatavalue ADD cvalue4integer        INTEGER;
ALTER TABLE timportmetadatavalue ADD cvalue5integer        INTEGER;
ALTER TABLE timportmetadatavalue ADD cvalue6integer        INTEGER;
ALTER TABLE timportmetadatavalue ADD cvalue7integer        INTEGER;
ALTER TABLE timportmetadatavalue ADD cvalue8integer        INTEGER;
ALTER TABLE timportmetadatavalue ADD cvalue9integer        INTEGER;
ALTER TABLE timportmetadatavalue ADD cvalue10integer       INTEGER;
ALTER TABLE timportmetadatavalue ADD cvalue11integer       INTEGER;
ALTER TABLE timportmetadatavalue ADD cvalue12integer       INTEGER;
ALTER TABLE timportmetadatavalue ADD cvalue13integer       INTEGER;
ALTER TABLE timportmetadatavalue ADD cvalue14integer       INTEGER;
ALTER TABLE timportmetadatavalue ADD cvalue15integer       INTEGER;
ALTER TABLE timportmetadatavalue ADD cvalue16integer       INTEGER;
ALTER TABLE timportmetadatavalue ADD cvalue17integer       INTEGER;
ALTER TABLE timportmetadatavalue ADD cvalue18integer       INTEGER;
ALTER TABLE timportmetadatavalue ADD cvalue19integer       INTEGER;
ALTER TABLE timportmetadatavalue ADD cvalue20integer       INTEGER;

ALTER TABLE tportalmetadatavalue ADD cvalue3string         VARCHAR2(2000 CHAR);
ALTER TABLE tportalmetadatavalue ADD cvalue4string         VARCHAR2(2000 CHAR);
ALTER TABLE tportalmetadatavalue ADD cvalue5string         VARCHAR2(2000 CHAR);
ALTER TABLE tportalmetadatavalue ADD cvalue6string         VARCHAR2(2000 CHAR);
ALTER TABLE tportalmetadatavalue ADD cvalue7string         VARCHAR2(2000 CHAR);
ALTER TABLE tportalmetadatavalue ADD cvalue8string         VARCHAR2(2000 CHAR);
ALTER TABLE tportalmetadatavalue ADD cvalue9string         VARCHAR2(2000 CHAR);
ALTER TABLE tportalmetadatavalue ADD cvalue10string        VARCHAR2(2000 CHAR);
ALTER TABLE tportalmetadatavalue ADD cvalue11string        VARCHAR2(2000 CHAR);
ALTER TABLE tportalmetadatavalue ADD cvalue12string        VARCHAR2(2000 CHAR);
ALTER TABLE tportalmetadatavalue ADD cvalue13string        VARCHAR2(2000 CHAR);
ALTER TABLE tportalmetadatavalue ADD cvalue14string        VARCHAR2(2000 CHAR);
ALTER TABLE tportalmetadatavalue ADD cvalue15string        VARCHAR2(2000 CHAR);
ALTER TABLE tportalmetadatavalue ADD cvalue16string        VARCHAR2(2000 CHAR);
ALTER TABLE tportalmetadatavalue ADD cvalue17string        VARCHAR2(2000 CHAR);
ALTER TABLE tportalmetadatavalue ADD cvalue18string        VARCHAR2(2000 CHAR);
ALTER TABLE tportalmetadatavalue ADD cvalue19string        VARCHAR2(2000 CHAR);
ALTER TABLE tportalmetadatavalue ADD cvalue20string        VARCHAR2(2000 CHAR);
ALTER TABLE tportalmetadatavalue ADD cvalue3integer        INTEGER;
ALTER TABLE tportalmetadatavalue ADD cvalue4integer        INTEGER;
ALTER TABLE tportalmetadatavalue ADD cvalue5integer        INTEGER;
ALTER TABLE tportalmetadatavalue ADD cvalue6integer        INTEGER;
ALTER TABLE tportalmetadatavalue ADD cvalue7integer        INTEGER;
ALTER TABLE tportalmetadatavalue ADD cvalue8integer        INTEGER;
ALTER TABLE tportalmetadatavalue ADD cvalue9integer        INTEGER;
ALTER TABLE tportalmetadatavalue ADD cvalue10integer       INTEGER;
ALTER TABLE tportalmetadatavalue ADD cvalue11integer       INTEGER;
ALTER TABLE tportalmetadatavalue ADD cvalue12integer       INTEGER;
ALTER TABLE tportalmetadatavalue ADD cvalue13integer       INTEGER;
ALTER TABLE tportalmetadatavalue ADD cvalue14integer       INTEGER;
ALTER TABLE tportalmetadatavalue ADD cvalue15integer       INTEGER;
ALTER TABLE tportalmetadatavalue ADD cvalue16integer       INTEGER;
ALTER TABLE tportalmetadatavalue ADD cvalue17integer       INTEGER;
ALTER TABLE tportalmetadatavalue ADD cvalue18integer       INTEGER;
ALTER TABLE tportalmetadatavalue ADD cvalue19integer       INTEGER;
ALTER TABLE tportalmetadatavalue ADD cvalue20integer       INTEGER;

CREATE INDEX idx_metadata_key ON tmetadata(ckey);
CREATE INDEX idx_metadata_subkey ON tmetadata(csubkey);
CREATE INDEX idx_pmetadata_key ON tportalmetadata(ckey);
CREATE INDEX idx_pmetadata_subkey ON tportalmetadata(csubkey);



ALTER TABLE tactivitypair MODIFY (coperator VARCHAR(16));



ALTER TABLE timportactivitypair MODIFY (coperator VARCHAR(16));



ALTER TABLE tportalactivitypair MODIFY (coperator VARCHAR(16));

CREATE SEQUENCE uservariable_sequence;
CREATE TABLE tuservariable (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL    ,
  cowneruid             VARCHAR2(250 CHAR)  NOT NULL,
  cname                 VARCHAR2(250 CHAR)  NOT NULL,
  ccontent              CLOB,
  CONSTRAINT uservariable_uid_pk PRIMARY KEY (crecorduid)
);

CREATE OR REPLACE TRIGGER uservariable_uid_tr BEFORE INSERT ON tuservariable
FOR EACH ROW
BEGIN
  IF :new.crecorduid IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'CRECORDUID cannot be specified for tuservariable');
  ELSE
    SELECT uservariable_sequence.NEXTVAL
    INTO   :new.crecorduid
    FROM   dual;
  END IF;
END;
/


CREATE INDEX idx_uservariable_key ON tuservariable(cowneruid, cname);

ALTER TABLE timportmanagerrule DROP CONSTRAINT importmanagerrule_target_ck;
ALTER TABLE tmanagerrule DROP CONSTRAINT managerrule_target_ck;
ALTER TABLE tportalmanagerrule DROP CONSTRAINT pmanagerrule_target_ck;

ALTER TABLE tmanager ADD cmanagedidentityfk              INTEGER;
ALTER TABLE tmanager ADD cindirect                       CHAR(1);

ALTER TABLE tmanagerrule ADD cmanagedidentityfk          INTEGER;

ALTER TABLE timportmanagerrule ADD cmanagedidentityfk    VARCHAR(64);


ALTER TABLE timportmanager ADD cmanagedidentityfk        VARCHAR(64);
ALTER TABLE timportmanager ADD cindirect                 CHAR(1);

ALTER TABLE tportalmanager ADD cmanagedidentityfk        INTEGER;
ALTER TABLE tportalmanager ADD cindirect                 CHAR(1);

ALTER TABLE tportalmanagerrule ADD cmanagedidentityfk    INTEGER;

CREATE INDEX idx_managerrule_mngdidnt ON tmanagerrule(cmanagedidentityfk);

-- IDNTMANAGERREVIEW table
CREATE TABLE tidntmanagerreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  cmanagerfk            INTEGER       NOT NULL,
  CONSTRAINT idntmanagerreview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

CREATE INDEX idx_manager_mngdident ON tmanager(cmanagedidentityfk);

CREATE INDEX idx_pmanagerrule_mngdidnt ON tportalmanagerrule(cmanagedidentityfk);

-- IDNTMANAGERREVIEW table
CREATE TABLE tportaltidntmanagerreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  cmanagerfk            INTEGER       NOT NULL,
  CONSTRAINT pidntmanagerrev_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

CREATE INDEX idx_pmanager_mngdident ON tportalmanager(cmanagedidentityfk);

CREATE INDEX idx_identmanagerrev_timeslot ON tidntmanagerreview(ctimeslotfk);
CREATE INDEX idx_identmanagerrev_ticket ON tidntmanagerreview(cticketreviewfk);
CREATE INDEX idx_identmanagerrev_manager ON tidntmanagerreview(cmanagerfk);

CREATE INDEX idx_pidentmanagerrev_timeslot ON tportaltidntmanagerreview(ctimeslotfk);
CREATE INDEX idx_pidentmanagerrev_ticket ON tportaltidntmanagerreview(cticketreviewfk);
CREATE INDEX idx_pidentmanagerrev_manager ON tportaltidntmanagerreview(cmanagerfk);

-- DIRECT identity manager view
CREATE VIEW vdirectidentitymanagers AS
  SELECT m.crecorduid,m.ctimeslotfk,m.corganisationfk,m.crepositoryfk,m.caccountfk,m.cgroupfk,m.cpermissionfk,m.capplicationfk,m.cassetfk,m.ccampaignfk,m.cmanagedidentityfk,m.cindirect,
  		 m.cexpertisedomainfk,m.cidentityfk,m.ccollected,m.cdelegation,m.cpriority,m.cstartdate,m.cstartday,m.cenddate,m.cendday,m.ccomment,m.cdelegationreason
  FROM tmanager m
  INNER JOIN tidentity i ON i.crecorduid = m.cmanagedidentityfk
  WHERE m.cindirect='0' OR m.cindirect IS NULL;

  -- DIRECT identity manager view
CREATE VIEW vpdirectidentitymanagers AS
  SELECT m.crecorduid,m.ctimeslotfk,m.corganisationfk,m.crepositoryfk,m.caccountfk,m.cgroupfk,m.cpermissionfk,m.capplicationfk,m.cassetfk,m.ccampaignfk,m.cmanagedidentityfk,m.cindirect,
  		 m.cexpertisedomainfk,m.cidentityfk,m.ccollected,m.cdelegation,m.cpriority,m.cstartdate,m.cstartday,m.cenddate,m.cendday,m.ccomment,m.cdelegationreason
  FROM tportalmanager m
  INNER JOIN tportalidentity i ON i.crecorduid = m.cmanagedidentityfk
  WHERE m.cindirect='0' OR m.cindirect IS NULL;
  
  -- change exiting column type from varchar(max) to nvarchar(max)
  
  
CREATE INDEX idx_user_data_uid ON tuserdata(cuuid);  

CREATE INDEX idx_account_ident_ts ON taccount(cidentifier, ctimeslotfk);
CREATE INDEX idx_paccount_ident_ts ON tportalaccount(cidentifier, ctimeslotfk);


UPDATE tproperties SET cvalue='32' WHERE cpropertiesuid='VERSION';

commit;
-- Upgrade script to version 33
-- --------


-- MISSION table
CREATE SEQUENCE mission_sequence;
CREATE TABLE tmission (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL ,
  -- Object information
  cname                 VARCHAR2(250 CHAR),
  cbusinessdomain       VARCHAR2(250 CHAR),
  cdescription          VARCHAR2(4000 CHAR),
  cduedate              VARCHAR(15),
  CONSTRAINT mission_uid_pk PRIMARY KEY (crecorduid)
);

CREATE OR REPLACE TRIGGER mission_uid_tr BEFORE INSERT ON tmission
FOR EACH ROW
BEGIN
  IF :new.crecorduid IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'CRECORDUID cannot be specified for TMISSION');
  ELSE
    SELECT mission_sequence.NEXTVAL
    INTO   :new.crecorduid
    FROM   dual;
  END IF;
END;
/


-- ENDPOINT table
CREATE SEQUENCE endpoint_sequence;
CREATE TABLE tendpoint (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  ,
  -- Object information
  cname                 VARCHAR2(250 CHAR)  NOT NULL,
  cdescription          VARCHAR2(4000 CHAR),
  cprovider             VARCHAR(100)  NOT NULL,
  cdefinition           VARCHAR2(4000 CHAR),
  CONSTRAINT endpoint_uid_pk PRIMARY KEY (crecorduid)
);

CREATE OR REPLACE TRIGGER endpoint_uid_tr BEFORE INSERT ON tendpoint
FOR EACH ROW
BEGIN
  IF :new.crecorduid IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'CRECORDUID cannot be specified for TENDPOINT');
  ELSE
    SELECT endpoint_sequence.NEXTVAL
    INTO   :new.crecorduid
    FROM   dual;
  END IF;
END;
/


-- MISSIONWAVE table
CREATE SEQUENCE missionwave_sequence;
CREATE TABLE tmissionwave (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  ,
  -- Object information
  cname                 VARCHAR2(250 CHAR)  NOT NULL,
  cdescription          VARCHAR2(4000 CHAR),
  cendpointfk           INTEGER,
  ctimeslotfk           VARCHAR(64),
  ccreationdate         VARCHAR(15),
  chidden               CHAR(1)       NOT NULL,
  CONSTRAINT missionwave_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT missionwave_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT missionwave_endpoint_fk FOREIGN KEY (cendpointfk) REFERENCES tendpoint(crecorduid) ON DELETE SET NULL
);

CREATE OR REPLACE TRIGGER missionwave_uid_tr BEFORE INSERT ON tmissionwave
FOR EACH ROW
BEGIN
  IF :new.crecorduid IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'CRECORDUID cannot be specified for TMISSIONWAVE');
  ELSE
    SELECT missionwave_sequence.NEXTVAL
    INTO   :new.crecorduid
    FROM   dual;
  END IF;
END;
/


-- MISSIONWAVESTAGE table
CREATE SEQUENCE missionwavestage_sequence;
CREATE TABLE tmissionwavestage (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  ,
  -- Object information
  corder                INTEGER       NOT NULL,
  ctype                 VARCHAR(32)   NOT NULL,
  ckey                  VARCHAR(100)  NOT NULL,
  cvalue                VARCHAR2(100 CHAR),
  clabels               VARCHAR2(4000 CHAR),
  cmissionwavefk        INTEGER       NOT NULL,
  cavailable            CHAR(1)       NOT NULL,
  ccompleted            CHAR(1)       NOT NULL,
  CONSTRAINT missionwavestage_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT stage_wave_fk FOREIGN KEY (cmissionwavefk) REFERENCES tmissionwave(crecorduid) ON DELETE CASCADE
);

CREATE OR REPLACE TRIGGER missionwavestage_uid_tr BEFORE INSERT ON tmissionwavestage
FOR EACH ROW
BEGIN
  IF :new.crecorduid IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'CRECORDUID cannot be specified for TMISSIONWAVESTAGE');
  ELSE
    SELECT missionwavestage_sequence.NEXTVAL
    INTO   :new.crecorduid
    FROM   dual;
  END IF;
END;
/


-- SOFTWARE table
CREATE SEQUENCE software_sequence;
CREATE TABLE tsoftware (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  ,
  -- Object information
  cname                 VARCHAR2(250 CHAR)  NOT NULL,
  cdescription          VARCHAR2(4000 CHAR),
  ccriticity            INTEGER,
  cfamily               VARCHAR2(100 CHAR),
  cmissionwavefk        INTEGER       NOT NULL,
  ctype                 CHAR(1)       NOT NULL,
  caddonname            VARCHAR(100),
  caddondisplayname     VARCHAR2(250 CHAR),
  CONSTRAINT software_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT software_wave_fk FOREIGN KEY (cmissionwavefk) REFERENCES tmissionwave(crecorduid) ON DELETE CASCADE
);

CREATE OR REPLACE TRIGGER software_uid_tr BEFORE INSERT ON tsoftware
FOR EACH ROW
BEGIN
  IF :new.crecorduid IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'CRECORDUID cannot be specified for TSOFTWARE');
  ELSE
    SELECT software_sequence.NEXTVAL
    INTO   :new.crecorduid
    FROM   dual;
  END IF;
END;
/


-- SOFTWAREVARIABLE table
CREATE SEQUENCE softwarevar_sequence;
CREATE TABLE tsoftwarevariable (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  ,
  -- Object information
  csoftwarefk           INTEGER       NOT NULL,
  ckey                  VARCHAR2(250 CHAR)  NOT NULL,
  cvalue                VARCHAR2(1000 CHAR),
  CONSTRAINT softwarevar_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT softwarevar_software_fk FOREIGN KEY (csoftwarefk) REFERENCES tsoftware(crecorduid) ON DELETE CASCADE
);

CREATE OR REPLACE TRIGGER softwarevar_uid_tr BEFORE INSERT ON tsoftwarevariable
FOR EACH ROW
BEGIN
  IF :new.crecorduid IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'CRECORDUID cannot be specified for TSOFTWAREVARIABLE');
  ELSE
    SELECT softwarevar_sequence.NEXTVAL
    INTO   :new.crecorduid
    FROM   dual;
  END IF;
END;
/


-- UPLOADFILE table
CREATE SEQUENCE uploadfile_sequence;
CREATE TABLE tuploadfile (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  ,
  -- Object information
  cinternalfilename     VARCHAR2(1000 CHAR) NOT NULL,
  cexternalfilename     VARCHAR2(1000 CHAR) NOT NULL,
  cdisplayname          VARCHAR2(1000 CHAR) NOT NULL,
  ctemporarypath        VARCHAR2(1000 CHAR) NOT NULL,
  cstatus               CHAR(1)       NOT NULL,
  csize                 INTEGER,
  clastmodified         VARCHAR(15),
  chashcode             VARCHAR(64),
  cissueddate           VARCHAR(15),
  cupdateddate          VARCHAR(15),
  cnode                 VARCHAR(250),
  cerrormessage         VARCHAR2(1000 CHAR),
  CONSTRAINT uploadfile_uid_pk PRIMARY KEY (crecorduid)
);

CREATE OR REPLACE TRIGGER tuploadfile_uid_tr BEFORE INSERT ON tuploadfile
FOR EACH ROW
BEGIN
  IF :new.crecorduid IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'CRECORDUID cannot be specified for TUPLOADFILE');
  ELSE
    SELECT uploadfile_sequence.NEXTVAL
    INTO   :new.crecorduid
    FROM   dual;
  END IF;
END;
/


-- DATASOURCE table
CREATE SEQUENCE datasource_sequence;
CREATE TABLE tdatasource (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  ,
  -- Object information
  cname                 VARCHAR2(250 CHAR)  NOT NULL,
  cdescription          VARCHAR2(4000 CHAR),
  csoftwarefk           INTEGER       NOT NULL,
  cendpointfk           INTEGER,
  ctype                 VARCHAR(15),
  cparsingoptions       VARCHAR2(4000 CHAR),
  CONSTRAINT datasource_uid_pk PRIMARY KEY (crecorduid)
);

CREATE OR REPLACE TRIGGER datasource_uid_tr BEFORE INSERT ON tdatasource
FOR EACH ROW
BEGIN
  IF :new.crecorduid IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'CRECORDUID cannot be specified for TDATASOURCE');
  ELSE
    SELECT datasource_sequence.NEXTVAL
    INTO   :new.crecorduid
    FROM   dual;
  END IF;
END;
/


-- DATASOURCEFILE table
CREATE SEQUENCE datasourcefile_sequence;
CREATE TABLE tdatasourcefile (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  ,
  -- Object information
  cdatasourcefk         INTEGER       NOT NULL,
  cuploadfilefk         INTEGER       NOT NULL,
  cvalidationstatus     VARCHAR(25),
  cmessages             CLOB,
  CONSTRAINT datasourcefile_uid_pk PRIMARY KEY (crecorduid)
);

CREATE OR REPLACE TRIGGER datasourcefile_uid_tr BEFORE INSERT ON tdatasourcefile
FOR EACH ROW
BEGIN
  IF :new.crecorduid IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'CRECORDUID cannot be specified for TDATASOURCEFILE');
  ELSE
    SELECT datasourcefile_sequence.NEXTVAL
    INTO   :new.crecorduid
    FROM   dual;
  END IF;
END;
/


-- MAPPING table
CREATE SEQUENCE mapping_sequence;
CREATE TABLE tmapping (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  ,
  -- Object information
  cname                 VARCHAR2(250 CHAR)  NOT NULL,
  cdatasourcefk         INTEGER       NOT NULL,
  centity               CHAR(1)       NOT NULL,
  CONSTRAINT mapping_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT mapping_datasource_fk FOREIGN KEY (cdatasourcefk) REFERENCES tdatasource(crecorduid) ON DELETE CASCADE
);

CREATE OR REPLACE TRIGGER mapping_uid_tr BEFORE INSERT ON tmapping
FOR EACH ROW
BEGIN
  IF :new.crecorduid IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'CRECORDUID cannot be specified for TMAPPING');
  ELSE
    SELECT mapping_sequence.NEXTVAL
    INTO   :new.crecorduid
    FROM   dual;
  END IF;
END;
/


-- MAPPINGCOMPUTED table
CREATE SEQUENCE mappingcomputed_sequence;
CREATE TABLE tmappingcomputed (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  ,
  -- Object information
  cname                 VARCHAR(100)  NOT NULL,
  cmappingfk            INTEGER       NOT NULL,
  ctype                 CHAR(1)       NOT NULL,
  cmode                 CHAR(1)       NOT NULL,
  cexpression           VARCHAR(2000),
  CONSTRAINT mappingcomputed_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT mappingcomp_mapping_fk FOREIGN KEY (cmappingfk) REFERENCES tmapping(crecorduid) ON DELETE CASCADE
);

CREATE OR REPLACE TRIGGER mappingcomputed_uid_tr BEFORE INSERT ON tmappingcomputed
FOR EACH ROW
BEGIN
  IF :new.crecorduid IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'CRECORDUID cannot be specified for TMAPPINGCOMPUTED');
  ELSE
    SELECT mappingcomputed_sequence.NEXTVAL
    INTO   :new.crecorduid
    FROM   dual;
  END IF;
END;
/


-- MAPPINGATTR table
CREATE SEQUENCE mappingattr_sequence;
CREATE TABLE tmappingattr (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  ,
  -- Object information
  cmappingfk            INTEGER       NOT NULL,
  centityattribute      VARCHAR(100)  NOT NULL,
  ctype                 CHAR(1)       NOT NULL,
  cmode                 CHAR(1)       NOT NULL,
  cdatasourceattribute  VARCHAR(100),
  ccomputedattributefk  INTEGER,
  CONSTRAINT mappingattr_uid_pk PRIMARY KEY (crecorduid)
);

CREATE OR REPLACE TRIGGER mappingattr_uid_tr BEFORE INSERT ON tmappingattr
FOR EACH ROW
BEGIN
  IF :new.crecorduid IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'CRECORDUID cannot be specified for TMAPPINGATTR');
  ELSE
    SELECT mappingattr_sequence.NEXTVAL
    INTO   :new.crecorduid
    FROM   dual;
  END IF;
END;
/


-- MAPPINGFILTER table
CREATE SEQUENCE mappingfilter_sequence;
CREATE TABLE tmappingfilter (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  ,
  -- Object information
  cmappingfk            INTEGER       NOT NULL,
  cname                 VARCHAR(250)  NOT NULL,
  cexpression           VARCHAR(2000),
  CONSTRAINT mappingfilter_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT mappingfilter_mapping_fk FOREIGN KEY (cmappingfk) REFERENCES tmapping(crecorduid) ON DELETE CASCADE
);

CREATE OR REPLACE TRIGGER mappingfilter_uid_tr BEFORE INSERT ON tmappingfilter
FOR EACH ROW
BEGIN
  IF :new.crecorduid IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'CRECORDUID cannot be specified for TMAPPINGFILTER');
  ELSE
    SELECT mappingfilter_sequence.NEXTVAL
    INTO   :new.crecorduid
    FROM   dual;
  END IF;
END;
/


-- EXECPLANMONITOR table
CREATE SEQUENCE execplanmonitor_sequence;
CREATE TABLE texecplanmonitor (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  ,
  -- Object information
  cstatus               CHAR(1)       NOT NULL,
  cprincipalname        VARCHAR2(200 CHAR)  NOT NULL,
  cmissionwavefk        INTEGER,
  csubmitdate           VARCHAR(15)   NOT NULL,
  ctimeslotfk           VARCHAR(64),
  ctaskid               VARCHAR(200),
  cstartdate            VARCHAR(15),
  cheartbeat            VARCHAR(15),
  ccompleteddate         VARCHAR(15),
  cphase                CHAR(1),
  cerrormessage         VARCHAR2(2000 CHAR),
  ccurrentfile          VARCHAR2(2000 CHAR),
  ccurrentsilo          VARCHAR2(250 CHAR),
  CONSTRAINT execplanmonitor_uid_pk PRIMARY KEY (crecorduid)
);

CREATE OR REPLACE TRIGGER execplanmonitor_uid_tr BEFORE INSERT ON texecplanmonitor
FOR EACH ROW
BEGIN
  IF :new.crecorduid IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'CRECORDUID cannot be specified for TEXECPLANMONITOR');
  ELSE
    SELECT execplanmonitor_sequence.NEXTVAL
    INTO   :new.crecorduid
    FROM   dual;
  END IF;
END;
/



UPDATE tproperties SET cvalue='33' WHERE cpropertiesuid='VERSION';

commit;
-- Upgrade script to version 35
-- --------


CREATE SEQUENCE confitem_sequence;
CREATE TABLE tconfitem (
  -- Database primary key
  crecorduid            INTEGER NOT NULL ,
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cconfitemuid          VARCHAR(64)   NOT NULL,
  cfamily               VARCHAR2(100 CHAR)  NOT NULL,
  ctype                 VARCHAR2(100 CHAR)  NOT NULL,
  cenvironment          VARCHAR2(100 CHAR),
  ccode                 VARCHAR2(1000 CHAR) NOT NULL,
  cdisplayname          VARCHAR2(1000 CHAR),
  cdescription          VARCHAR2(4000 CHAR),
  cdn                   VARCHAR2(500 CHAR),
  ccanonicalname        VARCHAR2(500 CHAR),
  ccountrycode          VARCHAR2(20 CHAR),
  cruntimename          VARCHAR2(100 CHAR),
  cruntimeversion       VARCHAR2(100 CHAR),
  cdnsname              VARCHAR2(150 CHAR),
  cipv4address          VARCHAR(15),
  cipv6address          VARCHAR(50),
  cenabled              CHAR(1),
  cstate                VARCHAR2(50 CHAR),
  carch                 VARCHAR2(50 CHAR),
  cnbcputhreads         INTEGER,
  cmemorysize           INTEGER,
  callocatedstorage     INTEGER,
  cstorageencrypted     CHAR(1),
  curn                  VARCHAR2(200 CHAR),
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
  cdetails              CLOB,
  caddress              VARCHAR2(1000 CHAR),
  clocationfk           INTEGER,
  cimportaction         CHAR(1)       NOT NULL,
  cdeletedaction        CHAR(1),
  CONSTRAINT confitem_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT confitem_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT confitem_uid_uk UNIQUE (ctimeslotfk, cconfitemuid)
);

CREATE OR REPLACE TRIGGER confitem_uid_tr BEFORE INSERT ON tconfitem
FOR EACH ROW
BEGIN
  IF :new.crecorduid IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'CRECORDUID cannot be specified for TCONFITEM');
  ELSE
    SELECT confitem_sequence.NEXTVAL
    INTO   :new.crecorduid
    FROM   dual;
  END IF;
END;
/


CREATE SEQUENCE confitemlink_sequence;
CREATE TABLE tconfitemlink (
  -- Database primary key
  crecorduid            INTEGER NOT NULL ,
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cconfitemlinkuid      VARCHAR(64)   NOT NULL,
  corigin               CHAR(1)       NOT NULL,
  cjointypes            VARCHAR(32)   NOT NULL,
  csemantic             VARCHAR2(1000 CHAR),
  cdescription          VARCHAR2(4000 CHAR),
  cindirect             CHAR(1)       NOT NULL,
  csourceconfitemfk     INTEGER,
  csourcerepofk         INTEGER,
  csourceapplifk        INTEGER,
  csourceaccountfk      INTEGER,
  csourceidentityfk     INTEGER,
  csourceorgfk          INTEGER,
  ctargetconfitemfk     INTEGER,
  ctargetrepofk         INTEGER,
  ctargetapplifk        INTEGER,
  ctargetaccountfk      INTEGER,
  ctargetidentityfk     INTEGER,
  ctargetorgfk          INTEGER,
  CONSTRAINT confitemlink_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT confitemlink_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT confitemlink_uid_uk UNIQUE (ctimeslotfk, cconfitemlinkuid)
);

CREATE OR REPLACE TRIGGER confitemlink_uid_tr BEFORE INSERT ON tconfitemlink
FOR EACH ROW
BEGIN
  IF :new.crecorduid IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'CRECORDUID cannot be specified for TCONFITEMLINK');
  ELSE
    SELECT confitemlink_sequence.NEXTVAL
    INTO   :new.crecorduid
    FROM   dual;
  END IF;
END;
/


CREATE TABLE timportconfitem (
  cimportlogfk          VARCHAR(64)   NOT NULL,
  -- Object information
  cconfitemuid          VARCHAR(64)   NOT NULL,
  csilofk               VARCHAR(64),
  cfamily               VARCHAR2(100 CHAR)  NOT NULL,
  ctype                 VARCHAR2(100 CHAR)  NOT NULL,
  cenvironment          VARCHAR2(100 CHAR),
  ccode                 VARCHAR2(1000 CHAR) NOT NULL,
  cdisplayname          VARCHAR2(1000 CHAR),
  cdescription          VARCHAR2(4000 CHAR),
  cdn                   VARCHAR2(500 CHAR),
  ccanonicalname        VARCHAR2(500 CHAR),
  ccountrycode          VARCHAR2(20 CHAR),
  cruntimename          VARCHAR2(100 CHAR),
  cruntimeversion       VARCHAR2(100 CHAR),
  cdnsname              VARCHAR2(150 CHAR),
  cipv4address          VARCHAR(15),
  cipv6address          VARCHAR(50),
  cenabled              CHAR(1),
  cstate                VARCHAR2(50 CHAR),
  carch                 VARCHAR2(50 CHAR),
  cnbcputhreads         INTEGER,
  cmemorysize           INTEGER,
  callocatedstorage     INTEGER,
  cstorageencrypted     CHAR(1),
  curn                  VARCHAR2(200 CHAR),
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
  cdetails              CLOB,
  caddress              VARCHAR2(1000 CHAR),
  clocationuid          VARCHAR(64),
  cimportaction         CHAR(1)       NOT NULL,
  CONSTRAINT importconfitem_uid_pk PRIMARY KEY (cconfitemuid, cimportlogfk),
  CONSTRAINT importconfitem_timeslot_fk FOREIGN KEY (cimportlogfk) REFERENCES timportlog(cimportloguid)
);

CREATE TABLE timportconfitemlink (
  cimportlogfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cconfitemlinkuid      VARCHAR(64)   NOT NULL,
  csilofk               VARCHAR(64),
  corigin               CHAR(1)       NOT NULL,
  cjointypes            VARCHAR(32)   NOT NULL,
  csemantic             VARCHAR2(1000 CHAR),
  cdescription          VARCHAR2(4000 CHAR),
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

CREATE TABLE tportalconfitem (
  -- Database primary key
  crecorduid            INTEGER NOT NULL,
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cconfitemuid          VARCHAR(64)   NOT NULL,
  cfamily               VARCHAR2(100 CHAR)  NOT NULL,
  ctype                 VARCHAR2(100 CHAR)  NOT NULL,
  cenvironment          VARCHAR2(100 CHAR),
  ccode                 VARCHAR2(1000 CHAR) NOT NULL,
  cdisplayname          VARCHAR2(1000 CHAR),
  cdescription          VARCHAR2(4000 CHAR),
  cdn                   VARCHAR2(500 CHAR),
  ccanonicalname        VARCHAR2(500 CHAR),
  ccountrycode          VARCHAR2(20 CHAR),
  cruntimename          VARCHAR2(100 CHAR),
  cruntimeversion       VARCHAR2(100 CHAR),
  cdnsname              VARCHAR2(150 CHAR),
  cipv4address          VARCHAR(15),
  cipv6address          VARCHAR(50),
  cenabled              CHAR(1),
  cstate                VARCHAR2(50 CHAR),
  carch                 VARCHAR2(50 CHAR),
  cnbcputhreads         INTEGER,
  cmemorysize           INTEGER,
  callocatedstorage     INTEGER,
  cstorageencrypted     CHAR(1),
  curn                  VARCHAR2(200 CHAR),
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
  cdetails              CLOB,
  caddress              VARCHAR2(1000 CHAR),
  clocationfk           INTEGER,
  cimportaction         CHAR(1)       NOT NULL,
  cdeletedaction        CHAR(1),
  CONSTRAINT pconfitem_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT pconfitem_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT pconfitem_uid_uk UNIQUE (ctimeslotfk, cconfitemuid)
);

CREATE TABLE tportalconfitemlink (
  -- Database primary key
  crecorduid            INTEGER NOT NULL,
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cconfitemlinkuid      VARCHAR(64)   NOT NULL,
  corigin               CHAR(1)       NOT NULL,
  cjointypes            VARCHAR(32)   NOT NULL,
  csemantic             VARCHAR2(1000 CHAR),
  cdescription          VARCHAR2(4000 CHAR),
  cindirect             CHAR(1)       NOT NULL,
  csourceconfitemfk     INTEGER,
  csourcerepofk         INTEGER,
  csourceapplifk        INTEGER,
  csourceaccountfk      INTEGER,
  csourceidentityfk     INTEGER,
  csourceorgfk          INTEGER,
  ctargetconfitemfk     INTEGER,
  ctargetrepofk         INTEGER,
  ctargetapplifk        INTEGER,
  ctargetaccountfk      INTEGER,
  ctargetidentityfk     INTEGER,
  ctargetorgfk          INTEGER,
  CONSTRAINT pconfitemlink_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT pconfitemlink_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT pconfitemlink_uid_uk UNIQUE (ctimeslotfk, cconfitemlinkuid)
);

ALTER TABLE tmetadata ADD cconfitemfk INTEGER;
ALTER TABLE tmetadatavalue ADD cvalueconfitemuid VARCHAR(64);
ALTER TABLE tmetadatavalue ADD cvalueconfitemfk INTEGER;

ALTER TABLE tmetadata ADD csearchlogfk INTEGER;
ALTER TABLE tmetadata ADD csearchloguid VARCHAR2(250 CHAR);
ALTER TABLE tmetadatavalue ADD cvaluesearchlogfk INTEGER;
ALTER TABLE tmetadatavalue ADD cvaluesearchloguid VARCHAR2(250 CHAR);

CREATE INDEX idx_metadata_confitem ON tmetadata(cconfitemfk);
CREATE INDEX idx_metadatav_confitem ON tmetadatavalue(cmetadatafk,cvalueconfitemfk);

CREATE INDEX idx_metadata_searchlog ON tmetadata(csearchlogfk);
CREATE INDEX idx_metadatav_searchlog ON tmetadatavalue(cmetadatafk,cvaluesearchlogfk);

ALTER TABLE timportmetadata ADD cconfitemfk VARCHAR(64);
ALTER TABLE timportmetadatavalue ADD cvalueconfitemfk VARCHAR(64);

ALTER TABLE tportalmetadata ADD cconfitemfk INTEGER;
ALTER TABLE tportalmetadatavalue ADD cvalueconfitemuid VARCHAR(64);
ALTER TABLE tportalmetadatavalue ADD cvalueconfitemfk INTEGER;

ALTER TABLE tportalmetadata ADD csearchlogfk INTEGER;
ALTER TABLE tportalmetadata ADD csearchloguid VARCHAR2(250 CHAR);
ALTER TABLE tportalmetadatavalue ADD cvaluesearchlogfk INTEGER;
ALTER TABLE tportalmetadatavalue ADD cvaluesearchloguid VARCHAR2(250 CHAR);

CREATE INDEX idx_pmetadata_confitem ON tportalmetadata(cconfitemfk);
CREATE INDEX idx_pmetadatav_confitem ON tportalmetadatavalue(cmetadatafk,cvalueconfitemfk);

CREATE INDEX idx_pmetadata_searchlog ON tportalmetadata(csearchlogfk);
CREATE INDEX idx_pmetadatav_searchlog ON tportalmetadatavalue(cmetadatafk,cvaluesearchlogfk);

CREATE SEQUENCE pamprogram_sequence;
CREATE TABLE tpamprogram (
  -- Database primary key
  crecorduid            INTEGER NOT NULL ,
  -- Object information
  cname                 VARCHAR2(250 CHAR) NOT NULL,
  cdescription          VARCHAR2(4000 CHAR),
  cdeadline             VARCHAR(15),
  CONSTRAINT pamprogram_uid_pk PRIMARY KEY (crecorduid)
);

CREATE OR REPLACE TRIGGER pamprogram_uid_tr BEFORE INSERT ON tpamprogram
FOR EACH ROW
BEGIN
  IF :new.crecorduid IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'CRECORDUID cannot be specified for TPAMPROGRAM');
  ELSE
    SELECT pamprogram_sequence.NEXTVAL
    INTO   :new.crecorduid
    FROM   dual;
  END IF;
END;
/


CREATE SEQUENCE pamscope_sequence;
CREATE TABLE tpamscope (
  -- Database primary key
  crecorduid            INTEGER NOT NULL ,
  -- Object information
  cprogramfk            INTEGER NOT NULL,
  cname                 VARCHAR2(250 CHAR) NOT NULL,
  cdescription          VARCHAR2(4000 CHAR),
  cstartdate            VARCHAR(15),
  cdeadline             VARCHAR(15),
  cstatus               VARCHAR2(100 CHAR),
  ctimeslotuid          VARCHAR(64),
  cimportance           INTEGER,
  crequestoruid         VARCHAR(64),
  crequestorfullname    VARCHAR2(250 CHAR),
  CONSTRAINT pamscope_uid_pk PRIMARY KEY (crecorduid)
);

CREATE OR REPLACE TRIGGER pamscope_uid_tr BEFORE INSERT ON tpamscope
FOR EACH ROW
BEGIN
  IF :new.crecorduid IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'CRECORDUID cannot be specified for TPAMSCOPE');
  ELSE
    SELECT pamscope_sequence.NEXTVAL
    INTO   :new.crecorduid
    FROM   dual;
  END IF;
END;
/


CREATE SEQUENCE pamscopeincl_sequence;
CREATE TABLE tpamscopeincl (
  -- Database primary key
  crecorduid            INTEGER NOT NULL ,
  -- Object information
  cscopefk              INTEGER NOT NULL,
  ctype                 CHAR(1)       NOT NULL,
  ctitle                VARCHAR2(1000 CHAR) NOT NULL,
  cruleid               VARCHAR2(250 CHAR),
  capplications         CLOB,
  cconfitems            CLOB,
  crepositories         CLOB,
  CONSTRAINT pamscopeincl_uid_pk PRIMARY KEY (crecorduid)
);

CREATE OR REPLACE TRIGGER pamscopeincl_uid_tr BEFORE INSERT ON tpamscopeincl
FOR EACH ROW
BEGIN
  IF :new.crecorduid IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'CRECORDUID cannot be specified for TPAMSCOPEINCL');
  ELSE
    SELECT pamscopeincl_sequence.NEXTVAL
    INTO   :new.crecorduid
    FROM   dual;
  END IF;
END;
/


CREATE SEQUENCE pammilestone_sequence;
CREATE TABLE tpammilestone (
  -- Database primary key
  crecorduid            INTEGER NOT NULL ,
  -- Object information
  cprogramfk            INTEGER,
  cscopefk              INTEGER,
  cname                 VARCHAR2(250 CHAR),
  cdeadline             VARCHAR(15),
  CONSTRAINT pammilestone_uid_pk PRIMARY KEY (crecorduid)
);

CREATE OR REPLACE TRIGGER pammilestone_uid_tr BEFORE INSERT ON tpammilestone
FOR EACH ROW
BEGIN
  IF :new.crecorduid IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'CRECORDUID cannot be specified for TPAMMILESTONE');
  ELSE
    SELECT pammilestone_sequence.NEXTVAL
    INTO   :new.crecorduid
    FROM   dual;
  END IF;
END;
/


DROP VIEW vuprightgroup;
DROP VIEW vdownrightgroup;

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

CREATE VIEW vdownrightgroup AS
    SELECT
      ctimeslotfk, crightgroupuid, crepositoryfk,
      cpermissionfk, cgroupfk, cperimeterfk, '1' as cfromgroup, cindirect,
      cdisplayname, caction, climit, cinherited,
      crighttype, cdefault, ccontext,
      ccustom1, ccustom2, ccustom3, ccustom4, ccustom5, ccustom6, ccustom7, ccustom8, ccustom9
    FROM
      trightgroup;

DROP VIEW vportaluprightgroup;
DROP VIEW vportaldownrightgroup;

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
CREATE SEQUENCE reviewactor_sequence;
CREATE TABLE treviewactor (
  -- Database primary key
  crecorduid            INTEGER NOT NULL ,
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER NOT NULL,
  cactorfk            INTEGER NOT NULL,
  CONSTRAINT reviewactor_ts_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

CREATE OR REPLACE TRIGGER ticketactor_uid_tr BEFORE INSERT ON treviewactor
FOR EACH ROW
BEGIN
  IF :new.crecorduid IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'CRECORDUID cannot be specified for TREVIEWACTOR');
  ELSE
    SELECT reviewactor_sequence.NEXTVAL
    INTO   :new.crecorduid
    FROM   dual;
  END IF;
END;
/



-- REVIEWACCOUNTABLE table
CREATE SEQUENCE reviewaccountable_sequence;
CREATE TABLE treviewaccountable (
  -- Database primary key
  crecorduid            INTEGER NOT NULL ,
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER NOT NULL,
  caccountablefk            INTEGER NOT NULL,
  CONSTRAINT reviewaccountable_ts_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

CREATE OR REPLACE TRIGGER reviewaccountable_uid_tr BEFORE INSERT ON treviewaccountable
FOR EACH ROW
BEGIN
  IF :new.crecorduid IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'CRECORDUID cannot be specified for TREVIEWACCOUNTABLE');
  ELSE
    SELECT reviewaccountable_sequence.NEXTVAL
    INTO   :new.crecorduid
    FROM   dual;
  END IF;
END;
/


-- PORTALREVIEWACTOR table
CREATE TABLE tportalreviewactor (
  -- Database primary key
  crecorduid            INTEGER NOT NULL,
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER NOT NULL,
  cactorfk            INTEGER NOT NULL,
  CONSTRAINT previewactor_ts_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- PortalREVIEWACCOUNTABLE table
CREATE TABLE tportalreviewaccountable (
  -- Database primary key
  crecorduid            INTEGER NOT NULL,
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER NOT NULL,
  caccountablefk            INTEGER NOT NULL,
  CONSTRAINT previewaccountable_ts_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- delete cactorfk, caccountablefk from ttickerreview
ALTER TABLE tticketreview DROP COLUMN cactorfk;

ALTER TABLE tticketreview DROP COLUMN caccountablefk;

-- migrate actor accountable data to new tables
INSERT INTO treviewactor (ctimeslotfk, cticketreviewfk, cactorfk)
	SELECT i.ctimeslotfk, t.crecorduid AS cticketreviewfk, i.crecorduid AS cactorfk FROM tticketreview t
	INNER JOIN tidentity i on i.cidentityuid=t.cactoruid;

INSERT INTO treviewaccountable (ctimeslotfk, cticketreviewfk, caccountablefk) 
	SELECT i.ctimeslotfk, t.crecorduid AS cticketreviewfk, i.crecorduid AS caccountablefk FROM tticketreview t
	INNER JOIN tidentity i on i.cidentityuid=t.caccountableuid;

INSERT INTO tportalreviewactor (crecorduid, ctimeslotfk, cticketreviewfk, cactorfk)
	SELECT crecorduid, ctimeslotfk, cticketreviewfk, cactorfk FROM treviewactor a
	INNER JOIN timportlog i on i.cimportloguid = a.ctimeslotfk
	where i.cportal='1';
	
INSERT INTO tportalreviewaccountable (crecorduid, ctimeslotfk, cticketreviewfk, caccountablefk)
	SELECT crecorduid, ctimeslotfk, cticketreviewfk, caccountablefk FROM treviewaccountable a
	INNER JOIN timportlog i on i.cimportloguid = a.ctimeslotfk
	where i.cportal='1';

CREATE INDEX idx_metadata_ts_master ON tmetadata(ctimeslotfk, cmastermetadatafk);
CREATE INDEX idx_pmetadata_ts_master ON tportalmetadata(ctimeslotfk, cmastermetadatafk);

CREATE INDEX idx_tr_actor_timeslot ON treviewactor(ctimeslotfk);
CREATE INDEX idx_tr_actor_ticket ON treviewactor(cticketreviewfk);
CREATE INDEX idx_tr_actor ON treviewactor(cactorfk);

CREATE INDEX idx_ptr_actor_timeslot ON tportalreviewactor(ctimeslotfk);
CREATE INDEX idx_ptr_actor_ticket ON tportalreviewactor(cticketreviewfk);
CREATE INDEX idx_ptr_actor ON tportalreviewactor(cactorfk);

CREATE INDEX idx_tr_accountable_timeslot ON treviewaccountable(ctimeslotfk);
CREATE INDEX idx_tr_accountable_ticket ON treviewaccountable(cticketreviewfk);
CREATE INDEX idx_tr_accountable ON treviewaccountable(caccountablefk);

CREATE INDEX idx_ptr_accountable_timeslot ON tportalreviewaccountable(ctimeslotfk);
CREATE INDEX idx_ptr_accountable_ticket ON tportalreviewaccountable(cticketreviewfk);
CREATE INDEX idx_ptr_accountable ON tportalreviewaccountable(caccountablefk);

UPDATE tproperties SET cvalue='35' WHERE cpropertiesuid='VERSION';

commit;
