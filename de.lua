UI.Label("---------------")

setDefaultTab("Main")


UI.Label("---------------")

-- =========================
-- ⚡ Script de Combo com TextEdits visíveis
-- =========================

storage.myCombo = storage.myCombo or {
    spell1s     = "Burning Waves",
    spellCanudo = "Super Namekian Final Flash",
    spellImpact = "Combo Impact",
    spell30     = "Kasai no Arashi",
    extraMs     = 120
}

local cycleIndex = 1
local nextAllowedTime = 0

-- Delay dinâmico
local function getIntervalMs()
    return 1000 + (storage.myCombo.extraMs or 120) + math.random(-20, 20)
end

-- Macro principal
local function comboTick()
    local now = os.clock() * 1000
    if now < nextAllowedTime then return end

    -- ⚠️ Só roda se estiver atacando
    if not g_game.isAttacking() then return end  

    local toCast
    if cycleIndex >= 1 and cycleIndex <= 4 then
        toCast = storage.myCombo.spell1s
    elseif cycleIndex == 5 then
        toCast = storage.myCombo.spellCanudo
    elseif cycleIndex == 6 then
        toCast = storage.myCombo.spellImpact
    end

    if toCast then
        say(toCast)
        nextAllowedTime = now + getIntervalMs()
        cycleIndex = cycleIndex + 1
        if cycleIndex > 6 then cycleIndex = 1 end
    end
end

macro(50, "Combo Ciclo", comboTick)

-- Hotkey F12 para magia de 30s
onKeyDown(function(keys)
    if keys == "F12" then
        say(storage.myCombo.spell30)
    end
end)

-- =========================
-- 🔹 TextEdits visíveis na aba do bot
-- =========================
addTextEdit("Magia 1s", storage.myCombo.spell1s, function(self, text)
    storage.myCombo.spell1s = text
end)

addTextEdit("Canudo", storage.myCombo.spellCanudo, function(self, text)
    storage.myCombo.spellCanudo = text
end)

addTextEdit("Combo Impact", storage.myCombo.spellImpact, function(self, text)
    storage.myCombo.spellImpact = text
end)

addTextEdit("Magia 30s (F12)", storage.myCombo.spell30, function(self, text)
    storage.myCombo.spell30 = text
end)

print("Script de combo com TextEdits carregado ✅")
print("Agora só funciona se estiver atacando.")

UI.Label("---------------")

-- Script Combo 5x ataque rápido + Canudo
local spellFast = "Burning Waves"
local spellCanudo = "Super Namekian Final Flash"
local spell30s = "Kasai no Arashi"

local fastCount = 0
local lastCast = 0

-- Ciclo automático
macro(100, "Combo Auto", function()
    if g_game.isAttacking() then
        if os.clock() - lastCast > 1.05 then
            if fastCount < 5 then
                say(spellFast)
                fastCount = fastCount + 1
            else
                say(spellCanudo)
                fastCount = 0
            end
            lastCast = os.clock()
        end
    end
end)

-- Hotkey para ataque de 30s
onKeyDown(function(keys)
    if keys == "F12" then
        say(spell30s)
    end
end)

setDefaultTab("Others")

UI.Label("---------------")



storage.Spell1 = storage.Spell1 or "Single target"
storage.Spell2 = storage.Spell2 or "Multi target"

local distance = 3
local amountOfMonsters = 2

macro(1000, "Magias sem PK", function()
    local isSafe = true
    local specAmount = 0
    if not g_game.isAttacking() then return end
    for i, mob in ipairs(getSpectators()) do
        if (getDistanceBetween(player:getPosition(), mob:getPosition()) <= distance and mob:isMonster()) then
            specAmount = specAmount + 1
        end
        if (mob:isPlayer() and (player:getName() ~= mob:getName()) and g_game.isAttacking(storage.Spell1)) then
            isSafe = false
        end
    end
    if (specAmount >= amountOfMonsters) and isSafe then
        say(storage.Spell2, 200)
    else
        say(storage.Spell1, 200)
    end
end)

