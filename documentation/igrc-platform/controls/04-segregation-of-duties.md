---
title: Controls in Segregation of Duties
Description: Documentation related to the configuration of the SoD matrix in the studio
---

# Segregation of Duties Controls

## Concept

Segregation of Duties (SoD) is a risk management principle that ensures no single individual has control over all steps of a critical process, thereby preventing errors and reducing the risk of fraud.

### Different types of SoD

SoD rules can be defined for any critical business process, such as:

- Accounting and Finance
    - Procure-to-Pay 
    - Order-to-Cash 
    - Record-to-Report 
    - Inventory Management 
    - Treasury & Cash Management 
    - Payroll & HR 
    - Fixed Assets 
- Trading and Asset Management
    - Separation of Front Office, Middle Office, and Back Office duties 
    - Separation of IT/maintenance and business duties 
- IT
    - Separation of Development and Production duties
    - Separation of admin rights and other high-privilege access (backup, DBA, user access management…) 
    - Change management / CI/CD

## SoD in Identity Analytics

There are two major ways to configure SoD in IDA: either by creating custom controls for each SoD rule you want to implement or by using the SoD matrix data collection process.

### Pros and cons

These two ways of implementing SoD each have pros and cons.

Implementing SoD using custom controls is more time-consuming and requires the creation of a single control for each rule. However, this allows for more flexibility and complexity in each rule configuration.

Implementing SoD with an embedded matrix provides a standardized way of loading rules, hence less flexibility and complexity. However, it makes the process faster and allows it to be used quickly out of the box.

Regardless of the complexity of the SoD rules to be implemented in the project, effort will be required to define those rules.

### Custom control

There are three ways to build custom SoD controls.

> [!Warning] Controls configured this way are not considered SoD controls by the product. Therefore, they will not be available on the SoD pages.

1) **Deprecated:** SoD control between two single permissions. This type of control returns the identities or accounts in discrepancy because they have access to both permissions at the same time. The use of the SoD matrix is recommended instead, as these controls are not displayed OOTB in the latest version of the IAP portal.  
   ![Segregation of duties](./images/sod-control-permissionxpermission.png "SoD permission x permission")
2) **Deprecated:** SoD control between two sets of permissions. This type of control returns the identities or accounts in discrepancy because they have access to at least one permission in the first set and one in the second set at the same time. The use of the SoD matrix along with business activities is recommended instead, as these controls are not displayed OOTB in the latest version of the IAP portal.  
   ![Segregation of duties](./images/sod-control-permission_list.png "SoD sets of permissions")

3) The third approach consists of using a custom rule for the control, which provides significantly more flexibility and complexity.

   In the example below, we want to identify identities that:
   - have access to the permissions "Utilisateur" and "Valideur3",
   - do not have access to the permission "Valideur2",
   - and have access to either the "Administrateur Remedy" or the "Administrateur SAGE" permission.

   Logical operation:  
   `Utilisateur AND Valideur3 AND NOT Valideur2 AND (Administrateur Remedy OR Administrateur SAGE)`

   ![Segregation of duties](./images/sod-rule.png "SoD rule")

   This rule can then be used in a control, and the returned identities will have SoD defects.

### SoD matrix

