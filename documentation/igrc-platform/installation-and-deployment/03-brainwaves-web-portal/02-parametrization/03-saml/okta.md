---
title: "OKTA application declaration"
description: "OKTA application declaration"
---

# OKTA application declaration

> [!warning] The information listed here is provided as an example only. This methodology is not supported by Identity Analytics, but has been tested.

Connect to your Okta admin console and add a new application.  
Select `SAML 2.0` Sign on method.  

![okta1](./images/okta1.png "okta1")

Fulfill the general settings: the nick name of your Brainwave project, a logo, ...  

![okta2](./images/okta2.png "okta2")

Fulfill the SAML attributes:  

The **SAML URI** is `/acs` within your Brainwave portal. For instance, if your deployment is `https://myhost/mybrainwaveapp`.  
The **SAML URL** to use will be `https://myhost/mybrainwaveapp/acs`.  

The **Audience URI** is `brainwavesaml`, it can be updated if needed (see below).  

![okta3](./images/okta3.png "okta3")

Keep the default parameters in the advanced settings.  

![okta4](./images/okta4.png "okta4")

If you want to propagate roles from the Identity Provider you need to fulfill the `group attribute statements`.  
The name will contain the name of the `SAML` attribute which will contain the groups, the filter will select the groups to send to the Brainwave instance amongst the total list of user groups.  

![okta5](./images/okta5.png "okta5")

Once the configuration is done, click on `Identity Provider metadata` to download the idp configuration. Rename the file to `idp-metadata.xml`.  
You will use it to declare your **Okta** instance in **Brainwave**.  

![okta6](./images/okta6.png "okta6")

Assign the application to an **Okta** user, it should appear in his menu.  

![okta7](./images/okta7.png "okta7")
