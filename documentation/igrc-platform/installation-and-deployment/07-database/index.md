---
title: "Database configuration information"
description: "Database configuration information"
---

# Database configuration information

## Minimal rights

Following you will find the minimal rights to be associated to the database users that are necessary to use the product. These include the rights to be allocated for:  

- The ledger schema: _i.e._ `igrc`
- The workflow schema: _i.e._ `activiti`

> It is recommended to have two distinct schemas on the same database, for consistency during backups & restore operations  
> But it is also possible to use two distinct databases

You will also find included SQL scripts that are used by Radiant Logic Support Services and can be used as **examples** to create the databases on the different platforms.  

### Microsoft SQL Server

#### MS SQL Scripts

When creating the database using Microsoft the required minimal rights are:  

- For the ledger database:  

```sql  
GRANT CREATE TABLE TO igrc_user ;
GRANT CREATE VIEW TO igrc_user ;
GRANT ALTER TO igrc_user ;
GRANT ALTER ON SCHEMA :: igrc_schema TO igrc_user ;
GRANT INSERT ON SCHEMA :: igrc_schema TO igrc_user ;
GRANT SELECT ON SCHEMA :: igrc_schema TO igrc_user ;
GRANT DELETE ON SCHEMA :: igrc_schema TO igrc_user ;
GRANT REFERENCES ON SCHEMA :: igrc_schema TO igrc_user ;
GRANT UPDATE ON SCHEMA :: igrc_schema TO igrc_user ;
```

> [!warning] When migrating from an pre Curie version to Curie R1 stored procedures are used. To execute the upgrade script (see [here](./schema-35-upgrade-procedure.md) for the detailed procedure) please ensure that the account can create and execute stored procedures.  

```sql  
GRANT EXECUTE ON SCHEMA :: "<SCHEMA>" TO "<LOGIN>" ;
```

- For the workflow database:  

```sql  
GRANT CREATE TABLE TO activiti_user ;
GRANT ALTER ON SCHEMA :: activiti_schema TO activiti_user ;
GRANT REFERENCES ON SCHEMA :: activiti_schema TO activiti_user ;
GRANT SELECT ON SCHEMA :: activiti_schema to activiti_user ;
GRANT UPDATE ON SCHEMA :: activiti_schema to activiti_user ;
GRANT INSERT ON SCHEMA :: activiti_schema to activiti_user ;
GRANT DELETE ON SCHEMA :: activiti_schema to activiti_user ;
```

> Please note that the `GRANT ALTER TO igrc` permission is only required when creating or re-initializing the schema/tables.  
As such, once the database is created and initialized it is possible to revoke the permission.  

The following script allows you to create the ledger and workflow database.  
Before using the script please remember to change the necessary information such as:  

- The name of the database
- The path to Microsoft SQL Server data and log files
- The initial size, growth rate of the data and log files  
- The names of the users (optional)

> [!warning] The script includes a DROP of the database if it already exists !  

