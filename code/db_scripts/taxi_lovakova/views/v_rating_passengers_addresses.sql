CREATE OR REPLACE VIEW v_rating_passengers_addresses AS
WITH cte_book AS
 (SELECT p.id
        ,p.name
        ,COUNT(b.id) AS cnt_booking
    FROM passenger p
    JOIN booking b
      ON b.passenger_id = p.id
   GROUP BY p.id
           ,p.name),
cte_all_addr AS
 (SELECT a.id
        ,a.name
        ,a.address_id
        ,COUNT(a.address_id) AS cnt_addr
        ,row_number() over(PARTITION BY a.id ORDER BY a.id) AS rn
    FROM (SELECT cb.id
                ,cb.name
                ,w.from_address_id AS address_id
                ,cb.cnt_booking
            FROM cte_book cb
            JOIN booking b
              ON b.passenger_id = cb.id
            JOIN way w
              ON w.booking_id = b.id
          UNION ALL
          SELECT cb.id
                ,cb.name
                ,w.to_address_id AS address_id
                ,cb.cnt_booking
            FROM cte_book cb
            JOIN booking b
              ON b.passenger_id = cb.id
            JOIN way w
              ON w.booking_id = b.id) a
   WHERE a.cnt_booking >= 10
   GROUP BY a.id
           ,a.name
           ,a.address_id
   ORDER BY a.id
           ,COUNT(a.address_id) DESC)

SELECT ca.id AS passenger_id
      ,ca.name AS passenger_name
      ,cr.name AS country_name
      ,c.name AS city_name
      ,s.name || ' ' || a.house_number AS street_name
      ,ca.rn AS top
  FROM cte_all_addr ca
  JOIN address a
    ON a.id = ca.address_id
  JOIN street s
    ON s.id = a.street_id
  JOIN city c
    ON c.id = s.city_id
  JOIN country cr
    ON cr.id = c.country_id
 WHERE ca.rn <= 5;
