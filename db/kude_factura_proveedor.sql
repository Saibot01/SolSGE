-- ============================================================================
-- Documento Factura de Proveedor (FN_KUDE_FACTURA_PROV_HTML) - remaqueta P97
-- ============================================================================
-- Rehace el documento de "Factura de Proveedor" (P97) siguiendo la identidad
-- visual del KuDE de factura (F12, FN_KUDE_FACTURA_HTML / P96), pero del lado
-- COMPRA: la factura la emitio el PROVEEDOR y nosotros somos el receptor.
--
--   * EMISOR  = el PROVEEDOR (razon social + RUC + timbrado + N de la factura que
--               EL nos emitio) -> bloque de cabecera (khead), como en la venta el
--               emisor es nuestra empresa; aca el emisor es el proveedor.
--   * RECEPTOR = NUESTRA empresa (PARAMETROS TIPO='EMPRESA' via FN_GET_PARAMETRO),
--               en el recuadro krec.
--   * Condicion (Contado/Credito) desde COMPROBANTES_PROVEEDOR.FORMA_PAGO (F24);
--     si es credito muestra el vencimiento de la CxP (CUENTAS_PAGAR).
--
-- MATIZ: es la representacion grafica de un comprobante RECIBIDO (registro
-- interno), no un Documento Electronico emitido por nosotros -> sin CDC/QR,
-- leyenda "sin validez fiscal". Reusa clases kude, FN_NUMERO_A_LETRAS, FN_GET_PARAMETRO.
--
-- El detalle de compra (DETALLE_COMPROBANTE_PROV) no guarda IVA por linea, pero el
-- PRODUCTO trae su tasa (PRODUCTOS.ID_TIPO_IVA -> TIPO_IVA.PORCENTAJE, 10/5). Como
-- el precio en PYG es IVA INCLUIDO, el documento desglosa Exentas/Gravada 5%/10% y
-- liquida el IVA contenido (5% = base*5/105, 10% = base*10/110), igual que el KuDE
-- de venta.
--
-- Idempotente: CREATE OR REPLACE. Pre-requisitos: F12 (FN_NUMERO_A_LETRAS,
-- FN_GET_PARAMETRO, params EMPRESA), F24 (COMPROBANTES_PROVEEDOR.FORMA_PAGO,
-- CUENTAS_PAGAR.FECHA_VENCIMIENTO).
-- Ejecucion: sql -S -name tesis_db < db/kude_factura_proveedor.sql
-- ============================================================================
set define off
set serveroutput on

