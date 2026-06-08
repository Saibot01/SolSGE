# F11 — Guía de implementación APEX (Builder)

> Guía operativa para implementar los Hitos 2-7 de
> [PLAN_ANULACION_FACTURAS.md](PLAN_ANULACION_FACTURAS.md). Asume Hito 1 (BD)
> aplicado: las procedures `PRC_SOLICITAR_ANULACION`, `PRC_APROBAR_ANULACION`,
> `PRC_RECHAZAR_ANULACION` y la vista `V_ANULACIONES_FACTURAS` ya existen.
>
> **Workflow para cada hito**:
> 1. Entrar a APEX Builder de la app 100 con usuario admin.
> 2. Seguir los pasos de la sección correspondiente.
> 3. Probar la página/cambio en el browser.
> 4. Re-exportar con la skill `apex-export` o vía `apex export -split`.
> 5. Agregar entry al `apex-work/f100/install_page.sql`.
> 6. Avisarme y commiteo.

---

## Hito 2 — P122 Modal "Solicitar Anulación"

### 2.1 Crear página

- **Page Number**: `122`
- **Name**: `Solicitar Anulación`
- **Page Mode**: `Modal Dialog`
- **Page Group**: `Facturacion`
- **Breadcrumb**: ninguno (modal).
- **HTTP Cache**: NO.

### 2.2 Items de página

Crear región principal **"Solicitud"** tipo `Static Content`. Adentro, agregar items:

| Item | Tipo | Source | Display | Notas |
|------|------|--------|---------|-------|
| `P122_ID_COMPROBANTE` | Hidden | Item value | — | PK que entra por URL. Protected. |
| `P122_NRO_COMPROBANTE` | Display Only | SQL Query (1 col) | `Nº Factura` | `SELECT NRO_COMPROBANTE FROM COMPROBANTES WHERE ID_COMPROBANTE = :P122_ID_COMPROBANTE` |
| `P122_FECHA` | Display Only | SQL Query | `Fecha` | `SELECT TO_CHAR(FECHA,'DD/MM/YYYY') FROM COMPROBANTES WHERE ID_COMPROBANTE = :P122_ID_COMPROBANTE` |
| `P122_TOTAL` | Display Only | SQL Query | `Total` | `SELECT TO_CHAR(TOTAL_MONEDA_LOCAL,'FM999G999G999G990')\|\|' '\|\|MONEDA FROM COMPROBANTES WHERE ID_COMPROBANTE = :P122_ID_COMPROBANTE` |
| `P122_CLIENTE` | Display Only | SQL Query | `Cliente` | `SELECT TRIM(p.PRIMER_NOMBRE\|\|' '\|\|p.PRIMER_APELLIDO) FROM COMPROBANTES c JOIN PERSONAS p ON p.ID_PERSONA = c.ID_CLIENTE WHERE c.ID_COMPROBANTE = :P122_ID_COMPROBANTE` |
| `P122_FORMA_PAGO` | Display Only | SQL Query | `Forma de Pago` | `SELECT CASE FORMA_PAGO WHEN '1' THEN 'Crédito' ELSE 'Contado' END FROM COMPROBANTES WHERE ID_COMPROBANTE = :P122_ID_COMPROBANTE` |
| `P122_MOTIVO` | Textarea | Always, null | `Motivo de anulación *` | Width 60, Height 5. **Required**. Help text: "Mínimo 10 caracteres. Explicá por qué se anula la factura." |

### 2.3 Validación BEFORE_HEADER (PL/SQL)

**Name**: `Pre-check: factura activa + ventana + cuotas`
**Type**: PL/SQL Code
**Execution Point**: Before Header