SoD matrices are objects embedded in the product. Their purpose is to generate multiple SoD controls automatically during an execution plan. The controls covered by a matrix are the same as those defined in parts 1 and 2 in [Custom control](#custom-control).

A matrix is identified by a code and a display name, as well as optional tags including a type and a list of nine custom fields.

![SoD collector matrix](./images/sod-collector-matrix.png "SoD collector matrix")

Once created, a matrix is an empty shell, and several pairs of toxic permissions must be added to it. Each toxic pair will be computed as an SoD control during the execution plan. These pairs can either be between two permissions or between two sets of permissions. In the latter case, those permission sets must be loaded into business activities beforehand.

#### SoD matrix permission pair

Permission pairs are built based on two application/permission pairs, a unique control identifier, and the code of a matrix created in a previous step.

The `Result type` option determines whether the control processes results at the identity level or the account level.

- On the account level, a discrepancy appears if the account has both permissions.
- On the identity level, a discrepancy appears if the identity has both permissions through one or more accounts.

For permission pairs, `Model validation` should be set to `Permission type validation`.

![SoD pair permission 1](./images/sod-pair-permission_1.png "SoD pair permission 1")

Some optional attributes can be configured on the pair, such as the display name, risk level (integer between 0 and 5), suggested mitigation, etc.

![SoD pair permission 2](./images/sod-pair-permission_2.png "SoD pair permission 2")

Tags can also be added. For compatibility with SoD pages as of IAP 3.5, the `type` field should be filled with the value "SoD between permissions," and `custom1` should contain the same matrix code as the one defined in the SoD control tab.

![SoD pair permission 3](./images/sod-pair-permission_3.png "SoD pair permission 3")

#### SoD matrix business activity pair

Creating a toxic pair based on BAs (Business Activities) can be done in the same way as for standard permissions but requires mandatory preprocessing as well as slight modification of several fields.

It is mandatory to load the BAs along with their permissions with a permission type set to `Activity` before using them as targets in the matrix permission pair. The toxic pair can then be created as explained above, using the identifier of the BA permission.

For BA pairs, `Model validation` should be set to `Activity type validation`.

![SoD pair BA 1](./images/sod-pair-ba_1.png "SoD pair BA 1")

For compatibility with SoD pages as of IAP 3.5, the `type` field should be filled with the value "SoD between activities," and `custom1` should contain the same matrix code as the one defined in the SoD control tab.

## SoD Designer

The SoD Designer is a webpage available in the IAP portal intended to help users build their SoD matrices. It provides an interface to select toxic permission pairs that can be added to a defined matrix along with a risk level assigned to each pair.

This "SoD - Designer" page is available to functional admins and technical admins through the Controls menu. The SoD license feature is required to access this interface.

### Create a matrix

From this page, the user must select two lists of applications. The permissions contained in those applications will then be displayed and can be used to populate an SoD matrix.

![SoD designer 1](./images/sod-designer_1.png "SoD designer 1")

The user can select one or more permissions in each list along with a risk level below, then press the "Add pairs" button to create the list of toxic pairs that will be added to the list on the right with the selected risk level.

If two permissions are selected in the first list and three in the second, six toxic pairs will be created (2×3). A permission cannot be toxic with itself, and pairs can span across applications.

![SoD designer 2](./images/sod-designer_2.png "SoD designer 2")

If toxic pairs need to be removed, they can be selected and removed using the "Remove pairs" button.

In case of an incorrect risk level, the pair should be selected again in both lists on the left along with the new risk level and added again. The previous pair will be overwritten by the new one, correcting the risk level.

![SoD designer 3](./images/sod-designer_3.png "SoD designer 3")

The matrix can be displayed as a cross table using the "Crosstable" button for a better overview.

![SoD designer crosstable](./images/sod-designer_crosstable.png "SoD designer crosstable")

Once created, the toxic pairs can be saved in a matrix. A name must be entered in the text field in the top right.

![SoD designer 4](./images/sod-designer_4.png "SoD designer 4")

The "Save matrix" button can then be pressed to save everything that has been created.

### Load a matrix

There are two ways to load a matrix on the SoD Designer page, both available via the "Load matrix" button.

![SoD designer load](./images/sod-designer_load.png "SoD designer load")

A matrix can be loaded either by selecting one that already exists in the environment, which will populate the page with the correct information, or by uploading an XLSX file exported from a matrix that follows a specific format. These exported matrix files can be retrieved using the "Export matrix" button, which is useful when a matrix has been configured in one environment and must be reused in another.

### Load a matrix

> [!Warning] The `bw_sod_designer` facet must be deployed in the project to load a matrix configured with the SoD Designer.

During matrix configuration, the `Load the matrix in the future execution plan` option can be checked before saving to include it in future execution plans.

The matrix can also be exported to an XLSX file that can be placed in a defined folder to load it into another environment.

### Delete a matrix

To delete a matrix, click "Delete matrix." A matrix must then be selected from the dialog that appears among the existing matrices in the environment, and the deletion must be confirmed.

## SoD Dashboards

### Concept

Once SoD controls have been defined, the product provides a set of dedicated dashboards to monitor, investigate, and remediate the resulting SoD defects. These dashboards are all available under the **Controls** menu.

> [!Warning] Before an SoD matrix can populate these dashboards, it must be included in an execution plan. When creating or editing a matrix, make sure the **Load the matrix in the future execution plan** option is checked, then relaunch an execution plan. Forgetting this step means the matrix will remain an empty shell and no defects will be computed.

### SoD Global Dashboard

The **SoD - Global Dashboard** page gives a high-level overview of the SoD situation for all matrices. It displays the current number of SoD matrices, SoD controls, SoD problems, and SoD exceptions, along with their evolution.

![SoD Global Dashboard - Identities tab](./images/sod_global1.png "SoD Global Dashboard - Identities tab")

The dashboard is split into two tabs:

- **Identities**: shows the identities with problems and the number of identity-related problems, each broken down by risk level, along with a history of these problems over time.
- **Roles**: shows the roles with core model problems and the number of core-model-related problems, following the same logic as the Identities tab.

![SoD Global Dashboard - Roles tab](./images/sod_global2.png "SoD Global Dashboard - Roles tab")

You can restrict the figures on this page to only reflect one selected matrix by using the **Matrix** dropdown at the top of the page.

### SoD Matrix

The **SoD - Matrix** page displays the toxic pairs defined in a matrix as a cross table, crossing every permission of the matrix against every other permission. Each cell shows the risk level of the corresponding pair, when one has been defined.

![SoD Matrix cross table](./images/sod_matrix1.png "SoD Matrix cross table")

The view can be filtered by **Matrix** and by **Minimum Risk Level** using the dropdowns at the top of the page.

Clicking on a permission label opens its detail panel, which includes information such as the number of accounts and identities holding it, its classification, and its managers.

![SoD Matrix permission detail](./images/sod_matrix2.png "SoD Matrix permission detail")

A specific pair can also be selected directly on the cross table. Once selected, the **Selected control details** button becomes available.

![SoD Matrix selected control](./images/sod_matrix3.png "SoD Matrix selected control")

Clicking this button opens the **Control Details** panel, which pulls up the information defined for that pair in the original matrix: its code, risk level, control type, description, notes, risk info, and suggested mitigation.

![SoD Matrix control details](./images/sod_matrix4.png "SoD Matrix control details")

### SoD Defects - User level

The **SoD defects - User level** page shows, for each toxic permission pair, the number of identities currently in discrepancy. Like the SoD Matrix page, it can be filtered by **Matrix** and **Minimum Risk Level**. It also offers a **Defect filtering** option to restrict the view to defects coming from a direct (individual) permission assignment, a role-based assignment, or both.

![SoD defects - User level cross table](./images/sod_user1.png "SoD defects - User level cross table")

It is always possible to open a specific controls' details page by selecting it in the matrix and clicking on the **Selected control details** in the top right.

![SoD defects - User level control details](./images/sod_user6.png "SoD defects -  User level control details")

The **Display as a list** button switches the cross table into a Pareto analysis of the most common toxic pairs, together with a detailed list of every defective identity. This list view adds a **Control filtering** field to narrow the results down to a specific control.

![SoD defects - User level list view](./images/sod_user2.png "SoD defects - User level list view")

Selecting a control on the cross table (or a bar on the Pareto chart) and clicking **Display as a list** filters the list to the identities in discrepancy for that control only.

![SoD defects - User level filtered on control](./images/sod_user3.png "SoD defects - User level filtered on control")

It is also possible to open this SoD Defects Analysis page by clicking the **Selected defect details** in the main matrix view.

![SoD defects - User level defect details](./images/sod_user7.png "SoD defects - User level defect details")

From this list, one or more identities can be checked to take action:

- **Remediation**: opens a dialog listing the accounts that hold the toxic permission pair, and lets you create a remediation request against them.

![SoD defects - User level remediation](./images/sod_user4.png "SoD defects - User level remediation")

- **Set Exception**: opens a dialog to record an exception for the selected identity/identities against the selected control, with a reason, an optional expiration date, and a comment.

![SoD defects - User level exception](./images/sod_user5.png "SoD defects - User level exception")

- **Root Cause Analysis**: launches an analysis to help understand how the identity ended up with the toxic combination. This button is generally used for role level defects.

### SoD Defects - Role level

The **SoD defects - Role level** page (also labelled **Core Model SoD Defects Analysis**) is presented the same way as the User level page described above, with a cross table view, a **Display as a list** view, and the same **Matrix** and **Minimum Risk Level** filters. However, it does not look for identities holding too many permissions: it looks for **core model defects**, i.e. SoD defects baked into the definition of the roles themselves, represented by **permissions** entities in Identity Analytics.

![Core Model SoD Defects Analysis cross table](./images/sod_role1.png "Core Model SoD Defects Analysis cross table")

Like the User level page, the cross table can be switched to a Pareto analysis by clicking **Display as a list**. This lists every role whose own definition triggers a control, along with the risk level, the application, the control, the two conflicting activities, and the number of accounts that hold the defective role.

![Core Model SoD Defects Analysis list view](./images/sod_role2.png "Core Model SoD Defects Analysis list view")

#### Why a role can be defective

A role can embed a defect when it is built out of other permissions that are themselves flagged as a toxic pair. For example, the role **Valideur2** is a composite permission. Opening its detail panel shows on the **Permission** tab that it has 2 sub-permissions.

![Valideur2 permission detail](./images/sod_role3.png "Valideur2 permission detail")

The **Content** tab of that same detail panel lists those sub-permissions: **Valideur2** contains **Valideur3** and **Valideur1**.

![Valideur2 content tab showing sub-permissions](./images/sod_role4.png "Valideur2 content tab showing sub-permissions")

Since the SoD matrix defines **Valideur1** and **Valideur3** as an incompatible pair, **Valideur2** ends up granting both sides of a toxic pair by design.

This is the kind of issue the Role level page surfaces, even when no single identity is affected.

#### Root Cause Analysis

Selecting a defect on the list (or a bar on the Pareto chart) and clicking **Root Cause Analysis** opens a dedicated panel with three tabs.

The **Root Cause List** tab shows the SoD Control Details for the defect (code, risk level, risk information) together with the two permission lists that are in conflict.

![SoD problem root cause analysis - Root Cause List](./images/sod_role5.png "SoD problem root cause analysis - Root Cause List")

The **Role Content** tab displays the full content of the role, splitting its sub-permissions into the two conflicting lists (colour-coded as **First List** and **Second List**) so you can see exactly which part of the role's definition causes each side of the conflict.

![SoD problem root cause analysis - Role Content](./images/sod_role6.png "SoD problem root cause analysis - Role Content")

The **Affected Identities** tab lists every identity that is impacted by this core-model defect, i.e. every identity that holds the defective role and therefore inherits the toxic combination.

![SoD problem root cause analysis - Affected Identities](./images/sod_role7.png "SoD problem root cause analysis - Affected Identities")

As with the User level page, the **Selected control details** and **Selected defect details** buttons let you open the detail page for a control or a defect selected on the main view.

![SoD problem root cause analysis - Control Details](./images/sod_role8.png "SoD problem root cause analysis - Control Details")
![SoD problem root cause analysis - Defect Details](./images/sod_role9.png "SoD problem root cause analysis - Defect Details")

### SoD Exceptions - User level

The **SoD exceptions - User level** page lists every exception that has been recorded, with its risk level, control, exception reason, comment, expiration date, and the name of the issuer. The list can be filtered by **Minimum Risk Level**, by control, or by identity.

![SoD Exceptions - User level list](./images/sod_exception1.png "SoD Exceptions - User level list")

Selecting an exception on the list displays its details in the panel on the right, either from the **Control details** tab (control code, name, entity, risk level, control type, description, notes, risk info) or the **Identity details** tab (HR code, name, email, status, arrival/leave dates, manager, and allocation).

![SoD Exceptions - User level identity details](./images/sod_exception2.png "SoD Exceptions - User level identity details")

An existing exception can be modified or removed using the **Update Exception** and **Delete Exception** buttons. Updating an exception allows the reason, expiration date, and comment to be edited.

![SoD Exceptions - User level update exception](./images/sod_exception3.png "SoD Exceptions - User level update exception")