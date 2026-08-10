# Seguridad

## Principio principal

ArmasVIP es server-authoritative. El cliente se considera manipulable. Ninguna acción sensible confía en valores del cliente sin revalidarlos en servidor.

## Panel administrativo

Abrir `/armasvip` requiere el ACE configurado en `Config.Permissions.AdminAce`. Los callbacks administrativos vuelven a comprobar el ACE. Forzar la NUI desde un executor no concede permisos.

## Usuario sin arma VIP

`/misarmasvip` comprueba en servidor si la identidad tiene un grant activo antes de abrir el menú.

Incluso si un usuario fuerza la NUI o llama callbacks manualmente:

- `equipGrant` recibe solo un `grantId`;
- el servidor obtiene la identidad desde `source`;
- comprueba que el grant activo pertenece a esa identidad;
- revalida en SQL antes de crear el item;
- valida el arma contra el dataset del recurso;
- evita una segunda instancia del mismo grant.

Un ID de grant inventado o perteneciente a otra persona no entrega nada.

## Camos

El cliente solo solicita `grantId + tint`. El servidor verifica propietario, grant activo, índice permitido y desbloqueo real en `armasvip_cosmetics`/cache.

## Accesorios

Los componentes recibidos desde el panel admin se filtran contra los componentes compatibles definidos para esa arma. Los accesorios no son un derecho regenerable después de la primera entrega.

## Transferencias

La instancia VIP lleva metadata propia, entre ella:

- `armasvip = true`
- `vipGrantId`
- `vipOwner`

El hook `swapItems` de `ox_inventory` cancela transferencias normales fuera del inventario propietario. Un arma normal con el mismo `WEAPON_*` no contiene esa metadata y no queda protegida por ArmasVIP.

## Durabilidad

La reparación server-side valida metadata VIP, grant esperado, propietario, arma correspondiente y rate limit. No puede utilizarse el evento de reparación para reparar un arma normal.

## Anti-spam

Los callbacks de administración, estado, retirada y tintes tienen rate limit por jugador. Una petición de retirada con un `grantId` ajeno se rechaza antes de la revalidación SQL.

## Límites de seguridad

ArmasVIP no puede corregir vulnerabilidades de otros recursos. Si otro script inseguro permite a un cliente ejecutar arbitrariamente `AddItem`, `RemoveItem`, modificar SQL o ejecutar código server-side, debe corregirse ese recurso.

La propiedad SQL de ArmasVIP sigue siendo independiente de la existencia momentánea del item físico.
