{{
    config(
        materialized='incremental',
        unique_key='store_id',
        incremental_strategy='merge',
        merge_exclude_columns=['created_at'],
        on_schema_change='sync_all_columns'
    )
}}


with store as (
    select 
        st.store_id,
        st.store_name,
        st.store_segment,
        st.store_plan_price,
        st.store_latitude,
        st.store_longitude,
        hb.hub_name,
        hb.hub_city,
        hb.hub_state,
        hb.hub_latitude,
        hb.hub_longitude,
        CURRENT_DATE() created_at,
        CURRENT_DATE() updated_at
    from
        {{source('deliv','stores')}} st 
        left join {{source('deliv','hubs')}}  hb  on hb.hub_id = st.hub_id   
)

select
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
    store

{% if is_incremental() %}
    where updated_at > (select coalesce(max(updated_at), '1900-01-01') from {{this}})
{% endif %}