# Instalación

## Requisitos

ArmasVIP requiere:

1. `oxmysql`
2. `ox_lib`
3. `ox_inventory`

El framework es opcional. La identidad se detecta en este orden cuando `Config.Identity.Provider = 'auto'`:

1. `qbx_core`
2. `qb-core`
3. `es_extended`
4. Rockstar license

## Orden recomendado en server.cfg

```cfg
ensure oxmysql
ensure ox_lib
# inicia aquí tu framework si aplica
ensure ox_inventory
ensure armasvip
```

## Permiso del dueño/admin

ArmasVIP no tiene una lista interna de administradores. FiveM ACE es la autoridad.

```cfg
add_ace group.armasvip armasvip.admin allow
add_principal identifier.license:TU_LICENSE group.armasvip
```

También puedes conceder el ACE a un grupo que ya administres:

```cfg
add_ace group.admin armasvip.admin allow
```

No concedas `armasvip.admin` a grupos de usuarios normales.

## Base de datos

El recurso intenta crear/migrar sus tablas al iniciar mediante `oxmysql`. Si prefieres instalación manual, ejecuta `sql/install.sql` desde el paquete oficial protegido.

Tablas utilizadas por la versión 2.2.0:

- `armasvip_grants`
- `armasvip_cosmetics`

## Primera prueba

1. Reinicia `armasvip`.
2. Confirma en consola que cargó los grants activos.
3. Entra con una cuenta que tenga el ACE.
4. Ejecuta `/armasvip`.
5. Asigna un arma a un jugador conectado.
6. Verifica que se entregue inmediatamente.
7. Con ese jugador ejecuta `/misarmasvip`.
8. Verifica que una segunda retirada no duplique el mismo grant.
