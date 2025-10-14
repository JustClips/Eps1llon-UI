return function(Library)
    local _typeof = typeof or function(v) return type(v) end
    local HttpService = Library.Services.HttpService

    -- Auto-Save Properties
    Library.autoSaveEnabled = false
    Library.autoSaveFile = nil
    Library.autoSaveData = {}

    -- Localization
    Library.Locale = "en"
    Library.Locales = {
        en = {
            ["GUI.Settings"] = "GUI Settings",
            ["GUI.AutoSave"] = "Auto Save",
            ["GUI.SaveNow"] = "Save Now",
            ["GUI.MenuToggleKey"] = "Menu Toggle Key",
            ["GUI.AccentColor"] = "Accent Color",
            ["GUI.Language"] = "Language",
            ["GUI.LanguageChangedTitle"] = "Language",
            ["Common.Enabled"] = "Enabled",
            ["Common.Disabled"] = "Disabled",
            ["Notify.SettingsSaved"] = "Settings saved.",
            ["Notify.SaveFailed"] = "Failed to save settings.",
            ["Notify.JSONEncodeFailed"] = "JSON encode failed.",
            ["KeySystem.Title"] = "Verification",
            ["KeySystem.Description"] = "Please enter your key below to gain access.",
            ["KeySystem.Placeholder"] = "Enter your key here...",
            ["KeySystem.GetKey"] = "Get Key",
            ["KeySystem.VerifyKey"] = "Verify Key",
            ["KeySystem.CopySuccess"] = "Discord link copied!",
            ["KeySystem.CopyFallback"] = "Copy failed. Link: ",
            ["KeySystem.Verifying"] = "Verifying...",
            ["KeySystem.Success"] = "Success! Access Granted.",
            ["KeySystem.Error"] = "Invalid Key. Please try again.",
        },
        ru = {
            ["GUI.Settings"] = "Настройки GUI",
            ["GUI.AutoSave"] = "Автосохранение",
            ["GUI.SaveNow"] = "Сохранить сейчас",
            ["GUI.MenuToggleKey"] = "Клавиша меню",
            ["GUI.AccentColor"] = "Цвет акцента",
            ["GUI.Language"] = "Язык",
            ["GUI.LanguageChangedTitle"] = "Язык",
            ["Common.Enabled"] = "Включено",
            ["Common.Disabled"] = "Выключено",
            ["Notify.SettingsSaved"] = "Настройки сохранены.",
            ["Notify.SaveFailed"] = "Не удалось сохранить настройки.",
            ["Notify.JSONEncodeFailed"] = "Ошибка кодирования JSON.",
            ["KeySystem.Title"] = "Проверка",
            ["KeySystem.Description"] = "Введите ключ ниже, чтобы получить доступ.",
            ["KeySystem.Placeholder"] = "Введите ваш ключ...",
            ["KeySystem.GetKey"] = "Получить ключ",
            ["KeySystem.VerifyKey"] = "Проверить ключ",
            ["KeySystem.CopySuccess"] = "Ссылка Discord скопирована!",
            ["KeySystem.CopyFallback"] = "Не удалось скопировать. Ссылка: ",
            ["KeySystem.Verifying"] = "Проверка...",
            ["KeySystem.Success"] = "Успешно! Доступ предоставлен.",
            ["KeySystem.Error"] = "Неверный ключ. Попробуйте снова.",
        }
    }

    Library._languageChangedCallbacks = {}
    function Library:_T(key, fallback)
        local lang = self.Locale or "en"
        local dict = self.Locales[lang]
        local value = dict and dict[key]
        if _typeof(value) == "string" then return value end
        return fallback or key
    end

    function Library:_onLanguageChanged(cb)
        table.insert(self._languageChangedCallbacks, cb)
    end

    function Library:SetLanguage(code)
        if _typeof(code) ~= "string" then return false end
        local c = string.lower(code)
        if c ~= "en" and c ~= "ru" then return false end
        self.Locale = c
        if self._SaveSetting then self:_SaveSetting("ui_language", c) end
        for _, cb in ipairs(self._languageChangedCallbacks) do
            pcall(cb, c)
        end
        local name = (c == "ru") and "Русский" or "English"
        if self.Notify then
            self:Notify({ Title = self:_T("GUI.LanguageChangedTitle", "Language"), Text = name, Duration = 2 })
        end
        return true
    end

    -- User-facing translation hook
    function Library:_Translate(text)
        if _typeof(text) ~= "string" then return text end
        local cb = rawget(self, "TranslateCallback")
        if _typeof(cb) == "function" then
            local ok, out = pcall(cb, text, self.Locale)
            if ok and _typeof(out) == "string" and out ~= "" then
                return out
            end
        end
        return text
    end

    function Library:_BindLocaleText(instance, rawText)
        if not instance or _typeof(rawText) ~= "string" then return end
        local function apply()
            local newText = self:_Translate(rawText)
            pcall(function() instance.Text = newText end)
        end
        apply()
        self:_onLanguageChanged(function()
            apply()
        end)
    end

    function Library:_BindLocalePlaceholder(instance, rawText)
        if not instance or _typeof(rawText) ~= "string" then return end
        local function apply()
            local newText = self:_Translate(rawText)
            pcall(function() instance.PlaceholderText = newText end)
        end
        apply()
        self:_onLanguageChanged(function()
            apply()
        end)
    end

    function Library:SetTranslator(fn)
        if _typeof(fn) == "function" then
            self.TranslateCallback = fn
            return true
        end
        self.TranslateCallback = nil
        return false
    end

    function Library:AutoDetectLanguage(opts)
        opts = opts or {}
        local force = opts.Force or false
        local saved = self.autoSaveEnabled and self.autoSaveData and self.autoSaveData["ui_language"]
        if saved and not force then return saved end
        local code = "en"
        local ok, loc = pcall(function()
            local ls = game:GetService("LocalizationService")
            local players = game:GetService("Players")
            return (ls.RobloxLocaleId ~= "" and ls.RobloxLocaleId)
                or (ls.SystemLocaleId ~= "" and ls.SystemLocaleId)
                or (players.LocalPlayer and players.LocalPlayer.LocaleId)
                or "en-us"
        end)
        if ok and _typeof(loc) == "string" then
            loc = string.lower(loc)
            if string.sub(loc, 1, 2) == "ru" then code = "ru" end
        end
        self:SetLanguage(code)
        return code
    end

    -- Saving/Loading
    function Library:InitAutoSave(fileName)
        self.autoSaveEnabled = true
        self.autoSaveFile = fileName or "ui_autosave.json"
        self.autoSaveData = {}
        if _typeof(isfile) == "function" and _typeof(readfile) == "function" and isfile(self.autoSaveFile) then
            local ok, data = pcall(readfile, self.autoSaveFile)
            if ok and data and data ~= "" then
                local success, decoded = pcall(HttpService.JSONDecode, HttpService, data)
                if success and _typeof(decoded) == "table" then
                    self.autoSaveData = decoded
                    local savedLang = decoded["ui_language"]
                    if _typeof(savedLang) == "string" and (savedLang == "en" or savedLang == "ru") then
                        self.Locale = savedLang
                    end
                    local savedAccent = decoded["ui_accent_color"]
                    if savedAccent ~= nil then
                        pcall(function() self:SetAccent(savedAccent) end)
                    end
                end
            end
        end
    end

    function Library:_SaveSetting(key, value)
        if not self.autoSaveEnabled or not key then return end
        self.autoSaveData[key] = value
        local ok, json = pcall(HttpService.JSONEncode, HttpService, self.autoSaveData)
        if ok and _typeof(writefile) == "function" then
            pcall(writefile, self.autoSaveFile, json)
        end
    end

    function Library:_GetSetting(key, default)
        if not self.autoSaveEnabled or not key then return default end
        local value = self.autoSaveData[key]
        if value == nil then
            return default
        else
            return value
        end
    end

    -- Create a GUI settings section inside an existing page
    function Library:CreateGUISettingsSection(opts)
        opts = opts or {}
        local page = opts.Page or opts.page
        if not page or _typeof(page) ~= "table" or not page.CreateSection then
            warn("CreateGUISettingsSection: missing or invalid Page")
            return nil
        end

        local section = page:CreateSection({ Title = opts.SectionTitle or self:_T("GUI.Settings", "GUI Settings"), Icon = opts.Icon })

        -- Auto Save toggle
        local autoToggle = section:CreateToggle({
            Title = opts.AutoSaveTitle or self:_T("GUI.AutoSave", "Auto Save"),
            Default = self.autoSaveEnabled,
            SaveKey = opts.AutoSaveSaveKey or "ui_auto_save_enabled",
            Callback = function(v)
                self.autoSaveEnabled = v
                if self.Notify then
                    self:Notify({ Title = self:_T("GUI.AutoSave", "Auto Save"), Text = v and self:_T("Common.Enabled", "Enabled") or self:_T("Common.Disabled", "Disabled"), Duration = 3 })
                end
                if v and not self.autoSaveFile then
                    self.autoSaveFile = opts.FileName or "ui_settings.json"
                end
            end,
        })

        -- Save Now button
        local saveBtn = section:CreateButton({
            Title = opts.SaveNowTitle or self:_T("GUI.SaveNow", "Save Now"),
            Callback = function()
                if not self.autoSaveEnabled then
                    if self.Notify then
                        self:Notify({ Title = self:_T("GUI.SaveNow", "Save Now"), Text = self:_T("Common.Disabled", "Disabled"), Duration = 3 })
                    end
                    return
                end
                local ok, json = pcall(HttpService.JSONEncode, HttpService, self.autoSaveData)
                if ok and _typeof(writefile) == "function" then
                    local success = pcall(writefile, self.autoSaveFile, json)
                    if self.Notify then
                        if success then
                            self:Notify({ Title = self:_T("GUI.SaveNow", "Save Now"), Text = self:_T("Notify.SettingsSaved", "Settings saved."), Duration = 3 })
                        else
                            self:Notify({ Title = self:_T("GUI.SaveNow", "Save Now"), Text = self:_T("Notify.SaveFailed", "Failed to save settings."), Duration = 4 })
                        end
                    end
                else
                    if self.Notify then
                        self:Notify({ Title = self:_T("GUI.SaveNow", "Save Now"), Text = self:_T("Notify.JSONEncodeFailed", "JSON encode failed."), Duration = 4 })
                    end
                end
            end,
        })

        -- Menu toggle keybind
        local keybindObj
        if section.CreateKeybind then
            keybindObj = section:CreateKeybind({
                Title = opts.ToggleKeyTitle or self:_T("GUI.MenuToggleKey", "Menu Toggle Key"),
                Default = self.Config.ToggleKey,
                SaveKey = opts.ToggleKeySaveKey or "ui_toggle_key",
                Callback = function(kc)
                    self.Config.ToggleKey = kc
                    self:_SaveSetting(opts.ToggleKeySaveKey or "ui_toggle_key", kc.Name)
                    if self.Notify then
                        self:Notify({ Title = "Keybind", Text = "Toggle key set to " .. kc.Name, Duration = 3 })
                    end
                end,
            })
        end

        -- Language dropdown (English / Russian)
        local codeToName = { en = "English", ru = "Русский" }
        local nameToCode = { ["English"] = "en", ["Русский"] = "ru" }
        local savedLang = self:_GetSetting("ui_language", self.Locale or "en")
        if _typeof(savedLang) ~= "string" or not codeToName[savedLang] then savedLang = "en" end
        self.Locale = savedLang

        local items = { "English", "Русский" }
        local defaultIndex = 1
        for i, n in ipairs(items) do if n == codeToName[savedLang] then defaultIndex = i break end end

        local langDropdown = section:CreateDropdown({
            Title = self:_T("GUI.Language", "Language"),
            Items = items,
            Default = defaultIndex,
            Callback = function(name)
                local code = nameToCode[name] or "en"
                self:SetLanguage(code)
                if autoToggle and autoToggle.Object then
                    for _, ch in ipairs(autoToggle.Object:GetChildren()) do
                        if ch:IsA("TextLabel") then ch.Text = self:_T("GUI.AutoSave", "Auto Save") break end
                    end
                end
                if saveBtn and saveBtn.Object then
                    saveBtn.Object.Text = self:_T("GUI.SaveNow", "Save Now")
                end
                if _typeof(section) == "table" and keybindObj and keybindObj.Object then
                    local holder = keybindObj.Object.Parent
                    if holder then
                        for _, ch in ipairs(holder:GetChildren()) do
                            if ch:IsA("TextLabel") then ch.Text = self:_T("GUI.MenuToggleKey", "Menu Toggle Key") break end
                        end
                    end
                end
                if langDropdown and langDropdown.Object then
                    local holder = langDropdown.Object.Parent
                    if holder then
                        for _, ch in ipairs(holder:GetChildren()) do
                            if ch:IsA("TextLabel") then ch.Text = self:_T("GUI.Language", "Language") break end
                        end
                    end
                end
            end,
        })

        -- Accent color picker
        local accentItems = { "Blue", "Red", "Orange", "Purple", "Pink", "Green" }
        local accentMap = { Blue = "blue", Red = "red", Orange = "orange", Purple = "purple", Pink = "pink", Green = "green" }
        local savedAccent = self:_GetSetting("ui_accent_color", nil)
        local defaultAccentIndex = 1
        if _typeof(savedAccent) == "string" then
            for i, n in ipairs(accentItems) do if string.lower(n) == string.lower(savedAccent) or accentMap[n] == string.lower(savedAccent) then defaultAccentIndex = i break end end
        end
        section:CreateDropdown({
            Title = self:_T("GUI.AccentColor", "Accent Color"),
            Items = accentItems,
            Default = defaultAccentIndex,
            SaveKey = "ui_accent_color",
            Callback = function(name)
                local key = accentMap[name] or name
                self:SetAccent(key)
            end,
        })

        return section
    end

    function Library:UseSaveModule(opts)
        opts = opts or {}
        local win = opts.Window
        if not win then
            warn("UseSaveModule: missing Window in options")
            return
        end
        local page = win:CreatePage({ Title = opts.PageTitle or "Save", Icon = opts.Icon })
        self:CreateGUISettingsSection({
            Page = page,
            SectionTitle = opts.SectionTitle or "Save Manager",
            FileName = opts.FileName,
            ToggleKeyTitle = opts.ToggleKeyTitle,
            ToggleKeySaveKey = opts.ToggleKeySaveKey,
        })
    end

    -- Public save API
    function Library:SetSaveKey(saveKey, value)
        if not self._widgetRegistry then return end
        local widget = self._widgetRegistry[saveKey]
        if not widget then return end

        if _typeof(value) == "table" then
            if widget.SetSliderValue and widget.SetToggleState then -- SliderToggle
                if value.value ~= nil then widget.SetSliderValue(value.value) end
                if value.toggled ~= nil then widget.SetToggleState(value.toggled) end
                return
            elseif widget.GetSelection and widget.GetValue then -- SliderButtonDropdown
                if value.item ~= nil then widget.SetSelection(value.item) end
                if value.value ~= nil then widget.SetValue(value.value) end
                return
            elseif widget.GetSelections then -- MultiSelectDropdown
                widget.SetSelection(value)
                return
            end
        end

        if widget.SetState then
            widget.SetState(value)
        elseif widget.SetNumber then
            widget.SetNumber(value)
        elseif widget.SetSelection then
            widget.SetSelection(value)
        elseif widget.SetText then
            widget.SetText(value)
        elseif widget.SetKey then
            widget.SetKey(value)
        end
    end

    function Library:ApplyAllSaveKeys()
        if not self._widgetRegistry then return end
        for key, _ in pairs(self._widgetRegistry) do
            self:SetSaveKey(key)
        end
    end

    function Library:GetSettings(saveKey)
        if not self._widgetRegistry or not saveKey then return nil end
        local widget = self._widgetRegistry[saveKey]
        if not widget then return nil end

        if widget.GetSelectedItems then
            return widget:GetSelectedItems()
        elseif widget.GetSliderValue and widget.GetToggleState then
            return { value = widget:GetSliderValue(), toggled = widget:GetToggleState() }
        elseif widget.GetSelection and widget.GetValue then
            return { item = widget:GetSelection(), value = widget:GetValue() }
        elseif widget.GetSelections then
            return widget:GetSelections()
        elseif widget.GetState then
            return widget:GetState()
        elseif widget.GetValue then
            return widget:GetValue()
        elseif widget.GetSelection then
            return widget:GetSelection()
        elseif widget.GetKey then
            return Library.keycodeToString(widget:GetKey())
        elseif widget.GetText then
            return widget:GetText()
        end
        return nil
    end

    function Library:LoadConfig(savefile)
        if not savefile then
            warn("LoadConfig: Файл сохранения не указан.")
            return
        end
        if _typeof(isfile) ~= "function" or _typeof(readfile) ~= "function" or not isfile(savefile) then
            return
        end

        local readSuccess, fileContent = pcall(readfile, savefile)
        if not readSuccess or not fileContent or fileContent == "" then
            warn("LoadConfig: Не удалось прочитать содержимое файла: " .. savefile)
            return
        end

        local decodeSuccess, configData = pcall(HttpService.JSONDecode, HttpService, fileContent)
        if not decodeSuccess or _typeof(configData) ~= "table" then
            warn("LoadConfig: Не удалось декодировать JSON из файла: " .. savefile)
            return
        end

        local wasAutoSaveEnabled = self.autoSaveEnabled
        self.autoSaveEnabled = false
        local prevSuppress = self._suppressCallbacks
        self._suppressCallbacks = true

        for key, value in pairs(configData) do
            if self._widgetRegistry[key] then
                self:SetSaveKey(key, value)
            end
        end

        self._suppressCallbacks = prevSuppress
        self.autoSaveEnabled = wasAutoSaveEnabled
    end
end

