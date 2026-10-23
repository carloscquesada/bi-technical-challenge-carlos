select
    'W1' as retention_period,
    sum(w1_active_users) as retained_user_weeks,
    sum(cohort_size) as eligible_user_weeks,
    round(
        100.0 * sum(w1_active_users) / sum(cohort_size),
        1
    ) as retention_pct

from {{ ref('mart_user_weekly_retention') }}
where w1_active_users is not null

union all

select
    'W2',
    sum(w2_active_users),
    sum(cohort_size),
    round(
        100.0 * sum(w2_active_users) / sum(cohort_size),
        1
    )

from {{ ref('mart_user_weekly_retention') }}
where w2_active_users is not null

union all

select
    'W3',
    sum(w3_active_users),
    sum(cohort_size),
    round(
        100.0 * sum(w3_active_users) / sum(cohort_size),
        1
    )

from {{ ref('mart_user_weekly_retention') }}
where w3_active_users is not null

union all

select
    'W4',
    sum(w4_active_users),
    sum(cohort_size),
    round(
        100.0 * sum(w4_active_users) / sum(cohort_size),
        1
    )

from {{ ref('mart_user_weekly_retention') }}
where w4_active_users is not null

union all

select
    'W8',
    sum(w8_active_users),
    sum(cohort_size),
    round(
        100.0 * sum(w8_active_users) / sum(cohort_size),
        1
    )

from {{ ref('mart_user_weekly_retention') }}
where w8_active_users is not null