addTextEdit("Spell1", storage.Spell1, function(widget, text) 
    storage.Spell1 = text
end)

addTextEdit("Spell2", storage.Spell2, function(widget, text) 
    storage.Spell2 = text
end)




macro(12000, "PVP OFF", function()
    say("!pvp off")
end)

UI.Label("---------------")

local showhp = macro(20000, "HP dos Personagens", function() end)

onCreatureHealthPercentChange(function(creature, healthPercent)
    if showhp:isOff() then return end
    if (creature:isMonster() or creature:isPlayer()) and creature:getPosition() and pos() then
        if getDistanceBetween(pos(), creature:getPosition()) <= 5 then
            creature:setText("\n\n\n\n" .. healthPercent .. "%")
        else
            creature:clearText()
        end
    end
end)

macro(1, "Virar Target pro Alvo", function()
    if not g_game.isAttacking() then return end
    local tt = g_game.getAttackingCreature()
    local tx = tt:getPosition().x
    local ty = tt:getPosition().y
    local dir = player:getDirection()
    local tdx = math.abs(tx - pos().x)
    local tdy = math.abs(ty - pos().y)
    if (tdy >= 2 and tdx >= 2) or tdx > 7 or tdy > 7 then return end
    if tdy >= tdx then
        if ty > pos().y then
            if dir ~= 2 then return turn(2) end
        else
            if dir ~= 0 then return turn(0) end
        end
    else
        if tx > pos().x then
            if dir ~= 1 then return turn(1) end
        else
            if dir ~= 3 then return turn(3) end
        end
    end
end)

local revidar = false
addSwitch("revidar", "revidar", function(widget)
    revidar = not revidar
    widget:setOn(revidar)
end)

onTextMessage(function(mode, text)
    if revidar == true and not g_game.getAttackingCreature() and string.find(text, "You lose") then
        local targetName = text:match("attack by (.+)%.")
        local target = getPlayerByName(targetName)
        if target then
            g_game.attack(target)
        end
    end
end)

UI.Label("---------------")

macro(100, "Mobs", function()
    local battlelist = getSpectators()
    local closest = 10
    local lowesthpc = 101
    for key, val in pairs(battlelist) do
        if val:isMonster() then
            local dist = getDistanceBetween(player:getPosition(), val:getPosition())
            if dist <= closest then
                closest = dist
                if val:getHealthPercent() < lowesthpc then
                    lowesthpc = val:getHealthPercent()
                end
            end
        end
    end
    for key, val in pairs(battlelist) do
        if val:isMonster() then
            local dist = getDistanceBetween(player:getPosition(), val:getPosition())
            if dist <= closest then
                if g_game.getAttackingCreature() ~= val and val:getHealthPercent() <= lowesthpc then
                    g_game.attack(val)
                    delay(100)
                    break
                end
            end
        end
    end
end)

-- Macro de ataque em área editável
storage.areaSpell = storage.areaSpell or "Furie"

macro(10, "area", function()
    if g_game.isAttacking() then
        say(storage.areaSpell)
    end
end)

addTextEdit("Ataque em Área", storage.areaSpell, function(widget, text)
    storage.areaSpell = text
end)



UI.Label("---------------")

local toFollow = "nick"
local toFollowPos = {nick}

macro(200, "follow target", function()
    local target = getCreatureByName(toFollow)
    if target then
        local tpos = target:getPosition()
        toFollowPos[tpos.z] = tpos
    end
    if player:isWalking() then return end
    local p = toFollowPos[posz()]
    if not p then return end
    if autoWalk(p, 20, {ignoreNonPathable = true, precision = 1}) then
        delay(100)
    end
end)

onCreaturePositionChange(function(creature, oldPos, newPos)
    if creature:getName() == toFollow then
        toFollowPos[newPos.z] = newPos
    end
end)

macro(10, "Andar para o Norte", function()
    schedule(10, function() walk(0) end)
end)


