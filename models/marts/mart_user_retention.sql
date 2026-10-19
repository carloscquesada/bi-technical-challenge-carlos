with users as (
    select
        user_id,
        cast(date_trunc('month', user_created_at) as date) as cohort_month
    from {{ ref('int_backend_users') }}
),

activity as (
    select
        user_id,
        activity_month
    from {{ ref('int_user_monthly_activity') }}

    -- February 2026 only contains partial data,
    -- so January 2026 is the latest complete month.
    where activity_month <= date '2026-01-01'
),

user_activity as (
    select
        u.user_id,
        u.cohort_month,
        a.activity_month,
        date_diff(
            'month',
            u.cohort_month,
            a.activity_month
        ) as months_since_signup

    from users u

    left join activity a
        on u.user_id = a.user_id
       and a.activity_month >= u.cohort_month
),

cohort_metrics as (
    select
        cohort_month,
        count(distinct user_id) as cohort_size,

        count(distinct case
            when months_since_signup = 0 then user_id
        end) as m0_active_users,

        count(distinct case
            when months_since_signup = 1 then user_id
        end) as m1_active_users,

        count(distinct case
            when months_since_signup = 2 then user_id
        end) as m2_active_users,

        count(distinct case
            when months_since_signup = 3 then user_id
        end) as m3_active_users,

        count(distinct case
            when months_since_signup = 6 then user_id
        end) as m6_active_users

    from user_activity

    group by cohort_month
)

select
    cohort_month,
    cohort_size,
    m0_active_users,

    case
        when cohort_month <= date '2025-12-01'
        then m1_active_users
    end as m1_active_users,

    case
        when cohort_month <= date '2025-11-01'
        then m2_active_users
    end as m2_active_users,

    case
        when cohort_month <= date '2025-10-01'
        then m3_active_users
    end as m3_active_users,

    case
        when cohort_month <= date '2025-07-01'
        then m6_active_users
    end as m6_active_users,

    case
        when cohort_month <= date '2025-12-01'
        then round(
            100.0 * m1_active_users / cohort_size,
            1
        )
    end as m1_retention_pct,

    case
        when cohort_month <= date '2025-10-01'
        then round(
            100.0 * m3_active_users / cohort_size,
            1
        )
    end as m3_retention_pct,

    case
        when cohort_month <= date '2025-07-01'
        then round(
            100.0 * m6_active_users / cohort_size,
            1
        )
    end as m6_retention_pct

from cohort_metrics

order by cohort_month