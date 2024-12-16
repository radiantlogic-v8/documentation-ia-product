---
title: Advice and Best Practices
Description: Documentation related to advices and best practices of creating reports
---

# Advice and Best Practices

## Arborescence and Naming Conventions

Reports are present in the `/reports` subtree of your audit project. Several subdirectories are present depending on the primary purpose of the report.

- **/reports/analysis/** : Analytical reports. Most of these reports launch an analysis on an element of the Ledger
- **/reports/browsing/** : Navigation report
- **/reports/controls/** : Dashboards and control summaries
- **/reports/custom/** : Project's custom reports
- **/reports/icons/** : Images library
- **/reports/dashboard/**  : Dashboard's summaries
- **/reports/library/** : Library on which all the standard reports rely. Do not modify the content of this directory
- **/reports/resources/** : Localization reports of the Ledger concepts
- **/reports/rules/** : Reports used by the rule engine when you click on the 'Report' button in the 'Results' tab
- **/reports/scripts/** : Scripts on which all the standard reports rely. Do not modify the content of this directory
- **/reports/style/** : Stylesheet used by standard reports

You must create your own reports in the '/reports/custom' subdirectory; this will facilitate the reversibility and the migration of your reports to a new version of  Identity Analytics.  
We recommend that you rely on existing reports to help create your own reports. Feel free to copy/paste reports or report elements.  
You can modify existing reports entirely, for example, to add or change detail texts in identity reports, account reports ... We advise you to keep track of the reports you have modified in order to facilitate upgrading the  Identity Analytics software. Identity Analytics supports the majority of version control managers. The best way to keep track of changes is fork your audit project in a version control manager such as SVN.
We recommend that you give your reports simple names that remind you of the concept presented by the report as well as the primary purpose of the report.  
Standard Identity Analytics reports adopt the following naming convention:

- The reports bear the name of their main concept
- `_[concept name]_search` for search reports
- `_[concept name]_detail` for detail reports
- The report parameters used by the Datasets bear the name of the Dataset column with which they are associated

We recommend that you keep those conventions, and also suggest you place your localization files in the same place as your report and that you name your default localization file with the same name as your report.

The `/reports/rules/` subdirectory contains a series of reports used by the rules engine. The rules engine dynamically lists the reports available for the main concept of the rule when you click on the 'Report' button. It then presents this list to the user, retrieving the title and description information entered in the report (General/Title and Description fields in the report's properties editor). The reports are classified according to the concept to which they apply:

- **/reports/rules/account** : Account rules results reports
- **/reports/rules/application** : Application rules results reports
- **/reports/rules/asset** : Assets rules results reports
- **/reports/rules/identity** : Identities rules results reports
- **/reports/rules/organization** : Organizations rules results reports
- **/reports/rules/permission** : Permissions rules results reports

You can add your own rules reports in these directories to extend the standard Identity Analytics functionalities. To do so, copy/paste an existing rules report, and use it as a model or use the following report templates: _Rule results, landscape report, Rule results report._

> Do not forget to read the _/reports/README FIRST.txt_ file before using Identity Analytics reports.

## Audit Views

Audit views are able to automatically skip parameters that are not valuated from the Datasets. Many audit views are available, all having several parameters in order to facilitate reuse; we recommend that whenever possible, you use a standard audit view.  

We <u>strongly</u> discourage you from modifying a standard audit view to extend its functionalities in order to meet a specific report's needs. The audit views are used by many reports, editing an audit view would introduce malfunctions in your audit reports. If no audit view meets your needs, we suggest that you duplicate an existing audit view or to create a new audit view.

## Performances

The following features induce a significant decrease in performance when generating reports:

- Filtering data in a Dataset or a Container
- Sorting in a Dataset or a Container
- Setting up sub-reports
- Generating data cubes without preparing the data beforehand

We recommend that you perform data filtering and sorting operations in audit views, the corresponding operations are then delegated to the database.  

We recommend that you use the grouping functionality in the tables rather than the sub-report functionality, which allows you to go from N +1 queries to a single query.  

We recommend that you create dedicated audit views leveraging the audit view aggregation features to optimize data cube creation.  

And lastly, we recommend that whenever possible, you set a limit on the number of rows to retrieve in your Dataset, in order to limit your reports to a reasonable size and optimize report generation time.

## Standard Reports

Many reports are available as standard in Identity Analytics. These reports allow you to navigate in the Identity Ledger as soon as you have loaded a first dataset. Many analyses are also available.
Reports allow you to focus on your immediate control and audit activities. In this chapter you will find a brief description of the various reports that comprise Identity Analytics.

![Standard analysis reports available](./images/report-analytics.png "Standard analysis reports available")
