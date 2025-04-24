/* 
COPYRIGHT BRAINWAVE, all rights reserved.
This computer program is protected by copyright law and international treaties.
Unauthorized duplication or distribution of this program, or any portion of it, may result in severe civil or criminal penalties, and will be prosecuted to the maximum extent possible under the law.

Usage: Upgrades The database schema from version 2017 R2 to Curie R1

(c) Radiant Logic 2021

Execute the script 
psql -U user -d database -a -f "<ABSOLUTE PATH TO FILE>/postgresql_XXXXX_to_Curie.sql" -W > /tmp/output.txt 2>&1

Where:
 - -U user
 - -d databasename
 - -p portnumber
 - -a echo all
 - -f script file to execute
 - -W force prompt password

 See below for more information:
 https://www.postgresql.org/docs/13/app-psql.html 

Set default schema for this session only
Example:
 SET search_path = 'igrc';  
 \set SchemaVariable '''igrc'''  

IMPORTANT: Update and uncomment the following script block before running the script 
*/

/*
SET search_path = '<schema>';                        --  !REPLACE schema_name
\set SchemaVariable '''<schema>'''                   --  !REPLACE SchemaVariable
*/
 
-- Upgrade script to version 30
-- --------

-- Upgrade database from version 29 to version 30

-- update  for FS tables and views
ALTER TABLE tfsrightgroup ADD  corder INTEGER NOT NULL DEFAULT 0    ;
ALTER TABLE tportalfsrightgroup ADD  corder INTEGER    NOT NULL DEFAULT 0 ;

DROP INDEX idx_fsrightgroup_permission ;
DROP INDEX idx_fsrightgroup_vgroup ;
DROP INDEX idx_pfsrightgroup_permission ;
DROP INDEX idx_pfsrightgroup_vgroup ;



CREATE INDEX idx_fsrightgroup_permission ON tfsrightgroup(ctimeslotfk, cpermissionfk);
CREATE INDEX idx_fsrightgroup_vgroup ON tfsrightgroup(ctimeslotfk, cgroupfk);
CREATE INDEX idx_fsrightgroup_tspo ON tfsrightgroup(ctimeslotfk, cpermissionfk,corder);
CREATE INDEX idx_pfsrightgroup_permission ON tportalfsrightgroup(ctimeslotfk, cpermissionfk);
CREATE INDEX idx_pfsrightgroup_vgroup ON tportalfsrightgroup(ctimeslotfk, cgroupfk);
CREATE INDEX idx_pfsrightgroup_tspo ON tportalfsrightgroup(ctimeslotfk, cpermissionfk,corder);

DROP VIEW vfsaggregatedright;
DROP VIEW vportalfsaggregatedright;
    
-- add column cfstype to applicaiton
ALTER TABLE tapplication ADD cfstype CHAR(10);
ALTER TABLE tportalapplication ADD cfstype CHAR(10);

-- change size of action / basic for aclaccount* , aclgroup*, fsrightgroup*
-- taclaccount, taclgroup, tfsrightgroup, tportalaclaccount, tportalaclgroup, tportalfsrightgroup

ALTER TABLE taclaccount ALTER COLUMN caction TYPE VARCHAR(40);


ALTER TABLE taclaccount ALTER COLUMN cbasic TYPE VARCHAR(16);



ALTER TABLE taclgroup ALTER COLUMN caction TYPE VARCHAR(40);


ALTER TABLE taclgroup ALTER COLUMN cbasic TYPE VARCHAR(16);



ALTER TABLE tfsrightgroup ALTER COLUMN caction TYPE VARCHAR(40);


ALTER TABLE tfsrightgroup ALTER COLUMN cbasic TYPE VARCHAR(16);



ALTER TABLE tportalaclaccount ALTER COLUMN caction TYPE VARCHAR(40);


ALTER TABLE tportalaclaccount ALTER COLUMN cbasic TYPE VARCHAR(16);



ALTER TABLE tportalaclgroup ALTER COLUMN caction TYPE VARCHAR(40);


ALTER TABLE tportalaclgroup ALTER COLUMN cbasic TYPE VARCHAR(16);



ALTER TABLE tportalfsrightgroup ALTER COLUMN caction TYPE VARCHAR(40);


ALTER TABLE tportalfsrightgroup ALTER COLUMN cbasic TYPE VARCHAR(16);


-- create views that depend on fsrightgroup* only after the columns were changed ( required for PG) 
CREATE VIEW vfsaggregatedright AS
   SELECT      R.ctimeslotfk, R.caction, R.cbasic, R.corder, A.caccountfk, R.cpermissionfk
    FROM  tfsrightgroup R    INNER JOIN tvaccountgroup A ON R.cgroupfk = A.cparentvgroupfk ;
CREATE VIEW vportalfsaggregatedright AS
   SELECT  R.ctimeslotfk, R.caction,R.cbasic, R.corder, A.caccountfk, R.cpermissionfk
    FROM  tportalfsrightgroup R    INNER JOIN tportalvaccountgroup A ON R.cgroupfk = A.cparentvgroupfk ;

-- add privileged flag to account
ALTER TABLE timportaccount ADD cprivilegedaccount CHAR(1);
ALTER TABLE taccount ADD cprivilegedaccount CHAR(1);
ALTER TABLE tportalaccount ADD cprivilegedaccount CHAR(1);
ALTER TABLE timportaccount ADD CONSTRAINT importaccount_privileged_ck CHECK (cprivilegedaccount IN ('0', '1'));
ALTER TABLE taccount ADD CONSTRAINT account_privileged_ck CHECK (cprivilegedaccount IN ('0', '1'));
ALTER TABLE tportalaccount ADD CONSTRAINT paccount_privileged_ck CHECK (cprivilegedaccount IN ('0', '1'));

