---
title: "LDAP Access"
description: "LDAP Access"
---

# LDAP Access

Identity Analytics's Web Portal relies on the security of the underlying web application server. Basically, Tomcat will be exposed to end users but it will rely on one or multiple LDAP repositories to authenticate and authorize users.

This post details how to rely on `LDAP Directory` for user authentication and authorization.  

Following features will be put in place:  

- AuthN: `LDAP Directory` authentication (login + password)  
- AuthZ: Roles retrieving (account direct groups will be considered as the user roles)  

The schema below represents the cinematic behind this kind of access:

![LDAP access architecture](./images/LDAP_access_architecture.png)

This setting consists of adding a Tomcat `Realm` to process the account authentication on LDAP Directory through LDAP requests. The realm is a standard Tomcat feature, named `JNDIRealm`.  

This realm setting is detailed on the following official Tomcat documentation:  

- For [Tomcat 8.5](https://tomcat.apache.org/tomcat-8.5-doc/realm-howto.html#JNDIRealm)
- For [Tomcat 9.0](https://tomcat.apache.org/tomcat-9.0-doc/realm-howto.html#JNDIRealm)  

The following procedure should work:

- With `Tomcat 8` and `Tomcat 9`
- Under `Windows` and `Linux`

## Prerequisites

To ensure this installation procedure, you should first download some required Identity Analytics `<LDAP_BW_LIB>` library available [here](https://download.brainwavegrc.com/index.php/s/n3qGRqKgtADw4Hn) depending on the Tomcat version installed:

- Tomcat 8: bw-tomcat-8.5-addons.jre8-X.jar
- Tomcat 9: bw-tomcat-9.0-addons.jre8-X.jar

It is also admitted that:

- Tomcat instance is installed and available
- The operator has RW privileges in needed files and folders to proceed to the installation
- Server that hosts the Tomcat can request required LDAP servers in LDAP/LDAPS ports (respectively by default port 389 and 636)

## Configuration procedure

In the following procedure, we will use the variables below:  

|         Variable         |                                            Description                                             |          Example value          |
| :----------------------: | :------------------------------------------------------------------------------------------------: | :-----------------------------: |
| `TOMCAT_INSTALL_FOLDER`  |                                  Tomcat installation root folder                                   |          /etc/tomcat9/          |
|   `TOMCAT_CONF_FOLDER`   |                          Folder that contains Tomcat configuration files                           |        /etc/tomcat9/conf        |
| `TOMCAT_LIB_FOLDER_HOME` |                       Folder that contains all libraries used by the Tomcat                        |     /usr/share/tomcat9/lib      |
|      `LDAP_BW_LIB`       | Brainwave JAVA library used to perform LDAP AuthN/AuthZ. See prerequisites section to retrieve it. | bw-tomcat-9.0-addons.jre8-X.jar |
| `LDAP_ROLE_MAPPING_FILE` |                   File that contains mapping between AD groups and Portal roles                    |     rolemapping.properties      |

### LDAP information retrieving

The first step is to gather some information prior to engage in the configuration.

For each LDAP directory, the client is willing to rely on for the **AuthN** mechanism, you must ask for the following information:

| Property                   | Description                                                                                                                                                                                                                                         |    Example value     |
| :------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------------: |
| `LDAP name`                | Name of the LDAP directory. Does not really matter as long as it allows to identify the LDAP directory (not used in technical files).                                                                                                               |         ACME         |
| `LDAP URL`                 | URL of the LDAP directory to be queried.                                                                                                                                                                                                            | ldaps://acme.com:636 |
| `Service account`          | LDAP service account used to query the LDAP directory. This should be the `distiguishedName` or the `userPrincipalName`.                                                                                                                            |  acme\svc-brw-prod   |
| `Service account password` | Password of the service account used to query the LDAP directory.                                                                                                                                                                                   |         ***          |
| `User base`                | The entry that is the base of the subtree containing users. If not specified, the search base is the top-level context.                                                                                                                             |    DC=acme,DC=com    |
| `User search`              | Pattern specifying the LDAP search filter to use after substitution of the username.                                                                                                                                                                | (samAccountName={0}) |
| `User sub tree`            | The user search scope. Set to **true** if you wish to search the entire subtree rooted at the **User base** entry. Default value is false (requests a single-level search including only the top level).                                            |         true         |
| `Role base`                | The base entry for the role search. If not specified, the search base is the top-level directory context.                                                                                                                                           |    DC=acme,DC=com    |
| `Role name`                | The attribute in a role entry containing the identifier of that role.                                                                                                                                                                               |          cn          |
| `Role sub tree`            | the role search scope. Set to **true** if you wish to search the entire subtree rooted at the **Role base** entry. The default value is **false** (requests a single-level search including the top level only).                                    |         true         |
| `Role nested`              | Enable nested roles. Set to **true** if you want to nest roles in roles. If configured, then every newly found **Role name** and distinguishedName will be recursively tried for a new role search. The default value is **false**.                 |         true         |
| `Role search`              | the LDAP search filter for selecting role entries. It optionally includes pattern replacements "{0}" for the distinguished name and/or "{1}" for the username and/or "{2}" for an attribute from user's directory entry, of the authenticated user. |     (member={0})     |

For each LDAP directory, if the client is willing to rely on for the **AuthZ** mechanism, you must ask for the following information (values indicated are examples):

| LDAP name | Identity Analytics portal role | LDAP group      |
| :-------- | :-------------------- | :-------------- |
| ACME      | user                  | brw-users       |
| ACME      | auditor               | brw-auditors    |
| ACME      | technical admin       | brw-tech-admins |
| ACME      | functional admin      | brw-func-admins |
| ...       | ...                   | ...             |

Where:

- **LDAP name**: name of the LDAP directory, does not really matter as long as it allows to identify the LDAP directory (not used in technical files)
- **Identity Analytics portal role**: role in the Identity Analytics application. The four roles listed in the above table are the IAP standard roles
- **LDAP group**: name of the LDAP group giving the Identity Analytics role to users (in case of authorization process delegated to LDAP). This value MUST be the LDAP group's attribute returned by the LDAP query. This attribute is selected in the previous **AuthN** table, under **Role name** column (the **cn** in our example)

### Tomcat configuration

> If you are under Linux, beware of files and folders rights.

The second step is to configure the LDAP AuthN/AuthZ under the Tomcat:

- Under the `<TOMCAT_LIB_FOLDER_HOME>` folder, add the `<LDAP_BW_LIB>` library

- Open the `<TOMCAT_CONF_FOLDER>/server.xml` file  
  - If present, comment the **UserDatabaseRealm** realm that should be encapsulated under **LockOutRealm** realm  

At this point, depending on the number of LDAP realms you want to configure, apply the corresponding case:

- One LDAP case
- Multiple LDAP case

#### One LDAP

Still under `<TOMCAT_CONF_FOLDER>/server.xml` file. Create a **JNDI** and a **RoleMapping** Realm to configure the connection to the LDAP directory

```xml
<!-- Use the LockOutRealm to prevent attempts to guess user passwords via a brute-force attack -->
<Realm className="org.apache.catalina.realm.LockOutRealm">
  ...
  <Realm className="com.brainwave.tomcat.realm.RoleMappingRealm" reloadPeriod="0" configurationFile="<LDAP_ROLE_MAPPING_FILE>">
    <!-- This is the Realm to which role mapping is applied. -->
    <Realm 
    className="org.apache.catalina.realm.JNDIRealm"
    connectionURL="<LDAP URL>"
    connectionName="<Technical account>"
    connectionPassword="<Technical account password>"
    authentication="simple"
    referrals="follow"
    adCompat="true"

    userBase="<User base>"
    userSearch="<User search>"

    userSubtree="<User sub tree>"
    roleBase="<Role base>"
    roleName="<Role name>"
    roleSubtree="<Role sub tree>"
    roleNested="<Role nested>"
    roleSearch="<Role search>"
    />
  </Realm>
  ...
<!-- End of LockOutRealm section -->
</Realm>
```

> All above configuration values should have been retrieved during the `LDAP information retrieving` section.

> **JNDIRealm** must be part of the **RoleMappingRealm**, itself part of the **LockoutRealm**.

Once realms configuration are done, the next step is to create the role mapping file:

- Under `<TOMCAT_CONF_FOLDER>` folder  
  - Create a `<LDAP_ROLE_MAPPING_FILE>` file
  - Fill it accordingly to your context and following the format below

```properties
<LDAP_ROLE1>=<PORTAL_ROLE1>
<LDAP_ROLE2>=<PORTAL_ROLE2>
...
<LDAP_ROLEn>=<PORTAL_ROLEn>
```

> Identity Analytics needs at least the **user** specific role to be mapped. Others default IAP portal roles are detailed in the [Web Portal Roles](https://developer.radiantlogic.com/ia/iap-2.0/identity-analytics/integration-guide/03-webportal-roles/) article.  

#### Multiple LDAP

Still under `<TOMCAT_CONF_FOLDER>/server.xml`:  

- Create as many as necessary **JNDI** and **RoleMapping** Realms to configure the connection to all LDAP directories

```xml
<!-- Use the LockOutRealm to prevent attempts to guess user passwords via a brute-force attack -->
<Realm className="org.apache.catalina.realm.LockOutRealm">
  ...
  <Realm ClassName="org.apache.catalina.realm.CombinedRealm">
    <!-- First JNDI Realm for first LDAP directory -->
    <Realm
      className="org.apache.catalina.realm.JNDIRealm"
      connectionURL="<LDAP URL>"
      connectionName="<Technical account>"
      connectionPassword="<Technical account password>"
      authentication="simple"
      referrals="follow"
      adCompat="true"

      userBase="<User base>"
      userSearch="<User search>"

      userSubtree="<User sub tree>"
      roleBase="<Role base>"
      roleName="<Role name>"
      roleSubtree="<Role sub tree>"
      roleNested="<Role nested>"
      roleSearch="<Role search>"
    />
    <!-- Second JNDI Realm for second LDAP directory -->
    <Realm
      className="org.apache.catalina.realm.JNDIRealm"
      connectionURL="<LDAP URL>"
      connectionName="<Technical account>"
      connectionPassword="<Technical account password>"
      authentication="simple"
      referrals="follow"
      adCompat="true"

      userBase="<User base>"
      userSearch="<User search>"

      userSubtree="<User sub tree>"
      roleBase="<Role base>"
      roleName="<Role name>"
      roleSubtree="<Role sub tree>"
      roleNested="<Role nested>"
      roleSearch="<Role search>"
    />
    ...
    <!-- Nth JNDI Realm for nth LDAP directory -->
    <Realm
      ClassName="org.apache.catalina.realm.JNDIRealm"
      ...
    />
  </Realm>

  <!-- First Role mapping configuration -->
  <Realm className="com.brainwave.tomcat.realm.RoleMappingRealm" reloadPeriod="0" configurationFile="<LDAP_ROLE_MAPPING_FILE>_1">
  <!-- Second Role mapping configuration -->
  <Realm className="com.brainwave.tomcat.realm.RoleMappingRealm" reloadPeriod="0" configurationFile="<LDAP_ROLE_MAPPING_FILE_2>">
  ...
  <!-- Nth Role mapping configuration -->
  <Realm className="com.brainwave.tomcat.realm.RoleMappingRealm" reloadPeriod="0" configurationFile="<LDAP_ROLE_MAPPING_FILE_N>">
  </Realm>
  ...
<!-- End of LockOutRealm section -->
</Realm>
```

> All above configuration values should have been retrieved during the `LDAP information retrieving` section.

> **JNDIRealm** must be part of the **CombinedRealm**, itself part of the **LockoutRealm**.

> If **RoleMappingRealm** are used, those realms MUST be declared outside of the **CombinedRealm**.

Once realms configuration are done, the next step is to create the role mapping file:

- Under `<TOMCAT_CONF_FOLDER>` folder  
  - Create a `<LDAP_ROLE_MAPPING_FILE>` file
  - Fill it according to your context and following the below format

```properties
<LDAP_ROLE1>=<PORTAL_ROLE1>
<LDAP_ROLE2>=<PORTAL_ROLE2>
...
<LDAP_ROLEn>=<PORTAL_ROLEn>
```

> You can create as many mapping files as required by your realms.

> Identity Analytics needs at least the **user** specific role to be mapped. Others default IAP portal roles are detailed in the [Web Portal Roles]({{ site.baseurl }}{% link docs/ias/integration-guide/web-portal-roles.md %}) article.

## Debug

To debug the authentication settings, you can add the following information at the bottom of your `<TOMCAT_CONF_FOLDER>/logging.properties`:

````properties  
# Authentication Realm debug
org.apache.catalina.realm.level = ALL
org.apache.catalina.realm.userParentHandlers=true
org.apache.catalina.authenticator.level=ALL
org.apache.catalina.authenticator.userParentHandlers=true
com.brainwave.tools.RoleMappingRealm.level = ALL
````

## Examples

### JNDI and RoleMapping realms for one LDAP  

```xml  
<Realm className="com.brainwave.tomcat.realm.RoleMappingRealm" reloadPeriod="10" configurationFile="mappings_sample_ad_group.properties">
  <Realm 
    className="org.apache.catalina.realm.JNDIRealm"
    connectionURL="ldaps://192.168.217.136:636"
    connectionName="tomcat-jndi@demo.local"
    connectionPassword="Password01"
    authentication="simple"
    referrals="follow"
    adCompat="true"

    userBase="dc=demo,dc=local"
    userSearch="(samAccountName={0})"
    userSubtree="true"

    roleBase="dc=demo,dc=local"
    roleName="cn"
    roleSubtree="true"
    roleNested="true"
    roleSearch="(member={0})"
  />
</Realm>
```

### Role mapping  

```properties  
user = BW_Users
technicaladmin = BW_Managers
```
