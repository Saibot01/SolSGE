-- ============================================================================
-- F26.1 — Documento Nota de Credito de Compra (FN_KUDE_NC_COMPRA_HTML)
-- ============================================================================
-- Representacion grafica de la NC que el PROVEEDOR nos emitio (F26). Espeja
-- FN_KUDE_FACTURA_PROV_HTML (db/kude_factura_proveedor.sql) pero para la NC:
--   * EMISOR   = el PROVEEDOR (razon social + RUC + timbrado + N de la NC).
--   * RECEPTOR = NUESTRA empresa (PARAMETROS TIPO='EMPRESA').
--   * Muestra el MOTIVO (MOTIVOS_NOTA_CREDITO) y el DOCUMENTO ASOCIADO (la
--     factura de compra origen, derivada por join via ID_FAC_ORIGEN).
--   * Detalle con desglose de IVA por producto (precio IVA incluido, PYG).
-- MATIZ: comprobante RECIBIDO (registro interno), NO Documento Electronico
-- emitido por nosotros -> sin CDC/QR, leyenda "sin validez fiscal".
-- Idempotente. Pre-req: F26 (COD_MOTIVO, la NC), F12 (FN_NUMERO_A_LETRAS,
-- FN_GET_PARAMETRO), F24. Ejecucion: sql -S -name tesis_db < db/F26_1_kude_nc_compra.sql
-- ============================================================================
set define off
set serveroutput on

