---
title: "Property files"
description: "Property files"
---

# Property files

It is possible to use property files to override values configured in the technical configuration.  

## project.properties  

This is a file containing the configuration variables of the project. This file contains a list of variables and their associated values. The file must be exported from the iGRC Analytics project tab 'Project by clicking on the disk icon. Within the file are the default values for the specific values of the project. For example, there may be a variable requesting the file path to be imported into the database through collection. These values may be edited to match the technical environment. The only variable system always present in the file is logPath. By default, this variable indicates that logs will be generated in the project's logs directory. It is possible to change this setting, if logs have to be generated in another directory.

## datasource.properties  

This contains the database's access configurations. This file can be obtained by copying the one in the project's webportal directory. It is preferable to leave all variables to the default configuration, except the following three:  

- hibernate.connection.url: this contains the url link to the base that must be adjusted according to the selected architecture.
- hibernate.connection.username: contains the data base user's username
- hibernate.connection.password: contains the user's password. The unencrypted password may be visible within the file.

The first time that `igrc_batch.cmd` is executed, the password within the file will be replaced by an encrypted version.

> Remember to leave the datasource.properties file rights in read/write for batch process.  

## mail.properties

This is a technical configuration file for sending messages. As soon as the execution of the batch is complete, a notification messages is sent to one or more administrators to inform them of the results. This file can be obtained by copying the example file found within the project's webportal directory.The file contains the following variables, which must be adapted for contacting the email server:  

- `mail.send`: contains true or false values in order to activate or inhibit the sending of the message.
- `mail.host`: contains the DNS name or the IP address of the mail server.
- `mail.port`: contains the listening port of the mail server.
- `mail.protocol`: contains SMTP for unencrypted sending, or SSL or TLS for encrypted sending.
- `mail.username`: contains the username of the mail server
- `mail.password`: contains the password of the mail server

The following properties are also supported:

- `mail.subjectprefix`: contains the text added as a subject prefix to all emails sent by the portal, the workflow and the notify rules.
- `mail.redirectto`: redirect all email toward this unique email.
- `mail.recipientsinattachment`: contains true or false values in order to add an attachment file containing the real recipients when the redirection is active.
- `mail.blacklist`: contains the email address list, separated by coma, which should never receive any emails.
