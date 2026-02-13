return function()
    local Player = Game.localPlayer
    local Q = Champions.Q
    local W = Champions.W
    local E = Champions.E
    local R = Champions.R

    local function GetPix()
        local hash_LuluFaerie = Game.HashStringSDBM("LuluFaerie")
        for _, obj in ObjectManager.allAIBaseClients:pairs() do
            if obj:IsValid() and obj.team == Player.team and obj.hash == hash_LuluFaerie then
                return obj
            end
        end
        return nil
    end

    local function SetMana()
        if Champions.Combo or Player.hpPercent < 20 then
            Champions.QMANA = 0
            Champions.WMANA = 0
            Champions.EMANA = 0
            Champions.RMANA = 0
            return
        end

        Champions.QMANA = Q:ManaCost()
        Champions.WMANA = W:ManaCost()
        Champions.EMANA = E:ManaCost()
        Champions.RMANA = R:ManaCost()
    end

    local function LogicQ()
        if not menu.Q.autoQ.value and not (Champions.Harass and menu.Q.harassQ.value) then return end

        local target = TargetSelector.GetTarget(Q.range, DamageType.Magical)
        if target and target:IsValidTarget() then
            -- Simple prediction cast
            Q:Cast(target, menu.Q.hitchanceQ)
        end

        -- Killsteal
        if menu.Q.ksQ.value then
            for _, enemy in ObjectManager.enemyHeroes:pairs() do
                if enemy:IsValidTarget(Q.range) and Q:GetDamage(enemy) > enemy.hp then
                    Q:Cast(enemy, menu.Q.hitchanceQ)
                end
            end
        end

        -- Lane Clear
        if Champions.LaneClear and menu.Q.farmQ.value and Champions.CanSpellFarm(true) then
            local farmPos = Q:GetCastOnBestFarmPosition(menu.Q.minMinionsQ.value, false)
            if farmPos:IsValid() then
                Q:Cast(farmPos, false)
            end
        end

        -- Jungle Clear
        if Champions.LaneClear and Champions.CanSpellFarm(false) then -- Jungle check usually implied or needs separate menu
            local junglePos = Q:GetCastOnBestFarmPosition(1, true)
            if junglePos:IsValid() then
                Q:Cast(junglePos, false)
            end
        end
    end

    local function LogicW()
        if not W:Ready() then return end

        -- Auto W on Enemy (Polymorph)
        if menu.W.autoW.value then
            for _, enemy in ObjectManager.enemyHeroes:pairs() do
                if enemy:IsValidTarget(W.range) then
                    if menu.W.intW.value and enemy.charIntermediate.isCastingInterruptibleSpell then
                        W:CastOnUnit(enemy, false, false)
                        return
                    end
                    if menu.W.gapW.value and Champions.Flee then -- Simplified Use case
                        -- SDK doesn't have IsDashing check easily here without callback
                    end
                end
            end
        end

        -- Buff Ally
        if menu.W.buffW.value and Player.mpPercent > menu.W.manaW.value then
            if Champions.Combo then
                for _, ally in ObjectManager.allyHeroes:pairs() do
                    if ally:IsValidTarget(W.range, false) and ally.hpPercent > 0 then
                        if ally.isMe or ally.charIntermediate.isAutoAttacking then
                            W:CastOnUnit(ally, false, false)
                            return
                        end
                    end
                end
            end
        end
    end

    local function LogicE()
        if not E:Ready() then return end

        -- Shield Ally
        if menu.E.autoE.value then
            for _, ally in ObjectManager.allyHeroes:pairs() do
                if ally:IsValidTarget(E.range, false) then
                    if ally.hpPercent < menu.E.hpE.value then
                        E:CastOnUnit(ally, false, false)
                        return
                    end
                    if menu.E.shieldCC.value and (ally.charIntermediate.isRooted or ally.charIntermediate.isStunned) then
                        E:CastOnUnit(ally, false, false)
                        return
                    end
                end
            end
        end

        -- Combo E on Enemy
        if Champions.Combo and menu.E.comboE.value then
            local target = TargetSelector.GetTarget(E.range, DamageType.Magical)
            if target and target:IsValidTarget() then
                E:CastOnUnit(target, false, false)
            end
        end
    end

    local function LogicR()
        if not R:Ready() then return end

        if menu.R.useR.value then
            R:CastOnUnit(Player, false, false)
            return
        end

        if menu.R.autoR.value then
            for _, ally in ObjectManager.allyHeroes:pairs() do
                if ally:IsValidTarget(R.range, false) and ally.hpPercent < menu.R.hpR.value then
                    if ally.position:CountEnemiesInRange(500) > 0 then
                        R:CastOnUnit(ally, false, false)
                        return
                    end
                end
            end
        end

        if menu.R.aoeR.value then
            for _, ally in ObjectManager.allyHeroes:pairs() do
                if ally:IsValidTarget(R.range, false) then
                    if ally.position:CountEnemiesInRange(400) >= menu.R.minR.value then
                        R:CastOnUnit(ally, false, false)
                        return
                    end
                end
            end
        end
    end

    local function OnTick()
        if Champions.LagFree(0) then
            SetMana()
        end

        -- Global menu check
        if not menu then return end

        if Q:Ready() then LogicQ() end
        if W:Ready() then LogicW() end
        if E:Ready() then LogicE() end
        if R:Ready() then LogicR() end
    end

    Callback.Bind(CallbackType.OnTick, OnTick)
end
