{{
    config(
        materialized = 'incremental',
        unique_key = 'idem_store',
        incremental_strategy = 'merge',
        merge_exclude_columns = ['created_at']
    )
}}

with dim_store as (
     select distinct
        store_id,  
        store_name,
        store_segment,
        store_plan_price,
        store_latitude,
        store_longitude,
        hub_name,
        hub_city,
        hub_state,
        hub_latitude,
        hub_longitude,
        created_at,
        updated_at
    from
        {{ref('stg_stores')}} 
)



select
     {{ dbt_utils.generate_surrogate_key([
     'store_id',
      'store_name'
   ])}} as idem_store,
    store_id,  
    store_name,
    store_segment,
    store_plan_price,
    store_latitude,
    store_longitude,
    hub_name,
    hub_city,
    hub_state,
    hub_latitude,
    hub_longitude,
    created_at,
    updated_at
from 
    dim_store

{% if is_incremental() %}
    where updated_at > (select coalesce(max(updated_at), '1900-01-01') from {{this}})
{% endif %}