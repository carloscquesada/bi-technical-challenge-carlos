# BI & Automations Engineer — Technical Challenge

## Overview

This project analyses HubSpot CRM data together with backend product events to answer three business questions:

1. How many customers do we have?
2. What is ACV?
3. What is user retention?

I used dbt with DuckDB locally to create a small, reproducible analytics pipeline with staging, intermediate and mart layers.

The focus was not only on calculating the metrics, but also on reconciling inconsistent signals across systems, documenting assumptions and creating reusable business-ready models.

---

## Key Results

| Metric | Result |
|---|---:|
| Customers | **26** |
| Current ACV | **€15,461.54** |
| Initial ACV | **€13,538.46** |
| M1 user retention | **99.3%** |
| M3 user retention | **96.6%** |
| M6 user retention | **95.1%** |

Bonus finding: two paying customers representing **€36,000 of current contract value** showed no meaningful product activity across the three latest complete months.

---

## Architecture

```text
Raw CSV exports
        ↓
Staging models
        ↓
Identity resolution / intermediate models
        ↓
Business marts
        ↓
Business metrics
```

### Staging

- `stg_hubspot_companies`
- `stg_hubspot_contacts`
- `stg_hubspot_deals`
- `stg_backend_events`

The staging layer performs basic cleaning, normalization and type casting while keeping the data close to the source.

### Intermediate

- `int_backend_users`
- `int_organization_company_map`
- `int_user_monthly_activity`

The intermediate layer handles reusable analytical logic such as cross-system identity resolution and meaningful monthly product activity.

### Marts

- `mart_customers`
- `mart_customer_contract_value`
- `mart_user_retention`
- `mart_customer_monthly_usage`

The marts expose business-ready datasets at clearly defined grains for answering the challenge questions.

---

# Results

## 1. Customers

**26 customers** based on the latest available dataset snapshot.

I define a customer as a HubSpot company with at least one Closed Won new-business deal.

I reconciled this definition against other customer signals:

- 253 HubSpot companies
- 37 backend product organizations
- 28 companies with contacts in HubSpot lifecycle stage `customer`
- 26 companies with a Closed Won new-business deal

All 26 Closed Won new-business companies also have a backend organization and customer-stage contacts.

Among the remaining 11 backend organizations:

- 9 are associated with opportunities rather than customers
- 1 has a lost deal but customer-stage contacts
- 1 has a lost deal plus an open deal but customer-stage contacts

I therefore use the Closed Won new-business definition as the most reliable commercial customer signal.

The supplied data has no explicit churn or contract-end field, so I assume Closed Won customers remain customers unless there is evidence indicating otherwise.

---

## 2. ACV

### Average current annual contract value per customer

**€15,461.54**

Calculation:

- 26 customers
- €352,000 Closed Won new-business value
- €50,000 Closed Won existing-business / upsell value
- €402,000 estimated current contract value

`€402,000 / 26 = €15,461.54`

### Average initial annual contract value per customer

For comparison, the average initial new-business contract value is:

**€13,538.46**

`€352,000 / 26 = €13,538.46`

I use current ACV as the primary metric because Closed Won existing-business deals are labelled as upsells and therefore appear to add contract value to existing customers.

All Closed Won deals are denominated in EUR, so no currency conversion is required.

The supplied data does not provide explicit contract duration, ARR, renewal or cancellation fields. I therefore assume that deal `amount` represents annual contract value and that Closed Won upsells are additive to the customer's existing annual contract value.

---

## 3. User Retention

I use monthly signup cohorts.

A user is considered retained when they perform at least one meaningful product action in the relevant month.

### Meaningful product activity

Included events:

- `SearchCreated`
- `SearchUpdated`
- `SearchExecuted`
- `SearchExported`
- `SearchResultAppraised`
- `SearchResultFullTextAppraised`
- `LabelCreated`
- `LabelUpdated`
- `LabelDeleted`

I exclude authentication and account-management activity such as:

- `TokenGenerated`
- `UserCreated`
- `UserUpdated`
- `OrganizationCreated`
- `OrganizationUpdated`

These events do not necessarily represent meaningful product usage. In particular, `TokenGenerated` can represent authentication or session refresh activity and could therefore inflate retention.

### Retention Results

| Retention period | Retained users | Eligible users | Retention |
|---|---:|---:|---:|
| M1 | 147 | 148 | **99.3%** |
| M3 | 142 | 147 | **96.6%** |
| M6 | 117 | 123 | **95.1%** |

- M1 = meaningful activity exactly one month after signup
- M3 = meaningful activity exactly three months after signup
- M6 = meaningful activity exactly six months after signup

The dataset ends on 8 February 2026. Because February is incomplete, January 2026 is treated as the latest complete activity month.

Only cohorts for which the relevant retention period is fully observable are included in each aggregate metric. Unobservable future retention periods are represented as `NULL`, rather than incorrectly reporting them as 0%.

As a secondary validation:

- M1 retention for users belonging to paying customers: **100.0%**
- M1 retention for users belonging to non-customer organizations: **95.0%**

The overall retention levels are unusually high. I therefore validated the result using only meaningful product events rather than authentication or administrative activity. The high retention remained and is reported as a characteristic of the supplied dataset.

---

# Bonus Insight — Commercial Value vs Product Engagement

I connected customer contract value with meaningful product usage to look for potentially relevant Customer Success signals.

Two paying customers representing **€36,000 of estimated current contract value** showed no meaningful product activity across the three latest complete months, November 2025 through January 2026:

| Customer | Current contract value | Backend users | Last meaningful activity |
|---|---:|---:|---|
| ZenithBio Oy | €24,000 | 5 | 15 Sep 2025 |
| PrecisionRx Inc | €12,000 | 3 | 29 Sep 2025 |

