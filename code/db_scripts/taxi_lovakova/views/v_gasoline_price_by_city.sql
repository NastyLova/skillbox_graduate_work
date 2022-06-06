CREATE OR REPLACE VIEW v_gasoline_price_by_city AS
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
      ON ct.id = c.country_id)

SELECT DISTINCT cc.country_name || ', ' || city_name AS city_name
               ,ROUND(p.amount_to_paid * nvl(rt.rate, 1) / r.amount_of_gasoline, 3) AS gasoline_price
               ,to_char(r.time_create, 'dd.mm.yyyy') AS date_price
               ,rt.rate
               ,p.id
  FROM refueling r
  JOIN payment p
    ON p.id = r.payment_id
  JOIN cte_country cc
    ON cc.address_id = r.address_id
  LEFT JOIN rate rt
    ON rt.currency1_id = p.currency_id
 WHERE rt.currency2_id = (SELECT c.id FROM currency c WHERE c.abbreviation = 'RUB')
    OR p.currency_id = (SELECT c.id FROM currency c WHERE c.abbreviation = 'RUB')
 ORDER BY gasoline_price DESC;