```plsql
DECLARE
  v_estado    COMPROBANTES.ESTADO%TYPE;
  v_fecha     COMPROBANTES.FECHA%TYPE;
  v_fp        COMPROBANTES.FORMA_PAGO%TYPE;
  v_nro       COMPROBANTES.NRO_COMPROBANTE%TYPE;
  v_cuotas    PLS_INTEGER;
BEGIN
  SELECT ESTADO, FECHA, FORMA_PAGO, NRO_COMPROBANTE
    INTO v_estado, v_fecha, v_fp, v_nro
    FROM COMPROBANTES WHERE ID_COMPROBANTE = :P122_ID_COMPROBANTE;

  IF v_estado <> 'A' THEN
    apex_error.add_error(
      p_message => 'La factura '||v_nro||' no está activa (estado '||v_estado||').',
      p_display_location => apex_error.c_inline_in_notification);
    apex_util.redirect_url('f?p=&APP_ID.:66:&SESSION.');
  END IF;

  IF TRUNC(v_fecha,'MM') <> TRUNC(SYSDATE,'MM') THEN
    apex_error.add_error(
      p_message => 'Fuera de ventana: la factura es del mes '
                   ||TO_CHAR(v_fecha,'MM/YYYY')||'. Solo se puede anular dentro del mismo mes calendario.',
      p_display_location => apex_error.c_inline_in_notification);
    apex_util.redirect_url('f?p=&APP_ID.:66:&SESSION.');
  END IF;

  IF v_fp = '1' THEN
    SELECT COUNT(*) INTO v_cuotas
      FROM CUENTAS_COBRAR     cxc
      JOIN CUENTAS_COBRAR_DET ccd ON ccd.ID_CXC = cxc.ID_CXC
     WHERE cxc.ID_COMPROBANTE = :P122_ID_COMPROBANTE
       AND ccd.ESTADO = 'PAGADA';
    IF v_cuotas > 0 THEN
      apex_error.add_error(
        p_message => 'No se puede anular: hay '||v_cuotas||' cuota(s) cobrada(s). Reversá los cobros primero.',
        p_display_location => apex_error.c_inline_in_notification);
      apex_util.redirect_url('f?p=&APP_ID.:66:&SESSION.');
    END IF;
  END IF;
END;
```

### 2.4 Botones

| Botón | Position | Action | Request |
|-------|----------|--------|---------|
| **Solicitar Anulación** | Region Body / Hot | Submit Page | `SOLICITAR` |
| **Cancelar** | Region Body | Defined by Dynamic Action | — |

Dynamic Action en "Cancelar": **Cancel Dialog** (close without saving).

### 2.5 Validación de motivo

**Name**: `Motivo ≥ 10 chars`
**Type**: PL/SQL Function (returning Error Text)
**Code**:

```plsql
RETURN CASE
  WHEN :P122_MOTIVO IS NULL OR LENGTH(TRIM(:P122_MOTIVO)) < 10
    THEN 'El motivo debe tener al menos 10 caracteres.'
  ELSE NULL
END;
```

**Condition**: Request = `SOLICITAR`.

### 2.6 Proceso AFTER_SUBMIT

**Name**: `Solicitar anulación`
**Type**: PL/SQL Code
**Sequence**: 10
**Condition**: Request = `SOLICITAR`

```plsql
BEGIN
  PRC_SOLICITAR_ANULACION(
    p_id_comprobante => :P122_ID_COMPROBANTE,
    p_motivo         => :P122_MOTIVO,
    p_usuario        => :APP_USER
  );
END;
```

**Success message**: `Solicitud de anulación registrada. La factura quedó pendiente de aprobación.`

### 2.7 Proceso "Close Dialog"

**Sequence**: 90
**Type**: Close Dialog
**Condition**: Request = `SOLICITAR` y sin error.

---

## Hito 3 — P120 Lista "Anulaciones de Facturas"

### 3.1 Crear página

- **Page Number**: `120`
- **Name**: `Anulaciones de Facturas`
- **Page Mode**: `Normal`
- **Page Group**: `Facturacion`
- **Breadcrumb**: agregar entry "Anulaciones" bajo "Ventas".

### 3.2 Región Interactive Report

- **Type**: Interactive Report
- **Source Type**: SQL Query
- **Source**:

```sql
SELECT
  ID_COMPROBANTE,
  NRO_COMPROBANTE,
  FECHA,
  CLIENTE_NOMBRE,
  TOTAL_MONEDA_LOCAL,
  MONEDA,
  ESTADO,
  CASE ESTADO
    WHEN 'P' THEN '<span class="t-Label t-Label--warning">Pendiente</span>'
    WHEN 'N' THEN '<span class="t-Label t-Label--danger">Anulada</span>'
  END AS ESTADO_BADGE,
  MOTIVO_ANULACION,
  USUARIO_SOLICITA,
  FECHA_SOLICITUD,
  USUARIO_APRUEBA,
  FECHA_RESOLUCION,
  MOTIVO_RECHAZO,
  OFICINA_NOMBRE
FROM V_ANULACIONES_FACTURAS
ORDER BY DECODE(ESTADO,'P',0,1), FECHA_SOLICITUD DESC NULLS LAST, FECHA DESC
```

