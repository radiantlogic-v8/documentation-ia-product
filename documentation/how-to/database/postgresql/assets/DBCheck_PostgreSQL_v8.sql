-- 
-- Copyright Radiant Logic 2020 - Ledger Base - PostgreSQL 9.6 and > 
-- Date creation : 05/2017
-- Date updated : 06/2021
--
-- Version: 8.0
-- Execute this script inside psql session as following: 
-- psql -h localhost -p 5432 -d igrc -U postgres -f <ABSOLUTE PATH TO FILE>/DBcheck_postgreSQL.sql > result.txt
-- -h hostname  -p port_number   -d database_name  -U postgres username
-- Return result.txt file to Identity Analytics for analysis.
-- !!!!!!!!!!!! WARNING !!!!!!!!!!! : REPLACE schema_name (Lines : 18 and 19)

-- Set default schema for this session only
-- Example:
-- SET search_path = 'ledger';                        
-- \set SchemaVariable '''ledger'''                   

SET search_path = '<TO CHANGE>';                      --  !REPLACE schema_name
\set SchemaVariable '''<TO CHANGE>'''                 --  !REPLACE schema_name 

\set ECHO none

-- Version of PostgreSQL Server
\echo Version of PostgreSQL Server :
\echo 
select version();

-- Parameters of PostgreSQL
\echo ===================================
\echo List of parameters defined :
\echo 

select * from pg_settings;


-- Size of databases
\echo ===================================
\echo Size of Databases :
\echo 

SELECT 
    datname AS DatabaseName
    ,pg_catalog.pg_get_userbyid(datdba) AS OwnerName
    ,CASE 
        WHEN pg_catalog.has_database_privilege(datname, 'CONNECT')
        THEN pg_catalog.pg_size_pretty(pg_catalog.pg_database_size(datname))
        ELSE 'No Access For You'
    END AS DatabaseSize
FROM pg_catalog.pg_database
ORDER BY 
    CASE 
        WHEN pg_catalog.has_database_privilege(datname, 'CONNECT')
        THEN pg_catalog.pg_database_size(datname)
        ELSE NULL
    END DESC;

	
-- Size of Objects
\echo ===================================
\echo Size of tables and indexes associated :
\echo 

SELECT *, pg_size_pretty(total_bytes) AS total
    , pg_size_pretty(index_bytes) AS INDEX
    , pg_size_pretty(toast_bytes) AS toast
    , pg_size_pretty(table_bytes) AS TABLE
  FROM (
  SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes FROM (
      SELECT c.oid,nspname AS table_schema, relname AS TABLE_NAME
              , c.reltuples AS row_estimate
              , pg_total_relation_size(c.oid) AS total_bytes
			  , ROUND(pg_total_relation_size(c.oid) / NULLIF(c.reltuples,0)) AS size_row_bytes
              , pg_indexes_size(c.oid) AS index_bytes
              , pg_total_relation_size(reltoastrelid) AS toast_bytes
          FROM pg_class c
          LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
          WHERE relkind = 'r' and n.nspname = :SchemaVariable
  ) a
) a order by 8 desc;


-- Number of objects (Tables, indexes, sequences, views)
\echo ===================================
\echo Number of objects :
\echo 

-- select count(relname) as "Number of Tables" from pg_class where relkind= 'r' and (relname !~ '^pg_' and relname !~ '^sql');
select count(relname) as "Number of tables" from pg_class c left join pg_namespace n on n.oid = c.relnamespace where relkind= 'r' and n.nspname = :SchemaVariable;

-- Number of indexes
select count(relname) as "Number of indexes" from pg_class c left join pg_namespace n on n.oid = c.relnamespace where relkind= 'i' and n.nspname = :SchemaVariable;

-- Number of Sequences
select count(relname) as "Number of Sequences" from pg_class c left join pg_namespace n on n.oid = c.relnamespace where relkind= 'S' and n.nspname = :SchemaVariable;

-- Number of views
select count(relname) as "Number of views" from pg_class c left join pg_namespace n on n.oid = c.relnamespace where relkind= 'v' and n.nspname = :SchemaVariable;

-- List of views
select relname as "View name" from pg_class c left join pg_namespace n on n.oid = c.relnamespace where relkind= 'v' and n.nspname = :SchemaVariable;

