CREATE TABLE Membership
(
  membership_type_name VARCHAR NOT NULL,
  membership_type_id INT NOT NULL,
  membership_description VARCHAR,
  membership_price FLOAT NOT NULL,
  price_per_min FLOAT NOT NULL,
  start_price FLOAT NOT NULL,
  included_ride_time INT NOT NULL,
  PRIMARY KEY (membership_type_id)
);

CREATE TABLE Artist
(
  email VARCHAR NOT NULL,
  name VARCHAR NOT NULL,
  artist_id INT NOT NULL,
  PRIMARY KEY (artist_id)
);

CREATE TABLE Category
(
  category_name VARCHAR NOT NULL,
  category_id INT NOT NULL,
  PRIMARY KEY (category_id)
);

CREATE TABLE Repair_center
(
  center_id INT NOT NULL,
  location VARCHAR NOT NULL,
  phone_number VARCHAR NOT NULL,
  PRIMARY KEY (center_id)
);

CREATE TABLE Users
(
  user_id INT GENERATED ALWAYS AS IDENTITY (start with 1 increment by 1) NOT NULL,
  first_name VARCHAR NOT NULL,
  last_name VARCHAR NOT NULL,
  email VARCHAR NOT NULL,
  registration_date DATE NOT NULL,
  login VARCHAR NOT NULL,
  u_password VARCHAR NOT NULL,
  membership_type_id INT DEFAULT 1,
  PRIMARY KEY (user_id),
  FOREIGN KEY (membership_type_id) REFERENCES Membership(membership_type_id)
);

CREATE TABLE Model
(
  model_id INT NOT NULL,
  model_name VARCHAR NOT NULL,
  model_description VARCHAR,
  artist_id INT,
  category_id INT NOT NULL,
  PRIMARY KEY (model_id),
  FOREIGN KEY (artist_id) REFERENCES Artist(artist_id),
  FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

CREATE TABLE Model_photo
(
  photo_id INT NOT NULL,
  link VARCHAR NOT NULL,
  model_id INT NOT NULL,
  PRIMARY KEY (photo_id),
  FOREIGN KEY (model_id) REFERENCES Model(model_id)
);

CREATE TABLE Bike
(
  bike_id INT NOT NULL,
  serial_number INT NOT NULL,
  status VARCHAR NOT NULL,
  current_location VARCHAR,
  last_repair_date DATE,
  mileage INT NOT NULL,
  model_id INT NOT NULL,
  PRIMARY KEY (bike_id),
  FOREIGN KEY (model_id) REFERENCES Model(model_id)
);

CREATE TABLE Rental_detail
(
  rental_id INT NOT NULL GENERATED ALWAYS AS IDENTITY (start with 1 increment by 1),
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP,
  end_location VARCHAR,
  ride_cost FLOAT,
  start_location VARCHAR NOT NULL,
  bike_id INT NOT NULL,
  user_id INT NOT NULL,
  PRIMARY KEY (rental_id),
  FOREIGN KEY (bike_id) REFERENCES Bike(bike_id),
  FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE Maintenance
(
  repair_date_start DATE NOT NULL,
  repair_date_end DATE NOT NULL,
  repair_info VARCHAR,
  maintenance_id INT NOT NULL,
  bike_id INT NOT NULL,
  center_id INT NOT NULL,
  PRIMARY KEY (maintenance_id),
  FOREIGN KEY (bike_id) REFERENCES Bike(bike_id),
  FOREIGN KEY (center_id) REFERENCES Repair_center(center_id)
);
