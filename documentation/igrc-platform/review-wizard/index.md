---
title: Review wizard
description: How to use the review wizard
---

# Review wizard

## Overview

The notion of compliance is a growing concern in companies and in order to prove to auditors that application rights in IT systems are correctly managed, a methodology called User Access Review (UAR) can be set up.
However compliance is not the unique motivation. User Access Review is also one of the best ways to mitigate risks among:

- Financial fraud
- Data theft

Setting up a successful review is not an easy task. Preparation is the key. One must take care, among others, of the following aspects (in no particular order):

- Schedule the review so the result is available when the auditors come
- Check the data quality
- Define the scope of the review and the granularity of reviewed permissions
- Think about the organizational aspect and responsibilities (who will be accountable, responsible, contributors...)
- Setup a change management to help the reviewers in their task
- Define the communication before, during and after the review
- Plan the remediation
- Prepare reports for top management about compliance level and risk mitigation

One very important aspect is that the campaign manager (and his organization) gets a mandate from the top management.
Without this prerequisite, the campaign is not legitimate and is in risk even if the operational details are under control.

From the reviewers perspective, this review can be seen as a transfer of responsibilities. As a result, all reviewers want to spend as little time as possible on this task.
This is why the review should be as smart as possible so the reviewers accept this mission in a positive way.

Hopefully, many of these concerns are addressed by the Campaign wizard generator along with the Campaign manager described in this document.

> In the whole document, the terms **campaign** and **review** are used interchangeably and have the same meaning.

## Objectives

Identity Analytics expertise in UAR shows that all customers have different needs when setting up a review.
These difference may comes from:

- The purpose of the review (compliance, risk mitigation...),
- The company organization which is specific,
- The campaign frequency and the company deadlines,
- The people involved in the review,
- The business applications which are different,
- The scope of the review.

There are differences but the all reviews follow the common specifications described here:

- Reviews may be started manually or scheduled with a given frequency.
- A campaign has a start date, a due date and a scope.
- The reviewers are notified when they have a task. Reminders and escalations can occur to be sure that the task will be done.
- The campaign manager must be able to follow the review progress.
- The campaign has 2 phases: the review and the remediation.
- The user interface for a reviewer should be smart to allow (if desired) multiple sessions, mass decisions, asking for contributors...
- A timestamped report must be generated with the campaign result (scope, actors and decisions).
- Incremental scope should be supported.

The review wizard is the culmination of this expertise.
It offers a way to focus on the business aspects while the technical details and the common behaviour is already implemented.

## Campaign

### From the campaign manager perspective

From the campaign manager perspective, a compliance review is different than a risk based review.

In a compliance review, the major concerns are the **accuracy** and the **completeness**.
In this situation, the campaign manager must check that

- the ingested data has a very good quality and is accurate.
- the scope of the review is complete.

Some of the most important KPIs for the campaign manager in a compliance review are:

- The compliance level. This is the percentage of accounts or rights having been reviewed depending on the frequency.
- The remediation effectiveness. Is the remediation complete for all accounts or rights having a revoke or update status.

In a risk based review, the major concerns are the **risk mitigation** and the **efficiency**.
In this situation, the campaign manager tries to find the minimal scope which covers the highest risks.
The completeness is not a real concern.
The campaign scheduling is prepared to mitigate the highest risks as soon as possible and as often as possible.

Some of the most important KPIs for the campaign manager in a risk based review are:

- The number of mitigated discrepancies by risk level.
- The trend of the risk level because the risk mitigation is always a work in progress.

### From the reviewer perspective

From the reviewer perspective, the review must offer these benefits:

- the review should be as **easy** as possible to complete (meaning all the context involved in the decision should be available)
- the review should be as **fast** as possible because reviewers do not have much time to spend on this task.

The reviewer usually wants to handle all accounts or rights which are sharing the same characteristics in one go.
This is a natural way of thinking when there is too much accounts or rights to review.
