SELECT
    title,
    score
FROM
    `bigquery-public-data.hacker_news.full`
WHERE
    type = "story"
    AND descendants >= 20
    AND score >= 10
    AND url IS NOT NULL
    AND timestamp BETWEEN "2019-08-01" AND "2022-08-01"
ORDER BY
    score DESC