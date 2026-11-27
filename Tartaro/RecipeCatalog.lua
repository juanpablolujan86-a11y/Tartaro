local _, A = ...
if A.traceLoad then A.traceLoad("module.begin", "RecipeCatalog.lua") end
local entries, cached, itemEntries

local searchKey; searchKey = A.traceCallback("RecipeCatalog.lua:5:searchKey", function(value)
    local lowered = (strlower or string.lower)(value)
    local accents = {["á"]="a", ["é"]="e", ["í"]="i", ["ó"]="o", ["ú"]="u", ["ü"]="u",
        ["Á"]="a", ["É"]="e", ["Í"]="i", ["Ó"]="o", ["Ú"]="u", ["Ü"]="u"}
    for letter, replacement in pairs(accents) do lowered = lowered:gsub(letter, replacement) end
    return lowered
end)

A.invalidateRecipeCatalog = A.traceCallback("RecipeCatalog.lua:13:A.invalidateRecipeCatalog", function()
    entries, cached, itemEntries = nil, nil, nil
end)

A.invalidateRecipeSearch = A.traceCallback("RecipeCatalog.lua:17:A.invalidateRecipeSearch", function()
    cached = nil
end)

local updateMetadata; updateMetadata = A.traceCallback("RecipeCatalog.updateMetadata", function(info)
    local name, object = A.professionRecipeNames(info.spell, info.item)
    local _, quality, icon, binding = A.professionItem(info.item)
    local changed = info.name ~= name or info.object ~= object or info.quality ~= quality
        or info.icon ~= icon or info.binding ~= binding
    if changed then
        info.name, info.object, info.quality, info.icon, info.binding = name, object, quality, icon, binding
        info.searchName, info.sortName = searchKey(name), searchKey(object or name)
        info.searchObject = object and searchKey(object)
    end
    return changed
end)

A.refreshRecipeItem = A.traceCallback("RecipeCatalog.refreshRecipeItem", function(item)
    local affected = itemEntries and itemEntries[item]
    if not affected then return end
    local changed = false
    for _, info in ipairs(affected) do
        if updateMetadata(info) then changed = true end
    end
    if changed then cached = nil end
    A.debugLog("catalog.item", "RecipeCatalog.refreshRecipeItem", item, #affected, changed)
end)

local buildCatalog; buildCatalog = A.traceCallback("RecipeCatalog.lua:45:buildCatalog", function()
    local index, metadata = {}, {}
    itemEntries = {}
    for member in pairs(A.members) do
      local profile = A.db.professions[member]
      if profile then
        local professions = {}
        index[member] = professions
        for id, profession in pairs(profile.list) do
            local recipes = {}
            for spell, item in pairs(profession.recipes or {}) do
                local key = spell .. ":" .. item
                local info = metadata[key]
                if not info then
                    info = {spell = spell, item = item}
                    updateMetadata(info)
                    metadata[key] = info
                    if item > 0 then
                        itemEntries[item] = itemEntries[item] or {}
                        itemEntries[item][#itemEntries[item] + 1] = info
                    end
                end
                recipes[#recipes + 1] = info
            end
            if #recipes > 0 then professions[#professions + 1] = {id = id, profession = profession, recipes = recipes} end
        end
      end
    end
    A.debugLog("catalog.build", "RecipeCatalog.buildCatalog")
    return index
end)

A.searchRecipes = A.traceCallback("RecipeCatalog.lua:77:A.searchRecipes", function(input, filters)
    local query = searchKey(input):match("^%s*(.-)%s*$")
    local wanted, professionID, rarity, hideBound = filters.member, filters.profession, filters.rarity, filters.hideBound
    if cached and cached.query == query and cached.member == wanted and cached.profession == professionID
        and cached.rarity == rarity and cached.hideBound == hideBound then return cached.results, cached.bySpell end
    entries = entries or buildCatalog()
    local members = {}
    for id, list in pairs(entries) do
        local member = A.members[id]
        if member and #list > 0 then
            local online = member.online == true or member.id == A.self
            if not wanted or wanted == id or wanted == "online" and online or wanted == "offline" and member.online == false then
                members[#members + 1] = member
            end
        end
    end
    table.sort(members, A.traceCallback("RecipeCatalog.lua:93:callback", function(left, right)
        if (left.online == true) ~= (right.online == true) then return left.online == true end
        return left.name < right.name
    end))
    local results, bySpell, matching = {}, {}, {}
    local itemQuery = tonumber(query:match("|hitem:(%d+)"))
    local bound = Enum and Enum.ItemBind and Enum.ItemBind.OnAcquire or 1
    for _, member in ipairs(members) do
        local matchesMember = not itemQuery and searchKey(member.name):find(query, 1, true)
        for _, profession in ipairs(entries[member.id]) do
          if not professionID or professionID == profession.id then
            for _, info in ipairs(profession.recipes) do
              if (not rarity or info.quality == rarity) and (not hideBound or info.binding ~= bound) then
                local matches = matching[info]
                if matches == nil then
                    if itemQuery then matches = info.item == itemQuery
                    else matches = not not (info.searchName:find(query, 1, true)
                        or info.searchObject and info.searchObject:find(query, 1, true)) end
                    matching[info] = matches
                end
                if matchesMember or matches then
                    local result = bySpell[info.spell]
                    if not result then
                        result = {spell = info.spell, item = info.item, name = info.name, object = info.object,
                            icon = info.icon, sortName = info.sortName, crafters = {}, profession = profession.profession.name, online = 0}
                        bySpell[info.spell] = result
                        results[#results + 1] = result
                    end
                    result.crafters[#result.crafters + 1] = {member = member, profession = profession.profession}
                    if member.online == true or member.id == A.self then result.online = result.online + 1 end
                end
              end
            end
          end
        end
    end
    table.sort(results, A.traceCallback("RecipeCatalog.lua:129:callback", function(left, right)
        return left.sortName < right.sortName or left.sortName == right.sortName and left.spell < right.spell
    end))
    cached = {query = query, member = wanted, profession = professionID, rarity = rarity,
        hideBound = hideBound, results = results, bySpell = bySpell}
    return results, bySpell
end)

if A.traceLoad then A.traceLoad("module.end", "RecipeCatalog.lua") end
