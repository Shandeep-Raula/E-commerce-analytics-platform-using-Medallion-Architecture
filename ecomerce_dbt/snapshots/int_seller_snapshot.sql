{% snapshot int_seller_snapshot %}

{{
    config(
        target_schema='SILVER',
        unique_key='SELLER_ID',
        strategy='timestamp',
        updated_at='_LOADED_AT',
        tags=['snapshot', 'sellers']
    )
}}

WITH seller AS (
select
    SELLER_ID,
    INITCAP(TRIM(SELLER_NAME)) AS SELLER_NAME,
    EMAIL,
    PHONE_NUMBER,
    TO_DATE(JOIN_DATE, 'DD-MM-YYYY') AS JOIN_DATE,
    LOCATION_ID,
    COALESCE(TRY_TO_DECIMAL(TO_VARCHAR(RATING), 2, 1), 0) AS RATING,
    UPPER(TRIM(CATEGORY_FOCUS)) AS CATEGORY_FOCUS,
    TO_VARCHAR(
    TRY_TO_NUMBER(BANK_ACCOUNT_NUMBER)
) AS BANK_ACCOUNT_NUMBER,
    IFSC_CODE,
    _LOADED_AT
    FROM {{ ref('STG_SELLERS') }}
)
SELECT * FROM seller

{% endsnapshot %}