---
title: "SAML Authenticators properties"
description: "SAML Authenticators properties"
---

# SAML Authenticators properties

To help you to configure the `SAMLAuthenticators.properties` file, here is detailed description of each property present in this file.

## idpMetadata

A sample is attached and provided below. Content should not be modified.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<md:EntityDescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata" entityID="http://www.okta.com/exk9ccpjwkXZhm7Jd0h7">
 <md:IDPSSODescriptor WantAuthnRequestsSigned="false" protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
 <md:KeyDescriptor use="signing">
 <ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
 <ds:X509Data>
 <ds:X509Certificate>MIIDpDCCAoygAwIBAgIGAVVABKuSMA0GCSqGSIb3DQEBBQUAMIGSMQswCQYDVQQGEwJVUzETMBEG
 A1UECAwKQ2FsaWZvcm5pYTEWMBQGA1UEBwwNU2FuIEZyYW5jaXNjbzENMAsGA1UECgwET2t0YTEU
 MBIGA1UECwwLU1NPUHJvdmlkZXIxEzARBgNVBAMMCmRldi03Mzk2MTkxHDAaBgkqhkiG9w0BCQEW
 DWluZm9Ab2t0YS5jb20wHhcNMTYwNjExMTUxMDM1WhcNMjYwNjExMTUxMTM1WjCBkjELMAkGA1UE
 BhMCVVMxEzARBgNVBAgMCkNhbGlmb3JuaWExFjAUBgNVBAcMDVNhbiBGcmFuY2lzY28xDTALBgNV
 BAoMBE9rdGExFDASBgNVBAsMC1NTT1Byb3ZpZGVyMRMwEQYDVQQDDApkZXYtNzM5NjE5MRwwGgYJ
 KoZIhvcNAQkBFg1pbmZvQG9rdGEuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
 o/TXjaFt6AxIyX0hibz07V9YfboduRBd6tBODE+L5kus7ccm4K+nMncdXZGtTly2niufRGhHFr0B
 FLgWr/KbtGY0oADhM76Bsfi0lIed5Emf4VsiEVg81tHLfr19grATGxvDOdJ4Ui0Ufx2bRk5xJWYJ
 QfENisOd+LsYgao+jE4wiFIQHRrE32+metUa26KVYxQaYKoECV70vIW+GBlRQYkKSWQNvDUliQca
 SXetbuMcmqlmoJxj+0iLVuFdPiy61YUej8WxO/uo9JjNEj3IubH08+hGR9+2C9IxSP4xtKKz58eP
 vi569sCcutrZtydAqUtVF2PTYOUPdjBc+xxogwIDAQABMA0GCSqGSIb3DQEBBQUAA4IBAQAjyQfT
 h7+0as59nS+qLorghrKhg9iM0KHh1ug8UmESagm8bMPBhTZ7RJwlm/fWi1ppsPIYgIo/Je3iGWcG
 yCjC4BjrZnJJRv6/YSOE1WRrgpVHpIi0B69uRKEgRT8py/B15XrmrzJXea+SJlCWjBvOYOkJX8fO
 eC4XKV4PRAYuRiIFR5mzeNhkImKG1zWwcLqk6G7elabAqcMRYa0JEJRYwQQ2q/UdB5oYkJR6taeQ
 IgrVdY2ExoOOmVOfffQIYLn7JPLVb/OOYzwSPUB7BU2UF+FtFsYCzav/SjyevrH359YXScmTyLv3
 VPPZ/70zoPsAW2iDpX4cyk8kzkBdpESE
 </ds:X509Certificate>
 </ds:X509Data>
 </ds:KeyInfo>
 </md:KeyDescriptor>
 <md:NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress</md:NameIDFormat>
 <md:NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified</md:NameIDFormat>
 <md:SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://dev-739619.oktapreview.com/app/brainwavedev739619_test_2/exk9ccpjwkXZhm7Jd0h7/sso/saml"/>
 <md:SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" Location="https://dev-739619.oktapreview.com/app/brainwavedev739619_test_2/exk9ccpjwkXZhm7Jd0h7/sso/saml"/>
 </md:IDPSSODescriptor>
</md:EntityDescriptor>
```

## spMetadata

A sample is both attached and provided below. You **must** edit the file content to update the `URLs` with your server infos.

> Note that `entityID` (sometimes called **Relying Party**) is the name of **your** application (`Service Provider`) that must be registered against your **IdP** (often via registration form).  

The default name is `sp-metadata.xml`:  

```xml
<?xml version="1.0"?>
<md:EntityDescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
                     validUntil="2099-01-19T13:33:05Z"
                     cacheDuration="PT3153600000S"
                     entityID="brainwavesaml">
    <md:SPSSODescriptor AuthnRequestsSigned="false" WantAssertionsSigned="false" protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
        <md:SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"
                                Location="http://localhost:9090/DEMO/logout" />
        <md:NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified</md:NameIDFormat>
        <md:AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
                                     Location="http://localhost:9090/DEMO/acs"
                                     index="1" />
    </md:SPSSODescriptor>
    <md:Organization>
       <md:OrganizationName xml:lang="en-US">Brainwave</md:OrganizationName>
       <md:OrganizationDisplayName xml:lang="en-US">Brainwave GRC</md:OrganizationDisplayName>
       <md:OrganizationURL xml:lang="en-US">http://www.brainwavegrc.com</md:OrganizationURL>
    </md:Organization>
    <md:ContactPerson contactType="technical">
        <md:GivenName>john</md:GivenName>
        <md:EmailAddress>contact@acme.com</md:EmailAddress>
    </md:ContactPerson>
    <md:ContactPerson contactType="support">
        <md:GivenName>jane</md:GivenName>
        <md:EmailAddress>contact@acme.com</md:EmailAddress>
    </md:ContactPerson>
