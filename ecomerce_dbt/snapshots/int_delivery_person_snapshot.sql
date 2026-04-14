{% snapshot int_delivery_person_snapshot %}

{{
    config(
        target_schema='SILVER',
        unique_key='delivery_person_id',
        strategy='timestamp',
        updated_at='_LOADED_AT',
        tags=['snapshot', 'delivery_persons']
    )
}}

WITH delivery_persons AS (
select
    delivery_person_id   AS delivery_person_id,
    INITCAP(TRIM(delivery_person_name)) AS delivery_person_name,
    employment_type      AS employment_type,
    gender               AS gender,
    location_id          AS location_id,
    phone_number         AS phone_number,
    vehicle_type         AS vehicle_type,
    date_of_joining      AS date_of_joining,
    _loaded_at           AS _loaded_at
FROM {{ ref('STG_DELIVERY_PERSONS') }}
)
SELECT * FROM delivery_persons

{% endsnapshot %}