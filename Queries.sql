-- Generate 1000 random records for Rental_detail
INSERT INTO Rental_detail (ride_cost, start_time, end_time, end_location, start_location, bike_id, user_id)
select
	tab.index as ride_cost,
    tab.s_time  as start_time, -- Random start time within the last 30 days
    tab.s_time + random() * interval '10 hours' as end_time,   -- Random end time within the last 30 days
    concat_ws(', ', random() * 180 - 90, random() * 360 - 180) as end_location,    -- Random end location coordinates
    concat_ws(', ', random() * 180 - 90, random() * 360 - 180) as start_location,  -- Random start location coordinates
    floor(random() * 99 + 2) as bike_id,                -- Random bike_id between 2 and 100
    floor(random() * 5 + 1) as user_id                  -- Random user_id between 1 and 5;
from (select generate_series(1, 1000) as index,
	NOW() - random() * interval '200 days'  as s_time) tab
    
-- Q1. Summary of rental activities
SELECT
    u.user_id,
    u.first_name || ' ' || u.last_name AS user_name,
    COUNT(rd.rental_id) AS total_rentals,
    SUM(EXTRACT(EPOCH FROM (rd.end_time - rd.start_time)) / 60) AS total_rental_duration_minutes,
    AVG(rd.ride_cost) AS average_rental_cost
FROM Users u
LEFT JOIN Rental_detail rd ON u.user_id = rd.user_id
WHERE u.user_id = 2  -- Replace with the user ID you want to query
GROUP BY u.user_id, user_name;

-- Q2. Identify high-value users
SELECT u.first_name, u.last_name, u.email, MAX(rd.ride_cost) AS max_ride_cost
FROM Users u
JOIN Rental_detail rd ON u.user_id = rd.user_id
WHERE rd.start_time BETWEEN '2023-10-10' AND '2023-10-31'
GROUP BY u.first_name, u.last_name, u.email
HAVING MAX(rd.ride_cost) >= (
    SELECT AVG(ride_cost)
    FROM Rental_detail
    WHERE start_time BETWEEN '2023-10-10' AND '2023-10-31'
);

-- Q3. Rank users based on their ride costs by month and year
WITH UserRideCost AS (
    SELECT
        u.user_id,
        EXTRACT(YEAR FROM rd.start_time) AS ride_year,
        EXTRACT(MONTH FROM rd.start_time) AS ride_month,
        SUM(rd.ride_cost) AS total_ride_cost
    FROM Users u
    JOIN Rental_detail rd ON u.user_id = rd.user_id
    GROUP BY u.user_id, ride_year, ride_month
)
SELECT
    u.first_name,
    u.last_name,
    u.email,
    urc.ride_year,
    urc.ride_month,
    urc.total_ride_cost,
    RANK() OVER (PARTITION BY urc.ride_year, urc.ride_month ORDER BY urc.total_ride_cost DESC) AS rank
FROM Users u
JOIN UserRideCost urc ON u.user_id = urc.user_id
ORDER BY urc.ride_year, urc.ride_month, rank;
