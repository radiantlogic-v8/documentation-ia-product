---
title: "Metadata editor"
description: Metadata editor in the studio presentation
---

# Metadata editor

Using metadata in the product require two distinct phases:

1. A step that determines the schema of the metadata. In other words the skeleton of the metadata and how it will later be populated
2. The population step. This can be done at different steps of the execution plan, during the data collection phase (collected metadata), during the activation (computed metadata) or in the web portal (portal metadata).

The Metadata editor is the editor that allows the user to configure the schema of the metadata and configure the method used to compute the metadata if necessary.  

## Metadata creation

A metadata is created from the main menu by selecting `New...` and then `Metadata schema`.

![Metadata creation](./images/metadata_creation.png "Metadata creation")

This menu opens a wizard to create a new schema extension. The metadata id field is the name of the schema extension and it must be unique among all extensions in the project, created in the project or included in installed add-ons.
Identity Analytics add-ons containing metadata always use a prefix `bw` for the metadata id.
The best practice is to use a prefix describing the project (or the customer) and then an explicit schema extension name in order to avoid conflicts, for example `acme_myfirstmetadata`.

The best practice is to fill in the description of the created metadata with the purpose of the extension. This helps document what the schema extension will be used for.

![Metadata id](./images/metadata_id.png "Metadata id")

## Schema definition

Upon completion of the wizard an editor is opened that allows the configuration of the schema of the metadata. This is an important step as this will provide the product with the way the metadata will be created and then what elements are necessary when populating the metadata.

The following snapshot shows the definition for the first use case.

![Metadata editor](./images/metadata_editor_full.png "Metadata editor")

As a metadata is to be used in views and rules. The view editor and the rule editor requires icons to display the entities or attributes in the palette.
This is why the metadata editor expects 2 icons: one in 16x16 and one in 48x48. An icon is provided by default but the user has the option to add custom icons.

The metadata editor is used to define both:

- The schema extension in the 'Metadata definition' tab of the editor
- The method to compute a metadata during the execution plan in the 'Metadata computation' tab of the editor.

If a metadata is not computed configuring the 'Metadata computation' is unnecessary.

## Metadata links

A metadata can be associated with no, one or several entities:

- Defining a metadata without an entity means that you create your own concept without any relation with other Identity Analytics entities. In rare occasions, you need to create a new concept which is not linked to any other Identity Analytics entities.
- The usual way to use metadata is to extend a Identity Analytics concept to add attributes. In this situation, a single concept is selected in the editor. The user has the choice of having an explicit link towards the Identity Analytics concept or to embed the metadata attributes directly in the Identity Analytics concept.
- Another usage is to select several concepts. This is the method to use to create a link with attributes between 2 or more concepts.

The following paragraphs explain how to configure the entity or the links.

### Metadata without entity

The following caption shows a new standalone concept called `acme_my_concept`.  that is not linked to a Identity Analytics entity.

![Metadata zero entity](./images/metadata_zero_entity.png "Metadata zero entity")

To do so, in the editor, keep all checkbox unchecked.
The 'short metadata title' **must** be filled to see the metadata in the view editor palette.

![Metadata zero entity configuration](./images/metadata_my_concept.png "Metadata zero entity configuration")

As there are no links from the metadata to any Identity Analytics concept, this mode is rarely used but can be useful to store configuration information for example.

### Metadata with attributes embedded in a single entity

This is the most common usage of metadata. The attributes defined in a metadata are added to a Identity Analytics entity.
The following picture shows a metadata called `acme_my_extension` extending the Identity concept.

![Metadata one entity with embedded attributes](./images/metadata_one_embedded_entity.png "Metadata one entity with embedded attributes")

To extend a Identity Analytics concept check the checkbox named 'Display metadata attributes in the following concept in the view editor'.

![Embed a metadata in single entity](./images/metadata_single_entity.png "Embed a metadata in single entity")

When checked, the entity holding the attributes must be selected in the dedicated combobox among the following list:

- Organization
- Identity
- Repository
- Group
- Account
- Permission
- Application
- Asset

![Select the entity to embed the metadata](./images/metadata_single_entity_combo.png "Select the entity to embed the metadata")

In this mode, all attributes defined in the metadata schema are visible directly on the entity itself in the view editor.

### Metadata with an explicit link in a single entity

In this mode, there is still a single concept but the metadata designer does not want to embed the attributes in the entity.
Technically this means that in the view editor, it is necessary to perform a join on the main entity to reach the desired metadata attribute.
The following picture shows the metadata named `acme_my_extension` which has an explicit link to the identity

