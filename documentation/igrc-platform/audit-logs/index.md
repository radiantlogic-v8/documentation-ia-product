---
title: Audit Logs
Description: Documentation related to audit logs configuration and usage
---

# Audit logs

## Definition and Purpose of Audit Logs

Identity Analytics helps you gain a holistic view of the assets of your company and the people who are interacting with them.  
This includes:  

- People and organizations
- IT assets such as applications and shared files
- Access rights
- Entitlements
- Policies
- Usages
- and now **Audit logs.**

By automatically collecting and consolidating all application-based audit logs, Identity Analytics helps you answer questions related to **Who has done what and when** , such as the following:  

- Who has read/deleted this sensible file during the last month?
- What were the files accessed by John Doe 3 months ago?
- What transactions have been performed by John Doe on the payment system?
- Who changed the CEO password on Active Directory?

Getting answers to these questions will help you address the following concerns:  

- Quickly provide answers your auditors requests regarding data access
- Rationalize your security configurations
- Pinpoint proven risks on your data
- and Mitigate potential risks on fraud and data theft.

Using the powerful and flexible extraction and collect capabilities of RadiantOne, audit logs can collect virtually any type of log events from any source, ranging from file access logs, directory administration logs, ERP usage and administration log, and so on. Heterogeneous log events are managed in a unified manner, and without losing any information from the original event.

## How to Use Audit Logs

Audit logs are accessible to authorized users and can be searched according to different criteria directly from the web interface. The search results provide comprehensive information on the actions taken.
This is a typical audit log multi-criteria search page:

![Audit Log](../audit-logs/images/1.png "Audit Log")

Audit logs can also be used as a data source to consolidate Usage metrics in the Identity Ledger.
Identity Ledger's Usage metrics allow aggregating audit log events and correlating them to Identity Ledger elements (organizations, people, etc.) to provide powerful analytics such as the following:  

- Are there people who are not part of the HR department and who accessed sensitive HR data on SharePoint?
- Are there people who are not part of the IT support team and who connected during the week end to reset passwords?
- Are there traders who came in trading during their holidays?
- Are there toxic permission combinations who were actually used during the last period (such as payment fraud pattern)?
- Which transactions/permissions are never used?
- Which accounts are never used?

Usage metrics are leveraged in Identity Analytics' user behavior analytics in order to help you "find the needle in the haystack" and identify abnormal behaviors through peer groups analysis.  

This chapter explains how to configure, collect and work with Audit Logs in RadiantOne solutions.
