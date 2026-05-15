# Shared Components — App 100 SolSGE

## Autenticación
| Nombre | Tipo | Detalle |
|--------|------|---------|
| Custom_login | NATIVE_CUSTOM | `AUT_PKG.AUTENTICACION_LOGIN` |
| Oracle APEX Accounts | NATIVE_APEX_ACCOUNTS | (secundario, no activo) |

## Autorización
| Nombre | Tipo | Expresión |
|--------|------|-----------|
| AUTH_PAGE_BY_PRIV | NATIVE_FUNCTION_BODY | `RETURN security_pkg.can_access(:APP_ID, :APP_USER, :APP_PAGE_ID, NULL);` |
| Administration Rights | NATIVE_IS_IN_GROUP | Rol Administrator (APEX ACL) |
| Contribution Rights | NATIVE_IS_IN_GROUP | Rol Contributor |
| Reader Rights | NATIVE_IS_IN_GROUP | Rol Reader |

## Build Options
| Nombre | Estado |
|--------|--------|
| Feature: Access Control | INCLUDE |
| Commented Out | EXCLUDE |

## Plugins instalados
| Tipo | Nombre |
|------|--------|
| Dynamic Action | APEX Notification |
| Dynamic Action | BBE Sweet Alert |
| Dynamic Action | Print Region to PDF v2.0 |
| Region Type | Orclking Bootstrap Carousel Extension |
| Template Component | Kebe Dashboard |
| Template Component | Multi Purpose Card |
| Template Component | Theme 42 Kebe Dashboard |

## Navegación — Menú principal

```
Home (p1)
├── Personas (p9,10,16,20)
│   ├── Personas (p9)
│   ├── Empleados IG (p16)
│   └── Empleados Roles (p11)
├── Clientes (p19,20)
│   ├── Clientes (p4)
│   ├── Oficinas (p21,22)
│   ├── Departamentos (p23,24)
│   ├── Ciudades (p26,27)
│   └── PRUEBA C IG (p28,29) [dev]
├── Ventas (p30,31)
│   ├── Proceso Ventas (p66,67)
│   ├── Orden de Venta (p52)
│   ├── Reservas de Productos (p59)
│   └── Reporte Orden (p58)
├── Proveedores (p41,42)
│   ├── Contactos (p43,44)
│   └── Nota de Credito Proveedor (p94)
├── Productos
│   ├── Productos (p5)
│   ├── Precio por Categoria (p8)
│   ├── Producto Proveedor (p25)
│   ├── Marcas (p37)
│   └── Categoria (p40)
├── Inventarios
│   ├── Ajuste Manual de Stock (p32)
│   ├── Stock de Productos (p47)
│   ├── Proceso de Inventario (p79)
│   ├── Conteo Fisico (p73,74)
│   ├── Revision (p80,85)
│   ├── Reporte Inventario (p55)
│   ├── Movimiento de Stock (p56)
│   └── Existencias (p88)
├── Caja
│   ├── Configuracion de Cajas (p63,64)
│   ├── Apertura de Caja (p65)
│   └── Cierre de Caja (p61)
├── Compras
│   ├── Proceso de Compras (p69,70)
│   ├── Orden de Compra (p71,72)
│   ├── Recepción de Orden de Compra (p107/106)
│   └── Aprobación de Órdenes de Compra (p110)
├── Cobros (p93)
│   └── Cobros (p95,98)
├── Administration (p10000)
│   ├── Roles (p13,14)
│   ├── Monedas (p17,18)
│   ├── Planes Cuota (p38,49)
│   ├── Talonarios (p51,53)
│   ├── Metodos de Pago (p57,60)
│   ├── Formas de Pago (p89,90)
│   ├── Cotizacion (p101)
│   └── Parámetros (p103,105)
└── Seguridad
    ├── Privilegios (p75,76)
    ├── Roles - Privilegios (p81)
    └── Recursos (p77,78)
```

## LOVs principales

| LOV Name | Fuente | Notas |
|----------|--------|-------|
| PROVEEDORES.NOMBRE | JOIN PROVEEDORES+PERSONAS | primer_nombre+primer_apellido |
| OFICINAS.DESCRIPCION | OFICINAS | — |
| PRODUCTOS.NOMBRE | PRODUCTOS | — |
| PRODUCTOS.PROVEEDOR.PRECIO | V_PRODUCTO_PROVEEDOR_VIGENTE + V_COMPARATIVA_PRECIO_PROVEEDORES | Popup LOV multicolumna: Producto, Proveedor, Precio, PrecioMin, Diferencia |
| CATEGORIAS_PRODUCTOS.NOMBRE | CATEGORIAS_PRODUCTOS | — |
| EMPLEADOS.NOMBRE | EMPLEADOS+PERSONAS | — |
| EMPLEADOS.CODIGO_USUARIO | EMPLEADOS | — |
| CLIENTES.CODIGO_USUARIO | CLIENTES+PERSONAS | — |
| MONEDA.DESCRIPCION | MONEDAS | — |
| MARCAS.NOMBRE | MARCAS | — |
| ROLES.DESCRIPCION | ROLES | — |
| PRIVILEGIOS | PRIVILEGIOS | — |
| PRIVILEGIOS.CODIGO | PRIVILEGIOS | — |
| TALONARIOS.TIPO_COMPROBANTE | TALONARIOS | — |
| DOCUMENTOS.DESCRIPCION | DOCUMENTOS | — |
| PERSONAS.TIPO_PERSONAS | ref dinámica | — |
| GENERO.PERSONAS | ref dinámica | — |
| PERSONAS.ESTADO_CIVIL | ref dinámica | — |
| CUENTAS_COBRAR.ESTADO | CUENTAS_COBRAR | — |
| ORDEN_COMPRA.ESTADO | ORDENES_COMPRA | — |
| ORDENES_VENTA.ESTADO | ORDENES_VENTA | — |
| NRO_DOCUMENTO.NO_CLIENTE | PERSONAS left join CLIENTES | Personas sin cuenta cliente |
| NRO_DOCUMENTO.NO_EMPLEADO | PERSONAS left join EMPLEADOS | Personas sin cuenta empleado |
| PERSONA.NOMBRE | PERSONAS | primer+segundo nombre/apellido |
| LOV_PERSONAS_CLIENTES | PERSONAS+CLIENTES | — |
| DEPARTAMENTOS.DESCRIPCION (x2) | DEPARTAMENTOS | 2 versiones |
| CIUDADES.DESCRIPCION | CIUDADES | — |
| PAISES.DESCRIPCION | PAISES | — |
| CAJA_CONF.DESCRIPCION | CAJA_CONF | — |
| PLANES_CUOTA | PLANES_CUOTA | — |
| COMPROBANTES.NRO_COMPROBANTE | COMPROBANTES | — |
| COMPONENTES | (sistema) | — |
| PAGINAS | (sistema) | — |
| ACCESS_ROLES | (ACL) | — |
| EMAIL_USERNAME_FORMAT | (static) | — |