-- IMPORTMETADATA table
CREATE TABLE timportmetadata (
  -- Sandbox (part of the primary key)
  cimportlogfk          VARCHAR(64)   NOT NULL,
  -- Object permanent key
  cmetadatauid          VARCHAR(64)   NOT NULL,
  -- Object information
  csilofk               VARCHAR(64),
  corganisationfk       VARCHAR(64),
  cidentityfk           VARCHAR(64),
  crepositoryfk         VARCHAR(64),
  cgroup1fk             VARCHAR(64),
  cgroup2fk             VARCHAR(64),
  caccountfk            VARCHAR(64),
  cperimeterfk          VARCHAR(64),
  cpermission1fk        VARCHAR(64),
  cpermission2fk        VARCHAR(64),
  capplicationfk        VARCHAR(64),
  cassetfk              VARCHAR(64),
  ctorenew              CHAR(1)       NOT NULL,
  corigin               CHAR(1)       NOT NULL,
  ckey                  VARCHAR(64)   NOT NULL,
  chash                 VARCHAR(320)  NOT NULL,
  cjointypes            VARCHAR(32)   NOT NULL,
  cvalue1string         VARCHAR(400),
  cvalue2string         VARCHAR(400),
  cvalue1integer        INTEGER,
  cvalue2integer        INTEGER,
  cvalue1double         DOUBLE PRECISION,
  cvalue2double         DOUBLE PRECISION,
  cvalue1date           VARCHAR(15),
  cvalue1day            INTEGER,
  cvalue2date           VARCHAR(15),
  cvalue2day            INTEGER,
  cvalueboolean         CHAR(1),
  cdescription          VARCHAR(4000),
  cdetails              TEXT,
  CONSTRAINT importmetadata_uid_pk PRIMARY KEY (cmetadatauid, cimportlogfk),
  CONSTRAINT importmetadata_importlog_fk FOREIGN KEY (cimportlogfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT importmetadata_boolean_ck CHECK (cvalueboolean IN ('0', '1')),
  CONSTRAINT importmetadata_torenew_ck CHECK (ctorenew IN ('0', '1')),
  CONSTRAINT importmetadata_origin_ck CHECK (corigin IN ('C', 'P', 'W')) -- C=Collector, P=comPuted, W=Web
);

-- METADATA table
CREATE SEQUENCE metadata_sequence;
CREATE TABLE tmetadata (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL      DEFAULT NEXTVAL('metadata_sequence'),
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object permanent key
  cmetadatauid          VARCHAR(64)   NOT NULL,
  -- Object information
  corganisationfk       INTEGER,
  cidentityfk           INTEGER,
  crepositoryfk         INTEGER,
  cgroup1fk             INTEGER,
  cgroup2fk             INTEGER,
  caccountfk            INTEGER,
  cperimeterfk          INTEGER,
  cpermission1fk        INTEGER,
  cpermission2fk        INTEGER,
  capplicationfk        INTEGER,
  cassetfk              INTEGER,
  ctorenew              CHAR(1)       NOT NULL,
  corigin               CHAR(1)       NOT NULL,
  ckey                  VARCHAR(64)   NOT NULL,
  chash                 VARCHAR(320)  NOT NULL,
  cjointypes            VARCHAR(32)   NOT NULL,
  cvalue1string         VARCHAR(400),
  cvalue2string         VARCHAR(400),
  cvalue1integer        INTEGER,
  cvalue2integer        INTEGER,
  cvalue1double         DOUBLE PRECISION,
  cvalue2double         DOUBLE PRECISION,
  cvalue1date           VARCHAR(15),
  cvalue1day            INTEGER,
  cvalue2date           VARCHAR(15),
  cvalue2day            INTEGER,
  cvalueboolean         CHAR(1),
  cdescription          VARCHAR(4000),
  cdetails              TEXT,
  CONSTRAINT metadata_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT metadata_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT metadata_uid_uk UNIQUE (ctimeslotfk, cmetadatauid),
  CONSTRAINT metadata_boolean_ck CHECK (cvalueboolean IN ('0', '1')),
  CONSTRAINT metadata_torenew_ck CHECK (ctorenew IN ('0', '1')),
  CONSTRAINT metadata_origin_ck CHECK (corigin IN ('C', 'P', 'W')) -- C=Collector, P=comPuted, W=Web
);


CREATE INDEX idx_metadata_timeslot ON tmetadata(ctimeslotfk);
CREATE INDEX idx_metadata_organisation ON tmetadata(corganisationfk);
CREATE INDEX idx_metadata_identity ON tmetadata(cidentityfk);
CREATE INDEX idx_metadata_repository ON tmetadata(crepositoryfk);
CREATE INDEX idx_metadata_group1 ON tmetadata(cgroup1fk);
CREATE INDEX idx_metadata_group2 ON tmetadata(cgroup2fk);
CREATE INDEX idx_metadata_account ON tmetadata(caccountfk);
CREATE INDEX idx_metadata_perimeter ON tmetadata(cperimeterfk);
CREATE INDEX idx_metadata_cpermission1fk ON tmetadata(cpermission1fk);
CREATE INDEX idx_metadata_cpermission2fk ON tmetadata(cpermission2fk);
CREATE INDEX idx_metadata_application ON tmetadata(capplicationfk);
CREATE INDEX idx_metadata_asset ON tmetadata(cassetfk);
CREATE INDEX idx_metadata_originrenew ON tmetadata(corigin,ctorenew);
CREATE INDEX idx_metadata_hash ON tmetadata(chash,ctimeslotfk);
CREATE INDEX idx_metadata_value1string ON tmetadata(ckey,ctimeslotfk,cvalue1string);
CREATE INDEX idx_metadata_value2string ON tmetadata(ckey,ctimeslotfk,cvalue2string);
CREATE INDEX idx_metadata_value1integer ON tmetadata(ckey,ctimeslotfk,cvalue1integer);
CREATE INDEX idx_metadata_value2integer ON tmetadata(ckey,ctimeslotfk,cvalue2integer);
CREATE INDEX idx_metadata_value1double ON tmetadata(ckey,ctimeslotfk,cvalue1double);
CREATE INDEX idx_metadata_value2double ON tmetadata(ckey,ctimeslotfk,cvalue2double);
CREATE INDEX idx_metadata_value1date ON tmetadata(ckey,ctimeslotfk,cvalue1date);
CREATE INDEX idx_metadata_value1day ON tmetadata(ckey,ctimeslotfk,cvalue1day);
CREATE INDEX idx_metadata_value2date ON tmetadata(ckey,ctimeslotfk,cvalue2date);
CREATE INDEX idx_metadata_value2day ON tmetadata(ckey,ctimeslotfk,cvalue2day);
CREATE INDEX idx_metadata_valueboolean ON tmetadata(ckey,ctimeslotfk,cvalueboolean);

-- PORTALMETADATA table
CREATE TABLE tportalmetadata (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL,
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object permanent key
  cmetadatauid          VARCHAR(64)   NOT NULL,
  -- Object information
  corganisationfk       INTEGER,
  cidentityfk           INTEGER,
  crepositoryfk         INTEGER,
  cgroup1fk             INTEGER,
  cgroup2fk             INTEGER,
  caccountfk            INTEGER,
  cperimeterfk          INTEGER,
  cpermission1fk        INTEGER,
  cpermission2fk        INTEGER,
  capplicationfk        INTEGER,
  cassetfk              INTEGER,
  ctorenew              CHAR(1)       NOT NULL,
  corigin               CHAR(1)       NOT NULL,
  ckey                  VARCHAR(64)   NOT NULL,
  chash                 VARCHAR(320)  NOT NULL,
  cjointypes            VARCHAR(32)   NOT NULL,
  cvalue1string         VARCHAR(400),
  cvalue2string         VARCHAR(400),
  cvalue1integer        INTEGER,
  cvalue2integer        INTEGER,
  cvalue1double         DOUBLE PRECISION,
  cvalue2double         DOUBLE PRECISION,
  cvalue1date           VARCHAR(15),
  cvalue1day            INTEGER,
  cvalue2date           VARCHAR(15),
  cvalue2day            INTEGER,
  cvalueboolean         CHAR(1),
  cdescription          VARCHAR(4000),
  cdetails              TEXT,
  CONSTRAINT pmetadata_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT pmetadata_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT pmetadata_uid_uk UNIQUE (ctimeslotfk, cmetadatauid),
  CONSTRAINT pmetadata_boolean_ck CHECK (cvalueboolean IN ('0', '1')),
  CONSTRAINT pmetadata_torenew_ck CHECK (ctorenew IN ('0', '1')),
  CONSTRAINT pmetadata_origin_ck CHECK (corigin IN ('C', 'P', 'W')) -- C=Collector, P=comPuted, W=Web
);

CREATE INDEX idx_pmetadata_timeslot ON tportalmetadata(ctimeslotfk);
CREATE INDEX idx_pmetadata_organisation ON tportalmetadata(corganisationfk);
CREATE INDEX idx_pmetadata_identity ON tportalmetadata(cidentityfk);
CREATE INDEX idx_pmetadata_repository ON tportalmetadata(crepositoryfk);
CREATE INDEX idx_pmetadata_group1 ON tportalmetadata(cgroup1fk);
CREATE INDEX idx_pmetadata_group2 ON tportalmetadata(cgroup2fk);
CREATE INDEX idx_pmetadata_account ON tportalmetadata(caccountfk);
CREATE INDEX idx_pmetadata_perimeter ON tportalmetadata(cperimeterfk);
CREATE INDEX idx_pmetadata_cpermission1fk ON tportalmetadata(cpermission1fk);
CREATE INDEX idx_pmetadata_cpermission2fk ON tportalmetadata(cpermission2fk);
CREATE INDEX idx_pmetadata_application ON tportalmetadata(capplicationfk);
CREATE INDEX idx_pmetadata_asset ON tportalmetadata(cassetfk);
CREATE INDEX idx_pmetadata_originrenew ON tportalmetadata(corigin,ctorenew);
CREATE INDEX idx_pmetadata_hash ON tportalmetadata(chash,ctimeslotfk);
CREATE INDEX idx_pmetadata_value1string ON tportalmetadata(ckey,ctimeslotfk,cvalue1string);
CREATE INDEX idx_pmetadata_value2string ON tportalmetadata(ckey,ctimeslotfk,cvalue2string);
CREATE INDEX idx_pmetadata_value1integer ON tportalmetadata(ckey,ctimeslotfk,cvalue1integer);
CREATE INDEX idx_pmetadata_value2integer ON tportalmetadata(ckey,ctimeslotfk,cvalue2integer);
CREATE INDEX idx_pmetadata_value1double ON tportalmetadata(ckey,ctimeslotfk,cvalue1double);
CREATE INDEX idx_pmetadata_value2double ON tportalmetadata(ckey,ctimeslotfk,cvalue2double);
CREATE INDEX idx_pmetadata_value1date ON tportalmetadata(ckey,ctimeslotfk,cvalue1date);
CREATE INDEX idx_pmetadata_value1day ON tportalmetadata(ckey,ctimeslotfk,cvalue1day);
CREATE INDEX idx_pmetadata_value2date ON tportalmetadata(ckey,ctimeslotfk,cvalue2date);
CREATE INDEX idx_pmetadata_value2day ON tportalmetadata(ckey,ctimeslotfk,cvalue2day);
CREATE INDEX idx_pmetadata_valueboolean ON tportalmetadata(ckey,ctimeslotfk,cvalueboolean);

-- ORGANISATIONVIEW table
CREATE TABLE torganisationreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  corganisationfk       INTEGER       NOT NULL,
  CONSTRAINT organisationreview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- ASSETREVIEW table
CREATE TABLE tassetreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  cassetfk              INTEGER       NOT NULL,
  CONSTRAINT assetreview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- PORTALORGANISATIONVIEW table
CREATE TABLE tportalorganisationreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  corganisationfk       INTEGER       NOT NULL,
  CONSTRAINT porgreview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

-- PORTALASSETREVIEW table
CREATE TABLE tportalassetreview (
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       INTEGER       NOT NULL,
  cassetfk              INTEGER       NOT NULL,
  CONSTRAINT passetreview_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);

--Fix ccampaignfk missed in tportalmanager
ALTER TABLE tportalmanager ADD ccampaignfk INTEGER;

--IGRC-2782 Remove the uniqueness constraint 

ALTER TABLE timportaclaccount DROP CONSTRAINT importaclaccount_uids_uk;
ALTER TABLE timportaclgroup DROP CONSTRAINT importaclgroup_uids_uk;
ALTER TABLE taclaccount DROP CONSTRAINT aclaccount_uniqueness_uk;
ALTER TABLE taclgroup DROP CONSTRAINT aclgroup_uniqueness_uk;
ALTER TABLE tportalaclaccount DROP CONSTRAINT paclaccount_uniqueness_uk;
ALTER TABLE tportalaclgroup DROP CONSTRAINT paclgroup_uniqueness_uk;

CREATE INDEX idx_importaclaccount_uids ON timportaclaccount(caccountfk, cpermissionfk, caction, cnegative, corder, cinherited, cinheritanceflags, cpropagationflags, cimportlogfk);
CREATE INDEX idx_aclaccount_uids ON taclaccount(caccountfk, cpermissionfk, caction, cnegative, corder, cinherited, cinheritanceflags, cpropagationflags);
CREATE INDEX idx_paclaccount_uids ON tportalaclaccount(caccountfk, cpermissionfk, caction, cnegative, corder, cinherited, cinheritanceflags, cpropagationflags);
CREATE INDEX idx_importaclgroup_uids ON timportaclgroup(cgroupfk, cpermissionfk, caction, cnegative, corder, cinherited, cinheritanceflags, cpropagationflags, cimportlogfk);
CREATE INDEX idx_aclgroup_uids ON taclgroup(cgroupfk, cpermissionfk, caction, cnegative, corder, cinherited, cinheritanceflags, cpropagationflags);
CREATE INDEX idx_paclgroup_uids ON tportalaclgroup(cgroupfk, cpermissionfk, caction, cnegative, corder, cinherited, cinheritanceflags, cpropagationflags);

-- add repositoryfamily to repository tables
ALTER TABLE timportrepository ADD crepositoryfamily VARCHAR(32);
ALTER TABLE trepository ADD crepositoryfamily VARCHAR(32);
ALTER TABLE tportalrepository ADD crepositoryfamily VARCHAR(32);

-- IGRC-2742 Add a field in ticketlog and ticketaction to be able to nationalize the title
ALTER TABLE tticketlog ADD cothertitles VARCHAR(4000);
ALTER TABLE tticketaction ADD cothertitles VARCHAR(4000);

ALTER TABLE tticketreview DROP CONSTRAINT ticketreview_type_ck;
ALTER TABLE tticketreview ADD CONSTRAINT ticketreview_type_ck CHECK (creviewtype IN ('I', 'O', 'M', 'P', 'A', 'C', 'R', 'T', 'N', 'G', 'Y', 'Z', 'E', 'L', 'U', 'S', 'F', 'X', 'W'));

ALTER TABLE timportapplication ADD capplicationfamily VARCHAR(32);
ALTER TABLE tapplication ADD capplicationfamily VARCHAR(32);
ALTER TABLE tportalapplication ADD capplicationfamily VARCHAR(32);
CREATE INDEX idx_application_family ON tapplication(ctimeslotfk,capplicationfamily);
CREATE INDEX idx_papplication_family ON tportalapplication(ctimeslotfk,capplicationfamily);

CREATE INDEX idx_identity_hrcode ON tidentity(ctimeslotfk, chrcode);
CREATE INDEX idx_importidentity_hrcode ON timportidentity(chrcode, cimportlogfk);
CREATE INDEX idx_pidentity_hrcode ON tportalidentity(ctimeslotfk, chrcode);

CREATE INDEX idx_accountapp_accountfk ON taccountapp(caccountfk);
CREATE INDEX idx_accountapp_applicationfk ON taccountapp(capplicationfk);
CREATE INDEX idx_paccountapp_accountfk ON tportalaccountapp(caccountfk);
CREATE INDEX idx_paccountapp_applicationfk ON tportalaccountapp(capplicationfk);


CREATE OR REPLACE VIEW vaggregatedright (
        ctimeslotfk, crightuid, cdisplayname, cfromgroup, cinherited, cindirect, caction, climit, crepositoryfk, caccountfk, cpermissionfk, cperimeterfk,
        crighttype,cdefault,ccontext,ccustom1,ccustom2,ccustom3,ccustom4,ccustom5,ccustom6,ccustom7,ccustom8,ccustom9
    ) AS
SELECT  direct.ctimeslotfk,direct.crightuid,direct.cdisplayname,direct.cfromgroup,direct.cinherited,direct.cindirect,direct.caction,direct.climit,direct.crepositoryfk,
		direct.caccountfk,direct.cpermissionfk,direct.cperimeterfk,direct.crighttype,direct.cdefault,direct.ccontext,direct.ccustom1,direct.ccustom2,direct.ccustom3,
		direct.ccustom4,direct.ccustom5,direct.ccustom6,direct.ccustom7,direct.ccustom8,direct.ccustom9
FROM (
		SELECT r.ctimeslotfk,r.crightuid, r.cdisplayname, r.cfromgroup, r.cinherited, r.cindirect, r.caction, r.climit,
          r.crepositoryfk, r.caccountfk, r.cpermissionfk,
          CASE
            WHEN r.cperimeterfk IS NULL THEN -1
            ELSE r.cperimeterfk
          END AS cperimeterfk,
          r.crighttype, r.cdefault, r.ccontext,
          r.ccustom1, r.ccustom2, r.ccustom3, r.ccustom4, r.ccustom5, r.ccustom6, r.ccustom7, r.ccustom8, r.ccustom9
        FROM tright r
    ) direct
UNION ALL
SELECT  fromgroup.ctimeslotfk,fromgroup.crightuid,fromgroup.cdisplayname,fromgroup.cfromgroup,fromgroup.cinherited,fromgroup.cindirect,fromgroup.caction,fromgroup.climit,
	fromgroup.crepositoryfk,fromgroup.caccountfk,fromgroup.cpermissionfk,fromgroup.cperimeterfk,fromgroup.crighttype,fromgroup.cdefault,fromgroup.ccontext,fromgroup.ccustom1,
	fromgroup.ccustom2,fromgroup.ccustom3,fromgroup.ccustom4,fromgroup.ccustom5,fromgroup.ccustom6,fromgroup.ccustom7,fromgroup.ccustom8,fromgroup.ccustom9
FROM (
		SELECT r.ctimeslotfk,r.crightgroupuid AS crightuid,r.cdisplayname,'1'::CHARACTER(1) AS cfromgroup,r.cinherited,r.cindirect,r.caction,r.climit,r.crepositoryfk,a.caccountfk,r.cpermissionfk,
            CASE
                WHEN (r.cperimeterfk IS NULL)
                THEN '-1'::INTEGER
                ELSE r.cperimeterfk
            END AS cperimeterfk,r.crighttype,r.cdefault,r.ccontext,r.ccustom1,r.ccustom2,r.ccustom3,r.ccustom4,r.ccustom5,r.ccustom6,r.ccustom7,r.ccustom8,r.ccustom9
      	FROM trightgroup r
          INNER JOIN taccountgroup a ON r.cgroupfk = a.cparentgroupfk
    ) fromgroup;



CREATE OR REPLACE VIEW vportalaggregatedright (ctimeslotfk,crightuid,cdisplayname,cfromgroup,cinherited,cindirect,caction,climit,crepositoryfk,caccountfk,cpermissionfk,cperimeterfk,crighttype,cdefault,
			ccontext,ccustom1,ccustom2,ccustom3,ccustom4,ccustom5,ccustom6,ccustom7,ccustom8,ccustom9) 
			
	AS SELECT direct.ctimeslotfk,direct.crightuid,direct.cdisplayname,direct.cfromgroup,direct.cinherited,direct.cindirect,direct.caction,direct.climit,direct.crepositoryfk,
			direct.caccountfk,direct.cpermissionfk,direct.cperimeterfk,direct.crighttype,direct.cdefault,direct.ccontext,direct.ccustom1,direct.ccustom2,direct.ccustom3,
			direct.ccustom4,direct.ccustom5,direct.ccustom6,direct.ccustom7,direct.ccustom8,direct.ccustom9 

	FROM (
	        SELECT r.ctimeslotfk,r.crightuid,r.cdisplayname,r.cfromgroup,r.cinherited,r.cindirect,r.caction,r.climit,r.crepositoryfk,r.caccountfk,r.cpermissionfk,
			CASE
			    WHEN (r.cperimeterfk IS NULL)
			    THEN '-1'::INTEGER
			    ELSE r.cperimeterfk
			END AS cperimeterfk,
			r.crighttype,r.cdefault,r.ccontext,r.ccustom1,r.ccustom2,r.ccustom3,r.ccustom4,r.ccustom5,r.ccustom6,r.ccustom7,r.ccustom8,r.ccustom9
			FROM tportalright r
    	) direct
UNION ALL
SELECT fromgroup.ctimeslotfk,fromgroup.crightuid,fromgroup.cdisplayname,fromgroup.cfromgroup,fromgroup.cinherited,fromgroup.cindirect,fromgroup.caction,
	fromgroup.climit,fromgroup.crepositoryfk,fromgroup.caccountfk,fromgroup.cpermissionfk,fromgroup.cperimeterfk,fromgroup.crighttype,fromgroup.cdefault,fromgroup.ccontext,
	fromgroup.ccustom1,fromgroup.ccustom2,fromgroup.ccustom3,fromgroup.ccustom4,fromgroup.ccustom5,fromgroup.ccustom6,fromgroup.ccustom7,fromgroup.ccustom8,fromgroup.ccustom9
FROM
    (
        SELECT r.ctimeslotfk,r.crightgroupuid AS crightuid,r.cdisplayname,'1'::CHARACTER(1) AS cfromgroup,r.cinherited,r.cindirect,r.caction,r.climit,r.crepositoryfk,a.caccountfk,r.cpermissionfk,
		CASE
			WHEN (r.cperimeterfk IS NULL)
			THEN '-1'::INTEGER
			ELSE r.cperimeterfk
		END AS cperimeterfk,
		r.crighttype,r.cdefault,r.ccontext,r.ccustom1,r.ccustom2,r.ccustom3,r.ccustom4,r.ccustom5,r.ccustom6,r.ccustom7,r.ccustom8,r.ccustom9
        FROM (tportalrightgroup r JOIN tportalaccountgroup a ON ((r.cgroupfk = a.cparentgroupfk)))
    ) fromgroup;


--indexes of review tables

CREATE INDEX idx_accountreview ON taccountreview(caccountfk);
CREATE INDEX idx_accountreview_ticket ON taccountreview(cticketreviewfk);

CREATE INDEX idx_allocationreview ON tallocationreview(callocationfk);
CREATE INDEX idx_allocationreview_ticket ON tallocationreview(cticketreviewfk);

CREATE INDEX idx_bossreview_ticket ON tbossreview(cticketreviewfk);
CREATE INDEX idx_bossreview ON tbossreview(cbossfk);

CREATE INDEX idx_identityreview_ticket ON tidentityreview(cticketreviewfk);
CREATE INDEX idx_identityreview ON tidentityreview(cidentityfk);

CREATE INDEX idx_reconreview_ticket ON treconciliationreview(cticketreviewfk);
CREATE INDEX idx_reconreview ON treconciliationreview(creconciliationfk);

CREATE INDEX idx_rightreview_ticket ON trightreview(cticketreviewfk);
CREATE INDEX idx_rightreview_account ON trightreview(caccountfk);
CREATE INDEX idx_rightreview_permission ON trightreview(cpermissionfk);
CREATE INDEX idx_rightreview_perimeter ON trightreview(cperimeterfk);

CREATE INDEX idx_appreview_timeslot ON tapplicationreview(ctimeslotfk);
CREATE INDEX idx_appreview_ticket ON tapplicationreview(cticketreviewfk);
CREATE INDEX idx_appreview_application ON tapplicationreview(capplicationfk);

CREATE INDEX idx_permreview_timeslot ON tpermissionreview(ctimeslotfk);
CREATE INDEX idx_permreview_ticket ON tpermissionreview(cticketreviewfk);
CREATE INDEX idx_permreview_application ON tpermissionreview(cpermissionfk);

CREATE INDEX idx_groupreview_timeslot ON tgroupreview(ctimeslotfk);
CREATE INDEX idx_groupreview_ticket ON tgroupreview(cticketreviewfk);
CREATE INDEX idx_groupreview_group ON tgroupreview(cgroupfk);

CREATE INDEX idx_reporeview_timeslot ON trepositoryreview(ctimeslotfk);
CREATE INDEX idx_reporeview_ticket ON trepositoryreview(cticketreviewfk);
CREATE INDEX idx_reporeview_repository ON trepositoryreview(crepositoryfk);

CREATE INDEX idx_orgmanagerrev_timeslot ON torgmanagerreview(ctimeslotfk);
CREATE INDEX idx_orgmanagerrev_ticket ON torgmanagerreview(cticketreviewfk);
CREATE INDEX idx_orgmanagerrev_manager ON torgmanagerreview(cmanagerfk);

CREATE INDEX idx_appmanagerrev_timeslot ON tappmanagerreview(ctimeslotfk);
CREATE INDEX idx_appmanagerrev_ticket ON tappmanagerreview(cticketreviewfk);
CREATE INDEX idx_appmanagerrev_manager ON tappmanagerreview(cmanagerfk);

CREATE INDEX idx_permmanagerrev_timeslot ON tpermmanagerreview(ctimeslotfk);
CREATE INDEX idx_permmanagerrev_ticket ON tpermmanagerreview(cticketreviewfk);
CREATE INDEX idx_permmanagerrev_manager ON tpermmanagerreview(cmanagerfk);

CREATE INDEX idx_groupmanagerrev_timeslot ON tgroupmanagerreview(ctimeslotfk);
CREATE INDEX idx_groupmanagerrev_ticket ON tgroupmanagerreview(cticketreviewfk);
CREATE INDEX idx_groupmanagerrev_manager ON tgroupmanagerreview(cmanagerfk);

CREATE INDEX idx_repomanagerrev_timeslot ON trepomanagerreview(ctimeslotfk);
CREATE INDEX idx_repomanagerrev_ticket ON trepomanagerreview(cticketreviewfk);
CREATE INDEX idx_repomanagerrev_manager ON trepomanagerreview(cmanagerfk);

CREATE INDEX idx_assetrev_timeslot ON tassetreview(ctimeslotfk);
CREATE INDEX idx_assetrev_ticket ON tassetreview(cticketreviewfk);
CREATE INDEX idx_assetrev ON tassetreview(cassetfk);

CREATE INDEX idx_orgreview_timeslot ON torganisationreview(ctimeslotfk);
CREATE INDEX idx_orgreview_ticket ON torganisationreview(cticketreviewfk);
CREATE INDEX idx_orgreview_org ON torganisationreview(corganisationfk);

CREATE INDEX idx_fsrightreview_ticket ON tfsrightreview(cticketreviewfk);
CREATE INDEX idx_fsrightreview_account ON tfsrightreview(caccountfk);
CREATE INDEX idx_fsrightreview_permission ON tfsrightreview(cpermissionfk);

--indexes of portal review tables

CREATE INDEX idx_paccountreview ON tportalaccountreview(caccountfk);
CREATE INDEX idx_paccountreview_ticket ON tportalaccountreview(cticketreviewfk);

CREATE INDEX idx_pallocationreview ON tportalallocationreview(callocationfk);
CREATE INDEX idx_pallocationreview_ticket ON tportalallocationreview(cticketreviewfk);

CREATE INDEX idx_pbossreview_ticket ON tportalbossreview(cticketreviewfk);
CREATE INDEX idx_pbossreview ON tportalbossreview(cbossfk);

CREATE INDEX idx_pidentityreview_ticket ON tportalidentityreview(cticketreviewfk);
CREATE INDEX idx_pidentityreview ON tportalidentityreview(cidentityfk);

CREATE INDEX idx_preconreview_ticket ON tportalreconciliationreview(cticketreviewfk);
CREATE INDEX idx_preconreview ON tportalreconciliationreview(creconciliationfk);

CREATE INDEX idx_prightreview_ticket ON tportalrightreview(cticketreviewfk);
CREATE INDEX idx_prightreview_account ON tportalrightreview(caccountfk);
CREATE INDEX idx_prightreview_permission ON tportalrightreview(cpermissionfk);
CREATE INDEX idx_prightreview_perimeter ON tportalrightreview(cperimeterfk);

CREATE INDEX idx_pappreview_timeslot ON tportalapplicationreview(ctimeslotfk);
CREATE INDEX idx_pappreview_ticket ON tportalapplicationreview(cticketreviewfk);
CREATE INDEX idx_pappreview_application ON tportalapplicationreview(capplicationfk);

CREATE INDEX idx_ppermreview_timeslot ON tportalpermissionreview(ctimeslotfk);
CREATE INDEX idx_ppermreview_ticket ON tportalpermissionreview(cticketreviewfk);
CREATE INDEX idx_ppermreview_application ON tportalpermissionreview(cpermissionfk);

CREATE INDEX idx_pgroupreview_timeslot ON tportalgroupreview(ctimeslotfk);
CREATE INDEX idx_pgroupreview_ticket ON tportalgroupreview(cticketreviewfk);
CREATE INDEX idx_pgroupreview_group ON tportalgroupreview(cgroupfk);

CREATE INDEX idx_preporeview_timeslot ON tportalrepositoryreview(ctimeslotfk);
CREATE INDEX idx_preporeview_ticket ON tportalrepositoryreview(cticketreviewfk);
CREATE INDEX idx_preporeview_repository ON tportalrepositoryreview(crepositoryfk);

CREATE INDEX idx_porgmanagerrev_timeslot ON tportalorgmanagerreview(ctimeslotfk);
CREATE INDEX idx_porgmanagerrev_ticket ON tportalorgmanagerreview(cticketreviewfk);
CREATE INDEX idx_porgmanagerrev_manager ON tportalorgmanagerreview(cmanagerfk);

CREATE INDEX idx_pappmanagerrev_timeslot ON tportalappmanagerreview(ctimeslotfk);
CREATE INDEX idx_pappmanagerrev_ticket ON tportalappmanagerreview(cticketreviewfk);
CREATE INDEX idx_pappmanagerrev_manager ON tportalappmanagerreview(cmanagerfk);

CREATE INDEX idx_ppermmanagerrev_timeslot ON tportalpermmanagerreview(ctimeslotfk);
CREATE INDEX idx_ppermmanagerrev_ticket ON tportalpermmanagerreview(cticketreviewfk);
CREATE INDEX idx_ppermmanagerrev_manager ON tportalpermmanagerreview(cmanagerfk);

CREATE INDEX idx_pgroupmanagerrev_timeslot ON tportalgroupmanagerreview(ctimeslotfk);
CREATE INDEX idx_pgroupmanagerrev_ticket ON tportalgroupmanagerreview(cticketreviewfk);
CREATE INDEX idx_pgroupmanagerrev_manager ON tportalgroupmanagerreview(cmanagerfk);

CREATE INDEX idx_prepomanagerrev_timeslot ON tportalrepomanagerreview(ctimeslotfk);
CREATE INDEX idx_prepomanagerrev_ticket ON tportalrepomanagerreview(cticketreviewfk);
CREATE INDEX idx_prepomanagerrev_manager ON tportalrepomanagerreview(cmanagerfk);

CREATE INDEX idx_passetrev_timeslot ON tportalassetreview(ctimeslotfk);
CREATE INDEX idx_passetrev_ticket ON tportalassetreview(cticketreviewfk);
CREATE INDEX idx_passetrev ON tportalassetreview(cassetfk);

CREATE INDEX idx_porgreview_timeslot ON tportalorganisationreview(ctimeslotfk);
CREATE INDEX idx_porgreview_ticket ON tportalorganisationreview(cticketreviewfk);
CREATE INDEX idx_porgreview_org ON tportalorganisationreview(corganisationfk);

CREATE INDEX idx_pfsrightreview_ticket ON tportalfsrightreview(cticketreviewfk);
CREATE INDEX idx_pfsrightreview_account ON tportalfsrightreview(caccountfk);
CREATE INDEX idx_pfsrightreview_permission ON tportalfsrightreview(cpermissionfk);

ALTER TABLE timportlog ADD creference VARCHAR(32);

ALTER TABLE tcontroldiscrepancy ADD crisklevel INTEGER;
ALTER TABLE tportalcontroldiscrepancy ADD crisklevel INTEGER;
ALTER TABLE texception ADD crisklevel INTEGER;
ALTER TABLE tportalexception ADD crisklevel INTEGER;

-- BUSINESSACTIVITY table
CREATE SEQUENCE businessactivity_sequence;
CREATE TABLE tbusinessactivity (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL      DEFAULT NEXTVAL('businessactivity_sequence'),
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cidentityfk           INTEGER       NOT NULL,
  cpermissionfk         INTEGER       NOT NULL,
  CONSTRAINT businessact_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT businessact_uid_pk PRIMARY KEY (crecorduid)
);


CREATE INDEX idx_businessact_identityfk ON tbusinessactivity(cidentityfk);
CREATE INDEX idx_businessact_permissionfk ON tbusinessactivity(cpermissionfk);

-- PORTALBUSINESSACTIVITY table
CREATE TABLE tportalbusinessactivity (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL,
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cidentityfk           INTEGER       NOT NULL,
  cpermissionfk         INTEGER       NOT NULL,
  CONSTRAINT pbusinessact_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT pbusinessact_uid_pk PRIMARY KEY (crecorduid)
);

CREATE INDEX idx_pbusinessact_identityfk ON tportalbusinessactivity(cidentityfk);
CREATE INDEX idx_pbusinessact_permissionfk ON tportalbusinessactivity(cpermissionfk);

-- Upgrade script to version 31
-- --------

-- Upgrade database from version 30 to version 31

-- add progress status in timportlog to follow the fine grained operation and prevent from starting the same one a second time
ALTER TABLE timportlog ADD cprogressstatus          VARCHAR(64);
ALTER TABLE timportlog ADD clastprogressdate        VARCHAR(15);
ALTER TABLE timportlog ADD clastprogressday         INTEGER;

-- expand reason in exception table

ALTER TABLE texception ALTER COLUMN creason TYPE VARCHAR(4000);


-- expand reason in exception portal table

ALTER TABLE tportalexception ALTER COLUMN creason TYPE VARCHAR(4000);


-- add columns in ticketlog to handle the on-hold feature
ALTER TABLE tticketlog ADD cnbreleasedsubproc       INTEGER;
ALTER TABLE tticketlog ADD cnbonholdsubproc         INTEGER;
ALTER TABLE tticketlog ADD cnbcandidates            INTEGER;
ALTER TABLE tticketlog ADD ccandidatefullnames      VARCHAR(4000);

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

ALTER TABLE timportaclaccount ALTER COLUMN caction TYPE VARCHAR(40);


ALTER TABLE timportaclgroup ALTER COLUMN caction TYPE VARCHAR(40);


ALTER TABLE tticketaction ADD creviewerfk           INTEGER;
ALTER TABLE tticketaction ADD crevieweruid          VARCHAR(64);
ALTER TABLE tticketaction ADD creviewerfullname     VARCHAR(96);
ALTER TABLE tticketaction ADD caccountablefk        INTEGER;
ALTER TABLE tticketaction ADD caccountableuid       VARCHAR(64);
ALTER TABLE tticketaction ADD caccountablefullname  VARCHAR(96);
ALTER TABLE tticketaction ADD ccategory             VARCHAR(250);
ALTER TABLE tticketaction ADD cworkloadtime         INTEGER;

ALTER TABLE tticketreview DROP CONSTRAINT ticketreview_type_ck;
ALTER TABLE tticketreview ADD cmetadatauid          VARCHAR(64);
ALTER TABLE tticketreview ADD cparentgroupuid       VARCHAR(64);
ALTER TABLE tticketreview ADD cparentpermuid        VARCHAR(64);
ALTER TABLE tticketreview ADD cactorfk              INTEGER;
ALTER TABLE tticketreview ADD cactoruid             VARCHAR(64);
ALTER TABLE tticketreview ADD cactorfullname        VARCHAR(96);
ALTER TABLE tticketreview ADD caccountablefk        INTEGER;
ALTER TABLE tticketreview ADD caccountableuid       VARCHAR(64);
ALTER TABLE tticketreview ADD caccountablefullname  VARCHAR(96);
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
ALTER TABLE tmetadata ADD cactorfullname VARCHAR(96);
ALTER TABLE tmetadata ADD CONSTRAINT metadata_charact_ck CHECK (ccharacteristic IN ('0', '1'));
ALTER TABLE tmetadata DROP CONSTRAINT metadata_origin_ck;
ALTER TABLE tmetadata DROP CONSTRAINT metadata_boolean_ck;

-- METADATA table
CREATE SEQUENCE metadatavalue_sequence;
CREATE TABLE tmetadatavalue (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL      DEFAULT NEXTVAL('metadatavalue_sequence'),
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object permanent key
  cmetadatafk           INTEGER       NOT NULL,
  -- Object information
  cvalue1string         VARCHAR(300),
  cvalue2string         VARCHAR(300),
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
  cdetails              TEXT,
  CONSTRAINT metadatavalue_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT metadatavalue_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT metadatavalue_boolean_ck CHECK (cvalueboolean IN ('0', '1'))
);



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
  cvalue1string         VARCHAR(300),
  cvalue2string         VARCHAR(300),
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
  cdetails              TEXT,
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
ALTER TABLE tportalmetadata ADD cactorfullname VARCHAR(96);
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
  cvalue1string         VARCHAR(300),
  cvalue2string         VARCHAR(300),
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
  cdetails              TEXT,
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
  crecorduid            INTEGER       NOT NULL DEFAULT NEXTVAL('metadatalink_sequence'),
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  cparentmetadatafk     INTEGER       NOT NULL,
  cchildmetadatafk      INTEGER       NOT NULL,
  clevel                INTEGER       NOT NULL,
  CONSTRAINT metadatalink_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT metadatalink_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT metadatalink_uk UNIQUE (ctimeslotfk, cparentmetadatafk, cchildmetadatafk)
);


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
  crecorduid            INTEGER       NOT NULL  DEFAULT NEXTVAL('rawrightgroup_sequence'),
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
  CONSTRAINT rawrightgroup_uniqueness_uk UNIQUE (cgroupfk, cpermissionfk, cperimeterfk, cnegative),
  CONSTRAINT rawrightgroup_uid_uk UNIQUE (ctimeslotfk, crawrightgroupuid),
  CONSTRAINT rawrightgroup_negative_ck CHECK (cnegative IN ('0', '1')),
  CONSTRAINT rawrightgroup_default_ck CHECK (cdefault IN ('0', '1'))
);




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


