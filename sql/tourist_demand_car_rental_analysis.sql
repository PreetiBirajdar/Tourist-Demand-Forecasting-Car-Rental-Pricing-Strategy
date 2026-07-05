/* 
Project: Tourist Demand Forecasting & Car Rental Pricing Strategy
Tools: SQLite, Excel, Tableau
Purpose: Clean raw datasets, analyze tourism demand, evaluate car rental pricing, and create dashboard-ready outputs.
*/


/* ============================================================
   1. DATA QUALITY CHECKS
   ============================================================ */

-- Check first 10 rows from car rental data
SELECT *
FROM car_rental_data
LIMIT 10;

-- Check first 10 rows from tourism data
SELECT *
FROM "Tourism_Hospitality_Industry_Analysis"
LIMIT 10;

-- Count total records in car rental dataset
SELECT COUNT(*) AS total_car_rental_records
FROM car_rental_data;

-- Count total records in tourism dataset
SELECT COUNT(*) AS total_tourism_records
FROM "Tourism_Hospitality_Industry_Analysis";

-- Check unique countries and cities in car rental data
SELECT DISTINCT country, city
FROM car_rental_data
ORDER BY country, city;

-- Check unique countries and cities in tourism data
SELECT DISTINCT Country, City
FROM "Tourism_Hospitality_Industry_Analysis"
ORDER BY Country, City;

-- Check missing values in car rental data
SELECT
    SUM(CASE WHEN airport IS NULL OR airport = '' THEN 1 ELSE 0 END) AS missing_airport,
    SUM(CASE WHEN city IS NULL OR city = '' THEN 1 ELSE 0 END) AS missing_city,
    SUM(CASE WHEN drive_away_price IS NULL OR drive_away_price = '' THEN 1 ELSE 0 END) AS missing_drive_away_price,
    SUM(CASE WHEN supplier_name IS NULL OR supplier_name = '' THEN 1 ELSE 0 END) AS missing_supplier,
    SUM(CASE WHEN average IS NULL THEN 1 ELSE 0 END) AS missing_average_rating
FROM car_rental_data;

-- Check missing values in tourism data
SELECT
    SUM(CASE WHEN Country IS NULL OR Country = '' THEN 1 ELSE 0 END) AS missing_country,
    SUM(CASE WHEN City IS NULL OR City = '' THEN 1 ELSE 0 END) AS missing_city,
    SUM(CASE WHEN Number_of_Tourists IS NULL OR Number_of_Tourists = '' THEN 1 ELSE 0 END) AS missing_tourists,
    SUM(CASE WHEN Tourism_Revenue_USD IS NULL OR Tourism_Revenue_USD = '' THEN 1 ELSE 0 END) AS missing_revenue,
    SUM(CASE WHEN Hotel_Occupancy_Rate IS NULL THEN 1 ELSE 0 END) AS missing_occupancy
FROM "Tourism_Hospitality_Industry_Analysis";


/* ============================================================
   2. CLEANING VIEWS
   ============================================================ */

-- Drop existing clean views if rerunning script
DROP VIEW IF EXISTS clean_car_rental_data;
DROP VIEW IF EXISTS clean_tourism_data;

-- Clean car rental data view
CREATE VIEW clean_car_rental_data AS
SELECT
    airport,
    airport_iata,
    country,
    city,
    rental_length,

    substr(start_date, 7, 4) || '-' || substr(start_date, 4, 2) || '-' || substr(start_date, 1, 2) AS start_date_clean,
    substr(return_date, 7, 4) || '-' || substr(return_date, 4, 2) || '-' || substr(return_date, 1, 2) AS return_date_clean,

    CAST(REPLACE(deposit_price, '$', '') AS REAL) AS deposit_price_num,
    CAST(REPLACE(drive_away_price, '$', '') AS REAL) AS drive_away_price_num,
    CAST(REPLACE(price, '$', '') AS REAL) AS price_num,

    currency,
    Car_name,
    product_id,
    doors,
    "group" AS car_group,
    seats,
    transmission,
    mileage,
    supplier_name,
    supplier_address,
    supplier_loction_type AS supplier_location_type,
    average AS supplier_rating,
    average_text,
    cleanliness,
    condition,
    efficiency,
    value_for_money,
    no_of_ratings,

    substr(RunDate, 7, 4) || '-' || substr(RunDate, 4, 2) || '-' || substr(RunDate, 1, 2) AS run_date_clean,

    setup_prams,
    tid
