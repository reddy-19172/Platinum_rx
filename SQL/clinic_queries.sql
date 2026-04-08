-- ===============================
-- CLINIC MANAGEMENT SYSTEM
-- ===============================

DROP TABLE IF EXISTS clinics;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS clinic_sales;
DROP TABLE IF EXISTS expenses;

-- ===============================
-- CREATE TABLES
-- ===============================

CREATE TABLE clinics (
    cid VARCHAR(50) PRIMARY KEY,
    clinic_name VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50)
);

CREATE TABLE customer (
    uid VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100),
    mobile VARCHAR(20)
);

CREATE TABLE clinic_sales (
    oid VARCHAR(50) PRIMARY KEY,
    uid VARCHAR(50),
    cid VARCHAR(50),
    amount DECIMAL(10,2),
    datetime DATETIME,
    sales_channel VARCHAR(50),
    FOREIGN KEY (uid) REFERENCES customer(uid),
    FOREIGN KEY (cid) REFERENCES clinics(cid)
);

CREATE TABLE expenses (
    eid VARCHAR(50) PRIMARY KEY,
    cid VARCHAR(50),
    description VARCHAR(100),
    amount DECIMAL(10,2),
    datetime DATETIME,
    FOREIGN KEY (cid) REFERENCES clinics(cid)
);

-- ===============================
-- INSERT SAMPLE DATA
-- ===============================

INSERT INTO clinics VALUES
('C1','ABC Clinic','Hyderabad','Telangana','India'),
('C2','XYZ Clinic','Chennai','Tamil Nadu','India');

INSERT INTO customer VALUES
('U1','John','9999999999'),
('U2','Jane','8888888888');

INSERT INTO clinic_sales VALUES
('O1','U1','C1',2000,'2021-09-10','Online'),
('O2','U2','C1',3000,'2021-09-15','Offline'),
('O3','U1','C2',4000,'2021-09-20','Online');

INSERT INTO expenses VALUES
('E1','C1','Medicines',1500,'2021-09-12'),
('E2','C2','Equipment',2000,'2021-09-18');

-- ===============================
-- QUERIES
-- ===============================

-- 1. Revenue by sales channel
SELECT sales_channel,
       SUM(amount) AS revenue
FROM clinic_sales
WHERE YEAR(datetime)=2021
GROUP BY sales_channel;

-- 2. Top 10 customers
SELECT uid,
       SUM(amount) AS total_spent
FROM clinic_sales
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;

-- 3. Monthly revenue, expense, profit
WITH rev AS (
    SELECT DATE_FORMAT(datetime,'%Y-%m') AS month,
           SUM(amount) AS revenue
    FROM clinic_sales
    GROUP BY month
),
exp AS (
    SELECT DATE_FORMAT(datetime,'%Y-%m') AS month,
           SUM(amount) AS expense
    FROM expenses
    GROUP BY month
)
SELECT r.month,
       r.revenue,
       e.expense,
       (r.revenue - e.expense) AS profit,
       CASE WHEN (r.revenue - e.expense)>0
            THEN 'Profitable'
            ELSE 'Not Profitable'
       END AS status
FROM rev r
LEFT JOIN exp e ON r.month = e.month;

-- 4. Most profitable clinic per city
WITH profit AS (
    SELECT c.city, cs.cid,
           SUM(cs.amount) - COALESCE(SUM(e.amount),0) AS profit
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
    LEFT JOIN expenses e ON cs.cid = e.cid
    GROUP BY c.city, cs.cid
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY city ORDER BY profit DESC) AS rnk
    FROM profit
)
SELECT * FROM ranked WHERE rnk = 1;

-- 5. Second least profitable clinic per state
WITH profit AS (
    SELECT c.state, cs.cid,
           SUM(cs.amount) - COALESCE(SUM(e.amount),0) AS profit
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
    LEFT JOIN expenses e ON cs.cid = e.cid
    GROUP BY c.state, cs.cid
),
ranked AS (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY state ORDER BY profit ASC) AS rnk
    FROM profit
)
SELECT * FROM ranked WHERE rnk = 2;