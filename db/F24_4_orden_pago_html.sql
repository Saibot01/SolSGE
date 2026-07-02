-- ============================================================================
-- F24.4 - Documento de Orden de Pago (FN_ORDEN_PAGO_HTML)
-- ============================================================================
-- Genera el HTML del comprobante de una Orden de Pago. P149 (Documento Orden de
-- Pago) lo invoca con RETURN FN_ORDEN_PAGO_HTML(:P149_ID_ORDEN_PAGO).
--
-- MATIZ SIFEN: la orden de pago NO es un Documento Electronico (SIFEN cubre
-- factura, NC/ND, remision, autofactura). Es un documento de CONTROL INTERNO ->
-- sin CDC ni QR, no se titula "KuDE"; reusa el estilo visual (clases kude) por
-- coherencia con factura/recibo/arqueo (F12/F13/F17).
--
-- Contenido: cabecera (emisor + OP N/estado/fechas/metodo/usuario), datos del
-- proveedor, detalle de las CxP aplicadas (comprobante/vencimiento/monto aplicado),
-- total pagado y leyenda.
--
-- Reusa: FN_GET_PARAMETRO (emisor, F12), FN_AHORA (F19).
-- Pre-requisitos: F24_1_ordenes_pago.sql (ORDENES_PAGO / ORDEN_PAGO_DET).
--
-- Idempotente: CREATE OR REPLACE.
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion: sql -S -name tesis_db < db/F24_4_orden_pago_html.sql
-- ============================================================================
set define off
set serveroutput on