### 3.3 Columnas

- `ESTADO_BADGE`: cambiar **Type** a `HTML`, ocultar `ESTADO`.
- `ID_COMPROBANTE`: ocultar.
- `FECHA`, `FECHA_SOLICITUD`, `FECHA_RESOLUCION`: formato `DD/MM/YYYY HH24:MI`.
- `TOTAL_MONEDA_LOCAL`: formato `FM999G999G999G990`.

### 3.4 Link "Aprobar/Rechazar" (columna virtual)

Agregar columna **Link** en columna virtual:
- **Target**: Page `121` (Modal)
- **Items to set**: `P121_ID_COMPROBANTE = #ID_COMPROBANTE#`
- **Condition**: Type = "Rows returned" SQL Expression `ESTADO = 'P'`
- **Icon**: `fa-check-square` con tooltip "Resolver".

### 3.5 Link "Ver factura" (columna virtual)

- **Target**: Page `96` (DOCUMENTO-FACTURA modal)
- **Items to set**: `P96_ID_COMPROBANTE = #ID_COMPROBANTE#`
- **Icon**: `fa-print` con tooltip "Ver factura".

### 3.6 Saved Reports / Filtros default

- Crear filtro nombrado **"Pendientes del mes"**: `ESTADO = 'P' AND TRUNC(FECHA,'MM') = TRUNC(SYSDATE,'MM')`.
- Marcarlo como **primary**.

### 3.7 Autorización

Sin nuevo Authorization Scheme (auth APEX estándar). El menú llega vía `security_pkg.can_access`.

---

## Hito 4 — P121 Modal "Aprobación / Rechazo de Anulación"

### 4.1 Crear página

- **Page Number**: `121`
- **Name**: `Detalle Anulación`
- **Page Mode**: `Modal Dialog`
- **Page Group**: `Facturacion`

### 4.2 Items (display only excepto motivo de rechazo)

| Item | Tipo | Source | Display |
|------|------|--------|---------|
| `P121_ID_COMPROBANTE` | Hidden | Item Value | — |
| `P121_NRO_COMPROBANTE` | Display Only | SQL Query | `Nº Factura` |
| `P121_FECHA` | Display Only | SQL Query | `Fecha emisión` |
| `P121_CLIENTE` | Display Only | SQL Query | `Cliente` |
| `P121_TOTAL` | Display Only | SQL Query | `Total` |
| `P121_FORMA_PAGO` | Display Only | SQL Query | `Forma Pago` |
| `P121_USUARIO_SOLICITA` | Display Only | SQL Query | `Solicitante` |
| `P121_FECHA_SOLICITUD` | Display Only | SQL Query | `Fecha solicitud` |
| `P121_MOTIVO_ANULACION` | Display Only | SQL Query | `Motivo solicitado` |
| `P121_MOTIVO_RECHAZO` | Textarea | Always, null | `Motivo de rechazo` (visible solo cuando se rechaza) |

Source SQL para los Display Only (reemplazá `NOMBRE_COLUMNA` por la del item):

```sql
SELECT NOMBRE_COLUMNA FROM V_ANULACIONES_FACTURAS WHERE ID_COMPROBANTE = :P121_ID_COMPROBANTE
```

Para `P121_FORMA_PAGO`: `SELECT CASE FORMA_PAGO WHEN '1' THEN 'Crédito' ELSE 'Contado' END FROM V_ANULACIONES_FACTURAS WHERE ID_COMPROBANTE = :P121_ID_COMPROBANTE`.

### 4.3 Validación BEFORE_HEADER

```plsql
DECLARE
  v_estado COMPROBANTES.ESTADO%TYPE;
BEGIN
  SELECT ESTADO INTO v_estado FROM COMPROBANTES WHERE ID_COMPROBANTE = :P121_ID_COMPROBANTE;
  IF v_estado <> 'P' THEN
    apex_error.add_error(
      p_message => 'Esta factura ya no está pendiente de anulación (estado '||v_estado||').',
      p_display_location => apex_error.c_inline_in_notification);
    apex_util.redirect_url('f?p=&APP_ID.:120:&SESSION.');
  END IF;
END;
```