![Metadata one entity with explicit link](./images/metadata_one_link_entity.png "Metadata one entity with explicit link")

To do so keep the checkbox named 'Display metadata attributes in the following concept in the view editor' unchecked.
Then select the link called 'Use and activate the link towards identities' and enter the label that will appear in the join section of the palette when the metadata is selected.

![Metadata editor with explicit link](./images/metadata_editor_explicit_link.png "Metadata editor with explicit link")

> This mode can seem less useful than embedding attributes in the target concept using an explicit link can be beneficial.
> This is the case when the metadata is multivalued. For example in the use case with the certifications on identities, it is better to have an explicit join from the identity to the certification metadata.
> If an identity has 3 certifications, the view result displaying `fullnames` and certification names will display 3 lines for this identity.
> Even if it is correct from a technical aspect, it may be odd to see duplicate lines appearing when you drag an embedded identity attribute.
> But if this attribute is taken from an external entity using a join, the possibility of having duplicates seems more obvious.

> From a performance perspective, it does not matter if attributes are embedded in the concept or if a join is used.
> Both methods are implemented in the database with a join to the metadata table.
> The difference between these 2 options is only for convenience in the view editor.

### Metadata with several entities

Defining a metadata with links to several entities is a way to create a new relation in the Identity Analytics data model.
The following picture illustrates a new link called `acme_my_link` between an identity and an application.

![Metadata link with several entities](./images/metadata_several_entities.png "Metadata link with several entities")

To create such a link, check at least 2 checkboxes defining a link towards entities in the metadata editor.
The following screenshot shows the configuration for adding a link between organization and application to define a responsibility for example.

![Metadata with several links](./images/metadata_several_links.png "Metadata with several links")

In this configuration, both the organization and the application have a new component to join in the view or rule palette to access the linked attributes.
Using these joins, it is possible to go from the organization to the metadata containing the `mngr_exp_date` attribute and then go to the managed application.

## Metadata values

### Single or multivalued attributes

By design all metadata values are multivalued. There is no way to restrict an attribute to a single value.

Whatever attribute is defined as values in the metadata schema definition, you can always create multiple values at runtime as long as the data conforms to the schema definition.
It is the responsibility of the application (when collecting or when updating metadata in a workflow) to ensure that only one value is saved if single value is desired.
For example, if a metadata defines an attribute called `cert_name` for certification, it is possible to add several certification names for a given user.

As explained earlier, the metadata is composed of several fields for the value.
A value is in fact a set of, at most, 20 strings, 20 integers, 2 floats, 2 dates, 1 boolean and 1 blob.
For a given metadata, it is possible to have several values, meaning several sets.
If there are 3 certifications, there will be 3 sets composed of, at most, 20 strings, 20 integers, 2 floats, 2 dates, 1 boolean and 1 blob.

When updating a metadata, the full set is created, updated or deleted.
Let's take the example of the certifications for an identity.
The metadata contains 4 attributes (2 strings and 2 dates, the others are unused):

- `cert_name`: string 1
- `cert_prov`: string 2
- `cert_date`: date 1
- `expn_date`: date 2

We can execute these operations either in the collect or in the workflow:

- add a value (a full set of 2 strings and 2 dates)
- remove a value (a full set of 2 strings and 2 dates)
- update a value (a full set of 2 strings and 2 dates)

From this example, we can see that if we add 3 values, we will always have the same cardinality in the 4 attributes (3 string values in `cert_name`, 3 string values in `cert_prov`, 3 date values in `cert_date` and 3 date values in `expn_date`).
`expn_date` can be null in the last set but there are still 3 values (2 non empty dates and 1 null).

> [!warning] If you have 2 attributes with different cardinality (for example 3 values in string 1 and 8 values in String 2), there is a chance that you should use 2 metadata instead of one.
> If you activate string 1 and string 2 in a metadata, it means that the first value of string 1 is related to the first value of string 2 and both attributes should have the same number of values.
> If the first value of string 1 is not related to first value of string 2, storing these 2 attributes in the same metadata is a bad idea.

In the metadata schema the type of metadata values are split in two categories:

- Simple values
- Entity values

The differences between both concepts are detailed below.

### Metadata simple values

It is possible to configure a metadata in order to use simple values as attributes. To activate and define these attributes in the metadata in the simple 'values tab', choose a type and enter an identifier in the corresponding field.
The available types are:

- `string`
- `integer`
- `float`
- `date`
- `boolean`
- `blob`

Once the value identifier is filled in, the label field to the right of the identifier field is then enabled. The label field is used to populate the palette in the view editor.

