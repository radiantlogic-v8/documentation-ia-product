---
title: Step by step Tutorial
Description: Documentation related to the step by step tutorial for the studio
---

## Step-by-step Tutorial

### My First Discovery

This section will allow you to discover the data discovery editor. After this tutorial, you will be able to import, analyze, and process a file in CSV format.
You can also see the various "screencasts," videos about discovery creation, by logging on to [http://expert-exchange.brainwavegrc.com](http://expert-exchange.brainwavegrc.com/)

#### Create a Discovery

Follow the steps below to create a discovery:

1. Create a new audit project and add the demonstration facet
2. Activate the 'iGRC Project' view.
3. Go to the main menu of your audit project
4. Click on New -> Data file inspector  
![Creating a new discovery](./images/worddav96e60c0ee3ae28ae73a47cfc6fc878b2.png  "Creating a new discovery")

5. Name your discovery, and don't forget to use its extension  
![Discovery file](./images/worddav97b699f3a4cd2afce207ef6b52bda652.png  "Discovery file")

6. Click on generic formats and select CSV format.  
![Using a CSV file format](./images/worddav7fe12f9613c4c3d082f361b23c8015fc.png  "Using a CSV file format")

7. Select the CSV file to import. Don't forget to specify the type of separator (";", ",", "|"...) in the file.  
![Importing the file to process](./images/worddave620c1bf9f16126924e3bcd6bfe2f97c.png  "Importing the file to process")

8. Click on "Next"  
![Verifying the attributes of the file to process](./images/worddava3eeb985b89b74894be64848a8a3c0a8.png  "Verifying the attributes of the file to process")

9. Click on "Finish"  
![Discovery configuration interface](./images/worddavbe604178d67117df0bfd07160e9c5968.png  "Discovery configuration interface")

#### Set up Rejection of Empty Data

Follow these steps to reject empty data

1. Go to the "Analysis" tab
2. Right-click on any attribute in the Attributes view, then on "Reject empty values"  
![Rejecting values](./images/worddavb0bb46bf122775c2ea6818b4ace1a699.png  "Rejecting values")

3. Enter a reason for the rejection  
![Rejection event](./images/worddav1f6e392b42f6b6df4460b06e2174638b.png  "Rejection event")  
4. Click on OK  
The rejected values are automatically added in the Rejected Values view of the work area.  
![Rejected values](./images/worddav2217fd8622742742efd36654a53d0ac1.png  "Rejected values")

#### Delete Duplicates

These steps are required to delete duplicates:

1. Go to the "Analysis" tab
2. Right-click on any attribute, then select the "Reject duplicated values" option  
![Criteria for rejecting a duplicate](./images/worddavde9283955f0fd013e2aae58d26efbabb.png  "Criteria for rejecting a duplicate")
3. Enter the event, then click on OK  
![Rejection event](./images/worddav95302ac7dc3052e3841afc5cacc4b577.png  "Rejection event")
The rejected values are automatically added to the "rejected values" view.  
![List of rejected values](./images/worddav8595e5f8d6fdc8863ea408959b7896a8.png  "List of rejected values")  

#### Add an Additional Attribute

To add an additional attribute, follow these steps:

1. Go to the "Analysis" tab
2. Right-click on any attribute in the "Attributes" view
3. Select the **Create a computed attribute**  option  
![Computed attribute creation wizard](./images/worddavbbe3cf21b3fbc4560e90c7bb1a7f3ee7.png  "Computed attribute creation wizard")  
4. Name your new attribute and give it a value and a description  
![New attribute creation wizard](./images/worddavb2bc883a7b3d36354024fa3dc36a4d04.png  "New attribute creation wizard")  
5. Then click OK  
![Adding a computed attribute](./images/worddav1bd5bc111b30d0507869db72f638f57e.png  "Adding a computed attribute")

#### Export the Results in CSV Format

To export the results in CSV format, follow these steps:

1. Right-click in the upper right side of the editor
2. Select "Export all in CSV and open in external editor"  
![Exporting results in CSV format](./images/worddavdfa620d30efcf17873ad3448b17357e0.png  "Exporting results in CSV format")

### My First Reconciliation Rule

This section will introduce you to the reconciliation rules editor. To do this we are going to configure a rule that will seek to reconcile an account based on the user's email.

#### Create the Reconciliation Rule

In the software's main menu, click "New..." and choose "Reconciliation rule".

![New reconciliation rule](./images/worddav0c7d6f3dc444fe20dd8212d5da4614ce.png  "New reconciliation rule")

Name your reconciliation rule remembering to add the extension ( **.reconrule** ) and click on **Next**

![Reconciliation rule file](./images/worddav1c058725c6feb126322d822ad046ea22.png  "Reconciliation rule file")

1. Enter a unique identifier for your reconciliation rule, for example **'account_reconciliation'**
2. Enter a description for your reconciliation rule, for example **'Reconciliation based on email address'**
3. Click **Finish**

![Reconciliation rule settings](./images/worddav8814129f229960bdf5f8b0e6d103f725.png  "Reconciliation rule settings")

#### Select Main Concept Criteria

1. Click the magnifying glass. Criteria applicable to the 'Identity' concept appear in the palette
2. Open the **'Criteria on email and phone'**  section
3. Drag and drop the **'mail is {mail}'** criteria onto the magnifying glass

![Add a Criterion](./images/worddav6ea76847a8a16a5c4d146d442aea7caa.png  "Add a Criterion")

1. Double click the hyperlink **'{mail}'**
2. Check **'Set the criterion with a global parameter of the rule'** box and select **'account user email'** , in the list of parameters.
3. Confirm the criteria entry by clicking **OK**

![Main concept criterion](./images/worddav7aa0d2680ecb52cd85ca111c4af6583d.png  "Main concept criterion")

#### Configure a Relationship Constraint

It is possible to link the identity repository with the repository when the reconciliation criterion is not in the identity repository.

1. Open the **'Link from identities'**  section
2. Drag and drop the **'link with accounts (using reconciliation)'** relationship on the magnifying glass.

![Add a relationship](./images/worddav3787f71f816758771ef4cc3d2d0bcb95.png  "Add a relationship")

#### Select Criteria Based on Linked Concepts

1. Click on the 'Account' join. The criteria which are applicable to the 'Account' concept appear in the palette
2. Open the **'criteria on identifiers'**  section
3. Drag and drop the **'account login is {login}'** criteria on the Account join

![Relationship criterion](./images/worddavaefcf693b42d8f7e3a5735277e62dd15.png  "Relationship criterion")

#### Display Results

1. Click the **'Results'** tab
2. You can click on the items, from the Ledger tab, to see them in detail,
3. You can select another 'Time slot' to execute this analysis on another Ledger data import date
4. You can filter the displayed results by clicking on 'Filter' and by replacing the text in the search field.

![Displayed Results](./images/worddavffe11fd6ca246ee19190ed42b2a49465.png  "Displayed Results")

### My First Reconciliation Policy

This section will introduce you to the reconciliation policy editor. To do this, we are going to configure a policy that will execute a reconciliation rule in each of the Active Directive (ADD) and OpenLDAP depositories.
We will consider two reconciliation rules ('identity **full name**  looks like **account user name'** ) for the AD repository and the login ('**HR Code**  looks like **account login**') for the OpenLDAP repository.

- Enable the '**iGRC Analytics**' view

1. In the product's main menu, click on "New..." and choose "Reconciliation policy".  
![New reconciliation policy](./images/worddav6d3b858c5b35162e40c731023dff99d2.png  "New reconciliation policy")

2. Name your reconciliation policy remembering to add the extension ( **.reconpolicy** ) and click **Next**  
![Reconciliation policy file](./images/worddav165e3dc7a31925b47f404cf6fd40bd21.png  "Reconciliation policy file")

3. Enter a unique identifier for your reconciliation policy, for example **'reconPolicy'**
4. Enter a description for your reconciliation policy, for example **'Reconciliation policy'**
5. Click **Finish**  
![Reconciliation policy settings](./images/worddavea32607dd1e542f9b111062ba204b803.png  "Reconciliation policy settings")

6. Click on ' **Add...**' located in the center of the policy editor. The list of all the repositories which have been declared in the Ledger can be open in the "Repository" field.
7. Select the AD repository (BRAINWAVE in our screenshot).  
![Reconciliation policy settings](./images/worddav704b9f90a36b816edfd160f8acaac132.png "Reconciliation policy settings")  

#### Add AD Repository

1. In order to select the rules associated with the AD repository, click on '**Add...**' located on the right of the reconciliation policy editor.
2. Double click on the reconciliation rule name that you want to associate with the AD repository. Check that the rule appears in the '**Rule list**' column.  
![Adding the rule to the AD repository.](./images/worddav76a8a46366cf51798950bc0cb462a42c.png  "Adding the rule to the AD repository.")

3. Follow the same principle for the OpenLDAP repository  
![Creating a reconciliation policy](./images/worddav5bf26ec52a8eb3a5e57c65b779d8ae54.png  "Creating a reconciliation policy")

#### Display Results

1. Click on the '**Results**' tab  
![Displaying reconciliation policy results](./images/worddavbbd00bef3b62509416c8d19c820e73c3.png "Displaying reconciliation policy results")  
![Displaying reconciliation policy results](./images/worddav6cce7d8b9c38ff6a0b199fee62bbb386.png  "Displaying reconciliation policy results")

The reconciliation policy results are displayed in the same way as reconciliation rules.

1. You can click the items, from the Ledger tab, to see them in detail
2. You can select another 'Time base' to execute this policy on another Ledger data import date
3. You can filter the displayed results by clicking on 'Filter' and by replacing the search field text.
4. By selecting an account, you can display the result of the policy for this account with the ![Policy icon](./images/worddav267ebe3bf403f70ae95deeeffa102cd8.png "Policy icon")
5. You can intervene dynamically in an account reconciliation to perform manual reconciliation operations.

### My First Audit View

This section will get you to be more familiar with the Audit View Editor. To this end, you will create an Audit View that lists all the identities contained within the Main Ledger and for each one, list the entire range of access accounts.
You can also see a video capture of a report being created with an associated Audit View by visiting [http://screencasts.brainwave.fr](http://screencasts.brainwave.fr/)

#### Create an Audit View

1. Activate the 'iGRC Analytics' view
2. Open the 'views/custom' folder in the project view and right click
3. Select 'new/audit view'
4. Name your Audit View, making sure to add the .view extension and click on **Next**  
![Selecting the file name](./images/worddaveae7550b4748bbbe5017397e749cf933.png  "Selecting the file name")

5. Key in a unique identifier for your Audit View and a description, and select _Identities_ from the drop-down  
![Configuring the Audit View](./images/worddav45f08ea866eea1ddd0152ba9f6fdd1c1.png  "Configuring the Audit View")

#### Set Attributes of the Main Concept

1. Drag and drop the following attributes from the **'Identity Attributes'**  toolbox to your **'identity'** concept:

- recorduid
- hrcode
- givenname
- surname
- mail
- internal

![Configuring attributes](./images/worddave2ac743db8b3afd891334c523b5945ac.png  "Configuring attributes")

#### Configure a Link to a Secondary Concept

1. Drag and drop the 'Join with accounts through reconciliation' from the 'Links from identities' toolbox
2. Select the 'Account(s)' concept in the graphical editor

#### Sett Attributes of a Secondary Concept

1. Drag and drop the following attributes from the 'Account attributes' toolbox to your 'account' concept:

- recorduid
- login
- username
- disabled
- locked

![Configuring a secondary concept](./images/worddave3b12dfea8241c90acbaa0c977d926ce.png  "Configuring a secondary concept")

#### Rename Attributes of a Secondary Concept

1. Right-click on the 'account' concept and select 'Modify table prefix'
2. Key in the 'account_' value

![Renaming attributes](./images/worddav32baaba9dbfd074ceaf609ace88424d7.png  "Renaming attributes")

#### Sort Search Results

1. Select the 'Sort' tab in the Properties Editor
2. Configure a sort operation by 'hrcode', then by 'account_login'

![Configuring a sort operation](./images/worddav4b47208d790cbd006ad146eaf41a94b8.png  "Configuring a sort operation")

#### View Audit View Results

1. Click on the 'Results' tab of the Audit View Editor
2. If desired, click on 'Export to CSV and open in linked program' to view values in your spreadsheet software

![Viewing results](./images/worddavd6d0145183e85b7fada61a1202b69bc0.png  "Viewing results")

### My First Report

This section allows you to familiarize yourself with the graphic report editor by creating a report yourself with just a few clicks. This report lists the identities contained in the Identity Ledger with, for each identity, his/her position and the organization s/he is attached to. The data is sorted by the HR unique ID of the identities displayed.

#### Create a List Report

1. Activate the 'iGRC Reports' perspective
2. Place the cursor on the 'reports/custom' directory in the project view, and right click
3. Select 'new/audit report'
4. Enter a name for your report, without forgetting its extension (.rptdesign) and click on Next
5. Select the template 'Search List Report' and click on 'Finish'

![Select the report template to use](./images/worddav0598a675e18ce8ee78ada104c678805f.png  "Select the report template to use")

The report editor then opens with your new report.

![Report editor after the wizard has run](./images/worddav5f376eb0a6316363c961bd861c5cc2e6.png  "Report editor after the wizard has run")

#### Reference Data to be Used

1. Select the 'Data Explorer' view
2. Right-click on the 'Data Sets' entry, then select 'New Data Set'
3. Name your Dataset, then do Next
4. Click on the 'folder' icon to select the Ledger view to associate with this Dataset
5. Select the 'identity/identitydirectorganisation.view' entry and click on OK
6. Click on Finish

![View selection](./images/worddav02d378a936a8c6d6bdb7fb58bcd3d9a8.png  "View selection")

The Dataset editor then opens and allows you to verify the attributes that are retrieved by the view, to refine the dataset settings, and to preview the data in an unformatted display.  
![Dataset editor](./images/worddav05a737a9edb4e1fd7bece73343a502b3.png  "Dataset editor")  

7. Click OK

#### Associate Data with the Table

1. Select the table in the report editor
2. Select the 'Binding' tab in the properties area
3. Select your Dataset in the 'Data Set' drop-down list
Your table is now paired with your Dataset, it is therefore now able to display data from this Dataset.  
![Associating the Dataset with the table](./images/worddav2c4671a8e7d458120cb30e7bf84c935f.png  "Associating the Dataset with the table")

4. Expand the tree section under your dataset in the 'Data Explorer' view
5. All of the attributes associated with the Dataset appear ; drag/drop the following columns in your table:

- hrcode
- givenname
- surname
- internal
- jobtitledisplayname
- org_displayname

![Associating attributes in the table](./images/worddav30f34243ebff3f8c2de1bbbdcc9d5d92.png  "Associating attributes in the table")

#### Format Columns

1. From the palette, drag and drop the 'label' item in each column header
2. Double-click on the various labels to edit them

- hrcode
- givenname
- surname
- internal
- jobtitledisplayname
- org_displayname

![Formatting the labels](./images/worddav796b52fa0e22960a5520dfa7e547fa81.png  "Formatting the labels")

#### Organize Data

1. Select the table in the graphical editor
2. Select the 'Sorting' tab in the property editor
3. Click on 'Add' and then select the 'hrcode' value in the drop-down list, click on OK

![Table results sorted](./images/worddav38d5be4411172e1a8302133328d00b1c.png  "Table results sorted")

#### View the Results

1. On the main menu, click on Run/View report/In Web Browser

![Previewing the results](./images/worddav685c9f4a6dde7e863300b6675d7b95b8.png  "Previewing the results")
