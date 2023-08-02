/*
 * Identify demographic characteristic for patients
 */
-- find sex distribution
SELECT
    sex,
    count(*),
    count(*) / 122.0 * 100
FROM
    demographic_all da
    JOIN consented c ON c.record_id = da.patid
WHERE
    c.ehr_access_agree = 1
GROUP BY
    sex;

-- find race distribution
SELECT
    lpad(race, 2, '0'),
    count(*),
    count(*) / 122.0 * 100
FROM
    demographic_all da
    JOIN consented c ON c.record_id = da.patid
WHERE
    c.ehr_access_agree = 1
GROUP BY
    lpad(race, 2, '0')
ORDER BY
    count(*) DESC;

;

-- find hispanic distribution
SELECT
    hispanic,
    count(*),
    count(*) / 122.0 * 100
FROM
    demographic_all da
    JOIN consented c ON c.record_id = da.patid
WHERE
    c.ehr_access_agree = 1
GROUP BY
    hispanic;

-- find age distribution
SELECT
    min(date_part('year', CURRENT_DATE::timestamp) - date_part('year', d.birth_date::timestamp)),
    max(date_part('year', CURRENT_DATE::timestamp) - date_part('year', d.birth_date::timestamp)),
    avg(date_part('year', CURRENT_DATE::timestamp) - date_part('year', d.birth_date::timestamp))
    age,
    stddev(date_part('year', CURRENT_DATE::timestamp) - date_part('year', d.birth_date::timestamp))
FROM
    demographic_all d
    JOIN consented c ON c.record_id = d.patid
WHERE
    c.ehr_access_agree = 1;

