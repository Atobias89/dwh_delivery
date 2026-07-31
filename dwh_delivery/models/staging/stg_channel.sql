{{
    config(
        materialized = 'incremental',
        unique_key = 'channel_id',
        incremental_strategy = 'merge',
        merge_exclude_columns = ['created_at'],
        on_schema_change = 'sync_all_columns'
    )
}}

with channels as (
    select
        channel_id,
        channel_name,
        channel_type,
        CURRENT_DATE() created_at,
        CURRENT_DATE() updated_at
    from
        {{source('deliv','channels')}}
)

select
    channel_id,
    channel_name,
    channel_type,
    created_at,
    updated_at
from 
    channels

{% if is_incremental() %}
    where updated_at > (select coalesce(max(updated_at), '1900-01-01') from {{this}})
{% endif %}