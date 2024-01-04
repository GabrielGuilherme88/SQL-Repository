select table_name, column_name, ordinal_position, is_nullable , data_type, udt_name ,
character_maximum_length
from information_schema.columns
where table_schema ='public'

SELECT *
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'public';
     
  