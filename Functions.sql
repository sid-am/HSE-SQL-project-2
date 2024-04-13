-- Registration function
CREATE OR REPLACE FUNCTION register_new_user(
    first_name VARCHAR,
    last_name VARCHAR,
    email VARCHAR,
    registration_date DATE,
    login VARCHAR,
    u_password VARCHAR,
    membership_type_id INT DEFAULT 1
)
RETURNS INT AS $$
DECLARE
    new_user_id INT;
BEGIN
    INSERT INTO Users (first_name, last_name, email, registration_date, login, u_password, membership_type_id)
    VALUES (first_name, last_name, email, registration_date, login, u_password, membership_type_id)
    RETURNING user_id INTO new_user_id;

    RETURN new_user_id;
END;
$$ LANGUAGE plpgsql;

select register_new_user('name', 'last_name', 'email@gmail.com', current_date, 'll', 'pp')

-- Membership update
CREATE OR REPLACE FUNCTION update_user_membership(
    u_id INT,
    m_id INT
)
RETURNS VOID AS $$
BEGIN
    UPDATE Users
    SET membership_type_id = m_id
    WHERE user_id = u_id;
END;
$$ LANGUAGE plpgsql;

select update_user_membership(6, 2)

-- A function of renting a bicycle
-- Rent start
CREATE OR REPLACE FUNCTION rent_bike(
    u_id INT,
    b_id INT
)
RETURNS INT AS $$
DECLARE
    new_rental_id INT;
   	new_location VARCHAR;
BEGIN
    -- Check if the bike is available for rent
    IF EXISTS (SELECT 1 FROM Bike WHERE bike_id = b_id AND status = 'available') THEN
        -- Get the current location of the bike
        SELECT current_location INTO new_location FROM Bike WHERE bike_id = b_id;

        -- Insert the rental record into the Rental_Detail table
        INSERT INTO Rental_Detail (user_id, bike_id, start_time, start_location)
        VALUES (u_id, b_id, NOW(), new_location)
       	RETURNING rental_id INTO new_rental_id;

        -- Update the bike status to 'rented' in the Bike table
        UPDATE Bike
        SET status = 'rented'
        WHERE bike_id = b_id;

        -- Return the newly generated rental ID
        RETURN new_rental_id;
    ELSE
        -- Bike is not available for rent
        RETURN NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

select rent_bike(1, 2)

-- Rent end
drop function end_rental
CREATE OR REPLACE FUNCTION end_rental(r_id INT)
RETURNS VOID AS $$
DECLARE
    duration_minutes INT;
    rental_start_time TIMESTAMP;
    rental_end_time TIMESTAMP;
    user_membership_id INT;
    rental_cost FLOAT;
BEGIN
    -- Get rental information and user's membership type
    SELECT rd.start_time, rd.end_time, u.membership_type_id
    INTO rental_start_time, rental_end_time, user_membership_id
    FROM Rental_detail rd
    JOIN Users u ON rd.user_id = u.user_id
    WHERE rd.rental_id = r_id;

    -- Calculate the duration of the rental in minutes
    duration_minutes := EXTRACT(EPOCH FROM rental_end_time - rental_start_time) / 60;

    -- Calculate the cost based on the membership price per minute
    SELECT (CASE
            WHEN duration_minutes > u.included_ride_time THEN
                (duration_minutes - u.included_ride_time) * u.price_per_min + u.start_price
            ELSE
                u.start_price
            END)
    INTO rental_cost
    FROM Membership u
    WHERE u.membership_type_id = user_membership_id;

    -- Update rental information
    UPDATE Rental_detail
    SET end_location = (SELECT current_location FROM Bike WHERE bike.bike_id = rental_detail.bike_id),
        end_time = current_timestamp,
        ride_cost = rental_cost
    WHERE rental_id = r_id;

    -- Mark the bike as 'available'
    UPDATE Bike
    SET status = 'available'
    WHERE bike_id = (SELECT bike_id FROM Rental_detail WHERE rental_id = r_id);

    RETURN;
END;
$$ LANGUAGE plpgsql;

select end_rental(1001)
