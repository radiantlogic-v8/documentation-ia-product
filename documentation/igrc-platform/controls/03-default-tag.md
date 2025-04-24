---
title: Controls Default Tag
Description: Documentation related to the Controls Default Tag
---

# Controls Default Tag

When creating controls, it is possible to assign to the controls a set of tags. The main tag fields are:

- type
- scope
- family
- custom1 to custom9

All the fields can store String values, the content is let open. The owner of the control can decide which tags to use and which values to write.

## What are these tags for?

The values stored in these tags have no impact for calculating the controls results. Content on this fields are not parsed nor interpreted, they are not checked for consistency or to avoid collision.

However, these tags can become very useful to clearly identify a set or group of controls. For example, it can be useful to classify the controls into two groups: risk and quality. This will make it easy to query the results controls filtering by the value of the tags. It will be easy to answer to the question: "What are the controls that represent a risk ?".

## What values are already used?

Some of the Identity Analytics facets deliver their own rules and controls. When these facets deliver views, pages or reports to display the results of the controls , it is common to use control tags in order to search, filter and classify.

If the value of the tags for the delivered controls is modified, then the views and pages associated may stop working correctly.

Some of the facets that use control tags: `bw_ad_controls`, `bw_ad_schema`, `bw_controlsdashboard`, `bw_controls_browser`, `bw_groupsandaccounts_analytics`.

| Tag Field | Description         | Values already used                                                                                                         |
| :-------- | :------------------ | :-------------------------------------------------------------------------------------------------------------------------- |
| type      | Entities keywords   | account, group, identity, organisation, application, permission, repository, control, right, rights, manager, owner, owners |
| family    | AD keywords         | securitygroup, localadmin, gporights, gpo, AD                                                                               |
| scope     | Categories keywords | risk, quality, privileged                                                                                                   |
| custom1   | Other keywords      | onallaccounts, perroganisation, perrepository, perapplication, WAB, AWS, SoD                                                |

## In which Add-Ons are these tags used?

Here you will find a non-exhaustive list of the main add-ons or facets that include controls and the tags that are used in their latest versions.

### bw_ad_controls

This facet is used mainly by the AD Booster and some other facets like `bw_groupsandaccounts_analytics`. It includes around a dozen of controls designed to find problems in Active Directory. The controls use the following tags:

- family:AD
- scope: quality, risk
- type: securitygroup, account, group
- custom1: onallaccounts

### bw_ad_schema

This facet is only used by the AD Booster. It extends `bw_ad_controls` by introducing advanced controls on Active Directory. The following tags are used:

- family: AD
- scope: privileged, quality, risk, localadmin, gporights
- type: account, securitygroup, group

### bw_controlsdashboard

This facet include some controls and some pages to display the results? The following tags are used:

- type: control
- scope: repository, application, per organization

### bw_mashup_bastion**

This add-on provides ready-to-use mashup dashboards. It includes some controls that use the following tags:

- family: WAB

### bw_mashup_amazonaws

This add-on provides support for Amazon AWS services.The following tags are used:

- family: AWS

### bw_segregationofduties

This add-ons generates SoD controls based on an SoD matrix received as input. The tags used for the controls are to be defined for each project. However, the most commonly used tags:

- family: SoD

## Best Practices

If you want to tag your controls in order to filter them:

- Avoid using the keywords mentioned above. Creating new controls with those tags might impact the functionalities of some existing facets
- Think of making your tags unique, for example by adding a prefix like `xx_risk`
- Combine multiple tags. For example family=AD AND scope=risk
