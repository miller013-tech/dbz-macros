setDefaultTab("Cave")

UI.Label("---------------")



-- Estado: 0 = desligado, 1 = verde, 2 = vermelho
local modo = 0

-- Macro para mensagens a cada 7 segundos
macro(1000, function()
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


storage.areaSpell = storage.areaSpell or "Furie"

macro(200, "area", function()
    say(storage.areaSpell)
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





