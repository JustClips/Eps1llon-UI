return function(Library)
    local _typeof = typeof or function(v) return type(v) end
    local TweenService = Library.Services.TweenService
    local UserInputService = Library.Services.UserInputService
    local RunService = Library.Services.RunService
    local PlayerGui = Library.PlayerGui

    local deepCopy = Library.deepCopy
    local deepMerge = Library.deepMerge

    local DEFAULT_KEY_SYSTEM_THEME = {
        bg = Color3.fromRGB(12, 14, 18),
        panel = Color3.fromRGB(16, 18, 24),
        text = Color3.fromRGB(230, 235, 240),
        textDim = Color3.fromRGB(170, 176, 186),
        accentA = Color3.fromRGB(64, 156, 255),
        btn = Color3.fromRGB(28, 30, 36),
        btnHover = Color3.fromRGB(36, 38, 46),
        success = Color3.fromRGB(40, 167, 69),
        successHover = Color3.fromRGB(60, 187, 89),
        error = Color3.fromRGB(220, 53, 69),
    }

    local DEFAULT_KEY_SYSTEM_CONFIG = {
        Enabled = false,
        Key = "Eps1llon",
        Title = "Eps1llon Hub | Verification",
        Description = "Please enter your key below to gain access.",
        PlaceholderText = "Enter your key here...",
        DiscordLink = "https://discord.gg/Eps1llon",
        CopySuccessText = "Discord link copied!",
        CopyFallbackText = "Copy failed. Link: discord.gg/Eps1llon",
        VerifyingText = "Verifying...",
        SuccessText = "Success! Access Granted.",
        ErrorText = "Invalid Key. Please try again.",
        GetKeyText = "Get Key",
        VerifyButtonText = "Verify Key",
        SaveFile = "eps_key_system.json",
        SaveIdentifier = "_Eps1llonKeySystemVerified",
        Theme = DEFAULT_KEY_SYSTEM_THEME,
    }

    Library.KeySystemConfig = deepCopy(DEFAULT_KEY_SYSTEM_CONFIG)
    Library._keySystemVerified = false

    function Library:ConfigureKeySystem(options)
        if options == nil then
            return deepCopy(self.KeySystemConfig)
        end

        if _typeof(options) == "boolean" then
            self.KeySystemConfig.Enabled = options
            return deepCopy(self.KeySystemConfig)
        end

        local config = deepCopy(self.KeySystemConfig)
        local opts = deepCopy(options)
        local themeOverride = opts.Theme
        opts.Theme = nil

        deepMerge(config, opts)

        if options.key ~= nil and options.Key == nil then
            config.Key = options.key
        end

        if options.enabled ~= nil and options.Enabled == nil then
            config.Enabled = options.enabled
        elseif options.Enabled ~= nil then
            config.Enabled = options.Enabled
        elseif options.Key ~= nil or options.key ~= nil or themeOverride ~= nil then
            config.Enabled = true
        end

        if themeOverride ~= nil then
            if _typeof(themeOverride) == "table" then
                local theme = deepCopy(DEFAULT_KEY_SYSTEM_THEME)
                deepMerge(theme, themeOverride)
                config.Theme = theme
            else
                config.Theme = deepCopy(DEFAULT_KEY_SYSTEM_THEME)
            end
        end

        self.KeySystemConfig = config

        return deepCopy(self.KeySystemConfig)
    end

    function Library:_IsKeySystemVerified()
        if self._keySystemVerified then
            return true
        end

        local config = self.KeySystemConfig
        local sharedEnv = Library._getSharedEnvironment()

        if sharedEnv then
            local cached = sharedEnv[config.SaveIdentifier]
            if _typeof(cached) == "table" and cached.verified and cached.key == config.Key then
                self._keySystemVerified = true
                return true
            end
        end

        if _typeof(isfile) == "function" and _typeof(readfile) == "function" and isfile(config.SaveFile) then
            local ok, contents = pcall(readfile, config.SaveFile)
            if ok and contents and contents ~= "" then
                local decoded = Library._decodeJSON(contents)
                if _typeof(decoded) == "table" and decoded.verified and decoded.key == config.Key then
                    self._keySystemVerified = true
                    if sharedEnv then
                        sharedEnv[config.SaveIdentifier] = decoded
                    end
                    return true
                end
            end
        end

        return false
    end

    function Library:_PersistKeySystemVerification()
        local config = self.KeySystemConfig
        local payload = {
            verified = true,
            key = config.Key,
            timestamp = os.time(),
        }

        local json = Library._encodeJSON(payload)
        if json and _typeof(writefile) == "function" then
            pcall(writefile, config.SaveFile, json)
        end

        local sharedEnv = Library._getSharedEnvironment()
        if sharedEnv then
            sharedEnv[config.SaveIdentifier] = payload
        end

        self._keySystemVerified = true
    end

    function Library:_ShowKeySystemPrompt()
        local config = self.KeySystemConfig
        local theme = deepCopy(DEFAULT_KEY_SYSTEM_THEME)
        if _typeof(config.Theme) == "table" then
            deepMerge(theme, config.Theme)
        end

        if PlayerGui:FindFirstChild("KeySystemGUI") then
            PlayerGui.KeySystemGUI:Destroy()
        end

        local keyGui = Instance.new("ScreenGui")
        keyGui.Name = "KeySystemGUI"
        keyGui.ResetOnSpawn = false
        keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        keyGui.Parent = PlayerGui

        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = UDim2.new(0, 360, 0, 250)
        mainFrame.Position = UDim2.new(0.5, -180, 0.5, -125)
        mainFrame.BackgroundColor3 = theme.panel
        mainFrame.BorderSizePixel = 0
        mainFrame.ClipsDescendants = true
        mainFrame.ZIndex = 2
        mainFrame.Active = true
        mainFrame.Draggable = true
        mainFrame.Parent = keyGui

        Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

        local stroke = Instance.new("UIStroke", mainFrame)
        stroke.Color = theme.accentA
        stroke.Transparency = 0.7
        stroke.Thickness = 1.5
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "Title"
        titleLabel.Size = UDim2.new(1, 0, 0, 30)
        titleLabel.Position = UDim2.new(0, 0, 0, 15)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = Library.asText(config.Title, Library:_T("KeySystem.Title", "Verification"))
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextColor3 = theme.text
        titleLabel.TextSize = 18
        titleLabel.TextXAlignment = Enum.TextXAlignment.Center
        titleLabel.ZIndex = 3
        titleLabel.Parent = mainFrame

        local descriptionLabel = Instance.new("TextLabel")
        descriptionLabel.Name = "Description"
        descriptionLabel.Size = UDim2.new(1, -40, 0, 30)
        descriptionLabel.Position = UDim2.new(0, 20, 0, 40)
        descriptionLabel.BackgroundTransparency = 1
        descriptionLabel.Text = Library.asText(config.Description, Library:_T("KeySystem.Description", "Please enter your key below to gain access."))
        descriptionLabel.Font = Enum.Font.Gotham
        descriptionLabel.TextColor3 = theme.textDim
        descriptionLabel.TextSize = 13
        descriptionLabel.TextWrapped = true
        descriptionLabel.TextXAlignment = Enum.TextXAlignment.Center
        descriptionLabel.TextYAlignment = Enum.TextYAlignment.Top
        descriptionLabel.ZIndex = 3
        descriptionLabel.Parent = mainFrame

        local feedbackLine = Instance.new("Frame")
        feedbackLine.Name = "FeedbackLine"
        feedbackLine.Size = UDim2.new(0, 0, 0, 3)
        feedbackLine.Position = UDim2.new(0, 20, 0, 75)
        feedbackLine.BackgroundColor3 = theme.accentA
        feedbackLine.BorderSizePixel = 0
        feedbackLine.ZIndex = 5
        feedbackLine.Parent = mainFrame
        Instance.new("UICorner", feedbackLine).CornerRadius = UDim.new(1, 0)

        local keyInput = Instance.new("TextBox")
        keyInput.Name = "KeyInput"
        keyInput.Size = UDim2.new(1, -40, 0, 38)
        keyInput.Position = UDim2.new(0, 20, 0, 80)
        keyInput.BackgroundColor3 = theme.bg
        keyInput.Text = ""
        keyInput.PlaceholderText = Library.asText(config.PlaceholderText, Library:_T("KeySystem.Placeholder", "Enter your key here..."))
        keyInput.PlaceholderColor3 = theme.textDim
        keyInput.Font = Enum.Font.Gotham
        keyInput.TextColor3 = theme.text
        keyInput.TextSize = 14
        keyInput.ClearTextOnFocus = false
        keyInput.TextXAlignment = Enum.TextXAlignment.Center
        keyInput.ZIndex = 4
        keyInput.Parent = mainFrame

        Instance.new("UICorner", keyInput).CornerRadius = UDim.new(0, 8)

        local statusLabel = Instance.new("TextLabel")
        statusLabel.Name = "StatusLabel"
        statusLabel.Size = UDim2.new(1, 0, 0, 20)
        statusLabel.Position = UDim2.new(0, 0, 0, 123)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = ""
        statusLabel.Font = Enum.Font.GothamBold
        statusLabel.TextColor3 = theme.textDim
        statusLabel.TextSize = 13
        statusLabel.TextXAlignment = Enum.TextXAlignment.Center
        statusLabel.ZIndex = 3
        statusLabel.Parent = mainFrame

        local getKeyButton = Instance.new("TextButton")
        getKeyButton.Name = "GetKeyButton"
        getKeyButton.Size = UDim2.new(1, -40, 0, 38)
        getKeyButton.Position = UDim2.new(0, 20, 0, 150)
        getKeyButton.BackgroundColor3 = theme.btn
        getKeyButton.Text = Library.asText(config.GetKeyText, Library:_T("KeySystem.GetKey", "Get Key"))
        getKeyButton.Font = Enum.Font.GothamBold
        getKeyButton.TextColor3 = theme.text
        getKeyButton.TextSize = 15
        getKeyButton.ZIndex = 4
        getKeyButton.Parent = mainFrame

        Instance.new("UICorner", getKeyButton).CornerRadius = UDim.new(0, 8)

        local verifyButton = Instance.new("TextButton")
        verifyButton.Name = "VerifyButton"
        verifyButton.Size = UDim2.new(1, -40, 0, 38)
        verifyButton.Position = UDim2.new(0, 20, 0, 195)
        verifyButton.BackgroundColor3 = theme.success
        verifyButton.Text = Library.asText(config.VerifyButtonText, Library:_T("KeySystem.VerifyKey", "Verify Key"))
        verifyButton.Font = Enum.Font.GothamBold
        verifyButton.TextColor3 = Color3.new(1, 1, 1)
        verifyButton.TextSize = 15
        verifyButton.ZIndex = 4
        verifyButton.Parent = mainFrame

        Instance.new("UICorner", verifyButton).CornerRadius = UDim.new(0, 8)

        local isVerifying = false

        local function recursiveFade(instance, targetTransparency)
            local fadeInfo = TweenInfo.new(0.4)
            if instance:IsA("GuiObject") then
                if pcall(function() return instance.BackgroundTransparency end) then
                    TweenService:Create(instance, fadeInfo, { BackgroundTransparency = targetTransparency }):Play()
                end
                if pcall(function() return instance.TextTransparency end) then
                    TweenService:Create(instance, fadeInfo, { TextTransparency = targetTransparency }):Play()
                end
                if pcall(function() return instance.ImageTransparency end) then
                    TweenService:Create(instance, fadeInfo, { ImageTransparency = targetTransparency }):Play()
                end
            end
            if pcall(function() return instance.Transparency end) and instance:IsA("UIStroke") then
                TweenService:Create(instance, fadeInfo, { Transparency = targetTransparency }):Play()
            end
            for _, child in ipairs(instance:GetChildren()) do
                recursiveFade(child, targetTransparency)
            end
        end

        local function shakeUI()
            local originalPos = mainFrame.Position
            for _ = 1, 5 do
                mainFrame.Position = originalPos + UDim2.new(0, math.random(-5, 5), 0, math.random(-5, 5))
                Library._waitCompat(0.02)
            end
            mainFrame.Position = originalPos
        end

        local completionEvent = Instance.new("BindableEvent")

        getKeyButton.Activated:Connect(function()
            if config.DiscordLink and Library._copyToClipboard(config.DiscordLink) then
                statusLabel.Text = Library.asText(config.CopySuccessText, Library:_T("KeySystem.CopySuccess", "Discord link copied!"))
                statusLabel.TextColor3 = theme.success
            else
                local fallbackText = Library.asText(config.CopyFallbackText, Library:_T("KeySystem.CopyFallback", "Copy failed. Link: "))
                statusLabel.Text = fallbackText .. (config.DiscordLink or "")
                statusLabel.TextColor3 = theme.error
            end
            Library._delayCompat(2, function()
                if statusLabel then
                    statusLabel.Text = ""
                end
            end)
        end)

        verifyButton.Activated:Connect(function()
            if isVerifying then
                return
            end
            isVerifying = true

            statusLabel.Text = Library.asText(config.VerifyingText, Library:_T("KeySystem.Verifying", "Verifying..."))
            statusLabel.TextColor3 = theme.textDim

            feedbackLine.Size = UDim2.new(0, 0, 0, 3)
            local lineAnim = TweenService:Create(feedbackLine, TweenInfo.new(0.5, Enum.EasingStyle.Linear), { Size = UDim2.new(1, -40, 0, 3) })
            lineAnim:Play()

            Library._waitCompat(0.6)

            if keyInput.Text == tostring(config.Key) then
                statusLabel.Text = Library.asText(config.SuccessText, Library:_T("KeySystem.Success", "Success! Access Granted."))
                statusLabel.TextColor3 = theme.success

                self:_PersistKeySystemVerification()

                recursiveFade(mainFrame, 1)
                local mainFade = TweenService:Create(mainFrame, TweenInfo.new(0.5), { BackgroundTransparency = 1 })
                mainFade.Completed:Connect(function()
                    keyGui:Destroy()
                    completionEvent:Fire(true)
                    completionEvent:Destroy()
                end)
                mainFade:Play()
            else
                statusLabel.Text = Library.asText(config.ErrorText, Library:_T("KeySystem.Error", "Invalid Key. Please try again."))
                statusLabel.TextColor3 = theme.error
                shakeUI()

                TweenService:Create(feedbackLine, TweenInfo.new(0.3), { Size = UDim2.new(0, 0, 0, 3) }):Play()
                isVerifying = false
            end
        end)

        -- Wait for completion robustly
        local evt = completionEvent.Event
        if Library._hasFunc(evt and evt.Wait) then
            return evt:Wait()
        end
        local result
        local done = false
        local conn
        conn = evt:Connect(function(v)
            result = v
            done = true
            if conn then conn:Disconnect() end
        end)
        while not done do Library._waitCompat(0.03) end
        return result
    end

    function Library:_EnsureKeySystem()
        if not self.KeySystemConfig.Enabled then
            return true
        end
        if self:_IsKeySystemVerified() then
            return true
        end
        return self:_ShowKeySystemPrompt()
    end
end

