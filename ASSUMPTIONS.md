# Assumptions

## Q1 — Customer definition

I define a customer as a HubSpot company with at least one Closed Won new-business deal.

I compared this against two other signals:
- customer lifecycle stages in HubSpot contacts
- organizations/users existing in the product backend

26 companies matched all three signals.

There are 11 additional backend organizations without a Closed Won new-business deal:
- 9 appear to still be sales opportunities
- 1 has a lost deal but contacts marked as customers
- 1 has a lost deal and an open deal but contacts marked as customers

I therefore did not count these 11 as customers.

The supplied data does not contain an explicit churn or contract-end field, so I assume a Closed Won new-business customer remains a customer unless there is evidence otherwise.


## Q2 — ACV definition

I interpret ACV primarily as the current annual contract value per customer.

The deal names identify the initial contracts as "Annual License", and I treat Closed Won existing-business / upsell deals as additive annual contract value.

Using this definition:
- 26 customers
- €352,000 initial new-business contract value
- €50,000 Closed Won upsells
- €402,000 current contract value
- Current ACV = €15,461.54

For comparison, the average initial new-business contract value is €13,538.46.

The supplied data does not include explicit contract duration, renewal, cancellation, or ARR fields, so this calculation assumes deal `amount` represents annual recurring contract value.