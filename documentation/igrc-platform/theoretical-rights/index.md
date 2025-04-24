---
title: "Theoretical Rights"
description: "Configuration of theoretical rights"
---

# Theoretical rights

Theoretical rights allow to load a list of accesses Identities should have in theory, and compare it with real access rights.  

The goal is to run controls, that list over-allocations and under-allocations:  

- Over-allocations: rights the Identity has in real applications that are not in the theoretical rights model
- Under-allocations: rights the Identity should have according to the theoretical rights model, but does not have in the real applications

![Theoretical rights model](./images/theoretical_rights_model.png)

There are two ways to collect theoretical rights:

- [Permissions are provided with accounts](#collect-iam-rights)
- [The criteria for obtaining permission are known using model policy](#collect-using-model-policy)

To achieve this goal, you have to implement the following steps:  

1. Collect of the theoretical rights model, from an IAM application
2. Define the theoretical rights model policy using the ingested data
3. Run controls for the theoretical rights to return over-allocations and under-allocations

> [!Warning] Please note that when description theoretical rights for a given permission using both the IAM data collection and the Model policy the resulting theoretical rights calculated corresponds to the union of the two sets.  

## Project & Facets

If possible, don't implement it yourself, but use the facets & what is included in the project already:  

- `bw_iamcollector`:
  - Allows to load the Theoretical rights of an IAM application into the ledger (Silo & collector lines)
  - It also contains a model policy: `iam_rolemodel`
  - *You might need to add a collector line to convert your source data to the format required by this facet*
- `IAP` / `IAS`, already contains:
  - Theoretical rights controls: `bwcd_ACC17` and `bwcd_ACC23`
  - Fragments for theoretical rights:  
    - `webportal/pages/bw_fragments/iamapplication`: to display the role model of the `IAM` applications
    - `/webportal/pages/bw_fragments/identity/theoreticalrights`: to show over-allocations on Identities

## Collect IAM Rights

Collecting IAM Rights allows the you to directly provide permission/account links in import files. These are often provided by a IAM solution.  

A dedicated target for collect lines has been added to allow the ingestion of IAM rights directly:  
![IAM rights target](./images/iam_rights_target.png)

It is required to reference in the target to a given unique permission and a given unique account(_i.e._ referencing application/permission and repository/account pairs):  
![IAM rights target permission and account](./images/iam_rights_target_permission_account.png)

Role and comment are optional parameters that provide more information, they don't affect theoretical rights:  
![IAM rights target model params](./images/iam_rights_target_optionnal.png)  

Here is some sample data to illustrate:

| Application code | Permission code | Repository code | Account id | Role            |
| ---------------- | --------------- | --------------- | ---------- | --------------- |
| Elyxo            | User            | EKYXO           | VIOLET9    | ``DFIN_Agents`` |
| RACKSTATION      | FIN_Share       | ACME            | JHORTON19  | ``DFIN_Agents`` |
| Elyxo            | Admin           | ELYXO           | ROMAIN11   | ``DFIN_Admins`` |
| RACKSTATION      | FIN_Share       | ACME            | OLIVA8     | ``DFIN_Admins`` |

- ``DFIN_Agents`` role grants `Elyxo/User` and `RACKSTATION/FIN_Share` permissions to the `VIOLET9` account in the `ELYXO` repository and `JHORTON19` account in the `ACME` repository.  
- ``DFIN_Admins`` role grants `Elyxo/Admin` and `RACKSTATION/FIN_Share` permissions to the `ROMAIN11` account in the `ELYXO` repository and `OLIVA8` account in the `ACME` repository.  

Once ingested into the import tables, **theoretical rights** between **Accounts**, **Identities** and **Permissions** are not yet created. They will be created after the activation of the timeslot during the `theoretical right model policy` step, just after the manager policy step.

## Theoretical rights loading

During the `theoretical right model policy` step, the accounts provided in the collect are linked with identities through the reconciliation.

After these steps, refer to [the control section](#controls).

## Collect using model policy

There is a dedicated target in the collect, for theoretical rights:  
![Theoretical rights target](./images/theoretical_rights_target.png)  

It requires to point on the target permission (which means to point to the couple application/permission):  
![Theoretical rights target permission](./images/theoretical_rights_target_permission.png)  

And the parameters used by the model policy to determine the population that should have said permission:  
![Theoretical rights target model params](./images/theoretical_rights_target_params.png)  

The model can vary between clients.  
It can use an identity's job, organization, or HR code.  

Here is some sample data to illustrate:  

Using a *job title* as param1:  

| Rule type | Application code | Permission code | Role          | param1 (Job) |
| --------- | ---------------- | --------------- | ------------- | ------------ |
| IAMTYPE   | Elyxo            | User            | `DFIN_Agents` | Actuary      |
| IAMTYPE   | RACKSTATION      | FIN_Share       | `DFIN_Agents` | Actuary      |
| IAMTYPE   | Elyxo            | Admin           | `DFIN_Admins` | Actuary_adm  |
| IAMTYPE   | RACKSTATION      | FIN_Share       | `DFIN_Admins` | Actuary_adm  |

> The ``DFIN_Agents`` grants the `Elyxo/User` and `RACKSTATION/FIN_Share` permissions for the identities having the `Actuary` job title.  
> The ``DFIN_Admins`` grants the `Elyxo/Admin` and `RACKSTATION/FIN_Share` permissions for the identities having the `Actuary_adm` job title.  

Using an *HRCode* as param1:  

| Rule type | Application code | Permission code | Role          | param1 (HR Code) |
| --------- | ---------------- | --------------- | ------------- | ---------------- |
| IAMTYPE   | Elyxo            | User            | `DFIN_Agents` | HR000285         |
| IAMTYPE   | RACKSTATION      | FIN_Share       | `DFIN_Agents` | HR000285         |
| IAMTYPE   | Elyxo            | User            | `DFIN_Agents` | HR000878         |
| IAMTYPE   | RACKSTATION      | FIN_Share       | `DFIN_Agents` | HR000878         |
| IAMTYPE   | Elyxo            | User            | `DFIN_Agents` | HR000666         |
| IAMTYPE   | RACKSTATION      | FIN_Share       | `DFIN_Agents` | HR000666         |
| IAMTYPE   | Elyxo            | Admin           | `DFIN_Admins` | HR000007         |
| IAMTYPE   | RACKSTATION      | FIN_Share       | `DFIN_Admins` | HR000007         |

- `DFIN_Agents` role grants the `Elyxo/User` and `RACKSTATION/FIN_Share` permissions for the identities having the `HR000285`, `HR000878` and `HR000666` HR Codes.  
- `DFIN_Admins` role grants the `Elyxo/Admin` and `RACKSTATION/FIN_Share` permissions for the identities having the `HR000007` HR Code.  

The end-result might be the same, even if the model is not build the same way. Some methods require larger files, like using the HR code to define theoretical rights for each identity (instead of using the Job title for instance).  

The data collected using this target in the collector line can be retrieved the `Theoretical right model` in the views:  
![Theoretical rights model view](./images/view_theoretical_right_model.png)  

The content of this table will be used by the model policy.  

> There is **one** entry for **each** permission.  
>
> After this step made during the collect, **theoretical rights** between **Identities** and **Permissions** are not yet created. They will be created during the `Entitlement model policy` step, just after the manager policy step.

## Entitlement model policy

The entitlement model policy will use the data loaded by the collect in the `Theoretical right model` to determine for each permission the target population (identities).  

It is defined in the `model` folder of the project, and the logical is very similar to manager policy.

![Model policy project explorer](./images/theoretical_rights_project_explorer.png)  

![Model policy](./images/theoretical_rights_model_policy.png)  

Each rule defined in the `Theoretical right model` will be called, passing the parameter values set in the collect (see previous point) and returning identities that should have the associated permission.  

Based on their Job Title or HR code if we take the examples from earlier, associated model rules should be set as below:

- For Job

![Model rule with Job](./images/theoretical_rights_model_rule_job.png)  

- For HR code

![Model rule with Job](./images/theoretical_rights_model_rule_hrcode.png)  

For each rule, all **Identities** returned by it will be linked to the concerned **Permission** by a **Theoretical Right**. Those results of the model computation will be stored in the database, and can be retrieved from a view using the `Theoretical rights` entity:  

![Theoretical rights entity](./images/theoretical_rights_entity_view.png)  

> In the IAM collector facet, the computation is done using roles directly. The roles are assigned to identities, and the role content is loaded as the theoretical rights of each identity having the role.  

## Controls

Now that the model, theoretical rights and real rights are loaded, we can run controls to compute over-allocations and under-allocations.  

Theoretical rights controls are `type 5` controls (`Theoretical entitlements`), with the control result type determining over-allocations (=1) or under-allocations (=2).  

![Active identities rule](./images/theoretical_rights_control.png)

A theoretical rights control requires two rules that will determine the perimeter of real rights the controls are run on against the theoretical rights model:  

- Identities, for example active identities only

![Active identities rule](./images/theoretical_rights_active_identities_rule.png)

- Permissions, often permissions that are used to define the theoretical model

![Active identities rule](./images/theoretical_rights_granted_permissions_rule.png)

For each Identity/Permission couple returned by theses rules:  

- If the **Identity** has a **real right** and a **theoretical right** to the **Permission**, no discrepancy returned, we are in the normal situation
- If the **Identity** has a **real right** but no **theoretical right** to the **Permission**, a `overallocation` discrepancy is returned
- If the **Identity** has no **real right** but a **theoretical right** to the **Permission**, an `underallocation` discrepancy is returned
