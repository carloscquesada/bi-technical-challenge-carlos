with won_deals as (
    select
        hubspot_company_id,

        sum(
            case
                when deal_type = 'newbusiness'
                then amount
                else 0
            end
        ) as initial_contract_value,

        sum(
            case
                when deal_type = 'existing_business'
                then amount
                else 0
            end
        ) as expansion_value

    from {{ ref('stg_hubspot_deals') }}

    where is_closed_won = true

    group by 1
)

select
    c.company_id,
    c.company_name,

    coalesce(d.initial_contract_value, 0) as initial_contract_value,
    coalesce(d.expansion_value, 0) as expansion_value,

    coalesce(d.initial_contract_value, 0)
        + coalesce(d.expansion_value, 0) as current_contract_value

from {{ ref('mart_customers') }} c

left join won_deals d
    on c.company_id = d.hubspot_company_id