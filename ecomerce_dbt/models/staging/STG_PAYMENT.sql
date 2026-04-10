SELECT *
FROM {{ source('ecommerce_landing', 'raw_payment') }}