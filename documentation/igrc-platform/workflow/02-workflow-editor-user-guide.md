---
title: "Workflow editor User guide"
description: "Workflow editor User guide"
---

# Workflow editor User guide

This document presents the Workflow editor functionalities in the studio of Identity Analytics's iGRC platform.  
This editor provides a user-friendly interface along with a series of wizards to allow you to create, configure and deploy a workflow. It is composed of five main tabs presented below.  

The audit workflow file, which has a .workflow extension, as well as the associated javascript file are created under the workflow folder into the project explorer:  

![Workflow](./images/Image_Documentation39.png "Workflow")  

Opening the created audit workflow can be done either via the project explorer (showed in the above caption) or using the audit menu. This opens the workflow editor content as following:  

![Workflow](./images/Image_Documentation43_bis7.png "Workflow")  

## The editor's tabs

This section describes the workflow editor's tabs as well as the palette.

### Workflow

The workflow tab contains the editor interface which allows you to drag and drop components (such as "Start", "End", "Manual Activity", "Call of a subprocess") from the palette located of the right hand side. More information on these components is available under: [Workflow: Start, End and manual activity components description](./11-components#start-or-manual-activity-component) and [Iterations and subprocesses](./06-iterations-and-subprocesses).  

![Workflow](./images/Image_Documentation43.png "Workflow")  

The workflow editor palette gives access to all components that can be used to build a workflow (see the caption below):  

![Workflow](./images/Image_Documentation44_BIS.png "Workflow")  

Each section of the palette allows the selection of specific elements.  

- The "connection links" and "note items" segment allows definition of the links between two components, adding notes and all selection tools.
  - The black coloured arrow corresponds to the standard connection between two components
  - The red coloured arrow is used for manual task expiration paths if the action is not performed (Please see [Exception management](./13-exception-management) for more information).
- The Activities section includes the generic components that can be used to create a Workflow. These include "Start", "Manual Activity", "Call of a Subprocess", "Stop" also named "End", "Email notification", etc.,
- The Reconciliation section includes components related to reconciliation, such as "Reconciliation update", "Reconciliation of service account", "Delete reconciliation" as well as "Reconciliation with person who left the company",
- The Delegations section includes components related to delegations, such as "Create delegation", "Update delegation" and "Delete delegation",
- The Meta-data section includes "Permission metadata update" and "Application metadata update".

The configuration of the different components is done trough the properties sub tab of the workflow editor (see caption below). Each component is described in the corresponding section of the documentation: [Components](./11-components). Each component has a different number of tabs that can be used to configure the behaviour of the workflow.

![Workflow](./images/WorkflowProperties.png "Workflow")  

### Configuration

The configuration tab allows you to configure/define the parameters to use during the workflow. This tab is composed of four different sections:  

- Process properties - used to configure:
  - The unique identifier of the workflow. This should be used in the pages
  - The definition title of the workflow: This is the name of the workflow that will be displayed in the web-portal. It is possible de nationalise the title using the little flag icon on the right of the text box
  - The instance title: In the case of multiple instances it is possible to give a distinct name to each workflow. This title can be calculated dynamically using variable. You can list the variables using the light-bulb on the right of the dialogue box.
  - A description of the workflow.
- Process roles: to configure all the roles used during the workflow processes. Role settings are described under the documentation [Roles](./03-roles).
- Process variables: to create workflow variables to be used in the associated pages. As shown in the screenshot below, a variable has an identifier, a display name, a type, a description. More information on variable definition as well as usage for the process start page and interaction with the iGRC ledger is provided into the documents available into chapter [Variables](./04-variables).
- Process e-mails: to configure notification rules and e-mails. These include reminder and escalation (see the corresponding documentation for more information: [E-mail notifications](./07-email-notifications)).  

![Configuration](./images/Image_Documentation58.png "Configuration")  

### Advanced Configuration

This tab includes more configuration sections:  

- "Process properties" allows you to configure whether you wish to allow or not the process to be started from the task manager or to be hidden in the associated webportal pages. You can also define the workflow type. This parameter is used during the purge process and is configured in the technical configuration of the project. This section also allows you to define the icons to be used in the web portal.
- "General options" allows you to configure the behaviour of the workflow in the web-portal and the location of the various elements such as the javascript file and the pages.
- "E-mail policies" allows you to control e-mails notifications (based on a notify rule). The e-mails are the sent after being validated by a javascript expression.
- "Compliance Report" configures the automatic report sent at the end of a process. The generated report is stored in the audit database while a copy can be saved onto the file system. A detailed configuration is available under [Compliance reports](./11-components#workflow-compliance-reports).  

![Advanced Configuration](./images/Image_Documentation46.png "Advanced Configuration")  

### Dependencies

This tab shows the files from which the current workflow audit is dependent. In the example presented in the screenshot below, the workflow audit file is only dependent to the associated java script file.  

![Dependencies](./images/Image_Documentation47.png "Dependencies")  

### Usage

The Usage section tab of the workflow editor show files(e.g.page, report page, another workflow process, etc.) using this workflow audit file.  

![Usage](./images/Image_Documentation48.png "Usage")  
