ArmasVipSkins = ArmasVipSkins or {}

ArmasVipSkins.Default = 'default'

-- Runtime skins replace the selected GTA weapon diffuse texture on the local client.
-- This avoids custom weapon models/Blender for compatible vanilla weapons.
ArmasVipSkins.Catalog = {
    { id = 'default', labelKey = 'skin_default', descriptionKey = 'skin_default_desc', rarity = 'common', animated = false, weapons = '*', source = { type = 'none' } },
    { id = 'carbon', labelKey = 'skin_carbon', descriptionKey = 'skin_carbon_desc', rarity = 'common', animated = false, weapons = '*', source = { type = 'procedural', preset = 'carbon' } },
    { id = 'gold', labelKey = 'skin_gold', descriptionKey = 'skin_gold_desc', rarity = 'rare', animated = false, weapons = '*', source = { type = 'procedural', preset = 'gold' } },
    { id = 'obsidian', labelKey = 'skin_obsidian', descriptionKey = 'skin_obsidian_desc', rarity = 'rare', animated = false, weapons = '*', source = { type = 'procedural', preset = 'obsidian' } },
    { id = 'arctic', labelKey = 'skin_arctic', descriptionKey = 'skin_arctic_desc', rarity = 'rare', animated = false, weapons = '*', source = { type = 'procedural', preset = 'arctic' } },
    { id = 'crimson', labelKey = 'skin_crimson', descriptionKey = 'skin_crimson_desc', rarity = 'epic', animated = false, weapons = '*', source = { type = 'procedural', preset = 'crimson' } },
    { id = 'toxic', labelKey = 'skin_toxic', descriptionKey = 'skin_toxic_desc', rarity = 'epic', animated = false, weapons = '*', source = { type = 'procedural', preset = 'toxic' } },
    { id = 'galaxy', labelKey = 'skin_galaxy', descriptionKey = 'skin_galaxy_desc', rarity = 'legendary', animated = true, weapons = '*', source = { type = 'procedural', preset = 'galaxy' } },
    { id = 'inferno', labelKey = 'skin_inferno', descriptionKey = 'skin_inferno_desc', rarity = 'epic', animated = true, weapons = '*', source = { type = 'procedural', preset = 'inferno' } },
    { id = 'electric', labelKey = 'skin_electric', descriptionKey = 'skin_electric_desc', rarity = 'epic', animated = true, weapons = '*', source = { type = 'procedural', preset = 'electric' } },
    { id = 'aurora', labelKey = 'skin_aurora', descriptionKey = 'skin_aurora_desc', rarity = 'legendary', animated = true, weapons = '*', source = { type = 'procedural', preset = 'aurora' } },
    { id = 'plasma', labelKey = 'skin_plasma', descriptionKey = 'skin_plasma_desc', rarity = 'legendary', animated = true, weapons = '*', source = { type = 'procedural', preset = 'plasma' } },
    { id = 'matrix', labelKey = 'skin_matrix', descriptionKey = 'skin_matrix_desc', rarity = 'epic', animated = true, weapons = '*', source = { type = 'procedural', preset = 'matrix' } },
    { id = 'bloodmoon', labelKey = 'skin_bloodmoon', descriptionKey = 'skin_bloodmoon_desc', rarity = 'legendary', animated = true, weapons = '*', source = { type = 'procedural', preset = 'bloodmoon' } },
}

