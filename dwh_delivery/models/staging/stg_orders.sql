{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='merge',
        merge_exclude_columns=['created_at'],
        on_schema_change='sync_all_columns'
    )
}}


with orders as (
    select
        order_id,
        store_id ,
        channel_id, 
        payment_order_id,
        delivery_order_id,
        order_status, 
        order_amount,
        order_delivery_fee,
        order_delivery_cost,
        order_created_hour,
        order_created_minute,
        order_created_day,
        order_created_month,
        order_created_year,
        order_moment_created,
        order_moment_accepted,
        order_moment_ready,
        order_moment_collected,
        order_moment_in_expedition,
        order_moment_delivering,
        order_moment_delivered,
        order_moment_finished,
        order_metric_collected_time, 
        order_metric_paused_time,
        order_metric_production_time, 
        order_metric_walking_time,
        order_metric_expediton_speed_time,
        order_metric_transit_time,
        order_metric_cycle_time,
        CURRENT_DATE() created_at,
        CURRENT_DATE() updated_at
    from 
       {{source('deliv','orders')}}    
)


select
        order_id,
        store_id ,
        channel_id, 
        payment_order_id,
        delivery_order_id,
        order_status, 
        order_amount,
        order_delivery_fee,
        order_delivery_cost,
        order_created_hour,
        order_created_minute,
        order_created_day,
        order_created_month,
        order_created_year,
        order_moment_created,
        order_moment_accepted,
        order_moment_ready,
        order_moment_collected,
        order_moment_in_expedition,
        order_moment_delivering,
        order_moment_delivered,
        order_moment_finished,
        order_metric_collected_time, 
        order_metric_paused_time,
        order_metric_production_time, 
        order_metric_walking_time,
        order_metric_expediton_speed_time,
        order_metric_transit_time,
        order_metric_cycle_time,
        created_at,
        updated_at
from
    orders

{% if is_incremental() %}
    where updated_at > (select coalesce(max(updated_at), '1900-01-01') from {{this}})
{% endif %}