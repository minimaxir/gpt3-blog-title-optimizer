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
    AND timestamp BETWEEN "2021-08-01" AND "2022-08-01" ),
  stories_gte100 AS (
  SELECT
    *
  FROM
    base_table
  WHERE
    score >= 100 )
SELECT
  *
FROM
  stories_gte100
ORDER BY
  score DESC