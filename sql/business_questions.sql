
-- 10 business questions for portfolio storytelling

-- 1. Which suburbs generate the highest estimated annual revenue?
SELECT * FROM vw_suburb_revenue_rank ORDER BY estimated_revenue DESC LIMIT 10;

-- 2. Which room types have the strongest pricing power?
SELECT room_type, COUNT(*) listings, ROUND(AVG(price_aud),2) avg_price, ROUND(AVG(estimated_annual_revenue),2) avg_revenue
FROM vw_airbnb_clean GROUP BY room_type ORDER BY avg_revenue DESC;

-- 3. What is the price premium for superhosts?
SELECT is_superhost, COUNT(*) listings, ROUND(AVG(price_aud),2) avg_price, ROUND(AVG(review_scores_rating),2) avg_rating
FROM vw_airbnb_clean GROUP BY is_superhost;

-- 4. Which suburbs are premium but under-supplied?
SELECT suburb, COUNT(*) listings, ROUND(AVG(price_aud),2) avg_price, ROUND(AVG(review_scores_rating),2) avg_rating
FROM vw_airbnb_clean
GROUP BY suburb
HAVING COUNT(*) BETWEEN 20 AND 150
ORDER BY avg_price DESC LIMIT 15;

-- 5. Where is competition highest?
SELECT suburb, COUNT(*) listings, ROUND(AVG(price_aud),2) avg_price
FROM vw_airbnb_clean GROUP BY suburb ORDER BY listings DESC LIMIT 15;

-- 6. Are high ratings associated with higher prices?
SELECT CASE WHEN review_scores_rating >= 4.8 THEN 'Premium rating' WHEN review_scores_rating >= 4.5 THEN 'Good rating' ELSE 'Below premium' END rating_band,
COUNT(*) listings, ROUND(AVG(price_aud),2) avg_price
FROM vw_airbnb_clean GROUP BY rating_band ORDER BY avg_price DESC;

-- 7. Which hosts control the most supply?
SELECT host_id, host_name, COUNT(*) listings, ROUND(SUM(estimated_annual_revenue),2) estimated_revenue
FROM vw_airbnb_clean GROUP BY host_id, host_name ORDER BY listings DESC LIMIT 20;

-- 8. Which listings are high-value opportunities?
SELECT id, name, suburb, room_type, price_aud, review_scores_rating, estimated_annual_revenue
FROM vw_airbnb_clean
WHERE review_scores_rating >= 4.8 AND occupancy_proxy >= 0.5
ORDER BY estimated_annual_revenue DESC LIMIT 25;
