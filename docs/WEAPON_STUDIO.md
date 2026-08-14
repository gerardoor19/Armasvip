# Weapon Studio

Weapon Studio is the ArmasVIP 2.4 cosmetic layer for persistent VIP weapons. It is designed to provide selectable static and animated skins without requiring custom weapon models or Blender for the bundled presets.

## How it works

ArmasVIP keeps the cosmetic choice server-authoritative while rendering the selected skin locally:

1. `/misarmasvip` loads the player's persistent grants.
2. Weapon Studio requests the skin catalog and the unlock state for each grant.
3. The player previews a skin in the NUI.
4. On Equip, the server verifies the grant owner, skin ID, weapon compatibility and unlock state.
5. The selected `skin_id` is persisted in `armasvip_skin_state`.
6. When that VIP weapon becomes the current `ox_inventory` weapon, the client asks the server for the selected skin and applies it through a FiveM DUI/runtime texture.

The NUI never decides ownership or unlocks.

## Bundled skins

The resource contains a local procedural renderer at `web/public/skin-renderer.html`. Vite copies it to the production NUI bundle. No external image URL is required.

- `default` — original GTA texture
- `carbon` — static carbon pattern
- `gold` — static metallic gold pattern
- `galaxy` — animated nebula/stars
- `inferno` — animated fire
- `electric` — animated electric arcs

The skin catalog is in `shared/skins.lua`.

## Compatible weapons

Runtime replacement needs the original GTA texture dictionary (`ytd`) and diffuse texture name. The built-in mapping in `shared/skins.lua` covers a curated set of vanilla pistols, SMGs/LMGs, rifles, sniper rifles and shotguns.

If a weapon has no mapping, Weapon Studio reports it as unsupported instead of attempting an unsafe replacement.

Custom weapons can be supported by adding their texture mapping:

```lua
ArmasVipSkins.Textures.WEAPON_MY_CUSTOM = {
    ytd = 'my_weapon_txd',
    texture = 'my_weapon_diffuse',
}
```

No model edit is required when the custom weapon already exposes a replaceable diffuse texture.

## Adding a local PNG/GIF/WebP skin

The engine also accepts local assets. Add the file to the production NUI files and define a catalog entry:

```lua
{
    id = 'my_skin',
    labelKey = 'skin_my_skin',
    descriptionKey = 'skin_my_skin_desc',
    rarity = 'epic',
    animated = true,
    weapons = { 'WEAPON_PISTOL' },
    source = {
        type = 'asset',
        path = 'skins/my_skin.gif',
    },
}
```

For repository development, place source assets under `web/public/skins/`; Vite copies them to `web/dist/skins/`.

## External URLs

External skin URLs are disabled by default:

```lua
Config.Skins.AllowExternalUrls = false
```

Local assets are preferred because they are reproducible, do not depend on third-party hosting and avoid privacy/tracking surprises.

## Persistence

Unlocks use the existing `armasvip_cosmetics` table with `cosmetic_type = 'skin'`. The selected skin is stored in:

```text
armasvip_skin_state
- grant_id
- skin_id
- updated_at
```

The selection belongs to the VIP grant, not globally to `WEAPON_PISTOL`.

## Administration

`/armasvipskins` requires the same `armasvip.admin` ACE used by the rest of the administrative system. It allows staff to unlock or remove compatible skins for each active VIP grant.

`Config.Skins.DefaultUnlocked` controls skins automatically available for all compatible grants.

## Weapon inspect

`/vipinspect` plays the configured GTA fidget animation only while a valid VIP weapon is equipped. The default key mapping is `I`.

```lua
Config.Skins.Inspect = {
    Enabled = true,
    Command = 'vipinspect',
    Key = 'I',
    Dict = 'shared@fidgets',
    Clip = 'fidget_med_loop',
    Duration = 2600,
    Flag = 49,
}
```

The animation cancels when the player fires, aims or unequips the VIP weapon.

## Important rendering limitation

FiveM's `AddReplaceTexture` operates on texture names in the local client. It is not an entity-instance material override API. ArmasVIP therefore guarantees persistence and correct rendering for the local player's selected VIP skin, but it does **not** claim that two remote players using the same GTA weapon texture can always display two different runtime replacements to a third client simultaneously.

A future fully per-instance remote-visible skin system would require streamed component/model variants or another entity-specific rendering strategy. This limitation does not affect VIP ownership, SQL persistence, security or the normal local Weapon Studio experience.
