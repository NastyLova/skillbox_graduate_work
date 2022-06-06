-- 1. Заполнение справочника статусов
INSERT INTO booking_status (brief, NAME) VALUES ('SEARCH_DRIVER', 'Поиск водителя');
INSERT INTO booking_status (brief, NAME) VALUES ('WAIT_DRIVER', 'Ожидание водителя');
INSERT INTO booking_status (brief, NAME) VALUES ('WAIT_PASSENGER', 'Ожидание пассажира');
INSERT INTO booking_status (brief, NAME) VALUES ('TRIP_STARTED', 'Начало поездки');
INSERT INTO booking_status (brief, NAME) VALUES ('WAIT_PAYMENT', 'Ожидание оплаты');
INSERT INTO booking_status (brief, NAME) VALUES ('TRIP_COMPLETED', 'Поездка завершена');
INSERT INTO booking_status (brief, NAME) VALUES ('CANCELED', 'Поездка отменена');

-- 2. Заполнение справочника типов платежей
INSERT INTO payment_type (brief, NAME) VALUES ('CARD', 'Банковская карта');
INSERT INTO payment_type (brief, NAME) VALUES ('CASH', 'Наличные');

-- 3. Заполнение справочника цветов автомобилей
INSERT INTO car_color (brief, NAME) VALUES ('WHITE', 'Белый');
INSERT INTO car_color (brief, NAME) VALUES ('BLACK', 'Черный');
INSERT INTO car_color (brief, NAME) VALUES ('GREY', 'Серый');
INSERT INTO car_color (brief, NAME) VALUES ('RED', 'Красный');
INSERT INTO car_color (brief, NAME) VALUES ('BLUE', 'Синий');
INSERT INTO car_color (brief, NAME) VALUES ('YELLOW', 'Желтый');
INSERT INTO car_color (brief, NAME) VALUES ('GREEN', 'Зеленый');

COMMIT;
