CREATE OR REPLACE VIEW v_amount_dynamics AS
WITH cte_country AS
 (SELECT a.id    AS address_id
        ,ct.id   AS country_id
        ,ct.name AS country_name
        ,c.name  AS city_name
    FROM address a
    JOIN street s
      ON s.id = a.street_id
    JOIN city c
      ON c.id = s.city_id
    JOIN country ct
      ON ct.id = c.country_id
   WHERE ct.id = 1)

SELECT t.country_name || ', ' || t.city_name || ', ' || t.year_b || ', ' || t.month_b year_city
      ,avg_amount
  FROM (SELECT cc.country_name
              ,cc.city_name
              ,extract(YEAR FROM trunc(b.time_end)) AS year_b
              ,to_char(trunc(b.time_end), 'Month') AS month_b
              ,ROUND(SUM(p.amount_to_paid * nvl(r.rate, 1)) / SUM(w.distance), 5) AS avg_amount
          FROM booking b
          JOIN cte_country cc
            ON cc.address_id = b.end_trip_address_id
          JOIN payment p
            ON p.id = b.payment_id
          LEFT JOIN rate r
            ON r.currency1_id = p.currency_id
          JOIN way w
            ON w.booking_id = b.id
         GROUP BY cc.country_name
                 ,cc.city_name
                 ,extract(YEAR FROM trunc(b.time_end))
                 ,to_char(trunc(b.time_end), 'Month')
         ORDER BY year_b
                 ,month_b DESC
                 ,cc.country_name
                 ,cc.city_name) t;
