# Solución de problemas

## `/armasvip` dice que no tengo permiso

Comprueba el ACE:

```cfg
add_ace group.armasvip armasvip.admin allow
add_principal identifier.license:TU_LICENSE group.armasvip
```

Reinicia el servidor o vuelve a cargar la configuración ACL.

## `/misarmasvip` no abre

Si el jugador no tiene grants activos, este comportamiento es intencional.

Si debería tenerlos, comprueba:

- proveedor de identidad;
- `owner_key` en SQL;
- estado `active`;
- `expires_at`;
- mensajes `[armasvip]` de consola.

## Error SQL al iniciar

Comprueba que `oxmysql` esté iniciado antes de ArmasVIP y que `mysql_connection_string` sea válido. Puedes importar manualmente `sql/install.sql` desde el paquete oficial.

## El arma no se entrega al asignarla

La propiedad puede haberse guardado aunque la entrega física falle. Revisa espacio/peso del inventario y luego usa `/misarmasvip`.

## Un accesorio perdido no vuelve

Es intencional. Los accesorios solo se regeneran durante la primera entrega del grant.

## Un arma normal también se bloquea

No debería ocurrir. La protección requiere metadata VIP válida; un `WEAPON_*` normal no se bloquea por compartir nombre.
