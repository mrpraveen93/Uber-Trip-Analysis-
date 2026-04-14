use capstone_project1;


describe uber_trip_data;
describe location_data;

select*from location_data;
select*from uber_trip_data;

select vehicle from uber_trip_data
group by vehicle;

# Uber_trip_data 

/*# KPI's

1.	Total Bookings – How many trips were booked over a given period?
2.	Total Booking Value – What is the total revenue generated from all bookings?
3.	Average Booking Value – What is the average revenue per booking?
4.	Total Trip Distance – What is the total distance covered by all trips?
5.	Average Trip Distance – How far are customers traveling on average per trip?
6.	Average Trip Time – What is the average duration of trips?

*/

# 1. Total Bookings

SELECT COUNT(trip_id) AS total_bookings
FROM uber_trip_data;

# 2. Total Booking Value

SELECT 
    ROUND(SUM(fare_amount + surge_fee),2 )AS total_booking_value
FROM uber_trip_data;

# 3. Average Booking values

SELECT 
   ROUND(AVG(fare_amount + Surge_Fee),2)AS average_booking_value
FROM uber_trip_data;

# 4. Total Trip Distance

SELECT 
    ROUND(SUM(trip_distance), 2) AS total_trip_distance
FROM uber_trip_data;

# 5.Average Trip Distance

SELECT 
    ROUND(avg(trip_distance), 2) AS total_trip_distance
FROM uber_trip_data;

# 6. Average Time Trip

SELECT 
    ROUND(
        AVG(
            TIMESTAMPDIFF(MINUTE, pickup_time, drop_off_time)
        ), 
    2) AS avg_trip_time_minutes
FROM uber_trip_data;

SELECT 
    DATE(pickup_time) AS trip_date,
    COUNT(trip_id) AS total_bookings,
    ROUND(SUM(fare_amount + surge_fee),2) AS total_revenue,
    ROUND(AVG(fare_amount + surge_fee),2) AS avg_booking_value,
    ROUND(SUM(trip_distance),2) AS total_distance,
    ROUND(AVG(trip_distance),2) AS avg_distance
FROM uber_trip_data
GROUP BY DATE(pickup_time)
ORDER BY trip_date;






# Q1. What are the busiest pickup hours?

SELECT HOUR(pickup_time) AS pickup_hour,
       COUNT(*) AS total_trips
FROM uber_trip_data
GROUP BY pickup_hour
ORDER BY total_trips DESC;

# Q2. What is the average trip distance and fare?

SELECT 
    ROUND(AVG(trip_distance),2) AS avg_distance,
    ROUND(AVG(fare_amount),2) AS avg_fare
FROM uber_trip_data;

# Q3. Which vehicle type generates the highest revenue?

SELECT vehicle,
       SUM(fare_amount + surge_fee) AS total_revenue
FROM uber_trip_data
GROUP BY vehicle
ORDER BY total_revenue DESC;

# Q4. How does surge pricing affect fare amount?

SELECT 
    CASE 
        WHEN surge_fee > 0 THEN 'Surge Applied'
        ELSE 'No Surge'
    END AS surge_status,
    ROUND(AVG(fare_amount),2) AS avg_fare
FROM uber_trip_data
GROUP BY surge_status;


# Q5. Which payment type is most commonly used?

SELECT payment_type,
       COUNT(*) AS total_trips
FROM uber_trip_data
GROUP BY payment_type
ORDER BY total_trips DESC;

# Q6. What is the average trip duration (in minutes)?

SELECT 
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, pickup_time, drop_off_time)),2)
    AS avg_trip_duration_minutes
FROM uber_trip_data;

# Q7. Passenger count vs number of trips

SELECT passenger_count,
       COUNT(trip_id) AS total_trips
FROM uber_trip_data
GROUP BY passenger_count
ORDER BY passenger_count;

# Q8. Top 5 pickup locations?

SELECT pulocationid,
       COUNT(*) AS total_pickups
FROM uber_trip_data
GROUP BY pulocationid
ORDER BY total_pickups DESC
LIMIT 5;

# Q9. Revenue generated per hour

SELECT HOUR(pickup_time) AS hour,
       SUM(fare_amount + surge_fee) AS revenue
FROM uber_trip_data
GROUP BY hour
ORDER BY revenue DESC;


# Q10. Identify long trips (above average distance)


