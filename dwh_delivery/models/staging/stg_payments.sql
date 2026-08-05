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
        {{dbt_utils.generate_surrogate_key([ 'payment_id',
            'payment_order_id',
            'payment_amount',
            'payment_fee',
            'payment_method',
            'payment_status'])}} hash_diff,
        CURRENT_DATE() created_at,
        CURRENT_DATE() updated_at
    from 
        {{source('deliv','payments')}}
)

select 
    p.payment_id,
    p.payment_order_id,
    p.payment_amount,
    p.payment_fee,
    p.payment_method,
    p.payment_status,
    p.hash_diff,
    p.created_at,
    p.updated_at
from 
    payment p

{% if is_incremental() %}
    where  p.payment_id in (
        select payment_id from payment
        except
        select payment_id from {{this}}
    )
    or p.payment_id in (
        select p.payment_id 
        from payment p
        left join {{this}} t on p.payment_id = t.payment_id
        where p.hash_diff != t.hash_diff
    )
{% endif %}