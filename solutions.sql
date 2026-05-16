DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix(
	show_id	VARCHAR(5),
	typee    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);

SELECT * FROM netflix

SELECT 
	COUNT(*) AS TOTAL 
FROM netflix


SELECT 
	DISTINCT typee 
FROM netflix

--1. Count the number of Movies vs TV Shows
SELECT 
	typee,
	COUNT(typee) AS Total 
FROM netflix
GROUP BY typee

--2. Find the most common rating for movies and TV shows
SELECT 
	typee,
	rating
FROM
(
SELECT
	typee,
	rating,
	COUNT(*),
	RANK() OVER(PARTITION BY typee ORDER BY COUNT(*) DESC) as Ranking
FROM netflix
GROUP BY 1, 2
) AS T1 
WHERE 
	ranking = 1 
	
--3. List all movies released in a specific year (e.g., 2020)
SELECT * FROM netflix 
WHERE release_year = 2020;


--4. Find the top 5 countries with the most content on NetflixS
SELECT 
    TRIM(country) AS country,
    COUNT(*) AS total_content
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country
    FROM netflix
) AS t1
WHERE country IS NOT NULL
GROUP BY TRIM(country)
ORDER BY total_content DESC
LIMIT 5;








--5. Identify the longest movie
SELECT * 
FROM netflix
WHERE typee = 'Movie'
AND 
duration = (SELECT MAX(duration) FROM netflix)



--6. Find content added in the last 5 years
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';



--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%'


--8. List all TV shows with more than 5 seasons
SELECT 
	*,
	SPLIT_PART(duration, '', 1) AS seasons
FROM netflix
WHERE 
	typee = 'TV Show'
	AND SPLIT_PART(duration, ' ', 1)::INT > 5;

--9. Count the number of content items in each genre
WITH flattened_genres AS (
    SELECT 
        show_id,
        UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre
    FROM netflix
)
SELECT 
    TRIM(genre) AS genre,
    COUNT(show_id) AS total_count
FROM flattened_genres
GROUP BY TRIM(genre)
ORDER BY total_count DESC;

--10.Find each year and the average numbers of content release in India on netflix. return top 5 year with highest avg content release!
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;


--11. List all movies that are documentaries
SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries%'

--12. Find all content without a director
SELECT * FROM netflix
WHERE director IS NULL


--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%' 
	AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10 

	
--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
	COUNT (*) AS total_count
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY total_count DESC
LIMIT 10

--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.

SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;




