--Parameterize the score threshold between good/bad submissions in case we want to tweak it
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
  -- Filter the good posts so that we can count how many there are
  stories_gte AS (
  SELECT
    *
  FROM
    base_table
  WHERE
    score >= score_threshold ),
  -- Balance the resulting dataset by selecting a (roughly) equal amount of bad posts.
  -- There are two SQL approaches to sampling N rows randomly from a dataset:
  -- 1) ORDER BY RAND() LIMIT N, which is more common but O(nlogn) time and may not scale to HN-sized data
  -- 2) RAND() < [proportion of good posts to bad posts], which is vectorized and effectively O(1) time
  -- Obviously #2 is better, but not pretty!
  stories_lt_downsampled AS (
  SELECT
    *
  FROM
    base_table
  WHERE
    RAND() < (SELECT COUNT(*) FROM stories_gte) / ((SELECT COUNT(*) FROM base_table) - (SELECT COUNT(*) FROM stories_gte))
    AND score < score_threshold ),
  -- This method of combining will not randomize the inputs.
  -- That is fine since the training process will sample them randomly, but have to be aware.
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
  IF (score >= score_threshold, " positive", " negative") AS completion
FROM
  combined_tables