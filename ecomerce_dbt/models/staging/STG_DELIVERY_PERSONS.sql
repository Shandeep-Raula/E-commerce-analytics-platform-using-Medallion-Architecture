SELECT *
FROM {{ source('ecommerce_landing', 'raw_delivery_persons') }}