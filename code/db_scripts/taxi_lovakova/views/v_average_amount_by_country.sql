CREATE OR REPLACE VIEW v_average_amount_by_country AS
WITH cte_country AS
 (SELECT a.id    AS address_id
        ,ct.id   AS country_id
        ,ct.name AS country_name
    FROM address a
    JOIN street s
      ON s.id = a.street_id
    JOIN city c
      ON c.id = s.city_id
    JOIN country ct
      ON ct.id = c.country_id)

SELECT t.country_id
      ,t.country_name
      ,AVG(t.amount) avg_amount
  FROM (SELECT DISTINCT cc.country_id
                       ,cc.country_name
                       ,p.amount_to_paid * nvl(r.rate, 1) AS amount
          FROM booking b
          JOIN payment p
            ON p.id = b.payment_id
          LEFT JOIN rate r
            ON r.currency1_id = p.currency_id
          JOIN cte_country cc
            ON cc.address_id = b.end_trip_address_id) t
 GROUP BY t.country_id
         ,t.country_name;
