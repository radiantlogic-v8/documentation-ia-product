---
title: "Schema 35 upgrade procedure"
description: "Schema 35 upgrade procedure"
---

# Schema 35 upgrade procedure

With the release of the version Curie, the schema of the database is updated to modify all recorduid column types in the database.

This represents a significant change in the database schema and can time consuming depending of the volume of data present in the database.

In order to ensure that the migration of the database schema is performed correctly the "automatic" upgrade via the studio has been removed .

> [!warning] The database schema migration can ONLY be performed manually!

The included sub-pages will provide the user with the procedure to execute in order to migrate the database to the version 35 (Curie R1) of the schema.

## Pre-requisites

### Recommendations

Before attempting the migration of the database it is recommended to:

- Turn off **all** services that connect to the database. This includes:
  - Closing all opened Studios
  - Shutdown the webportal
  - If relevant, deactivate all scheduled tasks (batch commands)
- Backup up the current database, including both the ledger and the activiti (workflow) schema
- The restore procedure of the database has been tested and validated

## Additional information

If you are migrating from a version of the product prior to **Curie R1** (2017, Ader or Braille) to a version including and after **Curie R2** the database migration must be performed in 2 steps:

1. Upgrade to the version 35 of the schema.
2. Upgrade from the version 35 of the schema to the current version. This can be done using the normal methods, directly in the studio or using the upgrade SQL script. It is however recommended to upgrade using the SQL scripts for production environments.

For example if migrating from a **Braille R1** to a **Curie R2** it is necessary to:

1. Upgrade from **Braille R1** to **Curie R1** using the corresponding scripts
2. Upgrade as usual from **Curie R1** to **Curie R2**

## Scripts

The upgrade scripts are provided for all supported databases:

- [**SQL server**](./01-sqlserver/index.md)
- [**PostgreSQL**](./02-postgresql.md)
- [**Oracle**](./03-oracle.md)

## Warning

The schema migration implies a modification of the type of all recorduid in the database. This operation is time consuming.

Internal tests have shown that the migration of the schema can take along the lines of 4 Mo/s.

As a result a migration of a 100 Gb database can take about 7h. This operation is disk space consuming. Internal tests on PostgreSQL have shown that during the migration the occupied disk space can be multiplied by 5. A vacuum full operation is necessary at the end of the migration to retrieve the storage.
