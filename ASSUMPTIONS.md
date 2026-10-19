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

“Today” is interpreted as 8 February 2026, the latest date present in the dataset.


## Q2 — ACV definition

For this challenge, ACV is calculated including Closed Won existing-business and upsell deals in addition to the initial new-business contract value.

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

Retention is calculated weekly.

A weekly cohort consists of all users who performed at least one intentional product action during that calendar week.

A user is retained at W1, W2, W3, etc. when that same user performs at least one intentional product action exactly 1, 2, 3, etc. weeks after the cohort week.

Intentional product actions include:

- SearchCreated
- SearchUpdated
- SearchExecuted
- SearchExported
- SearchResultAppraised
- SearchResultFullTextAppraised
- LabelCreated
- LabelUpdated
- LabelDeleted

I exclude system and account-management events such as TokenGenerated, UserCreated, UserUpdated, OrganizationCreated and OrganizationUpdated because these do not necessarily represent intentional product usage.

The dataset ends on Sunday, 8 February 2026. Weeks are grouped using Monday as the start of the calendar week.

Only cohorts with a fully observable future retention period are included in each aggregate metric. Future periods that cannot yet be observed are represented as NULL rather than 0%.

Aggregate retention is weighted by cohort size.

Results:

- W1 retention: 86.0% (4,398 / 5,113 eligible active user-weeks)
- W2 retention: 85.7% (4,288 / 5,001)
- W3 retention: 85.8% (4,198 / 4,891)
- W4 retention: 85.2% (4,078 / 4,784)
- W8 retention: 84.1% (3,659 / 4,351)

Because this is exact-week retention rather than continuous survival retention, later retention rates do not have to decrease monotonically. A user may skip one week and return in a later week.

## Bonus insight — Product engagement

For the customer-engagement analysis, I use the same meaningful product events as the retention calculation.

The latest complete three-month period is November 2025 through January 2026.

Two customers had zero meaningful events during all three months:

- ZenithBio Oy: €24,000 current contract value, 5 backend users, last meaningful activity 2025-09-15
- PrecisionRx Inc: €12,000 current contract value, 3 backend users, last meaningful activity 2025-09-29

Together they represent €36,000 of current contract value.

I treat this as a Customer Success review signal rather than evidence of churn. The dataset does not contain renewal dates, expected usage thresholds, contracted seats or qualitative account-health information.