</md:EntityDescriptor>
```

> Remeber to **update** the `location` fields in the example above to match the configured protocol (http or https), the port and the Web Application name that you are using.  
> For instance `http://localhost:9090/DEMO/acs` becomes `https://localhost:8443/MyWebApp/acs`  

## defaultURI

The default `URI attribute` is not mandatory but is strongly encouraged. It must contains a relative `URI` to the main portal page. In the **Identity Analytics** context it is a `/portal` URI.  
When the authentication is **Idp** initiated (the user directly connects to **Okta** and clicks on the **Identity Analytics** icon in the **Okta** portal), the user will be redirected to this `URL` once authenticated.  

A value could be: `/[your application]/portal`.  

> Note that if the authentication is **Sp** initiated, this `URL` will be **ignored**: the user will be redirected to the initially requested `URL` once authenticated.  

## forceURI

The `force URI` attribute is not mandatory. It contains a `relative URI` to the main portal page. In the **Identity Analytics** context it is a `/portal` URI.  
When the authentication is **SP** initiated the user is redirected to this `URL` once authenticated.  

A value could be: `/[your application]/portal`.  

## checkRealm

This attribute accept a boolean value (`0`/`1` or `false`/`true`). If set to `true`, once authenticated through `SAML`, the user will be pushed to the configured `Realm` with a blank password.  
It can be used to declare the **roles locally** while maintaining a delegated authentication through an **Idp**.  

If set to `true`, and if you are using the default `Realm`, you can edit the users roles in the `/conf/tomcat-users.xml` file:  

```xml
<tomcat-users xmlns="http://tomcat.apache.org/xml"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
version="1.0">
    <role rolename="tomcat"/>
    <role rolename="user"/>
    <user username="jdoe@acme.com" password="" roles="tomcat"/>
    <user username="mcarrey@acme.com" password="" roles="tomcat,user"/>
    <user username="jbegood@acme.com" password="" roles="user"/>
</tomcat-users>
```

Note that:

- The **username** value must be equal to the user value provided by the `Identity Provider`
- The **password** value must be empty  

If set to `True`, the **IdP** roles and the default roles will be **ignored**. `checkRealm`is set to **False** by default.  

## defaultRoleList

The `defaultRoleList` attribute is optional, it contains a list of roles who are associated to users who are successfully authenticated by the **identity provider**. The roles are separated by a '`,`'. The default value is `user`.  

## roleAttribute

The role attribute is optional, it contains the name of the `SAML` attribute which contains a list of role as provided back by the **Identity Provider**.  
The attribute is **empty** by default.  

## roleMapping

The role mapping attribute is **mandatory** if `roleAttribute` is set, it must point to a **property** file. The property file is used to dynamically **map the role** names provided by the **identity provider** to local roles names.  
This could be useful to map **identity provider** roles to your **Identity Analytics** application roles (such as `igrc-administrator` for instance).  

The file has to be located in the Tomcat `/conf/` subdirectory. A sample is attached.  

This file is reloaded automatically every 10 minutes.  

## staticRole

The static role attribute is **mandatory**, it must point to a **property** file. The property file is used to declare the users roles.  
The content is in the form `login=roles` where roles is in the form `role1,role2,role3`.  

The file has to be located in the `/conf/` subdirectory. A sample is attached.  

This file is reloaded automatically every 10 minutes.  

## genericUsers

The generic users attribute is optional, if used it can **substitute** an individual with a **generic account**.  
It can be useful if you do not load the **identity provider** content in **Identity Analytics** and thus don't know the users who connect the portal.  

Here is how you can leverage this parameter:  

- Load some fake identities in your **Identity Analytics** ledger (for instance `standard user` and `power user`)  
- Create `standard user` and `power user` as roles in your **Idp** and attach them to your **Idp** users (only one of those roles at a time)  
- Configure the genericUsers attribute with the following value: `standard user,power user`  

We assume here that `John Doe` can connect to **Identity Analytics** and is associated with the `standard user` role:  

- `John Doe` tries to access the **Identity Analytics** instance  
- He is redirected to the **Idp**, he authenticates  
- He is redirected to the **Identity Analytics** instance  
- The `SAML` response is decoded, `John Doe` is assigned the `standard user` role  
- `standard user` is part of the `genericUsers` attribute, `John Doe` will be connected to the **Identity Analytics** instance as the `standard user` identity  

## genericUserPattern

When a generic user is found, this optional parameter can be used to format the user login. `{login}` and `{generic}` can be used and will be dynamically replaced by their corresponding value.  
For instance: if you configure this parameter with `{login} ({generic})`.  
When `jdoe@acme.com` is connecting with the generic user `user` role,  the user returned by the Principal will be:  
`jdoe@acme.com (user)`  

## Downloads

[SAMLAuthenticator.properties](https://download.brainwavegrc.com/index.php/s/zWGEG2MkKrjbktZ/download/SAMLAuthenticator.properties)  
[idp-metadata.xml](https://download.brainwavegrc.com/index.php/s/8LFGDrSx8oMWrkw/download/idp-metadata.xml)  
[rolemapping.properties](https://download.brainwavegrc.com/index.php/s/NSL5SpGRARX2LHB/download/rolemapping.properties)  
[sp-metadata.xml](https://download.brainwavegrc.com/index.php/s/aygkqXTpA4MtAMG/download/sp-metadata.xml)  
[staticroles.properties](https://download.brainwavegrc.com/index.php/s/9bkwpxgGbJoMpEw/download/staticroles.properties)
