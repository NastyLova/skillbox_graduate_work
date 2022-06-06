DECLARE
  v_sql VARCHAR2(4000);
BEGIN
  FOR i IN (SELECT lower(c.table_name) AS table_name
              FROM all_tables t
              JOIN all_tab_columns c
                ON c.table_name = t.table_name
             WHERE t.owner = 'TAXI_LOVAKOVA'
               AND c.column_name = 'TIME_CREATE'
               AND c.data_type = 'TIMESTAMP(6)'
               AND c.nullable = 'N')
  LOOP
    v_sql := 'CREATE OR REPLACE TRIGGER tr_after_insert_' || i.table_name || '
  BEFORE INSERT ON ' || i.table_name || '
  FOR EACH ROW
DECLARE
BEGIN
  :new.time_create := systimestamp;
END tr_after_insert_' || i.table_name || ';';
    EXECUTE IMMEDIATE v_sql;
  END LOOP;
END;
/
