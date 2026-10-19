select
    cast(event_id as varchar) as event_id,
    nullif(trim(event_name), '') as event_name,
    cast(event_timestamp as timestamp) as event_timestamp,
    cast(user_id as varchar) as user_id,
    cast(organization_id as varchar) as organization_id,
    event_properties

from read_csv_auto(
    'data/backend_events.csv',
    header = true
)
