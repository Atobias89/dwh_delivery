{{
    config(
        materialized = 'incremental',
        unique_key = 'idem_payment',
        incremental_strategy = 'merge',
        merge_exclude_columns = ['created_at']
    )
}}


select 
     {{ dbt_utils.generate_surrogate_key([
     'payment_id',
      'payment_amount'
   ])}} as idem_payment,
    payment_id,    
    payment_amount,
    payment_fee,
    payment_method,
    payment_status,
    created_at,
    updated_at
from 
    {{ref('stg_payments')}}


{% if is_incremental() %}
    where updated_at > (select coalesce(max(updated_at), '1900-01-01') from {{this}})
{% endif %}