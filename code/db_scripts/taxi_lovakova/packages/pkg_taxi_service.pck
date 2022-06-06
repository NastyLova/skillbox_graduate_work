CREATE OR REPLACE PACKAGE pkg_taxi_service IS

  -- Author  : Lovakova A.A
  -- Created : 13-May-22
  -- Purpose : ����� ��� ������ ������� ������ �����

  TYPE rec_driver_salary IS RECORD(
     driver_id driver.id%TYPE
    ,NAME      driver.name%TYPE
    ,salary    NUMBER);

  TYPE tt_driver_salary IS TABLE OF rec_driver_salary;
  TYPE tt_address IS TABLE OF address.id%TYPE;
  TYPE tt_way IS TABLE OF way.distance%TYPE;

  /*
  * ��������� �������� ����� ���������� ���������
  * @param par_driver_id - �� ��������
  * @param par_car_id    - �� ����������
  */
  PROCEDURE create_rent_car_for_driver
  (
    par_driver_id IN NUMBER
   ,par_car_id    IN NUMBER
  );

  /*
  * ��������� �������� ����� ����������
  * @param par_car_id      - �� ����������
  * @param par_gas_mileage - ���-�� ������������ �������
  * @param par_distance    - ���������
  */
  PROCEDURE close_rent_car_for_driver
  (
    par_car_id      IN NUMBER
   ,par_gas_mileage IN NUMBER
   ,par_distance    IN NUMBER
  );

  /*
  * ��������� �������� �������� ����������
  * @param par_car_id             - �� ����������
  * @param par_amount_to_paid     - ����� � ������
  * @param par_currency           - ������
  * @param par_payment_type       - ��� ������
  * @param par_amount_of_gasoline - ���-�� �������
  * @param par_address_id         - ����� ��������
  */
  PROCEDURE create_refueling_for_car
  (
    par_car_id             IN NUMBER
   ,par_amount_to_paid     IN NUMBER
   ,par_currency           IN VARCHAR2
   ,par_payment_type       IN VARCHAR2
   ,par_amount_of_gasoline IN NUMBER
   ,par_address_id         IN NUMBER
  );

  /*
  * ��������� �������� ������ �����
  * @param par_passenger_id    - �� ���������
  * @param par_address_id      - �� ������
  * @param par_addresses_array - ������ ������� "����"
  * @param par_way_array       - ������ ���������
  * @param par_amount_to_paid  - ����� � ������
  * @param par_payment_type    - ��� ������
  * @param par_currency        - ������
  */
  PROCEDURE create_booking
  (
    par_passenger_id    IN NUMBER
   ,par_address_id      IN NUMBER
   ,par_addresses_array IN VARCHAR2
   ,par_way_array       IN VARCHAR2
   ,par_amount_to_paid  IN NUMBER
   ,par_payment_type    IN NUMBER
   ,par_currency        IN NUMBER
  );

  /*
  * ��������� ���������� �������� ����������
  * @param par_period_day - ������ � ����, �� ������� ����� ����� ������ ������������� �� ���������
  */
  PROCEDURE update_passenger_rating(par_period_day IN NUMBER);

  /*
  * ��������� ���������� �������� ���������
  * @param par_period_day - ������ � ����, �� ������� ����� ����� ������ ��������� �� �������������
  */
  PROCEDURE update_driver_rating(par_period_day IN NUMBER);

  /*
  * ��������� ���������� ����� �� ���� ��������� �� ��� � �����
  * @param par_year  - ��� ��� �������
  * @param par_month - ����� ��� �������
  */
  FUNCTION get_driver_salary
  (
    par_year  IN NUMBER
   ,par_month IN NUMBER
  ) RETURN tt_driver_salary
    PIPELINED;

