# Guía de Fecha/Hora — SolSGE

> **Regla de oro:** en este proyecto **NUNCA** uses `SYSDATE` ni `SYSTIMESTAMP`
> para una fecha/hora de **negocio**. Usá `WKSP_WORKPLACE.FN_HOY` (fecha) o
> `WKSP_WORKPLACE.FN_AHORA` (fecha+hora). El motivo está abajo.

## El problema (por qué existe esta guía)

La base corre en **Oracle Autonomous Database con `DBTIMEZONE = +00:00` (UTC)**.
Eso significa que:

- `SYSDATE` y `SYSTIMESTAMP` devuelven la hora del **servidor en UTC**, no la
  hora local de Paraguay/Argentina (UTC-3).
- Después de las **~21:00 hora local**, en UTC ya es el **día siguiente**.

Síntoma real que disparó el fix (2026-06-26): se abrió una caja a las 21hs del
día 26 (`FEC_APERTURA` local = 26), pero la validación "¿la caja es de hoy?"
comparaba contra `TRUNC(SYSDATE)` = **27** (UTC) → bloqueaba la facturación con
*"Tu caja fue abierta en una fecha distinta a hoy"*. Lo mismo pasaba con
aprobación de notas de crédito, reversos de cobro y vigencia de talonarios.

## El gotcha de la zona horaria (importante)

No alcanza con convertir a `America/Asuncion`: **el archivo de timezones de la
base tiene reglas viejas** y `America/Asuncion` devuelve **UTC-4** en invierno
(aplica un DST que Paraguay ya no usa desde 2024). Comprobado:

```
SYSTIMESTAMP AT TIME ZONE 'America/Asuncion'                  -> UTC-4 (mal, 1h atrás)
SYSTIMESTAMP AT TIME ZONE 'America/Argentina/Buenos_Aires'   -> UTC-3 (correcto)
SYSTIMESTAMP AT TIME ZONE '-03:00'                           -> UTC-3 (correcto)
```

Por eso se usa **`America/Argentina/Buenos_Aires`** (UTC-3 estable, sin DST), que
coincide con la hora local real y con la zona que ya usaba P67.

## La solución: `FN_HOY` y `FN_AHORA`

Definidas en [`db/F19_fecha_local.sql`](db/F19_fecha_local.sql):

```sql
-- Fecha local truncada (DATE, sin hora). Reemplaza TRUNC(SYSDATE).
WKSP_WORKPLACE.FN_HOY   RETURN DATE
  := TRUNC(CAST(SYSTIMESTAMP AT TIME ZONE 'America/Argentina/Buenos_Aires' AS DATE));

-- Fecha + hora local (DATE con hora). Reemplaza SYSDATE/SYSTIMESTAMP de negocio.
WKSP_WORKPLACE.FN_AHORA RETURN DATE
  := CAST(SYSTIMESTAMP AT TIME ZONE 'America/Argentina/Buenos_Aires' AS DATE);
```

## Cómo elegir qué usar (para nuevos desarrollos)

| Caso de uso | Usar | Ejemplo |
|---|---|---|
| "¿Es de hoy?", comparar contra el día | `FN_HOY` | `WHERE TRUNC(fec) = WKSP_WORKPLACE.FN_HOY` |
| Vigencia (BETWEEN fecha_inicio/fin) | `FN_HOY` | `WKSP_WORKPLACE.FN_HOY BETWEEN f_ini AND f_fin` |
| Mes/año de negocio | `FN_HOY` | `TO_CHAR(WKSP_WORKPLACE.FN_HOY,'YYYYMM')` |
| Default de un ítem fecha en APEX | `FN_HOY` | item default = `WKSP_WORKPLACE.FN_HOY` |
| Fecha+hora de un evento operativo | `FN_AHORA` | `FECHA_MOVIMIENTO = WKSP_WORKPLACE.FN_AHORA` |
| Hora del día (HH24:MI:SS) | `FN_AHORA` | `TO_CHAR(WKSP_WORKPLACE.FN_AHORA,'HH24:MI:SS')` |
| Fecha de movimiento de caja / cierre | `FN_AHORA` | `MOVIMIENTOS_CAJA.FECHA`, `CAJAS.FEC_CIERRE` |
| "Generado el ..." en documentos/reportes | `FN_AHORA` | `TO_CHAR(WKSP_WORKPLACE.FN_AHORA,'dd/mm/yyyy hh24:mi')` |

