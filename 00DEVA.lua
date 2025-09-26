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


setDefaultTab("TARGET")


-- Variável persistente para lembrar estado mesmo após relogar
if storage.travelNpcScriptActive == nil then
  storage.travelNpcScriptActive = true  -- começa ativado por padrão
end

local scriptActive = storage.travelNpcScriptActive

-- Botão para ativar/desativar o script
UI.Button(scriptActive and "Desativar Travel NPC Script" or "Ativar Travel NPC Script", function(widget)
  scriptActive = not scriptActive
  storage.travelNpcScriptActive = scriptActive
  if scriptActive then
    widget:setText("Desativar Travel NPC Script")
  else
    widget:setText("Ativar Travel NPC Script")
  end
end)

local npcOptions = {
  ["King Kai"] = {
    options = {"diario", "info", "feito", "buff", "habilidades"},
    flow = "default"
  },
  ["Gate Keaper"] = {
    options = {"Earth", "M2", "Tsufur", "Zelta", "Vegeta", "Namek", "Gardia", "Lude", "Premia", "City 17", "Rygol", "Ruudese", "Kanassa", "Gelbo", "Tritek", "CC21", "Yardratto"},
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
  }
}

local currentNpc = nil
local saidHi = false

-- UI Setup
local travelUI = setupUI([[
UIWindow
  !text: tr('NPC Interactions')
  color: #99d6ff
  font: sans-bold-16px
  size: 180 120
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
    text-align: center
    opacity: 1.0
    color: yellow
    font: sans-bold-16px
    margin-top: 25

  Button
    id: closeButton
    text: X
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    color: #99d6ff
    size: 15 15
    margin-bottom: 10
    margin-right: 10
    onClick: |
      travelUI:hide()
]], g_ui.getRootWidget())

travelUI:hide()

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

local function sayHi(npcName)
  if not saidHi then
    npcTalk("hi")
    saidHi = true
  end
end

local function onOptionClick(option)
  if not currentNpc then return end
  local npcData = npcOptions[currentNpc]
  if not npcData then return end

  if npcData.flow == "default" then
    npcTalk(option)
    if not (currentNpc == "King Kai" and (option == "buff" or option == "habilidades")) then
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

travelUI.travelOptions.onOptionChange = function(widget, option, data)
  if option ~= "None" then
    onOptionClick(option)
    schedule(50, function()
      travelUI.travelOptions:setCurrentOption("None")
    end)
  end
end

macro(500, function()
  if not scriptActive then return end

  local nearestNpc = nil
  local nearestDist = 100

  for npcName, data in pairs(npcOptions) do
    local npcCreature = getCreatureByName(npcName)
    if npcCreature then
      local dist = getDistanceBetween(pos(), npcCreature:getPosition())
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
      sayHi(currentNpc)
    end
  else
    if currentNpc ~= nil then
      resetState()
    end
  end
end)



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


setDefaultTab("OTHERS")

-- Variável persistente para lembrar estado mesmo após relogar
if storage.travelNpcScriptActive == nil then
  storage.travelNpcScriptActive = true  -- começa ativado por padrão
end

local scriptActive = storage.travelNpcScriptActive

-- Botão para ativar/desativar o script
UI.Button(scriptActive and "Desativar Travel NPC Script" or "Ativar Travel NPC Script", function(widget)
  scriptActive = not scriptActive
  storage.travelNpcScriptActive = scriptActive
  if scriptActive then
    widget:setText("Desativar Travel NPC Script")
  else
    widget:setText("Ativar Travel NPC Script")
  end
end)

local npcOptions = {
  ["King Kai"] = {
    options = {"diario", "info", "feito", "buff", "habilidades"},
    flow = "default"
  },
  ["Gate Keaper"] = {
    options = {"Earth", "M2", "Tsufur", "Zelta", "Vegeta", "Namek", "Gardia", "Lude", "Premia", "City 17", "Rygol", "Ruudese", "Kanassa", "Gelbo", "Tritek", "CC21", "Yardratto"},
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
  }
}

local currentNpc = nil
local saidHi = false

-- UI Setup
local travelUI = setupUI([[
UIWindow
  !text: tr('NPC Interactions')
  color: #99d6ff
  font: sans-bold-16px
  size: 180 120
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
    text-align: center
    opacity: 1.0
    color: yellow
    font: sans-bold-16px
    margin-top: 25

  Button
    id: closeButton
    text: X
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    color: #99d6ff
    size: 15 15
    margin-bottom: 10
    margin-right: 10
    onClick: |
      travelUI:hide()
]], g_ui.getRootWidget())

travelUI:hide()

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

local function sayHi(npcName)
  if not saidHi then
    npcTalk("hi")
    saidHi = true
  end
end

local function onOptionClick(option)
  if not currentNpc then return end
  local npcData = npcOptions[currentNpc]
  if not npcData then return end

  if npcData.flow == "default" then
    npcTalk(option)
    if not (currentNpc == "King Kai" and (option == "buff" or option == "habilidades")) then
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

travelUI.travelOptions.onOptionChange = function(widget, option, data)
  if option ~= "None" then
    onOptionClick(option)
    schedule(50, function()
      travelUI.travelOptions:setCurrentOption("None")
    end)
  end
end

macro(500, function()
  if not scriptActive then return end

  local nearestNpc = nil
  local nearestDist = 100

  for npcName, data in pairs(npcOptions) do
    local npcCreature = getCreatureByName(npcName)
    if npcCreature then
      local dist = getDistanceBetween(pos(), npcCreature:getPosition())
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
      sayHi(currentNpc)
    end
  else
    if currentNpc ~= nil then
      resetState()
    end
  end
end)
