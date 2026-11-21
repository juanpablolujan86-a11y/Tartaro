local _, A = ...
local week, history = 7 * 86400, 30 * 86400

function A.purgeExpired()
    if not A.db then return 0 end
    local db, now, removed = A.db, GetServerTime(), A.purgeOrderState()
    local function purge(data, expiry, onRemove)
        for id, record in pairs(data or {}) do
            local limit = expiry(record, id)
            if type(limit) == "number" and limit <= now then
                data[id] = nil
                removed = removed + 1
                if onRemove then onRemove(id) end
            end
        end
    end
    purge(db.donations, function(record) return record.created and record.created + week end)
    purge(db.events, function(record) return record.when and record.when + history end, function(id)
        db.signups[id], db.eventReminders[id] = nil, nil
    end)
    local function deletionExpiry(record)
        if type(record.when) == "number" and type(record.rev) == "number" then
            return math.max(record.when, math.floor(record.rev / 100)) + history
        end
    end
    purge(db.deletedEvents, deletionExpiry)
    purge(db.sharedEventDeletes, deletionExpiry)
    purge(db.notices, function(record) return record.when and record.when + history end)
    for id, signups in pairs(db.signups or {}) do
        if not db.events[id] then
            purge(signups, function(record) return record.rev and math.floor(record.rev / 100) + history end)
            if not next(signups) then db.signups[id] = nil end
        end
    end
    if removed > 0 then
        A.invalidateDonations()
        A.invalidate("events")
        A.invalidate("notices")
    end
    return removed
end

C_Timer.NewTicker(60, function() A.purgeExpired() end)
