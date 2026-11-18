local _, A = ...
local roleOrder = {"TANK", "HEALER", "DAMAGER"}
local druidOrder = {"FERAL", "BALANCE", "RESTORATION"}
local roles = {TANK = "Tanque", HEALER = "Sanador", DAMAGER = "DPS", UNKNOWN = "Sin datos"}
local druidRoles = {FERAL = "Feral", BALANCE = "Balance", RESTORATION = "Restauración"}

local function addCombinedLabels(labels, order)
    for i, first in ipairs(order) do
        for j = i + 1, #order do
            local second = order[j]
            labels[first .. "/" .. second] = labels[first] .. "/" .. labels[second]
        end
    end
    labels[table.concat(order, "/")] = table.concat({labels[order[1]], labels[order[2]], labels[order[3]]}, "/")
end
addCombinedLabels(roles, roleOrder)
addCombinedLabels(druidRoles, druidOrder)

function A.roleLabel(role, class)
    if class == "DRUID" then return druidRoles[role] or roles.UNKNOWN end
    return roles[role] or druidRoles[role] or roles.UNKNOWN
end
local casterClasses = {HUNTER = true, MAGE = true, ROGUE = true}
local legacyDruidRoles = {FERAL = "UNKNOWN", BALANCE = "DAMAGER", RESTORATION = "HEALER"}

-- Use the displayed branch name for hybrid classes. Some branches support multiple roles.
local branchRoles = {
    WARRIOR = {Arms = "DAMAGER", Armas = "DAMAGER", Fury = "DAMAGER", Furia = "DAMAGER",
        Protection = "TANK", ["Protección"] = "TANK"},
    PALADIN = {Protection = "TANK", ["Protección"] = "TANK", Retribution = "DAMAGER", ["Reprensión"] = "DAMAGER"},
    DRUID = {Feral = "FERAL", ["Feral Combat"] = "FERAL", ["Combate feral"] = "FERAL",
        Balance = "BALANCE", Equilibrio = "BALANCE", Restoration = "RESTORATION", ["Restauración"] = "RESTORATION"},
    PRIEST = {Shadow = "DAMAGER", Sombras = "DAMAGER", Holy = "HEALER", Sagrado = "HEALER"},
    SHAMAN = {Elemental = "DAMAGER", Restoration = "HEALER", ["Restauración"] = "HEALER"},
    WARLOCK = {Affliction = "DAMAGER", ["Aflicción"] = "DAMAGER", Destruction = "DAMAGER", ["Destrucción"] = "DAMAGER"},
}

local function talentRole()
    local _, class = UnitClass("player")
    local spec, talents, traits = C_SpecializationInfo, C_ClassTalents, C_Traits
    if not traits or not traits.GetConfigInfo or not traits.GetGroupDisplayInfoByTreeID
        or not traits.GetGroupCurrencyInfo then return end
    local configID
    if spec and spec.GetCombatConfigIDForSpecGroup and spec.GetActiveSpecGroup then
        local group = spec.GetActiveSpecGroup()
        if group then configID = spec.GetCombatConfigIDForSpecGroup(group) end
    end
    if not configID and talents and talents.GetActiveConfigID then configID = talents.GetActiveConfigID() end
    local config = configID and traits.GetConfigInfo(configID)
    local tree = config and config.treeIDs and config.treeIDs[1]
    local groups = tree and traits.GetGroupDisplayInfoByTreeID(tree)
    if not groups or #groups == 0 then return end
    local ids, names = {}, {}
    for _, group in ipairs(groups) do
        ids[#ids + 1] = group.groupID
        names[group.groupID] = group.displayName
    end
    local highest, pointsByRole = 0, {}
    for _, group in ipairs(traits.GetGroupCurrencyInfo(configID, ids) or {}) do
        local currency = group.currencyInfos and group.currencyInfos[1]
        local spent = currency and currency.spent or 0
        local branch = names[group.traitNodeGroupID]
        if branch and spent > 0 then
            highest = math.max(highest, spent)
            local role = casterClasses[class] and "DAMAGER" or branchRoles[class] and branchRoles[class][branch]
            if role then pointsByRole[role] = math.max(pointsByRole[role] or 0, spent) end
        end
    end
    local primary, primaryPoints
    local nearby = {}
    for _, role in ipairs(class == "DRUID" and druidOrder or roleOrder) do
        local spent = pointsByRole[role]
        if spent and highest - spent <= 3 then
            nearby[#nearby + 1] = role
            if not primaryPoints or spent > primaryPoints then primary, primaryPoints = role, spent end
        end
    end
    if primary then return table.concat(nearby, "/"), legacyDruidRoles[primary] or primary end
end

function A.receiveRole(member, role, combined)
    if roles[combined] or druidRoles[combined] then role = combined end
    if (roles[role] or druidRoles[role]) and A.db.roles[member] ~= role then
        A.db.roles[member] = role
        A.refreshMembers()
    end
end

function A.shareRole(force)
    if not A.db or not A.me then return end
    local ok, role, primary = pcall(talentRole)
    if not ok then role = nil end
    if not role and UnitGroupRolesAssigned then
        local assigned = UnitGroupRolesAssigned("player")
        if (not issecretvalue or not issecretvalue(assigned)) and roles[assigned] then role = assigned end
    end
    role = role or "UNKNOWN"
    local changed = A.db.roles[A.self] ~= role
    if force or changed then
        local sent
        if primary and primary ~= role then
            sent = A.send("H", primary, role)
        else
            sent = A.send("H", role)
        end
        if sent then A.receiveRole(A.self, role) end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("TRAIT_CONFIG_UPDATED")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:SetScript("OnEvent", function()
    if InCombatLockdown and InCombatLockdown() then return end
    A.shareRole()
end)
