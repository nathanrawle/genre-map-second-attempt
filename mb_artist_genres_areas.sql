WITH genres AS (
            SELECT id AS genre_id, "name" AS genre
              FROM musicbrainz.tag
             WHERE "name" IN (SELECT "name" FROM musicbrainz.genre)
),
artist_all_gens AS (
            SELECT ROW_NUMBER() OVER (PARTITION BY a.id ORDER BY at2."count" DESC) AS genre_rank
                 , a.id AS artist_id
                 , g.*
                 , at2."count"
              FROM musicbrainz.artist AS a
              JOIN musicbrainz.artist_tag AS at2 ON a.id=at2.artist
              JOIN genres AS g ON at2.tag=g.genre_id
),
areas AS (
            SELECT a.id AS id, a."name" AS area_name, at2."name" AS area_type, a.ended
              FROM musicbrainz."area" AS a 
              JOIN musicbrainz.area_type AS at2 ON a."type" = at2.id
),
artist_areas AS (
            SELECT a.id AS artist_id, a2.area_name AS "area", a2.area_type, a2.ended AS area_ended
                 , a3.area_name AS begin_area, a3.area_type AS begin_area_type, a3.ended AS begin_area_ended
              FROM musicbrainz.artist AS a 
         LEFT JOIN areas AS a2 ON a."area" = a2.id 
         LEFT JOIN areas AS a3 ON a.begin_area = a3.id
             WHERE a2.area_name NOTNULL OR a3.area_name NOTNULL
),
artist_top_gens AS (
            SELECT *
              FROM artist_all_gens AS aag
             WHERE genre_rank < 3
)
SELECT a4."name" AS artist, a4.sort_name AS sort_artist
     , atg.genre
     , aa."area", aa.area_type, aa.area_ended, aa.begin_area, aa.begin_area_type, aa.begin_area_ended
     , a4.begin_date_year, a4.begin_date_month, a4.begin_date_day
     , a4.end_date_year, a4.end_date_month, a4.end_date_day
  FROM musicbrainz.artist AS a4
  JOIN artist_top_gens AS atg ON a4.id = atg.artist_id
  JOIN artist_areas AS aa ON a4.id = aa.artist_id