FROM car_rental_data;

-- Clean tourism data view
CREATE VIEW clean_tourism_data AS
SELECT
    Country,
    City,
    Year,
    Month,

    CAST(REPLACE(Number_of_Tourists, ',', '') AS INTEGER) AS number_of_tourists,
    Purpose_of_Visit,
    Average_Length_of_Stay,

    CAST(REPLACE(REPLACE(Tourist_Spending_USD, '$', ''), ',', '') AS REAL) AS tourist_spending_usd,

    Hotel_Occupancy_Rate,
    Number_of_Hotels,
    Hotel_Rating,

    CAST(REPLACE(REPLACE(Average_Room_Price_USD, '$', ''), ',', '') AS REAL) AS average_room_price_usd,
    CAST(REPLACE(REPLACE(Tourism_Revenue_USD, '$', ''), ',', '') AS REAL) AS tourism_revenue_usd,
    CAST(REPLACE(Employment_in_Tourism, ',', '') AS INTEGER) AS employment_in_tourism,

    Contribution_to_GDP_Percent,
    CAST(REPLACE(Number_of_Flights, ',', '') AS INTEGER) AS number_of_flights,
    Airport_Passenger_Traffic,
    Transport_Infrastructure_Quality,

    CAST(REPLACE(REPLACE(Eco_Tourism_Revenue_USD, '$', ''), ',', '') AS REAL) AS eco_tourism_revenue_usd,

    Carbon_Footprint_kg,
    Waste_Management_Rating,
    Tourist_Satisfaction_Score,
    CAST(REPLACE(Number_of_Online_Reviews, ',', '') AS INTEGER) AS number_of_online_reviews
FROM "Tourism_Hospitality_Industry_Analysis";


/* ============================================================
   3. CAR RENTAL PRICING ANALYSIS
   ============================================================ */

-- Average rental price by city
SELECT
    city,
    COUNT(*) AS total_listings,
    ROUND(AVG(drive_away_price_num), 2) AS avg_drive_away_price,
    MIN(drive_away_price_num) AS min_price,
    MAX(drive_away_price_num) AS max_price
FROM clean_car_rental_data
GROUP BY city
ORDER BY avg_drive_away_price DESC;

-- Average rental price by airport
SELECT
    airport,
    airport_iata,
    city,
    COUNT(*) AS total_listings,
    ROUND(AVG(drive_away_price_num), 2) AS avg_price
FROM clean_car_rental_data
GROUP BY airport, airport_iata, city
ORDER BY avg_price DESC;

-- Average rental price by car group
SELECT
    car_group,
    COUNT(*) AS total_listings,
    ROUND(AVG(drive_away_price_num), 2) AS avg_price,
    MIN(drive_away_price_num) AS lowest_price,
    MAX(drive_away_price_num) AS highest_price
FROM clean_car_rental_data
GROUP BY car_group
ORDER BY avg_price DESC;

-- Manual vs automatic pricing
SELECT
    transmission,
    COUNT(*) AS total_listings,
    ROUND(AVG(drive_away_price_num), 2) AS avg_price,
    ROUND(AVG(supplier_rating), 2) AS avg_supplier_rating
FROM clean_car_rental_data
GROUP BY transmission
ORDER BY avg_price DESC;

-- Supplier pricing and rating comparison
SELECT
    supplier_name,
    COUNT(*) AS total_listings,
    ROUND(AVG(drive_away_price_num), 2) AS avg_price,
    ROUND(AVG(supplier_rating), 2) AS avg_rating,
    ROUND(AVG(value_for_money), 2) AS avg_value_for_money,
    SUM(no_of_ratings) AS total_customer_ratings