prompt == FN_KUDE_FACTURA_PROV_HTML ==
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_KUDE_FACTURA_PROV_HTML (
  p_id_comprobante IN NUMBER
) RETURN CLOB IS
  -- Receptor = nuestra empresa
  v_e_razon  VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('RAZON_SOCIAL','TEXTO'),'-');
  v_e_ruc    VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('RUC','TEXTO'),'-');
  v_e_dir    VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('DIRECCION','TEXTO'),'-');
  v_e_ciudad VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('CIUDAD','TEXTO'),'-');

  CURSOR cr IS
    SELECT TRIM(PE.PRIMER_NOMBRE||' '||PE.SEGUNDO_NOMBRE||' '||PE.PRIMER_APELLIDO||' '||PE.SEGUNDO_APELLIDO) AS PROVEEDOR,
           PE.ID_PERSONA, PE.NRO_DOCUMENTO, PE.CORREO,
           C.ID_COMPROBANTE, C.FECHA_EMISION, C.TOTAL_COMPROBANTE AS TOTAL,
           C.NRO_COMPROBANTE, C.NRO_TIMBRADO, C.FECHA_INICIO_TIMBRADO,
           C.TIPO_COMPROBANTE, C.FORMA_PAGO, C.ESTADO, C.OBSERVACION, C.ID_ORDEN_COMPRA,
           NVL(MO.DESCRIPCION, C.MONEDA) AS MONEDA, NVL(MO.ES_LOCAL,'S') AS ES_LOCAL
      FROM WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR C
      JOIN WKSP_WORKPLACE.PROVEEDORES PR ON PR.ID_PERSONA = C.ID_PROVEEDOR
      JOIN WKSP_WORKPLACE.PERSONAS    PE ON PE.ID_PERSONA = PR.ID_PERSONA
      LEFT JOIN WKSP_WORKPLACE.MONEDAS MO ON (MO.CODIGO_MONEDA = C.MONEDA OR MO.DESCRIPCION = C.MONEDA)
     WHERE C.ID_COMPROBANTE = p_id_comprobante;

  -- El detalle de compra no guarda IVA, pero el PRODUCTO trae su tasa
  -- (ID_TIPO_IVA -> TIPO_IVA.PORCENTAJE). Precio IVA incluido (PYG).
  CURSOR cd (p_id NUMBER) IS
    SELECT P.NOMBRE AS PRODUCTO, D.CANTIDAD, D.PRECIO_UNITARIO, D.TOTAL AS TOTAL_LINEA,
           NVL(TI.PORCENTAJE,0) AS PIVA
      FROM WKSP_WORKPLACE.DETALLE_COMPROBANTE_PROV D
      JOIN WKSP_WORKPLACE.PRODUCTOS P ON P.ID_PRODUCTO = D.ID_PRODUCTO
      LEFT JOIN WKSP_WORKPLACE.TIPO_IVA TI ON TI.ID_TIPO_IVA = P.ID_TIPO_IVA
     WHERE D.ID_COMPROBANTE = p_id
     ORDER BY D.ID_DETALLE;

  v_html     CLOB;
  v_cond     VARCHAR2(30);
  v_tel_pro  VARCHAR2(100);
  v_dir_pro  VARCHAR2(300);
  v_vto      DATE;
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
    v_cond := CASE WHEN v.FORMA_PAGO = '1' THEN 'Cr&eacute;dito' ELSE 'Contado' END;
    v_anul := (v.ESTADO = 'A');
    v_kclass := CASE WHEN v_anul THEN 'kude anulada' ELSE 'kude' END;

    -- Datos de contacto del proveedor (emisor)
    BEGIN
      SELECT NRO_TELEFONO INTO v_tel_pro
        FROM WKSP_WORKPLACE.TELEFONOS WHERE ID_PERSONA = v.ID_PERSONA AND ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_tel_pro := NULL; END;
    BEGIN
      SELECT TRIM(CALLE_PRINCIPAL||' '||NRO_CASA) INTO v_dir_pro
        FROM WKSP_WORKPLACE.DIRECCIONES WHERE ID_PERSONA = v.ID_PERSONA AND ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_dir_pro := NULL; END;

    -- Vencimiento (si es a credito, desde la CxP)
    v_vto := NULL;
    IF v.FORMA_PAGO = '1' THEN
      BEGIN
        SELECT FECHA_VENCIMIENTO INTO v_vto
          FROM WKSP_WORKPLACE.CUENTAS_PAGAR
         WHERE ID_COMPROBANTE = v.ID_COMPROBANTE AND ROWNUM = 1;
      EXCEPTION WHEN NO_DATA_FOUND THEN v_vto := NULL; END;
    END IF;

    IF v_anul THEN
      v_html := '<style>'
             || '.kude.anulada{position:relative;}'
             || '.kude.anulada .kanul-wm{position:absolute;top:50%;left:50%;'
             || 'transform:translate(-50%,-50%) rotate(-28deg);font-size:120px;'
             || 'font-weight:900;color:rgba(220,38,38,.22);letter-spacing:14px;'
             || 'border:10px solid rgba(220,38,38,.30);padding:18px 56px;border-radius:14px;'
             || 'pointer-events:none;z-index:999;white-space:nowrap;}'
             || '@media print{.kude.anulada .kanul-wm{color:rgba(220,38,38,.30);'
             || 'border-color:rgba(220,38,38,.45);-webkit-print-color-adjust:exact;'
             || 'print-color-adjust:exact;}}'
             || '</style>';
      v_html := v_html || '<div class="'||v_kclass||'"><div class="kanul-wm">ANULADA</div>';
    ELSE
      v_html := '<div class="'||v_kclass||'">';
    END IF;

    v_html := v_html || '<div class="ktit">Factura de Proveedor</div>';

    -- Cabecera: EMISOR = proveedor
    v_html := v_html || '<table class="khead"><tr><td class="kemis"><b>'||v.PROVEEDOR||'</b><br>'
                     || NVL(v_dir_pro,'-')||'<br>Tel.: '||NVL(v_tel_pro,'-')
                     || '<br>Correo: '||NVL(v.CORREO,'-')||'</td>';
    v_html := v_html || '<td class="r"><b>RUC:</b> '||NVL(v.NRO_DOCUMENTO,'-')
                     || '<br><b>Timbrado N&deg;:</b> '||NVL(v.NRO_TIMBRADO,'-')
                     || '<br><b>Inicio de Vigencia:</b> '||NVL(TO_CHAR(v.FECHA_INICIO_TIMBRADO,'dd/mm/yyyy'),'-')
                     || '<br><b>Factura de Compra ('||NVL(v.TIPO_COMPROBANTE,'FA')||')</b>'
                     || '<br><b>N&deg; '||NVL(v.NRO_COMPROBANTE,'-')||'</b></td></tr></table>';

    -- Recuadro: RECEPTOR = nuestra empresa + datos del comprobante
    v_html := v_html || '<div class="kbox"><table class="krec">';
    v_html := v_html || '<tr><td><span class="klabel">Receptor (Raz&oacute;n Social)</span><br>'||v_e_razon
                     || '</td><td><span class="klabel">RUC</span><br>'||v_e_ruc
                     || '</td><td><span class="klabel">Direcci&oacute;n</span><br>'||v_e_dir||' - '||v_e_ciudad||'</td></tr>';
    v_html := v_html || '<tr><td><span class="klabel">Fecha de Emisi&oacute;n</span><br>'||NVL(TO_CHAR(v.FECHA_EMISION,'dd/mm/yyyy'),'-')
                     || '</td><td><span class="klabel">Condici&oacute;n de Compra</span><br>'||v_cond
                     || '</td><td><span class="klabel">Moneda</span><br>'||NVL(v.MONEDA,'-')||'</td></tr>';
    v_html := v_html || '<tr><td><span class="klabel">Orden de Compra</span><br>'||NVL(TO_CHAR(v.ID_ORDEN_COMPRA),'-')
                     || '</td><td><span class="klabel">Vencimiento</span><br>'||NVL(TO_CHAR(v_vto,'dd/mm/yyyy'),'(contado)')
                     || '</td><td></td></tr></table></div>';

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

    -- IVA contenido (precio incluye IVA): 5% -> x*5/105, 10% -> x*10/110
    v_iva5  := ROUND(v_sub_5  * 5 / 105);
    v_iva10 := ROUND(v_sub_10 * 10 / 110);

    -- Total + liquidacion del IVA
    v_html := v_html || '<table class="ktot"><tr><td><b>Total a Pagar:</b> '
                     || CASE WHEN v.ES_LOCAL = 'S' THEN WKSP_WORKPLACE.FN_NUMERO_A_LETRAS(v.TOTAL)
                             ELSE WKSP_WORKPLACE.FN_NUMERO_A_LETRAS(v.TOTAL, v.MONEDA) END
                     || '</td><td class="r"><b>'||fmt(v.TOTAL)||'</b></td></tr>';
    v_html := v_html || '<tr><td>Liquidaci&oacute;n del IVA: (5%) '||fmt(v_iva5)||' &nbsp; (10%) '||fmt(v_iva10)
                     || '</td><td class="r"><b>Total IVA: '||fmt(v_iva5 + v_iva10)||'</b></td></tr></table>';

    IF v.OBSERVACION IS NOT NULL THEN
      v_html := v_html || '<div class="kbox"><span class="klabel">Observaci&oacute;n</span><br>'||v.OBSERVACION||'</div>';
    END IF;

    v_html := v_html || '<div class="kleg">Representaci&oacute;n gr&aacute;fica del comprobante recibido del proveedor '
                     || '(registro interno de compras).<br>'
                     || '<i>Representaci&oacute;n de demostraci&oacute;n &mdash; sin validez fiscal.</i></div>';

    IF v_anul THEN
      v_html := v_html || '<div class="kbox" style="border-color:#b91c1c;background:#fef2f2;color:#7f1d1d;">'
                       || '<b>COMPROBANTE ANULADO</b></div>';
    END IF;

    v_html := v_html || '</div>';
  END LOOP;

  IF v_html IS NULL THEN
    v_html := '<h2>Factura de proveedor no encontrada.</h2><p>Verifique que el ID corresponda a un comprobante v&aacute;lido.</p>';
  END IF;
  RETURN v_html;
