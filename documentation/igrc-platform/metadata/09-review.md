---
title: "Reviewing Metadata"
description: "How to review Metadata"
---

# Reviewing Metadata

As metadata can be used to document Ledger concepts and add or update information to many concepts in the portal, there is a need to review the modified information.
Reviewing information in the Identity Analytics product is done using a workflow which stores the reviewer's decisions in tickets (TicketReviews) in the Ledger.

## Creating metadata tickets

To be able to review metadata, the TicketReview target in the workflow editor has been enhanced to attach a ticket to a metadata

![Metadata ticket](./images/metadata_workflow_ticketreview.png "Metadata ticket")

This target supports multivalued attribute containing several metadata UIDs

## Reading tickets

The view editor allows the user query metadata tickets.

- From the metadata concept (that is a non embedded metadata), a link to the ticket review is available.
- From the ticket review, a link to the metadata is available.

Both queries automatically filter on the metadata name (in this example: `acme_user_case_1`).

The following screenshot shows the link between a ticket review and a metadata defined in the project.

![Metadata ticket to metadata](./images/metadata_ticket_to_metadata.png "Metadata ticket to metadata")

The following screenshot shows the same link reversed.

![Metadata to ticket](./images/metadata_to_ticket.png "Metadata to ticket")

When using tickets, the best practice is to avoid embedded metadata.
Tickets on embedded metadata are more difficult to query.
This is because metadata does not appear in the view (they are part of another Ledger entity).
For example, from an account, linking to ticket review is tricky because the link starts from the Account but is related to only a part of the account (not the account itself).

From a logical point of view, if a metadata has to be reviewed, it means that there is a life cycle for this metadata and it is better to keep it as a separate entity (not embedded).
