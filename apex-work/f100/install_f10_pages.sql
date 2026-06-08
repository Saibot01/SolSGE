-- F10 — importa las paginas parcheadas para ID_CAJA_CONF:
--   P51 (lista Talonarios), P53 (form Talonarios), P67 (Proceso Ventas),
--   P100 (Cobro de Cuotas).
-- Las demas paginas listadas en install_page.sql no se tocan en esta corrida.
prompt --install_f10_pages
@@application/set_environment.sql
@@application/pages/delete_00051.sql
@@application/pages/page_00051.sql
@@application/pages/delete_00053.sql
@@application/pages/page_00053.sql
@@application/pages/delete_00067.sql
@@application/pages/page_00067.sql
@@application/pages/delete_00100.sql
@@application/pages/page_00100.sql
@@application/end_environment.sql
