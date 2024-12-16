/* 
COPYRIGHT BRAINWAVE, all rights reserved.
This computer program is protected by copyright law and international treaties.
Unauthorized duplication or distribution of this program, or any portion of it, may result in severe civil or criminal penalties, and will be prosecuted to the maximum extent possible under the law.

Usage: Upgrades The database schema from version Braille R1 to Curie R1

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
