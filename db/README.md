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

Próximos: F2 caducidad, F3 stock por oficina, F5 pantalla cambio estado, F6 reporte anulados.
