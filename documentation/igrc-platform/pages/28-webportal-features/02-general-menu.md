---
title:  "General Menu"
description: "General menu" 
---

# General Menu

Even if the General Menu does not look much different, it has been redesigned in the way it works. It implements the new [tagging system](./index#tags) which makes it very flexible and customizable.

All the links in this page are being created dynamically. To add a new link to a **Page** or a **Report** from the general menu all you have to do is tag it following the default tags and fulfilling the requirements . In the same way, to delete an existing link, all you have to do is remove the tags from the target.

## Default tags

The General Menu uses 4 different sets of tags:  

| **Set of Tags** | **Description** |  **Priority** |
|:--|:--|:--|
|  "**generic**" and "**control**" | This includes pages or reports defines as **control** and that do not receive any parameter |  Not used |
|  "**generic**" and "**mining**" | This includes pages or reports defines as **mining**  and that do not receive any parameter |  Not used |
|  "**generic**" and "**browsing**" | This includes pages or reports defines as **browsing** and that do not receive any parameter |  Not used |
| "**conceptsearch**" | This includes pages or reports that have as main goal the search of concepts. For example: search of sharepoint elements |  Not used |

The priority is not used, and the links are ordered by alphabetical order using their title as an index.  

The common tag for the reports in this category is **generic** , the idea is that reports that contain this tag are reports that will work as expected when no parameter is sent. In order to be properly displayed the page or report must comply with the requirements.

## Requirements

Being tagged properly guaranties that the Report or Page will be linked from the General Menu; However, in order to be shown properly it is important to consider:  

- An **icon** must be defined. It should be a 16px image , it is recommended to follow existing look-and-feel, this will be the icon shown in the menu
- A **title** must be defined and it will be used as the text of the link
- The good practice is that the target should not depend on receiving a parameter. Parameter could be defined, but normally those parameters would be optional. After all, these are **generic** pages and reports