```sql  
-- ---------------------------------------------------------------------
-- Copyright Radiant Logic 2017
-- Date: 04/2017
-- SAMPLE not to be used as is
-- ---------------------------------------------------------------------

USE master;
GO

DECLARE @dbName varchar(255) ;
DECLARE @sql varchar(255) ;

SET @dbName = '<SCHEMA NAME>' ;

-- Delete the declared database if it exists
IF EXISTS( SELECT * FROM sys.databases WHERE name = @dbName )
BEGIN
    EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = @dbName ;
    USE [master]
    exec('ALTER DATABASE ['+@dbName+'] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE') ;
    USE [master]
    exec('DROP DATABASE ['+@dbName+']') ;
END

-- Create the new database
exec('CREATE DATABASE '+@dbName+'
CONTAINMENT = NONE
ON PRIMARY
( NAME = N'''+@dbName+'-01-dat'', FILENAME = ''<PATH TO DATA FILES>'+@dbName+'-01-dat.mdf'', SIZE = 5GB, FILEGROWTH = 10% )
LOG ON
( NAME = N'''+@dbName+'_01_log'', FILENAME = ''<PATH TO LOG FILES>'+@dbName+'-01-log.ldf'', SIZE = 2GB, FILEGROWTH = 10%, MAXSIZE = 5GB ) ;
')
-- Change the database recovery model
exec('ALTER DATABASE ['+@dbName+'] SET RECOVERY SIMPLE') ;
exec('IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default=1 AND name = N''PRIMARY'') ALTER DATABASE ['+@dbName+'] MODIFY FILEGROUP [PRIMARY] DEFAULT') ;

--Create the Schemas
-- IGRC
SET @sql = 'exec '+ QUOTENAME(@dbName) + '..sp_executesql N''CREATE SCHEMA igrc AUTHORIZATION dbo '''
exec (@sql)
-- ACTIVITI
SET @sql = 'exec '+ QUOTENAME(@dbName) + '..sp_executesql N''CREATE SCHEMA activiti AUTHORIZATION dbo '''
exec (@sql)

-- Create Users and schema for igrc and activiti
EXEC('USE '+@dbName+';
    CREATE USER igrc FOR LOGIN igrc WITH DEFAULT_SCHEMA = igrc ;
    GRANT CREATE TABLE TO igrc ;
    GRANT CREATE VIEW TO igrc ;
    GRANT ALTER TO igrc ;
    GRANT ALTER ON SCHEMA :: igrc TO igrc ;
    GRANT INSERT ON SCHEMA :: igrc TO igrc ;
    GRANT SELECT ON SCHEMA :: igrc TO igrc ;
    GRANT DELETE ON SCHEMA :: igrc TO igrc ;
    GRANT REFERENCES ON SCHEMA :: igrc TO igrc ;
    GRANT UPDATE ON SCHEMA :: igrc TO igrc ;
    CREATE USER activiti FOR LOGIN activiti WITH DEFAULT_SCHEMA = activiti ;
    GRANT CREATE TABLE TO activiti ;
    GRANT ALTER ON SCHEMA :: activiti TO activiti ;
    GRANT REFERENCES ON SCHEMA :: activiti TO activiti ;
    GRANT SELECT ON SCHEMA :: activiti to activiti ;
    GRANT UPDATE ON SCHEMA :: activiti to activiti ;
    GRANT INSERT ON SCHEMA :: activiti to activiti ;
    GRANT DELETE ON SCHEMA :: activiti to activiti ;')

-- Multi-thread
exec('ALTER DATABASE ['+@dbName+'] SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE') ;

GO
```

It is also possible to declare a Read-Only User. This user will only be able to read the ledger data from the studio, but will not be able to modify the data.  
You will find following an example in the following script, using database demo2016:  

```sql  
USE [master]
CREATE LOGIN [<Login name>] WITH PASSWORD=N'<Password>', DEFAULT_DATABASE=[<Ledger database name>]
GO

USE [<Ledger database name>]
CREATE USER [<User name>] FOR LOGIN [<Login name>]
ALTER USER [<User name>] WITH DEFAULT_SCHEMA=[<schema name>]
ALTER ROLE [db_datareader] ADD MEMBER [<User name>]
GO
```

#### MS SQL GUI

> These are **not recommended** settings for PRODUCTION environments, but rather **sample** configurations for DEVELOPMENT

Launch `Microsoft SQL Server Management Studio` and connect to your **MSSQL Server** instance.  

1. Create a new database
   1. In the `Object Explorer`, right click on the `Databases` folder and select `New Database...`
    ![MSSQL New Database...](./images/mssql_new_db.png "Create new MSSQL Database")
   2. In the `General` tab, set the `Database name` (for example *igrc_sample_db*)
    ![MSSQL Database name](./images/mssql_choose_db_name.png "Set the database name")
   3. In the `Options` tab, set the `Recovery model` to `Simple`
    ![MSSQL Recovery mode](./images/mssql_recovery_mode.png "Set the recovery mode to simple")
   4. Close the dialog
2. Create a new user for the **Ledger** tables in the database
   1. In the `Object Explorer`, right click on the `Security` > `Logins` folder and select `New Login...`
    ![MSSQL new login](./images/mssql_new_login.png "Create new MSSQL login")
   2. In the `General` tab, set the `Login name` (for example *sample_user_ledger*), set a `Password` (ideally a strong one that matches the policy), and select as the `Default database` the one created above (*igrc_sample_db*)
    ![MSSQL new user](./images/mssql_new_user.png "New user configuration")
   3. In the `User Mapping` tab, select the database created earlier (*igrc_sample_db*), and choose a default schema (*igrc* by default), and select the `db_owner` role
    ![MSSQL ledger user schema](./images/mssql_ledgeruser_schema.png "Set the ledger user schema")
   4. Close the dialog
