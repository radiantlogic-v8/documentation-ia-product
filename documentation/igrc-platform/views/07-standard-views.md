---
title: "Standard views"
description: "Usage of standard rules"
---

Identity Analytics supplies a selection of Audit Views as standard. These are included in the default project and enable the user to make use of the data contained within the Identity Ledger as soon as the data has been loaded. The default audit Views are located in the 'views' sub-folder of your audit project.  

> When creating a custom view, you must create these in the /views/custom folder of your audit project. Sub-folders can be created within this folder for sorting and storage of views.

Audit views are classified following the main concept that the view processes:  

- **account** : Views based on accounts
- **application** : Views based on applications
- **asset** : Views based on assets
- **custom** : Directory where custom project views are stored
- **filesystem** : Views based on shared directories
- **group** : Views based on groups
- **identity** : Views based on identity
- **job** : Views based on job title
- **organisation** : Views based on organisations
- **permission** : Views based on permissions
- **physicalaccess** : Views based on physical access
- **repository** : Views based on reference to repositories
- **rules** : Directory containing all views dealing with validation and rules
  - **account** : Account based views
  - **application** : Application based views
  - **asset** : Asset based views
  - **identity** : Identity based views
  - **organisation** : Organisation based views
  - **permission** : Permission based views
  - **sharedfolder** : Views on shared folders
- **usage** : Views based on usage status

The names of Audit Views are prefixed by the main concept to which the view relates. The key word 'count' is used for views which trigger mathematical operations on data. When joins are created with restrictions, the key word 'by' is used to link the concepts in the name, for example `applicationsbyaccount`.  

View identifiers are named by taking the names of the relevant view and adding the prefix 'br\_'. It is recommended that you choose a different prefix if you are generating your own views.  

All views may contain various optional parameters so that it is possible to use a single view to search for information in the Main Ledger or to retrieve information on a given entry.  

> [!warning] Users must not modify views supplied with the product as standard as this could have impacts on the results displayed in pages and/or reports of the default project.  
If you want to modify a view used in a specific page and/or report it is recommended to duplicate the view and modify the view used in either the page or report.
