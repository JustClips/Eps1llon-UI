return function(Library)
    -- Provide typeof fallback for non-Roblox Lua (executors usually have typeof)
    local _typeof = typeof or function(v) return type(v) end

    -- Expose helpers
    function Library.asText(value, default)
        local t = _typeof(value)
        if t == "string" then return value end
        if t == "number" or t == "boolean" then return tostring(value) end
        return default or ""
    end

    function Library._hasFunc(f)
        return _typeof(f) == "function"
    end

    function Library._waitCompat(seconds)
        if Library._hasFunc(task and task.wait) then
            return task.wait(seconds)
        end
        if Library._hasFunc(wait) then
            return wait(seconds)
        end
        local rs = Library.Services.RunService
        if seconds == nil then
            return rs.Heartbeat:Wait()
        end
        local t0 = tick()
        repeat rs.Heartbeat:Wait() until (tick() - t0) >= (seconds or 0)
        return seconds or 0
    end

    function Library._delayCompat(seconds, fn)
        if _typeof(fn) ~= "function" then return end
        if Library._hasFunc(task and task.delay) then
            return task.delay(seconds, fn)
        end
        if Library._hasFunc(delay) then
            return delay(seconds, fn)
        end
        if Library._hasFunc(spawn) then
            spawn(function()
                Library._waitCompat(seconds)
                pcall(fn)
            end)
        else
            pcall(fn)
        end
    end

    function Library._copyToClipboard(text)
        if _typeof(text) ~= "string" then return false end
        if Library._hasFunc(setclipboard) then
            local ok = pcall(setclipboard, text)
            if ok then return true end
        end
        if Library._hasFunc(toclipboard) then
            local ok = pcall(toclipboard, text)
            if ok then return true end
        end
        return false
    end

    function Library._deferCompat(fn)
        if _typeof(fn) ~= "function" then return end
        if Library._hasFunc(task and task.defer) then
            return task.defer(fn)
        end
        if Library._hasFunc(spawn) then
            return spawn(fn)
        end
        pcall(fn)
    end

    function Library.deepCopy(tbl)
        if _typeof(tbl) ~= "table" then
            return tbl
        end
        local result = {}
        for key, value in pairs(tbl) do
            result[key] = Library.deepCopy(value)
        end
        return result
    end

    function Library.deepMerge(target, source)
        for key, value in pairs(source) do
            if _typeof(value) == "table" and _typeof(target[key]) == "table" then
                Library.deepMerge(target[key], value)
            else
                target[key] = value
            end
        end
        return target
    end

    function Library._getSharedEnvironment()
        if _typeof(getgenv) == "function" then
            local ok, env = pcall(getgenv)
            if ok and _typeof(env) == "table" then
                return env
            end
        end
        return nil
    end

    function Library._encodeJSON(data)
        local ok, json = pcall(Library.Services.HttpService.JSONEncode, Library.Services.HttpService, data)
        if ok then return json end
        return nil
    end

    function Library._decodeJSON(data)
        local ok, decoded = pcall(Library.Services.HttpService.JSONDecode, Library.Services.HttpService, data)
        if ok then return decoded end
        return nil
    end

    function Library.keycodeToString(kc)
        if _typeof(kc) == "EnumItem" then
            return kc.Name
        elseif _typeof(kc) == "string" then
            return kc
        end
        return "None"
    end

    function Library.stringToKeycode(s)
        if _typeof(s) == "EnumItem" then return s end
        if _typeof(s) == "string" and Enum.KeyCode[s] then
            return Enum.KeyCode[s]
        end
        return nil
    end

    function Library:SetToggleKey(key)
        local kc = key
        if _typeof(key) == "string" then
            kc = Library.stringToKeycode(key)
        end
        if _typeof(kc) == "EnumItem" then
            self.Config.ToggleKey = kc
            return true
        end
        return false
    end
end