3. Create a new user for the **Workflow** tables in the database (aka *activiti*)
   1. In the `Object Explorer`, right click on the `Security` > `Logins` folder and select `New Login...`
    ![MSSQL new login](./images/mssql_new_login.png "Create new MSSQL login")
   2. In the `General` tab, set the `Login name` (for example *sample_user_workflow*), set a `Password` (ideally a strong one that matches the policy), and select as the `Default database` the one created above (*igrc_sample_db*)
    ![MSSQL new workflow user](./images/mssql_new_user_activiti.png "New workflow user configuration")
   3. In the `User Mapping` tab, select the database created earlier (*igrc_sample_db*), and choose a default schema (*activiti* by default), and select the `db_owner` role
    ![MSSQL ledger user schema](./images/mssql_activitiuser_schema.png "Set the ledger user schema")
   4. Close the dialog

### Oracle

#### Database creation

If the database was not created upon installation of the database engine please follow these steps to create the database. Run the program "Database configuration Assistant" in the oracle installation home folder of the launch menu.This will open a wizard : 

1. Select the `Create a database` radio button and then click next
![Create and oracle database](./images/orcl-01-createDatabase.png "Create and oracle database")
2. Select the `Advanced configuration` radio button and click next
3. Select the Custom database template and click next
![Custom database](./images/orcl-02-customDatabase.png "Custom database")
4. Rename the database according to your context (in the followning example `igrc`) and uncheck the tickbox to `Create as a container database`. Then click next
![Database identification](./images/orcl-03-databaseIdentification.png "Database identification")
5. Select the second radio button to define the database storage options and click next  
![Database storage options](./images/orcl-04-storageOptions.png "Database storage options")
6. Click next without selecting a Fast recovery option
![Fast recovery options](./images/orcl-05-fastRecoveryOptions.png "Fast recovery options")
7. If required create a new listener and click next
![Listner](./images/orcl-06-listener.png "Listener")
8. Keep all components selected by default and click next
9. The configuration options is used to specify the following elements. It is recommended to keep the default values if you are un certain on what parameters to use  
   1. The allocated memory (SAG, PGA)
   ![Memory configuration](./images/orcl-07-memory.png "Memory configuration")
   2. The database sizing
   ![Sizing](./images/orcl-08-sizing.png "Sizing")
   3. The database character sets
   ![Character sets](./images/orcl-09-characterSets.png "Character sets")
   4. the connection mode  
   ![Connection mode](./images/orcl-10-connectionMode.png "Connection mode")
   5. The sample schemas, it is recommended not to install the sample schemas
10. In the management option, if desired you can configure by default the `Enterprise Manager (EM) Database Express`. We suggest using the default configuration
11. Then configure the Passwords of the `SYS` and `SYSTEM` user accounts. The same password can be used for both accounts using teh second option. It is highly recommended to use a secure password when configuring the database
![Password configuration](./images/orcl-11-pwd.png "Password configuration")
12. Create the database with the default values
![Creation options](./images/orcl-12-creationOptions.png "Creation options")
13. A summary is displayed. If satisfied with the configuration click finish. Once the installation is finish you can close the wizard
![Summary](./images/orcl-13-summary.png "Summary")

#### Oracle SQL Scripts

For oracle the minimal rights for the ledger and workflow users are identical. They are as following, assuming the user in `igrc`:  

```sql  
grant connect to igrc ;
grant create session to igrc ;
grant alter session to igrc ;
grant create table to igrc ;
grant create sequence igrc ;
grant create trigger to igrc ;
create view to igrc ;
grant unlimited tablespace to igrc ;
```

The following script allows you to create the ledger and workflow database.  
Before using the script please remember to change the necessary information such as:  

- The name of the user
- The path for oracles datafiles
- The size of the datafile  
- The passwords

> **Important**:  The script includes a DROP of the database if it already exists!

