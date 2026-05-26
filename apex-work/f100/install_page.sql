prompt --install_page
@@application/set_environment.sql
@@application/pages/delete_00006.sql
@@application/pages/page_00006.sql
@@application/pages/delete_00052.sql
@@application/pages/page_00052.sql
@@application/pages/delete_00054.sql
@@application/pages/page_00054.sql
-- navigation_menu.sql se aplica manualmente vía APEX UI (no hay API
-- pública para hacer replace de una List shared component; el create_list
-- choca con la PK existente).  Ver PLAN_VENTAS.md §10.
@@application/end_environment.sql
