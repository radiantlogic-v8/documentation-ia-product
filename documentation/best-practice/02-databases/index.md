---
title: "Best practice for databases"
description: "Best practice for databases"
---

# Best practices for database

The recommendation provided in the following documents were performed in a integration environment using volume of data representative of a production environment. These are the result of several data loading phases including testing, and tuning.

The overall data loading phase as well the end user usage in the webportal (restitution phase) has been found to be optimal by respecting the following recommendations or best practices.

However, it will be up to the database DBA to adapt parameters according to the hardware and software environment on which runs the database engine as well as the physical location of data files, transaction logs.  

It is also recommended to adapt the configuration to production constraints. For example: Archive mode, resource sharing and naming rules among others.

> [!warning] The database recommandation are dependant on the database management system used.  
> Please refer to the following pages for more information