ALTER TABLE tmetadatavalue ADD cvalue3string         VARCHAR(2000);
ALTER TABLE tmetadatavalue ADD cvalue4string         VARCHAR(2000);
ALTER TABLE tmetadatavalue ADD cvalue5string         VARCHAR(2000);
ALTER TABLE tmetadatavalue ADD cvalue6string         VARCHAR(2000);
ALTER TABLE tmetadatavalue ADD cvalue7string         VARCHAR(2000);
ALTER TABLE tmetadatavalue ADD cvalue8string         VARCHAR(2000);
ALTER TABLE tmetadatavalue ADD cvalue9string         VARCHAR(2000);
ALTER TABLE tmetadatavalue ADD cvalue10string        VARCHAR(2000);
ALTER TABLE tmetadatavalue ADD cvalue11string        VARCHAR(2000);
ALTER TABLE tmetadatavalue ADD cvalue12string        VARCHAR(2000);
ALTER TABLE tmetadatavalue ADD cvalue13string        VARCHAR(2000);
ALTER TABLE tmetadatavalue ADD cvalue14string        VARCHAR(2000);
ALTER TABLE tmetadatavalue ADD cvalue15string        VARCHAR(2000);
ALTER TABLE tmetadatavalue ADD cvalue16string        VARCHAR(2000);
ALTER TABLE tmetadatavalue ADD cvalue17string        VARCHAR(2000);
ALTER TABLE tmetadatavalue ADD cvalue18string        VARCHAR(2000);
ALTER TABLE tmetadatavalue ADD cvalue19string        VARCHAR(2000);
ALTER TABLE tmetadatavalue ADD cvalue20string        VARCHAR(2000);
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

