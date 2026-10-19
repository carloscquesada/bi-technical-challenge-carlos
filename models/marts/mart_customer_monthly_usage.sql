with customer_users as (
    select
        u.user_id,
        m.hubspot_company_id
    from {{ ref('int_backend_users') }} u

    join {{ ref('int_organization_company_map') }} m
        on u.organization_id = m.organization_id

    join {{ ref('mart_customers') }} c
        on m.hubspot_company_id = c.company_id
),

monthly_activity as (
    select
        cu.hubspot_company_id,
        a.activity_month,
        count(distinct a.user_id) as active_users,
        sum(a.meaningful_events) as meaningful_events

    from customer_users cu

    join {{ ref('int_user_monthly_activity') }} a
        on cu.user_id = a.user_id

    group by
        cu.hubspot_company_id,
        a.activity_month
)

select
    c.company_id,
    c.company_name,
    a.activity_month,
    a.active_users,
    a.meaningful_events

from monthly_activity a

join {{ ref('mart_customers') }} c
    on a.hubspot_company_id = c.company_id