-- F10.1 — re-importa P53 con P53_ESTABLECIMIENTO como display_only derivado.
prompt --install_f10_1_pages
@@application/set_environment.sql
@@application/pages/delete_00053.sql
@@application/pages/page_00053.sql
@@application/end_environment.sql
