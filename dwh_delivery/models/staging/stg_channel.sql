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
        {{dbt_utils.generate_surrogate_key(['channel_id',
            'channel_name',
            'channel_type'])}} hash_diff,
        CURRENT_DATE() created_at,
        CURRENT_DATE() updated_at
    from
        {{source('deliv','channels')}}
)

select
    c.channel_id,
    c.channel_name,
    c.channel_type,
    c.hash_diff,
    c.created_at,
    c.updated_at
from 
    channels c

{% if is_incremental() %}
    left join {{this}} t on c.channel_id = t.channel_id
    where t.channel_id is null 
        or c.hash_diff != t.hash_diff 
{% endif %}