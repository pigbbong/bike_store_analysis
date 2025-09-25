-- 가설4: 특정 브랜드는 매출이 한두 개 카테고리에 집중되어 있어, 해당 카테고리 수요 변화에 따라 매출 변동성이 커질 수 있다.

SELECT  b.brand_name,
        c.category_name,
        ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount))) AS revenue,
        ROUND(RATIO_TO_REPORT(SUM(oi.quantity * oi.list_price * (1 - oi.discount))) 
              OVER (PARTITION BY b.brand_name) * 100, 2) AS pct_category_revenue
FROM    order_items oi
JOIN    products p
ON      oi.product_id = p.product_id
JOIN    brands b
ON      p.brand_id = b.brand_id
JOIN    categories c
ON      p.category_id = c.category_id
GROUP BY b.brand_name, c.category_name
ORDER BY 1, 4 DESC;


--******
-- 결과
--******

-------------------
-- 1. 집중형 브랜드
-------------------

-- Heller, Pure Cycles, Ritchey, Strider → 단일 카테고리에 100% 집중.
-- Heller/Ritchey: Mountain Bikes
-- Pure Cycles: Cruisers Bicycles
-- Strider: Children Bicycles

-- -> 카테고리 의존도가 매우 높아, 특정 수요 변화에 크게 영향을 받을 수 있는 구조.


-------------------
-- 2. 편중형 브랜드
-------------------

-- Haro: Mountain Bikes(84%) 중심, Children(16%) 보조.

-- Electra → Cruisers(58%), Comfort(23%), Children(17%)으로 상위 3개 카테고리에 거의 매출 집중.
-- -> 사실상 1~2개 카테고리가 매출 대부분을 차지.


-------------------
-- 3. 분산형 브랜드
-------------------

-- Sun Bicycles: Cruisers(44%), Comfort(36%), Electric(14%), Mountain(6%).
-- -> 여러 카테고리에 매출이 비교적 고르게 분포 → 변동성 완화 가능.

-- Surly: Mountain(46%), Cyclocross(46%), Road(7%).
-- -> Mountain & Cyclocross 이원화 → 특정 카테고리에만 의존하지 않음.

-- Trek: Mountain(40%), Road(35%), Electric(18%), Cyclocross(6%).
-- -> 가장 다변화된 구조로 매출 안정성이 높음.


--******
-- 결론
--******
-- 브랜드마다 카테고리별 매출 집중도가 다르며, 일부 브랜드는 특정 카테고리에만 의존해 변동성이 크고, 반대로 Trek 같은 브랜드는 다변화를 통해 안정성을 확보하고 있음을 알 수 있음.