ALTER TABLE timportmetadatavalue ADD cvalue3string         VARCHAR(2000);
ALTER TABLE timportmetadatavalue ADD cvalue4string         VARCHAR(2000);
ALTER TABLE timportmetadatavalue ADD cvalue5string         VARCHAR(2000);
ALTER TABLE timportmetadatavalue ADD cvalue6string         VARCHAR(2000);
ALTER TABLE timportmetadatavalue ADD cvalue7string         VARCHAR(2000);
ALTER TABLE timportmetadatavalue ADD cvalue8string         VARCHAR(2000);
ALTER TABLE timportmetadatavalue ADD cvalue9string         VARCHAR(2000);
ALTER TABLE timportmetadatavalue ADD cvalue10string        VARCHAR(2000);
ALTER TABLE timportmetadatavalue ADD cvalue11string        VARCHAR(2000);
ALTER TABLE timportmetadatavalue ADD cvalue12string        VARCHAR(2000);
ALTER TABLE timportmetadatavalue ADD cvalue13string        VARCHAR(2000);
ALTER TABLE timportmetadatavalue ADD cvalue14string        VARCHAR(2000);
ALTER TABLE timportmetadatavalue ADD cvalue15string        VARCHAR(2000);
ALTER TABLE timportmetadatavalue ADD cvalue16string        VARCHAR(2000);
ALTER TABLE timportmetadatavalue ADD cvalue17string        VARCHAR(2000);
ALTER TABLE timportmetadatavalue ADD cvalue18string        VARCHAR(2000);
ALTER TABLE timportmetadatavalue ADD cvalue19string        VARCHAR(2000);
ALTER TABLE timportmetadatavalue ADD cvalue20string        VARCHAR(2000);
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

ALTER TABLE tportalmetadatavalue ADD cvalue3string         VARCHAR(2000);
ALTER TABLE tportalmetadatavalue ADD cvalue4string         VARCHAR(2000);
ALTER TABLE tportalmetadatavalue ADD cvalue5string         VARCHAR(2000);
ALTER TABLE tportalmetadatavalue ADD cvalue6string         VARCHAR(2000);
ALTER TABLE tportalmetadatavalue ADD cvalue7string         VARCHAR(2000);
ALTER TABLE tportalmetadatavalue ADD cvalue8string         VARCHAR(2000);
ALTER TABLE tportalmetadatavalue ADD cvalue9string         VARCHAR(2000);
ALTER TABLE tportalmetadatavalue ADD cvalue10string        VARCHAR(2000);
ALTER TABLE tportalmetadatavalue ADD cvalue11string        VARCHAR(2000);
ALTER TABLE tportalmetadatavalue ADD cvalue12string        VARCHAR(2000);
ALTER TABLE tportalmetadatavalue ADD cvalue13string        VARCHAR(2000);
ALTER TABLE tportalmetadatavalue ADD cvalue14string        VARCHAR(2000);
ALTER TABLE tportalmetadatavalue ADD cvalue15string        VARCHAR(2000);
ALTER TABLE tportalmetadatavalue ADD cvalue16string        VARCHAR(2000);
ALTER TABLE tportalmetadatavalue ADD cvalue17string        VARCHAR(2000);
ALTER TABLE tportalmetadatavalue ADD cvalue18string        VARCHAR(2000);
ALTER TABLE tportalmetadatavalue ADD cvalue19string        VARCHAR(2000);
ALTER TABLE tportalmetadatavalue ADD cvalue20string        VARCHAR(2000);
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


ALTER TABLE tactivitypair ALTER COLUMN coperator TYPE VARCHAR(16);



ALTER TABLE timportactivitypair ALTER COLUMN coperator TYPE VARCHAR(16);



ALTER TABLE tportalactivitypair ALTER COLUMN coperator TYPE VARCHAR(16);


CREATE SEQUENCE uservariable_sequence;
CREATE TABLE tuservariable (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL    DEFAULT NEXTVAL('uservariable_sequence'),
  cowneruid             VARCHAR(250)  NOT NULL,
  cname                 VARCHAR(250)  NOT NULL,
  ccontent              TEXT,
  CONSTRAINT uservariable_uid_pk PRIMARY KEY (crecorduid)
);


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
-- Upgrade script to version 33
-- --------


-- MISSION table
CREATE SEQUENCE mission_sequence;
CREATE TABLE tmission (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL DEFAULT NEXTVAL('mission_sequence'),
  -- Object information
  cname                 VARCHAR(250),
  cbusinessdomain       VARCHAR(250),
  cdescription          VARCHAR(4000),
  cduedate              VARCHAR(15),
  CONSTRAINT mission_uid_pk PRIMARY KEY (crecorduid)
);


-- ENDPOINT table
CREATE SEQUENCE endpoint_sequence;
CREATE TABLE tendpoint (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  DEFAULT NEXTVAL('endpoint_sequence'),
  -- Object information
  cname                 VARCHAR(250)  NOT NULL,
  cdescription          VARCHAR(4000),
  cprovider             VARCHAR(100)  NOT NULL,
  cdefinition           VARCHAR(4000),
  CONSTRAINT endpoint_uid_pk PRIMARY KEY (crecorduid)
);


