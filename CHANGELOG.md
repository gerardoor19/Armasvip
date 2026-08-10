# Changelog

## 2.2.0

- Endurecimiento para release pública.
- ACE administrativo renombrado a `armasvip.admin`.
- El propietario del servidor controla completamente quién recibe acceso admin desde `server.cfg`.
- Eliminado callback legacy de entrega directa.
- Eliminado evento de cleanup invocable por cliente.
- `/misarmasvip` ya no abre si la identidad no tiene grants activos.
- Rate-limit en callbacks sensibles.
- Rechazo temprano de `grantId` ajenos antes de SQL.
- Grants duplicados del mismo arma bloqueados por defecto.
- Auditoría básica de acciones administrativas/denegadas en consola.
- Preparación `escrow_ignore` para Asset Escrow.
- Paquete de documentación completo para instalación, uso, seguridad y publicación.
- Limpieza de archivos de auditoría/desarrollo de versiones anteriores.
