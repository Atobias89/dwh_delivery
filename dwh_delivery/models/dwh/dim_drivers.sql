
{{
    config(
        materialized = 'incremental',
        unique_key = 'idem_driver',
        incremental_strategy = 'merge',
        merge_exclude_columns = ['created_at'],
        on_schema_change='sync_all_columns'
    )
}}

with dim_driver as (
    select 
        driver_id,
        driver_modal,
        driver_type,
        created_at,
        updated_at
    from 
    {{ref('stg_drivers')}}
)


select 
    {{ dbt_utils.generate_surrogate_key([
        'driver_id',
        'driver_modal'
       ])}} as idem_driver,
        driver_id,
        driver_modal,
        driver_type,
        created_at,
        updated_at
from 
    dim_driver

{% if is_incremental() %}
  where updated_at > (select coalesce(max(updated_at),'1900-01-01') from {{this}})
{% endif %}