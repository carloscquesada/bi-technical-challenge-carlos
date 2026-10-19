select
    cast(company_id as bigint) as company_id,
    trim(company_name) as company_name,
    lower(trim(domain)) as domain,
    nullif(trim(industry), '') as industry,
    nullif(trim(country), '') as country,
    nullif(trim(number_of_employees), '') as number_of_employees,
    cast(create_date as timestamp) as created_at

from read_csv_auto(
    'data/hubspot_companies.csv',
    header = true
)
