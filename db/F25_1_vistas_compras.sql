-- ============================================================================
-- F25.1 - Vistas gerenciales de Compras (single source of truth de P144/P145)
-- ============================================================================
-- Consumidas por el Dashboard de Compras (P144) y el Informe imprimible (P145).
-- REGLA DE ORO: el gasto se cuenta por el COMPROBANTE DE PROVEEDOR (factura de
-- compra) FA no anulada con TOTAL no NULL, NO por la OC (la OC es el embudo).
-- Dimension comprador/oficina viene de la OC (fallback: oficina del comprobante).
-- Fechas locales con FN_HOY (UTC-3), nunca SYSDATE (BD en UTC).
--
-- Reusa la capa transaccional de F24: V_CXP_DEUDA (deuda/aging) y ORDENES_PAGO
-- (pagos). No recalcula la deuda: F24 es la fuente autoritativa.
--
-- Idempotente: CREATE OR REPLACE FORCE VIEW.
-- Aplicar: sql -S -name tesis_db < db/F25_1_vistas_compras.sql
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;
set define off
whenever sqlerror exit sql.sqlcode rollback

prompt == F25.1 V_CMP_COMPRA (grano comprobante = gasto) ==
-- Incluye FA (gasto +) y NC de compra (credito -, F26): el gasto neto = SUM(TOTAL).
-- La columna TIPO_COMPROBANTE permite a las vistas downstream distinguir FA de NC.
CREATE OR REPLACE FORCE VIEW WKSP_WORKPLACE.V_CMP_COMPRA AS
SELECT c.ID_COMPROBANTE,
       c.ID_PROVEEDOR,
       TRIM(perp.PRIMER_NOMBRE||' '||perp.PRIMER_APELLIDO) PROVEEDOR,
       c.FECHA_EMISION,
       TRUNC(c.FECHA_EMISION,'MM')                         PERIODO,
       CASE WHEN c.TIPO_COMPROBANTE='NC' THEN -c.TOTAL_COMPROBANTE
            ELSE c.TOTAL_COMPROBANTE END                   TOTAL,
       c.ESTADO,
       CASE WHEN c.TIPO_COMPROBANTE='NC' THEN 'Nota de credito'
            ELSE CASE c.ESTADO WHEN 'R' THEN 'Registrada'
                               WHEN 'PR' THEN 'Recepcion parcial'
                               WHEN 'C' THEN 'Completada'
                               WHEN 'A' THEN 'Anulada' ELSE c.ESTADO END
       END                                                 ESTADO_LABEL,
       c.FORMA_PAGO,
       CASE WHEN c.TIPO_COMPROBANTE='NC' THEN 'Nota de credito'
            WHEN c.FORMA_PAGO='1'  THEN 'Credito'
            WHEN c.FORMA_PAGO='21' THEN 'Contado' ELSE 'Otro' END CONDICION,
       NVL(oc.ID_OFICINA, c.ID_OFICINA)                    ID_OFICINA,
       ofi.DESCRIPCION                                     OFICINA,
       oc.ID_ORDEN_COMPRA,
       oc.ID_EMPLEADO,
       NVL(TRIM(pere.PRIMER_NOMBRE||' '||pere.PRIMER_APELLIDO),'(sin asignar)') COMPRADOR,
       c.TIPO_COMPROBANTE
  FROM WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR c
  JOIN WKSP_WORKPLACE.PROVEEDORES pr        ON pr.ID_PERSONA   = c.ID_PROVEEDOR
  LEFT JOIN WKSP_WORKPLACE.PERSONAS perp    ON perp.ID_PERSONA = pr.ID_PERSONA
  LEFT JOIN WKSP_WORKPLACE.ORDENES_COMPRA oc ON oc.ID_ORDEN_COMPRA = c.ID_ORDEN_COMPRA
  LEFT JOIN WKSP_WORKPLACE.EMPLEADOS emp    ON emp.ID_EMPLEADO = oc.ID_EMPLEADO
  LEFT JOIN WKSP_WORKPLACE.PERSONAS pere    ON pere.ID_PERSONA = emp.ID_PERSONA
  LEFT JOIN WKSP_WORKPLACE.OFICINAS ofi     ON ofi.CODIGO_OFICINA = NVL(oc.ID_OFICINA, c.ID_OFICINA)
 WHERE c.TIPO_COMPROBANTE IN ('FA','NC')
   AND c.ESTADO <> 'A'
   AND c.TOTAL_COMPROBANTE IS NOT NULL;

