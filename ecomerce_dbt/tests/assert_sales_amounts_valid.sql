-- Fails if quantity is not positive, any amount is negative,
-- a discount exceeds the gross amount, or a refund exceeds the order value.
select
    order_line_id,
    quantity,
    unit_price,
    gross_amount,
    discount_amount,
    tax_amount,
    shipping_fee,
    order_value,
    refund_amount
from {{ ref('FACT_SALES') }}
where quantity <= 0
   or unit_price < 0
   or gross_amount < 0
   or discount_amount < 0
   or tax_amount < 0
   or shipping_fee < 0
   or order_value < 0
   or refund_amount < 0
   or discount_amount > gross_amount
   or refund_amount > order_value
