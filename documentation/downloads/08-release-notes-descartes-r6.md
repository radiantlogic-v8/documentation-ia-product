---
title: Release Notes
description: Descartes R5 Release Notes
---

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
