-- 가설3: 브랜드별로 매장들의 수익 분포는 고르게 분포되어 있을 것이다.

SELECT  b.brand_name,
        s.store_name,
        ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2) AS revenue,
        ROUND(RATIO_TO_REPORT(SUM(oi.quantity * oi.list_price * (1 - oi.discount))) 
              OVER (PARTITION BY b.brand_name) * 100, 2) AS pct_store_revenue
FROM    orders o
JOIN    order_items oi
ON      o.order_id = oi.order_id
JOIN    stores s
ON      o.store_id = s.store_id
JOIN    products p
ON      oi.product_id = p.product_id
JOIN    brands b
ON      p.brand_id = b.brand_id
GROUP BY b.brand_name, s.store_name
ORDER BY 1, 4 DESC;


--******
-- 결과
--******

-- 모든 브랜드에서 60~70% 수준의 매출이 Baldwin Bikes에 집중됨.
-- Santa Cruz Bikes 매장들은 대체로 브랜드에서 20% 전후의 매출을 차지.
-- Rowlett Bikes 매장들은 모든 브랜드의 10% 내외 매출 차지.


--******
-- 결론
--******

-- 모든 브랜드별 매출의 2/3 이상이 Baldwin Bikes에 몰림 -> Baldwin Bikes 매장 실적이 떨어지면, 브랜드 전체 매출이 큰 타격을 받음.
-- 매출 안정성을 위해 Santa Cruz / Rowlett 매장에서의 비중을 높이는 전략 필요.