FROM clean_car_rental_data
GROUP BY supplier_name
HAVING COUNT(*) >= 5
ORDER BY avg_rating DESC, avg_price ASC;

-- Best value suppliers
SELECT
    supplier_name,
    COUNT(*) AS total_listings,
    ROUND(AVG(drive_away_price_num), 2) AS avg_price,
    ROUND(AVG(supplier_rating), 2) AS avg_rating,
    ROUND(AVG(value_for_money), 2) AS avg_value_for_money,
    ROUND(AVG(supplier_rating) / AVG(drive_away_price_num), 4) AS rating_per_price_score
FROM clean_car_rental_data
GROUP BY supplier_name
HAVING COUNT(*) >= 5
ORDER BY rating_per_price_score DESC;


/* ============================================================
   4. TOURISM DEMAND ANALYSIS
   ============================================================ */

-- Tourist demand by country
SELECT
    Country,
    SUM(number_of_tourists) AS total_tourists,
    ROUND(AVG(Hotel_Occupancy_Rate), 2) AS avg_hotel_occupancy,
    SUM(number_of_flights) AS total_flights,
    SUM(tourism_revenue_usd) AS total_tourism_revenue
FROM clean_tourism_data
GROUP BY Country
ORDER BY total_tourists DESC;

-- Tourist demand by city
SELECT
    City,
    Country,
    SUM(number_of_tourists) AS total_tourists,
    ROUND(AVG(Hotel_Occupancy_Rate), 2) AS avg_hotel_occupancy,
    SUM(number_of_flights) AS total_flights,
    ROUND(AVG(Tourist_Satisfaction_Score), 2) AS avg_satisfaction
FROM clean_tourism_data
GROUP BY City, Country
ORDER BY total_tourists DESC;

-- Monthly tourism seasonality
SELECT
    Month,
    SUM(number_of_tourists) AS total_tourists,
    ROUND(AVG(Hotel_Occupancy_Rate), 2) AS avg_hotel_occupancy,
    SUM(number_of_flights) AS total_flights,
    SUM(tourism_revenue_usd) AS total_revenue
FROM clean_tourism_data
GROUP BY Month
ORDER BY Month;

-- Yearly tourism trend
SELECT
    Year,
    SUM(number_of_tourists) AS total_tourists,
    SUM(tourism_revenue_usd) AS total_revenue,
    ROUND(AVG(Hotel_Occupancy_Rate), 2) AS avg_occupancy,
    SUM(number_of_flights) AS total_flights
FROM clean_tourism_data
GROUP BY Year
ORDER BY Year;

-- Tourism purpose analysis
SELECT
    Purpose_of_Visit,
    COUNT(*) AS total_records,
    SUM(number_of_tourists) AS total_tourists,
    ROUND(AVG(Average_Length_of_Stay), 2) AS avg_length_of_stay,
    ROUND(AVG(tourist_spending_usd), 2) AS avg_spending,
    SUM(tourism_revenue_usd) AS total_revenue
FROM clean_tourism_data
GROUP BY Purpose_of_Visit
ORDER BY total_tourists DESC;


/* ============================================================
   5. ADVANCED BUSINESS ANALYSIS
   ============================================================ */

-- Rank cities by tourism demand and revenue
WITH city_demand AS (
    SELECT
        City,
        Country,
        SUM(number_of_tourists) AS total_tourists,
        SUM(tourism_revenue_usd) AS total_revenue,
        ROUND(AVG(Hotel_Occupancy_Rate), 2) AS avg_occupancy
    FROM clean_tourism_data
    GROUP BY City, Country
)

SELECT
    City,
    Country,
    total_tourists,
    total_revenue,
    avg_occupancy,
    RANK() OVER (ORDER BY total_tourists DESC) AS tourist_demand_rank,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM city_demand;


-- Classify cities into demand segments
WITH city_demand AS (
    SELECT
        City,
        Country,
        SUM(number_of_tourists) AS total_tourists,
        ROUND(AVG(Hotel_Occupancy_Rate), 2) AS avg_occupancy,
        SUM(number_of_flights) AS total_flights
    FROM clean_tourism_data
    GROUP BY City, Country
)

