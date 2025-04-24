---
title: Batch Mode
description: Notification rules in batch mode
---

# Batch mode

## Command line  

Notification rules can be launched via command line in the Windows and Linux environments. The batch scripts are available in the root folder of your installation:  

- `igrc_notify.cmd` in Windows
- `igrc_notify.sh` in Linux  

The command line scripts give access to the two modes of notification rules:  

- Sending emails to recipients
- Save reports (i.e. attachments) in a folder (a sub-folder is created for each recipients)  
To use these two modes, two different syntax should be used when calling the command line. These two methods are described below  

> [!Warning] Command line notifications only work on the last validated timeslot. It is not possible to use data from older timeslots or sandboxes.

### Sending emails  

The command line syntax for sending emails is the following:  

```sh
igrc_notify <project name> <config directory path> <config name> [<filename>]
SEND <email campaign name> ['ALL' or <notify rule list>]
```

Please note that the SEND keyword specifies that we want to send emails.  

The parameters are described as:  

- project name is the name of the project containing the notification rules to run  
- config directory path corresponds to the absolute file path containing the license file and/or the properties files  
- config name is the name of the configuration file to use
- filename is a path of the UTF-8 file containing the parameters of the notify rule  
- email campaign name is the name of the emailing campaign. For more information see the chapter on retry on error  
- notify rule list is the list of notification rules to run, separated by spaces. It is possible to use the ALL keyword to run all the notification rules of the project.  
Command examples:  

```sh
igrc_notify.sh demonstration /var/igrc/config default SEND ALL
igrc_notify.sh demonstration /var/igrc/config default SEND managernotify auditornotify hrnotify
igrc_notify.sh demonstration /var/igrc/config default /var/myparameters.properties SEND managernotify auditornotify hrnotify
```

### Saving reports  

The command line syntax for saving reports is the following:  

```sh
igrc_notify.sh <project name> <config directory path> <config name> [<filename>] SAVE <save directory> ['ALL' or <notify rule list>]
```

Please note that the SAVE keyword specifies that we want to save the reports.  

The parameters are described as:  

- project name is the name of the project containing the notification rules to run  
- config directory path corresponds to the absolute file path containing the license file and/or the properties files  
- config name is the name of the configuration file to use  
- save directory is the absolute path to the folder where you wish to save your reports. A sub-directory will be created for each recipient: name after the email address, and containing the recipients reports (attachments)
- notify rule list is the list of notification rules to run, separated by spaces. It is possible to use the ALL keyword to run all the notification rules of the project.  

Command examples :  

```sh
igrc_notify.sh demonstration /var/igrc/config default SAVE /var/igrc/reports ALL
igrc_notify.sh demonstration /var/igrc/config default SAVE /var/igrc/reports managernotify auditornotify hrnotify
```

## Retry on error  

An important feature, that is only provided in batch mode, is the possibility to retry on error. The issue with emailing campaigns is error management when large volumes are sent. As an example:  

- Running the command line including the keyword SEND, knowing that there are 200 recipients.
- The campaign sent out the first 30 emails without issues
- A momentary unavailability of the mail server causes the command to stop on an error  
- 170 recipients did not receive the email due to the error  

At the end of this scenario it would be interesting to execute the same the command, resuming the campaign without sending the same mail again to the first 30 recipients. This feature is included in emailing campaign concept.  

The command line allow you to set a campaign name. This name is used as a prefix to create a file which stores the list of successfully processed recipients during the campaign.  
In the above example, this file would have contained the list of the first 30 recipients. When re-executing the command line with the same campaign name, the product will automatically skip the first 30 first recipients since they are in the file and already got the email.  
Let's see the same example again:  

- Execution of the command including the SEND keyword and with a new campaign name, knowing that there are 200 recipients  
- As the campaign file does not exist, all the recipients are included in the campaign  
- Emails are sent without issues for the first 30, their email addresses are stored in the campaign file  
- The mail server is rendered unavailable and causes the command to stop
- The campaign file only includes the email addresses of the fist 30 recipients and 170 recipients did not receive the email
- Once the mail server is back online, a second execution of the command line is performed using the same campaign name.  
- As the campaign file already exists it is read by the product in order to determine which recipients are not to be processed as they have already successfully received an email  
- Emails are sent to 170 remaining recipients. If successful they are added to the list contained in the campaign file  
- Once the execution is successfully finished the campaign file contains all 200 recipients  

If the command line was executed a third time using the same campaign name, no mail would be sent since all the recipients are already included the campaign file.

> [!warning] It is important to understand that each new campaign must have a distinct name.

If the command line is executed by a job scheduler to, for example, send emails after each execution plan, you should include the date in the campaign name in order to ensure that a new campaign file is created each time the job is executed.

## Rule parameters

A notify rule can have input parameters. In previous product versions, the parameter values had to be set inside the notify rule. But since version 2017 R3 SP1, the notify.cmd and notify.sh accepts a filename as a fourth argument to set or override the rule input parameters from the command line. This is handy to have only one notify rule which behave differently depending on the parameters given in the command line.  
There is no way to set rule input parameters on the command line. The parameters must be set in a filename and this filename can be used as an argument of the command line.  

The following example does NOT work. You can not give parameter values on the command line :  

```sh
igrc_notify.sh demonstration /var/igrc/config default application=Elyxo SEND ALL
```  

The following example is the right way to execute a notify rule with parameters :  

1) Make a file containing all the parameters. In this example, we create a file `/var/myparameters.properties` containing the parameter application:  
`application=Elyxo`  

2) Use the file in the command line  
`igrc_notify demonstration /var/igrc/config default/var/myparameters.properties SEND ALL`

The filename is a classic Properties file with the following format :  

```properties
<key1>=<value1>
<key2>=<value2>
```

The key is the name of the parameter defined in the notify rule. The case should be the same. An input parameter Orgs can not be set with the key oRgS.  
The content of the Properties file should be encoded in UTF-8 so that accents are preserved.  

Multivalued input parameters are also supported. All values should be given in the same line. The values must be separated by the pilcrow character **¶**. The order of the values is respected. The following example has an input parameter with a list of organization codes :  

```properties
application=Elyxo
organisations=DCOM¶DFIN
```

> The filename parameter on the command line is optional.  
