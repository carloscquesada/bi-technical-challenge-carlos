with won_new_business as (
    select
        hubspot_company_id,
        min(close_date) as first_customer_close_date,
        count(*) as won_new_business_deals,
        sum(amount) as new_business_value
    from {{ ref('stg_hubspot_deals') }}
    where is_closed_won = true
      and deal_type = 'newbusiness'
    group by 1
),

backend as (
    select
        hubspot_company_id,
        organization_id,
        backend_users
    from {{ ref('int_organization_company_map') }}
),

customer_contacts as (
    select
        hubspot_company_id,
        count(*) as customer_contacts
    from {{ ref('stg_hubspot_contacts') }}
    where lifecycle_stage = 'customer'
    group by 1
)

select
    c.company_id,
    c.company_name,
    c.country,
    c.industry,
    w.first_customer_close_date,
    w.won_new_business_deals,
    w.new_business_value,
    b.organization_id,
    b.backend_users,
    coalesce(cc.customer_contacts, 0) as customer_contacts

from won_new_business w

join {{ ref('stg_hubspot_companies') }} c
    on w.hubspot_company_id = c.company_id

left join backend b
    on c.company_id = b.hubspot_company_id

left join customer_contacts cc
    on c.company_id = cc.hubspot_company_id