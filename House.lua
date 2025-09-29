macro(1000, "Andar no horário (Norte)", function()
  local H, M = 23, 55
  storage.lastMove = storage.lastMove or {hour=-1, min=-1}
  local t = os.date("*t")
  if t.hour == H and t.min == M then
    if storage.lastMove.hour ~= t.hour or storage.lastMove.min ~= t.min then
      g_game.walk(North)
      storage.lastMove = {hour=t.hour, min=t.min}
    end
  end
end)

macro(1000, "Andar no horário (Sul)", function()
  local H, M = 00, 05
  storage.lastMove = storage.lastMove or {hour=-1, min=-1}
  local t = os.date("*t")
  if t.hour == H and t.min == M then
    if storage.lastMove.hour ~= t.hour or storage.lastMove.min ~= t.min then
      g_game.walk(South)
      storage.lastMove = {hour=t.hour, min=t.min}
    end
  end
end)


local saidOnLogin = false

local sendCommandMacro = macro(1000, "RELOGAR RAT", function()
  if not saidOnLogin and g_game.isOnline() then
    say("!rat")
    saidOnLogin = true
  end
end)



UI.Label("Nomes para convidar para party:")
local partyInviteList = UI.TextEdit(storage.partyInviteList or "Darkzin, Gokuu", function(widget, text)
  storage.partyInviteList = text
end)

local inviteMacro = macro(2000, "Auto Invite Party", function()
  if not storage.partyInviteList or storage.partyInviteList == "" then return end

  local names = {}
  for name in string.gmatch(storage.partyInviteList, '([^,]+)') do
    name = name:trim()
    if name ~= "" then
      table.insert(names, name)
    end
  end
  if #names == 0 then return end

  if not storage.partyConfirmed then storage.partyConfirmed = {} end
  if not storage.pendingInvites then storage.pendingInvites = {} end

  -- Remove da lista quem já está na party
  if g_game.getPartyMemberByName then
    for _, name in ipairs(names) do
      if g_game.getPartyMemberByName(name) then
        storage.partyConfirmed[name:lower()] = true
      end
    end
  end

  for _, name in ipairs(names) do
    local lowerName = name:lower()

    if not storage.partyConfirmed[lowerName] and not storage.pendingInvites[lowerName] then
      local creature = getCreatureByName(name)
      if creature and creature:isPlayer() then
        g_game.partyInvite(creature:getId())
        storage.pendingInvites[lowerName] = true

        -- ? Usa o nome real da criatura (com hífen, acento, etc.)
        schedule(200, function()
          say("pt " .. creature:getName())
        end)

        break -- só um por vez
      end
    end
  end
end)

-- Escuta mensagens do chat para registrar "pta"
onTalk(function(name, level, mode, text, channelId, pos)
  if text:lower() == "pta" then
    storage.partyConfirmed = storage.partyConfirmed or {}
    storage.partyConfirmed[name:lower()] = true
    storage.pendingInvites = storage.pendingInvites or {}
    storage.pendingInvites[name:lower()] = nil
  end

  -- Comando para resetar listas
  if text:lower() == "!rat" then
    storage.partyConfirmed = {}
    storage.pendingInvites = {}
    say("Listas de party resetadas.")
  end
end)

UI.Label("---------------")

local acceptPartyMacro = macro(100, "Auto Accept Party", function() end)

onTalk(function(name, level, mode, text, channelId, pos)
  if not acceptPartyMacro:isOn() then return end

  local realName = player:getName()
  local textLower = text:lower()
  local realNameLower = realName:lower()

  -- Verifica se a mensagem contém "pt" seguido do nome real (com hífen, maiúsculas, etc)
  if textLower:match("pt%s+" .. realNameLower) or text:match("pt%s+" .. realName) then
    local creature = getCreatureByName(name)
    if creature then
      say("pta")
      schedule(100, function()
        g_game.partyJoin(creature:getId())
        acceptPartyMacro:stop()
      end)
    end
  end
end)


local ITEM_ID = 2474
local requestedTarget = nil