SELECT
    City,
    Country,
    total_tourists,
    avg_occupancy,
    total_flights,
    CASE
        WHEN total_tourists >= 500000 THEN 'High Demand'
        WHEN total_tourists >= 250000 THEN 'Medium Demand'
        ELSE 'Low Demand'
    END AS demand_segment
FROM city_demand
ORDER BY total_tourists DESC;


-- Monthly peak season classification
WITH monthly_demand AS (
    SELECT
        Month,
        SUM(number_of_tourists) AS total_tourists,
        ROUND(AVG(Hotel_Occupancy_Rate), 2) AS avg_occupancy,
        SUM(number_of_flights) AS total_flights
    FROM clean_tourism_data
    GROUP BY Month
),

demand_stats AS (
    SELECT
        AVG(total_tourists) AS avg_monthly_tourists
    FROM monthly_demand
)

SELECT
    m.Month,
    m.total_tourists,
    m.avg_occupancy,
    m.total_flights,
    CASE
        WHEN m.total_tourists > d.avg_monthly_tourists * 1.15 THEN 'Peak Season'
        WHEN m.total_tourists < d.avg_monthly_tourists * 0.85 THEN 'Low Season'
        ELSE 'Normal Season'
    END AS season_type
FROM monthly_demand m
CROSS JOIN demand_stats d
ORDER BY m.Month;


-- Supplier ranking using window functions
WITH supplier_summary AS (
    SELECT
        supplier_name,
        COUNT(*) AS total_listings,
        ROUND(AVG(drive_away_price_num), 2) AS avg_price,
        ROUND(AVG(supplier_rating), 2) AS avg_rating,
        ROUND(AVG(value_for_money), 2) AS avg_value_for_money,
        SUM(no_of_ratings) AS total_reviews
    FROM clean_car_rental_data
    GROUP BY supplier_name
    HAVING COUNT(*) >= 5
)

SELECT
    supplier_name,
    total_listings,
    avg_price,
    avg_rating,
    avg_value_for_money,
    total_reviews,
    RANK() OVER (ORDER BY avg_rating DESC) AS rating_rank,
    RANK() OVER (ORDER BY avg_price ASC) AS affordability_rank,
    RANK() OVER (ORDER BY avg_value_for_money DESC) AS value_rank
FROM supplier_summary
ORDER BY value_rank;


-- Car group pricing opportunity
WITH car_group_summary AS (
    SELECT
        car_group,
        COUNT(*) AS total_listings,
        ROUND(AVG(drive_away_price_num), 2) AS avg_price,
        ROUND(AVG(supplier_rating), 2) AS avg_rating,
        ROUND(AVG(value_for_money), 2) AS avg_value_for_money
    FROM clean_car_rental_data
    GROUP BY car_group
)

SELECT
    car_group,
    total_listings,
    avg_price,
    avg_rating,
    avg_value_for_money,
    CASE
        WHEN avg_price > 150 AND avg_rating >= 7 THEN 'Premium Opportunity'
        WHEN avg_price < 100 AND avg_value_for_money >= 7 THEN 'Budget Value Opportunity'
        WHEN avg_rating < 6 THEN 'Service Improvement Needed'
        ELSE 'Stable Segment'
    END AS pricing_opportunity
FROM car_group_summary
ORDER BY avg_price DESC;


-- Airport pricing segmentation
WITH airport_summary AS (
    SELECT
        airport,
        airport_iata,
        city,
        COUNT(*) AS total_listings,
        ROUND(AVG(drive_away_price_num), 2) AS avg_price,
        ROUND(AVG(supplier_rating), 2) AS avg_rating,
        ROUND(AVG(value_for_money), 2) AS avg_value_for_money
    FROM clean_car_rental_data
    GROUP BY airport, airport_iata, city
)

SELECT
    airport,
    airport_iata,
    city,
    total_listings,
    avg_price,
    avg_rating,
    avg_value_for_money,
    CASE
        WHEN avg_price >= 150 THEN 'High Price Airport'
        WHEN avg_price >= 100 THEN 'Mid Price Airport'
        ELSE 'Low Price Airport'
    END AS airport_price_segment
