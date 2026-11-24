local _, A = ...
if A.traceLoad then A.traceLoad("module.begin", "Cleanup.lua") end
local week, history = 7 * 86400, 30 * 86400

A.purgeExpired = A.traceCallback("Cleanup.lua:5:A.purgeExpired", function()
    if not A.db then return 0 end
    local db, now, removed = A.db, GetServerTime(), A.purgeOrderState()
    local purge; purge = A.traceCallback("Cleanup.lua:8:purge", function(data, expiry, onRemove)
        for id, record in pairs(data or {}) do
            local limit = expiry(record, id)
            if type(limit) == "number" and limit <= now then
                data[id] = nil
                removed = removed + 1
                if onRemove then onRemove(id) end
            end
        end
    end)
    purge(db.donations, A.traceCallback("Cleanup.lua:18:callback", function(record) return record.created and record.created + week end))
    purge(db.events, A.traceCallback("Cleanup.lua:19:callback", function(record) return record.when and record.when + history end), A.traceCallback("Cleanup.lua:19:callback", function(id)
        db.signups[id], db.eventReminders[id] = nil, nil
    end))
    local deletionExpiry; deletionExpiry = A.traceCallback("Cleanup.lua:22:deletionExpiry", function(record)
        if type(record.when) == "number" and type(record.rev) == "number" then
            return math.max(record.when, math.floor(record.rev / 100)) + history
        end
    end)
    purge(db.deletedEvents, deletionExpiry)
    purge(db.sharedEventDeletes, deletionExpiry)
    purge(db.notices, A.traceCallback("Cleanup.lua:29:callback", function(record) return record.when and record.when + history end))
    for id, signups in pairs(db.signups or {}) do
        if not db.events[id] then
            purge(signups, A.traceCallback("Cleanup.lua:32:callback", function(record) return record.rev and math.floor(record.rev / 100) + history end))
            if not next(signups) then db.signups[id] = nil end
        end
    end
    if removed > 0 then
        A.invalidateDonations()
        A.invalidate("events")
        A.invalidate("notices")
    end
    return removed
end)

C_Timer.NewTicker(60, A.traceCallback("Cleanup.lua:44:callback", function() A.purgeExpired() end))
if A.traceLoad then A.traceLoad("module.end", "Cleanup.lua") end