local function itemPresent(id)
  local z = posz()
  local tiles = g_map.getTiles(z)
  if not tiles then return false end
  for _, tile in ipairs(tiles) do
    local count = tile:getThingCount()
    for i = 0, count - 1 do
      local thing = tile:getThing(i)
      if thing and thing.getId and thing:getId() == id then
        return true
      end
    end
  end
  return false
end

onTalk(function(name, level, mode, text, channelId, pos)
  if not text then return end
  if text:lower():find("!attackme", 1, true) then
    requestedTarget = name
    print("[SignalAttack] Pedido recebido de: " .. tostring(name))
  end
end)

macro(3000, "Atacar por sinal com item", function()
  if not requestedTarget then return end
  if not itemPresent(ITEM_ID) then return end

  local creature = getCreatureByName(requestedTarget)
  if creature and creature:isPlayer() then
    if g_game.getAttackingCreature() ~= creature then
      g_game.attack(creature)
      print("[SignalAttack] Iniciando ataque em: " .. tostring(requestedTarget))
    end
  end
end)





UI.Label("---------------")



macro(5000, "Power Down check", function()
  for _, tile in ipairs(g_map.getTiles(posz())) do
    for i=0, tile:getThingCount()-1 do
      local thing = tile:getThing(i)
      if thing and thing:getId() == 5725 then
        say("Power Down")
        return
      end
    end
  end
end)




storage.areaSpell = storage.areaSpell or "Furie"

macro(1000, "ATAQUE", function()
    say(storage.areaSpell)
end)

addTextEdit("Ataque em Área", storage.areaSpell, function(widget, text)
    storage.areaSpell = text
end)


UI.Label("---------------")


UI.Label(" x MAIN x ")


UI.Label("---------------")




UI.Label("Nome do alvo para atacar:")
local attackTargetName = UI.TextEdit(storage.attackTargetName or "Comedor-de-lanche", function(widget, text)
  storage.attackTargetName = text
end)

local attackTarget = macro(1000, "Atacar alvo", function()
  local targetName = storage.attackTargetName
  if not targetName or targetName:trim() == "" then return end

  local creature = getCreatureByName(targetName)
  if creature and creature:isPlayer() then
    if g_game.getAttackingCreature() ~= creature then
      g_game.attack(creature)
    end
  end
end)




-- ME ATACAR (com storage)
local ITEM_ID = 5725
local DELAY = 5000 -- 5 segundos

-- Macro principal
local meAtacarMacro = macro(DELAY, "ME ATACAR", function()
  -- checa se item está na tela
  local function itemPresent(id)
    local z = posz()
    local tiles = g_map.getTiles(z)
    if not tiles then return false end
    for _, tile in ipairs(tiles) do
      local count = tile:getThingCount()
      for i = 0, count - 1 do
        local thing = tile:getThing(i)
        if thing and thing.getId and thing:getId() == id then
          return true
        end
      end
    end
    return false
  end

  if itemPresent(ITEM_ID) then
    say("!attackme")
  end
end)

-- Inicializa storage se não existir (desativado por padrão)
if storage.meAtacarEnabled == nil then
  storage.meAtacarEnabled = false
end

-- Aplica estado salvo
if storage.meAtacarEnabled then
  if not meAtacarMacro:isOn() then meAtacarMacro:start() end
else
  if meAtacarMacro:isOn() then meAtacarMacro:stop() end
end

-- Funções utilitárias para console
function enableMeAtacar()
  storage.meAtacarEnabled = true
  meAtacarMacro:start()
  print("[ME ATACAR] Habilitado e salvo em storage.")
end

function disableMeAtacar()
  storage.meAtacarEnabled = false
  meAtacarMacro:stop()
  print("[ME ATACAR] Desabilitado e salvo em storage.")
end

function toggleMeAtacar()
  if meAtacarMacro:isOn() then
    disableMeAtacar()
  else
    enableMeAtacar()
  end
end

-- Atualiza storage automaticamente se macro for ligado/desligado manualmente
spawn(function()
  local lastState = meAtacarMacro:isOn()
  while true do
    local cur = meAtacarMacro:isOn()
    if cur ~= lastState then
      storage.meAtacarEnabled = cur
      lastState = cur
      print(("[ME ATACAR] Estado alterado -> storage atualizado = %s"):format(tostring(cur)))
    end
    sleep(1000)
  end
end)
