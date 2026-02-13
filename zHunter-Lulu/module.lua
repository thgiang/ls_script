-- zHunter Lulu
-- Entry point

if Game.HashStringSDBM("Lulu") ~= Game.localPlayer.hash then
    return
end

-- Disable C++ champion script
Champions.CppScriptMaster(false)

-- Initialize Champions global variables to avoid nil errors
Champions.Q = nil
Champions.W = nil
Champions.E = nil
Champions.R = nil
Champions.QMANA = 0
Champions.WMANA = 0
Champions.EMANA = 0
Champions.RMANA = 0
Champions.Combo = false
Champions.Harass = false
Champions.LaneClear = false
Champions.FastLaneClear = false
Champions.Flee = false
Champions.OnlyHarass = false
Champions.Freeze = false
Champions.None = false

-- Load submodules
-- Define menu as global for logic.lua access
menu = Environment.LoadModule("menu")
local logic = Environment.LoadModule("logic")

local function Init()
    -- Initialize Spells
    Champions.Q = SDKSpell.Create(SpellSlot.Q, 925, DamageType.Magical)
    Champions.W = SDKSpell.Create(SpellSlot.W, 650, DamageType.Magical)
    Champions.E = SDKSpell.Create(SpellSlot.E, 650, DamageType.Magical)
    Champions.R = SDKSpell.Create(SpellSlot.R, 900, DamageType.Magical)

    -- Set Spell Data
    Champions.Q:SetSkillshot(0.25, 60, 1450, SkillshotType.SkillshotLine, true, CollisionFlag.CollidesWithYasuoWall,
        HitChance.High, true)

    -- Targetted spells
    Champions.W:SetTargetted(0.25, math.huge, SkillshotType.SkillshotLine, false, CollisionFlag.CollidesWithNothing,
        HitChance.High, true)
    Champions.E:SetTargetted(0.25, math.huge, SkillshotType.SkillshotLine, false, CollisionFlag.CollidesWithNothing,
        HitChance.High, true)
    Champions.R:SetTargetted(0.25, math.huge, SkillshotType.SkillshotLine, false, CollisionFlag.CollidesWithNothing,
        HitChance.High, true)

    -- Initialize Menu
    menu = menu()

    -- Initialize Logic
    logic()

    PrintChat("zHunter-Lulu Loaded! Have fun!")
end

Init()

Callback.Bind(CallbackType.OnUnload, function()
    Champions.Clean()
    PrintChat("zHunter-Lulu Unloaded!")
end)

-- Drawing Callbacks
Callback.Bind(CallbackType.OnDraw, function()
    local Player = Game.localPlayer
    if not Player or not Player:IsValid() or Player.isDead then return end

    if menu.draw.drawQ.value and Champions.Q:Ready() then
        Renderer.DrawCircle3D(Player.position, Champions.Q.range, 30, 2, menu.draw.qColor.value)
    end
    if menu.draw.drawW.value and Champions.W:Ready() then
        Renderer.DrawCircle3D(Player.position, Champions.W.range, 30, 2, menu.draw.wColor.value)
    end
    if menu.draw.drawE.value and Champions.E:Ready() then
        Renderer.DrawCircle3D(Player.position, Champions.E.range, 30, 2, menu.draw.eColor.value)
    end
    if menu.draw.drawR.value and Champions.R:Ready() then
        Renderer.DrawCircle3D(Player.position, Champions.R.range, 30, 2, menu.draw.rColor.value)
    end
end)
