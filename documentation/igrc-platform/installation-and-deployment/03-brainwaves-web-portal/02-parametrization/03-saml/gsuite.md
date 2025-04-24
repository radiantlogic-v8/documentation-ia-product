---
title: "G-Suite application declaration"
description: "G-Suite application declaration"
---

# G-Suite application declaration

> [!warning] The information listed here is provided as an example only. This methodology is not supported by Identity Analytics, but has been tested.

Open your **Google suite** admin console and click on `applications`.  

![Console d'administration](./images/gsuite1.png "Console d'administration")

Clic on `SAML applications`

![Console d'administration](./images/gsuite2.png "Console d'administration")

Clic on the plus sign (➕)  

![Console d'administration](./images/gsuite3.png "Console d'administration")

Clic on `configure a custom application`  

![Console d'administration](./images/gsuite4.png "Console d'administration")

Download the `IDP metadata` file  

![Console d'administration](./images/gsuite5.png "Console d'administration")

Type a name, a description and upload a logo for your application  

![Console d'administration](./images/gsuite6.png "Console d'administration")

Fulfill the **Service Provider** informations.  
Don't forget to select `EMAIL` as the **name ID**.  
**Do not click** the `sign response` option (as it will sign the `SAML envelope` **instead** of the `SAML assertion`).  

![Console d'administration](./images/gsuite7.png "Console d'administration")

Map the **OU** information to an `SAML attribute`, if needed  

![Console d'administration](./images/gsuite8.png "Console d'administration")

The configuration is done on the **G-Suite** side  

![Console d'administration](./images/gsuite9.png "Console d'administration")

Don't forget to **activate** the application in `G-suite` (it is disabled by default)  

![Console d'administration](./images/gsuite10.png "Console d'administration")
