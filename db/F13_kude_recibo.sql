-- ============================================================================
-- F13 - P119 (Documento Recibo) con identidad visual KuDE
-- ============================================================================
-- Aplica a P119 el MISMO maquetado visual que P96 (F12), para coherencia de
-- marca entre los comprobantes impresos del sistema.
--
-- IMPORTANTE - matiz SIFEN: el RECIBO DE COBRO/DINERO **no** es un Documento
-- Electronico regulado por SIFEN (SIFEN cubre factura, NC/ND, remision,
-- autofactura). Por eso este documento NO lleva CDC ni QR ni se titula "KuDE":
-- se titula "RECIBO DE DINERO". Es un comprobante (timbrado via talonario RC)
-- pero no electronico. Reusa el estilo visual del KuDE solo por coherencia.
--
-- Contenido:
--   FN_KUDE_RECIBO_HTML(p_id_recibo): arma el HTML del recibo. P119 lo invoca
--   con RETURN FN_KUDE_RECIBO_HTML(:P119_ID_RECIBO).
--
-- Reusa: FN_GET_PARAMETRO (emisor), FN_NUMERO_A_LETRAS (total en letras) de F12.
-- Pre-requisitos: F12_kude_factura.sql aplicado; V_RECIBOS_COBRO existente (F8/F9).
--
-- Idempotente: CREATE OR REPLACE.
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion: sql -S -name tesis_db @db/F13_kude_recibo.sql
-- ============================================================================
set define off
set serveroutput on

