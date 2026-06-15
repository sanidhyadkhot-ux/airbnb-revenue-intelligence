
-- Advanced SQL: percentiles, ranking, opportunity segmentation
WITH suburb_stats AS (
    SELECT suburb, COUNT(*) listings, AVG(price_aud) avg_price, AVG(review_scores_rating) avg_rating,
           SUM(estimated_annual_revenue) revenue
    FROM vw_airbnb_clean
    GROUP BY suburb
), scored AS (
    SELECT *,
           NTILE(4) OVER (ORDER BY revenue) AS revenue_quartile,
           NTILE(4) OVER (ORDER BY avg_price) AS price_quartile,
           NTILE(4) OVER (ORDER BY avg_rating) AS rating_quartile
    FROM suburb_stats
)
SELECT suburb, listings, ROUND(avg_price,2) avg_price, ROUND(avg_rating,2) avg_rating, ROUND(revenue,2) revenue,
       CASE
           WHEN revenue_quartile >= 3 AND rating_quartile >= 3 THEN 'Scale and defend'
           WHEN price_quartile >= 3 AND listings < 100 THEN 'Premium expansion opportunity'
           WHEN listings >= 200 AND price_quartile <= 2 THEN 'Competitive price-sensitive market'
           ELSE 'Monitor'
       END AS commercial_strategy
FROM scored
ORDER BY revenue DESC;