-- Vanilla GTA texture dictionary + diffuse texture mappings.
-- Custom weapons can be added here without changing the skin engine.
ArmasVipSkins.Textures = {
    WEAPON_PISTOL = { ytd = 'w_pi_pistol', texture = 'w_pi_pistol' },
    WEAPON_PISTOL_MK2 = { ytd = 'w_pi_pistolmk2', texture = 'w_pi_pistolmk2' },
    WEAPON_COMBATPISTOL = { ytd = 'w_pi_combatpistol', texture = 'w_pi_combatpistol' },
    WEAPON_PISTOL50 = { ytd = 'w_pi_pistol50', texture = 'w_pl_pistol50' },
    WEAPON_SNSPISTOL = { ytd = 'w_pi_sns_pistol', texture = 'w_pi_sns_pistol' },
    WEAPON_HEAVYPISTOL = { ytd = 'w_pi_heavypistol', texture = 'w_pi_heavypistol' },
    WEAPON_VINTAGEPISTOL = { ytd = 'w_pi_vintage_pistol', texture = 'w_pi_vintage_pistol' },
    WEAPON_MARKSMANPISTOL = { ytd = 'w_pi_singleshot', texture = 'w_pi_singleshot_dm' },
    WEAPON_REVOLVER = { ytd = 'w_pi_revolver', texture = 'w_pi_revolver' },
    WEAPON_STUNGUN = { ytd = 'w_pi_stungun', texture = 'w_pi_stungun' },
    WEAPON_APPISTOL = { ytd = 'w_pi_appistol', texture = 'w_pi_appistol' },

    WEAPON_MICROSMG = { ytd = 'w_sb_microsmg', texture = 'w_sb_microsmg' },
    WEAPON_MACHINEPISTOL = { ytd = 'w_sb_compactsmg', texture = 'w_sb_compactsmg' },
    WEAPON_SMG = { ytd = 'w_sb_smg', texture = 'w_sb_smg' },
    WEAPON_SMG_MK2 = { ytd = 'w_sb_smgmk2', texture = 'w_sb_smgmk2' },
    WEAPON_ASSAULTSMG = { ytd = 'w_sb_assaultsmg', texture = 'w_sb_assaultsmg' },
    WEAPON_COMBATPDW = { ytd = 'w_sb_pdw', texture = 'w_sb_pdw' },
    WEAPON_MG = { ytd = 'w_mg_mg', texture = 'w_mg_mg' },
    WEAPON_COMBATMG = { ytd = 'w_mg_combatmg', texture = 'w_mg_combatmg_tint' },
    WEAPON_COMBATMG_MK2 = { ytd = 'w_mg_combatmgmk2', texture = 'w_mg_combatmgmk2_l1' },
    WEAPON_GUSENBERG = { ytd = 'w_sb_gusenberg', texture = 'w_sb_gusenberg' },
    WEAPON_MINISMG = { ytd = 'w_sb_minismg', texture = 'w_sb_minismg_dm' },

    WEAPON_ADVANCEDRIFLE = { ytd = 'w_ar_advancedrifle', texture = 'w_ar_advancedrifle' },
    WEAPON_ASSAULTRIFLE = { ytd = 'w_ar_assaultrifle', texture = 'w_ar_assaultrifle' },
    WEAPON_ASSAULTRIFLE_MK2 = { ytd = 'w_ar_assaultriflemk2', texture = 'w_ar_assaultriflemk2' },
    WEAPON_CARBINERIFLE = { ytd = 'w_ar_carbinerifle', texture = 'w_ar_carbinerifle' },
    WEAPON_CARBINERIFLE_MK2 = { ytd = 'w_ar_carbineriflemk2', texture = 'w_ar_carbineriflemk2' },
    WEAPON_SPECIALCARBINE = { ytd = 'w_ar_specialcarbine', texture = 'w_ar_specialcarbine_tint' },
    WEAPON_BULLPUPRIFLE = { ytd = 'w_ar_bullpuprifle', texture = 'w_ar_bullpuprifle' },
    WEAPON_COMPACTRIFLE = { ytd = 'w_ar_assaultrifle_smg', texture = 'w_ar_assaultrifle_smg_d' },

    WEAPON_SNIPERRIFLE = { ytd = 'w_sr_sniperrifle', texture = 'w_sr_sniperrifle' },
    WEAPON_HEAVYSNIPER = { ytd = 'w_sr_heavysniper', texture = 'w_sr_heavysniper' },
    WEAPON_HEAVYSNIPER_MK2 = { ytd = 'w_sr_heavysnipermk2', texture = 'w_sr_heavysnipermk2' },
    WEAPON_MARKSMANRIFLE = { ytd = 'w_sr_marksmanrifle', texture = 'w_sr_marksmanrifle' },

    WEAPON_PUMPSHOTGUN = { ytd = 'w_sg_pumpshotgun', texture = 'w_sg_pumpshotgun' },
    WEAPON_SAWNOFFSHOTGUN = { ytd = 'w_sg_sawnoff', texture = 'w_sg_sawnoff' },
    WEAPON_BULLPUPSHOTGUN = { ytd = 'w_sg_bullpupshotgun', texture = 'w_sg_bullpupshotgun' },
    WEAPON_ASSAULTSHOTGUN = { ytd = 'w_sg_assaultshotgun', texture = 'w_sg_assaultshotgun' },
    WEAPON_DBSHOTGUN = { ytd = 'w_sg_doublebarrel', texture = 'w_sg_doublebarrel_dm' },
}

local byId = {}
for _, skin in ipairs(ArmasVipSkins.Catalog) do byId[skin.id] = skin end

function ArmasVipSkins.Get(id)
    return type(id) == 'string' and byId[id] or nil
end

function ArmasVipSkins.GetTexture(weaponName)
    return type(weaponName) == 'string' and ArmasVipSkins.Textures[weaponName:upper()] or nil
end

function ArmasVipSkins.IsCompatible(weaponName, skinId)
    local skin = ArmasVipSkins.Get(skinId)
    if not skin or not ArmasVipSkins.GetTexture(weaponName) then return false end
    if skin.weapons == '*' then return true end
    if type(skin.weapons) ~= 'table' then return false end

    local normalized = tostring(weaponName):upper()
    for _, allowed in ipairs(skin.weapons) do
        if tostring(allowed):upper() == normalized then return true end
    end
    return false
end

-- Expose support to the NUI weapon catalog so unsupported/custom weapons do not
-- advertise runtime skins that the engine cannot actually apply.
if ArmasVipData and type(ArmasVipData.weapons) == 'table' then
    for _, weapon in ipairs(ArmasVipData.weapons) do
        weapon.skinSupported = ArmasVipSkins.GetTexture(weapon.name) ~= nil
    end
end
