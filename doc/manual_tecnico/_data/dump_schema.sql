-- Vuelca la estructura del esquema WKSP_WORKPLACE a CSV para el generador del Manual Técnico.
SET FEEDBACK OFF
SET PAGESIZE 0
SET SQLFORMAT csv

SPOOL D:\GitHub\SOLSGE\doc\manual_tecnico\_data\cols.csv
SELECT c.table_name, c.column_id, c.column_name,
  CASE
    WHEN c.data_type IN ('VARCHAR2','CHAR','NVARCHAR2','NCHAR') THEN c.data_type||'('||c.char_length||')'
    WHEN c.data_type='NUMBER' AND c.data_precision IS NOT NULL AND NVL(c.data_scale,0)>0 THEN 'NUMBER('||c.data_precision||','||c.data_scale||')'
    WHEN c.data_type='NUMBER' AND c.data_precision IS NOT NULL THEN 'NUMBER('||c.data_precision||')'
    WHEN c.data_type='NUMBER' THEN 'NUMBER'
    WHEN c.data_type LIKE 'TIMESTAMP%' THEN 'TIMESTAMP'
    ELSE c.data_type
  END AS tipo,
  c.nullable
FROM all_tab_columns c
WHERE c.owner='WKSP_WORKPLACE'
ORDER BY c.table_name, c.column_id;
SPOOL OFF

SPOOL D:\GitHub\SOLSGE\doc\manual_tecnico\_data\pk.csv
SELECT c.table_name, cols.column_name
FROM all_constraints c
JOIN all_cons_columns cols ON cols.owner=c.owner AND cols.constraint_name=c.constraint_name
WHERE c.owner='WKSP_WORKPLACE' AND c.constraint_type='P'
ORDER BY c.table_name, cols.position;
SPOOL OFF

SPOOL D:\GitHub\SOLSGE\doc\manual_tecnico\_data\fk.csv
SELECT c.table_name, cols.column_name, r.table_name AS ref_table
FROM all_constraints c
JOIN all_cons_columns cols ON cols.owner=c.owner AND cols.constraint_name=c.constraint_name
JOIN all_constraints r ON r.owner=c.r_owner AND r.constraint_name=c.r_constraint_name
WHERE c.owner='WKSP_WORKPLACE' AND c.constraint_type='R'
ORDER BY c.table_name, cols.position;
SPOOL OFF

SPOOL D:\GitHub\SOLSGE\doc\manual_tecnico\_data\checks.csv
SELECT c.table_name, REPLACE(c.search_condition_vc, CHR(10), ' ') cond
FROM all_constraints c
WHERE c.owner='WKSP_WORKPLACE' AND c.constraint_type='C'
  AND c.search_condition_vc IS NOT NULL
  AND c.search_condition_vc NOT LIKE '%IS NOT NULL%'
ORDER BY c.table_name;
SPOOL OFF

SPOOL D:\GitHub\SOLSGE\doc\manual_tecnico\_data\comments.csv
SELECT table_name, column_name, REPLACE(comments, CHR(10), ' ') comments
FROM all_col_comments
WHERE owner='WKSP_WORKPLACE' AND comments IS NOT NULL
ORDER BY table_name, column_name;
SPOOL OFF
