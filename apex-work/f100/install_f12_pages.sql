-- F12 — re-importa P96 (Documento Factura) con el layout KuDE.
-- Region pasa a invocar WKSP_WORKPLACE.FN_KUDE_FACTURA_HTML(:P96_ID_COMPROBANTE)
-- (definida en db/F12_kude_factura.sql — aplicar ese script ANTES de importar).
-- Efimero: solo P96, para no pisar el resto de install_page.sql.
prompt --install_f12_pages
@@application/set_environment.sql
@@application/pages/delete_00096.sql
@@application/pages/page_00096.sql
@@application/end_environment.sql