prompt == F13.1 FN_KUDE_RECIBO_HTML ==
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_KUDE_RECIBO_HTML (
  p_id_recibo IN NUMBER
) RETURN CLOB IS
  v_razon  VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('RAZON_SOCIAL','TEXTO'),'-');
  v_ruc    VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('RUC','TEXTO'),'-');
  v_dir    VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('DIRECCION','TEXTO'),'-');
  v_ciudad VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('CIUDAD','TEXTO'),'-');
  v_tel    VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('TELEFONO','TEXTO'),'-');
  v_act    VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('ACTIVIDAD_ECONOMICA','TEXTO'),'-');

  CURSOR cr IS
    SELECT TRIM(PE.PRIMER_NOMBRE||' '||PE.SEGUNDO_NOMBRE||' '||PE.PRIMER_APELLIDO||' '||PE.SEGUNDO_APELLIDO) AS CLIENTE,
           PE.ID_PERSONA, PE.NRO_DOCUMENTO, PE.CORREO,
           V.ID_RECIBO, V.NRO_RECIBO, V.FECHA_EMISION_RECIBO, V.USUARIO,
           V.TOTAL_MONEDA_LOCAL AS TOTAL, V.OBSERVACION, V.NRO_CUOTA, V.ID_CXC, V.COMPROBANTE_ORIGEN,
           NVL(MO.DESCRIPCION, V.MONEDA) AS MONEDA, MO.ES_LOCAL,
           C.NRO_COMPROBANTE AS NRO_COMP_ORIGEN,
           T.TIMBRADO, T.FECHA_INICIO AS TIMB_INI
      FROM WKSP_WORKPLACE.V_RECIBOS_COBRO V
      JOIN WKSP_WORKPLACE.PERSONAS  PE ON PE.ID_PERSONA = V.ID_PERSONA
      LEFT JOIN WKSP_WORKPLACE.COMPROBANTES C ON C.ID_COMPROBANTE = V.COMPROBANTE_ORIGEN
      LEFT JOIN WKSP_WORKPLACE.MONEDAS     MO ON (MO.CODIGO_MONEDA = V.MONEDA OR MO.DESCRIPCION = V.MONEDA)
      JOIN WKSP_WORKPLACE.TALONARIOS T ON T.ID_TALONARIO = V.ID_TALONARIO_RECIBO
     WHERE V.ID_RECIBO = p_id_recibo;

  CURSOR cp (p_id NUMBER) IS
    SELECT NVL(MP.NOMBRE,'-') AS METODO_PAGO,
           D.MONTO_LOCAL, D.NRO_REFERENCIA
      FROM WKSP_WORKPLACE.DETALLE_MOVIMIENTO_CAJA D
      LEFT JOIN WKSP_WORKPLACE.METODOS_PAGO MP ON MP.ID_METODO_PAGO = D.ID_METODO_PAGO
     WHERE D.ID_MOVIMIENTO = p_id
     ORDER BY D.ID_DETALLE;

  v_html    CLOB;
  v_tel_cli VARCHAR2(100); v_dir_cli VARCHAR2(300);
  v_origen  VARCHAR2(200);

  FUNCTION fmt(n NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TRANSLATE(TO_CHAR(NVL(n,0),'FM999G999G999G990'), ',', '.');
  END;
BEGIN
  FOR v IN cr LOOP
    BEGIN
      SELECT NRO_TELEFONO INTO v_tel_cli
        FROM WKSP_WORKPLACE.TELEFONOS WHERE ID_PERSONA = v.ID_PERSONA AND ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_tel_cli := NULL; END;
    BEGIN
      SELECT TRIM(CALLE_PRINCIPAL||' '||NRO_CASA) INTO v_dir_cli
        FROM WKSP_WORKPLACE.DIRECCIONES WHERE ID_PERSONA = v.ID_PERSONA AND ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_dir_cli := NULL; END;

    v_origen := 'Cobro de cuota N&deg; '||v.NRO_CUOTA||' de la cuenta corriente #'||v.ID_CXC;
    IF v.NRO_COMP_ORIGEN IS NOT NULL THEN
      v_origen := v_origen||' (factura origen N&deg; '||v.NRO_COMP_ORIGEN||')';
    END IF;

    v_html := '<div class="kude"><div class="ktit">Recibo de Dinero</div>';
    v_html := v_html || '<table class="khead"><tr><td class="kemis"><b>'||v_razon||'</b><br>'
                     || v_dir||'<br>'||v_ciudad||'<br>Tel.: '||v_tel||'<br>Act. Econ.: '||v_act||'</td>';
    v_html := v_html || '<td class="r"><b>RUC:</b> '||v_ruc
                     || '<br><b>Timbrado N&deg;:</b> '||NVL(v.TIMBRADO,'-')
                     || '<br><b>Inicio de Vigencia:</b> '||NVL(TO_CHAR(v.TIMB_INI,'dd/mm/yyyy'),'-')
                     || '<br><b>Recibo de Dinero</b><br><b>N&deg; '||NVL(v.NRO_RECIBO,'-')||'</b></td></tr></table>';

    v_html := v_html || '<div class="kbox"><table class="krec">';
    v_html := v_html || '<tr><td><span class="klabel">Nombre o Raz&oacute;n Social</span><br>'||v.CLIENTE
                     || '</td><td><span class="klabel">RUC / CI</span><br>'||NVL(v.NRO_DOCUMENTO,'-')
                     || '</td><td><span class="klabel">Tel&eacute;fono</span><br>'||NVL(v_tel_cli,'-')||'</td></tr>';
    v_html := v_html || '<tr><td><span class="klabel">Direcci&oacute;n</span><br>'||NVL(v_dir_cli,'-')
                     || '</td><td><span class="klabel">Correo Electr&oacute;nico</span><br>'||NVL(v.CORREO,'-')
                     || '</td><td><span class="klabel">Moneda</span><br>'||NVL(v.MONEDA,'-')||'</td></tr>';
    v_html := v_html || '<tr><td><span class="klabel">Fecha de Emisi&oacute;n</span><br>'||NVL(TO_CHAR(v.FECHA_EMISION_RECIBO,'dd/mm/yyyy'),'-')
                     || '</td><td><span class="klabel">Cajero</span><br>'||NVL(v.USUARIO,'-')
                     || '</td><td></td></tr></table></div>';

    v_html := v_html || '<p style="margin:.2em 0 .6em;">'||v_origen||'</p>';

    v_html := v_html || '<table class="kitems"><thead><tr><th>M&eacute;todo de Pago</th>'
                     || '<th>Monto</th><th>Nro. Referencia</th></tr></thead><tbody>';
    FOR d IN cp(v.ID_RECIBO) LOOP
      v_html := v_html || '<tr><td>'||d.METODO_PAGO
                       || '</td><td class="r">'||fmt(d.MONTO_LOCAL)||'</td><td>'||NVL(d.NRO_REFERENCIA,'-')||'</td></tr>';
    END LOOP;
    v_html := v_html || '<tr class="ksub"><td class="r"><b>Total Cobrado</b></td>'
                     || '<td class="r"><b>'||fmt(v.TOTAL)||'</b></td><td></td></tr></tbody></table>';

    v_html := v_html || '<table class="ktot"><tr><td><b>Total Cobrado:</b> '
                     || CASE WHEN v.ES_LOCAL = 'S' THEN WKSP_WORKPLACE.FN_NUMERO_A_LETRAS(v.TOTAL)
                             ELSE WKSP_WORKPLACE.FN_NUMERO_A_LETRAS(v.TOTAL, v.MONEDA) END
                     || '</td><td class="r"><b>'||fmt(v.TOTAL)||'</b></td></tr></table>';

    IF v.OBSERVACION IS NOT NULL THEN
      v_html := v_html || '<div class="kbox"><span class="klabel">Observaciones</span><br>'||v.OBSERVACION||'</div>';
    END IF;

    v_html := v_html || '<div class="kleg">Comprobante de cobro &mdash; recibo de dinero no electr&oacute;nico.<br>'
                     || '<i>Representaci&oacute;n de demostraci&oacute;n &mdash; sin validez fiscal.</i></div></div>';
  END LOOP;

  IF v_html IS NULL THEN
    v_html := '<h2>Recibo no encontrado.</h2><p>Verifique que el ID indicado corresponda a un movimiento de cobro v&aacute;lido.</p>';
  END IF;
  RETURN v_html;
END FN_KUDE_RECIBO_HTML;
/

prompt == F13.2 Verificacion final ==
DECLARE
  v_ok  BOOLEAN := TRUE;
  v_cnt PLS_INTEGER;
  v_id  NUMBER;
  v_clob CLOB;

  PROCEDURE chk(p_cond BOOLEAN, p_msg VARCHAR2) IS
  BEGIN
    IF p_cond THEN
      DBMS_OUTPUT.PUT_LINE('  OK   '||p_msg);
    ELSE
      DBMS_OUTPUT.PUT_LINE('  FAIL '||p_msg);
      v_ok := FALSE;
    END IF;
  END;
BEGIN
  SELECT COUNT(*) INTO v_cnt
    FROM all_objects
   WHERE owner='WKSP_WORKPLACE' AND object_name='FN_KUDE_RECIBO_HTML'
     AND object_type='FUNCTION' AND status='VALID';
  chk(v_cnt = 1, 'FUNCTION FN_KUDE_RECIBO_HTML VALID');

  SELECT MAX(ID_MOVIMIENTO) INTO v_id
    FROM WKSP_WORKPLACE.MOVIMIENTOS_CAJA WHERE TIPO='COBRO_CXC';
  IF v_id IS NOT NULL THEN
    v_clob := WKSP_WORKPLACE.FN_KUDE_RECIBO_HTML(v_id);
    chk(DBMS_LOB.GETLENGTH(v_clob) > 0 AND v_clob LIKE '%Recibo de Dinero%',
        'FN_KUDE_RECIBO_HTML(ID='||v_id||') genera HTML ('||DBMS_LOB.GETLENGTH(v_clob)||' chars)');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  -    sin recibos COBRO_CXC: smoke test omitido');
  END IF;

  IF v_ok THEN
    DBMS_OUTPUT.PUT_LINE('== F13 OK ==');
  ELSE
    DBMS_OUTPUT.PUT_LINE('== F13 CON ERRORES ==');
  END IF;
END;
/

set define on
