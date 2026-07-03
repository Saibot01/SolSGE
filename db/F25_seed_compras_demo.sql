--------------------------------------------------------------------------------
-- F25_seed_compras_demo.sql  --  Reportes Gerenciales de Compras (F25) - H1
--------------------------------------------------------------------------------
-- Enriquece el dataset de Compras (el mas chico de todos los modulos) para que
-- los charts gerenciales no queden degenerados. DATO DE DEMOSTRACION, no historico
-- real (presentarlo asi en la defensa). Idempotente: guardas por NRO_DOCUMENTO
-- (proveedores) y NRO_COMPROBANTE (compras) => se puede re-correr sin duplicar.
--
-- Enriquece: proveedores (2 -> 5), productos/categorias comprados (Gaming -> +Laptops/
-- Smartphones/Audio/Televisores), meses (jul-2025 .. may-2026), oficinas (1 -> 2),
-- condicion (agrega 2 contado), y aging de CxP (los creditos generan CxP via
-- TRG_INS_CUENTAS_PAGAR, con vencimientos = FECHA_EMISION + PLAZO_PAGO_DIAS).
--
-- Seguridad de triggers (verificado 2026-07-02):
--   * DETALLE_COMPROBANTE_PROV: TRG_MOV_STOCK_DETALLE_PROV esta DISABLED
--     => insertar detalle de compra NO mueve stock.
--   * NO se siembran RECEPCIONES_COMPRA (TRG_MOV_STOCK_RECEPCION esta ENABLED y
--     moveria stock) -> el lead time usa las recepciones reales existentes.
--   * COMPROBANTES_PROVEEDOR credito dispara TRG_INS_CUENTAS_PAGAR (deseado: CxP).
--
-- Aplicar:  sql -S -name tesis_db < db/F25_seed_compras_demo.sql
-- Errores:  -20945 (bloque F25 -20945..-20948)
--------------------------------------------------------------------------------

SET SERVEROUTPUT ON

DECLARE
  v_tecno  NUMBER;   -- TecnoImport S.A.
  v_global NUMBER;   -- Global PC Distribuciones S.A.
  v_audio  NUMBER;   -- AudioVisual Import S.A.

  -- Alta idempotente de proveedor (persona juridica + fila PROVEEDORES).
  PROCEDURE ensure_prov(p_nombre VARCHAR2, p_ape VARCHAR2, p_ruc VARCHAR2,
                        p_plazo NUMBER, o_id OUT NUMBER) IS
  BEGIN
    SELECT id_persona INTO o_id FROM WKSP_WORKPLACE.PERSONAS
     WHERE nro_documento = p_ruc;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    INSERT INTO WKSP_WORKPLACE.PERSONAS(tipo_documento, nro_documento, tipo_persona,
              primer_nombre, primer_apellido, fecha_registro)
      VALUES('2', p_ruc, 'J', p_nombre, p_ape, WKSP_WORKPLACE.FN_AHORA)
      RETURNING id_persona INTO o_id;
    INSERT INTO WKSP_WORKPLACE.PROVEEDORES(id_persona, codigo_usuario, estado,
              fecha_registro, categoria, plazo_pago_dias)
      VALUES(o_id, 'DEMO', 'A', WKSP_WORKPLACE.FN_AHORA, 'N', p_plazo);
  END;

  -- Alta idempotente de un documento de compra: OC (estado C) + comprobante FA
  -- (linkeado a la OC) + 1 linea de detalle. Guard por NRO_COMPROBANTE.
  PROCEDURE ensure_compra(p_nro VARCHAR2, p_prov NUMBER, p_emp NUMBER, p_ofi NUMBER,
                          p_fecha DATE, p_forma VARCHAR2, p_prod NUMBER,
                          p_cant NUMBER, p_precio NUMBER) IS
    v_oc    NUMBER;
    v_comp  NUMBER;
    v_total NUMBER := p_cant * p_precio;
    v_n     NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_n FROM WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR
     WHERE nro_comprobante = p_nro;
    IF v_n > 0 THEN RETURN; END IF;

    INSERT INTO WKSP_WORKPLACE.ORDENES_COMPRA(id_proveedor, fecha_orden, estado,
              observacion, id_empleado, id_oficina, total_orden, id_aprobador,
              fecha_aprobacion)
      VALUES(p_prov, p_fecha - 5, 'C', 'DEMO F25', p_emp, p_ofi, v_total, p_emp,
             p_fecha - 3)
      RETURNING id_orden_compra INTO v_oc;

    INSERT INTO WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR(tipo_comprobante, id_proveedor,
              fecha_emision, nro_comprobante, moneda, tipo_cambio, total_comprobante,
              id_oficina, id_orden_compra, estado, forma_pago, observacion)
      VALUES('FA', p_prov, p_fecha, p_nro, '1', 1, v_total, p_ofi, v_oc, 'C',
             p_forma, 'DEMO F25')
      RETURNING id_comprobante INTO v_comp;

    INSERT INTO WKSP_WORKPLACE.DETALLE_COMPROBANTE_PROV(id_comprobante, id_producto,
              cantidad, precio_unitario, total)
      VALUES(v_comp, p_prod, p_cant, p_precio, v_total);
  END;
