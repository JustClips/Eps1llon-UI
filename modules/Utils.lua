local Utils = {}

-- Basic text coercion
function Utils.asText(value, default)
    local t = typeof(value)
    if t == "string" then return value end
    if t == "number" or t == "boolean" then return tostring(value) end
    return default or ""
end

-- Function presence check
local function _hasFunc(f)
    return typeof(f) == "function"
end
Utils.hasFunc = _hasFunc

-- Wait compatibility
function Utils.wait(seconds)
    if _hasFunc(task and task.wait) then
        return task.wait(seconds)
    end
    if _hasFunc(wait) then
        return wait(seconds)
    end
    local rs = game:GetService("RunService")
    if seconds == nil then
        return rs.Heartbeat:Wait()
    end
    local t0 = tick()
    repeat rs.Heartbeat:Wait() until (tick() - t0) >= (seconds or 0)
    return seconds or 0
end

-- Delay compatibility
function Utils.delay(seconds, fn)
    if not _hasFunc(fn) then return end
    if _hasFunc(task and task.delay) then
        return task.delay(seconds, fn)
    end
    if _hasFunc(delay) then
        return delay(seconds, fn)
    end
    if _hasFunc(spawn) then
        spawn(function()
            Utils.wait(seconds)
            pcall(fn)
        end)
    else
        pcall(fn)
    end
end

function Utils.defer(fn)
    if typeof(fn) ~= "function" then return end
    if _hasFunc(task and task.defer) then
        return task.defer(fn)
    end
    if _hasFunc(spawn) then
        return spawn(fn)
    end
    pcall(fn)
end

-- Clipboard helpers
function Utils.copyToClipboard(text)
    if typeof(text) ~= "string" then return false end
    if _hasFunc(setclipboard) then
        local ok = pcall(setclipboard, text)
        if ok then return true end
    end
    if _hasFunc(toclipboard) then
        local ok = pcall(toclipboard, text)
        if ok then return true end
    end
    return false
end

-- Shared env helpers
function Utils.getSharedEnvironment()
    if typeof(getgenv) == "function" then
        local ok, env = pcall(getgenv)
        if ok and typeof(env) == "table" then
            return env
        end
    end
    return nil
end

-- JSON helpers
do
    local HttpService = game:GetService("HttpService")
    function Utils.encodeJSON(data)
        local ok, json = pcall(HttpService.JSONEncode, HttpService, data)
        if ok then return json end
        return nil
    end
    function Utils.decodeJSON(data)
        local ok, decoded = pcall(HttpService.JSONDecode, HttpService, data)
        if ok then return decoded end
        return nil
    end
end

-- KeyCode helpers
function Utils.keycodeToString(kc)
    if typeof(kc) == "EnumItem" then
        return kc.Name
    elseif typeof(kc) == "string" then
        return kc
    end
    return "None"
end

function Utils.stringToKeycode(s)
    if typeof(s) == "EnumItem" then return s end
    if typeof(s) == "string" and Enum.KeyCode[s] then
        return Enum.KeyCode[s]
    end
    return nil
end

-- Table deep copy/merge (local utilities for modules)
function Utils.deepCopy(tbl)
    if typeof(tbl) ~= "table" then return tbl end
    local copy = {}
    for k, v in pairs(tbl) do
        if typeof(v) == "table" then
            copy[k] = Utils.deepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

function Utils.deepMerge(target, source)
    if typeof(target) ~= "table" then target = {} end
    if typeof(source) ~= "table" then return target end
    for key, value in pairs(source) do
        if typeof(value) == "table" and typeof(target[key]) == "table" then
            Utils.deepMerge(target[key], value)
        else
            target[key] = value
        end
    end
    return target
end

return Utils

