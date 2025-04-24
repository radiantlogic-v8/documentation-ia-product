---
title: "Basic form Access"
description: "Basic form Access"
---

# Basic form Access

In `Basic` authentication, if you try to hit a web application protected URL and you are currently unauthenticated:

- A popup window appears and you enter a particular **username/password**, which gets sent to Tomcat
- Tomcat checks to see that the sent **username** and **password** match a **user** entry in `tomcat-users.xml`
- If we have a match (username/password), the user retrieves associated static roles and gains access to the application resource

The below schema shows you the cinematic behind this kind of access:

![Basic access architecture](./images/basic_access_architecture.png)

The following procedure should work:

- With Tomcat 8 and Tomcat 9
- Under `Windows` and `Linux`

## Prerequisites

To ensure this installation procedure, it is admitted that:

- Tomcat instance is installed and available
- The operator has RW privileges in needed files and folders to proceed to the installation

## Installation procedure

In the following procedure, we will use below variables:

|        Variable         |           Description           | Example value |
| :---------------------: | :-----------------------------: | :-----------: |
| `TOMCAT_INSTALL_FOLDER` | Tomcat installation root folder | /etc/tomcat9  |

The Basic form authentication uses the `UserDatabaseRealm` to authenticate the user and retrieve static roles.

To do so, Tomcat configuration should be set as this:

- In `<TOMCAT_INSTALL_FOLDER>/conf/server.xml`, a resource must be declared and encapsulated in the `Global JNDI Resources` section

```xml
<GlobalNamingResources>
...
    <Resource name="UserDatabase" auth="Container"
        type="org.apache.catalina.UserDatabase"
        description="User database that can be updated and saved"
        factory="org.apache.catalina.users.MemoryUserDatabaseFactory"
        pathname="conf/tomcat-users.xml" />
...
</GlobalNamingResources>
```

> Usually, in a standard Tomcat installation, it is already set as this.

- The `pathname` variable must point to a file which contains all portal users credentials

```xml
<tomcat-users>
...
    <user username="<LOGIN>" password="<PASSWORD>" roles="<ROLE1, ROLE2, ..., ROLEn>"/>
...
</tomcat-users>
```

- After declared, the realm `UserDatabaseRealm` must be declared in the `<Engine>` section

```xml
<Engine name="Catalina" defaultHost="localhost">
...
    <Realm className="org.apache.catalina.realm.UserDatabaseRealm"
        resourceName="UserDatabase"/>
...
</Engine>
```

> [!warning] The **LOGIN** must belong to an existing `Account` in the last loaded timeslot reconciled to an `Identity`.  
> To avoid clear password in the flat file, you can hash them (see [here](../02-parametrization/index#encrypt-passwords)).
