---
title: Introduction to Business Views
Description: Documentation related to Business Views
---

# Business Views

## Introduction

Business views are a new concept introduced in the product as of version 2017.

During the project lifecycle, the customer often wants to adapt pages or reports to his specific needs or asks for new reports. The work needed to produce these pages or reports is split into two technical parts :

- The data query (_i.e._ the view in the Identity Analytics architecture). This phase is used to configure what data is shown.
- The presentation (_i.e._ the page or report in the Identity Analytics architecture). This phase is used to configure how data is shown.

The best practice is to address the filtering and computation phases (what data to show) with views using criteria and computed attributes. Depending on the complexity of the customer need, views may not offer enough features to produce the data expected by the page or the report. In such cases, part of the filtering or computation must be done in the pages or in the reports. Both the Pages language and Birt support a type of dataset to make application joins (compared to database joins) or trends. Typically, this kind of dataset is an application logic which could be called business logic.

Integrating business logic into the reports or the pages has some drawbacks. If both a page and a report are needed to display the same data, two implementations have to be done because reports and Pages offer incompatible tools to do the same thing.

As a result, a new concept has been introduced to handle these use cases and keep the Pages and reports as simple as possible without application logic but only presentation. This new concept has been called **business views**.

To differentiate the various types of views we will name the normal views **ledger views**.

- Ledger views are used to send queries to the database. In these views almost everything is handled by the database itself (joins, filtering, aggregations, sort,...)
- Business views are used to consolidate data, compute trends,.. in memory. This implementation detail is very important and will be covered in the optimization chapter.

> A Business view can be based on a Ledger view, a log view or another Business view indifferently.

Before dealing with the usage and configuration details of business views, let's review the typical use cases where they come in handy.

## Multiple counts  

Multiple counts can not be returned by a ledger view. For example if we want to get a list of identities and, for each one, get the number of accounts, the number of groups, the number of applications, the number of organizations,... A ledger view can only return one count.  
Business views can be used to call several ledger views, each one returning a counter (number of accounts, number of groups, ...). The business view joins the data queried from the database using ledger views on the application level. The output is a list of identities with several counters.

## Handling Duplicate entries  

Depending of the joins used in ledger views entries can be duplicated. For example, the list of identities with their organizations can generate several lines if an identity works in two different organizations.
If the customer wants one and only one line for each identity and wants to display a list of organization in a column (organization codes separated by coma), then a business view can be used to consolidate the duplicated lines and build a string of the multiple organization codes.

## Trends  

Trends are another hot topic not covered by ledger views. It is possible to get trends using the Pages language but now business views bring this feature to both the Pages and the reports.
Business views provide a way to compute several trends and add attributes to be used in the presentation layer.

## Timeslot comparisons  

Producing comparisons between timeslots is quite difficult to do when using ledger views. A typical example would be to list the accounts that have been granted access to a specific folder on a remote share and for each account display if it is new or if it has been deleted in the last timeslot.  
With Business views this is just a matter of specifying 2 timeslots. The view adds a new attribute containing the status for each account to know if it has been added, deleted or if it exists in both timeslots.

## Negative rights  

The only method to handle negative rights is to use application logic along with exclusions. Business views offer an exclusion feature so that you can compute positive rights (using a ledger view) and remove negative rights (read from another ledger view).

## Highlight changes  

Another example is to display a list of accounts with some attributes and show in bold the attribute values that has changed since the previous timeslot. Ledger views cannot automatically add flags for each attribute to know if it has changed. Using business views it is just a comparison of 2 timeslots of the same ledger view associated to computed attributes.

> All these examples show that business views use the output of the Ledger views to transform data or compute new information.

A number of features have been integrated in the business views but there is no limit to the number of use cases that can be addressed. When a feature is not available in the business views, you can still expand the business views with Javascript.
