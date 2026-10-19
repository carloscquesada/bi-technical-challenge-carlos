select
    user_id,
    organization_id,
    lower(
        json_extract_string(event_properties, '$.user.email')
    ) as email,
    event_timestamp as user_created_at

from {{ ref('stg_backend_events') }}

where event_name = 'UserCreated'
  and json_extract_string(event_properties, '$.user.email') is not null