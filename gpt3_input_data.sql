DECLARE score_threshold INT64 DEFAULT 100;

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
  stories_gte AS (
  SELECT
    *
  FROM
    base_table
  WHERE
    score >= score_threshold ),
  stories_lt_downsampled AS (
  SELECT
    *
  FROM
    base_table
  WHERE
    RAND() < (SELECT COUNT(*) FROM stories_gte) / ((SELECT COUNT(*) FROM base_table) - (SELECT COUNT(*) FROM stories_gte))
    AND score < score_threshold ),
  combined_tables AS (
  SELECT
    *
  FROM
    stories_gte
  UNION ALL (
    SELECT
      *
    FROM
      stories_lt_downsampled) )
SELECT
  CONCAT("Title: ", title) AS prompt,
IF
  (score >= score_threshold,
    " positive",
    " negative") AS completion
FROM
  combined_tables