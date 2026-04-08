-- ===============================
-- HOTEL MANAGEMENT SYSTEM
-- ===============================

-- DROP TABLES (optional)
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS booking_commercials;
DROP TABLE IF EXISTS items;

-- ===============================
-- CREATE TABLES
-- ===============================

CREATE TABLE users (
    user_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100),
    phone_number VARCHAR(20),
    mail_id VARCHAR(100),
    billing_address TEXT
);

CREATE TABLE bookings (
    booking_id VARCHAR(50) PRIMARY KEY,
    booking_date DATETIME,
    room_no VARCHAR(50),
    user_id VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE items (
    item_id VARCHAR(50) PRIMARY KEY,
    item_name VARCHAR(100),
    item_rate DECIMAL(10,2)
);

CREATE TABLE booking_commercials (
    id VARCHAR(50) PRIMARY KEY,
    booking_id VARCHAR(50),
    bill_id VARCHAR(50),
    bill_date DATETIME,
    item_id VARCHAR(50),
    item_quantity DECIMAL(10,2),
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    FOREIGN KEY (item_id) REFERENCES items(item_id)
);

-- ===============================
-- INSERT SAMPLE DATA
-- ===============================

INSERT INTO users VALUES
('U1','John Doe','9999999999','john@gmail.com','ABC Street'),
('U2','Jane Smith','8888888888','jane@gmail.com','XYZ Street');

INSERT INTO bookings VALUES
('B1','2021-11-10 10:00:00','R101','U1'),
('B2','2021-11-15 12:00:00','R102','U1'),
('B3','2021-10-05 09:00:00','R103','U2');

INSERT INTO items VALUES
('I1','Paratha',20),
('I2','Veg Curry',100),
('I3','Rice',50);

INSERT INTO booking_commercials VALUES
('C1','B1','BL1','2021-11-10 12:00:00','I1',5),
('C2','B1','BL1','2021-11-10 12:00:00','I2',2),
('C3','B2','BL2','2021-11-15 13:00:00','I3',3),
('C4','B3','BL3','2021-10-05 11:00:00','I2',15);

-- ===============================
-- QUERIES
-- ===============================

-- 1. Last booked room per user
SELECT user_id, room_no
FROM (
    SELECT user_id, room_no,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY booking_date DESC) AS rn
    FROM bookings
) t
WHERE rn = 1;

-- 2. Booking total billing (Nov 2021)
SELECT b.booking_id,
       SUM(bc.item_quantity * i.item_rate) AS total_amount
FROM bookings b
JOIN booking_commercials bc ON b.booking_id = bc.booking_id
JOIN items i ON bc.item_id = i.item_id
WHERE DATE_FORMAT(bc.bill_date, '%Y-%m') = '2021-11'
GROUP BY b.booking_id;

-- 3. Bills > 1000 (Oct 2021)
SELECT bc.bill_id,
       SUM(bc.item_quantity * i.item_rate) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE DATE_FORMAT(bc.bill_date, '%Y-%m') = '2021-10'
GROUP BY bc.bill_id
HAVING bill_amount > 1000;

-- 4. Most & Least ordered items per month
WITH item_orders AS (
    SELECT DATE_FORMAT(bill_date,'%Y-%m') AS month,
           item_id,
           SUM(item_quantity) AS qty
    FROM booking_commercials
    GROUP BY month, item_id
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY month ORDER BY qty DESC) AS r1,
           RANK() OVER (PARTITION BY month ORDER BY qty ASC) AS r2
    FROM item_orders
)
SELECT * FROM ranked WHERE r1=1 OR r2=1;

-- 5. Second highest bill per month
WITH bill_data AS (
    SELECT DATE_FORMAT(bill_date,'%Y-%m') AS month,
           bill_id,
           SUM(item_quantity * item_rate) AS total
    FROM booking_commercials bc
    JOIN items i ON bc.item_id = i.item_id
    GROUP BY month, bill_id
),
ranked AS (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY month ORDER BY total DESC) AS rnk
    FROM bill_data
)
SELECT * FROM ranked WHERE rnk = 2;