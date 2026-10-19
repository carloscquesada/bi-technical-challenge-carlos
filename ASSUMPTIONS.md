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


## Q3 — User retention

I define retention using monthly signup cohorts.

A user is considered active in a month when they perform at least one meaningful product action:
- SearchCreated
- SearchUpdated
- SearchExecuted
- SearchExported
- SearchResultAppraised
- SearchResultFullTextAppraised
- LabelCreated
- LabelUpdated
- LabelDeleted

I exclude authentication and account-management events such as TokenGenerated, UserCreated, UserUpdated, OrganizationCreated and OrganizationUpdated because these do not necessarily represent meaningful product usage.

The dataset ends on 8 February 2026. Since February is incomplete, January 2026 is treated as the latest complete activity month.

Retention is calculated as exact-month cohort retention:
- M1 = active one month after signup
- M3 = active three months after signup
- M6 = active six months after signup

Only cohorts with a fully observable retention period are included in each aggregate metric.

Results across eligible cohorts:
- M1 retention: 99.3% (147 / 148)
- M3 retention: 96.6% (142 / 147)
- M6 retention: 95.1% (117 / 123)

As a secondary check, M1 retention is 100% among users belonging to paying customers and 95% among users belonging to non-customer organizations.


## Bonus insight — Product engagement

For the customer-engagement analysis, I use the same meaningful product events as the retention calculation.

The latest complete three-month period is November 2025 through January 2026.

Two customers had zero meaningful events during all three months:

- ZenithBio Oy: €24,000 current contract value, 5 backend users, last meaningful activity 2025-09-15
- PrecisionRx Inc: €12,000 current contract value, 3 backend users, last meaningful activity 2025-09-29

Together they represent €36,000 of current contract value.

I treat this as a Customer Success review signal rather than evidence of churn. The dataset does not contain renewal dates, expected usage thresholds, contracted seats or qualitative account-health information.