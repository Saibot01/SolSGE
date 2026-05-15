prompt --application/pages/page_00087
begin
--   Manifest
--     PAGE: 00087
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
 p_id=>87
,p_name=>'Reporte de Revision'
,p_alias=>'REPORTE-DE-REVISION'
,p_page_mode=>'MODAL'
,p_step_title=>'Reporte de Revision'
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
,p_page_template_options=>'#DEFAULT#'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'25'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(15461161761249304)
,p_plug_name=>'Region de Botones'
,p_region_template_options=>'#DEFAULT#:t-Region--hideHeader js-addHiddenHeadingRoleDesc:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(15461247196249305)
,p_plug_name=>'Vista Previa'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_location=>null
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  -- Cursor de cabecera',
'  CURSOR cr_inv IS',
'    SELECT ',
'      i.ID_INVENTARIO,',
'      i.NRO_DOCUMENTO,',
'      o.DESCRIPCION AS OFICINA,',
'      TRUNC(i.FECHA_INVENTARIO) AS FECHA_INVENTARIO,',
'      i.ESTADO,',
'      i.USUARIO_ENVIO,',
'      i.FECHA_ENVIO,',
'      i.OBSERVACION',
'    FROM INVENTARIO i',
'    JOIN OFICINAS o ON o.CODIGO_OFICINA = i.ID_OFICINA',
'    WHERE i.ID_INVENTARIO = :P87_ID_INVENTARIO;',
'',
'  -- Cursor de detalle',
'  CURSOR cr_det IS',
'    SELECT',
'      NVL(s.NOMBRE,''(Sin sector)'') AS SECTOR,',
'      NVL(u.CODIGO,''-'') AS UBICACION,',
'      p.NOMBRE || NVL2(p.MODELO,'' - ''||p.MODELO,'''') AS PRODUCTO,',
'      d.STOCK_SISTEMA,',
'      d.CANTIDAD_FISICA,',
'      (d.CANTIDAD_FISICA - d.STOCK_SISTEMA) AS DIFERENCIA',
'    FROM INVENTARIO_DETALLE d',
'    LEFT JOIN SECTORES s ON s.ID_SECTOR = d.ID_SECTOR',
'    LEFT JOIN UBICACIONES u ON u.ID_UBICACION = d.ID_UBICACION',
'    JOIN PRODUCTOS p ON p.ID_PRODUCTO = d.ID_PRODUCTO',
'    WHERE d.ID_INVENTARIO = :P87_ID_INVENTARIO',
'    ORDER BY d.ORDEN_SECTOR, d.ORDEN_UBICACION, p.NOMBRE, p.MODELO;',
'',
'  v_html          CLOB;',
'  v_sector_actual VARCHAR2(200);',
'  v_subtotal_sistema   NUMBER := 0;',
'  v_subtotal_fisico    NUMBER := 0;',
'  v_subtotal_diferencia NUMBER := 0;',
'  v_total_sistema       NUMBER := 0;',
'  v_total_fisico        NUMBER := 0;',
'  v_total_diferencia    NUMBER := 0;',
'BEGIN',
'  FOR v_cab IN cr_inv LOOP',
'    v_html := ''',
'    <header>',
unistr('      <h1>REVISI\00D3N DE INVENTARIO</h1>'),
'      <address>',
'        <h4>',
'          Oficina: ''||v_cab.OFICINA||''<br>',
unistr('          N\00B0 Documento: ''||v_cab.NRO_DOCUMENTO||''<br>'),
'          Fecha Inventario: ''||TO_CHAR(v_cab.FECHA_INVENTARIO, ''DD/MM/YYYY'')||''<br>',
'          Estado: ''||v_cab.ESTADO||''<br>',
'          Enviado por: ''||NVL(v_cab.USUARIO_ENVIO,''-'')||'' (''||TO_CHAR(v_cab.FECHA_ENVIO,''DD/MM/YYYY'')||'')',
'        </h4>',
'      </address>',
'    </header>',
'',
'    <article>',
'      <table class="inventory">',
'        <thead>',
'          <tr>',
unistr('            <th><span>Ubicaci\00F3n</span></th>'),
'            <th><span>Producto</span></th>',
'            <th style="text-align:right;"><span>Stock Sistema</span></th>',
unistr('            <th style="text-align:right;"><span>Cantidad F\00EDsica</span></th>'),
'            <th style="text-align:right;"><span>Diferencia</span></th>',
'          </tr>',
'        </thead>',
'        <tbody>'';',
'',
'    v_sector_actual := NULL;',
'',
'    FOR v_det IN cr_det LOOP',
'      -- Si cambia el sector, mostrar subtotales previos',
'      IF v_sector_actual IS NOT NULL AND v_sector_actual <> v_det.SECTOR THEN',
'        v_html := v_html || ''',
'          <tr style="background:#e8e8e8; font-weight:bold;">',
'            <td colspan="2" style="text-align:right;">Subtotal ''||v_sector_actual||'':</td>',
'            <td style="text-align:right;">''||TO_CHAR(v_subtotal_sistema,''999G999G990'')||''</td>',
'            <td style="text-align:right;">''||TO_CHAR(v_subtotal_fisico,''999G999G990'')||''</td>',
'            <td style="text-align:right;">''||TO_CHAR(v_subtotal_diferencia,''999G999G990'')||''</td>',
'          </tr>'';',
'',
'        v_subtotal_sistema := 0;',
'        v_subtotal_fisico := 0;',
'        v_subtotal_diferencia := 0;',
'      END IF;',
'',
'      -- Si cambia el sector, agregar encabezado de grupo',
'      IF v_sector_actual IS NULL OR v_sector_actual <> v_det.SECTOR THEN',
'        v_sector_actual := v_det.SECTOR;',
'        v_html := v_html || ''',
'          <tr style="background:#f3f3f3;">',
'            <td colspan="5"><strong>Sector: ''||v_sector_actual||''</strong></td>',
'          </tr>'';',
'      END IF;',
'',
'      -- Detalle',
'      v_html := v_html || ''',
'        <tr>',
'          <td>''||v_det.UBICACION||''</td>',
'          <td>''||v_det.PRODUCTO||''</td>',
'          <td style="text-align:right;">''||NVL(TO_CHAR(v_det.STOCK_SISTEMA,''999G999G990''),'''')||''</td>',
'          <td style="text-align:right;">''||NVL(TO_CHAR(v_det.CANTIDAD_FISICA,''999G999G990''),'''')||''</td>',
'          <td style="text-align:right;">''||NVL(TO_CHAR(v_det.DIFERENCIA,''999G999G990''),'''')||''</td>',
'        </tr>'';',
'',
'      -- Acumuladores',
'      v_subtotal_sistema   := v_subtotal_sistema + NVL(v_det.STOCK_SISTEMA,0);',
'      v_subtotal_fisico    := v_subtotal_fisico + NVL(v_det.CANTIDAD_FISICA,0);',
'      v_subtotal_diferencia := v_subtotal_diferencia + NVL(v_det.DIFERENCIA,0);',
'',
'      v_total_sistema   := v_total_sistema + NVL(v_det.STOCK_SISTEMA,0);',
'      v_total_fisico    := v_total_fisico + NVL(v_det.CANTIDAD_FISICA,0);',
'      v_total_diferencia := v_total_diferencia + NVL(v_det.DIFERENCIA,0);',
'    END LOOP;',
'',
unistr('    -- Subtotal del \00FAltimo sector'),
'    v_html := v_html || ''',
'      <tr style="background:#e8e8e8; font-weight:bold;">',
'        <td colspan="2" style="text-align:right;">Subtotal ''||v_sector_actual||'':</td>',
'        <td style="text-align:right;">''||TO_CHAR(v_subtotal_sistema,''999G999G990'')||''</td>',
'        <td style="text-align:right;">''||TO_CHAR(v_subtotal_fisico,''999G999G990'')||''</td>',
'        <td style="text-align:right;">''||TO_CHAR(v_subtotal_diferencia,''999G999G990'')||''</td>',
'      </tr>'';',
'',
'    -- Totales generales',
'    v_html := v_html || ''',
'      <tr style="background:#ccc; font-weight:bold;">',
'        <td colspan="2" style="text-align:right;">TOTAL GENERAL:</td>',
'        <td style="text-align:right;">''||TO_CHAR(v_total_sistema,''999G999G990'')||''</td>',
'        <td style="text-align:right;">''||TO_CHAR(v_total_fisico,''999G999G990'')||''</td>',
'        <td style="text-align:right;">''||TO_CHAR(v_total_diferencia,''999G999G990'')||''</td>',
'      </tr>',
'      </tbody>',
'      </table>',
'    </article>'';',
'',
'    -- Observaciones y firmas',
'    v_html := v_html || ''',
'    <aside style="margin-top:40px;">',
'      <h3>Observaciones:</h3>',
'      <p>''||NVL(v_cab.OBSERVACION,''-'')||''</p>',
'    </aside>',
'',
'    <footer style="margin-top:50px;">',
'      <table style="width:100%; border:none;">',
'        <tr>',
'          <td style="width:33%; text-align:center;">',
'            ___________________________<br>',
'            <strong>Revisado por</strong>',
'          </td>',
'          <td style="width:33%; text-align:center;">',
'            ___________________________<br>',
'            <strong>Aprobado por</strong>',
'          </td>',
'          <td style="width:33%; text-align:center;">',
'            ___________________________<br>',
'            <strong>Fecha</strong>',
'          </td>',
'        </tr>',
'      </table>',
'    </footer>'';',
'  END LOOP;',
'',
'  RETURN v_html;',
'END;',
''))
,p_lazy_loading=>false
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(15461777067249310)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(15461161761249304)
,p_button_name=>'Imprimir'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Imprimir'
,p_warn_on_unsaved_changes=>null
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(15461331735249306)
,p_name=>'P87_ID_INVENTARIO'
,p_item_sequence=>20
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(15461872182249311)
,p_name=>'New'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(15461777067249310)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(15461913458249312)
,p_event_id=>wwv_flow_imp.id(15461872182249311)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'PLUGIN_PRINT.REGION.TO.PDF.V.2.0'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(15461247196249305)
);
wwv_flow_imp.component_end;
end;
/
