---
title: "Review wizard structure"
description: "Description of the review wizard structure"
---

# Review wizard structure

Before diving into the review editor and the details of each tab, we must understand the architecture of a review and how it is working.
This will be of great help to understand the impact of each setting in the review editor.

## General workflow architecture

Whatever the answer to the questions 'Who will review' and 'What will be reviewed' is, the generated workflow has the same architecture.
There is always a main process called 'master'. This process is the one launched when the campaign owner starts his campaign.

The master process finds how the reviewed items will be split. For an account review by repository managers, the split is by repository.
The master process launches as many sub-processes as entities for the split. For example, if we have 3 repositories, we will end up with 3 detail processes.

![Review workflow architecture](./images/review_workflow_architecture.png "Review workflow architecture")

The scope of the campaign defines 3 repositories to review: Active Directory, Elyxo repository and Sage repository.
The ledger contains also the repository managers. A single person may manage several repositories.
In this example, Marc Vegas manages both Elyxo and Sage repositories while Paul Martin manages Active Directory.

The role of the master process is to launch one detail sub-process by repository.
Marc Vegas manages 2 repositories so he will have 2 tasks in his task list and when taking the task for Elyxo, only the accounts related to Elyxo will be displayed in the review page.

The role of the detail sub-process is to send notifications to the reviewers and provide a task where they can decide what to do on each item.

When both Paul Martin and Marc Vegas have finished their review, the master process can generate a compliance report containing
all the decisions.

## Scope

When a review is started, the scope represents the list of items to review. The term 'scope' may have two meanings:

- scope definition
- scope result list

A scope definition is the business criteria used to select a part of the IT resources to review.
For example, a scope definition could be: all the privileged accounts having access to a financial application and having a discrepancy.
This looks like a query to filter accounts (or whatever will be reviewed)

A scope result list is the extensive list of accounts that matches the scope definition.
For example, a scope result list could be:

- CN=Domain Admin, CN=Users, DC=acme in ActiveDirectory
- root in LinFront
- SageAdmin in Sage

### Filtering by Who and What

A scope definition can also be seen as a matrix to match the 'Who' and the 'What'.
Let's take the example of a right review by the organization managers.
For the 'What', we want only privileged accounts of financial applications (Sage and SAP for example).
And for the 'Who', we want to target the managers of the 'Sales' division. Another review will take place later for the other organizations.

The following schema shows how both dimensions (rights and organizations) are handled in the scope.

![Review scope definition](./images/review_scope_definition.png "Review scope definition")

This schema shows that the rights involved in this review are filtered using criteria like the kind of account and the application name.
The 'What' is reduced to a subset of the rights.
On the other hand, from the list of organizations, the campaign owner selects only the 'Sales' division.
The 'Who' is reduced to one organization.

In a right review by organization, the organization manager can review only the rights belonging to the people working in the same organization.
Only for his team the manager knows if a right is OK or if it should be revoked.
So the next step is to combine the 'What' and the 'Who' to keep only the rights belonging to his team.
This is accomplished by the following filter:

- For each right, the review finds the account and then the identity owning this right.
- From the identity, the review finds which organization the identity is working in.
- The rights are kept only if the organization matches the selected organizations.

### Filtering by rules

The objective is to offer business filtering when launching a campaign.
In the campaign start page, a list of filters are available. Any combination of these filters can be selected.
When the campaign is launched, the item list is reduced to the items belonging to one of these filters.

When selecting multiple filters, the item are kept if they match at least one filter.

The filters are implemented as rules in the Identity Analytics product which means that complex filtering is available.
Here are some examples (from basic to sophisticated):

- accounts from the Elyxo repository
- accounts belonging to ActiveDirectory groups containing the word 'Admin'
- orphan accounts giving access to SAP
- active accounts belonging to an identity who has moved (job or organization) less that 3 month ago.

### Scope warning

When combining the 'Who' and the 'What', there is a potential issue with the completeness.
Let's continue with the previous example (right review by organization managers).

When the review is at the step of combining the list of filtered rights with the selected organizations, some rights may be filtered out:

- The rights for orphan accounts. These rights have no owner and no organization. When matching the organizations, these rights are filtered out.
- The rights for people in no organization. When matching the organizations, these rights are also filtered out.

These rights should be reviewed either in a specific review or in a specific case in the main review.
At the end of the day, as there is no organization, there is no manager to review these rights.
It means that this is a specific case where a reviewer should be assigned the task (it can be the campaign owner himself).

## Review pages

The user interface for the manager has 2 modes:

- a list of items to review with filtering and grouping facilities,
- a cross table to get a visual analysis of the scope to review.

Both working modes are explained below in the next paragraphs.

### List

The list is the default presentation. Each line is an item to review.
With the example of a right review by organization managers, the item is a right so the line displays the information representing this right.
This could be the account, the identity owning it, the permission and the application.

When an item is selected, details are shown in the right pane. This pane may contain one or more tabs, each one focusing on a different aspect.
With these details, the manager obtains the complete context (who has this right, what is his job, in which organization...) which is very important for the decision.

