
-- Cleaning and feature engineering view
CREATE OR REPLACE VIEW vw_airbnb_clean AS
SELECT
    id,
    name,
    host_id,
    host_name,
    host_since,
    CASE WHEN host_is_superhost = 't' THEN 1 ELSE 0 END AS is_superhost,
    neighbourhood_cleansed AS suburb,
    latitude,
    longitude,
    property_type,
    room_type,
    accommodates,
    bedrooms,
    beds,
    CAST(REPLACE(REPLACE(price, '$', ''), ',', '') AS NUMERIC) AS price_aud,
    minimum_nights,
    availability_30,
    availability_60,
    availability_90,
    availability_365,
    number_of_reviews,
    number_of_reviews_ltm,
    review_scores_rating,
    review_scores_location,
    review_scores_value,
    reviews_per_month,
    CASE WHEN instant_bookable = 't' THEN 1 ELSE 0 END AS is_instant_bookable,
    1 - (availability_365::NUMERIC / 365) AS occupancy_proxy,
    CAST(REPLACE(REPLACE(price, '$', ''), ',', '') AS NUMERIC) * (1 - (availability_365::NUMERIC / 365)) * 365 AS estimated_annual_revenue
FROM stg_airbnb_listings
WHERE price IS NOT NULL;
