-- ============================================================================
-- F17.1 - Documento de Arqueo y Cierre de Caja (FN_CIERRE_CAJA_HTML)
-- ============================================================================
-- H5 de PLAN_CIERRE_CAJA.md. Genera el HTML del documento de cierre/arqueo de
-- una caja. P132 (Documento Cierre de Caja) lo invoca con
--   RETURN FN_CIERRE_CAJA_HTML(:P132_ID_CAJA).
--
-- IMPORTANTE - matiz SIFEN: el arqueo de caja **no** es un Documento Electronico
-- (SIFEN cubre factura, NC/ND, remision, autofactura). Es un documento de
-- CONTROL INTERNO. Por eso NO lleva CDC ni QR ni se titula "KuDE": se titula
-- "Arqueo y Cierre de Caja" y reusa el estilo visual (clases kude) solo por
-- coherencia, igual que el recibo de F13.
--
-- Contenido: cabecera (emisor + caja/cajero/fechas/estado), saldo por moneda
-- (apertura/ingresos/egresos/esperado/declarado/diferencia desde V_CAJA_SALDO),
-- desglose por TIPO de movimiento y por FORMA DE PAGO.
--
-- Reusa: FN_GET_PARAMETRO (emisor) de F12, V_CAJA_SALDO de F17.
-- Pre-requisitos: F17_cierre_caja.sql aplicado.
--
-- Idempotente: CREATE OR REPLACE.
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion: sql -S -name tesis_db @db/F17_1_arqueo_html.sql
-- ============================================================================
set define off
set serveroutput on

