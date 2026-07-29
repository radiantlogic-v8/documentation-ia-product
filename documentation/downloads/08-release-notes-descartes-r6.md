---
title: Release Notes
description: Descartes R5 Release Notes
---

# Descartes R6 prerequisites

**Requires** `Java 21`

Add the following java9 option to your tomcat: `--add-opens=java.base/java.net=ALL-UNNAMED`.

# Release Notes Descartes R6 SP2

> Release date: 2026-07-29

**Requires** `Java 21`

Add the following java9 option to your tomcat: `--add-opens=java.base/java.net=ALL-UNNAMED`.

## Bug fixes

- **BWIPUAR-3047:** Performance issues with portal - disabled CSP upgrade-insecure-requests
- **BWIPUAR-3068:** Hide passwords in logs when views are executed

# Release Notes Descartes R6 SP1

This version has not been published because of a blocking bug.

## Bug fixes

- **BWIPUAR-2492:** Allow selecting and copying text from portal react pages
- **BWIPUAR-2497:** PenTest report: vulnerability fixes - Missing Critical Security Headers Exposing Application to Clickjacking, Data Leakage, and Feature Abuse
- **BWIPUAR-2524:** It's not possible to sort tables on the view's computed columns (removed parameters in projections)
- **BWIPUAR-2650:** UAR Review - Custom Perimeter Rule Filter - Not possible to create in past timeslot
- **BWIPUAR-2705:** Issue on controls on organizations
- **BWIPUAR-2765:** Performance issue on IAS review pages due to missing timeslot filter in aggregated rights
- **BWIPUAR-2957:** [ Dashboards ] view-based indicators are always displaying data from current timeslot
- **BWIPUAR-2978:** igrc_view "Required array length 2147483638 + x is too large" error
- **SQ-1584:** Slow activation for confitems (CommitConfItems)

# Release Notes Descartes R6

> Release date: 2026-05-19

### Prerequisites

**Requires** `Java 21`

Add the following java9 option to your tomcat: `--add-opens=java.base/java.net=ALL-UNNAMED`.

### New Features

- Add SQL projections to views

### Bug fixes

- **COL-1722:** Fixed an issue where purge operations could fail with a “The incoming request contains too many parameters” error.
- **BWIPUAR-2314:** Fixed a translation issue affecting Smart Search temporal criteria.
- **BWIPUAR-2603:** Reduced business view logs when filtering entries.
- **BWIPUAR-2620:** Optimized cross-table clustering.
- **BWIPUAR-2690:** Fixed an issue where content suggestions in views did not display all available columns and attributes.
