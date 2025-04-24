---
title: Release Notes
description: Descartes R3 Release Notes
---

# Release Notes Descartes R3

## Version Descartes R3

> [!warning] This version requires Java 17 (IGRC-4741 Upgrade platform to Eclipse 2023-09)

### New Features

- **COL-1538:** Add perimeter as a main entity in view
- **IGRC-3104:** allow multivalued parameters in workflow, provisioning, businessview and portal javascript API (executeView, esxceuteProcess, writeMetadata, countView)
- **IGRC-4334:** Be able to set the priority of an e-mail (notify rule)
- **IGRC-4479:** Rules: Add a join from rights to accounts (direct) not through group
- **IGRC-4486:** In the execution plan logs, add number of timeslots already in the DB
- **IGRC-4516:** Add email attribute to accounts in smartSearch
- **IGRC-4557:** In the CSV source component add the possibility to select the "UTF-8 BOM" as the file encoding
- **IGRC-4621:** Ability to use regexp in rules, views and smartsearch
- **IGRC-4760:** Javascript allow to parse ISO date format
- **IGRC-4761:** Include the purge activiti and tickets in the purge mechanism
- **IGRC-4768:** Cleans activiti tables from already deleted timeslots
- **IGRC-4784:** Add notion of CI manager
- **IGRC-4792:** Be able to prevent log file deletion on batch exit
- **IGRC-4794:** Add an option in `igrc_sqlscript` to create all migration scripts in separate files

### Bug fixes

- **IGRC-3823:** Retry purge when there is an error
- **IGRC-4423:** Clear password in the logs if password is used in an update variable
- **IGRC-4453:** In the studio, stats updates to improve performance are not performed on portal tables.
- **IGRC-4518:** An index is missing on the table `tmetadatavalue` on the column `ctimeslotfk`
- **IGRC-4540:** Deprecated criteria in rule editor
- **IGRC-4631:** Ambiguous label in business view filters
- **IGRC-4642:** Empty type 5 control are executed and returns all identities
- **IGRC-4676:** The current handling of the information in `tconfiggrids` can results in SQL insert errors
- **IGRC-4759:** No longer insert in the DB when when using an importfile with uncollected entity
- **IGRC-4763:** Event is now created when a group doesn't exist
- **IGRC-4767:** Update delegation tables at the end of timeslot validation
- **IGRC-4783:** Links between CIs are not unfolded if predefined CI families are not respected
- **IGRC-4785:** Add any missing links related to CI in rules and views
- **IGRC-4787:** Create new table to collect theoretical rights in import table
- **IGRC-4789:** Fix Business view with prefix returns wrong result
- **IGRC-4795:** Add missing labels in smartsearch
- **IGRC-4800:** Under Oracle, in the portal, modifying, adding or deleting a manager (on any entity) does not work and causes an error in the log.
- **IGRC-4801:** Under Oracle the index update action takes an unjustified amount of time.
- **IGRC-4805:** Remove workflow publication when launching a purge process
- **COL-1278:** Typo correction
- **COL-1292:** Misleading phrasing of the sample batch result values in technical conf
- **COL-1402:** Harmonize validation logs
- **COL-1515:** Generating self permission links can fail if self permission link already loaded during collect
- **COL-1538:** add join between perimeter and raw permission link and metadata
- **COL-1539:** Improvements for group and permission children targets
- **COL-1542:** Set the prefix on the name when doing a join
- **COL-1545:** Metadata and perimeter links missing in views
- **COL-1547:** Remove attribute when operator is 'looks like' and 'not looks like'
- **COL-1552:** Computed manager hierarchy working without `-Duseportalinexecplan=true`
- **COL-1566:** Optimization of no owner accounts recon
