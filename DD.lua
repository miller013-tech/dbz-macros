setDefaultTab("Main")

UI.Label("------ DD LUA ------")

local SpellData = {};
local CastData = {};

local update = function(data)
    SpellData = data:split(",");
    storage.SpellData = text;
end

UI.TextEdit(storage.SpellData or "Magia, Magia em Laranja", function(widget, text)
    text = text:trim():lower();
    update(text);
end)

spellTimeMacro = macro(1, 'Spell Time', function()
    say(SpellData[1]);
end)

onTalk(function(name, level, mode, text, channelId, pos)
    if (player:getName() ~= name) then return; end
    if (spellTimeMacro.isOff()) then return; end
    
    local spellName = (SpellData[2] or SpellData[1]):trim();
    if (text:lower() == spellName) then
        if (CastData.name == spellName) then
            info(tr(now - CastData.time));
        end
        CastData = {name=spellName,time=now};
    end
end)

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

setDefaultTab("Cave")

UI.Label("---------------")



-- Estado: 0 = desligado, 1 = verde, 2 = vermelho
local modo = 0

-- Macro para mensagens a cada 7 segundos
macro(1000, "OFF-ON", function()
    if modo == 1 or modo == 2 then
        local comando = (modo == 1) and "!pvp off" or "!pvp on"

        if not storage.lastMsg or now - storage.lastMsg >= 7000 then
            say(comando)
            storage.lastMsg = now
        end
    end
end)

-- Macro para piscar a cor
macro(200, function()
    if modo == 1 then
        if math.random() > 0.5 then
            player:setMarked("green")
        else
            player:setMarked()
        end
    elseif modo == 2 then
        if math.random() > 0.5 then
            player:setMarked("red")
        else
            player:setMarked()
        end
    else
        player:setMarked()
    end
end)

-- Hotkey F1 para alternar modos
hotkey("F1", function()
    modo = modo + 1
    if modo > 2 then modo = 0 end
    storage.lastMsg = 0
end)





-- F2 ? usa !tecnicas
hotkey("F2", function()
    say("!tecnicas")
end)

-- F3 ? usa !reverter
hotkey("F3", function()
    say("!reverter")
end)

-- F4 ? usa !transformarfinal
hotkey("F4", function()
    say("!transformarfinal")
end)


hotkey("F11", function()
    say("!owner list")
end)







macro(30000, "TRANSFORMAR!!!", function()
    say("!transformarfinal")
end)



UI.Label("---------------")

setDefaultTab("Others")

UI.Label("---------------")

UI.Label('Spells:');

storage.widgetPos = storage.widgetPos or {};

local antiRedTimeWidget = setupUI([[
UIWidget
  background-color: black
  opacity: 0.8
  padding: 0 5
  focusable: true
  phantom: false
  draggable: true
]], g_ui.getRootWidget());

local isMobile = modules._G.g_app.isMobile();
g_keyboard = g_keyboard or modules.corelib.g_keyboard;

local isDragKeyPressed = function()
	return isMobile and g_keyboard.isKeyPressed("F2") or g_keyboard.isCtrlPressed();
end

antiRedTimeWidget.onDragEnter = function(widget, mousePos)
	if (not isDragKeyPressed()) then return; end
	widget:breakAnchors();
	local widgetPos = widget:getPosition();
	widget.movingReference = {x = mousePos.x - widgetPos.x, y = mousePos.y - widgetPos.y};
	return true;
end

antiRedTimeWidget.onDragMove = function(widget, mousePos, moved)
	local parentRect = widget:getParent():getRect();
	local x = math.min(math.max(parentRect.x, mousePos.x - widget.movingReference.x), parentRect.x + parentRect.width - widget:getWidth());
	local y = math.min(math.max(parentRect.y - widget:getParent():getMarginTop(), mousePos.y - widget.movingReference.y), parentRect.y + parentRect.height - widget:getHeight());   
	widget:move(x, y);
	storage.widgetPos.antiRedTime = {x = x, y = y};
	return true;
