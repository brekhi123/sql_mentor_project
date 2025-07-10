# SQL Mentor User Performance Analysis

## Project Summary

This project explores user behavior and performance analytics using SQL. I worked with a structured dataset from a learning platform to extract meaningful insights about user submissions. The goal was to answer real-world questions about correctness, engagement, and scoring patterns by writing clear and efficient SQL queries.

## Skills Applied

* Aggregation using `COUNT`, `SUM`, `AVG`
* Conditional logic with `CASE WHEN`
* Ranking users using `DENSE_RANK()`
* Time-based analysis using `TO_CHAR()` and `EXTRACT()`
* Common Table Expressions (CTEs) for clean query structure

## Dataset Description

The dataset contains submission-level data from an online platform:

* `user_id`
* `question_id`
* `points` (positive for correct, negative for incorrect)
* `submitted_at` (timestamp)
* `username`


## Questions & Solutions

### 1. List All Distinct Users and Their Stats

**Goal**: Show each user’s total number of submissions and points earned.

```sql
SELECT 
    DISTINCT username, 
    COUNT(question_id) AS total_submissions, 
    SUM(points) AS points_earned
FROM user_submissions
GROUP BY username
ORDER BY total_submissions DESC;
```


### 2. Daily Average Points for Each User

**Goal**: For each day, calculate each user's average points.

```sql
SELECT
    TO_CHAR(submitted_at, 'DD-MM') AS day_m,
    username,
    AVG(points) AS daily_average
FROM user_submissions
GROUP BY day_m, username
ORDER BY day_m;
```


### 3. Top 3 Users with the Most Correct Submissions Per Day

**Goal**: Identify the top 3 users per day based on correct submissions.

```sql
WITH daily_submissions AS (
    SELECT
        TO_CHAR(submitted_at, 'DD-MM') AS daily,
        username,
        SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END) AS correct_submissions
    FROM user_submissions
    GROUP BY daily, username
),
users_rank AS (
    SELECT
        daily,
        username,
        correct_submissions,
        DENSE_RANK() OVER(PARTITION BY daily ORDER BY correct_submissions DESC) AS rank_r
    FROM daily_submissions
)
SELECT
    daily,
    username,
    correct_submissions
FROM users_rank
WHERE rank_r <= 3;
```


### 4. Top 5 Users with the Most Incorrect Submissions

**Goal**: Rank users by incorrect attempts and also show scoring breakdown.

```sql
WITH incorrect_sub_data AS (
    SELECT
        username,
        SUM(CASE WHEN points < 0 THEN 1 END) AS incorrect_submissions,
        SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END) AS correct_submissions,
        SUM(CASE WHEN points > 0 THEN points ELSE 0 END) AS points_for_correct_submission,
        -(SUM(CASE WHEN points < 0 THEN points ELSE 0 END)) AS points_lost_to_incorrect,
        SUM(points) AS total_points_earned
    FROM user_submissions
    GROUP BY username
)
SELECT *
FROM incorrect_sub_data
WHERE incorrect_submissions IS NOT NULL
ORDER BY incorrect_submissions DESC
LIMIT 5;
```


### 5. Top 10 Weekly Performers

**Goal**: Identify the top 10 users with the highest points per week.

```sql
SELECT *
FROM (
    SELECT
        EXTRACT(WEEK FROM submitted_at) AS week,
        username,
        SUM(points) AS total_points_earned,
        DENSE_RANK() OVER(PARTITION BY EXTRACT(WEEK FROM submitted_at) ORDER BY SUM(points) DESC) AS rank_w
    FROM user_submissions
    GROUP BY username, week
    ORDER BY week, total_points_earned DESC
)
WHERE rank_w <= 10;
```


## Conclusion

This project provided hands-on experience in analyzing user performance data with SQL. By combining aggregations, window functions, and date logic, I was able to answer analytical questions that reflect typical business use cases in edtech and user engagement platforms.
