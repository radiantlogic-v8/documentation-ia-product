---
title: Release Notes
description: Descartes R5 Release Notes
---

# Release Notes Descartes R5

## Version Descartes R5 SP4

### Security fix

- **IGRC-4836:** Remove common-compress library located in native xlsx emitter (security fix)

## Version Descartes R5 SP3

### New Features

- **IGRC-4834:** Allow custom AD repository types in AD accounts activation
- **BWIPUAR-2205:** pass current timeslot to workflow

### Bug fixes

- **IGRC-4831:** Metadata created on a past timeslot are not written correctly in database

## Version Descartes R5 SP2

### Bug fixes

- **IGRC-4827:** indirect manager links are copied from previous timeslot
- **IGRC-4828:** Reuse the same global classloader upon several Business View executions
- **COL-1641:** Leave date of leaver account updated if left identity does not have departure date

## Version Descartes R5 SP1

### New Features

- **COL-1590:** Log memory/GC infos in batch
- **COL-1610:** Log batch options used

### Bug fixes

- **IGRC-4780:** Impossible to get the grace period date in notification
- **IGRC-4814:** Missing translation key `deleteImportTheoricalAccRights`
- **IGRC-4817:** TypedQuery error in the exception tab of controls in the studio
- **IGRC-4825:** IAM theoretical rights can crash with duplicates
- **COL-1527:** Studio freeze when merging review wizard generate files
- **COL-1591:** Ticket review update slow when updating
- **COL-1606:** Workflow - Parameter mapping in NotifyRule show Undefined for the mapped value
- **COL-1625:** A new classloader is created for each script executed, inducing a memory leak
- **COL-1631:** TaskComplete wait-end latency
- **COL-1639:** IAM right target error during collecting phase

## Version Descartes R5

### Bug fixes

- This is a security fix with an upgrade of the whole Eclipse platform