SELECT *
FROM uber_trip_data
WHERE trip_distance >
      (SELECT AVG(trip_distance) FROM uber_trip_data);

# Q11. Which routes are most frequently used?


SELECT pulocationid,
       dolocationid,
       COUNT(*) AS total_trips
FROM uber_trip_data
GROUP BY pulocationid, dolocationid
ORDER BY total_trips DESC
LIMIT 5;

# Q12. Highest paying trips?

SELECT trip_id,
       fare_amount + surge_fee AS total_fare
FROM uber_trip_data
ORDER BY total_fare DESC
LIMIT 10;

# Q13. Daily trip volume

SELECT DATE(pickup_time) AS trip_date,
       COUNT(*) AS total_trips
FROM uber_trip_data
GROUP BY trip_date
ORDER BY trip_date;

# Q14. Average fare per passenger

SELECT passenger_count,
       ROUND(AVG(fare_amount),2) AS avg_fare
FROM uber_trip_data
GROUP BY passenger_count;

# Q15. Count Trips with zero surge fee

SELECT COUNT(*) AS no_surge_trips
FROM uber_trip_data
WHERE surge_fee = 0;



# Q16: How does revenue grow over time?

WITH daily_revenue AS (
    SELECT 
        DATE(pickup_time) AS trip_date,
        SUM(fare_amount + surge_fee) AS daily_revenue
    FROM uber_trip_data
    GROUP BY DATE(pickup_time)
)
SELECT 
    trip_date,
    daily_revenue,
    SUM(daily_revenue) 
        OVER (ORDER BY trip_date) AS running_revenue
FROM daily_revenue;


# Q17: Rank pickup hours by number of trips

SELECT 
    HOUR(pickup_time) AS pickup_hour,
    COUNT(*) AS total_trips,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS hour_rank
FROM uber_trip_data
GROUP BY pickup_hour;


# Q18: What are the highest-paying trips per vehicle?

WITH ranked_trips AS (
    SELECT 
        trip_id,
        vehicle,
        fare_amount + surge_fee AS total_fare,
        ROW_NUMBER() OVER (
            PARTITION BY vehicle 
            ORDER BY fare_amount + surge_fee DESC
        ) AS rn
    FROM uber_trip_data
)
SELECT *
FROM ranked_trips
WHERE rn <= 3;


# Q19: Is a trip above or below average fare?

SELECT 
    trip_id,
    fare_amount,
    ROUND(AVG(fare_amount) OVER (),2) AS avg_fare,
    CASE 
        WHEN fare_amount > AVG(fare_amount) OVER () 
        THEN 'Above Average'
        ELSE 'Below Average'
    END AS fare_category
FROM uber_trip_data;

# Q20: Rank pickup locations by revenue

SELECT 
    pulocationid,
    SUM(fare_amount + surge_fee) AS revenue,
    DENSE_RANK() OVER (
        ORDER BY SUM(fare_amount + surge_fee) DESC
    ) AS location_rank
FROM uber_trip_data
GROUP BY pulocationid;

# Q21: Which vehicle contributes most to revenue?

SELECT 
    vehicle,
    SUM(fare_amount + surge_fee) AS vehicle_revenue,
    ROUND(
        100 * SUM(fare_amount + surge_fee) /
        SUM(SUM(fare_amount + surge_fee)) OVER (),
    2) AS revenue_percentage
FROM uber_trip_data
GROUP BY vehicle;


# Q22: What is the longest trip each day?

WITH ranked_trips AS (
    SELECT 
        trip_id,
        DATE(pickup_time) AS trip_date,
        trip_distance,
        ROW_NUMBER() OVER (
            PARTITION BY DATE(pickup_time)
            ORDER BY trip_distance DESC
        ) AS rn
    FROM uber_trip_data
)
SELECT *
FROM ranked_trips
WHERE rn = 1;


# Q23: Compare trip distance within passenger groups

SELECT 
    passenger_count,
    trip_distance,
    ROUND(AVG(trip_distance) OVER (
        PARTITION BY passenger_count
    ),2) AS avg_distance_per_passenger_group
FROM uber_trip_data;




#  Location_data

# Q1. What are the busiest pickup hours?

SELECT HOUR(pickup_time) AS pickup_hour,
       COUNT(*) AS total_trips
FROM uber_trip_data
GROUP BY pickup_hour
ORDER BY total_trips DESC;








