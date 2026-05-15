prompt --application/pages/page_00006
begin
--   Manifest
--     PAGE: 00006
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
 p_id=>6
,p_name=>'Reporte Orden de Venta'
,p_alias=>'REPORTE-ORDEN-DE-VENTA'
,p_page_mode=>'MODAL'
,p_step_title=>'Reporte Orden de Venta'
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
,p_created_on=>wwv_flow_imp.dz('20250509193630Z')
,p_last_updated_on=>wwv_flow_imp.dz('20250509200114Z')
,p_created_by=>'WILLIAN'
,p_last_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(12003587784524704)
,p_plug_name=>'New'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_location=>null
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  CURSOR cr_orden IS',
'    SELECT ',
'    PE.PRIMER_NOMBRE || '' '' || PE.SEGUNDO_NOMBRE || '' '' || PE.PRIMER_APELLIDO || '' '' || PE.SEGUNDO_APELLIDO AS DATOS,',
'    PE.NRO_DOCUMENTO,',
'    VE.ID_ORDEN,',
'    VE.FECHA_ORDEN,',
'    VE.TOTAL,',
'    VE.OBSERVACION FROM  ORDENES_VENTA VE, PERSONAS PE',
'WHERE PE.ID_PERSONA = VE.ID_PERSONA',
'    AND ID_ORDEN = :P6_ID_ORDEN;',
'',
'  CURSOR cr_detalles (p_id_orden NUMBER) IS',
'    SELECT PR.NOMBRE,',
'        DE.CANTIDAD,',
'        DE.PRECIO_UNITARIO',
'         FROM DETALLE_ORDEN DE, PRODUCTOS PR',
'WHERE DE.ID_PRODUCTO = PR.ID_PRODUCTO',
'     AND DE.ID_ORDEN = p_id_orden',
'     ORDER BY DE.ID_ORDEN;',
'',
'  v_retorno CLOB;',
'BEGIN',
'  FOR v_orden IN cr_orden LOOP',
'    v_retorno := ''',
'    <header>',
'      <h1>ORDEN DE VENTA</h1>',
'      <address>',
unistr('        <h5> RUC: 80004571-1<br>Denominacion: SOLSGE<br>Direccion: Itaugu\00E1 Km 25 Mboiy<br>Inicio Actividad: 31/10/2023</h5>'),
'      </address>',
'      <h1>RECEPTOR</h1>',
'      <address>',
unistr('        <h5>RUC/CEDULA IDENTIDAD: '' || V_ORDEN.NRO_DOCUMENTO || ''<br>NOMBRE/RAZ\00D3N SOCIAL: '' || V_ORDEN.DATOS || ''<br>DOMICILIO: ''''</h5>'),
'      </address>',
'    </header>',
'    <table class="meta">',
'      <tr>',
'        <th><span>Factura #</span></th>',
'        <td><span>'' || V_ORDEN.ID_ORDEN || ''</span></td>',
'      </tr>',
'      <tr>',
unistr('        <th><span>Fecha Emisi\00F3n</span></th>'),
'        <td><span>'' || TO_CHAR(V_ORDEN.FECHA_ORDEN, ''dd/mm/yyyy'') || ''</span></td>',
'      </tr>',
'      <tr>',
'        <th><span>Importe Total</span></th>',
'        <td><span id="prefix">Gs.</span><span>'' || TO_CHAR(V_ORDEN.TOTAL, ''999G999G999G999G990'') || ''</span></td>',
'      </tr>',
'    </table>',
'    <article>',
'      <table class="inventory">',
'        <thead>',
'          <tr>',
'            <th><span>Cantidad</span></th>',
unistr('            <th><span>Descripci\00F3n Detallada</span></th>'),
'            <th><span>Precio Unitario</span></th>',
'          </tr>',
'        </thead>',
'        <tbody>'';',
'',
'    FOR v_detalles IN cr_detalles(V_ORDEN.ID_ORDEN) LOOP',
'      v_retorno := v_retorno || ''',
'      <tr>',
'        <td><span>'' || TO_CHAR(v_detalles.cantidad) || ''</span></td>',
'        <td><span>'' || v_detalles.NOMBRE || ''</span></td>',
'        <td><span data-prefix>Gs.</span><span>'' || v_detalles.PRECIO_UNITARIO || ''</span></td>',
'      </tr>'';',
'    END LOOP;',
'',
'    v_retorno := v_retorno || ''',
'        </tbody>',
'      </table>',
'      <table class="balance">',
'        <tr>',
'          <th><span>Total a Pagar</span></th>',
'          <td><span data-prefix>Gs.</span><span>'' || TO_CHAR(V_ORDEN.TOTAL, ''999G999G999G999G990'') || ''</span></td>',
'        </tr>',
'      </table>',
'    </article>',
'    <aside>',
'      <h1><span contenteditable>Notas Adicionales</span></h1>',
'      <div contenteditable>',
unistr('        <p>CONDICI\00D3N DE LA VENTA: <br>Atenci\00F3n: La validez de esta orden de venta es de 15 d\00EDas. Por favor, confirme su pedido antes de la fecha de vencimiento para garantizar precios y disponibilidad.</p>'),
'      </div>',
'    </aside>'';',
'  END LOOP;',
'',
'  RETURN v_retorno;',
'END;',
''))
,p_lazy_loading=>false
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
,p_created_on=>wwv_flow_imp.dz('20250509195327Z')
,p_updated_on=>wwv_flow_imp.dz('20250509200114Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12003616578524705)
,p_name=>'P6_ID_ORDEN'
,p_item_sequence=>20
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250509195327Z')
,p_updated_on=>wwv_flow_imp.dz('20250509195903Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp.component_end;
end;
/
