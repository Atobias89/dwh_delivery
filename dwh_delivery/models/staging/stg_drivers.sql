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
        {{dbt_utils.generate_surrogate_key([ 'driver_id',
        'driver_modal',
        'driver_type'])}} hash_diff,
        CURRENT_DATE() created_at,
        CURRENT_DATE() updated_at
    from 
        {{source('deliv','drivers')}}
)

select 
        d.driver_id,
        d.driver_modal,
        d.driver_type,
        d.hash_diff,      
        d.created_at,
        d.updated_at
from 
    drivers d

{% if is_incremental() %}
  left join {{this}} t on  d.driver_id = t.driver_id  
  where t.driver_id is null
      or d.hash_diff != t.hash_diff
{% endif %}