### 4.4 Botones

| Botón | Hot? | Action | Request |
|-------|------|--------|---------|
| **Aprobar Anulación** | Sí (Green) | Submit Page | `APROBAR` |
| **Rechazar** | Sí (Red) | Submit Page | `RECHAZAR` |
| **Cancelar** | — | Cancel Dialog DA | — |

### 4.5 Validación de motivo de rechazo

**Type**: PL/SQL returning Error Text
**Code**:

```plsql
RETURN CASE
  WHEN :P121_MOTIVO_RECHAZO IS NULL OR LENGTH(TRIM(:P121_MOTIVO_RECHAZO)) < 10
    THEN 'Para rechazar, el motivo debe tener al menos 10 caracteres.'
  ELSE NULL
END;
```

**Condition**: Request = `RECHAZAR`.

### 4.6 Procesos AFTER_SUBMIT

**Aprobar** (sequence 10, cuando `Request = APROBAR`):

```plsql
BEGIN
  PRC_APROBAR_ANULACION(
    p_id_comprobante => :P121_ID_COMPROBANTE,
    p_usuario        => :APP_USER
  );
END;
```

Success: `Factura anulada. Se revirtieron stock, OV y caja.`

**Rechazar** (sequence 20, cuando `Request = RECHAZAR`):

```plsql
BEGIN
  PRC_RECHAZAR_ANULACION(
    p_id_comprobante => :P121_ID_COMPROBANTE,
    p_motivo_rechazo => :P121_MOTIVO_RECHAZO,
    p_usuario        => :APP_USER
  );
END;
```

Success: `Solicitud rechazada. La factura vuelve a estado activo.`

**Close Dialog** (sequence 90, condition Request IN APROBAR,RECHAZAR).

### 4.7 Dynamic Action: visibilidad del motivo de rechazo

- **Event**: Page Load
- **Action**: Hide `P121_MOTIVO_RECHAZO`.

Otro DA:
- **Event**: Click sobre botón "Rechazar" (use Static ID en el botón `RECHAZAR_BTN`).
- **Action**: Show `P121_MOTIVO_RECHAZO` y set focus, **antes** del Submit. Confirm con `confirm('Confirmar rechazo?')`. *Opcional — más simple es dejar el motivo siempre visible.*

> **Más simple y recomendado**: mostrar siempre `P121_MOTIVO_RECHAZO` con help text "Solo requerido si rechazás la solicitud." y dejar que la validación lo exija solo cuando `Request=RECHAZAR`.

---

## Hito 5 — Ajustes a P66 y P67

### 5.1 P66 Lista de Comprobantes

**Cambios al SQL del IR** (Source):

- Agregar columna `ESTADO_BADGE`:

```sql
SELECT
  c.*,
  CASE c.ESTADO
    WHEN 'A' THEN '<span class="t-Label t-Label--success">Activa</span>'
    WHEN 'P' THEN '<span class="t-Label t-Label--warning">Pendiente Anul.</span>'
    WHEN 'N' THEN '<span class="t-Label t-Label--danger">Anulada</span>'
  END AS ESTADO_BADGE
FROM COMPROBANTES c
WHERE …  -- mantener filtros existentes
```

- Columna `ESTADO_BADGE`: Type `HTML`. Ocultar `ESTADO`.

**Agregar columna virtual "Solicitar Anulación"** (link icon):
- Target: Page `122`
- Items to set: `P122_ID_COMPROBANTE = #ID_COMPROBANTE#`
- Icon: `fa-times-circle` con tooltip "Solicitar anulación".
- **Condition**: Type = "Rows returned" SQL `ESTADO = 'A' AND TRUNC(FECHA,'MM') = TRUNC(SYSDATE,'MM')`.

### 5.2 P67 Form de Factura

**Item `P67_ESTADO`**:
- Cambiar **Display As** de `Select List` a `Display Only`.
- Source: derivar texto:

```sql
SELECT CASE ESTADO
         WHEN 'A' THEN 'Activa'
         WHEN 'P' THEN 'Pendiente de anulación'
         WHEN 'N' THEN 'Anulada'
       END FROM COMPROBANTES WHERE ID_COMPROBANTE = :P67_ID_COMPROBANTE
```

