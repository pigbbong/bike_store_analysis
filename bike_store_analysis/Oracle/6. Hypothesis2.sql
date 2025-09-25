-- 가설2: 처음에 특정 브랜드를 산 고객군은, 이후에도 같은 브랜드에 충성할 가능성이 높다.

WITH customer_orders AS (
    SELECT  order_id,
            customer_id,
            rn,
            CASE
                WHEN MAX (rn) OVER (PARTITION BY customer_id) = 1 THEN 'new'
                ELSE 'repeat'
            END AS customer_type
    FROM    (
        SELECT  order_id,
                customer_id,
                order_date,
                ROW_NUMBER () OVER (PARTITION BY customer_id ORDER BY order_date) AS rn
        FROM    orders
    )
), 

repeat_customer AS (
    SELECT  order_id,
            customer_id,
            rn
    FROM    customer_orders
    WHERE   customer_type = 'repeat'
), 

purchase_brand AS (
    SELECT  rc.order_id,
            rc.customer_id,
            min(rc.rn) AS nth_purchase,
            min(b.brand_name) AS brand_name
    FROM    repeat_customer rc
    JOIN    order_items oi
    ON      rc.order_id = oi.order_id
    JOIN    products p
    ON      oi.product_id = p.product_id
    JOIN    brands b
    ON      p.brand_id = b.brand_id
    GROUP BY rc.order_id, rc.customer_id
),

first_brand AS (
    SELECT  customer_id, brand_name
    FROM    purchase_brand
    WHERE   nth_purchase = 1
),

brand_loyalty AS (
    SELECT  pb.customer_id, 
            pb.brand_name,
            CASE WHEN pb.brand_name = fb.brand_name THEN 1 ELSE 0 END AS is_loyal
    FROM    purchase_brand pb
    JOIN    first_brand fb
    ON      pb.customer_id = fb.customer_id
    WHERE   pb.nth_purchase > 1
)

SELECT  brand_name,
        SUM(is_loyal) AS loyal_purchases,
        COUNT(*) AS total_purchases,
        ROUND(SUM(is_loyal) * 100.0 / COUNT(*), 2) AS loyalty_rate
FROM    brand_loyalty
GROUP BY brand_name;


--******
-- 결과
--******

----------------------------------------
-- Electra = 충성 고객이 많은 브랜드
----------------------------------------
-- 재구매 고객 기반이 뚜렷함.


----------------------------------------
-- Trek = 매출 볼륨은 크지만, 충성도는 낮음
----------------------------------------
-- 매출 분석에서는 압도적 1위인 것에 반해, 충성도는 매우 낮음.
-- “인지도에 의해 첫 구매는 많지만, 유지 전략은 약하다”는 해석 가능.


----------------------------------------
-- 나머지 브랜드들
----------------------------------------
-- 충성 고객이 전무 -> 입문용/한시적 선택 브랜드 역할일 가능성이 큼.
-- 장기적인 고객 확보 전략은 실패, niche 성격 강함.


--******
-- 결론
--******
-- Electra 브랜드는 신규 고객 확보보다는 충성 고객 유지 전략(멤버십, 업그레이드 모델 제공 등)에 집중하는 것도 괜찮은 전략이 될 수 있음.
-- Trek 브랜드는 충성 고객층을 늘리기 위한 구매 고객에 대한 여러 프리미엄 해택 등의 전략을 고려해볼 필요가 있음.

