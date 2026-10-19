select
    cast(contact_id as bigint) as contact_id,
    nullif(trim(first_name), '') as first_name,
    nullif(trim(last_name), '') as last_name,
    lower(nullif(trim(email), '')) as email,
    nullif(trim(job_title), '') as job_title,
    cast(hubspot_company_id as bigint) as hubspot_company_id,
    lower(nullif(trim(lifecycle_stage), '')) as lifecycle_stage,
    cast(create_date as timestamp) as created_at

from read_csv_auto(
    'data/hubspot_contacts.csv',
    header = true
)