END FN_KUDE_FACTURA_PROV_HTML;
/

prompt == Verificacion ==
DECLARE
  v_ok BOOLEAN := TRUE; v_cnt PLS_INTEGER; v_clob CLOB; v_id NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_objects
   WHERE owner='WKSP_WORKPLACE' AND object_name='FN_KUDE_FACTURA_PROV_HTML'
     AND object_type='FUNCTION' AND status='VALID';
  IF v_cnt=1 THEN DBMS_OUTPUT.PUT_LINE('  OK   FUNCTION VALID'); ELSE DBMS_OUTPUT.PUT_LINE('  FAIL'); v_ok:=FALSE; END IF;

  SELECT MIN(ID_COMPROBANTE) INTO v_id FROM WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR
   WHERE TOTAL_COMPROBANTE IS NOT NULL;
  IF v_id IS NOT NULL THEN
    v_clob := WKSP_WORKPLACE.FN_KUDE_FACTURA_PROV_HTML(v_id);
    IF DBMS_LOB.GETLENGTH(v_clob) > 0 AND v_clob LIKE '%Factura de Proveedor%'
       THEN DBMS_OUTPUT.PUT_LINE('  OK   HTML comprobante '||v_id||' ('||DBMS_LOB.GETLENGTH(v_clob)||' chars)');
       ELSE DBMS_OUTPUT.PUT_LINE('  FAIL HTML'); v_ok:=FALSE; END IF;
  END IF;

  v_clob := WKSP_WORKPLACE.FN_KUDE_FACTURA_PROV_HTML(-999);
  IF v_clob LIKE '%no encontrada%' THEN DBMS_OUTPUT.PUT_LINE('  OK   inexistente -> mensaje'); ELSE v_ok:=FALSE; END IF;

  IF v_ok THEN DBMS_OUTPUT.PUT_LINE('== FN_KUDE_FACTURA_PROV_HTML OK =='); ELSE RAISE_APPLICATION_ERROR(-20942,'con errores'); END IF;
END;
/
set define on