-- MISSIONWAVE table
CREATE SEQUENCE missionwave_sequence;
CREATE TABLE tmissionwave (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  DEFAULT NEXTVAL('missionwave_sequence'),
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
CREATE SEQUENCE missionwavestage_sequence;
CREATE TABLE tmissionwavestage (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  DEFAULT NEXTVAL('missionwavestage_sequence'),
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
CREATE SEQUENCE software_sequence;
CREATE TABLE tsoftware (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  DEFAULT NEXTVAL('software_sequence'),
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
CREATE SEQUENCE softwarevar_sequence;
CREATE TABLE tsoftwarevariable (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  DEFAULT NEXTVAL('softwarevar_sequence'),
  -- Object information
  csoftwarefk           INTEGER       NOT NULL,
  ckey                  VARCHAR(250)  NOT NULL,
  cvalue                VARCHAR(1000),
  CONSTRAINT softwarevar_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT softwarevar_software_fk FOREIGN KEY (csoftwarefk) REFERENCES tsoftware(crecorduid) ON DELETE CASCADE ON UPDATE NO ACTION
);


-- UPLOADFILE table
CREATE SEQUENCE uploadfile_sequence;
CREATE TABLE tuploadfile (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  DEFAULT NEXTVAL('uploadfile_sequence'),
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
CREATE SEQUENCE datasource_sequence;
CREATE TABLE tdatasource (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  DEFAULT NEXTVAL('datasource_sequence'),
  -- Object information
  cname                 VARCHAR(250)  NOT NULL,
  cdescription          VARCHAR(4000),
  csoftwarefk           INTEGER       NOT NULL,
  cendpointfk           INTEGER,
  ctype                 VARCHAR(15),
  cparsingoptions       VARCHAR(4000),
  CONSTRAINT datasource_uid_pk PRIMARY KEY (crecorduid)
  , CONSTRAINT datasource_software_fk FOREIGN KEY (csoftwarefk) REFERENCES tsoftware(crecorduid) ON DELETE CASCADE ON UPDATE NO ACTION
  , CONSTRAINT datasource_endpoint_fk FOREIGN KEY (cendpointfk) REFERENCES tendpoint(crecorduid) ON DELETE SET NULL ON UPDATE NO ACTION
);


-- DATASOURCEFILE table
CREATE SEQUENCE datasourcefile_sequence;
CREATE TABLE tdatasourcefile (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  DEFAULT NEXTVAL('datasourcefile_sequence'),
  -- Object information
  cdatasourcefk         INTEGER       NOT NULL,
  cuploadfilefk         INTEGER       NOT NULL,
  cvalidationstatus     VARCHAR(25),
  cmessages             TEXT,
  CONSTRAINT datasourcefile_uid_pk PRIMARY KEY (crecorduid)
  , CONSTRAINT datasourcefile_ds_fk FOREIGN KEY (cdatasourcefk) REFERENCES tdatasource(crecorduid) ON DELETE CASCADE ON UPDATE NO ACTION
  , CONSTRAINT datasourcefile_upload_fk FOREIGN KEY (cuploadfilefk) REFERENCES tuploadfile(crecorduid) ON DELETE CASCADE ON UPDATE NO ACTION
);


-- MAPPING table
CREATE SEQUENCE mapping_sequence;
CREATE TABLE tmapping (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  DEFAULT NEXTVAL('mapping_sequence'),
  -- Object information
  cname                 VARCHAR(250)  NOT NULL,
  cdatasourcefk         INTEGER       NOT NULL,
  centity               CHAR(1)       NOT NULL,
  CONSTRAINT mapping_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT mapping_datasource_fk FOREIGN KEY (cdatasourcefk) REFERENCES tdatasource(crecorduid) ON DELETE CASCADE ON UPDATE NO ACTION
);


-- MAPPINGCOMPUTED table
CREATE SEQUENCE mappingcomputed_sequence;
CREATE TABLE tmappingcomputed (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  DEFAULT NEXTVAL('mappingcomputed_sequence'),
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
CREATE SEQUENCE mappingattr_sequence;
CREATE TABLE tmappingattr (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  DEFAULT NEXTVAL('mappingattr_sequence'),
  -- Object information
  cmappingfk            INTEGER       NOT NULL,
  centityattribute      VARCHAR(100)  NOT NULL,
  ctype                 CHAR(1)       NOT NULL,
  cmode                 CHAR(1)       NOT NULL,
  cdatasourceattribute  VARCHAR(100),
  ccomputedattributefk  INTEGER,
  CONSTRAINT mappingattr_uid_pk PRIMARY KEY (crecorduid)
  , CONSTRAINT mappingattr_mapping_fk FOREIGN KEY (cmappingfk) REFERENCES tmapping(crecorduid) ON DELETE CASCADE ON UPDATE NO ACTION
  , CONSTRAINT mappingattr_computed_fk FOREIGN KEY (ccomputedattributefk) REFERENCES tmappingcomputed(crecorduid) ON DELETE CASCADE ON UPDATE NO ACTION
);


-- MAPPINGFILTER table
CREATE SEQUENCE mappingfilter_sequence;
CREATE TABLE tmappingfilter (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  DEFAULT NEXTVAL('mappingfilter_sequence'),
  -- Object information
  cmappingfk            INTEGER       NOT NULL,
  cname                 VARCHAR(250)  NOT NULL,
  cexpression           VARCHAR(2000),
  CONSTRAINT mappingfilter_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT mappingfilter_mapping_fk FOREIGN KEY (cmappingfk) REFERENCES tmapping(crecorduid) ON DELETE CASCADE ON UPDATE NO ACTION
);


-- EXECPLANMONITOR table
CREATE SEQUENCE execplanmonitor_sequence;
CREATE TABLE texecplanmonitor (
  -- Database primary key
  crecorduid            INTEGER       NOT NULL  DEFAULT NEXTVAL('execplanmonitor_sequence'),
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



UPDATE tproperties SET cvalue='33' WHERE cpropertiesuid='VERSION';
--
-- Copyright Radiant Logic 2021 
-- Execute this script inside psql session as following or pgadmin tool.
-- Allow to drop all views used in Braille version (63 views)

DROP VIEW IF EXISTS vdelegation;
DROP VIEW IF EXISTS vdirectticketlink;
DROP VIEW IF EXISTS vcontrolassetresult;
DROP VIEW IF EXISTS vcontrolorgresult;
DROP VIEW IF EXISTS vcontrolflatorgresult;
DROP VIEW IF EXISTS vcontrolidentresult;
DROP VIEW IF EXISTS vcontrolresult;
DROP VIEW IF EXISTS voverentitlement;
DROP VIEW IF EXISTS vunderentitlement;
DROP VIEW IF EXISTS vaggregatedright;
DROP VIEW IF EXISTS vuprightgroup;
DROP VIEW IF EXISTS vdownrightgroup;
DROP VIEW IF EXISTS vdirectpermissionlink;
DROP VIEW IF EXISTS vindirectpermissionlink;
DROP VIEW IF EXISTS vdirecthierarchy;
DROP VIEW IF EXISTS vupaccountgroup;
DROP VIEW IF EXISTS vdownaccountgroup;
DROP VIEW IF EXISTS vdirectgrouplink;
DROP VIEW IF EXISTS vdirectgenericteam;
DROP VIEW IF EXISTS vdirectgenericmanager;
DROP VIEW IF EXISTS vgenericteam;
DROP VIEW IF EXISTS vgenericmanager;
DROP VIEW IF EXISTS vmanagerorboss;
DROP VIEW IF EXISTS vupmanager;
DROP VIEW IF EXISTS vdownmanager;
DROP VIEW IF EXISTS vdirectidentitymanagers;
DROP VIEW IF EXISTS vbosslink;
DROP VIEW IF EXISTS vdirectboss;
DROP VIEW IF EXISTS vupallocation;
DROP VIEW IF EXISTS vdownallocation;
DROP VIEW IF EXISTS vdirectrelationship;
DROP VIEW IF EXISTS vportaldelegation;
DROP VIEW IF EXISTS vportalcontrolassetresult;
DROP VIEW IF EXISTS vportalcontrolorgresult;
DROP VIEW IF EXISTS vportalcontrolflatorgresult;
DROP VIEW IF EXISTS vportalcontrolidentresult;
DROP VIEW IF EXISTS vportalcontrolresult;
DROP VIEW IF EXISTS vportaloverentitlement;
DROP VIEW IF EXISTS vportalunderentitlement;
DROP VIEW IF EXISTS vportalaggregatedright;
DROP VIEW IF EXISTS vportaluprightgroup;
DROP VIEW IF EXISTS vportaldownrightgroup;
DROP VIEW IF EXISTS vportaldirectpermissionlink;
DROP VIEW IF EXISTS vportalindirectpermissionlink;
DROP VIEW IF EXISTS vportaldirecthierarchy;
DROP VIEW IF EXISTS vportalupaccountgroup;
DROP VIEW IF EXISTS vportaldownaccountgroup;
DROP VIEW IF EXISTS vportaldirectgrouplink;
DROP VIEW IF EXISTS vportaldirectgenericteam;
DROP VIEW IF EXISTS vportaldirectgenericmanager;
DROP VIEW IF EXISTS vportalgenericteam;
DROP VIEW IF EXISTS vportalgenericmanager;
DROP VIEW IF EXISTS vportalmanagerorboss;
DROP VIEW IF EXISTS vportalupmanager;
DROP VIEW IF EXISTS vportaldownmanager;
DROP VIEW IF EXISTS vpdirectidentitymanagers;
DROP VIEW IF EXISTS vportalbosslink;
DROP VIEW IF EXISTS vportaldirectboss;
DROP VIEW IF EXISTS vportalupallocation;
DROP VIEW IF EXISTS vportaldownallocation;
DROP VIEW IF EXISTS vportaldirectrelationship;
DROP VIEW IF EXISTS vfsaggregatedright;
DROP VIEW IF EXISTS vportalfsaggregatedright;

-- Function to change the type integer to bigint for all columns as recorduid, %fk, and some others
CREATE OR REPLACE FUNCTION integer_to_bigint(schemaname TEXT) RETURNS SETOF TEXT AS $$
DECLARE
	_ref_tab_name TEXT;
	_ref_tab_column_name TEXT;
	_tab_column_name refcursor;
	SQLString TEXT;
	SQLtable TEXT;
	SQLcolumn TEXT;
	AnalyzeSQLString TEXT;
	-- Cursor on all historical and portal tables (not activity tables or import tables)
	_table_name CURSOR FOR SELECT distinct(t.table_name) from information_schema.tables t inner join information_schema.columns c on c.table_name = t.table_name
		where t.table_type = 'BASE TABLE'
		and t.table_schema not in ('information_schema', 'pg_catalog')
		and t.table_name not like 'act%' 
		order by t.table_name;
BEGIN
	-- Open the cursor to iterate on tables
	OPEN _table_name;
	LOOP
		-- fetch row into 
    	FETCH _table_name INTO _ref_tab_name;
	    -- exit when no more row to fetch
	    EXIT WHEN NOT FOUND;
		
	    -- On filtre uniquement sur les colonnes qui se terminent par fk (%fk) pour l'ensemble des tables.
		-- et les colonnes suivantes qui sont également des FK (fausses FK) à savoir  cforeignrecorduid, cobjectrecorduid, cobjectuid
		-- et de type integer
		--
		-- La variable curseur est ouverte et reçoit la requête spécifiée à exécuter. 
		-- Le curseur ne peut pas être déjà ouvert et doit avoir été déclaré comme une variable de curseur non lié (c'est-à-dire comme une simple variable refcursor). 
		OPEN _tab_column_name FOR EXECUTE 'SELECT column_name FROM information_schema.Columns WHERE table_name = ' || '''' || _ref_tab_name || '''' || ' and table_schema = ' || '''' || schemaname || '''' ||' and (column_name like ''%fk'' OR column_name in (''crecorduid'',''cforeignrecorduid'',''cobjectrecorduid'',''cobjectuid'',''coptionuid'',''crequestid'',''cworkrecuid'')) and data_type = ''integer'' ';

		SQLtable := 'ALTER TABLE ' || _ref_tab_name ;
		SQLcolumn := '' ;

		LOOP
			-- fetch row into 
			FETCH _tab_column_name INTO _ref_tab_column_name;
			-- exit when no more row to fetch
			EXIT WHEN NOT FOUND;  
			-- Change the type integer to bigint to support 64 bits
			-- 
			SQLcolumn := CONCAT ( SQLcolumn ,' ALTER COLUMN ' || _ref_tab_column_name || ' TYPE BIGINT ,') ;
			AnalyzeSQLString := 'ANALYZE ' || _ref_tab_name;
			
		END LOOP;
		
		IF SQLcolumn <> '' THEN
			SQLstring := CONCAT( SQLtable , SQLcolumn ) ;
			SQLString := RTRIM(SQLstring,',') ;
		END IF; 
		
		-- Close the cursor
		CLOSE _tab_column_name;
		
		AnalyzeSQLString := 'ANALYZE ' || _ref_tab_name;
		BEGIN
			
			IF SQLString <> '' THEN
				raise notice 'Start time =%', clock_timestamp();
				raise notice '%', SQLString;
				execute SQLString; 
				raise notice 'End time =%', clock_timestamp();
				execute AnalyzeSQLString; 
			END IF;
			
		END;

	END LOOP;
   	-- Close the cursor
	CLOSE _table_name;
END;
$$ LANGUAGE plpgsql;

-- Execute the function
select integer_to_bigint(:SchemaVariable);
-- Drop the function
drop function IF EXISTS integer_to_bigint(text);
--
-- Copyright Radiant Logic 2021 
-- Execute this script inside psql session as following or pgadmin tool.
-- Allow to re-create all views used in Braille version.

CREATE VIEW vdirectrelationship AS
  SELECT * from trelationship WHERE cindirect='0';
  
-- UPWARD RECURSIVE ALLOCATION view
CREATE VIEW vupallocation AS
    SELECT
      ctimeslotfk, crepositoryfk,
      cidentityfk, corganisationfk, cjobtitlefk, '0' AS cindirect
    FROM
      tallocation
  UNION ALL
    SELECT
      A.ctimeslotfk, A.crepositoryfk,
      A.cidentityfk, R.cparentorganisationfk AS corganisationfk, A.cjobtitlefk, '1' AS cindirect
    FROM
      tallocation A
    INNER JOIN trelationship R ON R.corganisationfk = A.corganisationfk;

-- DOWNWARD RECURSIVE ALLOCATION view
CREATE VIEW vdownallocation AS
    SELECT
      ctimeslotfk, crepositoryfk,
      cidentityfk, corganisationfk, cjobtitlefk, '0' AS cindirect
    FROM
      tallocation
  UNION ALL
    SELECT
      A.ctimeslotfk, A.crepositoryfk,
      A.cidentityfk, R.corganisationfk, A.cjobtitlefk, '1' AS cindirect
    FROM
      tallocation A
    INNER JOIN trelationship R ON R.cparentorganisationfk = A.corganisationfk;

-- DIRECT BOSS view
CREATE VIEW vdirectboss AS
  SELECT * from tboss WHERE cindirect='0';

-- BOSS link view
CREATE VIEW vbosslink AS
  SELECT DISTINCT
    B.ctimeslotfk AS ctimeslotfk, B.cidentityfk AS cidentityfk, C.cbossidentityfk AS cbossidentityfk
  FROM
    tboss B
  INNER JOIN tboss C ON B.cbossidentityfk = C.cidentityfk
  WHERE NOT EXISTS (
    SELECT
      D.crecorduid
    FROM tboss D
    WHERE
      D.cidentityfk = B.cidentityfk
    AND
      D.cbossidentityfk = C.cbossidentityfk
  );
  
 -- DIRECT identity manager view
CREATE VIEW vdirectidentitymanagers AS
  SELECT m.crecorduid,m.ctimeslotfk,m.corganisationfk,m.crepositoryfk,m.caccountfk,m.cgroupfk,m.cpermissionfk,m.capplicationfk,m.cassetfk,m.ccampaignfk,m.cmanagedidentityfk,m.cindirect,
  		 m.cexpertisedomainfk,m.cidentityfk,m.ccollected,m.cdelegation,m.cpriority,m.cstartdate,m.cstartday,m.cenddate,m.cendday,m.ccomment,m.cdelegationreason
  FROM tmanager m
  INNER JOIN tidentity i ON i.crecorduid = m.cmanagedidentityfk
  WHERE m.cindirect='0' OR m.cindirect IS NULL;

-- UPWARD RECURSIVE MANAGER view
CREATE VIEW vupmanager AS
    SELECT
      ctimeslotfk, 
      corganisationfk, cexpertisedomainfk, cidentityfk, '0' AS cindirect
    FROM
      tmanager
  UNION ALL
    SELECT
      M.ctimeslotfk, 
      R.cparentorganisationfk AS corganisationfk, M.cexpertisedomainfk,
      M.cidentityfk, '1' AS cindirect
    FROM
      tmanager M
    INNER JOIN trelationship R ON R.corganisationfk = M.corganisationfk;

-- DOWNWARD RECURSIVE MANAGER view
CREATE VIEW vdownmanager AS
    SELECT
      ctimeslotfk, 
      corganisationfk, cexpertisedomainfk, cidentityfk, '0' AS cindirect
    FROM
      tmanager
  UNION ALL
    SELECT
      M.ctimeslotfk,
      R.corganisationfk, M.cexpertisedomainfk, M.cidentityfk, '1' AS cindirect
    FROM
      tmanager M
    INNER JOIN trelationship R ON R.cparentorganisationfk = M.corganisationfk;

-- MANAGER OR BOSS inner view
CREATE VIEW vmanagerorboss AS
    SELECT
      ctimeslotfk, cidentityfk, cbossidentityfk, cindirect
    FROM
      tboss
  UNION ALL
    SELECT
      A.ctimeslotfk, A.cidentityfk, M.cidentityfk as cbossidentityfk, '0' as cindirect
    FROM
      tallocation A
    INNER JOIN tmanager M ON M.corganisationfk = A.corganisationfk AND A.cidentityfk <> M.cidentityfk
  UNION ALL
    SELECT
      A.ctimeslotfk, A.cidentityfk, D.cidentityfk as cbossidentityfk, D.cindirect
    FROM
      tallocation A
    INNER JOIN vdownmanager D ON D.corganisationfk = A.corganisationfk;

-- GENERIC MANAGER view
CREATE VIEW vgenericmanager AS
  SELECT DISTINCT
    I.ctimeslotfk, M.cidentityfk, M.cbossidentityfk, M.cindirect
  FROM
    tidentity I
  LEFT JOIN vmanagerorboss M ON M.cidentityfk = I.crecorduid;

-- GENERIC TEAM view
CREATE VIEW vgenericteam AS
  SELECT DISTINCT
    I.ctimeslotfk, M.cidentityfk, M.cbossidentityfk, M.cindirect
  FROM
    tidentity I
  LEFT JOIN vmanagerorboss M ON M.cbossidentityfk = I.crecorduid;

-- DIRECT GENERIC MANAGER view
CREATE VIEW vdirectgenericmanager AS
  SELECT * from vgenericmanager WHERE cindirect='0';

-- DIRECT GENERIC TEAM view
CREATE VIEW vdirectgenericteam AS
  SELECT * from vgenericteam WHERE cindirect='0';

-- DIRECT GROUPLINK view
CREATE VIEW vdirectgrouplink AS
  SELECT * from tgrouplink WHERE cindirect='0';

-- UPWARD RECURSIVE ACCOUNTGROUP view
CREATE VIEW vupaccountgroup AS
    SELECT
      ctimeslotfk, 
      crepositoryfk, caccountfk, cparentgroupfk, '0' AS cindirect
    FROM
      taccountgroup
  UNION ALL
    SELECT
      A.ctimeslotfk,
      A.crepositoryfk, A.caccountfk, G.cparentgroupfk, '1' AS cindirect
    FROM
      taccountgroup A
    INNER JOIN tgrouplink G ON G.cgroupfk = A.cparentgroupfk;

-- DOWNWARD RECURSIVE ACCOUNTGROUP view
CREATE VIEW vdownaccountgroup AS
    SELECT
      ctimeslotfk, 
      crepositoryfk, caccountfk, cparentgroupfk, '0' AS cindirect
    FROM
      taccountgroup
  UNION ALL
    SELECT
      A.ctimeslotfk, 
      A.crepositoryfk, A.caccountfk, G.cgroupfk AS cparentgroupfk, '1' AS cindirect
    FROM
      taccountgroup A
    INNER JOIN tgrouplink G ON G.cparentgroupfk = A.cparentgroupfk;

-- DIRECT HIERARCHY view
CREATE VIEW vdirecthierarchy AS
  SELECT * from thierarchy WHERE cindirect='0';

-- DIRECT PERMISSIONLINK view
CREATE VIEW vdirectpermissionlink AS
  SELECT * from tpermissionlink WHERE cindirect='0';

-- INDIRECT PERMISSIONLINK view
CREATE VIEW vindirectpermissionlink AS
  SELECT * from tpermissionlink WHERE cindirect='0' OR cindirect='1';

-- UPWARD RECURSIVE RIGHTGROUP view
CREATE VIEW vuprightgroup AS
    SELECT
      ctimeslotfk, crightgroupuid, crepositoryfk,
      cpermissionfk, cgroupfk, cperimeterfk, '1' as cfromgroup, '0' AS cindirect,
      cdisplayname, caction, climit, cinherited,
      crighttype, cdefault, ccontext,
      ccustom1, ccustom2, ccustom3, ccustom4, ccustom5, ccustom6, ccustom7, ccustom8, ccustom9
    FROM
      trightgroup
  UNION ALL
    SELECT DISTINCT
      A.ctimeslotfk, A.crightgroupuid, A.crepositoryfk,
      A.cpermissionfk, R.cparentgroupfk AS cgroupfk, A.cperimeterfk, '1' as cfromgroup, '1' AS cindirect,
      A.cdisplayname, A.caction, A.climit, A.cinherited,
      A.crighttype, A.cdefault, A.ccontext,
      A.ccustom1, A.ccustom2, A.ccustom3, A.ccustom4, A.ccustom5, A.ccustom6, A.ccustom7, A.ccustom8, A.ccustom9
    FROM
      trightgroup A
    INNER JOIN tgrouplink R ON R.cgroupfk = A.cgroupfk;

-- DOWNWARD RECURSIVE RIGHTGROUP view
CREATE VIEW vdownrightgroup AS
    SELECT
      ctimeslotfk, crightgroupuid, crepositoryfk,
      cpermissionfk, cgroupfk, cperimeterfk, '1' as cfromgroup, '0' AS cindirect,
      cdisplayname, caction, climit, cinherited,
      crighttype, cdefault, ccontext,
      ccustom1, ccustom2, ccustom3, ccustom4, ccustom5, ccustom6, ccustom7, ccustom8, ccustom9
    FROM
      trightgroup
  UNION ALL
    SELECT DISTINCT
      A.ctimeslotfk, A.crightgroupuid, A.crepositoryfk,
      A.cpermissionfk, R.cgroupfk AS cgroupfk, A.cperimeterfk, '1' as cfromgroup, '1' AS cindirect,
      A.cdisplayname, A.caction, A.climit, A.cinherited,
      A.crighttype, A.cdefault, A.ccontext,
      A.ccustom1, A.ccustom2, A.ccustom3, A.ccustom4, A.ccustom5, A.ccustom6, A.ccustom7, A.ccustom8, A.ccustom9
    FROM
      trightgroup A
    INNER JOIN tgrouplink R ON R.cparentgroupfk = A.cgroupfk;

-- AGGREGATED RIGHT view for rights belonging to permissions




CREATE VIEW vaggregatedright (
        ctimeslotfk, crightuid, cdisplayname, cfromgroup, cinherited, cindirect, caction, climit, crepositoryfk, caccountfk, cpermissionfk, cperimeterfk,
        crighttype,cdefault,ccontext,ccustom1,ccustom2,ccustom3,ccustom4,ccustom5,ccustom6,ccustom7,ccustom8,ccustom9
    ) AS
SELECT  direct.ctimeslotfk,direct.crightuid,direct.cdisplayname,direct.cfromgroup,direct.cinherited,direct.cindirect,direct.caction,direct.climit,direct.crepositoryfk,
		direct.caccountfk,direct.cpermissionfk,direct.cperimeterfk,direct.crighttype,direct.cdefault,direct.ccontext,direct.ccustom1,direct.ccustom2,direct.ccustom3,
		direct.ccustom4,direct.ccustom5,direct.ccustom6,direct.ccustom7,direct.ccustom8,direct.ccustom9
FROM (
		SELECT r.ctimeslotfk,r.crightuid, r.cdisplayname, r.cfromgroup, r.cinherited, r.cindirect, r.caction, r.climit,
          r.crepositoryfk, r.caccountfk, r.cpermissionfk,
          CASE
            WHEN r.cperimeterfk IS NULL THEN -1
            ELSE r.cperimeterfk
          END AS cperimeterfk,
          r.crighttype, r.cdefault, r.ccontext,
          r.ccustom1, r.ccustom2, r.ccustom3, r.ccustom4, r.ccustom5, r.ccustom6, r.ccustom7, r.ccustom8, r.ccustom9
        FROM tright r
    ) direct
UNION ALL
SELECT  fromgroup.ctimeslotfk,fromgroup.crightuid,fromgroup.cdisplayname,fromgroup.cfromgroup,fromgroup.cinherited,fromgroup.cindirect,fromgroup.caction,fromgroup.climit,
	fromgroup.crepositoryfk,fromgroup.caccountfk,fromgroup.cpermissionfk,fromgroup.cperimeterfk,fromgroup.crighttype,fromgroup.cdefault,fromgroup.ccontext,fromgroup.ccustom1,
	fromgroup.ccustom2,fromgroup.ccustom3,fromgroup.ccustom4,fromgroup.ccustom5,fromgroup.ccustom6,fromgroup.ccustom7,fromgroup.ccustom8,fromgroup.ccustom9
FROM (
		SELECT r.ctimeslotfk,r.crightgroupuid AS crightuid,r.cdisplayname,'1'::CHARACTER(1) AS cfromgroup,r.cinherited,r.cindirect,r.caction,r.climit,r.crepositoryfk,a.caccountfk,r.cpermissionfk,
            CASE
                WHEN (r.cperimeterfk IS NULL)
                THEN '-1'::INTEGER
                ELSE r.cperimeterfk
            END AS cperimeterfk,r.crighttype,r.cdefault,r.ccontext,r.ccustom1,r.ccustom2,r.ccustom3,r.ccustom4,r.ccustom5,r.ccustom6,r.ccustom7,r.ccustom8,r.ccustom9
      	FROM trightgroup r
          INNER JOIN taccountgroup a ON r.cgroupfk = a.cparentgroupfk
    ) fromgroup;

-- OVERALLOCATION view
CREATE VIEW voverentitlement AS
  SELECT I.ctimeslotfk, I.crecorduid AS cidentityfk, P.crecorduid AS cpermissionfk
  FROM
    tidentity I
    INNER JOIN treconciliation R ON R.cidentityfk = I.crecorduid
    INNER JOIN taccount A ON A.crecorduid = R.caccountfk
    INNER JOIN vaggregatedright AR ON AR.caccountfk = A.crecorduid
    INNER JOIN tpermissionlink L ON AR.cpermissionfk = L.cparentpermissionfk
    INNER JOIN tpermission P ON L.cpermissionfk = P.cpermissionlinkfk
  WHERE
    (A.cdisabled IS NULL OR A.cdisabled = '0')
  AND
    NOT EXISTS (
      SELECT 1
      FROM
        ttheoricalright TR
      WHERE
        TR.cidentityfk = I.crecorduid AND TR.cpermissionfk = P.crecorduid
      UNION
      SELECT 1
      FROM
        tderogation D
      WHERE
        D.cidentityfk = I.crecorduid AND D.cpermissionfk = P.crecorduid
    )
;

-- UNDERALLOCATION view



CREATE VIEW vunderentitlement AS
  WITH
    thecurrent AS (
      SELECT I.crecorduid AS iru, P.crecorduid AS pru
      FROM
        tidentity I
      INNER JOIN treconciliation R ON R.cidentityfk = I.crecorduid
      INNER JOIN taccount A ON A.crecorduid = R.caccountfk
      INNER JOIN vaggregatedright AR ON AR.caccountfk = A.crecorduid
      INNER JOIN tpermissionlink L ON AR.cpermissionfk = L.cparentpermissionfk
      INNER JOIN tpermission P ON L.cpermissionfk = P.cpermissionlinkfk
      WHERE
        (A.cdisabled IS NULL OR A.cdisabled = '0')
    )
  SELECT TR.ctimeslotfk, TR.cidentityfk as cidentityfk, TR.cpermissionfk as cpermissionfk
  FROM
    ttheoricalright TR
  WHERE NOT EXISTS (
    SELECT 1
    FROM
      thecurrent C
  WHERE
      C.iru = TR.cidentityfk AND C.pru = TR.cpermissionfk
  )
  UNION
  SELECT D.ctimeslotfk, D.cidentityfk as cidentityfk, D.cpermissionfk as cpermissionfk
  FROM
    tderogation D
  WHERE NOT EXISTS (
    SELECT 1
    FROM
      thecurrent C
  WHERE
      C.iru = D.cidentityfk AND C.pru = D.cpermissionfk
  )
;

-- CONTROLRESULT view to simulate old tcontrolresult
CREATE VIEW vcontrolresult AS
  SELECT d.ccontrollogfk AS ccontrollogfk, r.cpermissionfk AS cpermissionfk, CAST (NULL AS INTEGER) AS coptionuid,
    CASE 
      WHEN r.crecorduid IS NOT NULL THEN r.crecorduid
      ELSE d.crecorduid
    END AS crecorduid,
    CASE l.ccontrolentity
      WHEN 'Permission' THEN d.cpermissionfk
      WHEN 'Application' THEN d.capplicationfk
      WHEN 'Account' THEN d.caccountfk
      WHEN 'Group' THEN d.cgroupfk
      WHEN 'Identity' THEN d.cidentityfk
      WHEN 'Organisation' THEN d.corganisationfk
      WHEN 'Asset' THEN d.cassetfk
      ELSE NULL
    END AS cobjectuid
  FROM tcontroldiscrepancy d INNER JOIN tcontrollog l ON l.crecorduid = d.ccontrollogfk LEFT JOIN tcontrolrootcause r ON r.ccontroldiscrepancyfk = d.crecorduid;

-- CONTROLIDENTRESULT view
CREATE VIEW vcontrolidentresult AS
    SELECT A.crecorduid, A.cobjectuid, A.ccontrollogfk, A.cpermissionfk, A.coptionuid
    FROM
      tcontrolresult A
    INNER JOIN tcontrollog B ON A.ccontrollogfk = B.crecorduid AND B.ccontrolentity='Identity'
  UNION 
    SELECT C.crecorduid, E.cidentityfk AS cobjectuid, C.ccontrollogfk, C.cpermissionfk, C.coptionuid
    FROM
      tcontrolresult C
    INNER JOIN tcontrollog D ON C.ccontrollogfk = D.crecorduid AND D.ccontrolentity='Account'
    INNER JOIN treconciliation E ON C.cobjectuid = E.caccountfk;

-- CONTROLFLATORGRESULT view
CREATE VIEW vcontrolflatorgresult AS
    SELECT A.crecorduid, A.cobjectuid, A.ccontrollogfk, A.cpermissionfk, A.coptionuid
    FROM
      tcontrolresult A
    INNER JOIN tcontrollog B ON A.ccontrollogfk = B.crecorduid AND B.ccontrolentity='Organisation'
  UNION 
    SELECT C.crecorduid, D.corganisationfk AS cobjectuid, C.ccontrollogfk, C.cpermissionfk, C.coptionuid
    FROM
      vcontrolidentresult C
    INNER JOIN tallocation D ON C.cobjectuid = D.cidentityfk;

-- CONTROLORGRESULT view
CREATE VIEW vcontrolorgresult AS
    SELECT A.crecorduid, A.cobjectuid, A.ccontrollogfk, A.cpermissionfk, A.coptionuid
    FROM
      vcontrolflatorgresult A
  UNION 
    SELECT B.crecorduid, C.cparentorganisationfk AS cobjectuid, B.ccontrollogfk, B.cpermissionfk, B.coptionuid
    FROM
      vcontrolflatorgresult B
    INNER JOIN trelationship C ON B.cobjectuid = C.corganisationfk;

-- CONTROLASSETRESULT view
CREATE VIEW vcontrolassetresult AS
    SELECT A.crecorduid, A.cobjectuid, A.ccontrollogfk, A.cpermissionfk, A.coptionuid
    FROM
      tcontrolresult A
    INNER JOIN tcontrollog B ON A.ccontrollogfk = B.crecorduid AND B.ccontrolentity='Asset'
  UNION 
    SELECT C.crecorduid, D.cassetfk, C.ccontrollogfk, C.cpermissionfk, C.coptionuid
    FROM
      vcontrolorgresult C
    INNER JOIN twork D ON C.cobjectuid = D.corganisationfk;

-- DIRECT TICKETLINK view
CREATE VIEW vdirectticketlink AS
  SELECT * from tticketlink WHERE cindirect='0';

-- DELEGATION view
CREATE VIEW vdelegation AS
    SELECT d.crecorduid, d.cactive, d.clabel, d.ccomment, d.crequestorfk, d.crequestoruid, d.crequestorfullname, d.cdelegatorfk, d.cdelegatoruid, d.cdelegatorfullname, i.crecorduid AS cdelegateefk,
        d.cdelegateeuid, d.cdelegateefullname, d.cbegindate, d.cbeginday, d.cenddate, d.cendday, d.crolelist, d.cprocdeflist, d.cticketlogbeginfk, d.cticketlogendfk
    FROM tdelegation d
    INNER JOIN tidentity i ON i.cidentityuid = d.cdelegateeuid;

-- DIRECT RELATIONSHIP view
CREATE VIEW vportaldirectrelationship AS
  SELECT * from tportalrelationship WHERE cindirect='0';

-- UPWARD RECURSIVE ALLOCATION view
CREATE VIEW vportalupallocation AS
    SELECT
      ctimeslotfk, crepositoryfk,
      cidentityfk, corganisationfk, cjobtitlefk, '0' AS cindirect
    FROM
      tportalallocation
  UNION ALL
    SELECT
      A.ctimeslotfk, A.crepositoryfk,
      A.cidentityfk, R.cparentorganisationfk AS corganisationfk, A.cjobtitlefk, '1' AS cindirect
    FROM
      tportalallocation A
    INNER JOIN tportalrelationship R ON R.corganisationfk = A.corganisationfk;

-- DOWNWARD RECURSIVE ALLOCATION view
CREATE VIEW vportaldownallocation AS
    SELECT
      ctimeslotfk, crepositoryfk,
      cidentityfk, corganisationfk, cjobtitlefk, '0' AS cindirect
    FROM
      tportalallocation
  UNION ALL
    SELECT
      A.ctimeslotfk, A.crepositoryfk,
      A.cidentityfk, R.corganisationfk, A.cjobtitlefk, '1' AS cindirect
    FROM
      tportalallocation A
    INNER JOIN tportalrelationship R ON R.cparentorganisationfk = A.corganisationfk;

-- DIRECT BOSS view
CREATE VIEW vportaldirectboss AS
  SELECT * from tportalboss WHERE cindirect='0';

-- BOSS link view
CREATE VIEW vportalbosslink AS
  SELECT DISTINCT
    B.ctimeslotfk AS ctimeslotfk, B.cidentityfk AS cidentityfk, C.cbossidentityfk AS cbossidentityfk
  FROM
    tportalboss B
  INNER JOIN tportalboss C ON B.cbossidentityfk = C.cidentityfk
  WHERE NOT EXISTS (
    SELECT
      D.crecorduid
    FROM tportalboss D
    WHERE
      D.cidentityfk = B.cidentityfk
    AND
      D.cbossidentityfk = C.cbossidentityfk
  );
  
 -- DIRECT identity manager view
CREATE VIEW vpdirectidentitymanagers AS
  SELECT m.crecorduid,m.ctimeslotfk,m.corganisationfk,m.crepositoryfk,m.caccountfk,m.cgroupfk,m.cpermissionfk,m.capplicationfk,m.cassetfk,m.ccampaignfk,m.cmanagedidentityfk,m.cindirect,
  		 m.cexpertisedomainfk,m.cidentityfk,m.ccollected,m.cdelegation,m.cpriority,m.cstartdate,m.cstartday,m.cenddate,m.cendday,m.ccomment,m.cdelegationreason
  FROM tportalmanager m
  INNER JOIN tportalidentity i ON i.crecorduid = m.cmanagedidentityfk
  WHERE m.cindirect='0' OR m.cindirect IS NULL;

-- UPWARD RECURSIVE MANAGER view
CREATE VIEW vportalupmanager AS
    SELECT
      ctimeslotfk, 
      corganisationfk, cexpertisedomainfk, cidentityfk, '0' AS cindirect
    FROM
      tportalmanager
  UNION ALL
    SELECT
      M.ctimeslotfk, 
      R.cparentorganisationfk AS corganisationfk, M.cexpertisedomainfk,
      M.cidentityfk, '1' AS cindirect
    FROM
      tportalmanager M
    INNER JOIN tportalrelationship R ON R.corganisationfk = M.corganisationfk;

-- DOWNWARD RECURSIVE MANAGER view
CREATE VIEW vportaldownmanager AS
    SELECT
      ctimeslotfk, 
      corganisationfk, cexpertisedomainfk, cidentityfk, '0' AS cindirect
    FROM
      tportalmanager
  UNION ALL
    SELECT
      M.ctimeslotfk,
      R.corganisationfk, M.cexpertisedomainfk, M.cidentityfk, '1' AS cindirect
    FROM
      tportalmanager M
    INNER JOIN tportalrelationship R ON R.cparentorganisationfk = M.corganisationfk;

-- MANAGER OR BOSS inner view
CREATE VIEW vportalmanagerorboss AS
    SELECT
      ctimeslotfk, cidentityfk, cbossidentityfk, cindirect
    FROM
      tportalboss
  UNION ALL
    SELECT
      A.ctimeslotfk, A.cidentityfk, M.cidentityfk as cbossidentityfk, '0' as cindirect
    FROM
      tportalallocation A
    INNER JOIN tportalmanager M ON M.corganisationfk = A.corganisationfk AND A.cidentityfk <> M.cidentityfk
  UNION ALL
    SELECT
      A.ctimeslotfk, A.cidentityfk, D.cidentityfk as cbossidentityfk, D.cindirect
    FROM
      tportalallocation A
    INNER JOIN vportaldownmanager D ON D.corganisationfk = A.corganisationfk;

-- GENERIC MANAGER view
CREATE VIEW vportalgenericmanager AS
  SELECT DISTINCT
    I.ctimeslotfk, M.cidentityfk, M.cbossidentityfk, M.cindirect
  FROM
    tportalidentity I
  LEFT JOIN vportalmanagerorboss M ON M.cidentityfk = I.crecorduid;

-- GENERIC TEAM view
CREATE VIEW vportalgenericteam AS
  SELECT DISTINCT
    I.ctimeslotfk, M.cidentityfk, M.cbossidentityfk, M.cindirect
  FROM
    tportalidentity I
  LEFT JOIN vportalmanagerorboss M ON M.cbossidentityfk = I.crecorduid;

-- DIRECT GENERIC MANAGER view
CREATE VIEW vportaldirectgenericmanager AS
  SELECT * from vportalgenericmanager WHERE cindirect='0';

-- DIRECT GENERIC TEAM view
CREATE VIEW vportaldirectgenericteam AS
  SELECT * from vportalgenericteam WHERE cindirect='0';

-- DIRECT GROUPLINK view
CREATE VIEW vportaldirectgrouplink AS
  SELECT * from tportalgrouplink WHERE cindirect='0';

-- UPWARD RECURSIVE ACCOUNTGROUP view
CREATE VIEW vportalupaccountgroup AS
    SELECT
      ctimeslotfk, 
      crepositoryfk, caccountfk, cparentgroupfk, '0' AS cindirect
    FROM
      tportalaccountgroup
  UNION ALL
    SELECT
      A.ctimeslotfk,
      A.crepositoryfk, A.caccountfk, G.cparentgroupfk, '1' AS cindirect
    FROM
      tportalaccountgroup A
    INNER JOIN tportalgrouplink G ON G.cgroupfk = A.cparentgroupfk;

-- DOWNWARD RECURSIVE ACCOUNTGROUP view
CREATE VIEW vportaldownaccountgroup AS
    SELECT
      ctimeslotfk, 
      crepositoryfk, caccountfk, cparentgroupfk, '0' AS cindirect
    FROM
      tportalaccountgroup
  UNION ALL
    SELECT
      A.ctimeslotfk, 
      A.crepositoryfk, A.caccountfk, G.cgroupfk AS cparentgroupfk, '1' AS cindirect
    FROM
      tportalaccountgroup A
    INNER JOIN tportalgrouplink G ON G.cparentgroupfk = A.cparentgroupfk;

-- DIRECT HIERARCHY view
CREATE VIEW vportaldirecthierarchy AS
  SELECT * from tportalhierarchy WHERE cindirect='0';

-- DIRECT PERMISSIONLINK view
CREATE VIEW vportaldirectpermissionlink AS
  SELECT * from tportalpermissionlink WHERE cindirect='0';

-- INDIRECT PERMISSIONLINK view
CREATE VIEW vportalindirectpermissionlink AS
  SELECT * from tportalpermissionlink WHERE cindirect='0' OR cindirect='1';


-- UPWARD RECURSIVE RIGHTGROUP view
CREATE VIEW vportaluprightgroup AS
    SELECT
      ctimeslotfk, crightgroupuid, crepositoryfk,
      cpermissionfk, cgroupfk, cperimeterfk, '1' as cfromgroup, '0' AS cindirect,
      cdisplayname, caction, climit, cinherited,
      crighttype, cdefault, ccontext,
      ccustom1, ccustom2, ccustom3, ccustom4, ccustom5, ccustom6, ccustom7, ccustom8, ccustom9
    FROM
      tportalrightgroup
  UNION ALL
    SELECT DISTINCT
      A.ctimeslotfk, A.crightgroupuid, A.crepositoryfk,
      A.cpermissionfk, R.cparentgroupfk AS cgroupfk, A.cperimeterfk, '1' as cfromgroup, '1' AS cindirect,
      A.cdisplayname, A.caction, A.climit, A.cinherited,
      A.crighttype, A.cdefault, A.ccontext,
      A.ccustom1, A.ccustom2, A.ccustom3, A.ccustom4, A.ccustom5, A.ccustom6, A.ccustom7, A.ccustom8, A.ccustom9
    FROM
      tportalrightgroup A
    INNER JOIN tportalgrouplink R ON R.cgroupfk = A.cgroupfk;

-- DOWNWARD RECURSIVE RIGHTGROUP view
CREATE VIEW vportaldownrightgroup AS
    SELECT
      ctimeslotfk, crightgroupuid, crepositoryfk,
      cpermissionfk, cgroupfk, cperimeterfk, '1' as cfromgroup, '0' AS cindirect,
      cdisplayname, caction, climit, cinherited,
      crighttype, cdefault, ccontext,
      ccustom1, ccustom2, ccustom3, ccustom4, ccustom5, ccustom6, ccustom7, ccustom8, ccustom9
    FROM
      tportalrightgroup
  UNION ALL
    SELECT DISTINCT
      A.ctimeslotfk, A.crightgroupuid, A.crepositoryfk,
      A.cpermissionfk, R.cgroupfk AS cgroupfk, A.cperimeterfk, '1' as cfromgroup, '1' AS cindirect,
      A.cdisplayname, A.caction, A.climit, A.cinherited,
      A.crighttype, A.cdefault, A.ccontext,
      A.ccustom1, A.ccustom2, A.ccustom3, A.ccustom4, A.ccustom5, A.ccustom6, A.ccustom7, A.ccustom8, A.ccustom9
    FROM
      tportalrightgroup A
    INNER JOIN tportalgrouplink R ON R.cparentgroupfk = A.cgroupfk;

-- AGGREGATED RIGHT view for rights belonging to permissions




CREATE VIEW vportalaggregatedright (ctimeslotfk,crightuid,cdisplayname,cfromgroup,cinherited,cindirect,caction,climit,crepositoryfk,caccountfk,cpermissionfk,cperimeterfk,crighttype,cdefault,
			ccontext,ccustom1,ccustom2,ccustom3,ccustom4,ccustom5,ccustom6,ccustom7,ccustom8,ccustom9) 
			
	AS SELECT direct.ctimeslotfk,direct.crightuid,direct.cdisplayname,direct.cfromgroup,direct.cinherited,direct.cindirect,direct.caction,direct.climit,direct.crepositoryfk,
			direct.caccountfk,direct.cpermissionfk,direct.cperimeterfk,direct.crighttype,direct.cdefault,direct.ccontext,direct.ccustom1,direct.ccustom2,direct.ccustom3,
			direct.ccustom4,direct.ccustom5,direct.ccustom6,direct.ccustom7,direct.ccustom8,direct.ccustom9 

	FROM (
	        SELECT r.ctimeslotfk,r.crightuid,r.cdisplayname,r.cfromgroup,r.cinherited,r.cindirect,r.caction,r.climit,r.crepositoryfk,r.caccountfk,r.cpermissionfk,
			CASE
			    WHEN (r.cperimeterfk IS NULL)
			    THEN '-1'::INTEGER
			    ELSE r.cperimeterfk
			END AS cperimeterfk,
			r.crighttype,r.cdefault,r.ccontext,r.ccustom1,r.ccustom2,r.ccustom3,r.ccustom4,r.ccustom5,r.ccustom6,r.ccustom7,r.ccustom8,r.ccustom9
			FROM tportalright r
    	) direct
UNION ALL
SELECT fromgroup.ctimeslotfk,fromgroup.crightuid,fromgroup.cdisplayname,fromgroup.cfromgroup,fromgroup.cinherited,fromgroup.cindirect,fromgroup.caction,
	fromgroup.climit,fromgroup.crepositoryfk,fromgroup.caccountfk,fromgroup.cpermissionfk,fromgroup.cperimeterfk,fromgroup.crighttype,fromgroup.cdefault,fromgroup.ccontext,
	fromgroup.ccustom1,fromgroup.ccustom2,fromgroup.ccustom3,fromgroup.ccustom4,fromgroup.ccustom5,fromgroup.ccustom6,fromgroup.ccustom7,fromgroup.ccustom8,fromgroup.ccustom9
FROM
    (
        SELECT r.ctimeslotfk,r.crightgroupuid AS crightuid,r.cdisplayname,'1'::CHARACTER(1) AS cfromgroup,r.cinherited,r.cindirect,r.caction,r.climit,r.crepositoryfk,a.caccountfk,r.cpermissionfk,
		CASE
			WHEN (r.cperimeterfk IS NULL)
			THEN '-1'::INTEGER
			ELSE r.cperimeterfk
		END AS cperimeterfk,
		r.crighttype,r.cdefault,r.ccontext,r.ccustom1,r.ccustom2,r.ccustom3,r.ccustom4,r.ccustom5,r.ccustom6,r.ccustom7,r.ccustom8,r.ccustom9
        FROM (tportalrightgroup r JOIN tportalaccountgroup a ON ((r.cgroupfk = a.cparentgroupfk)))
    ) fromgroup;

-- OVERALLOCATION view
CREATE VIEW vportaloverentitlement AS
  SELECT I.ctimeslotfk, I.crecorduid AS cidentityfk, P.crecorduid AS cpermissionfk
  FROM
    tportalidentity I
    INNER JOIN tportalreconciliation R ON R.cidentityfk = I.crecorduid
    INNER JOIN tportalaccount A ON A.crecorduid = R.caccountfk
    INNER JOIN vportalaggregatedright AR ON AR.caccountfk = A.crecorduid
    INNER JOIN tportalpermissionlink L ON AR.cpermissionfk = L.cparentpermissionfk
    INNER JOIN tportalpermission P ON L.cpermissionfk = P.cpermissionlinkfk
  WHERE
    (A.cdisabled IS NULL OR A.cdisabled = '0')
  AND
    NOT EXISTS (
      SELECT 1
      FROM
        tportaltheoricalright TR
      WHERE
        TR.cidentityfk = I.crecorduid AND TR.cpermissionfk = P.crecorduid
      UNION
      SELECT 1
      FROM
        tportalderogation D
      WHERE
        D.cidentityfk = I.crecorduid AND D.cpermissionfk = P.crecorduid
    )
;

-- UNDERALLOCATION view



CREATE VIEW vportalunderentitlement AS
  WITH
    thecurrent AS (
      SELECT I.crecorduid AS iru, P.crecorduid AS pru
      FROM
        tportalidentity I
      INNER JOIN tportalreconciliation R ON R.cidentityfk = I.crecorduid
      INNER JOIN tportalaccount A ON A.crecorduid = R.caccountfk
      INNER JOIN vportalaggregatedright AR ON AR.caccountfk = A.crecorduid
      INNER JOIN tportalpermissionlink L ON AR.cpermissionfk = L.cparentpermissionfk
      INNER JOIN tportalpermission P ON L.cpermissionfk = P.cpermissionlinkfk
      WHERE
        (A.cdisabled IS NULL OR A.cdisabled = '0')
    )
  SELECT TR.ctimeslotfk, TR.cidentityfk as cidentityfk, TR.cpermissionfk as cpermissionfk
  FROM
    tportaltheoricalright TR
  WHERE NOT EXISTS (
    SELECT 1
    FROM
      thecurrent C
  WHERE
      C.iru = TR.cidentityfk AND C.pru = TR.cpermissionfk
  )
  UNION
  SELECT D.ctimeslotfk, D.cidentityfk as cidentityfk, D.cpermissionfk as cpermissionfk
  FROM
    tportalderogation D
  WHERE NOT EXISTS (
    SELECT 1
    FROM
      thecurrent C
  WHERE
      C.iru = D.cidentityfk AND C.pru = D.cpermissionfk
  )
;

-- CONTROLRESULT view to simulate old tportalcontrolresult
CREATE VIEW vportalcontrolresult AS
  SELECT d.ccontrollogfk AS ccontrollogfk, r.cpermissionfk AS cpermissionfk, CAST (NULL AS INTEGER) AS coptionuid,
    CASE 
      WHEN r.crecorduid IS NOT NULL THEN r.crecorduid
      ELSE d.crecorduid
    END AS crecorduid,
    CASE l.ccontrolentity
      WHEN 'Permission' THEN d.cpermissionfk
      WHEN 'Application' THEN d.capplicationfk
      WHEN 'Account' THEN d.caccountfk
      WHEN 'Group' THEN d.cgroupfk
      WHEN 'Identity' THEN d.cidentityfk
      WHEN 'Organisation' THEN d.corganisationfk
      WHEN 'Asset' THEN d.cassetfk
      ELSE NULL
    END AS cobjectuid
  FROM tportalcontroldiscrepancy d INNER JOIN tportalcontrollog l ON l.crecorduid = d.ccontrollogfk LEFT JOIN tportalcontrolrootcause r ON r.ccontroldiscrepancyfk = d.crecorduid;

-- CONTROLIDENTRESULT view
CREATE VIEW vportalcontrolidentresult AS
    SELECT A.crecorduid, A.cobjectuid, A.ccontrollogfk, A.cpermissionfk, A.coptionuid
    FROM
      tportalcontrolresult A
    INNER JOIN tportalcontrollog B ON A.ccontrollogfk = B.crecorduid AND B.ccontrolentity='Identity'
  UNION 
    SELECT C.crecorduid, E.cidentityfk AS cobjectuid, C.ccontrollogfk, C.cpermissionfk, C.coptionuid
    FROM
      tportalcontrolresult C
    INNER JOIN tportalcontrollog D ON C.ccontrollogfk = D.crecorduid AND D.ccontrolentity='Account'
    INNER JOIN tportalreconciliation E ON C.cobjectuid = E.caccountfk;

-- CONTROLFLATORGRESULT view
CREATE VIEW vportalcontrolflatorgresult AS
    SELECT A.crecorduid, A.cobjectuid, A.ccontrollogfk, A.cpermissionfk, A.coptionuid
    FROM
      tportalcontrolresult A
    INNER JOIN tportalcontrollog B ON A.ccontrollogfk = B.crecorduid AND B.ccontrolentity='Organisation'
  UNION 
    SELECT C.crecorduid, D.corganisationfk AS cobjectuid, C.ccontrollogfk, C.cpermissionfk, C.coptionuid
    FROM
      vportalcontrolidentresult C
    INNER JOIN tportalallocation D ON C.cobjectuid = D.cidentityfk;

-- CONTROLORGRESULT view
CREATE VIEW vportalcontrolorgresult AS
    SELECT A.crecorduid, A.cobjectuid, A.ccontrollogfk, A.cpermissionfk, A.coptionuid
    FROM
      vportalcontrolflatorgresult A
  UNION 
    SELECT B.crecorduid, C.cparentorganisationfk AS cobjectuid, B.ccontrollogfk, B.cpermissionfk, B.coptionuid
    FROM
      vportalcontrolflatorgresult B
    INNER JOIN tportalrelationship C ON B.cobjectuid = C.corganisationfk;

-- CONTROLASSETRESULT view
CREATE VIEW vportalcontrolassetresult AS
    SELECT A.crecorduid, A.cobjectuid, A.ccontrollogfk, A.cpermissionfk, A.coptionuid
    FROM
      tportalcontrolresult A
    INNER JOIN tportalcontrollog B ON A.ccontrollogfk = B.crecorduid AND B.ccontrolentity='Asset'
  UNION 
    SELECT C.crecorduid, D.cassetfk, C.ccontrollogfk, C.cpermissionfk, C.coptionuid
    FROM
      vportalcontrolorgresult C
    INNER JOIN tportalwork D ON C.cobjectuid = D.corganisationfk;

-- DELEGATION view
CREATE VIEW vportaldelegation AS
    SELECT d.crecorduid, d.cactive, d.clabel, d.ccomment, d.crequestorfk, d.crequestoruid, d.crequestorfullname, d.cdelegatorfk, d.cdelegatoruid, d.cdelegatorfullname, i.crecorduid AS cdelegateefk,
        d.cdelegateeuid, d.cdelegateefullname, d.cbegindate, d.cbeginday, d.cenddate, d.cendday, d.crolelist, d.cprocdeflist, d.cticketlogbeginfk, d.cticketlogendfk
    FROM tportaldelegation d
    INNER JOIN tportalidentity i ON i.cidentityuid = d.cdelegateeuid;

-- FSAGGREGATEDRIGHT view
CREATE VIEW vfsaggregatedright AS
   SELECT R.ctimeslotfk, R.caction, R.cbasic, R.corder, R.cread, R.cwrite, R.ccontrol, A.caccountfk, R.cpermissionfk
    FROM  tfsrightgroup R
    INNER JOIN tvaccountgroup A ON R.cgroupfk = A.cparentvgroupfk ;
    
-- PORTAL
CREATE VIEW vportalfsaggregatedright AS
   SELECT R.ctimeslotfk, R.caction,R.cbasic, R.corder, R.cread, R.cwrite, R.ccontrol, A.caccountfk, R.cpermissionfk
    FROM  tportalfsrightgroup R
    INNER JOIN tportalvaccountgroup A ON R.cgroupfk = A.cparentvgroupfk ;
	


  -- Upgrade script to version 35
-- --------


CREATE SEQUENCE confitem_sequence;
CREATE TABLE tconfitem (
  -- Database primary key
  crecorduid            BIGINT NOT NULL DEFAULT NEXTVAL('confitem_sequence'),
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
  cdetails              TEXT,
  caddress              VARCHAR(1000),
  clocationfk           BIGINT,
  cimportaction         CHAR(1)       NOT NULL,
  cdeletedaction        CHAR(1),
  CONSTRAINT confitem_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT confitem_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT confitem_uid_uk UNIQUE (ctimeslotfk, cconfitemuid)
);


CREATE SEQUENCE confitemlink_sequence;
CREATE TABLE tconfitemlink (
  -- Database primary key
  crecorduid            BIGINT NOT NULL DEFAULT NEXTVAL('confitem_sequence'),
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
  cdetails              TEXT,
  caddress              VARCHAR(1000),
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
  cdetails              TEXT,
  caddress              VARCHAR(1000),
  clocationfk           BIGINT,
  cimportaction         CHAR(1)       NOT NULL,
  cdeletedaction        CHAR(1),
  CONSTRAINT pconfitem_uid_pk PRIMARY KEY (crecorduid),
  CONSTRAINT pconfitem_timeslot_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid),
  CONSTRAINT pconfitem_uid_uk UNIQUE (ctimeslotfk, cconfitemuid)
);

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

ALTER TABLE tmetadata ADD cconfitemfk BIGINT;
ALTER TABLE tmetadatavalue ADD cvalueconfitemuid VARCHAR(64);
ALTER TABLE tmetadatavalue ADD cvalueconfitemfk BIGINT;

ALTER TABLE tmetadata ADD csearchlogfk BIGINT;
ALTER TABLE tmetadata ADD csearchloguid VARCHAR(250);
ALTER TABLE tmetadatavalue ADD cvaluesearchlogfk BIGINT;
ALTER TABLE tmetadatavalue ADD cvaluesearchloguid VARCHAR(250);

CREATE INDEX idx_metadata_confitem ON tmetadata(cconfitemfk);
CREATE INDEX idx_metadatav_confitem ON tmetadatavalue(cmetadatafk,cvalueconfitemfk);

CREATE INDEX idx_metadata_searchlog ON tmetadata(csearchlogfk);
CREATE INDEX idx_metadatav_searchlog ON tmetadatavalue(cmetadatafk,cvaluesearchlogfk);

ALTER TABLE timportmetadata ADD cconfitemfk VARCHAR(64);
ALTER TABLE timportmetadatavalue ADD cvalueconfitemfk VARCHAR(64);

ALTER TABLE tportalmetadata ADD cconfitemfk BIGINT;
ALTER TABLE tportalmetadatavalue ADD cvalueconfitemuid VARCHAR(64);
ALTER TABLE tportalmetadatavalue ADD cvalueconfitemfk BIGINT;

ALTER TABLE tportalmetadata ADD csearchlogfk BIGINT;
ALTER TABLE tportalmetadata ADD csearchloguid VARCHAR(250);
ALTER TABLE tportalmetadatavalue ADD cvaluesearchlogfk BIGINT;
ALTER TABLE tportalmetadatavalue ADD cvaluesearchloguid VARCHAR(250);

CREATE INDEX idx_pmetadata_confitem ON tportalmetadata(cconfitemfk);
CREATE INDEX idx_pmetadatav_confitem ON tportalmetadatavalue(cmetadatafk,cvalueconfitemfk);

CREATE INDEX idx_pmetadata_searchlog ON tportalmetadata(csearchlogfk);
CREATE INDEX idx_pmetadatav_searchlog ON tportalmetadatavalue(cmetadatafk,cvaluesearchlogfk);

CREATE SEQUENCE pamprogram_sequence;
CREATE TABLE tpamprogram (
  -- Database primary key
  crecorduid            BIGINT NOT NULL DEFAULT NEXTVAL('pamprogram_sequence'),
  -- Object information
  cname                 VARCHAR(250) NOT NULL,
  cdescription          VARCHAR(4000),
  cdeadline             VARCHAR(15),
  CONSTRAINT pamprogram_uid_pk PRIMARY KEY (crecorduid)
);


CREATE SEQUENCE pamscope_sequence;
CREATE TABLE tpamscope (
  -- Database primary key
  crecorduid            BIGINT NOT NULL DEFAULT NEXTVAL('pamscope_sequence'),
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


CREATE SEQUENCE pamscopeincl_sequence;
CREATE TABLE tpamscopeincl (
  -- Database primary key
  crecorduid            BIGINT NOT NULL DEFAULT NEXTVAL('pamscopeincl_sequence'),
  -- Object information
  cscopefk              BIGINT NOT NULL,
  ctype                 CHAR(1)       NOT NULL,
  ctitle                VARCHAR(1000) NOT NULL,
  cruleid               VARCHAR(250),
  capplications         TEXT,
  cconfitems            TEXT,
  crepositories         TEXT,
  CONSTRAINT pamscopeincl_uid_pk PRIMARY KEY (crecorduid)
);


CREATE SEQUENCE pammilestone_sequence;
CREATE TABLE tpammilestone (
  -- Database primary key
  crecorduid            BIGINT NOT NULL DEFAULT NEXTVAL('pammilestone_sequence'),
  -- Object information
  cprogramfk            BIGINT,
  cscopefk              BIGINT,
  cname                 VARCHAR(250),
  cdeadline             VARCHAR(15),
  CONSTRAINT pammilestone_uid_pk PRIMARY KEY (crecorduid)
);


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
  crecorduid            BIGINT NOT NULL DEFAULT NEXTVAL('reviewactor_sequence'),
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       BIGINT NOT NULL,
  cactorfk            BIGINT NOT NULL,
  CONSTRAINT reviewactor_ts_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);



-- REVIEWACCOUNTABLE table
CREATE SEQUENCE reviewaccountable_sequence;
CREATE TABLE treviewaccountable (
  -- Database primary key
  crecorduid            BIGINT NOT NULL DEFAULT NEXTVAL('reviewaccountable_sequence'),
  -- Archive information
  ctimeslotfk           VARCHAR(64)   NOT NULL,
  -- Object information
  cticketreviewfk       BIGINT NOT NULL,
  caccountablefk            BIGINT NOT NULL,
  CONSTRAINT reviewaccountable_ts_fk FOREIGN KEY (ctimeslotfk) REFERENCES timportlog(cimportloguid)
);


-- PORTALREVIEWACTOR table
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

CREATE INDEX IF NOT EXISTS idx_metadata_ts_master ON tmetadata(ctimeslotfk, cmastermetadatafk);
CREATE INDEX IF NOT EXISTS idx_pmetadata_ts_master ON tportalmetadata(ctimeslotfk, cmastermetadatafk);

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