FROM airport_summary
ORDER BY avg_price DESC;


-- Tourism demand priority score
WITH city_metrics AS (
    SELECT
        City,
        Country,
        SUM(number_of_tourists) AS total_tourists,
        SUM(number_of_flights) AS total_flights,
        ROUND(AVG(Hotel_Occupancy_Rate), 2) AS avg_occupancy,
        SUM(tourism_revenue_usd) AS total_revenue
    FROM clean_tourism_data
    GROUP BY City, Country
),

ranked_metrics AS (
    SELECT
        City,
        Country,
        total_tourists,
        total_flights,
        avg_occupancy,
        total_revenue,
        RANK() OVER (ORDER BY total_tourists DESC) AS tourist_rank,
        RANK() OVER (ORDER BY total_flights DESC) AS flight_rank,
        RANK() OVER (ORDER BY avg_occupancy DESC) AS occupancy_rank,
        RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
    FROM city_metrics
)

SELECT
    City,
    Country,
    total_tourists,
    total_flights,
    avg_occupancy,
    total_revenue,
    tourist_rank,
    flight_rank,
    occupancy_rank,
    revenue_rank,
    tourist_rank + flight_rank + occupancy_rank + revenue_rank AS demand_priority_score
FROM ranked_metrics
ORDER BY demand_priority_score ASC;


-- Pricing strategy recommendation by month
WITH monthly_demand AS (
    SELECT
        Month,
        SUM(number_of_tourists) AS total_tourists,
        ROUND(AVG(Hotel_Occupancy_Rate), 2) AS avg_occupancy,
        SUM(number_of_flights) AS total_flights,
        SUM(tourism_revenue_usd) AS total_revenue
    FROM clean_tourism_data
    GROUP BY Month
),

demand_stats AS (
    SELECT
        AVG(total_tourists) AS avg_tourists
    FROM monthly_demand
)

SELECT
    m.Month,
    m.total_tourists,
    m.avg_occupancy,
    m.total_flights,
    m.total_revenue,
    CASE
        WHEN m.total_tourists > d.avg_tourists * 1.20 AND m.avg_occupancy >= 75 THEN 'Increase Rental Prices'
        WHEN m.total_tourists > d.avg_tourists AND m.avg_occupancy >= 65 THEN 'Maintain Premium Pricing'
        WHEN m.total_tourists < d.avg_tourists * 0.80 THEN 'Offer Discounts / Promotions'
        ELSE 'Maintain Standard Pricing'
    END AS pricing_strategy_recommendation
FROM monthly_demand m
CROSS JOIN demand_stats d
ORDER BY m.Month;


-- Join tourism demand with car rental pricing where city names match
WITH tourism_city_summary AS (
    SELECT
        LOWER(City) AS city_key,
        City,
        Country,
        SUM(number_of_tourists) AS total_tourists,
        ROUND(AVG(Hotel_Occupancy_Rate), 2) AS avg_occupancy,
        SUM(number_of_flights) AS total_flights
    FROM clean_tourism_data
    GROUP BY City, Country
),

rental_city_summary AS (
    SELECT
        LOWER(city) AS city_key,
        city,
        COUNT(*) AS rental_listings,
        ROUND(AVG(drive_away_price_num), 2) AS avg_rental_price,
        ROUND(AVG(supplier_rating), 2) AS avg_supplier_rating
    FROM clean_car_rental_data
    GROUP BY city
)

SELECT
    t.City,
    t.Country,
    t.total_tourists,
    t.avg_occupancy,
    t.total_flights,
    r.rental_listings,
    r.avg_rental_price,
    r.avg_supplier_rating,
    CASE
        WHEN t.total_tourists >= 500000 AND r.avg_rental_price < 100 THEN 'Potential Underpricing'
        WHEN t.total_tourists >= 500000 AND r.avg_rental_price >= 100 THEN 'Strong Demand with Premium Pricing'
        WHEN t.total_tourists < 250000 AND r.avg_rental_price > 150 THEN 'Potential Overpricing'
        ELSE 'Balanced Pricing'
    END AS demand_pricing_insight