- Type: SQL Query (return single value).
- Quitar el LOV legacy `STATIC:Anular;N,Activo;A`.

**Botón `SOLICITAR_ANULACION`** (region body, Hot=No):
- Action: Redirect to Page in this Application
- Target: Page `122` (Modal)
- Items to set: `P122_ID_COMPROBANTE = &P67_ID_COMPROBANTE.`
- **Condition** (Server-Side): Type = PL/SQL Expression:

```plsql
:P67_ID_COMPROBANTE IS NOT NULL
AND :P67_ESTADO IN ('A','Activa')
AND EXISTS (SELECT 1 FROM COMPROBANTES
            WHERE ID_COMPROBANTE = :P67_ID_COMPROBANTE
              AND ESTADO = 'A'
              AND TRUNC(FECHA,'MM') = TRUNC(SYSDATE,'MM'))
```

**Región nueva "Información de Anulación"** (Static Content, sequence después del Detalle):
- Condition: PL/SQL Expression `:P67_ID_COMPROBANTE IS NOT NULL AND EXISTS (SELECT 1 FROM COMPROBANTES WHERE ID_COMPROBANTE=:P67_ID_COMPROBANTE AND ESTADO IN ('P','N'))`.
- Items display only dentro:

| Item | Source SQL |
|------|------------|
| `P67_MOTIVO_ANULACION` | `SELECT MOTIVO_ANULACION FROM COMPROBANTES WHERE ID_COMPROBANTE = :P67_ID_COMPROBANTE` |
| `P67_USUARIO_SOLICITA` | idem |
| `P67_FECHA_SOLICITUD` | idem (formato fecha) |
| `P67_USUARIO_APRUEBA` | idem |
| `P67_FECHA_RESOLUCION` | idem |
| `P67_MOTIVO_RECHAZO` | idem |

---

## Hito 6 — P96 Watermark "ANULADA"

P96 es el documento de factura (modal print). Editar la región Dynamic PL/SQL Content.

### 6.1 Agregar CSS al header (Page Attributes → Inline CSS):

```css
.t-watermark-anulada {
  position: fixed;
  top: 35%;
  left: 15%;
  font-size: 12rem;
  color: rgba(220, 53, 69, 0.18);
  transform: rotate(-25deg);
  z-index: 1000;
  pointer-events: none;
  font-weight: 900;
  letter-spacing: 1rem;
}
.t-anulacion-footer {
  margin-top: 2rem;
  padding: 1rem;
  border-top: 2px solid #dc3545;
  color: #dc3545;
  font-size: 0.9rem;
}
```

### 6.2 En el HTML del documento

En el PL/SQL que genera el HTML del documento de factura, dentro del bloque que lee de COMPROBANTES, agregar:

```plsql
-- al inicio del HTML:
IF v_estado = 'N' THEN
  htp.p('<div class="t-watermark-anulada">ANULADA</div>');
END IF;

-- al final del HTML (después del total / firma):
IF v_estado IN ('P','N') THEN
  htp.p('<div class="t-anulacion-footer">');
  IF v_estado = 'P' THEN
    htp.p('<strong>Solicitud de anulación pendiente</strong><br>');
  ELSE
    htp.p('<strong>FACTURA ANULADA</strong><br>');
  END IF;
  htp.p('Motivo: '||apex_escape.html(v_motivo_anulacion)||'<br>');
  htp.p('Solicitado por: '||apex_escape.html(v_usuario_solicita)
        ||' el '||TO_CHAR(v_fecha_solicitud,'DD/MM/YYYY HH24:MI')||'<br>');
  IF v_estado = 'N' THEN
    htp.p('Aprobado por: '||apex_escape.html(v_usuario_aprueba)
          ||' el '||TO_CHAR(v_fecha_resolucion,'DD/MM/YYYY HH24:MI')||'<br>');
  END IF;
  htp.p('</div>');
END IF;
```

Asumir que el bloque PL/SQL ya tiene un `SELECT ESTADO, MOTIVO_ANULACION, USUARIO_SOLICITA, FECHA_SOLICITUD, USUARIO_APRUEBA, FECHA_RESOLUCION INTO v_estado, …` o agregarlo en el cursor de la cabecera.

---

## Hito 7 — Menú "Anulaciones de Facturas"

> ⚠️ **No usar `@@` para re-importar el menú** (memoria: APEX shared components no-upsert). Editar manualmente en Builder + re-export.

