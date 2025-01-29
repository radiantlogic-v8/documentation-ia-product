---
title: Authentication and authorization configuration
description: Authentication and authorization configuration
---

# Authentication and authorization configuration

All resources provided by the current Identity analytics solution installed using docker-compose are protected by the Authentication and Authorization server.
It is implemented with [RedHat Keycloak](https://www.keycloak.org). This chapter describes how to implement supported use cases. For detailed explanations about options, please refer to the [official documentation](https://www.keycloak.org/docs/latest/server_admin/index.html).

## Supported Identity Providers

The current Identity analytics solution installed using docker-compose supports:

- **Local Directory**: this the default identity provider. Users, its credentials and groups/roles are stored in the Keycloak's internal repository.
- **User Federation with Active Directory**: the user federation allows Keycloak to delegate authentication and authorization based on groups to Active Directory through LDAP(s) v3 protocol.
- **Identity Provider with Azure Active Directory**: Azure AD will provide users authentication and authorization using OpenID Connect or SAML v2 protocol .

## Static built-in roles

This package comes with default configuration (clients, roles, etc.). The roles provided by Identity analytics are:

- **user**: standard user. It allows access to the Governance Portal user interface
- **designer**: allows the design of Mashup Dashboards in the Governance Portal user interface
- **technicaladmin**: allows the Technical Administration in the Governance Portal user interface and miscellaneous technical interfaces (configuration and controller UIs)
- **functionaladmin**: allows the Functional Administration in the Governance Portal user interface

All these roles are defined in the client `apisix` client of the `Brainwave` realm.

> [!warning] If you change the configuration of those roles or delete them, the Identity analytics solution will not work anymore.

## Keycloak Administration Console

You first need to get the initial password of user `setup`.  
There are 2 cases:

1. Not mail setup has been done during install and before first start
2. Email configuration has been setup and email has been assigned to `setup` user

In the first case, the default password of `setup` user is `Brainwave@2023`. After successful login, you are invited to change it.

> The new password must match the initial Password Policy:

- History: 10
- Force change password after: 90 days
- Minimum length: 8
- Minimum upper case: 1
- Minimum lower case: 1
- Minimum digit: 1
- Minimum special: 1
- Username and email as password: forbidden

In the second use case, the password is randomly generated during first startup.
To retrieve the password of `setup` user please follow steps.

- Go to https://{{HOSTNAME}}/config and login with `setup` account
- Click on *Forgot password* on login screen
- Enter the email of `setup` user
- Keycloak sends you an email with reset password link (that expires in 1 hour)
- With that link, you will be invited to set a new password compliant with the default password policy (see above)

## Self-service user administration

Keycloak can notify end-users related to accounts and credentials lifecycle.  
The email configuration in Keycloak is managed by the Identity Analytics configuration UI (`https://{{HOSTNAME}}/config`)

> Any changes in Keycloak, will be erased at newt platform restart

## Local Directory configuration

There is nothing to do to use of this directory. Simply, declare users inside the `Brainwave` realm using the [administration console](https://www.keycloak.org/docs/latest/server_admin/index.html#using-the-admin-console).

All users declared in this directory must authenticate with the email or username and local credentials.

> Note that you cannot declare a user (with same username or email) in this directory that already exists in User Federation or Identity Provider.

To create a new user granted to this directory, follow the steps below.

Once connected to the Keycloak Administration Console:

1. Select the `Brainwave` realm from the dropdown box.
2. Click on the `Users` menu.
3. Then click on the button `Add user`.
4. Enter values for the `username` (not updatable after creation) and `email` fields. They can have the same values or different values. It depends how your Identity Analytics iGRC project is configured (**TODO**: `make reference to something out of this chapter that explains portal view is configured. br_portal_identity?`). This is the login used by the end-user when accessing the user interfaces such as Governance Portal.
5. Enter other fields like `First name` and `Last name`.
6. Choose `Update Password` option in the select box `Required user actions` so that end-user must change the initial password during first connection.
7. Click on the `Create` button.
8. Once user successfully created, go the `Credentials` tab to setup initial password.
9. Click on `Set password` button.
10. Enter `Password` and `Password confirmation`.
11. Set `Temporary` field to `On` so that end-user must enter its own password.
12. Then click save.
13. Click on `Role mapping` tab.
14. Click on `Assign role` button.
15. Click on `Filter by role` field and choose `Filter by clients`.
16. In the field `Search by role name`, enter `apisix` to select Identity Analytics static built-in roles to assign.
17. Check the roles to assign (ex. `user`)
18. Then click on `Assign` button.

## Active Directory user federation

The user federation with Active Directory allows Keycloak to delegate authentication and authorization based on groups to Active Directory through LDAP(s) v3 protocol.

The user federation is also known as external user storage. To support all the features of Keycloak, user information is stored locally except credentials. The User federation regularly synchronizes its local storage with Active Directory. See details on [how it works](https://www.keycloak.org/docs/latest/server_admin/index.html#_user-storage-federation).

This section explains how to configure Keycloak to look for users (identity with Active Directory credentials) and groups (for authorization based).

### Prerequisites

To enable Keycloak to query your Active Directory, you must declare a read-only service account granted to traverse the directory tree where your users and groups are located including referrals.

> Don't forget to allow the service account to follow referrals if you have multiple domains and forests.

Enable Active Directory to support LDAP or LDAPs if not yet available

Open route from the Identity analytics solution cluster to Active Directory on port LDAP port (default is 389) or LDAPs port (default 686).

### User Federation required information

Get from your Active Directory administrator:

- [ ] `LDAP Host`: Domain Controller host name or IP
- [ ] `Service Account Bind DN`: Service Account distinguished name.
- [ ] `Service Account Bind Credentials`: Service Account credentials.
- [ ] `Users DN`: distinguished name from which users are searched for. If users that you will grant to Identity analytics solution are located in distinct nodes, choose the root DN common to those nodes. It is not possible to enter more than one DN to search for users.
- [ ] `Username LDAP attribute`: name of the LDAP attribute which is mapped to Keycloak username. For instance `cn` or `sAMAccountName`.
- [ ] `User search scope`: possible values are `One Level` or `Subtree`. First option means that users are search at the `Users DN` level. Second options means that users are searched whatever the level from `Users DN`.
- [ ] `Groups DN`: distinguished name from which groups are searched for. If groups assigned to LDAP users are located in distinct nodes, choose the root DN common to those nodes. It is not possible to enter more than one DN to search for groups.
- [ ] `Group name LDAP attribute`: name of the LDAP attribute which is mapped to Keycloak username. For instance `cn` or `sAMAccountName`.

### User Federation authentication

Once connected to the Keycloak Administration Console:

1. Select the `Brainwave` realm from the dropdown box.  
2. Select `User Federation` from the menu.  
3. Click on `Add new provider`dropdown list and choose `LDAP`.  
4. Enter **General options** and **Connection settings**  
    - `Console display name`: a name to identify your Active Directory users repository.
    - `Vendor`: choose `Active Directory`
    - `Connection URL`: LDAP connection URL of ACtive Directory. It is prefixed by `ldap://` or `ldaps://` followed by the `LDAP Host`. See [gathered information](#user-federation-required-information).
    - `Enable StartTLS`: if you choose LDAPS
    - `Use Truststore SPI`: choose option `Only for ldaps`
    - `Connection timeout`: LDAP connection timeout in milliseconds. For instance, 1000.
    - `Bind type`: select `simple` to connect to Active Directory with LDAP service account and password.
    - `Bind DN`: service account distinguished name. See [gathered information](#user-federation-required-information).
    - `Bind credentials`: service account credentials name. See [gathered information](#user-federation-required-information).
5. Enter **LDAP searching and updating** fields
    - `Edit mode`: choose the `READ_ONLY` value so that LDAP attributes are one-way synched to Keycloak.
    - `Users DN`: distinguished name from which users are searched for. See [gathered information](#user-federation-required-information). For example, 
    - `Username LDAP attribute`: choose the LDAP attribute in Active Directory that fills the Keycloak username. See [gathered information](#user-federation-required-information). For example, the common name `cn`.  
  
    > [!warning]  
    > If you are using standard *iGRC project configuration*, `Username LDAP attribute` must be equal to `sAMAccountName` (same as `username` attribute mapper defined later in this section).  
    >
    > If user dos not connect with `sAMAccountName` or `email`, then you must adapt the configuration *iGRC project configuration*, the provided iGRC view (`br_portal_identity`), for username to match the corresponding login in the right repository.

    - `Search scope`: recursive or one level user search. See [gathered information](#user-federation-required-information). For example, `Subtree`.
    - `Read timeout`: 
    - `Pagination`: set to `On` in case of large number of users.
6. Enter **Synchronization settings** fields
    - `Import users`: set to `On`. Keycloak will import users at after configuration terminated.
    - `Batch size`: import `1000` users per transaction.
    - `Periodic full sync`: set to `On`. Execute a full synchronization from Active Directory to Keycloak.
    - `Full sync period`: full synchronization every `86400` seconds (24 hours).
    - `Periodic changed users sync`: set to `On`.  
    - `Changed users sync period`: synchronize changes in Active Directory to Keycloak every `14400` seconds (4 hours).
7. Enter **Cache settings** fields
    - `Cache policy`: MAX_LIFESPAN
    - `Max lifespan`: `3600` milliseconds
8. Enter **Advanced settings** fields
    - `Trust email`: set to `On`. Active Directory is considered as authoritative source for email and verification is not required.
9. Click `Save` button

### LDAP over SSL

> [!warning] This configuration is not yet supported.

### User Federation group mapping

Once connected to the Keycloak Administration Console, do the following steps to map authorizations to Active Directory groups.

When you created the User Federation in the previous section, Keycloak created default mappers.

| Mapper Name           | Mapper Type                      |
| --------------------- | -------------------------------- |
| creation date         | user-attribute-ldap-mapper       |
| email                 | user-attribute-ldap-mapper       |
| full name             | full-name-ldap-mapper            |
| groups                | group-ldap-mapper                |
| last name             | user-attribute-ldap-mapper       |
| modify date           | user-attribute-ldap-mapper       |
| MSAD account controls | msad-user-account-control-mapper |
| username              | user-attribute-ldap-mapper       |

You will now check the configuration to create a new mapper for the Active Directory groups.

1. Select the `Brainwave` realm from the dropdown box.
2. Select `User Federation` from the menu.
3. Click on the card with the `Console display name` you have chosen in the previous section.
4. Click on `Add mapper` button.
5. Enter the general mapper fields
  - `Name`: the mapper will be named `groups`.
  - `Mapper type`: the type to map LDAP group is `group-ldap-mapper`.
6. Enter the `Group LDAP mapper` fields
  - `LDAP Groups DN`: distinguished name from which groups are searched for. See [gathered information](#user-federation-required-information).
  - `Preserve Group Inheritance`: set to `Off`. It is mandatory to disable this option if you have multiple parent groups for a group. This is often the case with nested groups.
  - `User Groups Retrieve Strategy`: choose `GET_GROUPS_FROM_USER_MEMBEROF_ATTRIBUTE` option
  - `Drop non-existing groups during sync`: set to `On`

### Synchronize Users and Groups

Once connected to the Keycloak Administration Console, do the following steps to synchronize Active Directory users and groups to Keycloak.

1. Select the `Brainwave` realm from the dropdown box.
2. Select `User Federation` from the menu.
3. Click on the card with the `Console display name` you have chosen in the previous section.
4. In the upper right dropdown list, select `Sync changed users` Action.

> When you finished the configuration above, the full synchronization is executed and may take long time depending on number of users and groups to synchronize.  
> `Remove imported` action with READ_ONLY edit mode (and with read-only service account) has no effect. Neither in Active Directory, neither in Keycloak. No users or groups are deleted from both sides even menu entry is enabled.

### Roles group mapping

When the synchronization is finalized, you will be able to assign Identity analytics static built-ins roles (Keycloak `Client Role`) to Active Directory groups.

#### Example

When an Active Directory user is member of an Active Directory group (for instance `BW_USERS`), the user will be granted to access (`user`) the Governance Portal user interface.

Once connected to the Keycloak Administration Console, do the following steps to assign a set of roles when an Active Directory user is member of an Active Directory group.

1. Select the `Brainwave` realm from the dropdown box.
2. Select `Groups` from the menu.
3. Select the Active Directory group (ex. `BW_USERS`)
4. Click on `Role mapping` tab.
5. Click on `Assign role` button.
6. Click on `Filter by roles` field and choose `Filter by clients`.
7. In the field `Search by role name`, enter `apisix` to select Identity Analytics static built-in roles to assign.
8. Check the roles to assign (ex. `user`)
9. Then click on `Assign` button.

## Azure Active Directory identity provider

This feature is based on [Identity Broker](https://www.keycloak.org/docs/latest/server_admin/index.html#_identity_broker) available in Keycloak.

In Keycloak, you can integrate with two main types of Identity Provider, depending on the security protocol supported by Identity Provider

- SAML v2.
- OpenID Connect v1.0.

### OpenID Connect protocol

#### OIDC Prerequisites

Ask your Azure Active Directory Administrator to create a new `App Registration` with the following properties

- `Redirect URI`: this is the address of Keycloak instance. This URI looks like `PROTOCOL`://`DNS_SERVICE_NAME`/auth/realms/brainwave/broker/`ALIAS`/endpoint where
  - `PROTOCOL` is http or https depending on your deployment configuration
  - `DNS_SERVICE_NAME` is the DNS of the Identity analytics solution cluster
  - `ALIAS` is the unique identifier set in Keycloak to this identity provider (remember it for later configuration). We suggest to provide a string that represents the Identity Provider without space or special characters. For instance, `bw-aad-oidc` for Identity Analytics Azure Active Directory using OpenID Connect.
- `Token configuration`: ask for optional groups claim with properties
  - Add `Security groups`.
  - Add `Group ID` in Access Token.

Authorizations in Azure Active Directory are supposed to be assigned using security groups. So ask your Azure Active Directory Administrator to create new groups that will be mapped later against static built-in roles

- `Technical Administrator` group
- `Functional Administrator` group
- `Standard User` group
- `Designer` group

Finally the group `claims` should be configured in the `token configuration`. If necessary add a group claims and customize the token properties to `Group ID`.  

#### Configure Identity Provider with OpenID Connect

When the administrator finalized the `App Registration` configuration and the groups creation in Azure Active Directory, gather the following information  

- `Application (Client) ID` <a id="oidc-aad-client-id">
- `Client Secret` <a id="oidc-aad-client-secret">
- Group ID for each of Active Directory group
- `OpenID Connect Metadata Document` <a id="oidc-aad-discovery-endpoint">

Once connected to the Keycloak Administration Console, do the following steps to configure the Identity Provider, either using OpenID connect or SAML protocol.

1. Select the `Brainwave` realm from the dropdown box.
2. Select `Identity providers` from the menu.
3. Click on `Add provider` button and select `OpenID Connect v1.0` option.
4. Fill in `General options` section
    - `Alias`: this is the value you provided to your Azure Active Directory (see `Redirect URI`).
    - `Display name`: Enter the display name that will be displayed on login user interface.
5. Fill in `OpenID Connect settings`
    - `Discovery endpoint`: this value was provided by your Azure Active Directory (see [OpenID Connect Metadata Document](#oidc-aad-discovery-endpoint)). If the value is valid, you'll see a green checkbox at the end of the URL and the section `Show metadata` is filled with information downloaded from the Identity Provider.
    - `Client authentication`: choose `Client secret sent as post` option.
    - `Client ID`: this value was provided by your Azure Active Directory (see [Application (Client) ID](#oidc-aad-client-id)).
    - `Client Secret`: this value was provided by your Azure Active Directory (see [Client Secret](#oidc-aad-client-secret)).
6. Click on `Add` button
7. Open `Advanced` section to change some parameters
    - `Pass current locale`: set to `On`
    - `Backchannel logout`: set to `On`
8. Change following `Advanced settings`
    - `Trust Email`: set to `On`.
    - `Sync mode`: select `Force` option.
9. Click on `Save` button
10. Click on `Mappers` tab
11. Click on `Add mapper` button. Create as many mappers as Azure Active Directory groups that match static built-in roles

    -  Map `Technical Administrator` group to the role `technicaladmin`. Fill in the mapper form fields
        - `Name`: `Technical Administrator Group Mapper`
        - `Sync mode override`: choose `Force` option to always update Keycloak during login
        - `Mapper type`: choose `Claim to Role` option
        - `Claim`: the claim that contains the Azure Active Directory groups is named `groups`
        - `Claim Value`: this is the group ID of `Technical Administrator` group provided by your Azure Active Directory administrator
        - `Role`
            - Client role: `apisix`
            - Name: `technicaladmin`

    -  Map `Functional Administrator` group to the role `functionaladmin`. Fill in the mapper form fields
        - `Name`: `Functional Administrator Group Mapper`
        - `Sync mode override`: choose `Force` option to always update Keycloak during login
        - `Mapper type`: choose `Claim to Role` option
        - `Claim`: the claim that contains the Azure Active Directory groups is named `groups`
        - `Claim Value`: this is the group ID of `Functional Administrator` group provided by your Azure Active Directory administrator
        - `Role`
            - Client role: `apisix`
            - Name: `functionaladmin`

    -  Map `Standard User` group to the role `user`. Fill in the mapper form fields
        - `Name`: `Standard User Group Mapper`
        - `Sync mode override`: choose `Force` option to always update Keycloak during login
        - `Mapper type`: choose `Claim to Role` option
        - `Claim`: the claim that contains the Azure Active Directory groups is named `groups`
        - `Claim Value`: this is the group ID of `Standard User` group provided by your Azure Active Directory administrator
        - `Role`
            - Client role: `apisix`
            - Name: `user`

    -  Map `Designer` group to the role `designer`. Fill in the mapper form fields
        - `Name`: `Designer Group Mapper`
        - `Sync mode override`: choose `Force` option to always update Keycloak during login
        - `Mapper type`: choose `Claim to Role` option
        - `Claim`: the claim that contains the Azure Active Directory groups is named `groups`
        - `Claim Value`: this is the group ID of `Designer` group provided by your Azure Active Directory administrator
        - `Role`
            - Client role: `apisix`
            - Name: `designer`

### SAML v2.0 protocol

#### Prerequisites

Ask your Azure Active Directory Administrator to create a new `Enterprise Application` for SAML v2 authentication with the following properties:  

- **Entity ID**: `<PROTOCOL>://<DNS_SERVICE_NAME>/auth/realms/brainwave`
- **Consumer Service URL (ACS)**: `<PROTOCOL>://<DNS_SERVICE_NAME>/auth/realms/brainwave/broker/<ALIAS>/endpoint` where
    - `<PROTOCOL>` is http or https depending on your deployment configuration
    - `<DNS_SERVICE_NAME>` is the DNS of the Brainwave package cluster
    - `<ALIAS>` is the unique identifier set in Keycloak to this identity provider (remember it for later configuration). We suggest to provide a string that represents the Identity Provider without space nor special characters. For instance, `bw-aad-saml` for Brainwave Azure Active Directory using SAML.
- **Claims**

| Claim name                                                         | Value                       |
| ------------------------------------------------------------------ | --------------------------- |
| Unique User Identifier (Name ID)                                   | user.userprincipalname      |
| name                                                               | user.userprincipalname      |
| http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenanme    | user.givenname              |
| http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname      | user.surname                |
| http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name         | user.userprincaipalname     |
| http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress | user.mail                   |
| http://schemas.microsoft.com/ws/2008/06/identity/claims/groups     | user.groups [SecurityGroup] |

Authorizations in Azure Active Directory are supposed to be assigned using security groups. So ask your Azure Active Directory Administrator to create new groups that will be mapped later against static built-in roles.

- `Technical Administrator` group.
- `Functional Administrator` group.
- `Standard User` group.
- `Designer` group.

Finally the group `claims` should be configured in the `token configuration`. If necessary add a group claims and customize the token properties to `Group ID`.  

#### SAML v2 configuration

When the administrator finalized the `Enterprise Application` configuration and the groups creation in Azure Active Directory, gather the following information

- List of group IDs for each of Active Directory group.
- `App Federation Metadata Url` <a id="saml-aad-metadata-endpoint">.

Once connected to the Keycloak Administration Console, do the following steps to configure the Identity Provider, either using OpenID connect or SAML protocol.

1. Select the `Brainwave` realm from the dropdown box.
2. Select `Identity providers` from the menu.
3. Click on `Add provider` button and select `SAML v2.0` option.
4. Fill in `General options` section
    - `Alias`: this is the value you provided to your Azure Active Directory (see `Consumer Service URL (ACS)`).
    - `Display name`: enter the display name that will be displayed on login user interface.
5. Fill in `SAML Settings` section
    - `Service provider entity ID`: this is the value you provided to your Azure Active Directory (see `Entity ID`).
    - `Use entity description`: set to `On`.
    - `SAML entity descriptor`: enter the value provided by Azure Active Directory Administrator. See [App Federation Metadata Url](#saml-aad-metadata-endpoint). If the value is valid, you'll see a green checkbox at the end of the URL and the section `Show metadata` is filled with information downloaded from the Identity Provider.
6. Click on `Add` button.
7. Change following `SAML settings`
    - `Backchannel logout`: set to `On`.
    - `NameID policy format`: select `Unspecified` option.
    - `Allow create`: set to `On`.
    - `HTTP-POST binding response`: set to `On`.
    - `HTTP-POST binding for AuthnRequest`: set to `On`.
    - `Signature algorithm`: select `RSA_SHA256` option.
    - `SAML signature key name`: select `CERT_SUBJECT` option.
    - `HTTP-POST binding logout`: set to `On`.
    - `Want AuthnRequests signed`: set to `On`.
    - `Want Assertions signed`: set to `On`.
8. Change following `Advanced settings`
    - `Trust Email`: set to `On`.
    - `Sync mode`: select `Force` option.
9. Click on `Save` button.
10. Click on `Add mapper` button. Create as many mappers as Azure Active Directory groups that match static built-in roles

    -  Map `Technical Administrator` group to the role `technicaladmin`. Fill in the mapper form fields
        - `Name`: `Technical Administrator Group Mapper`
        - `Sync mode override`: choose `Force` option to always update Keycloak during login
        - `Mapper type`: choose `SAML Attribute to Role` option
        - `Attribute Name`: the claim that contains the Azure Active Directory groups is named `http://schemas.microsoft.com/ws/2008/06/identity/claims/groups`
        - `Attribute Value`: this is the group ID of `Technical Administrator` group provided by your Azure Active Directory administrator
        - `Role`
            - Client role: `apisix`
            - Name: `technicaladmin`

    -  Map `Functional Administrator` group to the role `functionaladmin`. Fill in the mapper form fields
        - `Name`: `Functional Administrator Group Mapper`
        - `Sync mode override`: choose `Force` option to always update Keycloak during login
        - `Mapper type`: choose `Claim to Role` option
        - `Attribute Name`: the claim that contains the Azure Active Directory groups is named `http://schemas.microsoft.com/ws/2008/06/identity/claims/groups`
        - `Attribute Value`: this is the group ID of `Functional Administrator` group provided by your Azure Active Directory administrator
        - `Role`
            - Client role: `apisix`
            - Name: `functionaladmin`

    -  Map `Standard User` group to the role `user`. Fill in the mapper form fields
        - `Name`: `Standard User Group Mapper`
        - `Sync mode override`: choose `Force` option to always update Keycloak during login
        - `Mapper type`: choose `Claim to Role` option
        - `Attribute Name`: the claim that contains the Azure Active Directory groups is named `http://schemas.microsoft.com/ws/2008/06/identity/claims/groups`
        - `Attribute Value`: this is the group ID of `Standard User` group provided by your Azure Active Directory administrator
        - `Role`
            - Client role: `apisix`
            - Name: `user`

    -  Map `Designer` group to the role `designer`. Fill in the mapper form fields
        - `Name`: `Designer Group Mapper`
        - `Sync mode override`: choose `Force` option to always update Keycloak during login
        - `Mapper type`: choose `Claim to Role` option
        - `Attribute Name`: the claim that contains the Azure Active Directory groups is named `http://schemas.microsoft.com/ws/2008/06/identity/claims/groups`
        - `Attribute Value`: this is the group ID of `Designer` group provided by your Azure Active Directory administrator
        - `Role`
            - Client role: `apisix`
            - Name: `designer`

11. Click on `Add mapper` button. Create mappers for last name, first name and email from Azure Active Directory to Keycloak user attributes
    - Map `givenname` SAML Attribute to the Keycloak user attribute. Fill in the mapper form fields
        - `Name`: `First name Attribute Mapper`
        - `Sync mode override`: choose `Force` option to always update Keycloak during login
        - `Mapper type`: choose `Attribute Importer` option
        - `Attribute Name`: enter the claim name you supplied to your Azure Active Directory administrator (like `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname`)
        - `Name Format`: select `ATTRIBUTE_FORMAT_URI` option
        - `User Attribute Name`: firstName

    - Map `surname` SAML Attribute to the Keycloak user attribute. Fill in the mapper form fields
        - `Name`: `Last name Attribute Mapper`
        - `Sync mode override`: choose `Force` option to always update Keycloak during login
        - `Mapper type`: choose `Attribute Importer` option
        - `Attribute Name`: enter the claim name you supplied to your Azure Active Directory administrator (like `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname`)
        - `Name Format`: select `ATTRIBUTE_FORMAT_URI` option
        - `User Attribute Name`: lastName

    - Map `emailaddress` SAML Attribute to the Keycloak user attribute. Fill in the mapper form fields
        - `Name`: `Email Attribute Mapper`
        - `Sync mode override`: choose `Force` option to always update Keycloak during login
        - `Mapper type`: choose `Attribute Importer` option
        - `Attribute Name`: enter the claim name you supplied to your Azure Active Directory administrator (like `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress`)
        - `Name Format`: select `ATTRIBUTE_FORMAT_URI` option
        - `User Attribute Name`: email

### Troubleshooting

If the user has "access denied" message after successful IdP login, check the Keycloak user whether it has been granted the appropriate role. If not, verify:  

- Keycloak Identity Provider `Mappers` configuration
    - Do you define one mapper per role?
    - Is the Azure Group ID valid?
    - Does the AAD user member of the expected group?
- Azure Active Directory claims definition with your Administrator
    - Does the group claim correctly defined?
    - Does the `Token Configuration` in AAD `App registration` contain the optional group claim named `groups`?
