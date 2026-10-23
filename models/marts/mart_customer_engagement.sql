with dataset_bounds as (

    select
        cast(
            date_trunc('month', max(event_timestamp))
            - interval '1 month'
            as date
        ) as latest_complete_month

    from {{ ref('stg_backend_events') }}

),

analysis_window as (

    select
        latest_complete_month,
        cast(
            latest_complete_month - interval '2 months'
            as date
        ) as window_start_month

    from dataset_bounds

),

usage_last_3_complete_months as (

    select
        u.company_id,

        count(distinct u.activity_month)
            as active_months_last_3_complete_months,

        sum(u.meaningful_events)
            as meaningful_events_last_3_complete_months,

        round(
            sum(u.meaningful_events) / 3.0,
            1
        ) as avg_monthly_meaningful_events_last_3_complete_months,

        max(u.activity_month)
            as last_active_month_in_window

    from {{ ref('mart_customer_monthly_usage') }} u

    cross join analysis_window w

    where u.activity_month between
          w.window_start_month
          and w.latest_complete_month

    group by
        u.company_id

)

select
    c.company_id,
    c.company_name,
    c.organization_id,
    c.backend_users,

    cv.current_contract_value,

    w.window_start_month,
    w.latest_complete_month,

    coalesce(
        u.active_months_last_3_complete_months,
        0
    ) as active_months_last_3_complete_months,

    coalesce(
        u.meaningful_events_last_3_complete_months,
        0
    ) as meaningful_events_last_3_complete_months,

    coalesce(
        u.avg_monthly_meaningful_events_last_3_complete_months,
        0
    ) as avg_monthly_meaningful_events_last_3_complete_months,

    u.last_active_month_in_window,

    case
        when coalesce(
            u.meaningful_events_last_3_complete_months,
            0
        ) = 0
        then true
        else false
    end as customer_success_review_flag

from {{ ref('mart_customers') }} c

left join {{ ref('mart_customer_contract_value') }} cv
    on c.company_id = cv.company_id

left join usage_last_3_complete_months u
    on c.company_id = u.company_id

cross join analysis_window w

order by
    customer_success_review_flag desc,
    cv.current_contract_value desc