### 7.1 En APEX Builder → Shared Components → Navigation Menu

Agregar entry nuevo:
- **Parent**: `Ventas`
- **List Entry Label**: `Anulaciones de Facturas`
- **Target**: Page `120`
- **Image/Icon**: `fa-ban` (o el que prefieras)
- **Authorization Scheme**: el mismo que usa "Proceso Ventas".
- **Condition Type**: PL/SQL Expression
- **Condition**:

```plsql
security_pkg.can_access(:APP_ID, :APP_USER, 120, NULL) = 'Y'
```

### 7.2 Re-export

Re-exportar el menú con la skill `apex` (export del Navigation Menu) y reemplazar `apex-work/f100/application/shared_components/navigation/lists/navigation_menu.sql`.

**No** agregar al `install_component.sql`. El menú se actualiza directo desde Builder.

---

## Hito 8 — Test plan end-to-end

Ver §7 de [PLAN_ANULACION_FACTURAS.md](PLAN_ANULACION_FACTURAS.md). Casos:

- **A** — Anulación contado feliz (TCASCO solicita → CBARRIOS aprueba).
- **B** — Crédito sin cuotas cobradas (CxC → ANULADA).
- **C** — Crédito con cuota cobrada (bloqueo claro).
- **D** — Fuera de mes (bloqueo).
- **E** — Rechazo.

Para preparar datos: emitir factura contado fresca con golden path F8 (P67),
después seguir el caso A.

---

## Hito 9 — Cierre F11

- [ ] Re-export de P66, P67, P96 + nuevas P120/P121/P122 a `apex-work/f100/application/pages/`.
- [ ] Agregar entries en `apex-work/f100/install_page.sql`:
```sql
prompt --application/pages/page_00120
@@application/pages/page_00120.sql
prompt --application/pages/page_00121
@@application/pages/page_00121.sql
prompt --application/pages/page_00122
@@application/pages/page_00122.sql
```
  Y los `delete_NNNNN.sql` correspondientes **antes** de cada `page_NNNNN.sql`.
- [ ] Commit: `feat(F11): pantallas APEX P120/P121/P122 + ajustes P66/P67/P96`.
- [ ] Tag: `git tag f11-anulacion-facturas`.
- [ ] Actualizar `PLAN_FACTURACION.md` §9 (sacar "Pantalla de anulación de comprobante" con link a `PLAN_ANULACION_FACTURAS.md`).

---

## Apéndice — Referencia rápida de errores de las procedures

| Error code | Procedure | Significado |
|------------|-----------|-------------|
| -20910 | (preflight) | F8 no aplicado: falta MOVIMIENTOS_CAJA |
| -20911 | (preflight) | F9 no aplicado: falta FN_COBRAR_CUOTA |
| -20912 | (preflight) | F8 no aplicado: falta FN_CAJA_ABIERTA_USUARIO |
| -20920 | TRG_OV_VALIDA_REVERSO_FACT | OV no se puede revertir a APROBADO sin factura ANULADA asociada |
| -20930 | PRC_SOLICITAR_ANULACION | Motivo de anulación < 10 chars |
| -20931 | PRC_SOLICITAR_ANULACION | Usuario solicitante NULL |
| -20932 | PRC_SOLICITAR_ANULACION | Factura no está en estado A |
| -20933 | PRC_SOLICITAR_ANULACION | Fuera de ventana mensual |
| -20934 | PRC_SOLICITAR_ANULACION | Hay cuotas cobradas (bloqueo) |
| -20940 | PRC_APROBAR_ANULACION | Usuario aprobador NULL |
| -20941 | PRC_APROBAR_ANULACION | Factura no está en P (pendiente) |
| -20942 | PRC_APROBAR_ANULACION | Fuera de ventana mensual |
| -20943 | PRC_APROBAR_ANULACION | Cuotas cobradas aparecieron desde la solicitud |
| -20944 | PRC_APROBAR_ANULACION | Aprobador sin caja abierta (contado) |
| -20950 | PRC_RECHAZAR_ANULACION | Motivo de rechazo < 10 chars |
| -20951 | PRC_RECHAZAR_ANULACION | Usuario aprobador NULL |
| -20952 | PRC_RECHAZAR_ANULACION | Factura no está pendiente |
