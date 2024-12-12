---
title: "PostgreSQL configuration recommendations"
description: "PostgreSQL configuration recommendations"
---

# PostgreSQL configuration recommendations

The recommendation provided in the following document were performed in a integration environment using volume of data representative of a production environment. These are the result of several data loading phases including testing, and tuning.

The overall data loading phase as well the end user usage in the webportal (restitution phase) has been found to be optimal by respecting the following recommendations or best practices.

However, it will be up to the PostgreSQL DBA to adapt parameters according to the hardware and software environment on which runs the PostgreSQL engine as well as the physical location of data files, transaction logs. It is also recommended to adapt the configuration to production constraints. For example: Archive mode, resource sharing and naming rules among others.

## Software environment

Please refer to the following documentation for the supported versions of Postgres:  

- [Supported Versions of PostgreSQL](../../igrc-platform/installation-and-deployment/04-brainwave-grc-certified-environments.md)

## Hardware environment

### RAM

A minimum of **8Gb** is required. It is recommended to allocate between **16Gb** and **32Gb** (dynamic allocation is possible on a virtual machine) as a function of the number of identities, accounts, permissions... that have an impact on the final storage space of the database as well as the number of simultaneous connections expected. As a reminder, each client process has its own private memory area (`work_mem`).

### Hard Drive

Your choice of hard drive will determine the performance of your database. Prefer fast disks as SAS 15K RPM, or SSD disks for example (with backup battery) for storing the WAL and statistics. This part is crucial so please consult your storage experts for a better expertise.

### CPU

The number of cores will help with parallel processing and determine the number of parallel client connections possible. The frequency is less important than the number of cores.

> PostgreSQL is a multi-process system. Each client connection is managed by a separate process, responsible for executing the request and returning the data to the client. As of PostgreSQL 9.6, a process executing a request can request the help of other processes (workers) to process this request (In 9.6 this is limited to the execution of read-only requests and not enabled by default). PostgreSQL 10 and above proposes the parallelization of new operations (although always in reading) as in the index path (index scan and index only scan), Merge Joints, the collection of results while preserving the sort order (gather Merge).

This is a configuration example that can be used in most cases for Linux:  

- Processor: Intel(R) Xeon(R) CPU E5-2660 v4 @ 2.00GHz (Number of cores / Threads: 14 / 28)
- Memory: 16 Gb
- Network Ethernet: 1Gb
- Hard Drive: SAS 15K RPM + SSD

## PostgreSQL environment

### Disk Volume

The allocated disk volume will depend on the number of objects present in the database (identities, accounts, groups, permissions, applications, metadatas, ...), the type of control implemented, the data loading frequency, as well as the retention period of the different timeslots.

Radiant Logic recommends the use of **10 Gb per Time Slot** for the first two or three loads. And to refine according to the project and the average disk space used by timeslot in a second time.

With a retention period of 12 months and a loading frequency every two weeks, the required space would be around 240 Gb at the end of a year.

> There is relatively little variation from one Time Slot to another one considering a constant data and functional scope, except during the project configuration phase. However, be aware that the final storage used for a timeslot is not representative of the maximum storage space used during the data loading phase.
>
> As a rule of thumb, if the end storage of a timeslot is 10 then the maximum storage space reached is up to 30

### Files distribution

It is recommended to Split transaction logs (the content of `pg_xlog` (Version 9.6) and `pg_wal` (Version 10 or >) directories), data files and statistics files (`pg_stat_dump`) on different disks.

### PostgreSQL Engine and system parameters

#### System

Swap configuration: **2 Gb** (use `swapon --s` command to check the current configuration)

It may be interesting to change the parameter controlling the swap capacity at the system level.

The swap capacity of a system is a primary factor that determines the overall functionality and speed performance of an OS.

There are some maths involved in the swap capacity that should be considered when changing your settings. If the parameter value is set to "60" your kernel will swap when the RAM reaches 40% capacity. Setting it to "100" means that your kernel will try to swap everything. Setting it to 10 means that swap will be used when RAM is 90% full, so if you have enough RAM memory, this could be a safe option that would easily improve the performance of your system.

To check the current value use the command: `sysctl -a \| grep swap` (or `cat /proc/sys/vm/swappiness`)

