-- ============================================================================
-- F15.2 — Interruptor maestro para OCULTAR el modulo de Reverso de Cobro (F15)
-- ----------------------------------------------------------------------------
-- Contexto: con la NC reconciliando las cuotas pendientes de la CxC y la regla
-- del PO de "no se devuelve dinero al cliente", el Reverso de Cobro (que genera
-- un EGRESO de caja = devolucion de efectivo) se oculta. NO se borra nada: el
-- backend (PRC/FN/vistas/tablas) y las paginas P128/P129/P130 quedan intactas.
--
-- Mecanismo: un parametro PARAMETROS.REVERSO_COBRO_ACTIVO ('S'/'N'). Las guardas
-- de UI lo leen via FN_GET_PARAMETRO(...,'TEXTO'):
--   - P99: el icono "Solicitar reverso" solo se dibuja si = 'S'.
--   - Menu "Reversos de Cobro" -> P129: el PO condiciona la entrada en el Builder
--     (shared component, no se importa por @@). Ver nota al pie.
--
-- REVERSIBLE con un solo cambio:
--   UPDATE WKSP_WORKPLACE.PARAMETROS SET VALOR_TEXTO='S'
--    WHERE CLAVE='REVERSO_COBRO_ACTIVO';   COMMIT;
--   (y re-mostrar la entrada de menu en el Builder)
--
-- Idempotente: crea el parametro en 'N' si no existe; si ya existe NO pisa el
-- valor (para no re-ocultar si alguien lo reactivo a mano).
-- ============================================================================

prompt == F15.2 Parametro REVERSO_COBRO_ACTIVO (default 'N' = oculto) ==
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM WKSP_WORKPLACE.PARAMETROS
   WHERE CLAVE = 'REVERSO_COBRO_ACTIVO';
  IF v_cnt = 0 THEN
    INSERT INTO WKSP_WORKPLACE.PARAMETROS
      (TIPO_PARAMETRO, CLAVE, VALOR_TEXTO, DESCRIPCION, ACTIVO, USUARIO_CREACION)
    VALUES
      ('REVERSO', 'REVERSO_COBRO_ACTIVO', 'N',
       'Interruptor del modulo Reverso de Cobro (F15). S=visible, N=oculto. '
       ||'Con N el icono de P99 y la entrada de menu se ocultan; el backend queda intacto.',
       'S', 'SYSTEM');
    DBMS_OUTPUT.PUT_LINE('  + Parametro REVERSO_COBRO_ACTIVO=N creado (modulo oculto)');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  = Parametro REVERSO_COBRO_ACTIVO ya existe (valor no modificado)');
  END IF;
  COMMIT;
END;
/

prompt == F15.2 Verificacion ==
DECLARE
  v_val VARCHAR2(10);
BEGIN
  v_val := WKSP_WORKPLACE.FN_GET_PARAMETRO('REVERSO_COBRO_ACTIVO','TEXTO');
  IF v_val IS NULL THEN
    RAISE_APPLICATION_ERROR(-20999,'REVERSO_COBRO_ACTIVO no quedo creado.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('  OK  PARAM  REVERSO_COBRO_ACTIVO = '||v_val);
END;
/

prompt == F15.2 - fin ==
-- ----------------------------------------------------------------------------
-- PASO MANUAL DEL PO (menu, shared component):
--   App Builder -> Shared Components -> Navigation Menu -> entrada
--   "Reversos de Cobro" (-> pagina 129). En "Condition":
--     Type      = PL/SQL Expression (Function Returning Boolean)
--     Expression: WKSP_WORKPLACE.FN_GET_PARAMETRO('REVERSO_COBRO_ACTIVO','TEXTO')='S'
--   Con el parametro en 'N' la entrada desaparece; en 'S' vuelve.
--   (Alternativa: simplemente desmarcar/ocultar la entrada.)
-- ----------------------------------------------------------------------------
