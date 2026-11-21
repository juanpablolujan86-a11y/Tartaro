local _, A = ...
A.groupCategories = {
    {key = "DUNGEON", label = "Mazmorra", categoryID = 2},
    {key = "RAID", label = "Banda (Raid)", categoryID = 3},
    {key = "BG", label = "BGs", categoryID = 8},
    {key = "QUEST", label = "Quest (Misiones)"},
    {key = "OTHER", label = "Otros"},
}

local function safe(fn, ...)
    if not fn then return end
    local ok, result = pcall(fn, ...)
    if ok and (not issecretvalue or not issecretvalue(result)) then return result end
end

function A.groupCategory(key)
    for _, category in ipairs(A.groupCategories) do
        if category.key == key then return category end
    end
end

function A.groupDestinations(key)
    local category = A.groupCategory(key)
    if key == "QUEST" then
        local list, seen = {}, {}
        local api = C_QuestLog
        local count = safe(api and api.GetNumQuestLogEntries)
        for index = 1, type(count) == "number" and math.min(count, 1000) or 0 do
            local info = safe(api.GetInfo, index)
            if type(info) == "table" and not info.isHeader and type(info.questID) == "number"
                and info.questID > 0 and type(info.title) == "string" and not seen[info.questID] then
                seen[info.questID] = true
                list[#list + 1] = {id = info.questID, name = info.title}
            end
        end
        table.sort(list, function(left, right) return left.name < right.name end)
        return list
    end
    if not category or not category.categoryID then return {} end
    local api = C_LFGList
    local list, seen = {}, {}
    if key == "BG" then
        local count = safe(GetNumBattlegroundTypes)
        for index = 1, type(count) == "number" and math.min(count, 100) or 0 do
            local info = safe(C_PvP and C_PvP.GetBattlegroundInfo, index)
            local name = type(info) == "table" and safe(function() return info.name end)
            local maximum = type(info) == "table" and safe(function() return info.maxPlayers end)
            if not name or not maximum then
                local ok, oldName, _, _, _, _, _, _, maxPlayers = pcall(GetBattlegroundInfo or function() end, index)
                if ok then name, maximum = name or oldName, maximum or maxPlayers end
            end
            if type(name) == "string" and name ~= "" and not seen[name] then
                seen[name] = true
                list[#list + 1] = {id = "bg:" .. name, name = name, maximum = maximum}
            end
        end
        table.sort(list, function(left, right) return left.name < right.name end)
        return list
    end
    local function collect()
        local ids = safe(api and api.GetAvailableActivities, category.categoryID, nil, 0)
        for _, id in ipairs(type(ids) == "table" and ids or {}) do
            local info = safe(api.GetActivityInfoTable, id)
            if info and info.categoryID == category.categoryID and type(info.fullName) == "string"
                and info.fullName ~= "" and not seen[info.fullName] then
                seen[info.fullName] = true
                list[#list + 1] = {id = id, name = info.fullName}
            end
        end
    end
    -- Read only the activities supplied by the running client.
    pcall(collect)
    table.sort(list, function(left, right) return left.name < right.name end)
    return list
end

function A.publishGroupSelection(key, destination, description, location, tanks, healers, damage, editing)
    local category = A.groupCategory(key)
    if not category then return nil, "Seleccioná el tipo de actividad." end
    local activity, maximum
    if key == "OTHER" then
        activity = A.clean(description)
        if activity == "" then return nil, "Describí la actividad." end
    else
        for _, entry in ipairs(A.groupDestinations(key)) do
            if entry.id == destination then activity, maximum = entry.name, entry.maximum; break end
        end
        if not activity then return nil, "Seleccioná un destino disponible para esta categoría." end
    end
    local values = {tanks, healers, damage}
    local counts, total = {}, 0
    for index, value in ipairs(values) do
        local count = value == "" and 0 or tonumber(value)
        if not count or count % 1 ~= 0 or count < 0 or count > 40 then
            return nil, "Cada rol admite un número entero entre 0 y 40."
        end
        counts[index], total = count, total + count
    end
    if #counts ~= 3 or total < 1 or total > 40 then return nil, "Indicá entre 1 y 40 jugadores que falten en total." end
    if key == "BG" then
        if type(maximum) ~= "number" or maximum % 1 ~= 0 or maximum < 1 or maximum > 40 then
            return nil, "El cliente todavía no informó la capacidad de esta BG."
        end
        if total > maximum then return nil, "Los cupos superan el máximo de " .. maximum .. " jugadores de esta BG." end
    end
    local needs = {}
    for index, count in ipairs(counts) do
        if count > 0 then needs[#needs + 1] = count .. " " .. A.eventRoles[A.eventRoleOrder[index]] end
    end
    local link
    if key == "QUEST" then
        link = safe(GetQuestLink, destination)
        if type(link) ~= "string" or not link:find("|Hquest:" .. destination .. ":", 1, true)
            or not link:find("|h", 1, true) or #link > 190 then
            return nil, "El enlace de la misión todavía no está disponible. Volvé a intentarlo."
        end
    end
    local group, err = A.publishGroup(category.label .. " · " .. activity, location, table.concat(needs, ", "),
        key == "BG" and {maximum = maximum, roles = counts} or nil, editing)
    if group then
        group.questLink = link
        group.selection = {category = key, destination = destination, description = description, counts = counts}
    end
    return group, err
end
