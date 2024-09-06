---
title: "Oracle configuration recommendations"
description: "Oracle configuration recommendations"
---

# Oracle configuration recommendations

> [!warning] Oracle is supported by Brainwave only for existing clients and projects. In the case of a new project the Oracle database management system is not supported.  

The following recommendations are based on a usage of the iGRC product in an integration environment using the volume of data equivalent to a production environment.  

The recommendations have been elaborated by performing multiple data loads, test following several months of integration testing a tuning.  

The global usage of the product and data-loading performances were optimal when following the following recommendations and prerequisites. However it is of the responsibility of the Oracle DBA to adapt certain parameters of the oracle instance depending of the used technical architecture. It is also necessary to adapt certain constraints (Recovery mode), instance sharing, resource naming,... to adapt to the customers best practices.  

## Recommendations

### Software

The certified environment matrix is available on the Brainwave GRC documentation site [here](../../igrc-platform/installation-and-deployment/04-brainwave-grc-certified-environments)

It is recommended that the Oracle environment be entirely dedicated to The solution Brainwave iGRC.  

The supported OS are:  

|                            OS                             |
|:---------------------------------------------------------:|
| AIX 7.1/7.2 (64Bits) physical or Logical Partition (LPAR) |
|      Windows 2008 R2 Enterprise / Standard Editions       |
|      Windows 2012 R2 Enterprise / Standard Editions       |
|            Linux CentOS Release 7.2 (64 Bits)             |

### Supported hardware

- A minimum of 8Go of Ram is required. It is recommended to allocate 16 to 32Go of RAM as a function of the number of resources/objects that are loaded into the database impacting data volume.
- A minimum of 4 CPU should be allocated

The standard configuration for Unix using AIX:  

- Partition « uncapped » AIX 7.1/7.2 (64bits)
- SMT activated
- 4 CPUs (3,1 Ghz)
- 32 Gb memory
- SWAP space 16Gb
- (Entitlement : 2 CPU, Max : 8 CPUs, Min : 1 CPU). Equivalent 16 logical CPU

The standard configuration for windows and/or linux systems:  

- Processor: Intel(R) Xeon(R) CPU E5-2660 v4 @ 2.00GHz
- Memory: 16 Gb
- Réseau Ethernet: 1Gb

### Oracle Environnement

#### Disk Storage

The required storage space of the database is dependent of the number of objects (identities, accounts, groups, permissions, applications ...), of the frequency of data ingestion and of the retention period of the different timeslots.  

From experience Brainwave recommends to plan for 10Go per timeslot, not including the storage space of the UNDO and TEMP tablespaces.  

Considering a retention period of 12 months and a frequency of data loads every 2 weeks the final storage space would be of the order 240Go in a year.  

#### Instance Parameters

Upon creation of the dedicated for the solution, the following parameters are recommended.  

| Parameter           | Value           |
|:--------------------|:----------------|
| `SGA`               | **6 Gb - 8 Gb** |
| `Character_set`     | AL32UTF8        |
| `Nls_Character_ser` | AL16UTF16       |

The default parameters are used except for the the following parameters:

| Parameter                  | Value      |
|:---------------------------|:-----------|
| `db_writer_processes`      | 4 or 8 max |
| `pga_aggregate_target`     | 1.5 Gb     |
| `optimizer_index_cost_adj` | 15         |
| `optimizer_index_caching`  | 90         |

#### TEMP Tablespace

Used during the re-indexation, sorts if `in-memory` sorting is not available. The recommended storage space is 3Go.  

The following SQL command can be adapted to create said tablespace:  

```sql  
create temporary tablespace IGRC_TEMP tempfile
'&TEMPDIR/igrc_temp_01.dbf' SIZE 3G extent management local uniform size
10M ;
```

Please note the the storage space of the database can depend on the maintenance plan of the database. A REBUILD of the indexes requires on average 2 times the indexes occupied space.  

#### UNDO Tablespace

All undo operations are stored in this tablespace  dedicated to rollback operations (Cancellation of updates, inserts and deletes). This tablespace can rapidly increase when loading large amounts of data during the execution plan.

The recommended sizing is as followed:

- Undo_management AUTO
- Undo_retention 900 (seconds)
- Tablespace storage space: 10 Go

#### iGRC Schema

It is recommended to create a dedicated tablespace for the iGRC schema as well as a temporary tablespace for sorting operation (other than the default TEMP).  

The following script provides an example on how to create said table space along with the minimal rights to allocate:

```sql
create tablespace IGRC_DATA
  datafile \'&DATA_DIR/IGRC_DATA01.dbf\' SIZE 10G reuse
  extent management local autoallocate
  segment space management auto online;

create user \<USERNAME\> identified by &DATABASE_PASSWORD
  default tablespace IGRC_DATA
  temporary tablespace IGRC_TEMP;

grant connect, resource, create session, alter session, create table,

create sequence, create trigger, create view to \<USERNAME\>;

grant unlimited tablespace to \<USERNAME\>;
```

#### Activiti Schema

This can be a dedicated instance or a distinct schema (activiti) within the same instance as the one created for the ledger. It is recommended to create a dedicated Activiti schema.
The temporary tablespace used for the igrc schema can be re-used:  

```sql
create tablespace IGRC_ACTIVITI
  datafile \'&DATA_DIR/ACTIVITI_DATA01.dbf\' SIZE 2G reuse
  extent management local autoallocate
  segment space management auto online;

create user activiti identified by &DATABASE_PASSWORD
  default tablespace IGRC_ACTIVTI
  temporary tablespace IGRC_TEMP;

grant connect, resource, create session, alter session, create table,

create sequence, create trigger, create view to activiti;

grant unlimited tablespace to activiti;
```

#### Datafiles

Depending on the physical disc configuration it is recommended to create multiple datafiles to spread the IOs over different volumes. Both for the TEMP and DATA datafiles. Ideally on a multidisc bay with multiple containers.  

It is recommended to place the oracle control files and the redo logs on fast discs different to those used for the storage of data. These files are frequently modified by the Oracle server and are essential to restore the database.  

#### Recovery mode

The following parameters are to be defined more precisely with an Oracle DBA as it conditions the recovery policy of the database. A redo log archiving must be created.  

These files are used to reconstruct the changes performed by the database. They are essential to the restoration processes. For better performance they should be positioned on fast discs.  

As an example and without archiving:  

- redo log file size: 50 Mb
- Number of redo logs: 3

#### Backup and maintenance plans

It is recommended to perform a FULL backup the database after each ingestion phase.

The statistic and index maintenance plan (drop and recreation of the indexes or a simple Rebuild) is to be included in the global maintenance of the database. The global performances of the database can be drastically impacted by the fragmentation of the indexes.  

## Annex

### Lab Configuration

#### Physical Serveur

- PowerEdge R430 for Intel v4 CPUs
- Processor: Intel(R) Xeon(R) CPU E5-2660 v4 @ 2.00GHz
- Discs:
  - 6 TB 7.2K RPM SATA 6Gbps (\- 2 DD)
  - 300GB 15K RPM SAS 12 Gbps (\*1)
  - PERC H330 RAID Controller
- Memory : 128 Gb
- Réseau Ethernet : 1Gb

Hyer-V Configuration:

- 1 VM hosting the database server
- 1 VM hosting the batch and the solution

#### Database server configuration

- Linux CentOS 7.2 (64bits)
- Oracle 12.1.0 Standard Edition
- 4 vCPU
- 4 Gb à 12 Gb dynamic

The data and log files are placed on different discs.

#### Batch configuration

- Windows Server 2012 R2
- 4 vCPUS
- 4 Gb à 12 Gb dynamic