prompt == FN_KUDE_NC_COMPRA_HTML ==
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_KUDE_NC_COMPRA_HTML (
  p_id_nc IN NUMBER
) RETURN CLOB IS
  v_e_razon  VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('RAZON_SOCIAL','TEXTO'),'-');
  v_e_ruc    VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('RUC','TEXTO'),'-');
  v_e_dir    VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('DIRECCION','TEXTO'),'-');
  v_e_ciudad VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('CIUDAD','TEXTO'),'-');

  CURSOR cr IS
    SELECT TRIM(PE.PRIMER_NOMBRE||' '||PE.SEGUNDO_NOMBRE||' '||PE.PRIMER_APELLIDO||' '||PE.SEGUNDO_APELLIDO) AS PROVEEDOR,
           PE.ID_PERSONA, PE.NRO_DOCUMENTO, PE.CORREO,
           C.ID_COMPROBANTE, C.FECHA_EMISION, C.TOTAL_COMPROBANTE AS TOTAL,
           C.NRO_COMPROBANTE, C.NRO_TIMBRADO, C.FECHA_INICIO_TIMBRADO,
           C.ESTADO, C.OBSERVACION, C.COD_MOTIVO,
           NVL(MNC.DESCRIPCION,'-') AS MOTIVO,
           FO.NRO_COMPROBANTE AS FO_NRO, FO.FECHA_EMISION AS FO_FECHA, FO.NRO_TIMBRADO AS FO_TIMB,
           NVL(MO.DESCRIPCION, C.MONEDA) AS MONEDA, NVL(MO.ES_LOCAL,'S') AS ES_LOCAL
      FROM WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR C
      JOIN WKSP_WORKPLACE.PROVEEDORES PR ON PR.ID_PERSONA = C.ID_PROVEEDOR
      JOIN WKSP_WORKPLACE.PERSONAS    PE ON PE.ID_PERSONA = PR.ID_PERSONA
      LEFT JOIN WKSP_WORKPLACE.MOTIVOS_NOTA_CREDITO MNC ON MNC.COD_MOTIVO = C.COD_MOTIVO
      LEFT JOIN WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR FO ON FO.ID_COMPROBANTE = C.ID_FAC_ORIGEN
      LEFT JOIN WKSP_WORKPLACE.MONEDAS MO ON (MO.CODIGO_MONEDA = C.MONEDA OR MO.DESCRIPCION = C.MONEDA)
     WHERE C.ID_COMPROBANTE = p_id_nc AND C.TIPO_COMPROBANTE = 'NC';

  CURSOR cd (p_id NUMBER) IS
    SELECT P.NOMBRE AS PRODUCTO, D.CANTIDAD, D.PRECIO_UNITARIO, D.TOTAL AS TOTAL_LINEA,
           NVL(TI.PORCENTAJE,0) AS PIVA
      FROM WKSP_WORKPLACE.DETALLE_COMPROBANTE_PROV D
      JOIN WKSP_WORKPLACE.PRODUCTOS P ON P.ID_PRODUCTO = D.ID_PRODUCTO
      LEFT JOIN WKSP_WORKPLACE.TIPO_IVA TI ON TI.ID_TIPO_IVA = P.ID_TIPO_IVA
     WHERE D.ID_COMPROBANTE = p_id
     ORDER BY D.ID_DETALLE;

  v_html     CLOB;
  v_tel_pro  VARCHAR2(100);
  v_dir_pro  VARCHAR2(300);
  v_sub_ex   NUMBER; v_sub_5 NUMBER; v_sub_10 NUMBER;
  v_iva5     NUMBER; v_iva10 NUMBER;
  v_ce       VARCHAR2(40); v_c5 VARCHAR2(40); v_c10 VARCHAR2(40);
  v_anul     BOOLEAN;
  v_kclass   VARCHAR2(40);

  FUNCTION fmt(n NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TRANSLATE(TO_CHAR(NVL(n,0),'FM999G999G999G990'), ',', '.');
  END;
BEGIN
  FOR v IN cr LOOP
    v_sub_ex := 0; v_sub_5 := 0; v_sub_10 := 0;
    v_anul := (v.ESTADO = 'A');
    v_kclass := CASE WHEN v_anul THEN 'kude anulada' ELSE 'kude' END;

    BEGIN
      SELECT NRO_TELEFONO INTO v_tel_pro
        FROM WKSP_WORKPLACE.TELEFONOS WHERE ID_PERSONA = v.ID_PERSONA AND ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_tel_pro := NULL; END;
    BEGIN
      SELECT TRIM(CALLE_PRINCIPAL||' '||NRO_CASA) INTO v_dir_pro
        FROM WKSP_WORKPLACE.DIRECCIONES WHERE ID_PERSONA = v.ID_PERSONA AND ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_dir_pro := NULL; END;

    IF v_anul THEN
      v_html := '<style>'
             || '.kude.anulada{position:relative;}'
             || '.kude.anulada .kanul-wm{position:absolute;top:50%;left:50%;'
             || 'transform:translate(-50%,-50%) rotate(-28deg);font-size:120px;'
             || 'font-weight:900;color:rgba(220,38,38,.22);letter-spacing:14px;'
             || 'border:10px solid rgba(220,38,38,.30);padding:18px 56px;border-radius:14px;'
             || 'pointer-events:none;z-index:999;white-space:nowrap;}'
             || '</style>';
      v_html := v_html || '<div class="'||v_kclass||'"><div class="kanul-wm">ANULADA</div>';
    ELSE
      v_html := '<div class="'||v_kclass||'">';
    END IF;

    v_html := v_html || '<div class="ktit">Nota de Cr&eacute;dito de Compra</div>';

    -- Cabecera: EMISOR = proveedor
    v_html := v_html || '<table class="khead"><tr><td class="kemis"><b>'||v.PROVEEDOR||'</b><br>'
                     || NVL(v_dir_pro,'-')||'<br>Tel.: '||NVL(v_tel_pro,'-')
                     || '<br>Correo: '||NVL(v.CORREO,'-')||'</td>';
    v_html := v_html || '<td class="r"><b>RUC:</b> '||NVL(v.NRO_DOCUMENTO,'-')
                     || '<br><b>Timbrado N&deg;:</b> '||NVL(v.NRO_TIMBRADO,'-')
                     || '<br><b>Nota de Cr&eacute;dito (NC)</b>'
                     || '<br><b>N&deg; '||NVL(v.NRO_COMPROBANTE,'-')||'</b></td></tr></table>';

    -- Recuadro: RECEPTOR = nuestra empresa + motivo + documento asociado
    v_html := v_html || '<div class="kbox"><table class="krec">';
    v_html := v_html || '<tr><td><span class="klabel">Receptor (Raz&oacute;n Social)</span><br>'||v_e_razon
                     || '</td><td><span class="klabel">RUC</span><br>'||v_e_ruc
                     || '</td><td><span class="klabel">Direcci&oacute;n</span><br>'||v_e_dir||' - '||v_e_ciudad||'</td></tr>';
    v_html := v_html || '<tr><td><span class="klabel">Fecha de Emisi&oacute;n</span><br>'||NVL(TO_CHAR(v.FECHA_EMISION,'dd/mm/yyyy'),'-')
                     || '</td><td><span class="klabel">Motivo</span><br>'||v.MOTIVO
                     || '</td><td><span class="klabel">Moneda</span><br>'||NVL(v.MONEDA,'-')||'</td></tr>';
    v_html := v_html || '<tr><td><span class="klabel">Documento asociado (Factura)</span><br>'||NVL(v.FO_NRO,'-')
                     || '</td><td><span class="klabel">Fecha factura</span><br>'||NVL(TO_CHAR(v.FO_FECHA,'dd/mm/yyyy'),'-')
                     || '</td><td><span class="klabel">Timbrado factura</span><br>'||NVL(v.FO_TIMB,'-')||'</td></tr></table></div>';

    -- Detalle (columnas por tasa de IVA, precio IVA incluido)
    v_html := v_html || '<table class="kitems"><thead><tr><th>Cant.</th><th>Descripci&oacute;n</th>'
                     || '<th>Precio Unitario</th><th>Exentas</th><th>Gravada 5%</th><th>Gravada 10%</th>'
                     || '</tr></thead><tbody>';
    FOR d IN cd(v.ID_COMPROBANTE) LOOP
      v_ce := ''; v_c5 := ''; v_c10 := '';
      IF d.PIVA = 5 THEN
        v_sub_5 := v_sub_5 + NVL(d.TOTAL_LINEA,0); v_c5 := fmt(d.TOTAL_LINEA);
      ELSIF d.PIVA = 10 THEN
        v_sub_10 := v_sub_10 + NVL(d.TOTAL_LINEA,0); v_c10 := fmt(d.TOTAL_LINEA);
      ELSE
        v_sub_ex := v_sub_ex + NVL(d.TOTAL_LINEA,0); v_ce := fmt(d.TOTAL_LINEA);
      END IF;
      v_html := v_html || '<tr><td class="c">'||TO_CHAR(d.CANTIDAD)||'</td><td>'||d.PRODUCTO
                       || '</td><td class="r">'||fmt(d.PRECIO_UNITARIO)||'</td>'
                       || '<td class="r">'||v_ce||'</td><td class="r">'||v_c5||'</td><td class="r">'||v_c10||'</td></tr>';
    END LOOP;
    v_html := v_html || '<tr class="ksub"><td colspan="3" class="r"><b>Subtotales</b></td>'
                     || '<td class="r">'||fmt(v_sub_ex)||'</td><td class="r">'||fmt(v_sub_5)
                     || '</td><td class="r">'||fmt(v_sub_10)||'</td></tr></tbody></table>';

    v_iva5  := ROUND(v_sub_5  * 5 / 105);
    v_iva10 := ROUND(v_sub_10 * 10 / 110);

    v_html := v_html || '<table class="ktot"><tr><td><b>Total acreditado:</b> '
                     || CASE WHEN v.ES_LOCAL = 'S' THEN WKSP_WORKPLACE.FN_NUMERO_A_LETRAS(v.TOTAL)
                             ELSE WKSP_WORKPLACE.FN_NUMERO_A_LETRAS(v.TOTAL, v.MONEDA) END
                     || '</td><td class="r"><b>'||fmt(v.TOTAL)||'</b></td></tr>';
    v_html := v_html || '<tr><td>Liquidaci&oacute;n del IVA: (5%) '||fmt(v_iva5)||' &nbsp; (10%) '||fmt(v_iva10)
                     || '</td><td class="r"><b>Total IVA: '||fmt(v_iva5 + v_iva10)||'</b></td></tr></table>';

    IF v.OBSERVACION IS NOT NULL THEN
      v_html := v_html || '<div class="kbox"><span class="klabel">Observaci&oacute;n</span><br>'||v.OBSERVACION||'</div>';
    END IF;

    v_html := v_html || '<div class="kleg">Representaci&oacute;n gr&aacute;fica de la nota de cr&eacute;dito recibida del proveedor '
                     || '(registro interno de compras).<br>'
                     || '<i>Representaci&oacute;n de demostraci&oacute;n &mdash; sin validez fiscal.</i></div>';

    v_html := v_html || '</div>';
  END LOOP;

  IF v_html IS NULL THEN
    v_html := '<h2>Nota de cr&eacute;dito no encontrada.</h2><p>Verifique que el ID corresponda a una NC de compra v&aacute;lida.</p>';
  END IF;
  RETURN v_html;
END FN_KUDE_NC_COMPRA_HTML;
/

prompt == Verificacion ==
DECLARE
  v_ok BOOLEAN := TRUE; v_cnt PLS_INTEGER; v_clob CLOB; v_id NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_objects
   WHERE owner='WKSP_WORKPLACE' AND object_name='FN_KUDE_NC_COMPRA_HTML'
     AND object_type='FUNCTION' AND status='VALID';
  IF v_cnt=1 THEN DBMS_OUTPUT.PUT_LINE('  OK   FUNCTION VALID'); ELSE DBMS_OUTPUT.PUT_LINE('  FAIL'); v_ok:=FALSE; END IF;

  SELECT MAX(ID_COMPROBANTE) INTO v_id FROM WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR
   WHERE TIPO_COMPROBANTE='NC';
  IF v_id IS NOT NULL THEN
    v_clob := WKSP_WORKPLACE.FN_KUDE_NC_COMPRA_HTML(v_id);
    IF DBMS_LOB.GETLENGTH(v_clob) > 0 AND v_clob LIKE '%Nota de Cr%dito de Compra%'
       THEN DBMS_OUTPUT.PUT_LINE('  OK   HTML NC '||v_id||' ('||DBMS_LOB.GETLENGTH(v_clob)||' chars)');
       ELSE DBMS_OUTPUT.PUT_LINE('  FAIL HTML'); v_ok:=FALSE; END IF;
  END IF;

  v_clob := WKSP_WORKPLACE.FN_KUDE_NC_COMPRA_HTML(-999);
  IF v_clob LIKE '%no encontrada%' THEN DBMS_OUTPUT.PUT_LINE('  OK   inexistente -> mensaje'); ELSE v_ok:=FALSE; END IF;

  IF v_ok THEN DBMS_OUTPUT.PUT_LINE('== FN_KUDE_NC_COMPRA_HTML OK =='); ELSE RAISE_APPLICATION_ERROR(-20912,'con errores'); END IF;
END;
/
set define on