prompt == F25.1 V_CMP_LINEA (grano detalle = top productos) ==
CREATE OR REPLACE FORCE VIEW WKSP_WORKPLACE.V_CMP_LINEA AS
SELECT d.ID_DETALLE,
       d.ID_COMPROBANTE,
       cc.PERIODO,
       cc.ID_PROVEEDOR,
       cc.PROVEEDOR,
       d.ID_PRODUCTO,
       p.NOMBRE                 PRODUCTO,
       cat.DESCRIPCION          CATEGORIA,
       d.CANTIDAD,
       d.PRECIO_UNITARIO,
       d.TOTAL
  FROM WKSP_WORKPLACE.DETALLE_COMPROBANTE_PROV d
  JOIN WKSP_WORKPLACE.V_CMP_COMPRA cc          ON cc.ID_COMPROBANTE = d.ID_COMPROBANTE
  LEFT JOIN WKSP_WORKPLACE.PRODUCTOS p         ON p.ID_PRODUCTO = d.ID_PRODUCTO
  LEFT JOIN WKSP_WORKPLACE.CATEGORIAS_PRODUCTOS cat ON cat.ID_CATEGORIA = p.ID_CATEGORIA
 WHERE cc.TIPO_COMPROBANTE = 'FA';   -- top productos = compras (FA); las lineas de NC no suman

prompt == F25.1 V_CMP_GASTO_MES (gasto por periodo/proveedor) ==
CREATE OR REPLACE FORCE VIEW WKSP_WORKPLACE.V_CMP_GASTO_MES AS
SELECT PERIODO,
       ID_PROVEEDOR,
       PROVEEDOR,
       SUM(CASE WHEN TIPO_COMPROBANTE='FA' THEN 1 ELSE 0 END) N_COMPRAS,  -- NC no cuenta como compra
       SUM(TOTAL)  GASTO   -- gasto neto: FA (+) menos NC (-)
  FROM WKSP_WORKPLACE.V_CMP_COMPRA
 GROUP BY PERIODO, ID_PROVEEDOR, PROVEEDOR;

prompt == F25.1 V_CMP_OC_EMBUDO (embudo de ordenes de compra) ==
CREATE OR REPLACE FORCE VIEW WKSP_WORKPLACE.V_CMP_OC_EMBUDO AS
SELECT oc.ESTADO,
       CASE oc.ESTADO WHEN 'B' THEN 'Borrador'
                      WHEN 'P' THEN 'Pendiente recepcion'
                      WHEN 'C' THEN 'Completada'
                      WHEN 'X' THEN 'Rechazada'
                      WHEN 'A' THEN 'Anulada' ELSE oc.ESTADO END ESTADO_LABEL,
       CASE oc.ESTADO WHEN 'B' THEN 1 WHEN 'P' THEN 2 WHEN 'C' THEN 3
                      WHEN 'X' THEN 4 WHEN 'A' THEN 5 ELSE 9 END ORDEN,
       COUNT(*)                     N_OC,
       SUM(NVL(oc.TOTAL_ORDEN,0))   MONTO
  FROM WKSP_WORKPLACE.ORDENES_COMPRA oc
 GROUP BY oc.ESTADO;

prompt == F25.1 V_CMP_OC_ABIERTA (OC aprobadas pendientes de recepcion) ==
CREATE OR REPLACE FORCE VIEW WKSP_WORKPLACE.V_CMP_OC_ABIERTA AS
SELECT oc.ID_ORDEN_COMPRA,
       oc.ID_PROVEEDOR,
       TRIM(per.PRIMER_NOMBRE||' '||per.PRIMER_APELLIDO) PROVEEDOR,
       oc.FECHA_ORDEN,
       oc.TOTAL_ORDEN,
       (TRUNC(WKSP_WORKPLACE.FN_HOY) - TRUNC(oc.FECHA_ORDEN)) DIAS_ABIERTA,
       oc.ID_OFICINA,
       ofi.DESCRIPCION OFICINA
  FROM WKSP_WORKPLACE.ORDENES_COMPRA oc
  JOIN WKSP_WORKPLACE.PROVEEDORES pr     ON pr.ID_PERSONA = oc.ID_PROVEEDOR
  LEFT JOIN WKSP_WORKPLACE.PERSONAS per  ON per.ID_PERSONA = pr.ID_PERSONA
  LEFT JOIN WKSP_WORKPLACE.OFICINAS ofi  ON ofi.CODIGO_OFICINA = oc.ID_OFICINA
 WHERE oc.ESTADO = 'P';

