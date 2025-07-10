

-- Q.1 List all distinct users and their stats (return user_name, total_submissions, points earned)

-- Q.2 Calculate the daily average points for each user.

-- Q.3 Find the top 3 users with the most correct submissions for each day.

-- Q.4 Find the top 5 users with the highest number of incorrect submissions.

-- Q.5 Find the top 10 performers for each week.



-- Q1
SELECT 
    DISTINCT username, 
        COUNT(question_id) AS total_submissions, 
        SUM (points) AS points_earned
FROM
    user_submissions
GROUP BY username
ORDER BY total_submissions DESC;

-- Q2
-- Each day
-- Each User and their daily avg points
SELECT
    TO_CHAR(submitted_at, 'DD-MM') AS day_m,
    username,
    AVG(points) AS daily_average
FROM 
    user_submissions
GROUP BY 
    day_m, username
ORDER BY day_m;

-- Q3
SELECT
    TO_CHAR(submitted_at, 'DD-MM') AS day_m,
    username,
    SUM(CASE
        WHEN points > 0 THEN 1 ELSE 0
        END) AS correct_submissions
FROM 
    user_submissions
GROUP BY 
    day_m, username
ORDER BY 
    day_m,
    correct_submissions DESC;

--Q3
WITH daily_submissions AS
    (
    SELECT
        TO_CHAR(submitted_at, 'DD-MM') AS daily,
        username,
        SUM(CASE
            WHEN points > 0 THEN 1 ELSE 0
            END) AS correct_submissions
    FROM 
        user_submissions
    GROUP BY 
        daily, 
        username
    ),
users_rank AS
    (SELECT
        daily,
        username,
        correct_submissions,
        DENSE_RANK() OVER(PARTITION BY daily ORDER BY correct_submissions DESC) AS rank_r
    FROM
        daily_submissions)
SELECT
    daily,
    username,
    correct_submissions
FROM
    users_rank
WHERE rank_r <=3;


--Q4
WITH incorrect_sub_data AS
    (SELECT
        username,
        SUM(CASE
            WHEN points < 0 THEN 1 
            END) AS incorrect_submissions,

        SUM(CASE
        WHEN points > 0 THEN 1 ELSE 0
        END) AS correct_submissions,

        SUM(CASE
        WHEN points > 0 THEN points ELSE 0
        END) AS points_for_correct_submission,

        -(SUM(CASE
        WHEN points < 0 THEN points ELSE 0 END)),

        SUM(points) AS total_points_earned
    FROM 
        user_submissions
    GROUP BY
        username)

SELECT 
    *
FROM
    incorrect_sub_data
WHERE
    incorrect_submissions IS NOT NULL
ORDER BY
    incorrect_submissions DESC
LIMIT 5;

--Q5
SELECT *
FROM
    (SELECT
        EXTRACT(WEEK FROM submitted_at) AS week,
        username,
        SUM(points) AS total_points_earned,
        DENSE_RANK() OVER(PARTITION BY EXTRACT(WEEK FROM submitted_at) ORDER BY SUM(points) DESC) AS rank_w
    FROM 
        user_submissions
    GROUP BY
        username, week
    ORDER BY 
        week, total_points_earned DESC)
WHERE
    rank_w <=10;
