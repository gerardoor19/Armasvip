# Uso

## Dueño / administrador

El propietario del servidor concede el ACE `armasvip.admin` desde `server.cfg`.

El administrador usa `/armasvip`.

Flujo:

1. Selecciona categoría y arma.
2. Selecciona accesorios iniciales.
3. Selecciona el tinte/camo inicial.
4. Pulsa `ASIGNAR ARMA VIP`.
5. Selecciona jugador conectado y duración.
6. El servidor valida los datos, guarda la propiedad y trata de entregar la instancia inmediatamente.

Si el inventario está lleno, la propiedad permanece guardada y el jugador puede retirarla más tarde.

## Jugador

El jugador usa `/misarmasvip`.

Si no posee grants activos, el servidor no abre el arsenal.

Desde el arsenal puede:

- ver sus armas VIP;
- comprobar si la instancia está en inventario;
- retirar una instancia si no la tiene;
- ver accesorios actualmente instalados;
- cambiar entre camos/tintes desbloqueados.

## Accesorios

Los accesorios seleccionados por el admin se instalan en la primera entrega. Después son físicos: si el jugador los quita, pierde o se los roban, ArmasVIP no los regenera al recuperar el arma.

## Propiedad

La propiedad es el grant SQL, no el item físico. Perder la instancia física no elimina el derecho a recuperar la VIP mientras el grant siga activo.
