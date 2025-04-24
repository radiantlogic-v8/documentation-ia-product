---
title: "Sorting the Results"
description: "Sorting the Results"
---

# Sorting the Results

It is possible to configure a sorting operation on the results of your Audit View via the view's Properties Editor.  
Up to five sorting criteria are possible, which are applied sequentially: 'Sort 2' enables a sub-sort to be carried out on lines for which 'Sort 1' returns the same value, etc.  
It is possible for each attribute to choose the order in which sort operations are carried out. This order is applicable whatever the type of attribute (character string, numeric, Boolean, or date).  

![Sorting the Results](./images/view-sort.png "Sorting the Results")  

> It is highly recommended that sorting operations are carried out at the level of Audit Views and not at the Report level.
> Configuring a sorting operation on an Audit View has the effect of carrying out this operation at the database level, which significantly increases the time taken to generate reports.
