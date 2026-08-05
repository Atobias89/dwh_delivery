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
        {{ dbt_utils.generate_surrogate_key([
            'order_id',
            'store_id',
            'channel_id', 
            'payment_order_id',
            'delivery_order_id',
            'order_status', 
            'order_amount',
            'order_delivery_fee',
            'order_delivery_cost',
            'order_created_hour',
            'order_created_minute',
            'order_created_day',
            'order_created_month',
            'order_created_year',
            'order_moment_created',
            'order_moment_accepted',
            'order_moment_ready',
            'order_moment_collected',
            'order_moment_in_expedition',
            'order_moment_delivering',
            'order_moment_delivered',
            'order_moment_finished',
            'order_metric_collected_time', 
            'order_metric_paused_time',
            'order_metric_production_time', 
            'order_metric_walking_time',
            'order_metric_expediton_speed_time',
            'order_metric_transit_time',
            'order_metric_cycle_time'
        ]) }} AS hash_diff,
        CURRENT_DATE() created_at,
        CURRENT_DATE() updated_at
    from 
       {{source('deliv','orders')}}    
)


select
        o.order_id,
        o.store_id ,
        o.channel_id, 
        o.payment_order_id,
        o.delivery_order_id,
        o.order_status, 
        o.order_amount,
        o.order_delivery_fee,
        o.order_delivery_cost,
        o.order_created_hour,
        o.order_created_minute,
        o.order_created_day,
        o.order_created_month,
        o.order_created_year,
        o.order_moment_created,
        o.order_moment_accepted,
        o.order_moment_ready,
        o.order_moment_collected,
        o.order_moment_in_expedition,
        o.order_moment_delivering,
        o.order_moment_delivered,
        o.order_moment_finished,
        o.order_metric_collected_time, 
        o.order_metric_paused_time,
        o.order_metric_production_time, 
        o.order_metric_walking_time,
        o.order_metric_expediton_speed_time,
        o.order_metric_transit_time,
        o.order_metric_cycle_time,
        o.hash_diff,
        o.created_at,
        o.updated_at
from
    orders o

{% if is_incremental() %}
    left join {{this}} t on t.order_id = o.order_id
    where t.order_id is null
    or  o.hash_diff !=  t.hash_diff
{% endif %}