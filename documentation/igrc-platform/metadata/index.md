---
title: "Metadata"
description: "Configuration and usage of Metadata"
---

# Metadata

## Extending Identity Analytics data model

Identity Analytics uses a predefined data model.
In order to ingest a new data source in Identity Analytics's ledger, one must define the mapping between the application entitlement model and Identity Analytics's data model.
This means that Identity Analytics's data model is a superset of all the entitlement models that can be found in third party applications.
The Identity Analytics data model is composed of HR and entitlement data model. It defines a number of entities and the available links between these entities.
HR and entitlement model must match the concepts and the links found in Identity Analytics's data model.

Sometimes, information related to HR or entitlements can not find a place in the data model as it does not match the Identity Analytics attribute semantics.
Up until version **2017 R3**, the data model could only be extended in two ways:

1. by using custom attributes to store the desired information in entities.
2. by using workflow tickets to annotate the relevant objects in the Ledger.

### Custom attributes

Custom attributes are the usual way to extend the data model:

- Each entity has a number of custom attributes to store information.
- The meaning of custom attributes is project specific.

However, there are some limitations to using custom attributes:

- There is a limited number of custom attributes depending on entity (usually 19 attributes).
- Custom attributes are single value only. Storing a list of values is not possible.
- In the database, the type is string and the maximum size is limited to either 1000 or 2000 depending on the entity.
- The values of custom attribute are collected and cannot be changed later on in the web portal (there is no workflow component to update a custom attribute).
- Custom attributes can not be used to add information on links.
- By default, custom attributes are not indexed in the database, project indexes are required.

### Tickets

There are also limitations to using Workflow tickets as their primary goal is to add review information on entities.

This document defines a way to extend the data model with a new concept called metadata.