prompt == F24.4 FN_ORDEN_PAGO_HTML ==
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_ORDEN_PAGO_HTML (
  p_id_orden_pago IN NUMBER
) RETURN CLOB IS
  v_razon  VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('RAZON_SOCIAL','TEXTO'),'-');
  v_ruc    VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('RUC','TEXTO'),'-');
  v_dir    VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('DIRECCION','TEXTO'),'-');
  v_ciudad VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('CIUDAD','TEXTO'),'-');

  v_estado   VARCHAR2(20);
  v_estadot  VARCHAR2(20);
  v_femi     DATE;
  v_fpago    DATE;
  v_total    NUMBER;
  v_usuario  VARCHAR2(60);
  v_obs      VARCHAR2(255);
  v_metodo   VARCHAR2(100);
  v_prov     VARCHAR2(255);
  v_provdoc  VARCHAR2(50);

  v_html     CLOB;
  v_sumdet   NUMBER := 0;

  CURSOR cd IS
    SELECT comp.NRO_COMPROBANTE,
           comp.FECHA_EMISION AS FEC_COMP,
           cp.FECHA_VENCIMIENTO,
           cp.TOTAL_A_PAGAR,
           d.MONTO_APLICADO
      FROM WKSP_WORKPLACE.ORDEN_PAGO_DET d
      JOIN WKSP_WORKPLACE.CUENTAS_PAGAR cp ON cp.ID_CXP = d.ID_CXP
      LEFT JOIN WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR comp ON comp.ID_COMPROBANTE = cp.ID_COMPROBANTE
     WHERE d.ID_ORDEN_PAGO = p_id_orden_pago
     ORDER BY cp.FECHA_VENCIMIENTO;

  FUNCTION fmt(n NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TRANSLATE(TO_CHAR(ROUND(NVL(n,0)),'FM999G999G999G990'), ',', '.');
  END;
BEGIN
  BEGIN
    SELECT op.ESTADO, op.FECHA_EMISION, op.FECHA_PAGO, op.TOTAL_PAGO,
           op.USUARIO, op.OBSERVACION, NVL(mp.NOMBRE,'-'),
           TRIM(per.PRIMER_NOMBRE||' '||per.PRIMER_APELLIDO), NVL(per.NRO_DOCUMENTO,'-')
      INTO v_estado, v_femi, v_fpago, v_total, v_usuario, v_obs, v_metodo, v_prov, v_provdoc
      FROM WKSP_WORKPLACE.ORDENES_PAGO op
      JOIN WKSP_WORKPLACE.PROVEEDORES pr ON pr.ID_PERSONA = op.ID_PROVEEDOR
      LEFT JOIN WKSP_WORKPLACE.PERSONAS per ON per.ID_PERSONA = pr.ID_PERSONA
      LEFT JOIN WKSP_WORKPLACE.METODOS_PAGO mp ON mp.ID_METODO_PAGO = op.ID_METODO_PAGO
     WHERE op.ID_ORDEN_PAGO = p_id_orden_pago;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN '<h2>Orden de pago no encontrada.</h2><p>Verifique que el N&deg; indicado corresponda a una orden v&aacute;lida.</p>';
  END;

  v_estadot := CASE v_estado WHEN 'BORRADOR' THEN 'BORRADOR (no pagada)'
                             WHEN 'PAGADA'   THEN 'PAGADA'
                             WHEN 'ANULADA'  THEN 'ANULADA'
                             ELSE NVL(v_estado,'-') END;

  v_html := '<div class="kude"><div class="ktit">Orden de Pago</div>';

  -- Cabecera emisor + OP
  v_html := v_html || '<table class="khead"><tr><td class="kemis"><b>'||v_razon||'</b><br>'
                   || v_dir||'<br>'||v_ciudad||'<br><b>RUC:</b> '||v_ruc||'</td>';
  v_html := v_html || '<td class="r"><b>Orden de Pago N&deg;:</b> '||p_id_orden_pago
                   || '<br><b>Estado:</b> '||v_estadot
                   || '<br><b>Emisi&oacute;n:</b> '||NVL(TO_CHAR(v_femi,'dd/mm/yyyy'),'-')
                   || '<br><b>Fecha de pago:</b> '||NVL(TO_CHAR(v_fpago,'dd/mm/yyyy'),'(pendiente)')||'</td></tr></table>';

  -- Datos del proveedor / pago
  v_html := v_html || '<div class="kbox"><table class="krec">';
  v_html := v_html || '<tr><td><span class="klabel">Proveedor</span><br>'||NVL(v_prov,'-')
                   || '</td><td><span class="klabel">RUC / Documento</span><br>'||v_provdoc
                   || '</td></tr>';
  v_html := v_html || '<tr><td><span class="klabel">M&eacute;todo de pago</span><br>'||v_metodo
                   || '</td><td><span class="klabel">Registrado por</span><br>'||NVL(v_usuario,'-')
                   || '</td></tr></table></div>';

  -- Detalle de comprobantes aplicados
  v_html := v_html || '<table class="kitems"><thead><tr>'
                   || '<th>Comprobante</th><th>Emisi&oacute;n</th><th>Vencimiento</th>'
                   || '<th>Deuda</th><th>Monto aplicado</th></tr></thead><tbody>';
  FOR r IN cd LOOP
    v_sumdet := v_sumdet + NVL(r.MONTO_APLICADO,0);
    v_html := v_html || '<tr><td>'||NVL(r.NRO_COMPROBANTE,'-')
                     || '</td><td>'||NVL(TO_CHAR(r.FEC_COMP,'dd/mm/yyyy'),'-')
                     || '</td><td>'||NVL(TO_CHAR(r.FECHA_VENCIMIENTO,'dd/mm/yyyy'),'-')
                     || '</td><td class="r">'||fmt(r.TOTAL_A_PAGAR)
                     || '</td><td class="r"><b>'||fmt(r.MONTO_APLICADO)||'</b></td></tr>';
  END LOOP;
  v_html := v_html || '</tbody></table>';

  -- Total
  v_html := v_html || '<table class="ktot"><tr><td><b>Total a pagar:</b></td>'
                   || '<td class="r"><b>'||fmt(NVL(v_total, v_sumdet))||'</b></td></tr></table>';

  IF v_obs IS NOT NULL THEN
    v_html := v_html || '<div class="kbox"><span class="klabel">Observaci&oacute;n</span><br>'||v_obs||'</div>';
  END IF;

  v_html := v_html || '<div class="kleg">Documento de control interno &mdash; orden de pago a proveedor.<br>'
                   || '<i>No es un documento electr&oacute;nico (SIFEN) &mdash; sin validez fiscal.</i><br>'
                   || 'Generado el '||TO_CHAR(WKSP_WORKPLACE.FN_AHORA,'dd/mm/yyyy hh24:mi')||'.</div></div>';

  RETURN v_html;
END FN_ORDEN_PAGO_HTML;
/

prompt == F24.4 Verificacion ==
DECLARE
  v_ok  BOOLEAN := TRUE;
  v_cnt PLS_INTEGER;
  v_clob CLOB;
  PROCEDURE chk(p_cond BOOLEAN, p_msg VARCHAR2) IS
  BEGIN
    IF p_cond THEN DBMS_OUTPUT.PUT_LINE('  OK   '||p_msg);
    ELSE DBMS_OUTPUT.PUT_LINE('  FAIL '||p_msg); v_ok := FALSE; END IF;
  END;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_objects
   WHERE owner='WKSP_WORKPLACE' AND object_name='FN_ORDEN_PAGO_HTML'
     AND object_type='FUNCTION' AND status='VALID';
  chk(v_cnt = 1, 'FUNCTION FN_ORDEN_PAGO_HTML VALID');

  v_clob := WKSP_WORKPLACE.FN_ORDEN_PAGO_HTML(-999);
  chk(v_clob LIKE '%no encontrada%', 'OP inexistente -> mensaje de error');

  IF v_ok THEN DBMS_OUTPUT.PUT_LINE('== F24.4 OK ==');
  ELSE RAISE_APPLICATION_ERROR(-20939,'F24.4 con errores'); END IF;
END;
/

set define on
