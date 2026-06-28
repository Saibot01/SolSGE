-- ============================================================================
-- F18 - Habilitador de la dimension "Vendedor" (Reportes Gerenciales / Ventas)
-- ============================================================================
-- Primer paso de los Reportes Gerenciales (arrancamos por el Dashboard de
-- Ventas). Habilita medir "ventas por vendedor vs. meta", que hoy es imposible
-- porque ORDENES_VENTA no registra QUIEN creo el presupuesto.
--
-- Definicion del PO (2026-06-26): el vendedor = el usuario que carga el
-- presupuesto (ORDENES_VENTA), que se propaga a la factura via
-- COMPROBANTES.ID_ORDEN_VENTA.
--
-- Este script hace SOLO el backend de datos (cero cambios en apex-work/):
--   1. ORDENES_VENTA.USUARIO_CREACION (VARCHAR2(60), nullable) - guarda el
--      :APP_USER en mayusculas, mismo formato que USUARIO_APROBACION
--      (valores reales: 'TCASCO', 'CBARRIOS', ...). Join a la dimension empleado
--      por EMPLEADOS.CODIGO_USUARIO.
--   2. TRG_OV_USUARIO_CREACION (BEFORE INSERT EACH ROW): estampa
--      USUARIO_CREACION := NVL(:NEW.USUARIO_CREACION, NVL(V('APP_USER'), USER)).
--      Aprobado por el PO (2026-06-26) por trigger en vez de un proceso en P54:
--      captura TODO camino de insert, NO toca la pagina APEX (sin riesgo de
--      re-export) y sigue el patron de TRG_OV_FECHA_VENCIMIENTO ya existente.
--   3. METAS_VENTA: meta de venta por vendedor O por sucursal, por mes
--      (real vs. meta). PERIODO es DATE truncado al 1ro del mes para joinear
--      directo contra TRUNC(COMPROBANTES.FECHA,'MM') sin parsear.
--      + TRG_METAS_VENTA_BI (BEFORE INSERT/UPDATE): trunca PERIODO a 'MM' y
--      valida que venga exactamente uno de (ID_EMPLEADO, ID_OFICINA).
--
-- LIMITACION CONOCIDA: backfill IMPOSIBLE. Las 35 ordenes / 21 facturas
-- historicas quedan con USUARIO_CREACION NULL (no se registro quien las creo);
-- el vendedor solo existira en presupuestos NUEVOS. Los reportes deben tratar
-- el vendedor NULL como "(sin asignar)".
--
-- Rango de error reservado: -20991 .. -20999.
-- Idempotente: re-correrlo es no-op.
-- Pre-requisitos: ORDENES_VENTA, EMPLEADOS, OFICINAS existentes.
--
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion (esta maquina): sql -S -name tesis_db < db/F18_habilitador_vendedor.sql
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;

set serveroutput on size unlimited
set define off
whenever sqlerror exit sql.sqlcode rollback

prompt == F18.0 Pre-check (tablas base) ==
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_tables
   WHERE owner='WKSP_WORKPLACE' AND table_name='ORDENES_VENTA';
  IF v_cnt = 0 THEN RAISE_APPLICATION_ERROR(-20991,'Falta ORDENES_VENTA.'); END IF;

  SELECT COUNT(*) INTO v_cnt FROM all_tables
   WHERE owner='WKSP_WORKPLACE' AND table_name='EMPLEADOS';
  IF v_cnt = 0 THEN RAISE_APPLICATION_ERROR(-20991,'Falta EMPLEADOS.'); END IF;

  SELECT COUNT(*) INTO v_cnt FROM all_tables
   WHERE owner='WKSP_WORKPLACE' AND table_name='OFICINAS';
  IF v_cnt = 0 THEN RAISE_APPLICATION_ERROR(-20991,'Falta OFICINAS.'); END IF;

  DBMS_OUTPUT.PUT_LINE('  = Pre-check OK');
END;
/

prompt == F18.1 Columna ORDENES_VENTA.USUARIO_CREACION ==
-- Vendedor = quien carga el presupuesto. Nullable: las ordenes historicas
-- quedan NULL (backfill imposible). Mismo tipo que USUARIO_APROBACION.
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_tab_columns
   WHERE owner='WKSP_WORKPLACE' AND table_name='ORDENES_VENTA'
     AND column_name='USUARIO_CREACION';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE
      'ALTER TABLE WKSP_WORKPLACE.ORDENES_VENTA ADD (USUARIO_CREACION VARCHAR2(60))';
    DBMS_OUTPUT.PUT_LINE('  + USUARIO_CREACION agregada');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  = USUARIO_CREACION ya existe');
  END IF;