```sql  
-- ---------------------------------------------------------------------
-- Copyright Radiant Logic 2017
-- Date: 04/2017
-- SAMPLE not to be used as is
-- ---------------------------------------------------------------------

define schema = 'igrc'

-- ---------------------------------------------------------------------
-- Drop previous user if already exist (Allow to reuse the same script)
-- ---------------------------------------------------------------------
whenever sqlerror continue NONE
drop user &schema cascade;
drop tablespace "&schema._DATA" including contents cascade constraints;
-- ---------------------------------------
-- Creation &schema schema FOR the ledger
-- ---------------------------------------
-- Exits if an SQL command generates an error or if an operating system occurs
whenever sqlerror exit failure rollback
whenever oserror exit failure rollback
create tablespace "&schema._DATA"
  datafile '<PATH TO DATA FILE>\&schema._DATA01.dbf' SIZE 5G reuse
  autoextend on
  extent management local autoallocate
  segment space management auto online;

create user &schema identified by igrc
default tablespace "&schema._DATA"
temporary tablespace TEMP;

grant connect, create session, alter session, create table, create sequence, create trigger, create view to &schema ;
grant unlimited tablespace to &schema ;

-- ---------------------------------------------------------------------
-- Drop previous user if already exist (Allow to reuse the same script)
-- ---------------------------------------------------------------------
whenever sqlerror continue NONE
drop user "&schema._ACT" cascade;
drop tablespace "&schema._ACT_DATA" including contents cascade constraints;
-- ------------------------------------
-- Creation "&schema._ACT" schema for ACTIVITI
-- ------------------------------------
-- Exits if an SQL command generates an error or if an operating system occurs
whenever sqlerror exit failure rollback
whenever oserror exit failure rollback
create tablespace "&schema._ACT_DATA"
  datafile '<PATH TO DATA FILE>\&schema._ACT_DATA01.dbf' SIZE 1G reuse
  autoextend on
  extent management local autoallocate
  segment space management auto online;

create user "&schema._ACT" identified by activiti
default tablespace "&schema._ACT_DATA"
temporary tablespace TEMP;

grant connect, create session, alter session, create table, create sequence, create trigger, create view to "&schema._ACT" ;
grant unlimited tablespace to "&schema._ACT" ;
```

#### Oracle GUI

> These are **not recommended** settings for PRODUCTION environments, but rather **sample** configurations for DEVELOPMENT

Before creating your Schema please download the latest version of SQL:
https://www.oracle.com/database/sqldeveloper/technologies/download/

Once installed you can follow these steps :

1. Create a new connection profile using the system account to your database by providing the correct `Hostname`, `port` and `SID`  
![New connection profile](./images/orcl-14-newConnectionProfile.png "New connection profile")
![Connnection profile configuration](./images/orcl-15-connectionProfile.png "Connection profile configuration")
2. Create a new user/schema for both the ledger and the activiti user respectively by right clicking on the `Other user` element of connection profile  
![New User](./images/orcl-16-createUser.png "Create a new user")
   1. Configure the `User Name` and `password` as well as the `Default Tablespace` (`USERS`) and `Temporary Tablespace` (`TEMP`)  
   ![User configuration](./images/orcl-17-userConfiguration.png "User configuration")
   2. Configure the roles. The minimum requirements are `CONNECT` and `RESOURCE`
   ![Granted role](./images/orcl-18-grantedRoles.png "Granted roles")
   3. Configure the system privileges. The minimum requirements are :
      - create session
      - alter session
      - create table
      - create sequence
      - create trigger  
      - create view
   ![System priveleges](./images/orcl-19-systemPrivileges.png "System Privileges")
   4. Configure the quotas on the tablespace:
   ![Quotas](./images/orcl-20-quotas.png "quotas")
3. Click on apply to create the configured user  

### PostgreSQL

#### PostgreSQL Scripts

In PostgreSQL a role such as `igrc` or `activiti` can connect to the database.  
Implicitly the role has the right to create all objects in his own schema (view, tables, indexes, ...). The role is not a superuser and as a result has no administrative rights. The user cannot create databases and roles, he cannot modify the system catalog.  

The following script allows you to create the ledger and workflow database.  
Before using the script please remember to change the necessary information such as:  

- The name of the user
- The path to the tablespace  
- The passwords

```sql  
-- ---------------------------------------------------------------------
-- Copyright Radiant Logic 2017
-- Date: 04/2017
-- SAMPLE not to be used as is

-- Execute this script inside psql session as following:
-- psql -U postgres -f <ABSOLUTE PATH TO FILE>\PostgresCreatedatabaseigrc.sql
-- ---------------------------------------------------------------------

-- Create user and password
CREATE USER igrc WITH PASSWORD 'igrc';

-- Create a dedicated tablespace
-- WARNING: The directory specified must be an existing, empty directory owned by the PostgreSQL operating system user)
CREATE TABLESPACE igrc OWNER igrc LOCATION '/data/Base_igrc';

-- Create Database in specifying the owner and the tablespace
CREATE DATABASE igrc WITH OWNER = igrc TABLESPACE igrc;

-- Connect to igrc database to create the schema
\c igrc

-- Create Schema
CREATE SCHEMA IF NOT EXISTS igrc AUTHORIZATION igrc;

-- Option BW : Activiti (Workflow)

CREATE USER activiti WITH PASSWORD 'activiti';
CREATE SCHEMA IF NOT EXISTS activiti AUTHORIZATION activiti;
```

#### PostgreSQL GUI

> These are **not recommended** settings for PRODUCTION environments, but rather **sample** configurations for DEVELOPMENT