END pkg_taxi_service;
/
CREATE OR REPLACE PACKAGE BODY pkg_taxi_service IS

  /*
  * ��������� �������� ����� ���������� ���������
  * @param par_driver_id - �� ��������
  * @param par_car_id    - �� ����������
  */
  PROCEDURE create_rent_car_for_driver
  (
    par_driver_id IN NUMBER
   ,par_car_id    IN NUMBER
  ) IS
    v_is_reserved NUMBER;
  BEGIN
    -- ��������� ��� ���������� ��� �� �������������
    SELECT c.is_reserved INTO v_is_reserved FROM car c WHERE c.id = par_car_id;
  
    IF v_is_reserved = 1
    THEN
      raise_application_error(-20001
                             ,'������ ���������� ��� ������������!');
    END IF;
  
    -- ������� ������ � ������������
    INSERT INTO rent
      (driver_id, car_id, date_start)
    VALUES
      (par_driver_id, par_car_id, trunc(SYSDATE));
  
    -- ����������� ������� ��������������
    UPDATE car c SET c.is_reserved = 1 WHERE c.id = par_car_id;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001, '���������� �� ������!');
    WHEN too_many_rows THEN
      raise_application_error(-20001
                             ,'������� ��������� ����������� � �������� ��!');
    WHEN OTHERS THEN
      raise_application_error(-20001, SQLERRM);
  END create_rent_car_for_driver;

  /*
  * ��������� �������� ����� ����������
  * @param par_car_id      - �� ����������
  * @param par_gas_mileage - ���-�� ������������ �������
  * @param par_distance    - ���������
  */
  PROCEDURE close_rent_car_for_driver
  (
    par_car_id      IN NUMBER
   ,par_gas_mileage IN NUMBER
   ,par_distance    IN NUMBER
  ) IS
  BEGIN
    -- ��������� ������ � ������������
    UPDATE rent r
       SET r.date_stop   = trunc(SYSDATE)
          ,r.gas_mileage = par_gas_mileage
          ,r.distance    = par_distance
     WHERE r.car_id = par_car_id;
  
    -- ����������� ������� ��������������
    UPDATE car c SET c.is_reserved = 0 WHERE c.id = par_car_id;
  
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001, '���������� �� ������!');
    WHEN too_many_rows THEN
      raise_application_error(-20001
                             ,'������� ��������� ����������� � �������� ��!');
    WHEN OTHERS THEN
      raise_application_error(-20001, SQLERRM);
  END close_rent_car_for_driver;

  /*
  * ��������� �������� �������� ����������
  * @param par_car_id             - �� ����������
  * @param par_amount_to_paid     - ����� � ������
  * @param par_currency           - ������
  * @param par_payment_type       - ��� ������
  * @param par_amount_of_gasoline - ���-�� �������
  * @param par_address_id         - ����� ��������
  */
  PROCEDURE create_refueling_for_car
  (
    par_car_id             IN NUMBER
   ,par_amount_to_paid     IN NUMBER
   ,par_currency           IN VARCHAR2
   ,par_payment_type       IN VARCHAR2
   ,par_amount_of_gasoline IN NUMBER
   ,par_address_id         IN NUMBER
  ) IS
    v_driver_id       driver.id%TYPE;
    v_payment_id      payment.id%TYPE;
    v_currency_id     currency.id%TYPE;
    v_payment_type_id payment_type.id%TYPE;
  BEGIN
    -- ������� �������� ����������
    BEGIN
      SELECT r.driver_id INTO v_driver_id FROM rent r WHERE r.car_id = par_car_id;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001, '�� ���������� ��� �����!');
      WHEN too_many_rows THEN
        raise_application_error(-20001
                               ,'������� ��������� ������������ ����������!');
      WHEN OTHERS THEN
        raise_application_error(-20001, SQLERRM);
    END;
  
    -- ������� ������
    BEGIN
      SELECT c.id INTO v_currency_id FROM currency c WHERE c.abbreviation = par_currency;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001, '�� ������� ��������� ������!');
      WHEN too_many_rows THEN
        raise_application_error(-20001
                               ,'������� ��������� ���������� �����!');
      WHEN OTHERS THEN
        raise_application_error(-20001, SQLERRM);
    END;
  
    -- ������� ��� ������
    BEGIN
      SELECT p.id INTO v_payment_type_id FROM payment_type p WHERE p.brief = par_payment_type;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001, '�� ������ ��� ������!');
      WHEN too_many_rows THEN
        raise_application_error(-20001, '������� ��������� ����� ������!');
      WHEN OTHERS THEN
        raise_application_error(-20001, SQLERRM);
    END;
  
    -- ��������� ���� � �������
    INSERT INTO payment
      (amount_to_paid, currency_id, payment_type_id)
    VALUES
      (par_amount_to_paid, v_currency_id, v_payment_type_id)
    RETURNING id INTO v_payment_id;
  
    INSERT INTO refueling
      (driver_id, car_id, payment_id, amount_of_gasoline, address_id)
    VALUES
      (v_driver_id, par_car_id, v_payment_id, par_amount_of_gasoline, par_address_id);
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001, SQLERRM);
  END create_refueling_for_car;

  /*
  * ��������� �������� ������ �����
  * @param par_passenger_id    - �� ���������
  * @param par_address_id      - �� ������
  * @param par_addresses_array - ������ ������� "����"
  * @param par_way_array       - ������ ���������
  * @param par_amount_to_paid  - ����� � ������
  * @param par_payment_type    - ��� ������
  * @param par_currency        - ������
  */
  PROCEDURE create_booking
  (
    par_passenger_id    IN NUMBER
   ,par_address_id      IN NUMBER
   ,par_addresses_array IN VARCHAR2
   ,par_way_array       IN VARCHAR2
   ,par_amount_to_paid  IN NUMBER
   ,par_payment_type    IN NUMBER
   ,par_currency        IN NUMBER
  ) IS
    v_status_id        booking_status.id%TYPE;
    v_payment_id       payment.id%TYPE;
    v_booking_id       booking.id%TYPE;
    v_preview_way_id   way.id%TYPE;
    v_from_address_id  address.id%TYPE;
    va_addresses_array tt_address;
    va_way_array       tt_way;
  BEGIN
    -- ������� ���������� ����������
    BEGIN
      -- ������� ������
      SELECT s.id INTO v_status_id FROM booking_status s WHERE s.brief = 'SEARCH_DRIVER';
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'�� ������� ���������� ���������� � ������!');
      WHEN too_many_rows THEN
        raise_application_error(-20001
                               ,'������� ��������� ������� ���������� ����������!');
      WHEN OTHERS THEN
        raise_application_error(-20001
                               ,'������ ��� ��������� ���������� ����������: ' || SQLERRM);
    END;
  
    -- ������� ������
    INSERT INTO payment
      (amount_to_paid, currency_id, payment_type_id)
    VALUES
      (par_amount_to_paid, par_currency, par_payment_type)
    RETURNING id INTO v_payment_id;
  
    -- ������� �����
    INSERT INTO booking
      (passenger_id, booking_status_id, payment_id)
    VALUES
      (par_passenger_id, v_status_id, v_payment_id)
    RETURNING id INTO v_booking_id;
  
    -- ������� � ��������� �� ������ ������ �� �������
    FOR i IN (SELECT regexp_substr(str, '[^,]+', 1, LEVEL) str
                FROM (SELECT par_addresses_array str FROM dual)
              CONNECT BY regexp_substr(str, '[^,]+', 1, LEVEL) IS NOT NULL)
    LOOP
      va_addresses_array.extend;
      va_addresses_array(va_addresses_array.last) := i.str;
    END LOOP;
  
    -- ������� � ��������� �� ������ ������ � ���������
    FOR i IN (SELECT regexp_substr(str, '[^,]+', 1, LEVEL) str
                FROM (SELECT par_way_array str FROM dual)
              CONNECT BY regexp_substr(str, '[^,]+', 1, LEVEL) IS NOT NULL)
    LOOP
      va_way_array.extend;
      va_way_array(va_way_array.last) := i.str;
    END LOOP;
  
    -- ������� ���������� � ���������
    FOR i IN 1 .. va_addresses_array.count
    LOOP
      -- �� ������� �������� ��������� ������� ���������� �� ������ ���������� � ���������� �� ���� �����
      -- ������ �������� ����� ����� � ������ ���������� v_preview_way_id, �.�. ���������� � ���������� ���� ��� ���
      -- � ������ ����������� ��������� � ���������� ����� ������������ ���������� � ���� ��� ��������� ������
      IF v_preview_way_id IS NULL
      THEN
        v_from_address_id := par_address_id;
      END IF;
    
      INSERT INTO way
        (from_address_id, to_address_id, distance, booking_id, preview_way_id)
      VALUES
        (v_from_address_id, va_addresses_array(i), va_way_array(i), v_booking_id, v_preview_way_id)
      RETURNING id, to_address_id INTO v_preview_way_id, v_from_address_id;
    
    END LOOP;
  
    -- ����� � ��������� �����
    UPDATE booking b SET b.end_trip_address_id = v_from_address_id WHERE b.id = v_booking_id;
  END create_booking;

  /*
  * ��������� ���������� �������� ����������
  * @param par_period_day - ������ � ����, �� ������� ����� ����� ������ ������������� �� ���������
  */
  PROCEDURE update_passenger_rating(par_period_day IN NUMBER) IS
  BEGIN
    FOR rec IN (SELECT p.passenger_id
                      ,ROUND(AVG(p.rating), 2) AS avg_rating
                  FROM rating_driver2passenger p
                 WHERE p.time_create BETWEEN trunc(SYSDATE) - par_period_day AND trunc(SYSDATE)
                 GROUP BY p.passenger_id)
    LOOP
      UPDATE passenger_rating r SET r.rating = rec.avg_rating WHERE r.passenger_id = rec.passenger_id;
    END LOOP;
  END update_passenger_rating;

  /*
  * ��������� ���������� �������� ���������
  * @param par_period_day - ������ � ����, �� ������� ����� ����� ������ ��������� �� �������������
  */
  PROCEDURE update_driver_rating(par_period_day IN NUMBER) IS
  BEGIN
    FOR rec IN (SELECT p.driver_id
                      ,ROUND(AVG(p.rating), 2) AS avg_rating
                  FROM rating_passenger2driver p
                 WHERE p.time_create BETWEEN trunc(SYSDATE) - par_period_day AND trunc(SYSDATE)
                 GROUP BY p.driver_id)
    LOOP
      UPDATE driver_rating r SET r.rating = rec.avg_rating WHERE r.driver_id = rec.driver_id;
    END LOOP;
  END update_driver_rating;

  /*
  * ��������� ���������� ����� �� ���� ��������� �� ��� � �����
  * @param par_year  - ��� ��� �������
  * @param par_month - ����� ��� �������
  */
  FUNCTION get_driver_salary
  (
    par_year  IN NUMBER
   ,par_month IN NUMBER
  ) RETURN tt_driver_salary
    PIPELINED IS
    vr_driver_salary rec_driver_salary;
  BEGIN
    FOR r IN (SELECT d.id
                    ,d.name
                    ,(d.percent_of_payment * (SUM(p_b.amount_to_paid) - SUM(p_r.amount_to_paid)) / 100) AS salary
                FROM driver d
                JOIN booking b
                  ON b.driver_id = d.id
                JOIN payment p_b
                  ON p_b.id = b.payment_id
                JOIN refueling r
                  ON r.driver_id = d.id
                JOIN payment p_r
                  ON p_r.id = r.payment_id
               WHERE extract(YEAR FROM b.time_create) = par_year
                 AND extract(MONTH FROM b.time_create) = par_month
               GROUP BY d.id
                       ,d.name
                       ,d.percent_of_payment)
    LOOP
      vr_driver_salary.driver_id := r.id;
      vr_driver_salary.name      := r.name;
      vr_driver_salary.salary    := r.salary;
      PIPE ROW(vr_driver_salary);
    END LOOP;
  
    RETURN;
  END get_driver_salary;

END pkg_taxi_service;
/