FROM tourism_city_summary t
JOIN rental_city_summary r
    ON t.city_key = r.city_key
ORDER BY t.total_tourists DESC;


/* ============================================================
   6. DASHBOARD-READY QUERIES
   ============================================================ */

-- Dashboard Table 1: Tourism monthly demand
SELECT
    Month,
    SUM(number_of_tourists) AS total_tourists,
    ROUND(AVG(Hotel_Occupancy_Rate), 2) AS avg_hotel_occupancy,
    SUM(number_of_flights) AS total_flights,
    SUM(tourism_revenue_usd) AS total_tourism_revenue
FROM clean_tourism_data
GROUP BY Month
ORDER BY Month;


-- Dashboard Table 2: City tourism demand ranking
SELECT
    City,
    Country,
    SUM(number_of_tourists) AS total_tourists,
    ROUND(AVG(Hotel_Occupancy_Rate), 2) AS avg_hotel_occupancy,
    SUM(number_of_flights) AS total_flights,
    SUM(tourism_revenue_usd) AS total_tourism_revenue,
    ROUND(AVG(Tourist_Satisfaction_Score), 2) AS avg_satisfaction_score
FROM clean_tourism_data
GROUP BY City, Country
ORDER BY total_tourists DESC;


-- Dashboard Table 3: Car rental pricing by airport
SELECT
    airport,
    airport_iata,
    city,
    COUNT(*) AS total_listings,
    ROUND(AVG(drive_away_price_num), 2) AS avg_drive_away_price,
    MIN(drive_away_price_num) AS min_price,
    MAX(drive_away_price_num) AS max_price,
    ROUND(AVG(supplier_rating), 2) AS avg_supplier_rating
FROM clean_car_rental_data
GROUP BY airport, airport_iata, city
ORDER BY avg_drive_away_price DESC;


-- Dashboard Table 4: Supplier performance
SELECT
    supplier_name,
    COUNT(*) AS total_listings,
    ROUND(AVG(drive_away_price_num), 2) AS avg_price,
    ROUND(AVG(supplier_rating), 2) AS avg_rating,
    ROUND(AVG(cleanliness), 2) AS avg_cleanliness,
    ROUND(AVG(condition), 2) AS avg_condition,
    ROUND(AVG(efficiency), 2) AS avg_efficiency,
    ROUND(AVG(value_for_money), 2) AS avg_value_for_money,
    SUM(no_of_ratings) AS total_reviews
FROM clean_car_rental_data
GROUP BY supplier_name
HAVING COUNT(*) >= 5
ORDER BY avg_rating DESC;


-- Dashboard Table 5: Pricing recommendation by month
WITH monthly_demand AS (
    SELECT
        Month,
        SUM(number_of_tourists) AS total_tourists,
        ROUND(AVG(Hotel_Occupancy_Rate), 2) AS avg_occupancy,
        SUM(number_of_flights) AS total_flights,
        SUM(tourism_revenue_usd) AS total_revenue
    FROM clean_tourism_data
    GROUP BY Month
),

demand_stats AS (
    SELECT
        AVG(total_tourists) AS avg_tourists
    FROM monthly_demand
)

SELECT
    m.Month,
    m.total_tourists,
    m.avg_occupancy,
    m.total_flights,
    m.total_revenue,
    CASE
        WHEN m.total_tourists > d.avg_tourists * 1.20 AND m.avg_occupancy >= 75 THEN 'Increase Rental Prices'
        WHEN m.total_tourists > d.avg_tourists AND m.avg_occupancy >= 65 THEN 'Maintain Premium Pricing'
        WHEN m.total_tourists < d.avg_tourists * 0.80 THEN 'Offer Discounts / Promotions'
        ELSE 'Maintain Standard Pricing'
    END AS pricing_strategy_recommendation
FROM monthly_demand m
CROSS JOIN demand_stats d
ORDER BY m.Month;
