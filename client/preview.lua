-- Unified arsenal preview callbacks.
-- The NUI preview is rendered immediately inside the weapon silhouette.
-- Runtime application remains persistent only after the player confirms Equip Skin.
RegisterNUICallback('armasvip:previewSkin', function(_, cb)
    cb(true)
end)

RegisterNUICallback('armasvip:cancelSkinPreview', function(_, cb)
    cb(true)
end)
