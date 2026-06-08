-- ============================================================================
-- F10 - PREFLIGHT (solo SELECT, no modifica nada)
-- ============================================================================
-- Inspeccion previa al script principal F10_talonarios_set.sql.
-- El operador corre este script, revisa los resultados y decide:
--   a) Migracion automatica   -> ninguna oficina tiene >1 CAJA_CONF.
--   b) Mapeo manual requerido -> alguna oficina tiene >1 CAJA_CONF y
--      hay talonarios compartidos. Crear TMP_MAP_TALONARIO_CAJA antes de F10.
--   c) Guard historico        -> hay talonarios con NRO_ACTUAL > NRO_INICIAL
--      que cambiarian de CAJA_CONF respecto a la inferencia automatica;
--      al invocar F10 hay que DEFINE bypass='SI' para autorizar.
--
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion: @db/F10_preflight.sql
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;
SET SERVEROUTPUT ON SIZE UNLIMITED

prompt ==============================================================================
prompt F10.PRE.1  Cantidad de CAJA_CONF por oficina
prompt ------------------------------------------------------------------------------
prompt Si 'cant_cajas' > 1 en alguna oficina, la migracion NO puede inferir
prompt automaticamente la asignacion talonario->caja para los talonarios de esa
prompt oficina. Crear TMP_MAP_TALONARIO_CAJA con el mapeo manual antes de F10.
prompt ==============================================================================
SELECT o.CODIGO_OFICINA                       AS id_oficina,
       o.DESCRIPCION                          AS oficina,
       COUNT(cc.ID_CAJA_CONF)                 AS cant_cajas
FROM   OFICINAS o
LEFT   JOIN CAJA_CONF cc ON cc.ID_OFICINA = o.CODIGO_OFICINA
GROUP  BY o.CODIGO_OFICINA, o.DESCRIPCION
ORDER  BY cant_cajas DESC, o.CODIGO_OFICINA;

prompt ==============================================================================
prompt F10.PRE.2  Talonarios actuales por oficina y tipo
prompt ------------------------------------------------------------------------------
prompt Listado completo de talonarios. Revisar columna NRO_ACTUAL vs NRO_INICIAL:
prompt si NRO_ACTUAL > NRO_INICIAL, ese talonario ya emitio comprobantes -> guard
prompt historico aplica en caso de reasignacion.
prompt ==============================================================================
SELECT t.ID_TALONARIO,
       t.ID_OFICINA,
       o.DESCRIPCION              AS oficina,
       t.TIPO_COMPROBANTE,
       t.ESTABLECIMIENTO,
       t.PUNTO_EXPEDICION,
       t.TIMBRADO,
       t.NRO_INICIAL,
       t.NRO_ACTUAL,
       t.NRO_FINAL,
       t.ACTIVO,
       CASE WHEN t.NRO_ACTUAL > t.NRO_INICIAL THEN 'SI' ELSE 'NO' END
                                  AS tiene_historico
FROM   TALONARIOS t
JOIN   OFICINAS o ON o.CODIGO_OFICINA = t.ID_OFICINA
ORDER  BY t.ID_OFICINA, t.TIPO_COMPROBANTE, t.ID_TALONARIO;

prompt ==============================================================================
prompt F10.PRE.3  Comprobantes emitidos por talonario
prompt ------------------------------------------------------------------------------
prompt Cantidad real de comprobantes en COMPROBANTES referenciando cada talonario.
prompt Si 'emitidos' > 0, el talonario tiene historico fiscal declarado.
prompt ==============================================================================
SELECT t.ID_TALONARIO,
       t.TIPO_COMPROBANTE,
       t.ESTABLECIMIENTO,
       t.PUNTO_EXPEDICION,
       COUNT(c.ID_COMPROBANTE)    AS emitidos
FROM   TALONARIOS t
LEFT   JOIN COMPROBANTES c ON c.ID_TALONARIO = t.ID_TALONARIO
GROUP  BY t.ID_TALONARIO, t.TIPO_COMPROBANTE, t.ESTABLECIMIENTO, t.PUNTO_EXPEDICION
ORDER  BY t.ID_TALONARIO;

prompt ==============================================================================
prompt F10.PRE.4  Mapeo CAJA_CONF -> OFICINA
prompt ------------------------------------------------------------------------------
prompt Catalogo de cajas fisicas. Sirve como referencia para llenar
prompt TMP_MAP_TALONARIO_CAJA en caso de mapeo manual.
prompt ==============================================================================
SELECT cc.ID_CAJA_CONF,
       cc.ID_OFICINA,
       o.DESCRIPCION              AS oficina,
       cc.DESCRIPCION             AS caja_conf,
       cc.ESTADO
FROM   CAJA_CONF cc
LEFT JOIN OFICINAS o ON o.CODIGO_OFICINA = cc.ID_OFICINA
ORDER  BY cc.ID_OFICINA NULLS LAST, cc.ID_CAJA_CONF;

prompt ==============================================================================
prompt F10.PRE.5  Veredicto
prompt ==============================================================================
DECLARE
  v_oficinas_multi NUMBER;
  v_talonarios_con_historico NUMBER;
BEGIN
  SELECT COUNT(*)
    INTO v_oficinas_multi
    FROM (SELECT o.CODIGO_OFICINA
            FROM OFICINAS o
            JOIN CAJA_CONF cc ON cc.ID_OFICINA = o.CODIGO_OFICINA
           GROUP BY o.CODIGO_OFICINA
          HAVING COUNT(*) > 1);

  SELECT COUNT(*)
    INTO v_talonarios_con_historico
    FROM TALONARIOS
   WHERE NRO_ACTUAL > NRO_INICIAL;

  DBMS_OUTPUT.PUT_LINE('Oficinas con >1 CAJA_CONF:        '||v_oficinas_multi);
  DBMS_OUTPUT.PUT_LINE('Talonarios con historico emitido: '||v_talonarios_con_historico);
  DBMS_OUTPUT.PUT_LINE('---');
  IF v_oficinas_multi = 0 THEN
    DBMS_OUTPUT.PUT_LINE('==> Migracion AUTOMATICA viable. Correr @db/F10_talonarios_set.sql');
  ELSE
    DBMS_OUTPUT.PUT_LINE('==> Crear TMP_MAP_TALONARIO_CAJA(ID_TALONARIO,ID_CAJA_CONF) con');
    DBMS_OUTPUT.PUT_LINE('    el mapeo manual para los talonarios de oficinas con >1 caja.');
  END IF;
  IF v_talonarios_con_historico > 0 THEN
    DBMS_OUTPUT.PUT_LINE('==> Si la reasignacion afecta a talonarios con historico emitido,');
    DBMS_OUTPUT.PUT_LINE('    invocar F10 con  DEFINE bypass=''SI''  para confirmar.');
  END IF;
END;
/
