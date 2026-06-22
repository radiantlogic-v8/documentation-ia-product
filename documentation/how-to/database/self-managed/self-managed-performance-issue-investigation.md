# Database Check Use Guide

## Table of Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Procedure](#procedure)
- [Expected result](#expected-result)

## Introduction

This document explains how to execute the Identity Analytics (IDA) PostgreSQL Database Check script against an existing self-managed IDA environment. It assumes that the IDA application and its backing PostgreSQL database are already running and reachable from your workstation or a database pod.

## Prerequisites

Before starting, ensure that the following prerequisites are met:

- A running Kubernetes cluster with Identity Analytics deployed.
- Access to the namespace where the IDA components are installed. In this guide, the recommended namespace is `ida`.
- `kubectl` is installed on the workstation.
- A valid `kubeconfig` file and sufficient permissions to access the cluster and run `kubectl exec` against the PostgreSQL pod.
- Access to the latest version of the PostgreSQL DB Check script. In this example, the script used is `DBCheck_PostgreSQL_v10.sql`.
  - For the latest DBCheck files, check [here](../postgresql/psql-performance-issue-investigation.md#downloads)
- Permission to retrieve Kubernetes secrets and execute commands in the PostgreSQL pod.
- A local folder on the workstation where the script and the output file can be stored.
- The PostgreSQL version used by `shared-db-1` must be compatible with the DB Check script version being executed. For `DBCheck_PostgreSQL_v10.sql`, PostgreSQL 9.6 or later is required.
  - The minimum supported PostgreSQL version for a given script can be verified in the header comments at the beginning of the script file.
  - The procedure described in this guide has been tested with PostgreSQL 18.1.

## Procedure

The DB Check script must be executed against the PostgreSQL database used by the IDA environment. The default database is `analytics_db`, hosted on the `shared-db-1` PostgreSQL cluster.

![IDA Cluster Screenshot](<images/IDA Cluster Screenshot.png>)

To start, retrieve and copy the `DBCheck_PostgreSQL_v10.sql` file to a local folder on the workstation and ensure that the file is accessible from the user account that will execute the command.

On Linux-based systems, permissions can be adjusted, if necessary, with:

```bash
chmod -R 777 <folder>
```

The database credentials are stored in a Kubernetes secret. For IDA, this is the `postgres-credentials` secret. You can check the list of secrets in your environment with:

```bash
kubectl get secrets -n ida
```

Retrieve the database username and password with the following commands:

```bash
kubectl get secret -n ida postgres-credentials \
  -o jsonpath='{.data.username}' | base64 -d && echo
kubectl get secret -n ida postgres-credentials \
  -o jsonpath='{.data.password}' | base64 -d && echo
```

![Secret Result](<images/Secret Result.png>)

Run the script by piping it from the workstation into the PostgreSQL process running inside the `shared-db-1` pod.

```bash
kubectl exec -i -n ida shared-db-1 -c postgres -- \
  env PGPASSWORD=<YOURPASSWORD> \
  psql -h localhost -p 5432 -d analytics_db -U postgres \
  > <PATHTORESULT> \
  < <PATHTOSCRIPT>
```

Replace the following values before running the command:

- `<YOURPASSWORD>` with the password retrieved from the `postgres-credentials` secret.
- `<PATHTORESULT>` with the full path to the output file to be generated.
- `<PATHTOSCRIPT>` with the full path to the `DBCheck_PostgreSQL_v10.sql` script on the workstation.

For example:

```bash
kubectl exec -i -n ida shared-db-1 -c postgres -- \
  env PGPASSWORD='T...f' \
  psql -h localhost -p 5432 -d analytics_db -U postgres \
  > /mnt/c/SQL2022/DBCheck/results_db_check.txt \
  < /mnt/c/SQL2022/DBCheck/DBCheck_PostgreSQL_v10.sql
```

## Expected result

After the command completes, the script output is written to the specified results file. This file can then be reviewed locally or shared with the Radiant Logic support team for analysis.
