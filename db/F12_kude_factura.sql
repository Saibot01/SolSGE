-- ============================================================================
-- F12 - P96 como Representacion Grafica KuDE (lineamientos SIFEN)
-- ============================================================================
-- Backend de la remaquetacion de P96 (Documento Factura) al layout KuDE de la
-- SET (Paraguay). NO integra SIFEN: no genera CDC ni QR (solo representacion
-- grafica). Ver plan: P96 como Representacion Grafica KuDE.
--
-- Contenido:
--   1. Parametros del emisor faltantes en PARAMETROS (TIPO_PARAMETRO='EMPRESA'):
--      TELEFONO, CIUDAD, ACTIVIDAD_ECONOMICA, TIPO_CONTRIBUYENTE.
--      Se leen con FN_GET_PARAMETRO(<clave>,'TEXTO'), igual que RUC/RAZON_SOCIAL.
--   2. FN_NUMERO_A_LETRAS: total en letras para el "Total a Pagar" del KuDE.
--
-- Idempotente: re-correrlo es no-op (MERGE + CREATE OR REPLACE).
--
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion: sql -S -name tesis_db @db/F12_kude_factura.sql
-- ============================================================================
set define off
set serveroutput on

prompt == F12.1 Parametros de emisor faltantes (TIPO_PARAMETRO=EMPRESA) ==
-- Valores placeholder: el admin los edita luego desde el mantenedor de
-- PARAMETROS. P96 los lee dinamicamente, sin re-deploy.
DECLARE
  PROCEDURE upsert_param(p_clave VARCHAR2, p_valor VARCHAR2, p_desc VARCHAR2) IS
  BEGIN
    MERGE INTO WKSP_WORKPLACE.PARAMETROS p
    USING (SELECT 'EMPRESA' AS tipo, p_clave AS clave FROM dual) src
       ON (p.TIPO_PARAMETRO = src.tipo AND p.CLAVE = src.clave)
    WHEN MATCHED THEN
      UPDATE SET p.DESCRIPCION = p_desc,
                 p.FECHA_MODIFICACION = SYSDATE,
                 p.USUARIO_MODIFICACION = 'F12_kude_factura.sql'
                 -- NO se pisa VALOR_TEXTO si ya existe (respeta ediciones del admin)
    WHEN NOT MATCHED THEN
      INSERT (TIPO_PARAMETRO, CLAVE, VALOR_TEXTO, DESCRIPCION, ACTIVO, FECHA_CREACION, USUARIO_CREACION)
      VALUES ('EMPRESA', p_clave, p_valor, p_desc, 'S', SYSDATE, 'F12_kude_factura.sql');
  END;
BEGIN
  upsert_param('TELEFONO',            '(0294) 220 100',                 'Telefono del emisor (cabecera KuDE)');
  upsert_param('CIUDAD',              unistr('Itaugu\00E1'),            'Ciudad del emisor (cabecera KuDE)');
  upsert_param('ACTIVIDAD_ECONOMICA', unistr('Comercio al por menor'), unistr('Actividad econ\00F3mica del emisor (KuDE)'));
  upsert_param('TIPO_CONTRIBUYENTE',  unistr('Persona Jur\00EDdica'),  'Tipo de contribuyente del emisor (KuDE)');
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('  + Parametros EMPRESA cargados/actualizados (TELEFONO, CIUDAD, ACTIVIDAD_ECONOMICA, TIPO_CONTRIBUYENTE)');
END;
/

