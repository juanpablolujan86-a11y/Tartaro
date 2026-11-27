local _, A = ...
if A.traceLoad then A.traceLoad("module.begin", "Professions.lua") end
local trade = C_TradeSkillUI or {}
local gathering = {[182] = true, [186] = true, [393] = true}
local withoutRecipes = {[182] = true, [393] = true, [356] = true, [794] = true}
local pending, incoming, openedAt, scheduled, learnedRecipes
local partSize, maxParts = 190, 128
local materialRequests = {}

local plain; plain = A.traceCallback("Professions.lua:10:plain", function(value)
    if issecretvalue and issecretvalue(value) then return end
    return value
end)

local try; try = A.traceCallback("Professions.lua:15:try", function(fn, ...)
    if not fn then return end
    local ok, value = A.debugPcall("Professions.lua:17:pcall", fn, ...)
    if ok then return plain(value) end
end)

local positive; positive = A.traceCallback("Professions.lua:21:positive", function(value)
    return type(value) == "number" and value > 0 and value < 100000000 and value % 1 == 0
end)

local sortedKeys; sortedKeys = A.traceCallback("Professions.lua:25:sortedKeys", function(values)
    local keys = {}
    for id in pairs(values) do keys[#keys + 1] = id end
    table.sort(keys)
    return keys
end)

local encode; encode = A.traceCallback("Professions.lua:32:encode", function(professions)
    local result = {}
    for _, id in ipairs(sortedKeys(professions)) do
        local prof = professions[id]
        local name = prof.name:gsub("[^A-Za-z0-9 ]", A.traceCallback("Professions.lua:36:callback", function(byte) return ("%%%02X"):format(byte:byte()) end))
        local recipes = {}
        for _, spell in ipairs(sortedKeys(prof.recipes or {})) do
            recipes[#recipes + 1] = spell .. ":" .. prof.recipes[spell]
        end
        local state = prof.recipes and "R" or (prof.canCraft and "W" or "N")
        result[#result + 1] = table.concat({id, prof.rank, prof.maximum, prof.category, name, state, table.concat(recipes, ".")}, ",")
    end
    return #result > 0 and table.concat(result, ";") or "-"
end)

local decode; decode = A.traceCallback("Professions.lua:47:decode", function(data)
    local professions = {}
    if data == "-" then return professions end
    local count = 0
    for entry in (data .. ";"):gmatch("([^;]*);") do
        local id, rank, maximum, category, name, state, recipes = entry:match("^(%d+),(%d+),(%d+),([FGS]),([^,]+),([RWN]),(.*)$")
        id, rank, maximum = tonumber(id), tonumber(rank), tonumber(maximum)
        count = count + 1
        if not positive(id) or not rank or not maximum or rank > maximum or professions[id] or count > 12 then return end
        name = A.clean((name:gsub("%%(%x%x)", A.traceCallback("Professions.lua:56:callback", function(byte) return string.char(tonumber(byte, 16)) end))))
        if name == "" or #name > 100 or (state ~= "R" and recipes ~= "") then return end
        local prof = {name = name, rank = rank, maximum = maximum, category = category, canCraft = state ~= "N"}
        if state == "R" then
            prof.recipes = {}
            if recipes ~= "" then
                for recipe in (recipes .. "."):gmatch("([^.]*)%.") do
                    local spell, item = recipe:match("^(%d+):(%d+)$")
                    spell, item = tonumber(spell), tonumber(item)
                    if not positive(spell) or not item or item >= 100000000 then return end
                    prof.recipes[spell] = item
                end
            end
        end
        professions[id] = prof
    end
    return professions
end)

A.shareProfessions = A.traceCallback("Professions.lua:75:A.shareProfessions", function()
    local own = A.db and A.db.professions[A.self]
    if not own or (pending and pending.rev == own.rev) then return end
    local total = math.ceil(#own.data / partSize)
    if total > maxParts then return end
    pending = {rev = own.rev, data = own.data, total = total, index = 1, db = A.db}
end)

A.receiveProfessions = A.traceCallback("Professions.lua:83:A.receiveProfessions", function(author, rev, index, total, part)
    if type(rev) ~= "number" or rev % 1 ~= 0 or rev <= 0 or rev > (GetServerTime() + 300) * 100
        or not positive(index) or not positive(total) or total > maxParts or index > total
        or type(part) ~= "string" or #part == 0 or #part > partSize then return end
    local known = A.db.professions[author]
    if known and known.rev >= rev then return end
    local now = GetTime()
    local transfer = incoming[author]
    if not transfer or transfer.untilTime < now or transfer.rev < rev then
        transfer = {rev = rev, total = total, parts = {}, received = 0, untilTime = now + 240}
        incoming[author] = transfer
        A.invalidate("recipeStatus")
        local db = A.db
        C_Timer.After(240, A.traceCallback("Professions.lua:96:callback", function()
            if A.db == db and incoming[author] == transfer then
                incoming[author] = nil
                A.debugLog("professions.transfer.expired","Professions.receiveProfessions",author,transfer.rev,transfer.received,transfer.total)
                A.invalidate("recipeStatus")
            end
        end))
    end
    if transfer.rev ~= rev or transfer.total ~= total or transfer.parts[index] then return end
    transfer.parts[index] = part
    transfer.received = transfer.received + 1
    if transfer.received ~= total then return end
    incoming[author] = nil
    A.invalidate("recipeStatus")
    local professions = decode(table.concat(transfer.parts))
    if not professions then return end
    A.db.professions[author] = {rev = rev, list = professions}
    A.verifyOrderOffers(author)
    A.invalidateRecipeCatalog()
    A.refreshProfessions()
end)

local isKnown; isKnown = A.traceCallback("Professions.lua:118:isKnown", function(spell)
    return try(IsPlayerSpell or IsSpellKnown or (C_SpellBook and C_SpellBook.IsSpellKnown), spell) == true
end)

local professionID; professionID = A.traceCallback("Professions.lua:122:professionID", function(info)
    if type(info) ~= "table" then return end
    local parent, id = plain(info.parentProfessionID), plain(info.professionID)
    return positive(parent) and parent or (positive(id) and id or nil)
end)

local recipeItem; recipeItem = A.traceCallback("Professions.lua:128:recipeItem", function(spell)
    local link = try(trade.GetRecipeItemLink, spell)
    if type(link) == "string" then return tonumber(link:match("item:(%d+)")) or 0 end
    local schematic = try(trade.GetRecipeSchematic, spell, false)
    local item = type(schematic) == "table" and plain(schematic.outputItemID)
    return positive(item) and item or 0
end)

local readMaterials; readMaterials = A.traceCallback("Professions.lua:136:readMaterials", function(spell)
    local schematic = try(trade.GetRecipeSchematic, spell, false)
    local slots = type(schematic) == "table" and plain(schematic.reagentSlotSchematics)
    if type(slots) ~= "table" then return end
    local materials = {}
    local basic = Enum and Enum.CraftingReagentType and Enum.CraftingReagentType.Basic
    for _, slot in ipairs(slots) do
        local slotType = plain(slot.reagentType)
        if not basic or slotType == basic or slotType == nil then
            local reagents = plain(slot.reagents)
            local reagent = type(reagents) == "table" and plain(reagents[1])
            local item, quantity = reagent and plain(reagent.itemID), plain(slot.quantityRequired)
            if not positive(item) or not positive(quantity) then return end
            materials[item] = (materials[item] or 0) + quantity
        end
    end
    return materials
end)

A.knowsRecipe = A.traceCallback("Professions.lua:155:A.knowsRecipe", function(author, spell)
    local profile = A.db.professions[author]
    if not profile then return false end
    for _, prof in pairs(profile.list) do
        if prof.recipes and prof.recipes[spell] ~= nil then return true end
    end
    return false
end)

A.recipeMaterials = A.traceCallback("Professions.lua:164:A.recipeMaterials", function(spell)
    local cache = TartaroDB.recipeMaterials
    if cache[spell] then return cache[spell] end
    local materials = readMaterials(spell)
    if materials then
        cache[spell] = materials
        return materials
    end
    local now = GetTime()
    if not materialRequests[spell] or now - materialRequests[spell] >= 15 then
        if A.send("FM", spell) then materialRequests[spell] = now end
    end
end)

A.shareRecipeMaterials = A.traceCallback("Professions.lua:178:A.shareRecipeMaterials", function(spell)
    if not positive(spell) or not A.knowsRecipe(A.self, spell) then return end
    local materials = TartaroDB.recipeMaterials[spell] or readMaterials(spell)
    if not materials then return end
    local parts = {}
    for _, item in ipairs(sortedKeys(materials)) do parts[#parts + 1] = item .. ":" .. materials[item] end
    A.send("FR", spell, #parts > 0 and table.concat(parts, ".") or "-")
end)

A.receiveRecipeMaterials = A.traceCallback("Professions.lua:187:A.receiveRecipeMaterials", function(author, spell, data)
    if not positive(spell) or not materialRequests[spell] or not A.knowsRecipe(author, spell)
        or not data or TartaroDB.recipeMaterials[spell] then return end
    local materials = {}
    if data ~= "-" then
        for entry in (data .. "."):gmatch("([^.]*)%.") do
            local item, qty = entry:match("^(%d+):(%d+)$")
            item, qty = tonumber(item), tonumber(qty)
            if not positive(item) or not positive(qty) then return end
            materials[item] = qty
        end
    end
    TartaroDB.recipeMaterials[spell] = materials
    A.refreshProfessions(true)
end)

local readLevels; readLevels = A.traceCallback("Professions.lua:203:readLevels", function(old, trustDrops)
    local result = {}
    if not GetProfessions or not GetProfessionInfo then return old end
    local indexes = {GetProfessions()}
    for slot = 1, 6 do
        local index = plain(indexes[slot])
        if index then
            local name, _, rank, maximum, _, _, id = GetProfessionInfo(index)
            name, rank, maximum, id = plain(name), plain(rank), plain(maximum), plain(id)
            if positive(id) and type(name) == "string" and type(rank) == "number" then
                local previous = old[id]
                result[id] = {name = A.clean(name), rank = rank, maximum = math.max(rank, tonumber(maximum) or 0),
                    category = slot > 2 and "S" or (gathering[id] and "G" or "F"),
                    canCraft = not withoutRecipes[id] or previous and previous.recipes ~= nil,
                    recipes = previous and previous.recipes}
            end
        end
    end
    if not trustDrops then
        for id, prof in pairs(old) do
            if not result[id] then result[id] = prof end
        end
    end
    return result
end)

local scanOpen; scanOpen = A.traceCallback("Professions.lua:229:scanOpen", function(professions, catalogs)
    if try(trade.IsTradeSkillReady) ~= true or try(trade.IsDataSourceChanging) then return end
    if try(trade.IsTradeSkillLinked) or try(trade.IsTradeSkillGuild) or try(trade.IsTradeSkillGuildMember)
        or try(trade.IsNPCCrafting) then return end
    local id = professionID(try(trade.GetChildProfessionInfo)) or professionID(try(trade.GetBaseProfessionInfo))
    local prof = id and professions[id]
    if not prof then return end
    local ids = try(trade.GetAllRecipeIDs)
    local complete = type(ids) == "table" and #ids > 0
    if not complete then ids = try(trade.GetFilteredRecipeIDs) end
    if type(ids) ~= "table" or #ids == 0 then return end
    local catalog, recipes, read = {}, {}, 0
    for _, value in ipairs(ids) do
        local spell = plain(value)
        local info = positive(spell) and try(trade.GetRecipeInfo, spell)
        if type(info) == "table" then
            read = read + 1
            if not plain(info.isDummyRecipe) then
                local learned = plain(info.learned)
                if learned == true or not isKnown(spell) then catalog[spell] = recipeItem(spell) end
                if learned == true then
                    recipes[spell] = catalog[spell]
                    if not TartaroDB.recipeMaterials[spell] then TartaroDB.recipeMaterials[spell] = readMaterials(spell) end
                end
            end
        end
    end
    if read == 0 then return end
    if complete and read == #ids and next(catalog) then catalogs[id] = catalog end
    -- Partial reads can add known recipes without erasing the last complete list.
    if not complete or read < #ids or not next(recipes) then
        for spell, item in pairs(prof.recipes or {}) do recipes[spell] = recipes[spell] or item end
    end
    prof.canCraft, prof.recipes = true, recipes
end)

local scan; scan = A.traceCallback("Professions.lua:265:scan", function()
    scheduled = false
    if not A.db then return end
    A.invalidate("recipeStatus")
    local own = A.db.professions[A.self]
    local professions = readLevels(own and own.list or {}, GetTime() - openedAt >= 10)
    local catalogs = TartaroDB.professionCatalogs
    scanOpen(professions, catalogs)
    for id, prof in pairs(professions) do
        local catalog = catalogs[id]
        if prof.canCraft and catalog then
            local recipes = {}
            for spell, item in pairs(prof.recipes or {}) do recipes[spell] = item end
            for spell, item in pairs(catalog) do
                if isKnown(spell) then recipes[spell] = (recipes[spell] ~= 0 and recipes[spell]) or item end
            end
            prof.recipes = recipes
        end
    end
    for spell in pairs(learnedRecipes) do
        local id = professionID(try(trade.GetProfessionInfoByRecipeID, spell))
        local prof = id and professions[id]
        if prof then
            prof.recipes = prof.recipes or {}
            local item = recipeItem(spell)
            prof.recipes[spell] = item > 0 and item or prof.recipes[spell] or 0
            prof.canCraft = true
            learnedRecipes[spell] = nil
        end
    end
    local data = encode(professions)
    if not own or data ~= own.data then
        local rev = math.max(GetServerTime() * 100, own and own.rev + 1 or 0)
        A.db.professions[A.self] = {rev = rev, data = data, list = professions}
        A.invalidateRecipeCatalog()
        A.shareProfessions()
        A.refreshProfessions()
    end
end)

local scheduleScan; scheduleScan = A.traceCallback("Professions.lua:305:scheduleScan", function()
    if scheduled then return end
    scheduled = true
    A.invalidate("recipeStatus")
    C_Timer.After(0.5, scan)
end)

A.professionGuildChanged = A.traceCallback("Professions.lua:312:A.professionGuildChanged", function()
    pending, incoming, openedAt, learnedRecipes = nil, {}, GetTime(), {}
    A.invalidateRecipeCatalog()
    if not A.db then return end
    TartaroDB.professionCatalogs = TartaroDB.professionCatalogs or {}
    TartaroDB.recipeMaterials = TartaroDB.recipeMaterials or {}
    materialRequests = {}
    scheduleScan()
    local db = A.db
    C_Timer.After(11, A.traceCallback("Professions.lua:321:callback", function()
        if A.db == db then scheduleScan() end
    end))
    C_Timer.After(4, A.traceCallback("Professions.lua:324:callback", function()
        if A.db == db then A.send("FQ"); A.shareProfessions() end
    end))
    C_Timer.After(35, A.traceCallback("Professions.lua:327:callback", function()
        if A.db == db then A.send("FQ") end
    end))
end)

local itemRequests = {}
A.professionItem = A.traceCallback("Professions.lua:333:A.professionItem", function(item)
    if item == 0 then return end
    local getInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo
    local name, quality, icon, binding
    if getInfo then
        local ok, itemName, _, rarity, _, _, _, _, _, _, texture, _, _, _, bindType = A.debugPcall("Professions.lua:338:pcall", getInfo, item)
        if ok then name, quality, icon, binding = plain(itemName), plain(rarity), plain(texture), plain(bindType) end
    end
    if not name then
        local now = GetTime()
        if not itemRequests[item] or now - itemRequests[item] >= 15 then
            itemRequests[item] = now
            try(C_Item and C_Item.RequestLoadItemDataByID, item)
        end
    end
    return name, quality, icon, binding
end)

A.professionRecipeNames = A.traceCallback("Professions.lua:351:A.professionRecipeNames", function(spell, item)
    local info = try(trade.GetRecipeInfo, spell)
    local recipe = type(info) == "table" and plain(info.name)
    recipe = recipe or try(C_Spell and C_Spell.GetSpellName, spell) or try(GetSpellInfo, spell)
    local object
    if item > 0 then
        object = try(C_Item and C_Item.GetItemNameByID, item) or A.professionItem(item)
    end
    return recipe or object or ("Receta " .. spell), object
end)

A.professionItemCount = A.traceCallback("Professions.lua:362:A.professionItemCount", function(item)
    return try((C_Item and C_Item.GetItemCount) or GetItemCount, item) or 0
end)

A.recipeSearchState = A.traceCallback("Professions.lua:366:A.recipeSearchState", function()
    if scheduled then return "loading", "scan" end
    for author, transfer in pairs(incoming or {}) do
        if A.members[author] and transfer.untilTime > GetTime() then
            return "loading", "transfer"
        end
    end
    local hasRecipes, missingItems = false, false
    local getInfo = C_Item and C_Item.GetItemInfo or GetItemInfo
    for author, profile in pairs(A.db and A.db.professions or {}) do
        if A.members[author] then
            for _, profession in pairs(profile.list) do
                for _, item in pairs(profession.recipes or {}) do
                    hasRecipes = true
                    if item > 0 and itemRequests[item] and not try(getInfo, item) then missingItems = true end
                end
            end
        end
    end
    if missingItems then
        return "metadata", "items"
    end
    return hasRecipes and "ready" or "empty"
end)

local frame = CreateFrame("Frame")
for _, event in ipairs({"SKILL_LINES_CHANGED", "LEARNED_SPELL_IN_SKILL_LINE", "SPELLS_CHANGED",
    "TRADE_SKILL_SHOW", "TRADE_SKILL_LIST_UPDATE", "TRADE_SKILL_DATA_SOURCE_CHANGED", "NEW_RECIPE_LEARNED",
    "GET_ITEM_INFO_RECEIVED", "BAG_UPDATE_DELAYED"}) do
    A.debugPcall("Professions.lua:395:pcall", frame.RegisterEvent, frame, event)
end
frame:SetScript("OnEvent", A.traceCallback("Professions.lua:397:callback", function(_, event, id, success)
    if not A.db or not learnedRecipes then return end
    id = plain(id)
    if event == "GET_ITEM_INFO_RECEIVED" then
        if id and itemRequests[id] then
            if plain(success) == false or not A.professionItem(id) then
                A.invalidate("recipeStatus")
                return
            end
            itemRequests[id] = nil
            A.refreshRecipeItem(id)
            A.refreshProfessions()
            A.refreshProfessions(true)
        end
        return
    end
    if event == "BAG_UPDATE_DELAYED" then A.refreshProfessions(true); return end
    if event == "NEW_RECIPE_LEARNED" and positive(id) then learnedRecipes[id] = true end
    scheduleScan()
end))
C_Timer.NewTicker(0.7, A.traceCallback("Professions.lua:417:callback", function()
    if not pending or A.db ~= pending.db then return end
    local start = (pending.index - 1) * partSize + 1
    if A.sendProfessionPart("F", pending.rev, pending.index, pending.total, pending.data:sub(start, start + partSize - 1)) then
        pending.index = pending.index + 1
        if pending.index > pending.total then pending = nil end
    end
end))
if A.traceLoad then A.traceLoad("module.end", "Professions.lua") end
