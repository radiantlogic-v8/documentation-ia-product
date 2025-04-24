---
title: "Using Silo constants"
description: "Using silo constants"
---

# Using Silo constants

In a collect line, we often need to have constants in attributes to map to targets. As an example, in the account target, an attribute containing the repository code is required. To facilitate the creation of your collect lines, in the silo definition, there is a section that allows you to declare some fixed constants. All these fields are optional however these can be extremely useful especially in the case of iteration. As a results the referential can be dynamically created as a function of the silo name. This would allow you to have a different repository for each Active Directory domain, for example.  

![Change the name of the silo](./images/studio_silo_constants.png "Change the name of the silo")

In the collect line, all the constants are automatically added to your main dataset. Your dataset contains the following attributes, the name of the attribute is shown as a tooltip in the silo editor (see caption above) :  

```properties
_APPLICATION_CODE_
_APPLICATION_DISPLAYNAME_
_APPLICATION_TYPE_
_APPLICATION_CRITICITY_
_REPOSITORY_CODE_
_REPOSITORY_DISPLAYNAME_
_ASSET_CODE_
_ASSET_DISPLAYNAME_
```

In the account target of the collect, when mapping an attribute to the repository code, you can select a constant from the above list. Of course, if you want to declare a constant not related to application, repository or asset, you will need to create a computed attribute in the discovery to add this constant or use a modification filter in the collect line to add the attribute with the constant value.
