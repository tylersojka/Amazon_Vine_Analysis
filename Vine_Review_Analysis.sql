--Create the tables 

CREATE TABLE review_id_table (
  review_id TEXT PRIMARY KEY NOT NULL,
  customer_id INTEGER,
  product_id TEXT,
  product_parent INTEGER,
  review_date DATE -- this should be in the formate yyyy-mm-dd
);

-- This table will contain only unique values
CREATE TABLE products_table (
  product_id TEXT PRIMARY KEY NOT NULL UNIQUE,
  product_title TEXT
);

-- Customer table for first data set
CREATE TABLE customers_table (
  customer_id INT PRIMARY KEY NOT NULL UNIQUE,
  customer_count INT
);

-- vine table
CREATE TABLE vine_table (
  review_id TEXT PRIMARY KEY,
  star_rating INTEGER,
  helpful_votes INTEGER,
  total_votes INTEGER,
  vine TEXT,
  verified_purchase TEXT
);

-- Check tables were created
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- check data was loaded to tables
SELECT * 
FROM customers_table
ORDER BY customer_count DESC
LIMIT 10;

SELECT * 
FROM products_table
LIMIT 10;

SELECT *
FROM review_id_table
LIMIT 10;

SELECT *
FROM vine_table
WHERE total_votes >=20
ORDER BY total_votes DESC;

-- check data types
select COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH 
from INFORMATION_SCHEMA.COLUMNS 
where TABLE_NAME='vine_table';

-- Create new table with entries that have >= 20 total votes
SELECT *
into vine20plus
FROM vine_table
WHERE total_votes >=20
ORDER BY total_votes DESC;

--DROP TABLE vine20plus;
 -- Check the vine20plus table 
SELECT *
FROM vine20plus
ORDER BY total_votes DESC;

-- create a new table where the number of helpful votes / total votes >= 50%
SELECT *
into vine50percent 
FROM vine20plus
WHERE CAST(helpful_votes AS FLOAT)/CAST(total_votes AS FLOAT) >=0.5
ORDER BY total_votes DESC;

--DROP TABLE vine50percent;

-- check vine50percent table
SELECT *
FROM vine50percent
ORDER BY total_votes DESC;

-- filter for rows in vine program vine == Y
SELECT * 
INTO vine_yes
FROM vine50percent
WHERE vine = 'Y';

SELECT *
INTO vine_no
FROM vine50percent
WHERE vine = 'N';

SELECT * 
FROM vine_no;
select *
from vine_yes;

SELECT COUNT(review_id) reviews
from vine_yes;
SELECT COUNT(review_id) reviews, star_rating
from vine_yes
group by star_rating 
order by star_rating DESC;

SELECT COUNT(review_id) reviews, star_rating, (Count(review_id)* 100 / (Select Count(*) From vine_no)) as percent_total
from vine_no
group by star_rating
order by star_rating DESC;

-- no vine reviews grouped by star rating with count and percentage 
SELECT COUNT(review_id) reviews, star_rating, CAST((Count(review_id) * 100.0/(Select Count(*) From vine_no)) as decimal(2,0)) as Percentage
into vine_no_summary
from vine_no
group by star_rating
order by star_rating DESC;

-- yes vine reviews grouped by star rating with count and percentage 
SELECT COUNT(review_id) reviews, star_rating, CAST((Count(review_id) * 100.0/(Select Count(*) From vine_yes)) as decimal(2,0)) as Percentage
into vine_yes_summary
from vine_yes
group by star_rating
order by star_rating DESC;

-- starting to build the summary table
select *
from vine_yes_summary
LEFT JOIN vine_no_summary on vine_no_summary.star_rating= vine_yes_summary.star_rating

-- build the summary table
select vine_no_summary.star_rating, vine_no_summary.reviews as Vine_no_review_count, vine_no_summary.percentage as vine_no_percent, 
vine_yes_summary.reviews as Vine_yes_review_count, vine_yes_summary.percentage as vine_yes_percent 
from vine_yes_summary
LEFT JOIN vine_no_summary on vine_no_summary.star_rating= vine_yes_summary.star_rating