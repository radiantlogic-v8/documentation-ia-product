---
title: "Tips and tricks"
description: "Tips and tricks"
---

# Tips and Best Practice

## Hierarchy and Naming Rules

Audit views are found in the `/views` folder of your audit project.  

- `/views/account`: Views based on accounts
- `/views/application`: Views based on applications
- `/views/asset`: Views based on assets
- `/views/custom`: Directory containing custom views for the project
- `/views/filesystem`: Views based on file system
- `/views/group`: Views based on group
- `/views/identity`: Views based on identities
- `/views/job`: Views based on job title
- `/views/organisation`: Views based on organisation
- `/views/permission`: Views based on permissions
- `/views/physicalaccess`: Views based on physical access
- `/views/repository`: based on reference to repositories
- `/views/rules`: Views referring to rules
- `/views/usage`: Views based on usage status  

Views provided by Identity Analytics are given an identifier prefixed by `br_` .  
File names of Audit Views are based on the view identifier but do not feature a prefix.  
File names start with the main concept that the view processes.  
The '_Notes_' tab of the Audit View contains the description of the view. This information is displayed when selecting an Audit View from the Report Editor.  
The names of concepts that are linked to the View's main concept are prefixed by the name of that concept  
The system modifies the names of attributes to which a mathematical operator has been applied to reflect the operation carried out.  
Your own views must be placed in the `/views/custom` subfolder.

## Limitations of the View Editor

A single relationship cannot be displayed multiple times from an audit view concept. As a result the following view is invalid.  

![Limitations of the View Editor](./images/worddava5a1da4317b07b549b7fe380bd3e899e.png "Limitations of the View Editor")

## Performance

For performance reasons please choose to configure sorting operations on data contained in Audit Views instead of sorting operations directly in Reports and/or Pages. In this situation the sorting operation is carried out directly at the database level and not in the product, limiting the amount of data transferred.  

In a similar fashion, is is recommended to filter your results in Audit View rather than in reports. In this case the filtering of your data is carried out directly at the database level.

## Reports

Identity Analytics provides many pre-configured and multi-format reports for security and compliance services. These reports allow these services to navigate through the data and conduct many analyses allowing them to rationalize permissions and reduce operational risks.  
It is often necessary to adapt the information presented to the client context. For this reason Identity Analytics incorporates a powerful report editor allowing you to customize existing reports or even to create your own reports.  
Identity Analytics reports are based on the Open Source BIRT solution (BI Reporting Tool) from the eclipse community.  

You will find a complete online BIRT documentation in English integrated within Identity Analytics. This documentation is available by pressing F1 and clicking on the 'Content' section.  

> The BIRT online documentation is the reference documentation for the report editor. Identity Analytics documentation allows you to get started with the report editor and highlights the specificities related to  Identity Analytics. If you want to use advanced settings in BIRT, we suggest you consult the reference materials in English after reading this documentation.|

The following sites can provide you with more information on BIRT:  

- BIRT Community Site: [http://www.birt-exchange.org/org/home/](http://www.birt-exchange.org/org/home/)
- Eclipse Official site: [http://www.eclipse.org/birt/](http://www.eclipse.org/birt/)
- Books and documentation: [http://www.birt-exchange.org/org/wiki/index.php?title=BIRT\_Books](http://www.birt-exchange.org/org/wiki/index.php?title=BIRT_Books)

For those who wish to go further, among the many reference books available, we recommend reading the book "BIRT: A Field Guide" :  

Title: BIRT: A Field Guide  
Publisher: Addison Wesley  
3rd edition (February 9, 2011)  
Language: English  
ISBN-10: 0321733584  
ISBN-13: 978-0321733580  

### Differences between the standard version of BIRT and Identity Analytics

Identity Analytics relies on the BIRT solution for all layout actions and report creation, allowing you to capitalize on skills already acquired on the BIRT open source solution. The BIRT solution has nevertheless been extended to facilitate the creation and maintenance of relationships within Identity Analytics.

### Dedicated data source

BIRT is a reporting solution capable of putting together information from many sources: files, SQL databases, data from the Cloud (Hadoop), ... This concept is represented in the 'Dataset' concept in the report editor. Identity Analytics extends the functionality of BIRT standards by providing a dedicated information source to the product (Dataset). This data source has the distinction of being configurable without requiring prior knowledge of SQL and without technical knowledge of the data model. This concept is called 'Audit View' in the Identity Analytics solution. Many audit views are available to those in security services when they wish to generate new reports. It is also possible to create new audit views in order to adjust settings for particular reports.

### Templates and wizards

In order to facilitate the creation of new reports,  Identity Analytics includes many report templates as well as a pre-configured environment for their layout: Main pages, stylesheets, icons, ... Allowing you to create new reports in just a few clicks, without having to reinvent the wheel with each new report.