prompt == F25.1 V_CMP_RECEPCION (lead time OC -> recepcion) ==
CREATE OR REPLACE FORCE VIEW WKSP_WORKPLACE.V_CMP_RECEPCION AS
SELECT r.ID_RECEPCION,
       r.ID_ORDEN_COMPRA,
       oc.ID_PROVEEDOR,
       TRIM(per.PRIMER_NOMBRE||' '||per.PRIMER_APELLIDO) PROVEEDOR,
       oc.FECHA_ORDEN,
       r.FECHA_RECEPCION,
       (TRUNC(r.FECHA_RECEPCION) - TRUNC(oc.FECHA_ORDEN)) LEAD_DIAS,
       TRUNC(r.FECHA_RECEPCION,'MM')                      PERIODO,
       (SELECT NVL(SUM(dr.CANTIDAD_RECIBIDA),0)
          FROM WKSP_WORKPLACE.DETALLE_RECEPCION_COMPRA dr
         WHERE dr.ID_RECEPCION = r.ID_RECEPCION)          CANT_RECIBIDA
  FROM WKSP_WORKPLACE.RECEPCIONES_COMPRA r
  LEFT JOIN WKSP_WORKPLACE.ORDENES_COMPRA oc ON oc.ID_ORDEN_COMPRA = r.ID_ORDEN_COMPRA
  LEFT JOIN WKSP_WORKPLACE.PROVEEDORES pr    ON pr.ID_PERSONA = oc.ID_PROVEEDOR
  LEFT JOIN WKSP_WORKPLACE.PERSONAS per      ON per.ID_PERSONA = pr.ID_PERSONA;

prompt == F25.1 V_CMP_CXP_AGING (aging de deuda, envuelve V_CXP_DEUDA) ==
CREATE OR REPLACE FORCE VIEW WKSP_WORKPLACE.V_CMP_CXP_AGING AS
SELECT d.ID_CXP,
       d.ID_PROVEEDOR,
       d.PROVEEDOR,
       d.ID_COMPROBANTE,
       d.NRO_COMPROBANTE,
       d.FECHA_EMISION,
       d.TOTAL_A_PAGAR,
       d.SALDO,
       d.FECHA_VENCIMIENTO,
       d.DIAS_ATRASO,
       d.SITUACION,
       CASE WHEN d.DIAS_ATRASO <= 0  THEN 'Por vencer'
            WHEN d.DIAS_ATRASO <= 30 THEN '1-30'
            WHEN d.DIAS_ATRASO <= 60 THEN '31-60'
            WHEN d.DIAS_ATRASO <= 90 THEN '61-90'
            ELSE '+90' END                                BUCKET,
       CASE WHEN d.DIAS_ATRASO <= 0  THEN 1
            WHEN d.DIAS_ATRASO <= 30 THEN 2
            WHEN d.DIAS_ATRASO <= 60 THEN 3
            WHEN d.DIAS_ATRASO <= 90 THEN 4
            ELSE 5 END                                    BUCKET_ORDEN
  FROM WKSP_WORKPLACE.V_CXP_DEUDA d
 WHERE d.SALDO > 0;

prompt == F25.1 V_CMP_PAGOS (ordenes de pago = pagos realizados / borrador) ==
CREATE OR REPLACE FORCE VIEW WKSP_WORKPLACE.V_CMP_PAGOS AS
SELECT op.ID_ORDEN_PAGO,
       op.ID_PROVEEDOR,
       TRIM(per.PRIMER_NOMBRE||' '||per.PRIMER_APELLIDO) PROVEEDOR,
       op.FECHA_EMISION,
       op.FECHA_PAGO,
       TRUNC(op.FECHA_PAGO,'MM')  PERIODO_PAGO,
       op.TOTAL_PAGO,
       op.ID_METODO_PAGO,
       mp.DESCRIPCION             METODO,
       op.ESTADO
  FROM WKSP_WORKPLACE.ORDENES_PAGO op
  JOIN WKSP_WORKPLACE.PROVEEDORES pr    ON pr.ID_PERSONA = op.ID_PROVEEDOR
  LEFT JOIN WKSP_WORKPLACE.PERSONAS per ON per.ID_PERSONA = pr.ID_PERSONA
  LEFT JOIN WKSP_WORKPLACE.METODOS_PAGO mp ON mp.ID_METODO_PAGO = op.ID_METODO_PAGO;

prompt == F25.1 Verificacion ==
DECLARE
  v_invalid PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_invalid FROM all_objects
   WHERE owner='WKSP_WORKPLACE' AND object_type='VIEW'
     AND object_name IN ('V_CMP_COMPRA','V_CMP_LINEA','V_CMP_GASTO_MES',
                          'V_CMP_OC_EMBUDO','V_CMP_OC_ABIERTA','V_CMP_RECEPCION',
                          'V_CMP_CXP_AGING','V_CMP_PAGOS')
     AND status <> 'VALID';
  IF v_invalid > 0 THEN
    RAISE_APPLICATION_ERROR(-20946,'F25.1: hay '||v_invalid||' vistas V_CMP_* invalidas.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('F25.1 OK: 8 vistas V_CMP_* validas.');
END;
/

prompt == F25.1 - fin ==
set define on
ALTER SESSION SET CURRENT_SCHEMA = ADMIN;
