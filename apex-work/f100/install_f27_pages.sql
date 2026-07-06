-- F27 + UX Talonarios/Cajas — re-importa P51, P53 y P64.
--   P53: Tipo Comprobante y Activo como select list (LOV estatica), Punto de
--        Expedicion derivado (display only), validacion de talonario unico por
--        (caja, tipo) activo.
--   P51: columnas Tipo Comprobante y Activo con LOV estatica (display amigable).
--   P64: item Punto de Expedicion (propiedad de la CAJA_CONF, alimenta el trigger).
-- Requiere db/F27_punto_expedicion_caja.sql aplicado primero.
prompt --install_f27_pages
@@application/set_environment.sql
@@application/pages/delete_00051.sql
@@application/pages/page_00051.sql
@@application/pages/delete_00053.sql
@@application/pages/page_00053.sql
@@application/pages/delete_00064.sql
@@application/pages/page_00064.sql
@@application/end_environment.sql