I would surface these accounts for Customer Success review.

I would not automatically classify them as churn risks because the supplied dataset does not contain renewal dates, contracted seats, expected usage thresholds or qualitative customer-health information.

The broader customer usage data also shows substantial variation between commercial value and product engagement. This suggests that combining CRM and product-usage data could support future customer-health monitoring and expansion analysis.

I deliberately did not create an arbitrary customer-health score because the business context required to define and validate such a score is not present in the supplied data.

---

# Data Quality and Reconciliation

## Cross-system identity resolution

The product backend and HubSpot do not share the same organization identifier.

Backend organizations use UUIDs, while HubSpot uses numeric company IDs.

I therefore created the following identity-resolution bridge:

```text
Backend user
    ↓
User email
    ↓
HubSpot contact
    ↓
HubSpot company
```

The backend contains:

- 150 users
- 150 unique user emails
- 37 backend organizations

All 150 backend users have an email in their `UserCreated` event, and all 150 emails match a HubSpot contact.

After resolving users to HubSpot companies, the 37 backend organizations map one-to-one to 37 HubSpot companies.

This validated bridge is used before combining CRM and product-behavior data.

## dbt data-quality tests

The project includes tests covering:

- primary-key uniqueness
- non-null identifiers
- contact-to-company relationships
- deal-to-company relationships
- accepted HubSpot lifecycle stages
- accepted deal types
- backend-user identity integrity
- backend-organization to HubSpot-company mapping integrity
- mart-level key integrity

The final project build passes all configured dbt tests.

---

# Important Grain Definitions

I established the grain of each model before joining data to avoid fan-out and double counting.

| Model | Grain |
|---|---|
| `stg_hubspot_companies` | One HubSpot company |
| `stg_hubspot_contacts` | One HubSpot contact |
| `stg_hubspot_deals` | One HubSpot deal |
| `stg_backend_events` | One backend product event |
| `int_backend_users` | One backend user |
| `int_organization_company_map` | One backend organization / HubSpot company mapping |
| `int_user_monthly_activity` | One user × month |
| `mart_customers` | One paying customer |
| `mart_customer_contract_value` | One paying customer |
| `mart_user_retention` | One signup cohort |
| `mart_customer_monthly_usage` | One paying customer × month with meaningful activity |

---

# Project Structure

```text
.
├── README.md
├── ASSUMPTIONS.md
├── AI_USAGE.md
├── dbt_project.yml
├── profiles.yml
├── models/
│   ├── staging/
│   │   ├── _staging.yml
│   │   ├── stg_backend_events.sql
│   │   ├── stg_hubspot_companies.sql
│   │   ├── stg_hubspot_contacts.sql
│   │   └── stg_hubspot_deals.sql
│   ├── intermediate/
│   │   ├── int_backend_users.sql
│   │   ├── int_organization_company_map.sql
│   │   └── int_user_monthly_activity.sql
│   └── marts/
│       ├── mart_customers.sql
│       ├── mart_customer_contract_value.sql
│       ├── mart_customer_monthly_usage.sql
│       └── mart_user_retention.sql
```

The raw `data/` directory is intentionally excluded from the submission ZIP. To run the project locally, create a `data/` directory and place the four supplied challenge CSV files inside it.

---

# How to Run

## Requirements

- dbt with DuckDB support
- Local copies of the supplied CSV files inside the `data/` directory

From the project root, validate the connection:

```bash
dbt debug --profiles-dir .
```

Build all models and run all configured tests:

```bash
dbt build --profiles-dir .
```

Example: inspect the customer mart:

```bash
dbt show --select mart_customers --limit 5
```

Example: inspect the retention mart:

```bash
dbt show --select mart_user_retention --limit -1
```

The project uses a local DuckDB database at:

```text
./flinn.duckdb
```

The generated database, raw CSV files, logs and dbt build artifacts are excluded from the submitted ZIP.

---

# Why DuckDB?

The challenge is based on local CSV exports and does not require production infrastructure.

DuckDB provides a lightweight local analytical database while still allowing the analysis to be structured as a dbt project.

This keeps the exercise reproducible without introducing unnecessary cloud infrastructure.

---

# Production Approach

For this take-home, the architecture is:

```text
CSV files → DuckDB → dbt → analytical marts
```

In a production environment, I would expect the equivalent architecture to look approximately like:

```text
Operational systems / product events
            ↓
Fivetran or other ingestion
            ↓
BigQuery
            ↓
dbt transformations and tests
            ↓
Omni / BI layer
            ↓
Business decisions and operational workflows
```

I would additionally introduce:

- dbt sources instead of direct CSV reads
- source freshness monitoring
- automated data-quality alerts
- Git-based pull-request review
- CI checks before deployment
- documented ownership of key business metrics
- explicit customer and revenue lifecycle fields
- a durable cross-system identity mapping instead of relying on email indefinitely
- monitoring for unexpected schema or volume changes

---

# Assumptions and Limitations

Detailed metric definitions, assumptions and known limitations are documented in:

`ASSUMPTIONS.md`

The most important limitations are:

- no explicit churn or contract-end field
- no explicit ARR field
- no explicit contract duration
- no renewal dates
- no contracted-seat information
- no predefined definition of meaningful product activity
- no native shared organization ID between HubSpot and the backend
- February 2026 contains only partial data

Where the data was ambiguous, I chose a defensible definition, validated it against other available signals and documented the assumption rather than silently treating it as fact.

---

# AI Assistance

AI assistance was used during development for setup guidance, SQL review, debugging, discussion of metric definitions and documentation support.

The analytical decisions, assumptions, source-data investigation and final results were manually reviewed and validated.

Full disclosure is available in:

`AI_USAGE.md`