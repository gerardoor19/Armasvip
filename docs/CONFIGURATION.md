# Configuración

La configuración pública del paquete 2.2.0 está en `config/config.lua`.

## Permisos

```lua
Config.Permissions = {
    AdminAce = 'armasvip.admin',
    AllowConsole = true,
}
```

`AdminAce` es el permiso que abre el panel administrativo. La asignación real vuelve a comprobar el mismo ACE en servidor.

## Identidad

```lua
Config.Identity = {
    Provider = 'auto',
}
```

Valores disponibles:

- `auto`
- `qbox`
- `qbcore`
- `esx`
- `license`

En servidores con personajes, se recomienda usar el framework real para que la propiedad quede asociada al personaje correcto.

## Grants

`AllowDuplicateWeaponGrants = false` evita dos grants activos del mismo `WEAPON_*` para el mismo propietario.

`DurationOptions` controla las duraciones visibles para el admin. `days = 0` significa permanente.

## Transferencias

`ProtectTransfers = true` cancela mediante `ox_inventory` los movimientos normales de una instancia VIP hacia otro jugador, drop, stash, trunk, glovebox u otro inventario.

No modifica las armas normales del mismo nombre.

## Durabilidad

`InfiniteDurability = true` mantiene en 100 únicamente las instancias cuya metadata pertenece a un grant VIP válido.

## Munición

`VipChamberAmmo` es la munición inicial de la instancia recuperada.

`VipReserveAmmoOnEquip = 0` evita utilizar el arsenal personal para farmear cajas de munición.

## Rate limits

`Config.Security.RateLimits` limita la frecuencia de callbacks sensibles. No es la seguridad principal; la seguridad real sigue siendo la validación server-side.
