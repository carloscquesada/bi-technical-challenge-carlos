select
    u.organization_id,
    c.hubspot_company_id,
    count(distinct u.user_id) as backend_users

from {{ ref('int_backend_users') }} u

inner join {{ ref('stg_hubspot_contacts') }} c
    on u.email = c.email

group by
    u.organization_id,
    c.hubspot_company_id
    