END;
/

prompt == F18.2 TRG_OV_USUARIO_CREACION (estampa el vendedor al crear) ==
-- BEFORE INSERT: si no vino seteado, estampa el usuario de sesion APEX
-- (:APP_USER). Fuera de APEX (script/job) cae a USER. El NVL deja setearlo
-- explicito si algun proceso lo necesita. No toca la pagina P54.
CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_OV_USUARIO_CREACION
BEFORE INSERT ON WKSP_WORKPLACE.ORDENES_VENTA
FOR EACH ROW
BEGIN
  :NEW.USUARIO_CREACION := NVL(:NEW.USUARIO_CREACION, NVL(V('APP_USER'), USER));
END;
/
show errors trigger TRG_OV_USUARIO_CREACION

prompt == F18.3 Tabla METAS_VENTA ==
-- Meta de venta por VENDEDOR (ID_EMPLEADO) O por SUCURSAL (ID_OFICINA),
-- exactamente uno, por mes. Para "real vs. meta" en el Dashboard de Ventas.
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_tables
   WHERE owner='WKSP_WORKPLACE' AND table_name='METAS_VENTA';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[
      CREATE TABLE WKSP_WORKPLACE.METAS_VENTA (
        ID_META      NUMBER GENERATED ALWAYS AS IDENTITY
                       CONSTRAINT PK_METAS_VENTA PRIMARY KEY,
        ID_EMPLEADO  NUMBER
                       CONSTRAINT FK_METAS_VENTA_EMP
                       REFERENCES WKSP_WORKPLACE.EMPLEADOS (ID_EMPLEADO),
        ID_OFICINA   NUMBER
                       CONSTRAINT FK_METAS_VENTA_OFI
                       REFERENCES WKSP_WORKPLACE.OFICINAS (CODIGO_OFICINA),
        PERIODO      DATE   NOT NULL,
        MONTO_META   NUMBER NOT NULL
                       CONSTRAINT CK_METAS_VENTA_MONTO CHECK (MONTO_META > 0),
        CONSTRAINT CK_METAS_VENTA_DIM CHECK (
          (ID_EMPLEADO IS NOT NULL AND ID_OFICINA IS NULL) OR
          (ID_EMPLEADO IS NULL     AND ID_OFICINA IS NOT NULL)
        )
      )]';
    DBMS_OUTPUT.PUT_LINE('  + METAS_VENTA creada');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  = METAS_VENTA ya existe');
  END IF;
END;
/

-- Indice unico: una meta por (vendedor/sucursal, periodo). NVL para que el
-- UNIQUE distinga las dos dimensiones sin colisionar por NULLs.
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_indexes
   WHERE owner='WKSP_WORKPLACE' AND index_name='UQ_METAS_VENTA_DIM_PER';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE
      'CREATE UNIQUE INDEX WKSP_WORKPLACE.UQ_METAS_VENTA_DIM_PER '||
      'ON WKSP_WORKPLACE.METAS_VENTA '||
      '(NVL(ID_EMPLEADO,-1), NVL(ID_OFICINA,-1), PERIODO)';
    DBMS_OUTPUT.PUT_LINE('  + UQ_METAS_VENTA_DIM_PER creado');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  = UQ_METAS_VENTA_DIM_PER ya existe');
  END IF;
END;
/

prompt == F18.4 TRG_METAS_VENTA_BI (normaliza periodo + valida dimension) ==
-- Trunca PERIODO al 1ro del mes y reafirma la regla 1-de-2 (defensa en
-- profundidad junto al CHECK CK_METAS_VENTA_DIM).
CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_METAS_VENTA_BI
BEFORE INSERT OR UPDATE ON WKSP_WORKPLACE.METAS_VENTA
FOR EACH ROW
BEGIN
  IF :NEW.PERIODO IS NOT NULL THEN
    :NEW.PERIODO := TRUNC(:NEW.PERIODO, 'MM');
  END IF;
  IF NOT ( (:NEW.ID_EMPLEADO IS NOT NULL AND :NEW.ID_OFICINA IS NULL) OR
           (:NEW.ID_EMPLEADO IS NULL     AND :NEW.ID_OFICINA IS NOT NULL) ) THEN
    RAISE_APPLICATION_ERROR(-20992,
      'METAS_VENTA: defina exactamente uno de ID_EMPLEADO o ID_OFICINA.');
  END IF;
END;
/
show errors trigger TRG_METAS_VENTA_BI

