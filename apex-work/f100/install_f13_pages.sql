-- F13 — re-importa P119 (Documento Recibo) con identidad visual KuDE.
-- Region pasa a invocar WKSP_WORKPLACE.FN_KUDE_RECIBO_HTML(:P119_ID_RECIBO)
-- (definida en db/F13_kude_recibo.sql — aplicar ese script ANTES de importar).
-- Efimero: solo P119, para no pisar el resto de install_page.sql.
prompt --install_f13_pages
@@application/set_environment.sql
@@application/pages/delete_00119.sql
@@application/pages/page_00119.sql
@@application/end_environment.sql
