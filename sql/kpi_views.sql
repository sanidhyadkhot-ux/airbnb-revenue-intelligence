
-- Executive KPI views
CREATE OR REPLACE VIEW vw_executive_kpis AS
SELECT
    COUNT(*) AS total_listings,
    ROUND(AVG(price_aud), 2) AS avg_price_aud,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_aud)::NUMERIC, 2) AS median_price_aud,
    ROUND(AVG(review_scores_rating), 2) AS avg_rating,
    ROUND(AVG(occupancy_proxy) * 100, 2) AS occupancy_proxy_pct,
    ROUND(AVG(is_superhost) * 100, 2) AS superhost_pct,
    ROUND(SUM(estimated_annual_revenue), 2) AS estimated_market_revenue
FROM vw_airbnb_clean;

CREATE OR REPLACE VIEW vw_suburb_revenue_rank AS
SELECT
    suburb,
    COUNT(*) AS listings,
    ROUND(AVG(price_aud), 2) AS avg_price,
    ROUND(AVG(review_scores_rating), 2) AS avg_rating,
    ROUND(SUM(estimated_annual_revenue), 2) AS estimated_revenue,
    RANK() OVER (ORDER BY SUM(estimated_annual_revenue) DESC) AS revenue_rank
FROM vw_airbnb_clean
GROUP BY suburb;
