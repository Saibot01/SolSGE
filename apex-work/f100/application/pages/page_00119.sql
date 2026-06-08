prompt --application/pages/page_00119
begin
--   Manifest
--     PAGE: 00119
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.17'
,p_default_workspace_id=>7697821598969118
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'WKSP_WORKPLACE'
);
wwv_flow_imp_page.create_page(
 p_id=>119
,p_name=>'Documento Recibo'
,p_alias=>'DOCUMENTO-RECIBO'
,p_page_mode=>'MODAL'
,p_step_title=>'Documento Recibo'
,p_autocomplete_on_off=>'OFF'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'/* heading */',
'',
'h1 { font: bold 100% sans-serif; letter-spacing: 0.5em; text-align: center; text-transform: uppercase; }',
'',
'/* table */',
'',
'table { font-size: 75%; table-layout: auto; width: 100%; }',
'table { border-collapse: separate; border-spacing: 2px; }',
'th, td { border-width: 1px; padding: 0.5em; position: relative; text-align: left; }',
'th, td { border-radius: 0.25em; border-style: solid; }',
'th { background: #EEE; border-color: #BBB; }',
'td { border-color: #DDD; }',
'',
'/* page */',
'',
'html { font: 16px/1 ''Open Sans'', sans-serif; overflow: auto; }',
'html { background: #999; cursor: default; }',
'',
'body { box-sizing: border-box; margin: 0 auto; overflow: hidden; width: 8.5in; }',
'body { background: #FFF; border-radius: 1px; box-shadow: 0 0 0in -0.25in rgba(0, 0, 0, 0.5); }',
'',
'/* header */',
'',
'header { margin: 0 0 0; }',
'header:after { clear: both; content: ""; display: table; }',
'header h1 { background: #000; border-radius: 0.25em; color: #FFF; margin: 0 0 1em; padding: 0.5em 0; }',
'',
'/* article */',
'',
'article, article address, table.meta, table.inventory { margin: 0 0 3em; }',
'article:after { clear: both; content: ""; display: table; }',
'article h1 { clip: rect(0 0 0 0); position: absolute; }',
'article address { float: left; font-size: 125%; font-weight: bold; }',
'',
'/* table meta & balance */',
'',
'table.meta, table.balance { float: right; width: 36%; }',
'table.meta:after, table.balance:after { clear: both; content: ""; display: table; }',
'table.meta th { width: 40%; }',
'table.meta td { width: 60%; }',
'',
'/* table items */',
'',
'table.inventory { clear: both; width: 100%; }',
'table.inventory th { font-weight: bold; text-align: center; }',
'',
'/* table balance */',
'',
'table.balance th, table.balance td { width: 50%; }',
'table.balance td { text-align: right; }',
'',
'/* aside */',
'',
'aside h1 { border: none; border-width: 0 0 1px; margin: 0 0 1em; }',
'aside h1 { border-color: #999; border-bottom-style: solid; }',
'',
'@media print {',
'	* { -webkit-print-color-adjust: exact; }',
'	html { background: none; padding: 0; }',
'	body { box-shadow: none; margin: 0; }',
'	span:empty { display: none; }',
'}',
'',
'@page { margin: 0; }'))
,p_page_template_options=>'#DEFAULT#:ui-dialog--stretch'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'25'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(23000100000000001)
,p_plug_name=>'Recibo'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_location=>null
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  CURSOR cr_recibo IS',
'    SELECT',
'      TRIM(PE.PRIMER_NOMBRE || '' '' || PE.SEGUNDO_NOMBRE || '' '' ||',
'           PE.PRIMER_APELLIDO || '' '' || PE.SEGUNDO_APELLIDO) AS DATOS_CLIENTE,',
'      PE.NRO_DOCUMENTO,',
'      V.ID_RECIBO,',
'      V.NRO_RECIBO,',
'      V.FECHA_EMISION_RECIBO,',
'      V.TOTAL_MONEDA_LOCAL AS TOTAL,',
'      V.MONEDA,',
'      V.OBSERVACION,',
'      V.USUARIO,',
'      V.NRO_CUOTA,',
'      V.ID_CXC,',
'      V.COMPROBANTE_ORIGEN,',
'      C.NRO_COMPROBANTE AS NRO_COMP_ORIGEN,',
'      T.TIMBRADO,',
'      T.FECHA_INICIO AS TIMB_INICIO,',
'      T.FECHA_FIN    AS TIMB_FIN',
'    FROM V_RECIBOS_COBRO V',
'    JOIN PERSONAS PE ON PE.ID_PERSONA = V.ID_PERSONA',
'    LEFT JOIN COMPROBANTES C ON C.ID_COMPROBANTE = V.COMPROBANTE_ORIGEN',
'    JOIN TALONARIOS T ON T.ID_TALONARIO = V.ID_TALONARIO_RECIBO',
unistr('   WHERE V.ID_RECIBO = :P119_ID_RECIBO;  -- << par\00E1metro de entrada'),
'',
'  CURSOR cr_pagos (p_id_movimiento NUMBER) IS',
'    SELECT',
'      FP.DESCRIPCION AS FORMA_PAGO,',
'      NVL(MP.NOMBRE, ''-'') AS METODO_PAGO,',
'      D.MONTO_LOCAL,',
'      D.NRO_REFERENCIA',
'    FROM DETALLE_MOVIMIENTO_CAJA D',
'    JOIN FORMAS_PAGO FP ON FP.ID_FORMA_PAGO = D.ID_FORMA_PAGO',
'    LEFT JOIN METODOS_PAGO MP ON MP.ID_METODO_PAGO = D.ID_METODO_PAGO',
'   WHERE D.ID_MOVIMIENTO = p_id_movimiento',
'   ORDER BY D.ID_DETALLE;',
'',
'  v_retorno CLOB;',
'BEGIN',
'  FOR v_rec IN cr_recibo LOOP',
'    v_retorno := ''',
'    <header>',
'      <h1>RECIBO DE COBRO</h1>',
'      <address>',
'        <h5>RUC: '' || NVL(FN_GET_PARAMETRO(''RUC'',''TEXTO''), ''-'') || ''<br>',
unistr('        Denominaci\00F3n: '' || NVL(FN_GET_PARAMETRO(''RAZON_SOCIAL'',''TEXTO''), ''-'') || ''<br>'),
unistr('        Direcci\00F3n: '' || NVL(FN_GET_PARAMETRO(''DIRECCION'',''TEXTO''), ''-'') || ''<br>'),
'        Timbrado: '' || v_rec.TIMBRADO || ''<br>',
'        Vigencia: '' || TO_CHAR(v_rec.TIMB_INICIO, ''dd/mm/yyyy'') || '' - '' || TO_CHAR(v_rec.TIMB_FIN, ''dd/mm/yyyy'') || ''</h5>',
'      </address>',
'      <h1>CLIENTE</h1>',
'      <address>',
'        <h5>',
'          RUC/C.I.: '' || v_rec.NRO_DOCUMENTO || ''<br>',
unistr('          Nombre/Raz\00F3n Social: '' || v_rec.DATOS_CLIENTE || ''<br>'),
'          Moneda: '' || v_rec.MONEDA || ''',
'        </h5>',
'      </address>',
'    </header>',
'',
'    <table class="meta">',
'      <tr>',
'        <th><span>Nro. Recibo</span></th>',
'        <td><span>'' || v_rec.NRO_RECIBO || ''</span></td>',
'      </tr>',
'      <tr>',
unistr('        <th><span>Fecha Emisi\00F3n</span></th>'),
'        <td><span>'' || TO_CHAR(v_rec.FECHA_EMISION_RECIBO, ''dd/mm/yyyy'') || ''</span></td>',
'      </tr>',
'      <tr>',
'        <th><span>Cajero</span></th>',
'        <td><span>'' || v_rec.USUARIO || ''</span></td>',
'      </tr>',
'      <tr>',
'        <th><span>Total Cobrado</span></th>',
'        <td><span id="prefix">Gs.</span><span>'' || TO_CHAR(v_rec.TOTAL, ''999G999G999G999G990'') || ''</span></td>',
'      </tr>',
'    </table>',
'',
'    <article>',
unistr('      <h5>Cobro de cuota N\00B0 '' || v_rec.NRO_CUOTA || '' de la cuenta corriente #'' || v_rec.ID_CXC ||'),
'       CASE WHEN v_rec.NRO_COMP_ORIGEN IS NOT NULL THEN '' (factura origen #'' || v_rec.NRO_COMP_ORIGEN || '')'' ELSE '''' END || ''</h5>',
'      <table class="inventory">',
'        <thead>',
'          <tr>',
'            <th><span>Forma de Pago</span></th>',
unistr('            <th><span>M\00E9todo</span></th>'),
'            <th><span>Monto</span></th>',
'            <th><span>Nro. Referencia</span></th>',
'          </tr>',
'        </thead>',
'        <tbody>'';',
'',
'    FOR v_pago IN cr_pagos(v_rec.ID_RECIBO) LOOP',
'      v_retorno := v_retorno || ''',
'      <tr>',
'        <td><span>'' || v_pago.FORMA_PAGO || ''</span></td>',
'        <td><span>'' || v_pago.METODO_PAGO || ''</span></td>',
'        <td style="text-align:right"><span data-prefix>Gs.</span><span>'' || TO_CHAR(v_pago.MONTO_LOCAL, ''999G999G990D00'') || ''</span></td>',
'        <td><span>'' || NVL(v_pago.NRO_REFERENCIA, ''-'') || ''</span></td>',
'      </tr>'';',
'    END LOOP;',
'',
'    v_retorno := v_retorno || ''',
'        </tbody>',
'      </table>',
'',
'      <table class="balance">',
'        <tr>',
'          <th><span>Total Cobrado</span></th>',
'          <td><span data-prefix>Gs.</span><span>'' || TO_CHAR(v_rec.TOTAL, ''999G999G999G999G990'') || ''</span></td>',
'        </tr>',
'      </table>',
'    </article>',
'',
'    <aside>',
'      <h1><span>Notas</span></h1>',
'      <div>',
'        <p>'' || NVL(v_rec.OBSERVACION, ''Sin observaciones'') || ''</p>',
'      </div>',
'    </aside>'';',
'  END LOOP;',
'',
'  IF v_retorno IS NULL THEN',
unistr('    v_retorno := ''<h2>Recibo no encontrado.</h2><p>Verifique que el ID indicado corresponda a un movimiento de cobro v\00E1lido.</p>'';'),
'  END IF;',
'',
'  RETURN v_retorno;',
'END;'))
,p_lazy_loading=>false
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(23000100000000002)
,p_name=>'P119_ID_RECIBO'
,p_item_sequence=>20
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp.component_end;
end;
/
