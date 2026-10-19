with weekly_activity as (
    select
        user_id,
        activity_week
    from {{ ref('int_user_weekly_activity') }}
),

cohort_retention as (
    select
        c.activity_week as cohort_week,

        count(distinct c.user_id) as cohort_size,

        count(distinct case
            when date_diff('week', c.activity_week, a.activity_week) = 1
            then c.user_id
        end) as w1_active_users,

        count(distinct case
            when date_diff('week', c.activity_week, a.activity_week) = 2
            then c.user_id
        end) as w2_active_users,

        count(distinct case
            when date_diff('week', c.activity_week, a.activity_week) = 3
            then c.user_id
        end) as w3_active_users,

        count(distinct case
            when date_diff('week', c.activity_week, a.activity_week) = 4
            then c.user_id
        end) as w4_active_users,

        count(distinct case
            when date_diff('week', c.activity_week, a.activity_week) = 8
            then c.user_id
        end) as w8_active_users

    from weekly_activity c

    left join weekly_activity a
        on c.user_id = a.user_id
       and a.activity_week >= c.activity_week

    group by 1
),

dataset_bounds as (
    select
        cast(date_trunc('week', max(event_timestamp)) as date) as latest_week
    from {{ ref('stg_backend_events') }}
)

select
    r.cohort_week,
    r.cohort_size,

    case
        when date_diff('week', r.cohort_week, b.latest_week) >= 1
        then r.w1_active_users
    end as w1_active_users,

    case
        when date_diff('week', r.cohort_week, b.latest_week) >= 2
        then r.w2_active_users
    end as w2_active_users,

    case
        when date_diff('week', r.cohort_week, b.latest_week) >= 3
        then r.w3_active_users
    end as w3_active_users,

    case
        when date_diff('week', r.cohort_week, b.latest_week) >= 4
        then r.w4_active_users
    end as w4_active_users,

    case
        when date_diff('week', r.cohort_week, b.latest_week) >= 8
        then r.w8_active_users
    end as w8_active_users,

    case
        when date_diff('week', r.cohort_week, b.latest_week) >= 1
        then round(100.0 * r.w1_active_users / r.cohort_size, 1)
    end as w1_retention_pct,

    case
        when date_diff('week', r.cohort_week, b.latest_week) >= 2
        then round(100.0 * r.w2_active_users / r.cohort_size, 1)
    end as w2_retention_pct,

    case
        when date_diff('week', r.cohort_week, b.latest_week) >= 3
        then round(100.0 * r.w3_active_users / r.cohort_size, 1)
    end as w3_retention_pct,

    case
        when date_diff('week', r.cohort_week, b.latest_week) >= 4
        then round(100.0 * r.w4_active_users / r.cohort_size, 1)
    end as w4_retention_pct,

    case
        when date_diff('week', r.cohort_week, b.latest_week) >= 8
        then round(100.0 * r.w8_active_users / r.cohort_size, 1)
    end as w8_retention_pct

from cohort_retention r
cross join dataset_bounds b

order by r.cohort_week