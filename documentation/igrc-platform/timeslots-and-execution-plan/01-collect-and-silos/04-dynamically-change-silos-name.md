---
title: "Dynamically change the Silo name"
description: "Dynamically change the Silo name"
---

# Dynamically change the Silo name

It is possible to change the silo name at any time in a collect line using a small piece of Javascript, or the dedicated modification action. This change will only affect the current collect line. If you wish to to override the silo name globally from the silo configuration please see [here](./03-iteration) for more information.  

Locally changing the name of the silo can be useful when you need to compute the silo name from a path or from one attribute of the dataset, or if the same file has to be collected into several silos. In order to do this:  

1. Use the the action "change the name of the silo" in the update component
![Change the name of the silo](./images/silo_name.png "Change the name of the silo")
2. Add a call to a Javascript function in an Update filter. In this function, add something along the lines of:  
`config.siloName = 'my silo name';`  