-- CheckNbRecordperTS
\echo ===================================
\echo Nb of records per timeslot :
\echo 

select count(*) as "Identity",cimportdate as "Import date" from tidentity join timportlog on ctimeslotfk=cimportloguid group by cimportdate order by 2;
select count(*) as "Accounts",cimportdate as "Import date" from taccount join timportlog on ctimeslotfk=cimportloguid group by cimportdate order by 2;
select count(*) as "Organisation",cimportdate as "Import date" from torganisation join timportlog on ctimeslotfk=cimportloguid group by cimportdate order by 2;
select count(*) as "Application",cimportdate as "Import date" from tapplication join timportlog on ctimeslotfk=cimportloguid group by cimportdate order by 2;
select count(*) as "Groups",cimportdate as "Import date" from tgroup join timportlog on ctimeslotfk=cimportloguid group by cimportdate order by 2;
select count(*) as "Permission",cimportdate as "Import date" from tpermission join timportlog on ctimeslotfk=cimportloguid group by cimportdate order by 2;
select count(*) as "Right",cimportdate as "Import date" from tright join timportlog on ctimeslotfk=cimportloguid group by cimportdate order by 2;
select count(*) as "Right Group",cimportdate as "Import date" from trightgroup join timportlog on ctimeslotfk=cimportloguid group by cimportdate order by 2;
select count(*) as "Repository",cimportdate as "Import date" from trepository join timportlog on ctimeslotfk=cimportloguid group by cimportdate order by 2;
select count(*) as "Asset",cimportdate as "Import date" from tasset join timportlog on ctimeslotfk=cimportloguid group by cimportdate order by 2;
select count(*) as "View Aggregated Right",cimportdate as "Import date" from vaggregatedright join timportlog on ctimeslotfk=cimportloguid group by cimportdate order by 2;
select count(*) as "Control Log",cimportdate as "Import date" from tcontrollog join timportlog on ctimeslotfk=cimportloguid group by cimportdate order by 2;
select count(*) as "Control Results" from tcontrolresult;

-- Metadata
select count(*) as "Metadata",cimportdate as "Import date" from tmetadata m inner join timportlog l on m.ctimeslotfk = l.cimportloguid group by cimportdate order by 2 ;
-- Metadata values only if the table exists
CREATE OR REPLACE FUNCTION select_if_exists()
RETURNS TABLE ( Metadatavalues bigint, Importdate varchar)
AS
$$
BEGIN
  IF EXISTS(SELECT *
                   FROM information_schema.tables
                   WHERE table_schema = current_schema()
                         AND table_name = 'tmetadatavalue') THEN
	return query select count(*) as "Metadatavalue",
						cimportdate as "Importdate" 
						from tmetadatavalue m 
						inner join timportlog l on m.ctimeslotfk = l.cimportloguid 
						group by cimportdate order by 2;
  END IF;
END;
$$
LANGUAGE plpgsql;

SELECT * FROM select_if_exists();
drop function select_if_exists();

-- Theoretical rights
select count(*) as "Theoretical Permission",cimportdate as "Import date" from ttheoricalpermission join timportlog on ctimeslotfk=cimportloguid group by cimportdate order by 2;
select count(*) as "Theoretical Right",cimportdate as "Import date" from ttheoricalright join timportlog on ctimeslotfk=cimportloguid group by cimportdate order by 2;

-- List the contents of tproperties table
\echo ===================================
\echo Contents of tproperties table :
\echo 

select * from tproperties;

-- List the contents of timportlog table
\echo ===================================
\echo Contents of timportlog table :
\echo 

select * from timportlog order by cimportloguid;


-- Current values of statistics for each table
\echo =========================================
\echo Statistics content
\echo 

SELECT * FROM pg_stat_user_tables ORDER BY schemaname, relname;

-- Current values of max crecorduid for each table
\echo =========================================
\echo Values of max crecorduid for each table
\echo =========================================
\echo

\echo tablename, cmaxrecorduid
\echo -------------------------

\echo 

