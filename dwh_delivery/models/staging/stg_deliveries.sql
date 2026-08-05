
{{
    config(
        materialized = 'incremental',
        unique_key = 'delivery_id',
        incremental_strategy = 'merge',
        merge_exclude_columns = ['created_at'],
        on_schema_change = 'sync_all_columns'
    )
}}

with delivery as (
    select 
        delivery_id,
        delivery_order_id,
        driver_id,
        delivery_distance_meters,
        delivery_status,
        {{dbt_utils.generate_surrogate_key([ 'delivery_id',
            'delivery_order_id',
            'driver_id',
            'delivery_distance_meters',
            'delivery_status'])}} hash_diff,
        CURRENT_DATE() created_at,
        CURRENT_DATE() updated_at 
        from {{source('deliv','deliveries')}}   
)

select 
        d.delivery_id,
        d.delivery_order_id,
        d.driver_id,
        d.delivery_distance_meters,
        d.delivery_status,
        d.hash_diff,
        d.created_at,
        d.updated_at
from 
    delivery d



{% if is_incremental() %}
    left join {{this}} t on t.delivery_id = d.delivery_id
    where t.delivery_id is null
    or  d.hash_diff !=  t.hash_diff
{% endif %}