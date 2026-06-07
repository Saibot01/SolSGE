# db/

Migraciones SQL versionadas para SolSGE.

Cada archivo `F<n>_<nombre>.sql` corresponde a una Feature del [`PLAN_VENTAS.md`](../PLAN_VENTAS.md) (u otro plan equivalente) y captura todo el DDL/DML/PLSQL no-APEX necesario para esa feature (columnas nuevas, constraints, funciones, triggers, jobs, parámetros).

## Por qué existe esta carpeta

Históricamente los cambios de BD se aplicaban directo al schema `WKSP_WORKPLACE` vía SQLcl o APEX UI, sin quedar versionados. F4 reveló el problema: la BD live tenía toda la lógica de estados (constraint, función, 3 triggers, columnas) que no estaba en el repo — irreproducible si la base se pierde.

Esta carpeta arregla eso de acá en adelante. F4 es el primer script; features siguientes deberían sumar el suyo antes (o al menos junto con) tocar APEX.

## Reglas

- **Idempotente.** Cada script debe poder correrse N veces sin errores ni efectos secundarios. Usar `CREATE OR REPLACE` para funciones/triggers, `DECLARE...IF NOT EXISTS` para columnas/constraints, `UPDATE...WHERE ...` con filtros que no re-modifiquen filas ya correctas.
- **Auto-contenido.** Cada script aplica una feature completa, no fragmentos.
- **Sección de verificación al final.** Un bloque `DBMS_OUTPUT` que chequea que todo quedó en estado VALID/ENABLED y emite OK/FAIL.
- **Schema explícito.** `WKSP_WORKPLACE.<objeto>` en todos los CREATE/ALTER. La sesión sale con `current_schema = ADMIN` por default.

## Cómo aplicar

```bash
sql -S -name $SQLCL_CONNECTION <<'EOF'
@db/F4_estados.sql
exit;
EOF
```

`SQLCL_CONNECTION` está en `.claude/settings.json` (`tesis_db` por default).

## Inventario

| Script | Feature | Estado |
|---|---|---|
| `F4_estados.sql` | F4 — Estados del Presupuesto (CHECK, funcion guardiana, 3 triggers, columnas auditoria) | Aplicado en live antes del 2026-05-26 (versionado retroactivamente el 2026-05-26) |
| `F2_caducidad.sql` | F2 — Caducidad parametrizable (PARAMETRO `DIAS_VIGENCIA_PRESUPUESTO`, columna `FECHA_VENCIMIENTO`, `TRG_OV_FECHA_VENCIMIENTO`) | Aplicado el 2026-05-27 |
| `F3_stock_oficina.sql` | F3 — Stock por oficina (`FN_HAY_STOCK`, `FN_OFICINAS_CON_STOCK`, `FN_OFICINA_USUARIO`) | Aplicado el 2026-05-27 |
| `F8_facturacion.sql` | F8 — Facturacion contado (renombre `RECIBOS_COBRO → MOVIMIENTOS_CAJA`, columnas del documento de recibo, `FN_CAJA_ABIERTA_USUARIO`, `FN_OFICINA_USUARIO_V2`, reescritura de `FN_OBTENER_COMPROBANTE`, vistas `V_TALONARIOS_DISPONIBLES` y `V_RECIBOS_COBRO`, drop `TRG_ACTUALIZAR_STOCK_FACTURA`, extension `TRG_OV_LIBERA_RESERVA`, `TRG_CAJA_UNA_POR_DIA`, `UQ_CAJA_ABIERTA_EMP`, `CERRAR_CAJA` v2) | en aplicación (2026-06-06) |

Próximos: F5 pantalla cambio estado (deuda PV), F6 reporte anulados (deuda PV), F9 cobros + recibo.