To review item, the manager can select one or several items and click on an action button (accept, revoke, update...) and add a comment if needed.
To handle several items by category (for example, all rights of a given identity), the user interface offers a way to group lines using a column.

The following screenshot shows the review list:

![Review list page](./images/review_list_page.png "Review list page")

Many options in this page can be customized like:

- columns displayed in the table,
- support for multiple selection,
- ability to add comments,
- list of actions available,
- list of detail tabs to display,
- availability of 'select all' feature.

### Cross table

The cross table is a table where each cell is an item to review.
The rows and the columns are dimensions about the item to review.
For example, with a right review, the rows can be the accounts and the columns the permissions.
Rows and columns may have several header levels.
Still with the right review, we can display a first header showing the identities and a second header showing the accounts of this identity.
For the columns, a first header line may contain applications and a second header line may contain the permissions.

The following screenshot shows the review crosstab:

![Review crosstab page](./images/review_crosstab_page.png "Review crosstab page")

Each header line or row is called a dimension. In this example we have 4 dimensions (2 dimensions in rows and 2 dimensions in columns).
All the features in the list mode are available in the cross table mode except the grouping.
But the cross table mode has a sort button that changes the rows and columns header to group the items by similarity.
In a right review, this would group people having the same permissions in a compact rectangle.
This is handy to select the rectangle and approve or revoke these rights.
This feature uses IA technology.

The cross table is not an alternative way of performing the review meaning that the list mode is not opposed to the cross table mode.
The activation of the cross table mode brings a major change in the review methodology as a whole as explained in the next section.

### Methodology

When there are many items to review, the methodology becomes important.
Following a methodology is not mandatory but helps performing the review in a minimum of time.

The methodology explained here is only a generic suggestion which has to be adapted to the company context, the kind of review, the kind of items...
To better understand the methodology, we are going to use the example of a right review by organization managers.
The basic idea is to divide the items to review into 3 groups:

- the discrepancies
- the similarities
- the remaining items

The first step is to review the items having some control discrepancies.
If many discrepancies are detected when starting the campaign, it may be useful to select the high risk discrepancies only so that the manager have less items in this first category.
This is an important step because the manager must be informed that keeping this right for a user is a risk for the company.
When all rights having discrepancies are handled, we can go to the second step which is based on similarities.

The second step uses the cross table representation. In this page, the manager should click on the icon to sort the table.

![Review crosstab page sorted](./images/review_crosstab_page_sorted.png "Review crosstab page sorted")

This operation changes both the columns and the rows to make some rectangles appear. These rectangles represent some people having the same rights.
Then, the manager looks at the identities and check that they are all from the same team or that they share the same business activities or job titles.
The manager can select the rectangle and click on Accept or Revoke.
This way, many rights are handle in one click.
The manager can click again on the sort button and start again with the next biggest rectangle.

Once all the rectangles are cleared, some individual cells (or very small rectangle) remain.
We can no longer work with similarities so we can come back to the list mode.
This is the third step where each right must be checked separately.
In this step, the context is very important to understand why a person is the only one to have a right or a combination of rights.

## Workflow tickets

The scope of the review and the decisions are stored as tickets in the Ledger. There are several kinds of tickets:

- TicketLog is the equivalent of the process. It contains which process has been launched by who and at which date.
- TicketAction represents a validated manual task. It contains which manual task has been validated by who and at which date.
- TicketReview is used to store the decision for a given reviewed item.

When the master process is started, it creates one TicketLog and one TicketAction representing respectively the process and the action of creating the process.
Then the process creates several TicketReview to remember the scope in the 'Who'.
In a right review by organization manager, a TicketReview is created for each organization.

The master process groups the organizations by managers and launches as many sub-processes as there are managers.

Each sub-process starts by creating one TicketLog and one TicketAction representing respectively the sub-process and the manager manual task.
When the manager has finished his review and validates his task, the TicketAction is updated with the name of the manager and the time of the task validation.
Then the sub-process creates as many TicketReview as items in the scope. Each TicketReview contains the decision along with the comment.

## Time based events

There are several time based events occurring in the review:

- reminders
- escalation reminders
- due date

The reminders and the escalation reminders trigger emails to campaign candidates.
The number of reminders and the time between two reminders are customizable.
All the configuration details are given in the chapter explaining the editor tabs.

The due date is entered by the campaign owner when he starts the campaign.
This due date is used to make all review tasks expire at the given date.
At this date, the candidates can no longer take the tasks (they are removed from their task list) and the whole campaign is finished.

The due date is used to compute the reminders backward in time.
For example send 3 notification reminders with 5 business days between each one.

## Emails

All the task notifications, the reminders and the escalation notifications are sent using emails.
These emails can be customized (change the title, the body, the attachments...) and nationalized (the identity language is used).
The following screenshot shows a notification email received by a manager:

![Review notification email](./images/review_notification_email.png "Review notification email")

## Compliance report

When a manager finishes his review, a report is generated for his scope.
When all the managers have finished, the main process generates a compliance report with all scopes consolidated.
The following screenshot is the first page of the compliance report/

![Review compliance report](./images/review_main_report.png "Review compliance report")

> The compliance report is always generated even if the due date was reached before all reviewers have finished and
even if the campaign is killed.
