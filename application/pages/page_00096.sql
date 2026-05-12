prompt --application/pages/page_00096
begin
--   Manifest
--     PAGE: 00096
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
 p_id=>96
,p_name=>'Documento Factura'
,p_alias=>'DOCUMENTO-FACTURA'
,p_page_mode=>'MODAL'
,p_step_title=>'Documento Factura'
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
,p_created_on=>wwv_flow_imp.dz('20251102203018Z')
,p_last_updated_on=>wwv_flow_imp.dz('20251102203734Z')
,p_created_by=>'WILLIAN'
,p_last_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(15983253910097108)
,p_plug_name=>'New'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_location=>null
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  CURSOR cr_comprobante IS',
'    SELECT ',
'      PE.PRIMER_NOMBRE || '' '' || PE.SEGUNDO_NOMBRE || '' '' || ',
'      PE.PRIMER_APELLIDO || '' '' || PE.SEGUNDO_APELLIDO AS DATOS,',
'      PE.NRO_DOCUMENTO,',
'      C.ID_COMPROBANTE,',
'      C.FECHA,',
'      C.TOTAL_MONEDA_LOCAL AS TOTAL,',
'      C.OBSERVACION,',
'      C.NRO_COMPROBANTE,',
'      C.FORMA_PAGO,',
'      C.MONEDA',
'    FROM COMPROBANTES C',
'    JOIN CLIENTES CL ON CL.ID_PERSONA = C.ID_CLIENTE',
'    JOIN PERSONAS PE ON PE.ID_PERSONA = CL.ID_PERSONA',
unistr('   WHERE C.ID_COMPROBANTE = :P96_ID_COMPROBANTE;  -- << par\00E1metro de entrada'),
'',
'  CURSOR cr_detalles (p_id_comprobante NUMBER) IS',
'    SELECT ',
'      PR.NOMBRE AS PRODUCTO,',
'      DC.CANTIDAD,',
'      DC.PRECIO_UNITARIO,',
'      DC.TOTAL_LINEA,',
'      DC.PORCENTAJE_IVA',
'    FROM DETALLE_COMPROBANTE DC',
'    JOIN PRODUCTOS PR ON PR.ID_PRODUCTO = DC.ID_PRODUCTO',
'   WHERE DC.ID_COMPROBANTE = p_id_comprobante',
'   ORDER BY DC.ID_DETALLE;',
'',
'  v_retorno CLOB;',
'BEGIN',
'  FOR v_comp IN cr_comprobante LOOP',
'    v_retorno := ''',
'    <header>',
'      <h1>COMPROBANTE DE VENTA</h1>',
'      <address>',
'        <h5>RUC: 80004571-1<br>',
unistr('        Denominaci\00F3n: SOLSGE<br>'),
unistr('        Direcci\00F3n: Itaugu\00E1 Km 25 Mboiy<br>'),
'        Inicio Actividad: 31/10/2023</h5>',
'      </address>',
'      <h1>CLIENTE</h1>',
'      <address>',
'        <h5>',
'          RUC/C.I.: '' || v_comp.NRO_DOCUMENTO || ''<br>',
unistr('          Nombre/Raz\00F3n Social: '' || v_comp.DATOS || ''<br>'),
'          Moneda: '' || v_comp.MONEDA || ''',
'        </h5>',
'      </address>',
'    </header>',
'',
'    <table class="meta">',
'      <tr>',
'        <th><span>Nro. Comprobante</span></th>',
'        <td><span>'' || v_comp.NRO_COMPROBANTE || ''</span></td>',
'      </tr>',
'      <tr>',
unistr('        <th><span>Fecha Emisi\00F3n</span></th>'),
'        <td><span>'' || TO_CHAR(v_comp.FECHA, ''dd/mm/yyyy'') || ''</span></td>',
'      </tr>',
'      <tr>',
'        <th><span>Forma de Pago</span></th>',
'        <td><span>'' || NVL(v_comp.FORMA_PAGO, ''Contado'') || ''</span></td>',
'      </tr>',
'      <tr>',
'        <th><span>Total</span></th>',
'        <td><span id="prefix">Gs.</span><span>'' || TO_CHAR(v_comp.TOTAL, ''999G999G999G999G990'') || ''</span></td>',
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
'            <th><span>IVA (%)</span></th>',
'          </tr>',
'        </thead>',
'        <tbody>'';',
'',
'    FOR v_det IN cr_detalles(v_comp.ID_COMPROBANTE) LOOP',
'      v_retorno := v_retorno || ''',
'      <tr>',
'        <td><span>'' || TO_CHAR(v_det.CANTIDAD) || ''</span></td>',
'        <td><span>'' || v_det.PRODUCTO || ''</span></td>',
'        <td><span data-prefix>Gs.</span><span>'' || TO_CHAR(v_det.PRECIO_UNITARIO, ''999G999G990D00'') || ''</span></td>',
'        <td><span data-prefix>Gs.</span><span>'' || TO_CHAR(v_det.TOTAL_LINEA, ''999G999G990D00'') || ''</span></td>',
'        <td><span>'' || TO_CHAR(v_det.PORCENTAJE_IVA) || ''%</span></td>',
'      </tr>'';',
'    END LOOP;',
'',
'    v_retorno := v_retorno || ''',
'        </tbody>',
'      </table>',
'',
'      <table class="balance">',
'        <tr>',
'          <th><span>Total a Pagar</span></th>',
'          <td><span data-prefix>Gs.</span><span>'' || TO_CHAR(v_comp.TOTAL, ''999G999G999G999G990'') || ''</span></td>',
'        </tr>',
'      </table>',
'    </article>',
'',
'    <aside>',
'      <h1><span contenteditable>Notas Adicionales</span></h1>',
'      <div contenteditable>',
'        <p>'' || NVL(v_comp.OBSERVACION, ''Sin observaciones'') || ''</p>',
'      </div>',
'    </aside>'';',
'  END LOOP;',
'',
'  RETURN v_retorno;',
'END;',
''))
,p_lazy_loading=>false
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
,p_created_on=>wwv_flow_imp.dz('20251102203625Z')
,p_updated_on=>wwv_flow_imp.dz('20251102203734Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(15983368763097109)
,p_name=>'P96_ID_COMPROBANTE'
,p_item_sequence=>20
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20251102203625Z')
,p_updated_on=>wwv_flow_imp.dz('20251102203625Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp.component_end;
end;
/