prompt == F17.1 FN_CIERRE_CAJA_HTML ==
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_CIERRE_CAJA_HTML (
  p_id_caja IN NUMBER
) RETURN CLOB IS
  v_razon  VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('RAZON_SOCIAL','TEXTO'),'-');
  v_ruc    VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('RUC','TEXTO'),'-');
  v_dir    VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('DIRECCION','TEXTO'),'-');
  v_ciudad VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('CIUDAD','TEXTO'),'-');

  v_estado  CHAR(1);
  v_estadot VARCHAR2(20);
  v_fap     TIMESTAMP;
  v_fci     TIMESTAMP;
  v_uap     VARCHAR2(60);
  v_uci     VARCHAR2(60);
  v_caja    VARCHAR2(100);
  v_ofi     VARCHAR2(100);

  v_html    CLOB;
  v_tot_dif NUMBER := 0;
  v_hay_decl VARCHAR2(1) := 'N';

  CURSOR cm IS
    SELECT NVL(m.DESCRIPCION, v.MONEDA) AS MONEDA,
           v.MONTO_APERTURA, v.INGRESOS, v.EGRESOS, v.SALDO_ESPERADO,
           v.MONTO_DECLARADO, v.MONTO_DIFERENCIA
      FROM WKSP_WORKPLACE.V_CAJA_SALDO v
      LEFT JOIN WKSP_WORKPLACE.MONEDAS m ON m.CODIGO_MONEDA = v.MONEDA
     WHERE v.ID_CAJA = p_id_caja
     ORDER BY v.MONEDA;

  CURSOR ct IS
    SELECT CASE TIPO WHEN 'INGRESO_VENTA' THEN 'Venta contado'
                     WHEN 'COBRO_CXC'     THEN 'Cobro de cuota'
                     WHEN 'EGRESO'         THEN 'Egreso / Reverso'
                     WHEN 'AJUSTE'         THEN 'Ajuste' ELSE TIPO END AS TIPO_DESC,
           COUNT(*) AS CANT,
           SUM(NVL(TOTAL_MONEDA_ORIGEN, TOTAL_MONEDA_LOCAL)) AS TOTAL
      FROM WKSP_WORKPLACE.MOVIMIENTOS_CAJA
     WHERE ID_CAJA = p_id_caja
     GROUP BY TIPO
     ORDER BY TIPO;

  CURSOR cf IS
    SELECT NVL(fp.DESCRIPCION,'-') AS FORMA,
           COUNT(*) AS CANT,
           SUM(NVL(d.MONTO_LOCAL,0)) AS TOTAL
      FROM WKSP_WORKPLACE.DETALLE_MOVIMIENTO_CAJA d
      JOIN WKSP_WORKPLACE.MOVIMIENTOS_CAJA mc ON mc.ID_MOVIMIENTO = d.ID_MOVIMIENTO
                                              AND mc.ID_CAJA = p_id_caja
      LEFT JOIN WKSP_WORKPLACE.FORMAS_PAGO fp ON fp.ID_FORMA_PAGO = d.ID_FORMA_PAGO
     GROUP BY NVL(fp.DESCRIPCION,'-')
     ORDER BY 3 DESC;

  FUNCTION fmt(n NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TRANSLATE(TO_CHAR(ROUND(NVL(n,0)),'FM999G999G999G990'), ',', '.');
  END;
BEGIN
  BEGIN
    SELECT c.ESTADO, c.FEC_APERTURA, c.FEC_CIERRE, c.USU_APERTURA, c.USU_CIERRE,
           NVL(cf2.DESCRIPCION,'-'), NVL(o.DESCRIPCION,'-')
      INTO v_estado, v_fap, v_fci, v_uap, v_uci, v_caja, v_ofi
      FROM WKSP_WORKPLACE.CAJAS c
      LEFT JOIN WKSP_WORKPLACE.CAJA_CONF cf2 ON cf2.ID_CAJA_CONF = c.ID_CAJA_CONF
      LEFT JOIN WKSP_WORKPLACE.OFICINAS  o   ON o.CODIGO_OFICINA = c.ID_OFICINA
     WHERE c.ID_CAJA = p_id_caja;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN '<h2>Caja no encontrada.</h2><p>Verifique que el ID indicado corresponda a una caja v&aacute;lida.</p>';
  END;

  v_estadot := CASE v_estado WHEN 'A' THEN 'ABIERTA' WHEN 'C' THEN 'CERRADA' ELSE NVL(v_estado,'-') END;

  v_html := '<div class="kude"><div class="ktit">Arqueo y Cierre de Caja</div>';

  -- Cabecera emisor + caja
  v_html := v_html || '<table class="khead"><tr><td class="kemis"><b>'||v_razon||'</b><br>'
                   || v_dir||'<br>'||v_ciudad||'<br><b>RUC:</b> '||v_ruc||'</td>';
  v_html := v_html || '<td class="r"><b>Caja N&deg;:</b> '||p_id_caja
                   || '<br><b>'||v_caja||'</b>'
                   || '<br><b>Oficina:</b> '||v_ofi
                   || '<br><b>Estado:</b> '||v_estadot||'</td></tr></table>';

  -- Datos de la sesion
  v_html := v_html || '<div class="kbox"><table class="krec">';
  v_html := v_html || '<tr><td><span class="klabel">Cajero (apertura)</span><br>'||NVL(v_uap,'-')
                   || '</td><td><span class="klabel">Fecha de Apertura</span><br>'||NVL(TO_CHAR(v_fap,'dd/mm/yyyy hh24:mi'),'-')
                   || '</td><td></td></tr>';
  v_html := v_html || '<tr><td><span class="klabel">Cajero (cierre)</span><br>'||NVL(v_uci,'-')
                   || '</td><td><span class="klabel">Fecha de Cierre</span><br>'||NVL(TO_CHAR(v_fci,'dd/mm/yyyy hh24:mi'),'(caja abierta)')
                   || '</td><td></td></tr></table></div>';

  -- Saldo por moneda (arqueo)
  v_html := v_html || '<table class="kitems"><thead><tr>'
                   || '<th>Moneda</th><th>Apertura</th><th>Ingresos</th><th>Egresos</th>'
                   || '<th>Esperado</th><th>Declarado</th><th>Diferencia</th></tr></thead><tbody>';
  FOR r IN cm LOOP
    IF r.MONTO_DECLARADO IS NOT NULL THEN v_hay_decl := 'S'; END IF;
    v_tot_dif := v_tot_dif + NVL(r.MONTO_DIFERENCIA,0);
    v_html := v_html || '<tr><td>'||r.MONEDA
                     || '</td><td class="r">'||fmt(r.MONTO_APERTURA)
                     || '</td><td class="r">'||fmt(r.INGRESOS)
                     || '</td><td class="r">'||fmt(r.EGRESOS)
                     || '</td><td class="r"><b>'||fmt(r.SALDO_ESPERADO)||'</b>'
                     || '</td><td class="r">'||CASE WHEN r.MONTO_DECLARADO IS NULL THEN '-' ELSE fmt(r.MONTO_DECLARADO) END
                     || '</td><td class="r"'
                     || CASE WHEN NVL(r.MONTO_DIFERENCIA,0) < 0 THEN ' style="color:#b00020;"'
                             WHEN NVL(r.MONTO_DIFERENCIA,0) > 0 THEN ' style="color:#0a7d28;"' ELSE '' END
                     || '>'||CASE WHEN r.MONTO_DECLARADO IS NULL THEN '-' ELSE fmt(r.MONTO_DIFERENCIA) END
                     || '</td></tr>';
  END LOOP;
  v_html := v_html || '</tbody></table>';

  IF v_hay_decl = 'S' THEN
    v_html := v_html || '<table class="ktot"><tr><td><b>Diferencia total (declarado - esperado):</b></td>'
                     || '<td class="r"><b'
                     || CASE WHEN v_tot_dif < 0 THEN ' style="color:#b00020;"'
                             WHEN v_tot_dif > 0 THEN ' style="color:#0a7d28;"' ELSE '' END
                     || '>'||fmt(v_tot_dif)
                     || CASE WHEN v_tot_dif < 0 THEN ' (faltante)' WHEN v_tot_dif > 0 THEN ' (sobrante)' ELSE '' END
                     || '</b></td></tr></table>';
  ELSE
    v_html := v_html || '<p class="klabel" style="margin:.4em 0;">Sin conteo declarado registrado para esta caja.</p>';
  END IF;

  -- Desglose por tipo de movimiento
  v_html := v_html || '<div class="kbox"><span class="klabel">Desglose por tipo de movimiento</span>';
  v_html := v_html || '<table class="kitems" style="margin-top:.4em;"><thead><tr>'
                   || '<th>Tipo</th><th>Cantidad</th><th>Total</th></tr></thead><tbody>';
  FOR t IN ct LOOP
    v_html := v_html || '<tr><td>'||t.TIPO_DESC
                     || '</td><td class="r">'||t.CANT
                     || '</td><td class="r">'||fmt(t.TOTAL)||'</td></tr>';
  END LOOP;
  v_html := v_html || '</tbody></table></div>';

  -- Desglose por forma de pago
  v_html := v_html || '<div class="kbox"><span class="klabel">Desglose por forma de pago</span>';
  v_html := v_html || '<table class="kitems" style="margin-top:.4em;"><thead><tr>'
                   || '<th>Forma de Pago</th><th>Cantidad</th><th>Total</th></tr></thead><tbody>';
  FOR f IN cf LOOP
    v_html := v_html || '<tr><td>'||f.FORMA
                     || '</td><td class="r">'||f.CANT
                     || '</td><td class="r">'||fmt(f.TOTAL)||'</td></tr>';
  END LOOP;
  v_html := v_html || '</tbody></table></div>';

  v_html := v_html || '<div class="kleg">Documento de control interno &mdash; arqueo y cierre de caja.<br>'
                   || '<i>No es un documento electr&oacute;nico (SIFEN) &mdash; sin validez fiscal.</i><br>'
                   || 'Generado el '||TO_CHAR(WKSP_WORKPLACE.FN_AHORA,'dd/mm/yyyy hh24:mi')||'.</div></div>';

  RETURN v_html;
END FN_CIERRE_CAJA_HTML;
/

prompt == F17.1 Verificacion ==
DECLARE
  v_ok  BOOLEAN := TRUE;
  v_cnt PLS_INTEGER;
  v_id  NUMBER;
  v_clob CLOB;
  PROCEDURE chk(p_cond BOOLEAN, p_msg VARCHAR2) IS
  BEGIN
    IF p_cond THEN DBMS_OUTPUT.PUT_LINE('  OK   '||p_msg);
    ELSE DBMS_OUTPUT.PUT_LINE('  FAIL '||p_msg); v_ok := FALSE; END IF;
  END;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_objects
   WHERE owner='WKSP_WORKPLACE' AND object_name='FN_CIERRE_CAJA_HTML'
     AND object_type='FUNCTION' AND status='VALID';
  chk(v_cnt = 1, 'FUNCTION FN_CIERRE_CAJA_HTML VALID');

  -- smoke: caja cerrada con COBRO_CXC (67) y caja abierta (la ultima 'A')
  v_clob := WKSP_WORKPLACE.FN_CIERRE_CAJA_HTML(67);
  chk(DBMS_LOB.GETLENGTH(v_clob) > 0 AND v_clob LIKE '%Arqueo y Cierre de Caja%',
      'HTML caja 67 ('||DBMS_LOB.GETLENGTH(v_clob)||' chars)');

  SELECT MAX(ID_CAJA) INTO v_id FROM WKSP_WORKPLACE.CAJAS WHERE ESTADO='A';
  IF v_id IS NOT NULL THEN
    v_clob := WKSP_WORKPLACE.FN_CIERRE_CAJA_HTML(v_id);
    chk(v_clob LIKE '%ABIERTA%', 'HTML caja abierta '||v_id||' marca estado ABIERTA');
  END IF;

  v_clob := WKSP_WORKPLACE.FN_CIERRE_CAJA_HTML(-999);
  chk(v_clob LIKE '%no encontrada%', 'caja inexistente -> mensaje de error');

  IF v_ok THEN DBMS_OUTPUT.PUT_LINE('== F17.1 OK ==');
  ELSE RAISE_APPLICATION_ERROR(-20941,'F17.1 con errores'); END IF;
END;
/

set define on