-- Metas de ejemplo (comentadas): las define el PO. Descomentar y ajustar.
-- INSERT INTO WKSP_WORKPLACE.METAS_VENTA (ID_EMPLEADO, PERIODO, MONTO_META)
--   VALUES (81, DATE '2026-06-01', 50000000);   -- Tobias Casco, jun/26
-- INSERT INTO WKSP_WORKPLACE.METAS_VENTA (ID_OFICINA, PERIODO, MONTO_META)
--   VALUES (1,  DATE '2026-06-01', 120000000);  -- Sucursal 1, jun/26
-- COMMIT;

prompt == F18.5 Verificacion final ==
DECLARE
  v_cnt PLS_INTEGER;
  v_ok  BOOLEAN := TRUE;
BEGIN
  -- columna nueva
  SELECT COUNT(*) INTO v_cnt FROM all_tab_columns
   WHERE owner='WKSP_WORKPLACE' AND table_name='ORDENES_VENTA'
     AND column_name='USUARIO_CREACION' AND data_type='VARCHAR2';
  IF v_cnt=1 THEN DBMS_OUTPUT.PUT_LINE('  OK  COLUMN   ORDENES_VENTA.USUARIO_CREACION');
  ELSE DBMS_OUTPUT.PUT_LINE('  FAIL COLUMN   ORDENES_VENTA.USUARIO_CREACION'); v_ok:=FALSE; END IF;

  -- trigger de estampado valido y habilitado
  SELECT COUNT(*) INTO v_cnt FROM all_triggers
   WHERE owner='WKSP_WORKPLACE' AND trigger_name='TRG_OV_USUARIO_CREACION'
     AND status='ENABLED';
  IF v_cnt=1 THEN DBMS_OUTPUT.PUT_LINE('  OK  TRIGGER  TRG_OV_USUARIO_CREACION (ENABLED)');
  ELSE DBMS_OUTPUT.PUT_LINE('  FAIL TRIGGER  TRG_OV_USUARIO_CREACION'); v_ok:=FALSE; END IF;

  SELECT COUNT(*) INTO v_cnt FROM all_objects
   WHERE owner='WKSP_WORKPLACE' AND object_name='TRG_OV_USUARIO_CREACION'
     AND object_type='TRIGGER' AND status='VALID';
  IF v_cnt=1 THEN DBMS_OUTPUT.PUT_LINE('  OK  TRIGGER  TRG_OV_USUARIO_CREACION (VALID)');
  ELSE DBMS_OUTPUT.PUT_LINE('  FAIL TRIGGER  TRG_OV_USUARIO_CREACION no VALID'); v_ok:=FALSE; END IF;

  -- tabla de metas + indice unico
  SELECT COUNT(*) INTO v_cnt FROM all_tables
   WHERE owner='WKSP_WORKPLACE' AND table_name='METAS_VENTA';
  IF v_cnt=1 THEN DBMS_OUTPUT.PUT_LINE('  OK  TABLE    METAS_VENTA');
  ELSE DBMS_OUTPUT.PUT_LINE('  FAIL TABLE    METAS_VENTA'); v_ok:=FALSE; END IF;

  SELECT COUNT(*) INTO v_cnt FROM all_indexes
   WHERE owner='WKSP_WORKPLACE' AND index_name='UQ_METAS_VENTA_DIM_PER';
  IF v_cnt=1 THEN DBMS_OUTPUT.PUT_LINE('  OK  INDEX    UQ_METAS_VENTA_DIM_PER');
  ELSE DBMS_OUTPUT.PUT_LINE('  FAIL INDEX    UQ_METAS_VENTA_DIM_PER'); v_ok:=FALSE; END IF;

  -- trigger de metas valido y habilitado
  SELECT COUNT(*) INTO v_cnt FROM all_objects
   WHERE owner='WKSP_WORKPLACE' AND object_name='TRG_METAS_VENTA_BI'
     AND object_type='TRIGGER' AND status='VALID';
  IF v_cnt=1 THEN DBMS_OUTPUT.PUT_LINE('  OK  TRIGGER  TRG_METAS_VENTA_BI (VALID)');
  ELSE DBMS_OUTPUT.PUT_LINE('  FAIL TRIGGER  TRG_METAS_VENTA_BI no VALID'); v_ok:=FALSE; END IF;

  IF v_ok THEN DBMS_OUTPUT.PUT_LINE(CHR(10)||'F18 aplicado OK.');
  ELSE RAISE_APPLICATION_ERROR(-20999,'F18 verificacion FAIL.'); END IF;
END;
/

prompt == F18 - fin ==
set define on
ALTER SESSION SET CURRENT_SCHEMA = ADMIN;
