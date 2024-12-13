---
title: "The Metadata concept"
description: "The Metadata concept"
---

# The Metadata concept

A Metadata is a way to add project specific data into the Ledger and link this information to other entities of Brainwave's data model entities. A Metadata can be seen as a schema extension. A metadata has a name and schema definition.  

The schema definition being a list of attributes and a list of entities which the metadata is linked to.

## Definition

Metadata can be used to store in the Ledger information related to:

- a specific existing entity.
- a relation between 2 or more entities. The relation can be either an existing link in the Identity Analytics data model or a new one.
- a new concept not existing in the Identity Analytics data model.

A metadata is composed of a name (also called a key) and a subkey:

- The name uniquely identifies the schema extension in a project.
- The subkey can be used as a category or a type of data.

> It is highly recommended, as a best practice, to use a 2 part name, separated by an underscore, for the key. This helps prevent schema name conflict:
>
> - The first part is the project name or the customer name.
> - The second part is the name of the schema extension.

For example, a new metadata extension can be created with the name `acme_role` and the subkey can be the type of role (business, technical). The name is given once when defining the metadata in the studio. The subkey is given at runtime when data is created either during the execution plan or in a workflow in the portal.

The other attributes of a metadata are divided in 2 categories:

1. Links between Ledger entities
2. Data to store

The data is composed of several fields:

- 20 strings
- 20 dates
- 2 integers
- 2 float
- 1 boolean
- 1 blob for binary or large content

The links are composed of several references to entities:

- 1 identity
- 1 organization
- 1 repository
- 1 account
- 2 groups
- 2 permissions
- 1 application

The link is a combination of zero, one or several of the above entity references.
For example, it is possible to link the metadata to both an organization and a repository
It means that data can be added at runtime between organization `DCOM` and repository `Elyxo`.

## Examples

Let's look at some examples:

### Adding a list of certifications to identities

We want to attach a list of certifications to identities.
A certification contains the following information:

- The certification name
- The certification provider
- The date when the user passed his certification.
- The expiration date if any

To be able to save certification information in the Identity Analytics data model, a metadata is created with the name `acme_certification`.
This metadata defines these field names along with a display name:

|    Name     |  Type  |         Display name          |
| :---------: | :----: | :---------------------------: |
| `cert_name` | string |      certification name       |
| `cert_prov` | string |    certification provider     |
| `cert_date` |  date  |      certification date       |
| `expn_date` |  date  | certification expiration date |

From the available fields in a metadata, we are using 2 strings and 2 dates. The other strings, 20 integers, 2 floats and the boolean are not used.

This metadata is linked to an identity only.
When a metadata is linked to a single entity we can choose between embedding the attributes in the main entity (Identity) or keep the metadata as a standalone entity (linked to the Identity).

In this case we chose to keep the metadata as a standalone entity as an identity may have several certifications. The best practice is to define multivalued metadata as standalone and not as embedded.

### Adding a KPI to identities

In this example we want to compute the number of privileged accounts per identity.

A single number is needed to store the KPI. Even if we have only one kind of KPI at the moment, we want to be able to add more KPI types in the future.  

From a schema point of view, all the KPI needs only an integer to store a counter. As such all KPIs share the same schema extension. However, each KPI stored in the database must have a type.

In short, we have a single metadata with name `acme_kpi` and we will use the subkey to distinguish KPI types.

The data part contains only one field:

|    Name     |  Type   | Display name |
| :---------: | :-----: | :----------: |
| `kpi_value` | integer |  KPI value   |

This metadata is only linked to an identity. The KPI is single value so we can embed the metadata in the identity concept.
This can be seen as extending the identity to include the `kpi_value` field.

## Adding new links between concepts

We want to store a link between organizations and applications meaning that an organization is in charge of an application. In addition, this responsibility may have an expiration date and we also want several types of responsibility.

The responsibility type (accountable, responsible) will be stored in the subkey in a metadata called `acme_appmanagers`

This metadata defines a new relation between organizations and applications.
The links are activated in the metadata definition:

|  Link type   |               Link name               |
| :----------: | :-----------------------------------: |
| organization | Organization managing the application |
| application  |         Managed applications          |

There is only one field used in this metadata:

|      Name       | Type  |     Display name      |
| :-------------: | :---: | :-------------------: |
| `mngr_exp_date` | date  | management expiration |

When a metadata uses 2 or more links, all of its fields (`mngr_exp_date`) are attributes of the relation, not attributes of either of the entities. This means that all theses metadata instances can exist in the database:

|   subkey    | organization link | application link | `mngr_exp_date` |
| :---------: | :---------------: | :--------------: | :-------------: |
| accountable |       DCOM        |      Elyxo       |      none       |
| accountable |       DCOM        |       SAP        |      none       |
| responsible |       DCOM        |       SAP        |      none       |
