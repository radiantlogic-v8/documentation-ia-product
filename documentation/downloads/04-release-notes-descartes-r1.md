---
title: Release Notes
description: Descartes R1 Release Notes
---

# Release Notes Descates R1

## Version Descartes R1 SP2

### Bug fixes

- **IGRC-4680:** Improve query caching in the collect step

## Version Descartes R1 SP1

### Bug fixes

- **IGRC-1723:** SQL filtering in a view generates an error if some filter attributes are not in the select
- **IGRC-4658:** When finalizing 2 IAP reviews at the same time only 1 is finalized
- **IGRC-4660:** There is a problem of displaying the results of controls in the studio (History tab)
- **IGRC-4661:** A workflow process can be stuck when a manual task is completed or expires when reminders are configured
- **IGRC-4662:** Some IAP controls based on metadata KPI/counters could give wrong results
- **IGRC-4663:** Individual copy of metadata fails due to parameter numbering
- **IGRC-4665:** If column order is not the same between history and portal tables, the copy to portal fails in batch mode (batchinsert=true)
- **IGRC-4666:** License not correctly displayed in French

## Version Descartes R1

### New Features

The platform and all used components (open source libraries) have been migrated to their latest versions.
This has allowed the elimination of residual vulnerabilities compared to Curie R3.

IMPORTANT: This major release does not require any upgrade of the database!
Performing a clean/new install (in a new directory) and republish the war is still necessary!

A connection pool is now used for the batch.

**IGRC-4633:** Default behaviour in Descartes is to optimize transaction log and IAP counters

### Bug fixes

- All bug fixes in this version are common with Curie R3 SP3.
- **IGRC-4647:** In some situations the validation of a file fails when there is a wildcard in the path
- **IGRC-4648:** Review fails on init when insert null in cactorfk and caccountablefk
- **IGRC-4650:** Handling of ticketreview update component and purged timeslot
- **IGRC-4651:** Optimization of controldiscrepancies copy in portal table