Launch `pgAdmin` and connect to your **PostgreSQL Server** instance.  

1. Create a new user for the **Ledger** tables in the database
   1. Right click on `Login/Group Roles`, select `Create` > `Login/Group Role...`
    ![PostgreSQL create user](./images/pg_create_user.png "Create new PostgreSQL User")
   2. In the `General` tab, choose the `Name` of the user (for example *sample_user_ledger*)
    ![PostgreSQL set user name](./images/pg_username.png "Set the ledger account user name")
   3. In the `Definition` tab, set a `Password` for the user
    ![PostgreSQL set user password](./images/pg_user_password.png "Set the account password")
   4. In the `Privileges` tab, check the `Can login?` option
    ![PostgreSQL allow user login](./images/pg_admin_allow_login.png "Allow user to login")
   5. Close the Dialog by clicking `Save`
2. Create a new user for the **Workflow** tables in the database (aka *activiti*)
   1. Right click on the `Login/Group Roles`, select `Create` > `Login/Group Role...`
    ![PostgreSQL create user](./images/pg_create_user.png "Create new PostgreSQL User")
   2. In the `General` tab, choose the `Name` of the user (for example *sample_user_workflow*)
    ![PostgreSQL set user name](./images/pg_username_workflow.png "Set the workflow account user name")
   3. In the `Definition` tab, set a `Password` for the user
    ![PostgreSQL set user password](./images/pg_user_password.png "Set the account password")
   4. In the `Privileges` tab, check the `Can login?` option
    ![PostgreSQL allow user login](./images/pg_admin_allow_login.png "Allow user to login")
   5. Close the Dialog by clicking `Save`
3. Create a new database
   1. Right click on `Databases`, select `Create` > `Database...`
    ![PostgreSQL create database](./images/pg_create_database.png "Create PostgreSQL database")
   2. Set the database name (for example *igrc_sample_db*)
    ![PostgreSQL set database name](./images/pg_db_name.png "Set the PostgreSQL database name")
   3. Not mandatory, but it is recommended to change the default database owner from `postgres` to another user. You can keep it as is, or set to the **ledger user** for instance (*sample_user_ledger*)
   4. Close the Dialog by clicking `Save`
4. Create a new **Ledger** schema
   1. Navigate to the `Schemas` of the new database (*igrc_sample_db*)
   2. Right click the `Schemas`, then select `Create` > `Schema...`
    ![PostgreSQL new schema](./images/pg_new_schema.png "Create a new PostgreSQL Schema")
   3. Set the Ledger **schema name** (default is `igrc`), and select the **ledger user** (*sample_user_ledger*) as the `Owner`
    ![PostgreSQL choose schema name and owner](./images/pg_schema_owner.png "Set PostgreSQL schema name and owner")
5. Create a new **Workflow** schema
   1. Navigate to the `Schemas` of the new database (*igrc_sample_db*)
   2. Right click the `Schemas`, then select `Create` > `Schema...`
    ![PostgreSQL new schema](./images/pg_new_schema.png "Create a new PostgreSQL Schema")
   3. Set the Ledger **schema name** (default is `activiti`), and select the **workflow user** (*sample_user_workflow*) as the `Owner`
    ![PostgreSQL choose schema name and owner](./images/pg_schema_owner_activiti.png "Set PostgreSQL schema name and owner")
   4. Close the Dialog by clicking `Save` 
6. Set the `search_path` for the **ledger user**
   1. Right click on the **ledger user** (*sample_user_ledger*), select `Properties`
    ![PostgreSQL user properties](./images/pg_edit_ledger_user.png "Edit the ledger user properties")
   2. In the `Parameters` tab, click on `+` to add a parameter
   3. Select the `search_path` parameter, set the **ledger schema** as the value (*igrc*), and select the new database (*igrc_sample_db*)
    ![PostgreSQL set ledger search path](./images/pg_search_path_ledger.png "Set search path parameter for the ledger user")
   4. Close the Dialog by clicking `Save`
7. Set the `search_path` for the **workflow user**
   1. Right click on the **workflow user** (*sample_user_workflow*), select `Properties`
    ![PostgreSQL user properties](./images/pg_edit_workflow_user.png "Edit the workflow user properties")
   2. In the `Parameters` tab, click on `+` to add a parameter
   3. Select the `search_path` parameter, set the **workflow schema** as the value (*activiti*), and select the new database (*igrc_sample_db*)
    ![PostgreSQL set workflow search path](./images/pg_search_path_workflow.png "Set search path parameter for the workflow user")
   4. Close the Dialog by clicking `Save`