### Qué SÍ puede quedar en `SYSDATE`/`SYSTIMESTAMP`

Solo **auditoría técnica pura** que no se compara como fecha de negocio ni se
muestra como hora local al usuario:

- `FECHA_CREACION`, `FECHA_MODIFICACION`, `FECHA_RESOLUCION`, `FECHA_SOLICITUD`,
  `FECHA_CAMBIO` (columnas de auditoría de registro).
- Ventanas técnicas internamente consistentes (ej. tokens de `PKG_EMPLEADOS`:
  el expiry y la comparación usan ambos `SYSTIMESTAMP`, así que la ventana de
  24h funciona igual en cualquier zona).

> Si tenés dudas entre auditoría y negocio: si el valor se **muestra al usuario**
> como fecha/hora, o se **compara/agrupa por día**, es **negocio** → `FN_HOY`/`FN_AHORA`.

## Reglas prácticas

1. En PL/SQL y vistas: `TRUNC(SYSDATE)` → `WKSP_WORKPLACE.FN_HOY`;
   `SYSDATE`/`SYSTIMESTAMP` de negocio → `WKSP_WORKPLACE.FN_AHORA`.
2. En APEX (procesos, validaciones, defaults de ítems, region source, badges):
   misma regla. El parsing schema es `WKSP_WORKPLACE`, así que se llaman directo.
3. **Ojo con `SYSTIMESTAMP`**: también está en UTC. No es "más local" que
   `SYSDATE`. Aplica la misma regla.
4. No uses `America/Asuncion` (timezone file desactualizado). Usá
   `America/Argentina/Buenos_Aires` o `-03:00` — o mejor, `FN_HOY`/`FN_AHORA`.

## Cómo auditar el código (encontrar usos nuevos de SYSDATE/SYSTIMESTAMP)

```sql
-- PL/SQL (funciones, procedimientos, paquetes, triggers)
SELECT name, type, line, text FROM all_source
 WHERE owner='WKSP_WORKPLACE'
   AND (UPPER(text) LIKE '%SYSDATE%' OR UPPER(text) LIKE '%SYSTIMESTAMP%')
 ORDER BY name, line;

-- Vistas
SELECT view_name FROM all_views
 WHERE owner='WKSP_WORKPLACE'
   AND (UPPER(text_vc) LIKE '%SYSDATE%' OR UPPER(text_vc) LIKE '%SYSTIMESTAMP%');

-- APEX (app 100): procesos, validaciones, items, regiones
SELECT page_id, process_name FROM apex_application_page_proc
 WHERE application_id=100
   AND (UPPER(process_source) LIKE '%SYSDATE%' OR UPPER(process_source) LIKE '%SYSTIMESTAMP%');
```

## Qué se corrigió en el fix original (2026-06-26/27)

- **Helpers:** `db/F19_fecha_local.sql` (`FN_HOY`, `FN_AHORA`).
- **Migración de negocio:** `db/F20_fix_timezone_negocio.sql` (objetos que solo
  vivían en la base: precios/costo, vistas de vigencia, triggers de HORA y de
  movimiento de stock, `INVENTARIO_BI`, `INVENTARIO_PKG`).
- **Ediciones in-place** (corregidas en su archivo de origen y re-aplicado el
  program unit): `F2` (vencimiento presupuesto), `F4` (reserva), `F8`/`F10`
  (talonarios, `FN_OBTENER_COMPROBANTE`, `FN_COBRAR_CUOTA`, `V_TALONARIOS_DISPONIBLES`),
  `F9` (cobro), `F11`/`F14`/`F15` (fecha de movimiento de caja + caja del día),
  `F16` (fecha CxC), `F17` (`FEC_CIERRE`), `F17_1`/`F18_2` ("Generado el").
- **APEX:** `apex-work/f100/install_p67.sql` (P67) y
  `apex-work/f100/install_p_tz.sql` (P15, P52, P72, P104, P106, P109, P112).

**Se dejó deliberadamente en UTC:** los timestamps de auditoría puros y los
tokens de `PKG_EMPLEADOS`.
