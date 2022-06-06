CREATE OR REPLACE VIEW v_five_driver_for_passenger AS
WITH cte_driver AS
 (SELECT d.id
        ,d.name
    FROM driver d
    JOIN driver_rating dr
      ON dr.driver_id = d.id
   WHERE dr.rating > 4)

SELECT passenger_id
      ,passenger_name
      ,driver_id
      ,driver_name
      ,rn
  FROM (SELECT t.passenger_id
              ,t.passenger_name
              ,t.driver_id
              ,t.driver_name
              ,row_number() over(PARTITION BY t.passenger_id ORDER BY t.passenger_id) rn
          FROM (SELECT DISTINCT p.id   AS passenger_id
                               ,p.name AS passenger_name
                               ,d.id   AS driver_id
                               ,d.name AS driver_name
                  FROM passenger p
                  JOIN booking b
                    ON b.passenger_id = p.id
                  JOIN cte_driver d
                    ON d.id NOT IN (SELECT b.driver_id FROM booking b WHERE b.passenger_id = p.id)
                 ORDER BY p.name
                         ,d.id) t) tt
 WHERE tt.rn <= 5;