You can make the change permanent by navigating to `/etc/sysctl.conf` which is a text configuration file. You may open this as root (administrator) and add the following line on the bottom to determine the swappiness: `vm.swappiness="your desire value here"`. For example:

- `vm.swappiness=10`

Type of file system: **ext4**

#### PostgreSQL engine  

Setting parameters via the configuration file `postgresql.conf`.

- `Shared_buffers` : Determines how much memory is dedicated to PostgreSQL to use for caching data.
  - Recommended value : **25% of physical/virtual memory** allocated to the machine (With a max value to **8Gb**)

- `Max_connections` : Maximum number of client connections allowed.
  - Recommended value: **In line with your project** (Default value : 100)

- `Work_mem` : Determines how much memory can be used during certain operations. (Internal sort operations and hash tables)
  - Recommended value:  **Between 10 and 50 Mb** (it generally corresponds to the size of the available memory divided by the number of connections expected in parallel).

- `Maintenance_work_mem` : By process, but for maintenance tasks as: vacuum, index creation, ...
  - Recommended value: **1Gb**

- `Checkpoint_timeout` : Checkpoint is started every `checkpoint_timeout`.
  - Recommended value: **5 minutes**

- `Max_wal_size:` : PostgreSQL will trigger a Checkpoint every 5 minutes, or after the WAL grows to about 1GB on disks.
  - Recommended value: **1 to 2 Gb**

- `Checkpoint_completion_target` : Parameter that makes PostgreSQL try to write the data slower. To finish in `Checkpoint_completion_target` x `Checkpoint_timeout`. To make I/O load lower.
  - Recommended value: **0.9**

- `Default_statistics_target` : Accuracy of statistics
  - Recommended value: **100**

- `Autovacuum_vacuum_scale_factor` : Tables are auto-vacuumed by default when 20% of the rows plus 50 rows are inserted, updated, or deleted
  - Recommended value: **0.2**

- `Max_parallel_workers_per_gather` : Sets the maximum number of workers that can be started by a single Gather (or operation) Can be increased to half of the max_worker_processes.
Do not go further (It will be inefficient) The number of workers started depends of the size of the table/index
  - Recommended value:  **2 or 3 for 8 CPUs**

- `Min_parallel_table_scan_size` : Sets the minimum amount of table data that must be scanned in order for a parallel scan to be considered.
  - Recommended value: **10MB**

- `Min_parallel_index_scan_size` : Sets the minimum amount of index data that must be scanned in order for a parallel scan to be considered.
  - Recommended value: **1MB**

- `Max_parallel_maintenance_workers` : **Only available in PosgreSQL 11 and above** Currently, the only parallel utility command that supports the use of parallel workers is CREATE INDEX, and only when building a B-tree index, and VACUUM without FULL option.
  - Default value: **2**

- `temp_buffers` : Sets the maximum amount of memory used for temporary buffers wihtin each database session.
  - Recommended value: **64 MB**

- `random_page_cost` : Sets the planner's estimate of the cost of a non-sequentially-fetched  disk page. Reducing this value relative to seq_page_cost will cause the system to prefer index scans.
  - Recommended value: **2** (Default value = 4)

  In using SSD disks, this cost can be set to **1.1** (or 1.2)

- `track_activity_query_size` : Specifies tha amount of memory reserved (as bytes) to store the text of the current executing command for each active session, for the pg_stat_activity query field.  
  - Recommended value:  **16384**

> The first 4 parameters all concern the amount of memory that postgreSQL will use for its different operations.

The list of parameters here is not exhaustive and only concerns parameters that have been modified from the default values or those relating to parallelism.

Example: Let's suppose that the machine has 8Gb of physical memory, we allocate 2Gb to `Shared_buffers`, 1Gb to `Maintenance_work_mem` and "10Mb*100 connections" or 1Gb to the `work_mem`. This leaves 4Gb to the system.

To sum up:

| Parameter                          | Recommended value              | Comment                                               |
| ---------------------------------- | ------------------------------ | ----------------------------------------------------- |
| `Shared_buffers`                   | 25% of physical/virtual memory | Set **4GB** for **16GB** configured                   |
| `Max_connections`                  | In line with your project      | Else keep the default value to                        |
| `work_mem`                         | Between 10 and 50 Mb           |                                                       |
| `Maintenance_work_mem`             | 1GB                            |                                                       |
| `Checkpoint_timeout`               | 5min                           |                                                       |
| `Max_wal_size`                     | 1GB to 2GB                     |                                                       |
| `Checkpoint_completion_target`     | 0,9                            |                                                       |
| `Default_statistics_target`        | 100                            |                                                       |
| `Autovacuum_vacuum_scale_factor`   | 0.2                            |                                                       |
| `Max_parallel_workers_per_gather`  | 2 or 3                         | Can be increased to half of the max_worker_processes. |
| `Min_parallel_table_scan_size`     | 10MB                           |                                                       |
| `Min_parallel_index_scan_size`     | 1MB                            |                                                       |
| `Max_parallel_maintenance_workers` | 2                              | Default value                                         |
| `temp_buffers`                     | 64MB                           |                                                       |
| `random_page_cost`                 | 2                              | Can be set to 1.1 on SSD disks                        |
| `track_activity_query_size`        | 16384                          |                                                       |

### Character Set

Use the UTF-8 character set encoding.

### User/schema/tablespace

Before initializing the database from the iGRC studio, it's necessary to have created a user dedicated to the Identity Analytics solution.

We also recommend the creation of a dedicated "tablespace" and "schema" for this user.

The following script can be used to do so:  

```sql  
-- Execute this script inside psql session as following:
-- psql -U postgres -f <ABSOLUTE PATH TO FILE>/PostgresCreatedatabaseigrc.sql

-- Create user and password
CREATE USER igrc WITH PASSWORD '<TO BE CHANGED>';

-- Create a dedicated tablespace (not mandatory. Just a recommandation)
-- WARNING: The directory specified must be an existing, empty directory owned by the PostgreSQL operating system user)
CREATE TABLESPACE igrc OWNER igrc LOCATION '/Base_igrc';

-- Create Database in specifying the owner and the tablespace
CREATE DATABASE igrc WITH OWNER = igrc TABLESPACE igrc;

-- Connect to igrc database to create the schema
\c igrc

-- Create Schema
CREATE SCHEMA IF NOT EXISTS igrc AUTHORIZATION igrc;
ALTER USER igrc SET SEARCH_PATH='igrc';

-- OPTIONS
-- Uncomment the relevant lines to enable

-- Option 1: Add the following extension to track statistics of all SQL statements
-- For Performance and Tunning use
-- CREATE EXTENSION pg_stat_statements;

-- Option 2: Add extensions to collect statistics about predicates and help find missing indexes
-- For Performance and Tunning use
-- CREATE EXTENSION pg_qualstats;
-- CREATE EXTENSION pg_stat_kcache;

-- Option BW: Activiti (Workflow)
-- CREATE USER activiti WITH PASSWORD '<TO BE CHANGED>';
-- CREATE SCHEMA IF NOT EXISTS activiti AUTHORIZATION activiti;
-- ALTER USER activiti SET SEARCH_PATH='activiti';

-- It's possible to copy/past all commands in PgAdmin console but in this case, it's important to connect to the database igrc before creating the schema.
-- Or else this last one will be created under public schema and under Postgres user.

```

### Archive mode

This part is to be defined more precisely with a PostgreSQL DBA, as it conditions the Recovery policy.

Transaction logs (directory named `pg_xlog` in Release 9.6 and `pg_wal` in Release 10.1 or >) are used to reconstruct all changes made to the database. They are essential for the restoration process.

### Backup and maintenance plan of indexes/statistics

Radiant Logic recommends a regular FULL backup of the database after each loading (`pg_dump`).

In addition, an index maintenance and disk space recovery plan (Vacuum Full) must be integrated into the overall database maintenance process.

Performance may be strongly impacted by index fragmentation.

The procedure for rebuilding indexes that can be applied is detailed here:
https://www.postgresql.org/docs/13/app-reindexdb.html

Note that statistics are kept up to date during the Identity Analytics execution plan (at each loading).

It is also recommended, after loading, to recalculate the indexes in order to optimize the next execution plan.

> [!warning] During a "vacuum full" command, an exclusive lock is set on the table. As such, on very large tables, this mechanism can be problematic if the database is always open for consulting.

An alternative solution is to use the extension `pg_squeeze` that allow to rebuild without lock tables or indexes during this operation.
https://www.cybertec-postgresql.com/en/products/pg_squeeze/
