{{
    config(
        materialized = 'incremental',
        unique_key = 'driver_id',
        incremental_strategy = 'merge',
        merge_exclude_columns = ['created_at'],
        on_schema_change = 'sync_all_columns'
    )
}}

with drivers as (
    select
        driver_id,
        driver_modal,
        driver_type,
        CURRENT_DATE() created_at,
        CURRENT_DATE() updated_at
    from 
        {{source('deliv','drivers')}}
)

select 
        driver_id,
        driver_modal,
        driver_type,
        created_at,
        updated_at
from 
    drivers

{% if is_incremental() %}
  where updated_at > (select coalesce(max(updated_at),'1900-01-01') from {{this}})
{% endif %}