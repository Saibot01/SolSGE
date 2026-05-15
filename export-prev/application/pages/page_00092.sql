prompt --application/pages/page_00092
begin
--   Manifest
--     PAGE: 00092
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.15'
,p_default_workspace_id=>7697821598969118
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'WKSP_WORKPLACE'
);
wwv_flow_imp_page.create_page(
 p_id=>92
,p_name=>'Orden de Compra Documento'
,p_alias=>'ORDEN-DE-COMPRA-DOCUMENTO'
,p_page_mode=>'MODAL'
,p_step_title=>'Orden de Compra Documento'
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
'',
'/* header */',
'',
'header { margin: 0 0 0; }',
'header:after { clear: both; content: ""; display: table; }',
'',
'header h1 { background: #000; border-radius: 0.25em; color: #FFF; margin: 0 0 1em; padding: 0.5em 0; }',
'',
'/* article */',
'',
'article, article address, table.meta, table.inventory { margin: 0 0 3em; }',
'article:after { clear: both; content: ""; display: table; }',
'article h1 { clip: rect(0 0 0 0); position: absolute; }',
'',
'article address { float: left; font-size: 125%; font-weight: bold; }',
'',
'/* table meta & balance */',
'',
'table.meta, table.balance { float: right; width: 36%; }',
'table.meta:after, table.balance:after { clear: both; content: ""; display: table; }',
'',
'/* table meta */',
'',
'table.meta th { width: 40%; }',
'table.meta td { width: 60%; }',
'',
'/* table items */',
'',
'table.inventory { clear: both; width: 100%; }',
'table.inventory th { font-weight: bold; text-align: center; }',
'',
'table.inventory td:nth-child(1) { max-width: 10%; }',
'table.inventory td:nth-child(2) { min-width: 50%; }',
'table.inventory td:nth-child(3) { text-align: right; max-width: 10%; }',
'table.inventory td:nth-child(4) { text-align: right; max-width: 10%; }',
'table.inventory td:nth-child(5) { text-align: right; max-width: 10%; }',
'table.inventory td:nth-child(6) { text-align: right; max-width: 10%; }',
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
'/* javascript */',
'',
'.add, .cut',
'{',
'	border-width: 1px;',
'	display: block;',
'	font-size: .8rem;',
'	padding: 0.25em 0.5em;	',
'	float: left;',
'	text-align: center;',
'	width: 0.6em;',
'}',
'',
'.add, .cut',
'{',
'	background: #9AF;',
'	box-shadow: 0 1px 2px rgba(0,0,0,0.2);',
'	background-image: -moz-linear-gradient(#00ADEE 5%, #0078A5 100%);',
'	background-image: -webkit-linear-gradient(#00ADEE 5%, #0078A5 100%);',
'	border-radius: 0.5em;',
'	border-color: #0076A3;',
'	color: #FFF;',
'	cursor: pointer;',
'	font-weight: bold;',
'	text-shadow: 0 -1px 2px rgba(0,0,0,0.333);',
'}',
'',
'.add { margin: 0 0 0; }',
'',
'.add:hover { background: #00ADEE; }',
'',
'.cut { opacity: 0; position: absolute; top: 0; left: -1.5em; }',
'.cut { -webkit-transition: opacity 100ms ease-in; }',
'',
'tr:hover .cut { opacity: 1; }',
'',
'@media print {',
'	* { -webkit-print-color-adjust: exact; }',
'	html { background: none; padding: 0; }',
'	body { box-shadow: none; margin: 0; }',
'	span:empty { display: none; }',
'	.add, .cut { display: none; }',
'}',
'',
'@page { margin: 0; }'))
,p_page_template_options=>'#DEFAULT#:ui-dialog--stretch'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'25'
,p_created_on=>wwv_flow_imp.dz('20251121120929Z')
,p_last_updated_on=>wwv_flow_imp.dz('20251121121412Z')
,p_created_by=>'WILLIAN'
,p_last_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(15983742160097113)
,p_plug_name=>'New'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_location=>null
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  -- Cursor principal: datos generales de la orden',
'  CURSOR cr_orden IS',
'    SELECT ',
'      PE.PRIMER_NOMBRE || '' '' || PE.SEGUNDO_NOMBRE || '' '' ||',
'      PE.PRIMER_APELLIDO || '' '' || PE.SEGUNDO_APELLIDO AS PROVEEDOR,',
'      PE.NRO_DOCUMENTO AS RUC_PROVEEDOR,',
'      OC.ID_ORDEN_COMPRA,',
'      OC.FECHA_ORDEN,',
'      OC.TOTAL_ORDEN,',
'      OC.OBSERVACION,',
'      OC.ESTADO',
'    FROM ORDENES_COMPRA OC',
'    JOIN PROVEEDORES PR ON PR.ID_PERSONA = OC.ID_PROVEEDOR',
'    JOIN PERSONAS PE ON PE.ID_PERSONA = PR.ID_PERSONA',
'   WHERE OC.ID_ORDEN_COMPRA = :P92_ID_ORDEN_COMPRA;',
'',
'  -- Cursor detalle de productos',
'  CURSOR cr_detalles (p_id_orden NUMBER) IS',
'    SELECT ',
'      P.NOMBRE AS PRODUCTO,',
'      D.CANTIDAD,',
'      D.PRECIO_UNITARIO,',
'      D.TOTAL_DETALLE',
'    FROM DETALLE_ORDEN_COMPRA D',
'    JOIN PRODUCTOS P ON P.ID_PRODUCTO = D.ID_PRODUCTO',
'   WHERE D.ID_ORDEN_COMPRA = p_id_orden',
'   ORDER BY D.ID_DETALLE_OC;',
'',
'  v_html CLOB;',
'BEGIN',
'  FOR v_ord IN cr_orden LOOP',
'    v_html :=',
'    ''',
'    <header>',
'      <h1>ORDEN DE COMPRA</h1>',
'      <address>',
'        <h5>RUC: 80004571-1<br>',
unistr('        Denominaci\00F3n: SOLSGE<br>'),
unistr('        Direcci\00F3n: Itaugu\00E1 Km 25 Mboiy<br>'),
'        Inicio Actividad: 31/10/2023</h5>',
'      </address>',
'',
'      <h1>PROVEEDOR</h1>',
'      <address>',
'        <h5>',
'          RUC: '' || v_ord.RUC_PROVEEDOR || ''<br>',
unistr('          Raz\00F3n Social: '' || v_ord.PROVEEDOR || '''),
'        </h5>',
'      </address>',
'    </header>',
'',
'    <table class="meta">',
'      <tr>',
'        <th><span>ID Orden</span></th>',
'        <td><span>'' || v_ord.ID_ORDEN_COMPRA || ''</span></td>',
'      </tr>',
'      <tr>',
'        <th><span>Fecha Orden</span></th>',
'        <td><span>'' || TO_CHAR(v_ord.FECHA_ORDEN, ''dd/mm/yyyy'') || ''</span></td>',
'      </tr>',
'      <tr>',
'        <th><span>Estado</span></th>',
'        <td><span>'' || v_ord.ESTADO || ''</span></td>',
'      </tr>',
'      <tr>',
'        <th><span>Total</span></th>',
'        <td>',
'           <span id="prefix">Gs.</span>',
'           <span>'' || TO_CHAR(v_ord.TOTAL_ORDEN, ''999G999G999G990'') || ''</span>',
'        </td>',
'      </tr>',
'    </table>',
'',
'    <article>',
'      <table class="inventory">',
'        <thead>',
'          <tr>',
'            <th><span>Cantidad</span></th>',
'            <th><span>Producto</span></th>',
'            <th><span>Precio Unitario</span></th>',
unistr('            <th><span>Total L\00EDnea</span></th>'),
'          </tr>',
'        </thead>',
'        <tbody>'';',
'',
'    -- Detalle de productos',
'    FOR v_det IN cr_detalles(v_ord.ID_ORDEN_COMPRA) LOOP',
'      v_html := v_html || ''',
'      <tr>',
'        <td><span>'' || TO_CHAR(v_det.CANTIDAD) || ''</span></td>',
'        <td><span>'' || v_det.PRODUCTO || ''</span></td>',
'        <td><span>Gs.</span><span>'' || TO_CHAR(v_det.PRECIO_UNITARIO, ''999G999G990D00'') || ''</span></td>',
'        <td><span>Gs.</span><span>'' || TO_CHAR(v_det.TOTAL_DETALLE, ''999G999G990D00'') || ''</span></td>',
'      </tr>'';',
'    END LOOP;',
'',
'    v_html := v_html ||',
'    ''',
'        </tbody>',
'      </table>',
'',
'      <table class="balance">',
'        <tr>',
'          <th><span>Total Orden</span></th>',
'          <td><span>Gs.</span><span>'' || TO_CHAR(v_ord.TOTAL_ORDEN, ''999G999G999G990'') || ''</span></td>',
'        </tr>',
'      </table>',
'    </article>',
'',
'    <aside>',
'      <h1><span>Observaciones</span></h1>',
'      <div>',
'        <p>'' || NVL(v_ord.OBSERVACION, ''Sin observaciones'') || ''</p>',
'      </div>',
'    </aside>'';',
'  END LOOP;',
'',
'  RETURN v_html;',
'END;',
''))
,p_lazy_loading=>false
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
,p_created_on=>wwv_flow_imp.dz('20251121121053Z')
,p_updated_on=>wwv_flow_imp.dz('20251121121412Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(15983997313097115)
,p_name=>'P92_ID_ORDEN_COMPRA'
,p_item_sequence=>20
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20251121121053Z')
,p_updated_on=>wwv_flow_imp.dz('20251121121305Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp.component_end;
end;
/
