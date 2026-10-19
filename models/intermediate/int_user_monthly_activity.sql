select
    user_id,
    organization_id,
    cast(date_trunc('month', event_timestamp) as date) as activity_month,
    count(*) as meaningful_events

from {{ ref('stg_backend_events') }}

where event_name in (
    'SearchCreated',
    'SearchUpdated',
    'SearchExecuted',
    'SearchExported',
    'SearchResultAppraised',
    'SearchResultFullTextAppraised',
    'LabelCreated',
    'LabelUpdated',
    'LabelDeleted'
)

group by
    user_id,
    organization_id,
    cast(date_trunc('month', event_timestamp) as date)
    