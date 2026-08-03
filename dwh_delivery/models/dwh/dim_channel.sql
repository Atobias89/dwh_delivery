{{
    config(
        materialized = 'incremental',
        unique_key = 'idem_channel',
        incremental_strategy = 'merge',
        merge_exclude_columns = ['created_at']
    )
}}

with dim_channel as (
  select
    channel_id,
    channel_name,
    channel_type,
    created_at,
    updated_at
  from 
     {{ref('stg_channel')}}
)

select
   {{ dbt_utils.generate_surrogate_key([
     'channel_id',
      'channel_name'
   ])}} as idem_channel,
   channel_id,
   channel_name,
   channel_type,
   created_at,
   updated_at
  from 
    dim_channel

{% if is_incremental() %}
    where updated_at > (select coalesce(max(updated_at), '1900-01-01') from {{this}})
{% endif %}

     