![Metadata simple values](./images/metadata_simple_values.png "Metadata simple values")

The field 'Details value identifier' at the bottom of the list corresponds to the blob field which can be used to save details about the metadata (for example XML or JSON content) or a binary content.

### Metadata entity values

A metadata value can also contain a link or reference to an entity.

![Metadata simple values](./images/metadata_entity_values.png "Metadata simple values")

#### Metadata entity value use case

Entity values correspond to links from the metadata to other entities of the Ledger (accounts, identities, organizations, applications, ...).

For example, this is useful when the value is a combination of a string, a date and a Ledger entity .
This is very similar to entity references in the key but the usage is different when used in values.

The need of declaring entity links as metadata values often arrives when a concept needs to reference several entities which are optional.
For example, a metadata is declared to create a link between an organization and an application. Both entities are part of the metadata key.
But we could also add values like identities responsible of this link. This information is optional and should not be part of the key.
To model this optional the link to the identity is added to the metadata values.  

#### Choosing between metadata keys and values

It is important to understand the difference between metadata keys and values as this will have an impact on how and when a metadata is created and what it will contain. However, there is no absolute rule to know if an entity should be part of the key or not.

Here is an example to understand the difference between referencing an entity in the key or in the value.

Let's add another feature to the certification metadata.
let's consider that this is an internal certification, as a result we would like to keep a reference to who within the company delivered the certification.
This  means that we need to add to the certification metadata a link to an identity in the ledger.

As a result the metadata schema is now composed of 4 simple attributes, the `certification name`, `provider`, `date` and the `expiration date`, and the identity who delivered the certification.

If the identity that delivered the certification is no longer part of the company then the link to the identity concept in the ledger is not longer available for the metadata. However this does not mean that the certification no longer exists or is invalid. As a result we can see that the certification provider should not be part of the key and be added to entity values.

### Portal metadata activation

On the contrary to collected or computed metadata, a portal metadata is copied from one timeslot to the next during the activation phase of the execution plan. However, a metadata can be copied to the next timeslot **only if all** the referenced entities defined in the key are available in the destination timeslot.

As an example, let's focus on a metadata containing a link to 2 entities in the key, application and organization, and a link to an entity value, identity.

In the first timeslot we have a metadata with the application `Elyxo`, the organization `DCOM` and, as a value, the identity `Paul Martin`.

In the second timeslot, if **either** key entity, `Elyxo` or `DCOM`, are missing then metadata is not copied over.

In the third timeslot if both key entities are found, `Elyxo` and `DCOM`, the metadata will be copied from timeslot 1 to timeslot 3

In all cases, if the entity value is missing, in this case the identity `Paul Martin` no longer is present in the ledger, then this **does not** prevent the metadata from being copied in all timeslot. The timeslot where `Paul Martin` is not present will fill `null` in the entity value.
If the identity is reintegrated back in the Ledger, then the metadata will point again on the identity `Paul Martin`.

### Metadata values conflicts

Another aspect that can influence the use of an entity in the **key** or in the **value** is the metadata life cycle.
This is especially important when the metadata is collected and later updated in the portal.
When a metadata has been changed in the portal, the collected values in the next timeslots are ignored, as a portal metadata has a higher priority than both the collected and computed metadata.

> The following explanation applies only if you have collected metadata that can be edited in the portal.

When a metadata can be collected and modified in the portal, you must take care of which entities are in the **key** and which entities are in the **value**. This influences the way conflicts between collected metadata and portal metadata are handled.

During the activation phase when the product merges the collected (or computed) metadata with the portal version of the same metadata, the operation is executed for each metadata key.
The key is composed of the **metadata name**, the **metadata subkey** and **all** the **key** entities defined in the schema.
In other words, for a single key, all the values are considered atomic during the merge operation.

This means that if there are several values in a key, then either:

- The metadata **was not** updated portal side and so **all** values are **collected**.
- The metadata **was** updated portal side and so **all** values are **copied** from the previous timeslot.

This ensures that the values are consistent.

Let's take an example with 2 entities (organization and application) where an organization is responsible for an application.
There are 3 distinct ways to design the metadata schema:

1. The organization is in the key and the application in the value.
2. Both organization and application are in the key.
3. The Application is in the key and the organization in the value.

#### The organization is in the metadata key

Let's examine the first option.
This design means that, for a given organization, we have a list of managed applications, 0 or more.

During the data collection phase it is determined that:

- The organization `DCOM` manages the 3 applications `Elyxo`, `FileShare` and `SAP``
- The organization `DFIN` manages 2 applications `FileShare` and `PeopleSoft`.

In the web portal, a user decides to change the list of managed applications:

- `DCOM` now manages `Elyxo` and `PeopleSoft` 
- `DFIN` now manages `FileShare` and `SAP`

The information entered by the user in the web portal now becomes the reference and the whole list is copied from timeslot to timeslot ignoring what is collected.

In a later timeslot, if during the data collection phase the import files say that:

- `DCOM` manages `FileShare` and `PeopleSoft`
- `DFIN` manages `FileShare` and `SAP`

The list of values entered by the user has a higher priority. And so the values in the metadata will be taken from the previous timeslot and remain:

- `DCOM` now manages `Elyxo` and `PeopleSoft` 
- `DFIN` now manages `FileShare` and `SAP`

In this configuration, in order to get all applications managed by a given organization (`DCOM`), we must fetch a unique metadata whose key is the organization and the values the list of applications.

The following table shows the timeslots with data collected or updated in the portal.
The last columns with a title 'Timeslot 2 (final result)' shows what the user can see when looking at the management information in the portal.

![Metadata with organization as key and application as value](./images/metadata_org_key_app_value.png "Metadata with organization as key and application as value")

The general rule for dealing with conflicts is that the whole list of the values (applications) for a given key (organization) is taken either from a single source:

- The collect
- The previous timeslot.

In this scenario, the application list for both `DCOM` and `DFIN` have been modified in the portal so the portal metadata wins.

This product behavior prevents a merge of the application list provided during the data collection phase or, if the list was edited in the portal, from the previous timeslot.
Upon conflict, the list is considered atomic and we can not end up with applications coming from both lists.

#### Both organization and application are in the metadata key

Now let's examine the second option.
Both the organization and the application are part of the key.

In this configuration, there is no more list of values for a given key as the key contains both entities.
Instead of having one metadata with a list of applications, we end up with several metadata, each one having an organization and only one application.
Each metadata is independent from the other, even if some of them share the same organization.

In this case, to get all the applications managed by `DCOM`, we must fetch all the metadata with the organisation equals to DCOM.
At most, we have 8 metadata:

- `DCOM` - `Elyxo`
- `DCOM` - `FileShare`
- `DCOM` - `SAP`
- `DCOM` - `PeopleSoft`
- `DFIN` - `Elyxo`
- `DFIN` - `FileShare`
- `DFIN` - `SAP`
- `DFIN` - `PeopleSoft`

The same scenario as detailed previously is executed, the metadata are collected then changed in the portal. The end result is different as shown in the following table.

![Metadata with organization and application as keys](./images/metadata_org_key_app_key.png "Metadata with organization and application as keys")

As a reminder, for each key, the activation keeps either the collected data or, if updated in the portal, the data from the previous timeslot.

The result shows that individual keys have been handled separately by the activation.

Let's review which application is managed by `DCOM`:

- `Elyxo` is not managed anymore because the last collect does not include this application.
- `FileShare` is managed because it has been removed by the user for `DCOM`. Removing a metadata on the portal side means that the data will be taken from the collect at the next timeslot. The key is then collected again.
- `SAP` is no longer managed as it has been removed by the user in the portal and has not been collected afterwards.
- `PeopleSoft` is only managed by `DCOM`, as it has been collected in the last timeslot. However `DFIN` no longer manages `PeopleSoft` as this was updated on the portal side and has not been collected in the last timeslot.

#### The application is Metadata key

Now let's examine the third option where the application correspond to the metadata key and the organization correspond to the metadata value.

In this model, the application either have no metadata, meaning no organization is managing it, or a metadata with at least one organization managing it.

The result is shown in the following table:

![Metadata with organization as value and application as key](./images/metadata_org_value_app_key.png "Metadata with organization as value and application as key")

After executing our scenario, we find the following results:

- `Elyxo` has no managing organization anymore because the last collect does not include `Elyxo`.
- `FileShare` has `DFIN` as a managing organization as `DCOM` was removed by the user. The whole value list, the list of organizations only containing DFIN, is used from the previous timeslot and the collected list is ignored.
- `SAP` has `DFIN` as a managing organization for the exact same reason as `FileShare`.
- `PeopleSoft` has `DCOM` as managing organization because the user changed the value list in the portal to keep only `DCOM` for this application.

#### Conclusion

It is important to understand that there is no absolute truth about which model is the good one.
The choice of the key will depend on the use case and the data semantics.

With the previous example, using the first option with organization in the key and applications in the value seems to be a better solution.
But it depends on:

- The authoritative data source. The collected one or information provided by the users in the portal
- The entity semantics of the entities
- The company context
- The way the data it is edited in the portal
- ...

A parameter to help decide if an entity goes in the **key** or in the **value** is to consider if the entity list should be considered as:

- Atomic, and taken as a whole from the collect or from the portal.
- Standalone, and putting all entities in the key

## Using metadata in the rule editor and portal search

### Metadata in the rule editor

Metadata can be used in the rule editor in 4 different situations:

1. Metadata with attributes embedded into another entity
2. Metadata with explicit links to other entities  
3. Metadata with value links to other entities  
4. Standalone metadata without entity  

In case 1, 2 and 3 (embedded, key link, and value link ) , the metadata can be used in rules through specific joins from the linked entities.  
For example, if the metadata is linked or embedded to Identity entity , a join to this metadata will be available from the identity entity in the palette.

![Rule editor metadata joins](./images/metadata_editor_rule_join.png "Rule editor metadata joins")

The metadata join will propose various criteria on the attributes of the metadata, depending on the type of the attribute, and criteria on generic properties of the metadata, such as description, creator, subkey , etc.  

![Rule editor metadata join attribute](./images/metadata_editor_rule_join_attr.png "Rule editor metadata join attribute")

In case (1) metadata with attributes embedded into another entity , it's also possible to use the metadata directly as criteria on the embedding entity in the rule editor.  
But this requires the metadata to follow some restrictions:  

- the metadata subkey must be empty ( not set through computation or code)
- runtime values of all metadata attributes must only contain single values.  

For this reason, this option must be set **explicitly** by checking the **Display also in Smart Search interface and rule editor as criteria of the single concept** box.

![Rule editor check embedded attribute](./images/metadata_editor_rule_check.png "Rule editor check embedded attributes")

In which case, the embedding entity will propose additional criteria for the embedded metadata attributes which can be used like the other entity attributes:

![Rule editor embedded attributes](./images/metadata_editor_rule_embed_attr.png "Rule editor embedded attributes")

### Metadata in the Smart Search

When this option is checked for embedded metadata attributes, you can also enable the use of metadata criteria in the Smart Search user interface in the web portal.  

To do so, you will have to provide additional labels to help build user-friendly search sentences in the Smart Search user interface. The meaning of the label depends on the type of the attribute:  

- for string, integer , float and date attributes,  you must provide a **prefix** label. The label that will appear in the UI for this attribute is built by concatenating the prefix and the attribute.  
For example, if the prefix is "which" and the label is "certification name", the search label attribute will be "which certification name". In French, the prefix would be "dont le" and the label "nom de certification", giving in the search "dont le nom de certification".
- for boolean attribute, you must provide the negative form of the attribute, assuming the label is the positive form.  
For example, the label could be "has expired" and the negation would be "has not expired"
- leaving the search prefix or negation label empty for an attribute will hide the attribute from the list of Smart Search criteria for the embedding entity.  

![metadata editor search labels](./images/metadata_editor_search.png "metadata editor search labels")

This is how the SmartSearch could look like.  In the example above, certification date and expiration dates are hidden.  

![metadata Smart Search UI](./images/metadata_editor_smartsearch.png "metadata Smart Search UI")
  
### Localizing metadata labels

You can localize all the metadata labels (name, attributes , relations and search labels) by clicking the blue flag to the right of the label edit box. This will create the appropriate entry in the specified properties file.
To make the localization task much easier, you can generate a localization template for all the active attributes and relations.
To generate the template text to the clipboard, click on the **Copy Label localization template to the clipboard** button at the bottom right of the editor.

![metadata localization](./images/metadata_editor_nls.png "metadata localization")

In the example above, this will copy the following text to the clipboard.  
You can then paste the text to the appropriate properties files and fill the blanks or translate the labels.

```java
Metadata.link.id_cert_embed.metadata=
Metadata.value.id_cert_embed.value1string=certification name
Metadata.value.id_cert_embed.value1string.search=which
Metadata.value.id_cert_embed.value2string=certification provider
Metadata.value.id_cert_embed.value2string.search=which
Metadata.value.id_cert_embed.value1date=certification date
Metadata.value.id_cert_embed.value1date.search=
Metadata.value.id_cert_embed.value2date=certification expiration date
Metadata.value.id_cert_embed.value2date.search=
Metadata.value.id_cert_embed.valueboolean=certification has expired
Metadata.value.id_cert_embed.valueboolean.search=certification has not expired
```
