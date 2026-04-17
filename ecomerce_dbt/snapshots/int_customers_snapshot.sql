{% snapshot int_customers_snapshot %}

{{
    config(
        target_schema='SILVER',
        unique_key='CUSTOMER_ID',
        strategy='timestamp',
        updated_at='_LOADED_AT',
        tags=['snapshot', 'customers']
    )
}}

WITH base AS (

    SELECT
        CUSTOMER_ID,
        INITCAP(TRIM(FIRST_NAME || ' ' || LAST_NAME)) AS full_name,
        EMAIL,
        PHONE_NUMBER,
        UPPER(TRIM({{ gendermap('GENDER') }})) AS gender,
        TO_DATE(DATE_OF_BIRTH, 'DD-MM-YYYY') AS date_of_birth,   
        UPPER(TRIM(INCOME_BRACKET)) AS INCOME_BRACKET,
        UPPER(TRIM(MARITAL_STATUS)) AS MARITAL_STATUS,
        LOCATION_ID,
        TO_DATE(REGISTRATION_DATE, 'DD-MM-YYYY') AS registration_date,
        CREDIT_CARD_NUMBER,
        UPI_ID,
        _LOADED_AT,      
        {{ calculate_age('TO_DATE(DATE_OF_BIRTH, \'DD-MM-YYYY\')') }} AS age

    FROM {{ ref('STG_CUSTOMERS') }}

)

SELECT
    *,
    {{ age_category('age') }} AS age_group

FROM base

{% endsnapshot %}