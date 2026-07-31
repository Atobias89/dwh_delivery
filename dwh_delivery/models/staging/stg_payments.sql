{{
    config(
        materialized='incremental',
        unique_key='payment_id',
        incremental_strategy='merge',
        merge_exclude_columns=['created_at'],
        on_schema_change='sync_all_columns'
    )
}}


with payment as (
    select 
        payment_id,
        payment_order_id,
        payment_amount,
        payment_fee,
        payment_method,
        payment_status,
        CURRENT_DATE() created_at,
        CURRENT_DATE() updated_at
    from 
        {{source('deliv','payments')}}
)

select 
    payment_id,
    payment_order_id,
    payment_amount,
    payment_fee,
    payment_method,
    payment_status,
    created_at,
    updated_at
from 
    payment

{% if is_incremental() %}
    where updated_at > (select coalesce(max(updated_at), '1900-01-01') from {{this}})
{% endif %}