BEGIN
  -- 1) Proveedores demo (3 nuevos; con Tobias(1) y Nissei(101) => 5).
  ensure_prov('TecnoImport', 'S.A.',            '80012345-1', 30, v_tecno);
  ensure_prov('Global PC Distribuciones', 'S.A.','80023456-2', 45, v_global);
  ensure_prov('AudioVisual Import', 'S.A.',     '80034567-3', 60, v_audio);

  -- 2) Documentos de compra demo (empleados: 81 Tobias, 61 Carlos).
  --    nro         prov      emp  ofi fecha              forma prod cant  precio_unit
  ensure_compra('DEMO-C-01', v_tecno,  81, 1, DATE '2025-07-15', '1',  21, 3, 4200000);
  ensure_compra('DEMO-C-02', v_tecno,  61, 2, DATE '2025-08-20', '1',  22, 5, 2100000);
  ensure_compra('DEMO-C-03', v_global, 81, 1, DATE '2025-09-10', '1',  21, 2, 4150000);
  ensure_compra('DEMO-C-04', v_global, 61, 2, DATE '2025-10-05', '21', 4, 10, 250000);
  ensure_compra('DEMO-C-05', v_audio,  81, 1, DATE '2025-11-25', '1',  23, 8, 780000);
  ensure_compra('DEMO-C-06', v_audio,  61, 2, DATE '2025-12-15', '1',  24, 4, 2900000);
  ensure_compra('DEMO-C-07', 101,      81, 1, DATE '2026-01-20', '1',   3, 6, 380000);
  ensure_compra('DEMO-C-08', v_tecno,  61, 1, DATE '2026-02-18', '21',  2, 3, 2300000);
  ensure_compra('DEMO-C-09', v_global, 81, 2, DATE '2026-03-22', '1',  24, 3, 2950000);
  ensure_compra('DEMO-C-10', v_audio,  61, 1, DATE '2026-05-12', '1',  22, 4, 2050000);

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Seed F25 aplicado (proveedores + compras demo).');
END;
/

--------------------------------------------------------------------------------
-- Verificacion
--------------------------------------------------------------------------------
DECLARE
  v_prov    NUMBER;
  v_compras NUMBER;
  v_cxp     NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_prov FROM WKSP_WORKPLACE.PROVEEDORES
   WHERE codigo_usuario = 'DEMO';
  SELECT COUNT(*) INTO v_compras FROM WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR
   WHERE observacion = 'DEMO F25';
  SELECT COUNT(*) INTO v_cxp FROM WKSP_WORKPLACE.CUENTAS_PAGAR cp
   JOIN WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR c ON c.id_comprobante = cp.id_comprobante
   WHERE c.observacion = 'DEMO F25';

  DBMS_OUTPUT.PUT_LINE('Proveedores demo : '||v_prov);
  DBMS_OUTPUT.PUT_LINE('Compras demo     : '||v_compras);
  DBMS_OUTPUT.PUT_LINE('CxP demo (credito): '||v_cxp);

  IF v_prov < 3 OR v_compras < 10 THEN
    RAISE_APPLICATION_ERROR(-20945,
      'Seed F25 incompleto: proveedores='||v_prov||' compras='||v_compras);
  END IF;
  -- 8 de las 10 compras demo son a credito => deben generar 8 CxP.
  IF v_cxp <> 8 THEN
    RAISE_APPLICATION_ERROR(-20945,
      'Seed F25: CxP demo esperadas=8 obtenidas='||v_cxp);
  END IF;
  DBMS_OUTPUT.PUT_LINE('Verificacion OK.');
END;
/
