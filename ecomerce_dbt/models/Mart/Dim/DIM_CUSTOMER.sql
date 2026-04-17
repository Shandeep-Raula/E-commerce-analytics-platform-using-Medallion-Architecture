{{ config(
    materialized='table',
    schema='GOLD',
    tags=['dimension', 'customer']
) }}

SELECT
    CUSTOMER_ID,
    DBT_SCD_ID AS CUSTOMER_SK,
    FULL_NAME,
    EMAIL,
    PHONE_NUMBER,
    GENDER,
    DATE_OF_BIRTH,
    INCOME_BRACKET,
    MARITAL_STATUS,
    LOCATION_ID,
    REGISTRATION_DATE,
    CREDIT_CARD_NUMBER,
    UPI_ID,
    AGE,
    AGE_GROUP
FROM {{ ref('int_customers_snapshot') }}
WHERE DBT_VALID_TO IS NULL