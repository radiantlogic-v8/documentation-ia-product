/* 
COPYRIGHT BRAINWAVE, all rights reserved.
This computer program is protected by copyright law and international treaties.
Unauthorized duplication or distribution of this program, or any portion of it, may result in severe civil or criminal penalties, and will be prosecuted to the maximum extent possible under the law.

Usage: Upgrades The database schema from version Braille R1 to Curie R1

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
