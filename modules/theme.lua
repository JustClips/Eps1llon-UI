return function(Library)
    local _typeof = typeof or function(v) return type(v) end
    local TweenService = Library.Services.TweenService

    -- Themes
    Library.Themes = {
        Dark = {
            bg = Color3.fromRGB(12, 14, 18),
            panel = Color3.fromRGB(15, 16, 21),
            panelHighlight = Color3.fromRGB(40, 42, 50),
            text = Color3.fromRGB(230, 235, 240),
            textActive = Color3.fromRGB(255, 255, 255),
            textDim = Color3.fromRGB(140, 146, 156),
            separator = Color3.fromRGB(255, 255, 255),
            accent = Color3.fromRGB(50, 130, 250),
            Success = Color3.fromRGB(39, 174, 96),
            Warning = Color3.fromRGB(242, 201, 76),
            Error = Color3.fromRGB(235, 87, 87),
            Info = Color3.fromRGB(50, 130, 250),
        },
    }

    Library.Theme = Library.Themes.Dark

    -- Accent management
    Library._accentTargets = {}
    Library._accentChangedCallbacks = {}
    function Library:_RegisterAccent(inst, property)
        if inst and inst[property] ~= nil then
            inst[property] = self.Theme.accent
            table.insert(self._accentTargets, { inst = inst, prop = property })
        end
    end
    function Library:_OnAccentChanged(cb)
        table.insert(self._accentChangedCallbacks, cb)
    end
    function Library:SetAccent(color)
        local named = {}
        named.blue   = Color3.fromRGB(50, 130, 250)
        named.red    = Color3.fromRGB(235, 87, 87)
        named.orange = Color3.fromRGB(255, 159, 67)
        named.purple = Color3.fromRGB(155, 89, 182)
        named.pink   = Color3.fromRGB(255, 99, 179)
        named.green  = Color3.fromRGB(39, 174, 96)

        local c = self.Theme.accent
        if _typeof(color) == "string" then
            local key = string.lower(color)
            c = named[key] or c
        elseif _typeof(color) == "Color3" then
            c = color
        end

        self.Theme.accent = c
        local saveName = nil
        for k, v in pairs(named) do if v == c then saveName = k break end end
        if self._SaveSetting then
            self:_SaveSetting("ui_accent_color", saveName or string.format("rgb(%d,%d,%d)", math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255)))
        end

        for _, ref in ipairs(self._accentTargets) do
            pcall(function() ref.inst[ref.prop] = c end)
        end
        for _, cb in ipairs(self._accentChangedCallbacks) do
            pcall(cb, c)
        end
    end

    -- CanvasGroup removal shim replacement
    local _groupBase = setmetatable({}, { __mode = "k" }) -- root -> { inst -> {prop->base} }
    local _groupAlphaObj = setmetatable({}, { __mode = "k" }) -- root -> NumberValue

    local function _gatherProps(inst)
        local props = {}
        if inst:IsA("GuiObject") then
            if inst.BackgroundTransparency ~= nil then props.BackgroundTransparency = inst.BackgroundTransparency end
            if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
                props.TextTransparency = inst.TextTransparency
                props.TextStrokeTransparency = inst.TextStrokeTransparency
            end
            if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
                props.ImageTransparency = inst.ImageTransparency
            end
            if inst:IsA("ScrollingFrame") then
                props.ScrollBarImageTransparency = inst.ScrollBarImageTransparency
            end
        elseif inst:IsA("UIStroke") then
            props.Transparency = inst.Transparency
        end
        return props
    end

    local function _collectGroupBase(root)
        local base = _groupBase[root]
        if not base then
            base = {}
            _groupBase[root] = base
            local function addOne(obj)
                local props = _gatherProps(obj)
                if next(props) ~= nil then
                    base[obj] = props
                end
            end
            addOne(root)
            for _, d in ipairs(root:GetDescendants()) do addOne(d) end
            root.DescendantAdded:Connect(function(d)
                local props = _gatherProps(d)
                if next(props) ~= nil then
                    base[d] = props
                    local alphaObj = _groupAlphaObj[root]
                    if alphaObj then
                        local a = alphaObj.Value or 0
                        for prop, baseVal in pairs(props) do
                            local final = baseVal + (1 - baseVal) * a
                            pcall(function() d[prop] = final end)
                        end
                    end
                end
            end)
            root.DescendantRemoving:Connect(function(d)
                base[d] = nil
            end)
        end
        return base
    end

    local function _applyGroupTransparency(root, alpha)
        local base = _collectGroupBase(root)
        for inst, props in pairs(base) do
            for prop, baseVal in pairs(props) do
                local final = baseVal + (1 - baseVal) * alpha
                pcall(function() inst[prop] = final end)
            end
        end
    end

    function Library:_EnsureGroupFader(root)
        if not root or not root.IsA or not root:IsA("GuiObject") then return nil end
        local alphaObj = _groupAlphaObj[root]
        if alphaObj and alphaObj.Parent then return alphaObj end
        alphaObj = Instance.new("NumberValue")
        alphaObj.Name = "GroupAlpha"
        alphaObj.Value = 0
        alphaObj.Parent = root
        _groupAlphaObj[root] = alphaObj
        _collectGroupBase(root)
        alphaObj:GetPropertyChangedSignal("Value"):Connect(function()
            _applyGroupTransparency(root, math.clamp(alphaObj.Value or 0, 0, 1))
        end)
        _applyGroupTransparency(root, alphaObj.Value)
        return alphaObj
    end

    function Library:_SetGroupTransparency(root, value)
        local nv = self:_EnsureGroupFader(root)
        if nv then nv.Value = math.clamp(tonumber(value) or 0, 0, 1) end
    end

    function Library:_TweenGroupTransparency(root, info, target)
        local nv = self:_EnsureGroupFader(root)
        if not nv then return nil end
        return TweenService:Create(nv, info, { Value = math.clamp(tonumber(target) or 0, 0, 1) })
    end
end

