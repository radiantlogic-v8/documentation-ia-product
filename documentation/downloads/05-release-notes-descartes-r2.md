---
title: Release Notes
description: Descartes R2 Release Notes
---

# Release Notes Descrates R2

## Version Descartes R2 SP2

### Bug fixes

- **IGRC-4773:** [SaaS][Cobalt] Vulnerable Javascript Dependency `#PT21409_1`
- **IGRC-4776:** No stack trace in the log file when the reconciliation switches to legacy mode upon error

## Version Descartes R2 SP1

### New Features

- **IGRC-4483:** "attribute is not set" added in rules: Account and Identity
- **IGRC-4739:** Enable / disable menu items based on license and conf variables

### Bug fixes

- **IGRC-3834:** Avoid the locate in history of any entity during the collect
- **IGRC-4727:** Issue with metadata `bwf_repositorymetrics_nbappshare` in optimized mode
- **IGRC-4738:** change portal favicon to Radiant Logic (16x16 only)
- **IGRC-4740:** Server connection is cut when uploading a large file
- **IGRC-4742:** Removal of CVE-2023-44487
- **IGRC-4745:** The Business View sort options are ignored if the business view is embedded in another one
- **IGRC-4747:** fix rule editor labels and hide from smart search

## Version Descartes R2

### New Features

- **IGRC-4696:** Add a new metadata computation phase (before temporal criteria)
- **IGRC-4708:** Enable the capability to alter the truncation policy through properties within batch context

### Bug fixes

- **IGRC-4644:** reviewactor and reviewaccountable tables should be cleaned on activiti db reinitiliasation
- **IGRC-4646:** Issue when resolving conflicts in IAP migration
- **IGRC-4676:** The current handling of the information in tconfiggrids can results in SQL insert errors
- **IGRC-4678:** Portal crashes when we click on nb of entries left to review
- **IGRC-4679:** Adding Reviewer as managers from the portal is not persisted in the next timeslot
- **IGRC-4680:** Improving query caching in the collect step
- **IGRC-4682:** Issue with portal created metadata if last timeslot is purged
- **IGRC-4688:** Change metadata step "after dynamic rules" to "before dynamic rules"
- **IGRC-4689:** In rules, the application tag criteria should be available also on safes
- **IGRC-4691:** Change Brainwave to Radiant Logic in Descartes R2
- **IGRC-4698:** Enable / disable controls and metadata based on license and conf variables
- **IGRC-4702:** Radiant Logic graphical chart as default theme in portal - configuration default colors,  labels & icons
- **IGRC-4703:** Update studio visuals for Radiant Logic
- **IGRC-4704:** Be able to disable Studio workspace build in the batch
- **IGRC-4705:** Javascript debugger (in BV, WF and Collect) does not display some native Java variables and generates an error in a popup on each execution step (step-in, step-over, step-out)
- **IGRC-4706:** Missing translation key `Info.commitRenewPreviousExpertiseDomains` in `com.brainwave.iaudit.database.service.DatabaseLogger`
- **IGRC-4707:** Replace SOFTWARE LICENSE AGREEMENT with a link on Radiant Logic website
- **IGRC-4709:** Suppress some Javascript false positive warnings
- **IGRC-4711:** Missing GO before CREATE TABLE queries for SQLServer
- **IGRC-4715:** Hidden timeslots are considered in the renew of the reconciliations
- **IGRC-4716:** Portal does not start when behind a reverse proxy or an apache front end
- **IGRC-4719:** Projects take a long time to close in studio
- **IGRC-4720:** timportlog is not taken into account by the truncation policy
- **IGRC-4721:** Change the DROP TABLES/VIEWS in SQLServer script with IF EXISTS to avoid errors
- **IGRC-4722:** Remove the JTDS driver from the package and the configuration options
- **IGRC-4726:** If the body of a notify rule contains '{', the content is interpreted as Javascript even though it is a CSS definition
- **COL-1498:** Activation failure during portal metadata renew
- **COL-1514:** Cannot create TypedQuery for query with more than one return using requested result type `[java.lang.Long]`

