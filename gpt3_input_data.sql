WITH
  base_table AS (
  SELECT
    title,
    score
  FROM
    `bigquery-public-data.hacker_news.full`
  WHERE
    type = "story"
    AND score >= 10
    AND url IS NOT NULL
    AND timestamp BETWEEN "2021-08-01" AND "2022-08-01"
    AND NOT REGEXP_CONTAINS(title, r"^Show HN")
    AND NOT REGEXP_CONTAINS(url, r"github.com") ),
  stories_gte100 AS (
  SELECT
    *
  FROM
    base_table
  WHERE
    score >= 100 ),
  stories_lt100_downsampled AS (
  SELECT
    *
  FROM
    base_table
  WHERE
    RAND() < (SELECT COUNT(*) FROM stories_gte100) / ((SELECT COUNT(*) FROM base_table) - (SELECT COUNT(*) FROM stories_gte100))
    AND score < 100 ),
  combined_tables AS (
  SELECT
    *
  FROM
    stories_gte100
  UNION ALL (
    SELECT
      *
    FROM
      stories_lt100_downsampled) )
SELECT
  CONCAT("Title: ", title) AS prompt,
IF
  (score >= 100,
    " positive",
    " negative") AS completion
FROM
  combined_tables