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
        {{ dbt_utils.generate_surrogate_key([
            'st.store_id',
            'st.store_name',
            'st.store_segment',
            'st.store_plan_price',
            'st.store_latitude',
            'st.store_longitude',
            'hb.hub_name',
            'hb.hub_city',
            'hb.hub_state',
            'hb.hub_latitude',
            'hb.hub_longitude'
        ]) }} AS hash_diff,
        CURRENT_DATE() created_at,
        CURRENT_DATE() updated_at
    from
        {{source('deliv','stores')}} st 
        left join {{source('deliv','hubs')}}  hb  on hb.hub_id = st.hub_id   
)

select
    s.store_id,  
    s.store_name,
    s.store_segment,
    s.store_plan_price,
    s.store_latitude,
    s.store_longitude,
    s.hub_name,
    s.hub_city,
    s.hub_state,
    s.hub_latitude,
    s.hub_longitude,
    s.hash_diff,
    s.created_at,
    s.updated_at
from 
    store s

{% if is_incremental() %}
    where s.store_id in (
        select store_id from store
        except 
        select store_id from  {{this}}
    ) or s.store_id in (
        select st.store_id  
        from store st 
        left join {{this}} t on st.store_id = t.store_id
        where st.hash_diff != t.hash_diff
    )
{% endif %}