---
title: Data Discovery Introduction
Description: Documentation related to Data Discovery
---

# Discorvery

## General information about discovery

Data file discovery is an elementary and intermediate step in data collection in the Identity Ledger. It consists of analyzing files in different formats (CSV, LDIF, XML, etc.) and applying simple processing to them. Examples of processing types are: adding new attributes, computing new attributes from those that are already present, removing or editing certain values or records.  
Data discovery automates data filtering/transformation/quality assurance before loading it into the Identity Ledger through "Data collection."  
As such, "data discovery" may be used as a source of data when configuring "Data collection." All the configured operations on the "data discovery" level are then performed in real time, transparently, before the collector line.  

Contrary to classic ETL solutions where it quickly becomes necessary to rely on a programming language (Java, JavaScript, C#) for transformation or filtering operations, the association and wealth of "data discovery" concepts and "data collection" allow these operations to be performed without programming.  

This "data discovery" component can also be used autonomously if you wish to apply transformation/filtering operations on data files regularly. In this case, the results will be available in CSV format. This is an alternative solution that is much more powerful than the filtering tools available in Excel.  
This objective of this documentation is to give you basic instructions that will allow you to use the Discovery component. You will find numerous "screencasts" on how to configure data "discovery" and "collection" on this site: [Discovery Editor](../getting-started/05-studio-editors#discovery-editor)  

## Data sources

The file discovery motor accepts the following data sources:

- **CSV:**  format in which each column is separated by a delimiter. A header row may be present to indicate column names. The delimiter is configurable (generally a comma or semicolon).

- **LDIF** : directory exchange format representing hierarchically structured entries (LDAP, X500). You may process a small part of the entries by filtering on a sub-tree and on one or more object classes.

- **XML** : format made up of hierarchically structured tags. Only a sub-section of the tags is taken into account when giving a path in the XML nodes tree.

- **Formatted:**  format consisting of fixed-sized fields. There is no separator between the values, so to configure this type of file, indicate the number of characters each column uses.

- **Log files:**  format consisting of access logs. The lines often contain "Who, What, Where, When, Why" type information (who performed which action, from where, when, with which rights and what was the result).

- **Microsoft Excel files:**  desktop spreadsheet or pivot table type format. Excel files may contain several tables per page and several pages. The product can handle XLS and XLSX file formats.

## File encoding

Please note that selection of the file encoding impacts the quality of the data. If the file encoding information is not included in the file encoding then no error will occur in the execution of a discovery, however non standard characters can be incorrectly handled.  

To avoid this type of issue it is recommended to use the file encodings that includes `BOM` to avoid issues when collecting data. For example by using `UTF-8 BOM`. In this situation if a file is provided using the wrong file encoding then an error will error in the execution plan avoiding to collect incorrect data.  
