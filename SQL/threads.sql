/*THREADS APP BY META EXPLORATORY DATA ANALYSIS USING SQL*/

/*SQL SKILLS: joins, date manipulation, regular expressions, views, stored procedures, aggregate functions, string manipulation*/

-- --------------------------------------------------------------------------------------------------------------
/* The first 10 users on the platform */
SELECT 
    *
FROM
    threads.users
ORDER BY created_at ASC
LIMIT 10;

/* Total number of registrations */
SELECT 
    COUNT(*) AS 'Total Registration'
FROM
    threads.users;

/* The day of the week most users register on */
CREATE VIEW vwtotalregistrations AS
    SELECT 
        DATE_FORMAT(created_at, '%W') AS 'day of the week',
        COUNT(*) AS 'total number of registration'
    FROM
        threads.users
    GROUP BY 1
    ORDER BY 2 DESC;

SELECT 
    *
FROM
    vwtotalregistrations;

/* Version 2 */
SELECT 
    DAYNAME(created_at) AS 'Day of the Week',
    COUNT(*) AS 'Total Registration'
FROM
    threads.users
GROUP BY 1
ORDER BY 2 DESC;

/* The users who have never posted a photo */
SELECT 
    u.username
FROM
    threads.users u
        LEFT JOIN
    threads.photos p ON p.user_id = u.id
WHERE
    p.id IS NULL;

/* The most likes on a single photo */
SELECT 
     u.username, p.image_url, COUNT(*) AS total
FROM
    threads.photos p
        INNER JOIN
    threads.likes l ON l.photo_id = p.id
        INNER JOIN
    threads.users u ON p.user_id = u.id
GROUP BY p.id
ORDER BY total DESC
LIMIT 1;

/* Version 2 */
SELECT 
    ROUND((SELECT 
                    COUNT(*)
                FROM
                    threads.photos) / (SELECT 
                    COUNT(*)
                FROM
                    threads.users),
            2) AS 'Average Posts by Users';

/* The number of photos posted by most active users */
SELECT 
    u.username AS 'Username',
    COUNT(p.image_url) AS 'Number of Posts'
FROM
    threads.users u
        JOIN
    threads.photos p ON u.id = p.user_id
GROUP BY u.id
ORDER BY 2 DESC
LIMIT 5;

/* The total number of posts */
SELECT 
    SUM(user_posts.total_posts_per_user) AS 'Total Posts by Users'
FROM
    (SELECT 
        u.username, COUNT(p.image_url) AS total_posts_per_user
    FROM
        threads.users u
    JOIN threads.photos p ON u.id = p.user_id
    GROUP BY u.id) AS user_posts;

/* The total number of users with posts */
SELECT 
    COUNT(DISTINCT (u.id)) AS total_number_of_users_with_posts
FROM
    threads.users u
        JOIN
    threads.photos p ON u.id = p.user_id;

/* The usernames with numbers as ending */
SELECT 
    id, username
FROM
    threads.users
WHERE
    username REGEXP '[$0-9]';

/* The usernames with character as ending */
SELECT 
    id, username
FROM
    threads.users
WHERE
    username NOT REGEXP '[$0-9]';

/* The number of usernames that start with A */
SELECT 
    count(id)
FROM
    threads.users
WHERE
    username REGEXP '^[A]';

/* The most popular tag names by usage */
SELECT 
    t.tag_name, COUNT(tag_name) AS seen_used
FROM
    threads.tags t
        JOIN
    threads.photo_tags pt ON t.id = pt.tag_id
GROUP BY t.id
ORDER BY seen_used DESC
LIMIT 10;

/* The most popular tag names by likes */
SELECT 
    t.tag_name AS 'Tag Name',
    COUNT(l.photo_id) AS 'Number of Likes'
FROM
    threads.photo_tags pt
        JOIN
    threads.likes l ON l.photo_id = pt.photo_id
        JOIN
    threads.tags t ON pt.tag_id = t.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

/* The users who have liked every single photo on the site */
SELECT 
    u.id, u.username, COUNT(l.user_id) AS total_likes_by_user
FROM
    threads.users u
        JOIN
    threads.likes l ON u.id = l.user_id
GROUP BY u.id
HAVING total_likes_by_user = (SELECT 
        COUNT(*)
    FROM
        threads.photos);

/* Total number of users without comments */
SELECT 
    COUNT(*) AS total_number_of_users_without_comments
FROM
    (SELECT 
        u.username, c.comment_text
    FROM
        threads.users u
    LEFT JOIN threads.comments c ON u.id = c.user_id
    GROUP BY u.id, c.comment_text
    HAVING comment_text IS NULL) AS users;

/* The percentage of users who have either never commented on a photo or likes every photo */
SELECT 
    tableA.total_A AS 'Number Of Users who never commented',
    (tableA.total_A / (SELECT 
            COUNT(*)
        FROM
            threads.users u)) * 100 AS '%',
    tableB.total_B AS 'Number of Users who likes every photos',
    (tableB.total_B / (SELECT 
            COUNT(*)
        FROM
            threads.users u)) * 100 AS '%'
FROM
    (SELECT 
        COUNT(*) AS total_A
    FROM
        (SELECT 
        u.username, c.comment_text
    FROM
        threads.users u
    LEFT JOIN threads.comments c ON u.id = c.user_id
    GROUP BY u.id, c.comment_text
    HAVING comment_text IS NULL) AS total_number_of_users_without_comments) AS tableA
        JOIN
    (SELECT 
        COUNT(*) AS total_B
    FROM
        (SELECT 
        u.id, u.username, COUNT(l.user_id) AS total_likes_by_user
    FROM
        threads.users u
    JOIN threads.likes l ON u.id = l.user_id
    GROUP BY u.id
    HAVING total_likes_by_user = (SELECT 
            COUNT(*)
        FROM
            threads.photos)) AS total_number_of_users_with_all_likes) AS tableB;