prompt == F12.2 FN_NUMERO_A_LETRAS ==
-- Convierte un monto entero a texto en espanol (hasta cientos de miles de
-- millones). Guarani no usa centavos: se trunca a entero. Devuelve
-- "<MONEDA> <texto>.-", ej: FN_NUMERO_A_LETRAS(17850) =>
-- 'GUARANIES DIECISIETE MIL OCHOCIENTOS CINCUENTA.-'
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_NUMERO_A_LETRAS (
  p_monto  IN NUMBER,
  p_moneda IN VARCHAR2 DEFAULT unistr('GUARAN\00CDES')
) RETURN VARCHAR2 IS
  v_n     PLS_INTEGER;
  v_mill  PLS_INTEGER;
  v_resto PLS_INTEGER;
  v_txt   VARCHAR2(4000);

  -- 0..999 en palabras
  FUNCTION centenas(c IN PLS_INTEGER) RETURN VARCHAR2 IS
    TYPE t_arr IS TABLE OF VARCHAR2(20);
    unidades t_arr := t_arr('','UNO','DOS','TRES','CUATRO','CINCO','SEIS','SIETE','OCHO','NUEVE',
       'DIEZ','ONCE','DOCE','TRECE','CATORCE','QUINCE','DIECISEIS','DIECISIETE','DIECIOCHO','DIECINUEVE',
       'VEINTE','VEINTIUNO','VEINTIDOS','VEINTITRES','VEINTICUATRO','VEINTICINCO','VEINTISEIS',
       'VEINTISIETE','VEINTIOCHO','VEINTINUEVE');
    decenas  t_arr := t_arr('','','','TREINTA','CUARENTA','CINCUENTA','SESENTA','SETENTA','OCHENTA','NOVENTA');
    centena  t_arr := t_arr('','CIENTO','DOSCIENTOS','TRESCIENTOS','CUATROCIENTOS','QUINIENTOS',
       'SEISCIENTOS','SETECIENTOS','OCHOCIENTOS','NOVECIENTOS');
    v   VARCHAR2(400) := '';
    cen PLS_INTEGER;
    m2  PLS_INTEGER;
  BEGIN
    IF c = 0   THEN RETURN ''; END IF;
    IF c = 100 THEN RETURN 'CIEN'; END IF;
    cen := TRUNC(c/100);
    m2  := MOD(c,100);
    IF cen > 0 THEN v := centena(cen+1); END IF;
    IF m2 > 0 THEN
      IF LENGTH(v) > 0 THEN v := v || ' '; END IF;
      IF m2 <= 29 THEN
        v := v || unidades(m2+1);
      ELSE
        v := v || decenas(TRUNC(m2/10)+1);
        IF MOD(m2,10) > 0 THEN
          v := v || ' Y ' || unidades(MOD(m2,10)+1);
        END IF;
      END IF;
    END IF;
    RETURN v;
  END centenas;

  -- Apocope de "UNO" -> "UN" antes de MIL / MILLONES
  FUNCTION apoc(s IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF s LIKE '%UNO' THEN
      RETURN SUBSTR(s, 1, LENGTH(s)-1);
    END IF;
    RETURN s;
  END apoc;

  -- 0..999999 en palabras (grupo de miles)
  FUNCTION miles(m IN PLS_INTEGER) RETURN VARCHAR2 IS
    th   PLS_INTEGER := TRUNC(m/1000);
    rest PLS_INTEGER := MOD(m,1000);
    v    VARCHAR2(2000) := '';
  BEGIN
    IF th > 0 THEN
      IF th = 1 THEN
        v := 'MIL';
      ELSE
        v := apoc(centenas(th)) || ' MIL';
      END IF;
    END IF;
    IF rest > 0 THEN
      IF LENGTH(v) > 0 THEN v := v || ' '; END IF;
      v := v || centenas(rest);
    END IF;
    RETURN v;
  END miles;

BEGIN
  v_n := TRUNC(NVL(p_monto, 0));
  IF v_n < 0 THEN v_n := -v_n; END IF;

  IF v_n = 0 THEN
    v_txt := 'CERO';
  ELSE
    v_mill  := TRUNC(v_n/1000000);
    v_resto := MOD(v_n,1000000);
    v_txt   := '';
    IF v_mill > 0 THEN
      IF v_mill = 1 THEN
        v_txt := 'UN MILLON';
      ELSE
        v_txt := apoc(miles(v_mill)) || ' MILLONES';
      END IF;
    END IF;
    IF v_resto > 0 THEN
      IF LENGTH(v_txt) > 0 THEN v_txt := v_txt || ' '; END IF;
      v_txt := v_txt || miles(v_resto);
    END IF;
  END IF;

  RETURN TRIM(p_moneda || ' ' || v_txt) || '.-';
END FN_NUMERO_A_LETRAS;
/

prompt == F12.3 FN_KUDE_FACTURA_HTML ==
-- Arma el HTML del KuDE (Representacion Grafica) de una factura. P96 lo invoca
-- con RETURN FN_KUDE_FACTURA_HTML(:P96_ID_COMPROBANTE). Se mantiene la logica
-- aqui (no inline en la pagina) para evitar el doble-escape de acentos en el
-- export APEX y para poder testearla con SELECT ... FROM DUAL.
--
-- Datos de emisor: PARAMETROS (TIPO_PARAMETRO='EMPRESA') via FN_GET_PARAMETRO.
-- Subtotales por tasa: se calculan desde DETALLE_COMPROBANTE.PORCENTAJE_IVA
--   (COMPROBANTES.TOTAL_GRAVADA_* esta NULL en los datos reales).
-- Acentos: se usan entidades HTML (&oacute; etc) para mantener el fuente ASCII.
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_KUDE_FACTURA_HTML (
  p_id_comprobante IN NUMBER
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
           C.ID_COMPROBANTE, C.FECHA, C.TOTAL_MONEDA_LOCAL AS TOTAL, C.NRO_COMPROBANTE, C.FORMA_PAGO,
           NVL(MO.DESCRIPCION, C.MONEDA) AS MONEDA, MO.ES_LOCAL,
           NVL(C.TOTAL_IVA_5,0) AS IVA5, NVL(C.TOTAL_IVA_10,0) AS IVA10, NVL(C.TOTAL_IVA,0) AS IVATOT,
           T.TIMBRADO, T.FECHA_INICIO AS TIMB_INI
      FROM WKSP_WORKPLACE.COMPROBANTES C
      JOIN WKSP_WORKPLACE.CLIENTES  CL ON CL.ID_PERSONA   = C.ID_CLIENTE
      JOIN WKSP_WORKPLACE.PERSONAS  PE ON PE.ID_PERSONA   = CL.ID_PERSONA
      LEFT JOIN WKSP_WORKPLACE.TALONARIOS T ON T.ID_TALONARIO = C.ID_TALONARIO
      LEFT JOIN WKSP_WORKPLACE.MONEDAS    MO ON (MO.CODIGO_MONEDA = C.MONEDA OR MO.DESCRIPCION = C.MONEDA)
     WHERE C.ID_COMPROBANTE = p_id_comprobante;

  CURSOR cd (p_id NUMBER) IS
    SELECT PR.NOMBRE AS PRODUCTO, DC.CANTIDAD, DC.PRECIO_UNITARIO, DC.TOTAL_LINEA,
           NVL(DC.PORCENTAJE_IVA,0) AS PIVA
      FROM WKSP_WORKPLACE.DETALLE_COMPROBANTE DC
      JOIN WKSP_WORKPLACE.PRODUCTOS PR ON PR.ID_PRODUCTO = DC.ID_PRODUCTO
     WHERE DC.ID_COMPROBANTE = p_id
     ORDER BY DC.ID_DETALLE;

  v_html    CLOB;
  v_sub_ex  NUMBER; v_sub_5 NUMBER; v_sub_10 NUMBER;
  v_cond    VARCHAR2(30);
  v_tel_cli VARCHAR2(100); v_dir_cli VARCHAR2(300);
  v_ce      VARCHAR2(40); v_c5 VARCHAR2(40); v_c10 VARCHAR2(40);

  -- Formato guarani: separador de miles "." y sin decimales.
  FUNCTION fmt(n NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TRANSLATE(TO_CHAR(NVL(n,0),'FM999G999G999G990'), ',', '.');
  END;
BEGIN
  FOR v IN cr LOOP
    v_sub_ex := 0; v_sub_5 := 0; v_sub_10 := 0;
    v_cond := CASE WHEN v.FORMA_PAGO = '1' THEN 'Cr&eacute;dito' ELSE 'Contado' END;

    BEGIN
      SELECT NRO_TELEFONO INTO v_tel_cli
        FROM WKSP_WORKPLACE.TELEFONOS WHERE ID_PERSONA = v.ID_PERSONA AND ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_tel_cli := NULL; END;
    BEGIN
      SELECT TRIM(CALLE_PRINCIPAL||' '||NRO_CASA) INTO v_dir_cli
        FROM WKSP_WORKPLACE.DIRECCIONES WHERE ID_PERSONA = v.ID_PERSONA AND ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_dir_cli := NULL; END;

    v_html := '<div class="kude"><div class="ktit">KuDE de Factura Electr&oacute;nica</div>';
    v_html := v_html || '<table class="khead"><tr><td class="kemis"><b>'||v_razon||'</b><br>'
                     || v_dir||'<br>'||v_ciudad||'<br>Tel.: '||v_tel||'<br>Act. Econ.: '||v_act||'</td>';
    v_html := v_html || '<td class="r"><b>RUC:</b> '||v_ruc
                     || '<br><b>Timbrado N&deg;:</b> '||NVL(v.TIMBRADO,'-')
                     || '<br><b>Inicio de Vigencia:</b> '||NVL(TO_CHAR(v.TIMB_INI,'dd/mm/yyyy'),'-')
                     || '<br><b>Factura Electr&oacute;nica</b><br><b>N&deg; '||NVL(v.NRO_COMPROBANTE,'-')||'</b></td></tr></table>';

    v_html := v_html || '<div class="kbox"><table class="krec">';
    v_html := v_html || '<tr><td><span class="klabel">Nombre o Raz&oacute;n Social</span><br>'||v.CLIENTE
                     || '</td><td><span class="klabel">RUC / CI</span><br>'||NVL(v.NRO_DOCUMENTO,'-')
                     || '</td><td><span class="klabel">Tel&eacute;fono</span><br>'||NVL(v_tel_cli,'-')||'</td></tr>';
    v_html := v_html || '<tr><td><span class="klabel">Direcci&oacute;n</span><br>'||NVL(v_dir_cli,'-')
                     || '</td><td><span class="klabel">Correo Electr&oacute;nico</span><br>'||NVL(v.CORREO,'-')
                     || '</td><td><span class="klabel">Moneda</span><br>'||NVL(v.MONEDA,'-')||'</td></tr>';
    v_html := v_html || '<tr><td><span class="klabel">Fecha de Emisi&oacute;n</span><br>'||NVL(TO_CHAR(v.FECHA,'dd/mm/yyyy'),'-')
                     || '</td><td><span class="klabel">Condici&oacute;n de Venta</span><br>'||v_cond
                     || '</td><td></td></tr></table></div>';

    v_html := v_html || '<table class="kitems"><thead><tr><th>Cant.</th><th>Descripci&oacute;n</th>'
                     || '<th>Precio Unitario</th><th>Desc.</th><th>Exentas</th><th>IVA 5%</th><th>IVA 10%</th></tr></thead><tbody>';

    FOR d IN cd(v.ID_COMPROBANTE) LOOP
      v_ce := ''; v_c5 := ''; v_c10 := '';
      IF d.PIVA = 5 THEN
        v_sub_5 := v_sub_5 + d.TOTAL_LINEA; v_c5 := fmt(d.TOTAL_LINEA);
      ELSIF d.PIVA = 10 THEN
        v_sub_10 := v_sub_10 + d.TOTAL_LINEA; v_c10 := fmt(d.TOTAL_LINEA);
      ELSE
        v_sub_ex := v_sub_ex + d.TOTAL_LINEA; v_ce := fmt(d.TOTAL_LINEA);
      END IF;
      v_html := v_html || '<tr><td class="c">'||TO_CHAR(d.CANTIDAD)||'</td><td>'||d.PRODUCTO
                       || '</td><td class="r">'||fmt(d.PRECIO_UNITARIO)||'</td><td class="r">0</td>'
                       || '<td class="r">'||v_ce||'</td><td class="r">'||v_c5||'</td><td class="r">'||v_c10||'</td></tr>';
    END LOOP;

    v_html := v_html || '<tr class="ksub"><td colspan="4" class="r"><b>Subtotales</b></td><td class="r">'||fmt(v_sub_ex)
                     || '</td><td class="r">'||fmt(v_sub_5)||'</td><td class="r">'||fmt(v_sub_10)||'</td></tr></tbody></table>';

    v_html := v_html || '<table class="ktot"><tr><td><b>Total a Pagar:</b> '
                     || CASE WHEN v.ES_LOCAL = 'S' THEN WKSP_WORKPLACE.FN_NUMERO_A_LETRAS(v.TOTAL)
                             ELSE WKSP_WORKPLACE.FN_NUMERO_A_LETRAS(v.TOTAL, v.MONEDA) END
                     || '</td><td class="r"><b>'||fmt(v.TOTAL)||'</b></td></tr>';
    v_html := v_html || '<tr><td>Liquidaci&oacute;n del IVA: (5%) '||fmt(v.IVA5)||' &nbsp; (10%) '||fmt(v.IVA10)
                     || '</td><td class="r"><b>Total IVA: '||fmt(v.IVATOT)||'</b></td></tr></table>';

    v_html := v_html || '<div class="kleg">ESTE DOCUMENTO ES UNA REPRESENTACI&Oacute;N GR&Aacute;FICA DE UN DOCUMENTO ELECTR&Oacute;NICO<br>'
                     || 'Si su documento electr&oacute;nico presenta alg&uacute;n error, podr&aacute; solicitar la modificaci&oacute;n dentro '
                     || 'de las 72 horas siguientes de la emisi&oacute;n de este comprobante.<br>'
                     || '<i>Representaci&oacute;n de demostraci&oacute;n &mdash; sin validez fiscal.</i></div></div>';
  END LOOP;

  IF v_html IS NULL THEN
    v_html := '<h2>Factura no encontrada.</h2><p>Verifique que el ID indicado corresponda a una factura v&aacute;lida.</p>';
  END IF;
  RETURN v_html;
END FN_KUDE_FACTURA_HTML;
/

prompt == F12.4 Verificacion final ==
DECLARE
  v_ok  BOOLEAN := TRUE;
  v_cnt PLS_INTEGER;
  v_res VARCHAR2(4000);

  PROCEDURE chk(p_cond BOOLEAN, p_msg VARCHAR2) IS
  BEGIN
    IF p_cond THEN
      DBMS_OUTPUT.PUT_LINE('  OK   ' || p_msg);
    ELSE
      DBMS_OUTPUT.PUT_LINE('  FAIL ' || p_msg);
      v_ok := FALSE;
    END IF;
  END;
BEGIN
  -- Parametros EMPRESA (los 3 previos + los 4 nuevos = 7)
  SELECT COUNT(*) INTO v_cnt
    FROM WKSP_WORKPLACE.PARAMETROS
   WHERE TIPO_PARAMETRO='EMPRESA'
     AND CLAVE IN ('RUC','RAZON_SOCIAL','DIRECCION','TELEFONO','CIUDAD','ACTIVIDAD_ECONOMICA','TIPO_CONTRIBUYENTE')
     AND ACTIVO='S';
  chk(v_cnt = 7, 'parametros EMPRESA (esperado 7, encontrado '||v_cnt||')');

  -- Funciones validas
  SELECT COUNT(*) INTO v_cnt
    FROM all_objects
   WHERE owner='WKSP_WORKPLACE' AND object_name='FN_NUMERO_A_LETRAS'
     AND object_type='FUNCTION' AND status='VALID';
  chk(v_cnt = 1, 'FUNCTION FN_NUMERO_A_LETRAS VALID');

  SELECT COUNT(*) INTO v_cnt
    FROM all_objects
   WHERE owner='WKSP_WORKPLACE' AND object_name='FN_KUDE_FACTURA_HTML'
     AND object_type='FUNCTION' AND status='VALID';
  chk(v_cnt = 1, 'FUNCTION FN_KUDE_FACTURA_HTML VALID');

  -- Smoke test del HTML sobre una factura real (si existe alguna)
  DECLARE
    v_id   NUMBER;
    v_clob CLOB;
  BEGIN
    SELECT MAX(ID_COMPROBANTE) INTO v_id
      FROM WKSP_WORKPLACE.COMPROBANTES
     WHERE TIPO_COMPROBANTE='FA' AND ESTADO='A' AND NRO_COMPROBANTE IS NOT NULL;
    IF v_id IS NOT NULL THEN
      v_clob := WKSP_WORKPLACE.FN_KUDE_FACTURA_HTML(v_id);
      chk(DBMS_LOB.GETLENGTH(v_clob) > 0 AND v_clob LIKE '%KuDE de Factura%',
          'FN_KUDE_FACTURA_HTML(ID='||v_id||') genera HTML ('||DBMS_LOB.GETLENGTH(v_clob)||' chars)');
    ELSE
      DBMS_OUTPUT.PUT_LINE('  -    sin facturas FA emitidas: smoke test omitido');
    END IF;
  END;

  -- Casos de prueba
  v_res := WKSP_WORKPLACE.FN_NUMERO_A_LETRAS(17850);
  DBMS_OUTPUT.PUT_LINE('  FN_NUMERO_A_LETRAS(17850) = ' || v_res);
  chk(v_res LIKE '%DIECISIETE MIL OCHOCIENTOS CINCUENTA.-', '17850 -> DIECISIETE MIL OCHOCIENTOS CINCUENTA');

  DBMS_OUTPUT.PUT_LINE('  FN_NUMERO_A_LETRAS(0)         = ' || WKSP_WORKPLACE.FN_NUMERO_A_LETRAS(0));
  DBMS_OUTPUT.PUT_LINE('  FN_NUMERO_A_LETRAS(100)       = ' || WKSP_WORKPLACE.FN_NUMERO_A_LETRAS(100));
  DBMS_OUTPUT.PUT_LINE('  FN_NUMERO_A_LETRAS(1000000)   = ' || WKSP_WORKPLACE.FN_NUMERO_A_LETRAS(1000000));
  DBMS_OUTPUT.PUT_LINE('  FN_NUMERO_A_LETRAS(2220000)   = ' || WKSP_WORKPLACE.FN_NUMERO_A_LETRAS(2220000));
  DBMS_OUTPUT.PUT_LINE('  FN_NUMERO_A_LETRAS(1234567)   = ' || WKSP_WORKPLACE.FN_NUMERO_A_LETRAS(1234567));

  IF v_ok THEN
    DBMS_OUTPUT.PUT_LINE('== F12 OK ==');
  ELSE
    DBMS_OUTPUT.PUT_LINE('== F12 CON ERRORES ==');
  END IF;
END;
/

set define on
