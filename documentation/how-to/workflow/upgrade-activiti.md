---
title: How-To upgrade your activiti database
description: How-To upgrade your activiti database
---

# How-To upgrade your activiti database

As of version 2016 R2 SP12 of the product, the version of the activiti engine has been updated to version 5.21. As a result when upgrading from a previous version of the product with active workflows it is necessary to upgrade the version of your activiti schema.  

## Prerequisites

- It is important that before performing any operations on your database instance you should have a working backup available.
- To be able to run the creation and the upgrade scripts the user must have the permission to alter the database.
- All instances of the portal must have been shutdown before performing the upgrade.

> The following operations are only required when and workflow database is declared in the technical configuration of the project.

## Dependencies

This requires the use of a declared Activiti database in the technical configuration.  

## Procedure  

It is **highly** recommended to upgrade the schema of your activiti database using the sql scripts provided in the `activiti_upgrade` folder of the upgrade archive. The scripts are also attached to this page.  

In this folder there are two versions of activiti available to upgrade from. Use only the scripts corresponding to the current version of your schema used (either 5.14 or 5.16).  

Execute the following sql query in your database management platform to determine the version of activiti used : 

```sql
SELECT NAME_, VALUE_ FROM ACT_GE_PROPERTY WHERE NAME_ = 'schema.version' ;  
```

The upgrade and creation scripts are provided for all three supported databases :  

- Microsoft SQL server
- Oracle
- PostgreSQL

> [!warning] If you are using **Microsoft SQL server** it is important to execute the upgrade script with a user that has the **ALTER DATABASE permission** or the execution of the final query will result in an exception:

```sql
declare @databasename varchar(256);
SELECT @databasename = DB_NAME();
exec('ALTER DATABASE ['+@databasename+'] SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE');
```