end

local name = "antiRedTime";
storage.widgetPos[name] = storage.widgetPos[name] or {};
antiRedTimeWidget:setPosition({x = storage.widgetPos[name].x or 50, y = storage.widgetPos[name].y or 50});



local refreshSpells = function()
	castingSpells = {};
	if (storage.comboSpells) then
		local split = storage.comboSpells:split(",");
		for _, spell in ipairs(split) do
			table.insert(castingSpells, spell:trim());
		end
	end
end


addTextEdit("Magias", storage.comboSpells or "magia1, magia2, magia3", function(widget, text)
	storage.comboSpells = text;
	refreshSpells();
end)

refreshSpells();


UI.Label('Area:')
addTextEdit("Area", storage.areaSpell or "Magia de Area", function(widget, text)
	storage.areaSpell = text;
end)

if (not getSpectators or #getSpectators(true) == 0) then
	getSpectators = function()
		local specs = {};
		local tiles = g_map.getTiles(posz());
		for i = 1, #tiles do
			local tile = tiles[i];
			local creatures = tile:getCreatures();
			for _, spec in ipairs(creatures) do
				table.insert(specs, creature);
			end
		end
		return specs;
	end
end

if (not storage.antiRedTime or storage.antiRedTime - 30000 > now) then
	storage.antiRedTime = 0;
end

local addAntiRedTime = function()
	storage.antiRedTime = now + 30000;
end

local toInteger = function(number)
	number = tostring(number);
	number = number:split(".");
	return tonumber(number[1]);
end

macro(1, "Anti-Red", function()
	local pos, monstersCount = pos(), 0;
	if (player:getSkull() >= 3) then
		addAntiRedTime();
	end
	local specs = getSpectators(true);
	for _, spec in ipairs(specs) do
		local specPos = spec:getPosition();
		local floorDiff = math.abs(specPos.z - pos.z);
		if (floorDiff > 3) then 
			goto continue;
		end
		if (spec ~= player and spec:isPlayer() and spec:getEmblem() ~= 1 and spec:getShield() < 3) then
			addAntiRedTime();
			break
		elseif (floorDiff == 0 and spec:isMonster() and getDistanceBetween(specPos, pos) == 1) then
			monstersCount = monstersCount + 1;
		end
		::continue::
	end
	if (storage.antiRedTime >= now) then
		antiRedTimeWidget:show();
		local diff = storage.antiRedTime - now;
		diff = diff / 1000;
		antiRedTimeWidget:setText(tr("Area blocked for %ds.", toInteger(diff)));
		antiRedTimeWidget:setColor("red");
	elseif (not antiRedTimeWidget:isHidden()) then
		antiRedTimeWidget:hide();
	end
	if (monstersCount > 1 and storage.antiRedTime < now) then
		return say(storage.areaSpell);
	end
	if (not g_game.isAttacking()) then return; end
   	for _, spell in ipairs(castingSpells) do
		say(spell);
	end
end)

UI.Label("---------------")

UI.Label("Follow Player")

storage.followPlayer = storage.followPlayer or "nick"

UI.TextEdit(storage.followPlayer, function(widget, text)
  storage.followPlayer = text
end)

UI.Label("---------------")

local toFollowPos = {}

macro(200, "Follow Target", function()
  local toFollow = storage.followPlayer

  if toFollow == "" then return end

  local target = getCreatureByName(toFollow)
  if target then
    local tpos = target:getPosition()
    toFollowPos[tpos.z] = tpos
  end

  if player:isWalking() then return end

  local p = toFollowPos[posz()]
  if not p then return end

  if autoWalk(p, 20, {ignoreNonPathable=true, precision=1}) then
    delay(100)
  end
end)

onCreaturePositionChange(function(creature, oldPos, newPos)
  if creature:getName() == storage.followPlayer then
    toFollowPos[newPos.z] = newPos
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


storage.areascriptdec = storage.areascriptdec or "Furie"

macro(200, "area", function()
    say(storage.areascriptdec)
end)

addTextEdit("Ataque em Área", storage.areascriptdec, function(widget, text)
    storage.areascriptdec = text
end)




UI.Label("---------------")

setDefaultTab("OTHERS")

-- ===============================
-- Estado persistente
-- ===============================
if storage.travelNpcScriptActive == nil then
  storage.travelNpcScriptActive = true
end

local scriptActive = storage.travelNpcScriptActive

UI.Button(
  scriptActive and "Desativar Travel NPC Script" or "Ativar Travel NPC Script",
  function(widget)
    scriptActive = not scriptActive
    storage.travelNpcScriptActive = scriptActive
    widget:setText(scriptActive and "Desativar Travel NPC Script" or "Ativar Travel NPC Script")
  end
)

-- ===============================
-- Regras especiais
-- ===============================
local noYesForBuff = {
  ["King Kai"] = true,
  ["Assistente Kage"] = true
}

-- ===============================
-- NPCs e opções (DBO + NTO)
-- ===============================
local npcOptions = {

  -- DBO
  ["King Kai"] = {
    options = {"diario", "info", "feito", "buff", "habilidades"},
    flow = "default"
  },

  ["Gate Keaper"] = {
    options = {
      "Earth","M2","Tsufur","Zelta","Vegeta","Namek","Gardia","Lude",
      "Premia","City 17","Rygol","Ruudese","Kanassa","Gelbo","Tritek",
      "CC21","Yardratto", "Underworld"
    },
    flow = "default"
  },

  ["Chi Chi"] = {
    options = {"recompensa"},
    flow = "default"
  },

  ["Boaterni"] = {
    options = {"namek island", "small city"},
    flow = "boaterni"
  },

  ["Blessed Tapion"] = {
    options = {"proteção"},
    flow = "default"
  },

  -- ===============================
  -- NTO (equivalentes)
  -- ===============================
  ["Assistente Kage"] = {
    options = {"diario", "info", "feito", "buff", "habilidades"},
    flow = "default"
  },

  ["Minoru"] = {
    options = {
      "Konoha Gakure",
      "Sunagakure",
      "Kaminari no Kuni",
      "Yu no Kuni",
      "Shikotsuko north Island",
      "Shikotsuko south island",
      "Kushiro Island",
      "Yunokawa Island",
      "Sounkyo",
      "An No Kuni",
      "Tsuchi no Kuni",
      "Kinnin no Kuni",
      "Hoshigakure Island",
      "Yuki no Kuni",
      "Tsukuyomi Dimension",
      "City Events",
      "GGN"
    },
    flow = "default"
  },

  ["Hana"] = {
    options = {"recompensa"},
    flow = "default"
  },

  ["Daiki"] = {
    options = {"proteção"},
    flow = "default"
  }
}

-- ===============================
-- Estado interno
-- ===============================
local currentNpc = nil
local saidHi = false

-- ===============================
-- UI
-- ===============================
local travelUI = setupUI([[
UIWindow
  !text: tr('NPC Interactions')
  size: 190 125
  background-color: black
  opacity: 0.85
  anchors.left: parent.left
  anchors.top: parent.top
  margin-left: 600
  margin-top: 150

  ComboBox
    id: travelOptions
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    margin-top: 25
    text-align: center
    color: yellow

  Button
    text: X
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 15 15
    margin-bottom: 10
    margin-right: 10
    onClick: |
      travelUI:hide()
]], g_ui.getRootWidget())

travelUI:hide()

-- ===============================
-- Funções auxiliares
-- ===============================
local function npcTalk(text)
  if g_game.getClientVersion() >= 810 then
    g_game.talkChannel(11, 0, text)
  else
    say(text)
  end
end

local function resetState()
  currentNpc = nil
  saidHi = false
  travelUI:hide()
  travelUI.travelOptions:clearOptions()
  travelUI.travelOptions:addOption("None")
  travelUI.travelOptions:setCurrentOption("None")
end

local function sayHi()
  if not saidHi then
    npcTalk("hi")
    saidHi = true
  end
end

-- ===============================
-- Clique na opção
-- ===============================
local function onOptionClick(option)
  if not currentNpc then return end

  local npcData = npcOptions[currentNpc]
  if not npcData then return end

  if npcData.flow == "default" then
    npcTalk(option)

    if not (
      noYesForBuff[currentNpc] and
      (option == "buff" or option == "habilidades")
    ) then
      schedule(400, function()
        npcTalk("yes")
      end)
    end

  elseif npcData.flow == "boaterni" then
    npcTalk("travel")
    schedule(400, function()
      npcTalk(option)
    end)
  end
end

travelUI.travelOptions.onOptionChange = function(widget, option)
  if option ~= "None" then
    onOptionClick(option)
    schedule(50, function()
      widget:setCurrentOption("None")
    end)
  end
end

-- ===============================
-- Macro principal
-- ===============================
macro(500, function()
  if not scriptActive then return end

  local nearestNpc = nil
  local nearestDist = 100

  for npcName in pairs(npcOptions) do
    local npc = getCreatureByName(npcName)
    if npc then
      local dist = getDistanceBetween(pos(), npc:getPosition())
      if dist <= 3 and dist < nearestDist then
        nearestDist = dist
        nearestNpc = npcName
      end
    end
  end

  if nearestNpc then
    if currentNpc ~= nearestNpc then
      resetState()
      currentNpc = nearestNpc

      travelUI.travelOptions:clearOptions()
      travelUI.travelOptions:addOption("None")

      for _, opt in ipairs(npcOptions[currentNpc].options) do
        travelUI.travelOptions:addOption(opt)
      end

      travelUI:show()
      sayHi()
    end
  else
    if currentNpc then
      resetState()
    end
  end
end)

setDefaultTab("Dev")

--2x healing spell
--2x healing rune
--utani hur
--mana shield
--anti paralyze
--4x equip

UI.Label("Healing spells")

if type(storage.healing1) ~= "table" then
  storage.healing1 = {on=false, title="HP%", text="exura", min=51, max=90}
end
if type(storage.healing2) ~= "table" then
  storage.healing2 = {on=false, title="HP%", text="exura vita", min=0, max=50}
end

-- create 2 healing widgets
for _, healingInfo in ipairs({storage.healing1, storage.healing2}) do
  local healingmacro = macro(20, function()
    local hp = player:getHealthPercent()
    if healingInfo.max >= hp and hp >= healingInfo.min then
      if TargetBot then 
        TargetBot.saySpell(healingInfo.text) -- sync spell with targetbot if available
      else
        say(healingInfo.text)
      end
    end
  end)
  healingmacro.setOn(healingInfo.on)

  UI.DualScrollPanel(healingInfo, function(widget, newParams) 
    healingInfo = newParams
    healingmacro.setOn(healingInfo.on)
  end)
end

UI.Separator()

UI.Label("Mana & health potions/runes")

if type(storage.hpitem1) ~= "table" then
  storage.hpitem1 = {on=false, title="HP%", item=266, min=51, max=90}
end
if type(storage.hpitem2) ~= "table" then
  storage.hpitem2 = {on=false, title="HP%", item=3160, min=0, max=50}
end
if type(storage.manaitem1) ~= "table" then
  storage.manaitem1 = {on=false, title="MP%", item=268, min=51, max=90}
end
if type(storage.manaitem2) ~= "table" then
  storage.manaitem2 = {on=false, title="MP%", item=3157, min=0, max=50}
end

for i, healingInfo in ipairs({storage.hpitem1, storage.hpitem2, storage.manaitem1, storage.manaitem2}) do
  local healingmacro = macro(20, function()
    local hp = i <= 2 and player:getHealthPercent() or math.min(100, math.floor(100 * (player:getMana() / player:getMaxMana())))
    if healingInfo.max >= hp and hp >= healingInfo.min then
      if TargetBot then 
        TargetBot.useItem(healingInfo.item, healingInfo.subType, player) -- sync spell with targetbot if available
      else
        local thing = g_things.getThingType(healingInfo.item)
        local subType = g_game.getClientVersion() >= 860 and 0 or 1
        if thing and thing:isFluidContainer() then
          subType = healingInfo.subType
        end
        g_game.useInventoryItemWith(healingInfo.item, player, subType)
      end
    end
  end)
  healingmacro.setOn(healingInfo.on)

  UI.DualScrollItemPanel(healingInfo, function(widget, newParams) 
    healingInfo = newParams
    healingmacro.setOn(healingInfo.on and healingInfo.item > 100)
  end)
end

if g_game.getClientVersion() < 780 then
  UI.Label("In old tibia potions & runes work only when you have backpack with them opened")
end

UI.Separator()


UI.Label("Eatable items:")
if type(storage.foodItems) ~= "table" then
  storage.foodItems = {3582, 3577}
end

local foodContainer = UI.Container(function(widget, items)
  storage.foodItems = items
end, true)
foodContainer:setHeight(35)
foodContainer:setItems(storage.foodItems)

macro(10000, "eat food", function()
  if not storage.foodItems[1] then return end
  -- search for food in containers
  for _, container in pairs(g_game.getContainers()) do
    for __, item in ipairs(container:getItems()) do
      for i, foodItem in ipairs(storage.foodItems) do
        if item:getId() == foodItem.id then
          return g_game.use(item)
        end
      end
    end
  end
  -- can't find any food, try to eat random item using hotkey
  if g_game.getClientVersion() < 780 then return end -- hotkey's dont work on old tibia
  local toEat = storage.foodItems[math.random(1, #storage.foodItems)]
  if toEat then g_game.useInventoryItem(toEat.id) end
end)

UI.Separator()
UI.Label("Auto equip")

if type(storage.autoEquip) ~= "table" then
  storage.autoEquip = {}
end
for i=1,4 do -- if you want more auto equip panels you can change 4 to higher value
  if not storage.autoEquip[i] then
    storage.autoEquip[i] = {on=false, title="Auto Equip", item1=i == 1 and 3052 or 0, item2=i == 1 and 3089 or 0, slot=i == 1 and 9 or 0}
  end
  UI.TwoItemsAndSlotPanel(storage.autoEquip[i], function(widget, newParams)
    storage.autoEquip[i] = newParams
  end)
end
macro(250, function()
  local containers = g_game.getContainers()
  for index, autoEquip in ipairs(storage.autoEquip) do
    if autoEquip.on then
      local slotItem = getSlot(autoEquip.slot)
      if not slotItem or (slotItem:getId() ~= autoEquip.item1 and slotItem:getId() ~= autoEquip.item2) then
        for _, container in pairs(containers) do
          for __, item in ipairs(container:getItems()) do
            if item:getId() == autoEquip.item1 or item:getId() == autoEquip.item2 then
              g_game.move(item, {x=65535, y=autoEquip.slot, z=0}, item:getCount())
              delay(1000) -- don't call it too often      
              return
            end
          end
        end
      end
    end
  end
end)

-- allows to test/edit bot lua scripts ingame, you can have multiple scripts like this, just change storage.ingame_lua
UI.Button("Ingame macro editor", function(newText)
  UI.MultilineEditorWindow(storage.ingame_macros or "", {title="Macro editor", description="You can add your custom macros (or any other lua code) here"}, function(text)
    storage.ingame_macros = text
    reload()
  end)
end)
UI.Button("Ingame hotkey editor", function(newText)
  UI.MultilineEditorWindow(storage.ingame_hotkeys or "", {title="Hotkeys editor", description="You can add your custom hotkeys/singlehotkeys here"}, function(text)
    storage.ingame_hotkeys = text
    reload()
  end)
end)

UI.Separator()

for _, scripts in ipairs({storage.ingame_macros, storage.ingame_hotkeys}) do
  if type(scripts) == "string" and scripts:len() > 3 then
    local status, result = pcall(function()
      assert(load(scripts, "ingame_editor"))()
    end)
    if not status then 
      error("Ingame edior error:\n" .. result)
    end
  end
end

UI.Separator()

UI.Button("Zoom In map [ctrl + =]", function() zoomIn() end)
UI.Button("Zoom Out map [ctrl + -]", function() zoomOut() end)

UI.Separator()

local moneyIds = {3031, 3035} -- gold coin, platinium coin
macro(1000, "Exchange money", function()
  local containers = g_game.getContainers()
  for index, container in pairs(containers) do
    if not container.lootContainer then -- ignore monster containers
      for i, item in ipairs(container:getItems()) do
        if item:getCount() == 100 then
          for m, moneyId in ipairs(moneyIds) do
            if item:getId() == moneyId then
              return g_game.use(item)            
            end
          end
        end
      end
    end
  end
end)

macro(1000, "Stack items", function()
  local containers = g_game.getContainers()
  local toStack = {}
  for index, container in pairs(containers) do
    if not container.lootContainer then -- ignore monster containers
      for i, item in ipairs(container:getItems()) do
        if item:isStackable() and item:getCount() < 100 then
          local stackWith = toStack[item:getId()]
          if stackWith then
            g_game.move(item, stackWith[1], math.min(stackWith[2], item:getCount()))
            return
          end
          toStack[item:getId()] = {container:getSlotPosition(i - 1), 100 - item:getCount()}
        end
      end
    end
  end
end)

macro(10000, "Anti Kick",  function()
  local dir = player:getDirection()
  turn((dir + 1) % 4)
  turn(dir)
end)

UI.Separator()
UI.Label("Drop items:")
if type(storage.dropItems) ~= "table" then
  storage.dropItems = {283, 284, 285}
end

local foodContainer = UI.Container(function(widget, items)
  storage.dropItems = items
end, true)
foodContainer:setHeight(35)
foodContainer:setItems(storage.dropItems)

macro(5000, "drop items", function()
  if not storage.dropItems[1] then return end
  if TargetBot and TargetBot.isActive() then return end -- pause when attacking
  for _, container in pairs(g_game.getContainers()) do
    for __, item in ipairs(container:getItems()) do
      for i, dropItem in ipairs(storage.dropItems) do
        if item:getId() == dropItem.id then
          if item:isStackable() then
            return g_game.move(item, player:getPosition(), item:getCount())
          else
            return g_game.move(item, player:getPosition(), dropItem.count) -- count is also subtype
          end
        end
      end
    end
  end
end)

UI.Separator()

UI.Label("Mana training")
if type(storage.manaTrain) ~= "table" then
  storage.manaTrain = {on=false, title="MP%", text="utevo lux", min=80, max=100}
end

local manatrainmacro = macro(1000, function()
  if TargetBot and TargetBot.isActive() then return end -- pause when attacking
  local mana = math.min(100, math.floor(100 * (player:getMana() / player:getMaxMana())))
  if storage.manaTrain.max >= mana and mana >= storage.manaTrain.min then
    say(storage.manaTrain.text)
  end
end)
manatrainmacro.setOn(storage.manaTrain.on)

UI.DualScrollPanel(storage.manaTrain, function(widget, newParams) 
  storage.manaTrain = newParams
  manatrainmacro.setOn(storage.manaTrain.on)
end)

UI.Separator()
