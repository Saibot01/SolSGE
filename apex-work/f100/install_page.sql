prompt --install_page
@@application/set_environment.sql
@@application/pages/delete_00006.sql
@@application/pages/page_00006.sql
@@application/pages/delete_00052.sql
@@application/pages/page_00052.sql
@@application/pages/delete_00054.sql
@@application/pages/page_00054.sql
@@application/pages/delete_00111.sql
@@application/pages/page_00111.sql
-- page_00115.sql intencionalmente FUERA del install:
--   F5 se rediseñó como página separada estilo P110 (Aprobación de OC),
--   manual vía APEX Builder. El page_00115.sql queda en el repo solo como
--   referencia del proceso PL/SQL (ProcesarCambioEstado). Ver
--   PLAN_VENTAS.md Feature 5.
-- navigation_menu.sql se aplica manualmente vía APEX UI (no hay API
-- pública para hacer replace de una List shared component; el create_list
-- choca con la PK existente).  Ver PLAN_VENTAS.md §10.
@@application/end_environment.sql
