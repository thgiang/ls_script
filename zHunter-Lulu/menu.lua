return function()
    local charName = Game.localPlayer.charName
    local displayName = Game.localPlayer.displayName

    local menu = UI.Menu.CreateMenu(charName, displayName, 2)
    Champions.CreateBaseMenu(menu, 0)

    -- Q Menu
    local QMenu = menu:AddMenu("Q", "Q - Glitterlance")
    QMenu:AddCheckBox("autoQ", "Auto Q in Combo", true)
    QMenu:AddCheckBox("harassQ", "Auto Q in Harass", true)
    QMenu:AddCheckBox("ksQ", "Auto Q for Killsteal", true)
    QMenu:AddCheckBox("farmQ", "Auto Q for Lane Clear", false)
    QMenu:AddSlider("minMinionsQ", "Lane clear minium minions", 3, 1, 6)
    QMenu:AddList("hitchanceQ", "Q Hitchance", { "Medium", "High", "VeryHigh(Slow)" }, 1)

    -- W Menu
    local WMenu = menu:AddMenu("W", "W - Whimsy")
    WMenu:AddCheckBox("autoW", "Auto W (Enemy Polymorph)", true)
    WMenu:AddCheckBox("buffW", "Auto W (Ally Buff)", true)
    WMenu:AddCheckBox("gapW", "Auto W on Gapcloser", true)
    WMenu:AddCheckBox("intW", "Auto W on Interruptable", true)
    WMenu:AddSlider("manaW", "Min Mana for W (%)", 30, 0, 100)

    -- E Menu
    local EMenu = menu:AddMenu("E", "E - Help, Pix!")
    EMenu:AddCheckBox("autoE", "Auto E (Shield Ally)", true)
    EMenu:AddCheckBox("comboE", "Auto E (Enemy Damage) in Combo", true)
    EMenu:AddSlider("hpE", "Shield Ally below HP %", 40, 0, 100)
    EMenu:AddCheckBox("shieldCC", "Shield Ally on Hard CC", true)

    -- R Menu
    local RMenu = menu:AddMenu("R", "R - Wild Growth")
    RMenu:AddCheckBox("autoR", "Auto R (Save Ally)", true)
    RMenu:AddCheckBox("aoeR", "Auto R (Knockback AOE)", true)
    RMenu:AddSlider("hpR", "R Ally below HP %", 20, 0, 100)
    RMenu:AddSlider("minR", "Min enemies for AOE R", 3, 1, 5)
    local useR = RMenu:AddKeyBind("useR", "Semi-manual R key", 84, false, false)
    useR:PermaShow(true, false)

    -- Drawing Menu
    local DrawMenu = menu:AddMenu("draw", "Drawings")
    -- To be safe and address the user's specific error about missing "qColor" etc variables:
    DrawMenu:AddColorPicker("qColor", "Q Range Color", 0xFFFFFFFF, false, false, function() end)
    DrawMenu:AddColorPicker("wColor", "W Range Color", 0xFF00FF00, false, false, function() end)
    DrawMenu:AddColorPicker("eColor", "E Range Color", 0xFFFFFF00, false, false, function() end)
    DrawMenu:AddColorPicker("rColor", "R Range Color", 0xFFFF0000, false, false, function() end)

    DrawMenu:AddCheckBox("drawQ", "Draw Q Range", true)
    DrawMenu:AddCheckBox("drawW", "Draw W Range", false)
    DrawMenu:AddCheckBox("drawE", "Draw E Range", true)
    DrawMenu:AddCheckBox("drawR", "Draw R Range", false)

    return menu
end