CREATE OR REPLACE FUNCTION loop_check_crecorduid_all_table() RETURNS TABLE (tablename TEXT, max_crecorduid integer) AS $$
DECLARE
        _ref_tab_name RECORD;
		SQLString TEXT;
		_cmaxcrecorduid TEXT DEFAULT ''; 
		
		-- Exclude 'tcontrolresult','tcontroldiscrepancy','tcontrolrootcause' tables because crecorduid is a bigint type
		
		v_state TEXT;
		v_msg TEXT;
		v_detail TEXT;
		v_hint TEXT;
		v_context TEXT;
		
		_table_name CURSOR FOR SELECT t.table_name, t.table_schema from information_schema.tables t inner join information_schema.columns c on c.table_name = t.table_name
		where c.column_name = 'crecorduid'
 		and t.table_type = 'BASE TABLE'
 		and t.table_schema not in ('information_schema', 'pg_catalog')
 		and t.table_name not like 'tportal%' AND t.table_name not like 'vportal%' AND t.table_name not in ('tcontrolresult','tcontroldiscrepancy','tcontrolrootcause')
 	    order by t.table_name;
			
			
BEGIN
	-- Open the cursor
   OPEN _table_name;
   
   LOOP
    -- fetch row into the film
      FETCH _table_name INTO _ref_tab_name;
    -- exit when no more row to fetch
      EXIT WHEN NOT FOUND;
	  
	-- build the output

	SQLString := 'select '''|| _ref_tab_name.table_name || ''', coalesce(max(crecorduid),0) AS "max" from ' || _ref_tab_name.table_schema || '.' || _ref_tab_name.table_name;
	
	BEGIN
	
	RETURN QUERY EXECUTE SQLString;
	
	EXCEPTION WHEN others THEN
		GET STACKED DIAGNOSTICS
			v_state = RETURNED_SQLSTATE,
			v_msg = MESSAGE_TEXT,
			v_detail = PG_EXCEPTION_DETAIL,
			v_hint = PG_EXCEPTION_HINT,
			v_context = PG_EXCEPTION_CONTEXT;
	
	raise notice E'Et une exception :
			state : %
			message: %
			detail : %
			hint : %
			context: %', v_state, v_msg, v_detail, v_hint, v_context;
	END;
	
	-- Allow to trace the content of _cmaxcrecorduid
	-- raise notice '%', _cmaxcrecorduid;
												
	END LOOP;
  
   -- Close the cursor
   CLOSE _table_name;
   -- return;
END;
$$ LANGUAGE plpgsql;

select * from loop_check_crecorduid_all_table() order by max_crecorduid DESC;
drop function loop_check_crecorduid_all_table();


-- Nb records per timeslot for each portal table
\echo =============================================
\echo Number of records per timeslot for each portal table
\echo =============================================
\echo

\echo tablename,    row_size,      nbrecords,      timeslotuid
\echo --------------------------------------------------------

CREATE OR REPLACE FUNCTION loop_check_nbrecords_all_portal_table() RETURNS TABLE (tablename TEXT, row_size TEXT, nb_cnt bigint, timeslot VARCHAR) AS $$
DECLARE
        _ref_tab_name RECORD;
		SQLString TEXT;
		_cmaxcrecorduid TEXT DEFAULT ''; 
		
		v_state TEXT;
		v_msg TEXT;
		v_detail TEXT;
		v_hint TEXT;
		v_context TEXT;
		
		_table_name CURSOR FOR SELECT t.table_name, t.table_schema from information_schema.tables t inner join information_schema.columns c on c.table_name = t.table_name
		where c.column_name = 'ctimeslotfk'
 		and t.table_type = 'BASE TABLE'
 		and t.table_schema not in ('information_schema', 'pg_catalog')
 		and t.table_name like 'tportal%' AND t.table_name not like 'vportal%'
 	    order by t.table_name;
			
			
BEGIN
	-- Open the cursor
   OPEN _table_name;
   
   LOOP
    -- fetch row into the film
      FETCH _table_name INTO _ref_tab_name;
    -- exit when no more row to fetch
      EXIT WHEN NOT FOUND;
	  
	-- build the output

	SQLString := 'select '''|| _ref_tab_name.table_name || ''', pg_size_pretty(sum(pg_column_size('|| _ref_tab_name.table_schema || '.' || _ref_tab_name.table_name ||'.*))), count(*) AS "nbrecords", ctimeslotfk from ' || _ref_tab_name.table_schema || '.' || _ref_tab_name.table_name || ' group by ctimeslotfk order by ctimeslotfk';	
	
	BEGIN

	RETURN QUERY EXECUTE SQLString;
	
	EXCEPTION WHEN others THEN
		GET STACKED DIAGNOSTICS
			v_state = RETURNED_SQLSTATE,
			v_msg = MESSAGE_TEXT,
			v_detail = PG_EXCEPTION_DETAIL,
			v_hint = PG_EXCEPTION_HINT,
			v_context = PG_EXCEPTION_CONTEXT;
	
	raise notice E'Et une exception :
			state : %
			message: %
			detail : %
			hint : %
			context: %', v_state, v_msg, v_detail, v_hint, v_context;
	END;
	
	-- Allow to trace the content of _cmaxcrecorduid
	-- raise notice '%', _cmaxcrecorduid;
												
	END LOOP;
  
   -- Close the cursor
   CLOSE _table_name;
   -- return;
END;
$$ LANGUAGE plpgsql;

select * from loop_check_nbrecords_all_portal_table() order by nb_cnt;
drop function loop_check_nbrecords_all_portal_table();


-- Nb records per timeslot for each import table

\echo =============================================
\echo Number of records per timeslot for each import table
\echo =============================================
\echo

\echo tablename,    nbrecords,      timeslotuid
\echo ------------------------------------------

CREATE OR REPLACE FUNCTION loop_check_nbrecords_all_import_table() RETURNS TABLE (tablename TEXT, nb_cnt bigint, timeslot VARCHAR) AS $$
DECLARE
        _ref_tab_name RECORD;
		SQLString TEXT;
		_cmaxcrecorduid TEXT DEFAULT ''; 
		
		v_state TEXT;
		v_msg TEXT;
		v_detail TEXT;
		v_hint TEXT;
		v_context TEXT;
		
		_table_name CURSOR FOR SELECT t.table_name, t.table_schema from information_schema.tables t inner join information_schema.columns c on c.table_name = t.table_name
		where c.column_name = 'cimportlogfk'
 		and t.table_type = 'BASE TABLE'
 		and t.table_schema not in ('information_schema', 'pg_catalog')
 		and t.table_name like 'timport%'
 	    order by t.table_name;
			
			
BEGIN
	-- Open the cursor
   OPEN _table_name;
   
   LOOP
    -- fetch row into the film
      FETCH _table_name INTO _ref_tab_name;
    -- exit when no more row to fetch
      EXIT WHEN NOT FOUND;
	  
	-- build the output
	SQLString := 'select '''|| _ref_tab_name.table_name || ''', count(*) AS "nbrecords", cimportlogfk from ' || _ref_tab_name.table_schema || '.' || _ref_tab_name.table_name || ' group by cimportlogfk order by cimportlogfk';	
	
	BEGIN
	RETURN QUERY EXECUTE SQLString;
	
	EXCEPTION WHEN others THEN
		GET STACKED DIAGNOSTICS
			v_state = RETURNED_SQLSTATE,
			v_msg = MESSAGE_TEXT,
			v_detail = PG_EXCEPTION_DETAIL,
			v_hint = PG_EXCEPTION_HINT,
			v_context = PG_EXCEPTION_CONTEXT;
	
	raise notice E'Et une exception :
			state : %
			message: %
			detail : %
			hint : %
			context: %', v_state, v_msg, v_detail, v_hint, v_context;
	END;
												
	END LOOP;
  
   -- Close the cursor
   CLOSE _table_name;
   -- return;
END;
$$ LANGUAGE plpgsql;

select * from loop_check_nbrecords_all_import_table() order by nb_cnt;
drop function loop_check_nbrecords_all_import_table() ;



-- Unused indexes
\echo =========================================
\echo Unused indexes based on statistics
\echo 

SELECT
	PSUI.indexrelid::regclass AS IndexName
	,PSUI.relid::regclass AS TableName
FROM pg_stat_user_indexes AS PSUI    
JOIN pg_index AS PI 
    ON PSUI.IndexRelid = PI.IndexRelid
WHERE PSUI.idx_scan = 0 
	AND PI.indisunique IS FALSE;
