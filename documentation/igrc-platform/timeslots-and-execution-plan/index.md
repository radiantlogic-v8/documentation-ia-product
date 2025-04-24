---
title: "Timeslots and execution plan"
description: "Timeslots and execution plan"
---

# Timeslots and execution plan

## Timeslot status

Here are the allowed timeslot statuses in the database (`timportlog.cstatus`):

- `I`: **I**mport (Sandbox)
- `W`: Active (**W**aiting for validation or **W**orking)
- `C`: **C**urrent
- `A`: **A**rchive
- `D`: Hidden (as good as **D**eleted for portal users)
- `S`: Reserved (not used - yet)

Here are the matching icons for each status:  
![Timeslot status icons](./images/ts_status_icons.png)

### Timeslot specific attributes

Some attributes in the `Ledger` (or data model) are **timeslot specific**.  
See [specific attributes linked to time](../getting-started/index.md#time-management-in-the-data-model).

### iGRC Purge

You can use **igrc_purge.cmd** either with the purge from the technical configuration (`purge` tab), or by passing the timeslot status (one of the values from above).

> For detailed information on the purge, see [purge of timeslots](02-purge-of-timeslots).
