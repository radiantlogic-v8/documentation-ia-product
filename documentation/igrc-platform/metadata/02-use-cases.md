---
title: "Metadata use cases"
description: "Metada use case descriptions"
---

# Metadata use cases

This chapter describes some use cases where the use of metadata is mandatory.

## Adding a list of certifications to identities

An example that requires the use of Metadata is when attaching a list of certifications to identities.
This information is used in controls to check that some applications or some permissions are only accessed by people having a particular certification.

![Metadata use case 1](./images/metadata_use_case_1.png "Metadata use case 1")

In this case using the Metadata concept is the only way to store the certifications in the ledger as custom attributes do not support lists. In a Metadata lists of values are allowed (either string, date, number or boolean) and can be attached to all main entities.

## Adding a KPI to identities

Another use case would be when computing the number of privileged accounts per identity. This information could be computed in real-time in a view but it is smarter to store this as a KPI especially if this information is used in multiple places.

The advantage of using a metadata is that the information is stored in the database and can be directly queried avoiding the possible performance issue of computing the information in a view.

![Metadata use case 2](./images/metadata_use_case_2.png "Metadata use case 2")

This KPI could have been stored in a custom attributes as it is of type number that will fit in any custom attribute. However, the KPI can be only be computed once all accounts have been reconciled during the execution plan. Custom attributes can only be positioned during the data collection phase, which is done prior to the reconciliation phase.

Using the Metadata concept is the correct way to attach numbers to entities. It can be done at the end of the execution plan so the KPI is always up to date.

## Adding new links between concepts

It can be useful to store the information that an organization is in charge of an application. This information corresponds to a new link in Identity Analytics's data model. This link could then be used in the project, in detail pages or in reviews.  

![Metadata use case 3](./images/metadata_use_case_3.png "Metadata use case 3")

Custom attributes are stored in a given entity and, as such, they cannot be used to link two different entities. However, a metadata can be used to create the links between several Ledger entities. In addition, the link itself can have several attributes to better qualify the link type.
