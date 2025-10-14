return function(Library)
    local TweenService = Library.Services.TweenService
    local RunService = Library.Services.RunService
    local PlayerGui = Library.PlayerGui

    local notificationContainer
    local centerContainer

    local function setupNotifications()
        if notificationContainer and centerContainer then return end
        local notificationGui = Instance.new("ScreenGui")
        notificationGui.Name = "Eps1llon_Notifications"
        notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        notificationGui.DisplayOrder = 999
        notificationGui.Parent = PlayerGui
        notificationContainer = Instance.new("Frame", notificationGui)
        notificationContainer.Name = "Container"
        notificationContainer.Size = UDim2.new(0, 320, 1, -20)
        notificationContainer.Position = UDim2.new(1, -340, 0, 0)
        notificationContainer.BackgroundTransparency = 1
        local listLayout = Instance.new("UIListLayout", notificationContainer)
        listLayout.Padding = UDim.new(0, 8)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        centerContainer = Instance.new("Frame", notificationGui)
        centerContainer.Name = "CenterContainer"
        centerContainer.Size = UDim2.fromScale(1, 1)
        centerContainer.BackgroundTransparency = 1
    end

    function Library:Notify(options)
        setupNotifications()
        options = options or {}
        local title = options.Title or "Notification"
        local text = options.Text
        local duration = options.Duration or 5
        local nType = options.Type or "Info"
        local THEME = Library.Theme
        local typeColors = {
            Info = THEME.Info,
            Success = THEME.Success,
            Warning = THEME.Warning,
            Error = THEME.Error,
        }
        local barColor = typeColors[nType] or typeColors.Info

        local notifFrame = Instance.new("Frame")
        notifFrame.Size = UDim2.new(1, 0, 0, 0)
        notifFrame.BackgroundColor3 = THEME.panel
        notifFrame.BackgroundTransparency = 0
        notifFrame.ClipsDescendants = true
        notifFrame.LayoutOrder = tick()
        notifFrame.Position = UDim2.new(0.2, 0, 0, 0)
        Library:_SetGroupTransparency(notifFrame, 1)
        notifFrame.Parent = notificationContainer
        Instance.new("UICorner", notifFrame).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", notifFrame)
        stroke.Color = THEME.separator
        stroke.Transparency = 0.94
        stroke.Thickness = 1
        local contentFrame = Instance.new("Frame", notifFrame)
        contentFrame.Size = UDim2.new(1, 0, 1, 0)
        contentFrame.BackgroundTransparency = 1
        local contentLayout = Instance.new("UIListLayout", contentFrame)
        contentLayout.Padding = UDim.new(0, 4)
        contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        contentLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        contentLayout.FillDirection = Enum.FillDirection.Vertical
        local padding = Instance.new("UIPadding", contentFrame)
        padding.PaddingTop = UDim.new(0, 8)
        padding.PaddingLeft = UDim.new(0, 12)
        padding.PaddingRight = UDim.new(0, 12)
        padding.PaddingBottom = UDim.new(0, 8)
        local titleLabel = Instance.new("TextLabel", contentFrame)
        titleLabel.Size = UDim2.new(1, 0, 0, 0)
        titleLabel.AutomaticSize = Enum.AutomaticSize.Y
        titleLabel.BackgroundTransparency = 1
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.Text = title
        titleLabel.TextColor3 = THEME.text
        titleLabel.TextSize = 14
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.TextWrapped = true
        if text and text ~= "" then
            local textLabel = Instance.new("TextLabel", contentFrame)
            textLabel.Size = UDim2.new(1, 0, 0, 0)
            textLabel.AutomaticSize = Enum.AutomaticSize.Y
            textLabel.BackgroundTransparency = 1
            textLabel.Font = Enum.Font.Gotham
            textLabel.Text = text
            textLabel.TextColor3 = THEME.textDim
            textLabel.TextSize = 11
            textLabel.TextXAlignment = Enum.TextXAlignment.Left
            textLabel.TextWrapped = true
        end
        local timerBar = Instance.new("Frame", notifFrame)
        timerBar.Size = UDim2.new(1, 0, 0, 3)
        timerBar.BackgroundColor3 = barColor
        timerBar.BorderSizePixel = 0
        timerBar.Position = UDim2.new(0, 0, 1, 0)
        timerBar.AnchorPoint = Vector2.new(0, 1)
        RunService.Heartbeat:Wait()
        local targetHeight = contentFrame.UIListLayout.AbsoluteContentSize.Y + padding.PaddingTop.Offset + padding.PaddingBottom.Offset + timerBar.Size.Y.Offset
        notifFrame.Size = UDim2.new(1, 0, 0, targetHeight)

        local appearTweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        local appearTween = TweenService:Create(notifFrame, appearTweenInfo, {
            Position = UDim2.new(0, 0, 0, 0),
        })
        appearTween:Play()
        local appearFade = Library:_TweenGroupTransparency(notifFrame, appearTweenInfo, 0)
        if appearFade then appearFade:Play() end

        local timerTween = TweenService:Create(timerBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 3) })
        timerTween:Play()
        timerTween.Completed:Connect(function()
            local disappearTweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            local disappearTween = TweenService:Create(notifFrame, disappearTweenInfo, {
                Position = UDim2.new(0.2, 0, 0, 0),
            })
            disappearTween:Play()
            local fadeOut = Library:_TweenGroupTransparency(notifFrame, disappearTweenInfo, 1)
            if fadeOut then fadeOut:Play() end
            disappearTween.Completed:Connect(function()
                notifFrame:Destroy()
            end)
        end)
    end

    function Library:NotifyCenter(options)
        setupNotifications()
        options = options or {}
        local title = options.Title or "Info"
        local text = options.Text or ""
        local duration = options.Duration or 3.5
        local THEME = Library.Theme

        local bubble = Instance.new("Frame")
        bubble.Name = "CenterBubble"
        bubble.Size = UDim2.new(0, 360, 0, 0)
        bubble.AutomaticSize = Enum.AutomaticSize.Y
        bubble.AnchorPoint = Vector2.new(0.5, 0.5)
        bubble.Position = UDim2.fromScale(0.5, 0.5)
        bubble.BackgroundColor3 = THEME.panel
        Library:_SetGroupTransparency(bubble, 1)
        bubble.Parent = centerContainer
        Instance.new("UICorner", bubble).CornerRadius = UDim.new(0, 10)
        local stroke = Instance.new("UIStroke", bubble)
        stroke.Color = THEME.separator
        stroke.Transparency = 0.92
        stroke.Thickness = 1

        local content = Instance.new("Frame", bubble)
        content.BackgroundTransparency = 1
        content.Size = UDim2.new(1, 0, 1, 0)
        local padding = Instance.new("UIPadding", content)
        padding.PaddingTop = UDim.new(0, 10)
        padding.PaddingBottom = UDim.new(0, 10)
        padding.PaddingLeft = UDim.new(0, 14)
        padding.PaddingRight = UDim.new(0, 14)
        local layout = Instance.new("UIListLayout", content)
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 4)

        if title and title ~= "" then
            local titleLabel = Instance.new("TextLabel", content)
            titleLabel.BackgroundTransparency = 1
            titleLabel.AutomaticSize = Enum.AutomaticSize.Y
            titleLabel.Size = UDim2.new(1, 0, 0, 0)
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.Text = title
            titleLabel.TextColor3 = THEME.text
            titleLabel.TextSize = 14
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.TextWrapped = true
        end
        if text and text ~= "" then
            local body = Instance.new("TextLabel", content)
            body.BackgroundTransparency = 1
            body.AutomaticSize = Enum.AutomaticSize.Y
            body.Size = UDim2.new(1, 0, 0, 0)
            body.Font = Enum.Font.Gotham
            body.Text = text
            body.TextColor3 = THEME.textDim
            body.TextSize = 12
            body.TextWrapped = true
            body.TextXAlignment = Enum.TextXAlignment.Left
        end

        local scale = Instance.new("UIScale", bubble)
        scale.Scale = 0.92
        RunService.Heartbeat:Wait()
        local appear = TweenService:Create(scale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
        local fadeIn = Library:_TweenGroupTransparency(bubble, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 0)
        appear:Play(); if fadeIn then fadeIn:Play() end

        task.delay(duration, function()
            local fadeOut = Library:_TweenGroupTransparency(bubble, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), 1)
            local shrink = TweenService:Create(scale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.97 })
            shrink:Play(); if fadeOut then fadeOut:Play() end
            fadeOut.Completed:Connect(function()
                bubble:Destroy()
            end)
        end)
    end

    function Library:NotifyBottom(options)
        setupNotifications()
        options = options or {}
        local title = options.Title or "Info"
        local text = options.Text or ""
        local duration = options.Duration or 3.5
        local THEME = Library.Theme

        local bubble = Instance.new("Frame")
        bubble.Name = "BottomBubble"
        bubble.Size = UDim2.new(0, 280, 0, 0)
        bubble.AutomaticSize = Enum.AutomaticSize.Y
        bubble.AnchorPoint = Vector2.new(0.5, 1)
        bubble.Position = UDim2.new(0.5, 0, 1, 40)
        bubble.BackgroundColor3 = THEME.panel
        Library:_SetGroupTransparency(bubble, 1)
        bubble.Parent = centerContainer
        Instance.new("UICorner", bubble).CornerRadius = UDim.new(0, 10)
        local stroke = Instance.new("UIStroke", bubble)
        stroke.Color = THEME.separator
        stroke.Transparency = 0.92
        stroke.Thickness = 1

        local content = Instance.new("Frame", bubble)
        content.BackgroundTransparency = 1
        content.Size = UDim2.new(1, 0, 1, 0)
        local padding = Instance.new("UIPadding", content)
        padding.PaddingTop = UDim.new(0, 14)
        padding.PaddingBottom = UDim.new(0, 14)
        padding.PaddingLeft = UDim.new(0, 14)
        padding.PaddingRight = UDim.new(0, 14)
        local layout = Instance.new("UIListLayout", content)
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 4)

        if title and title ~= "" then
            local titleLabel = Instance.new("TextLabel", content)
            titleLabel.BackgroundTransparency = 1
            titleLabel.AutomaticSize = Enum.AutomaticSize.Y
            titleLabel.Size = UDim2.new(1, 0, 0, 0)
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.Text = title
            titleLabel.TextColor3 = THEME.text
            titleLabel.TextSize = 14
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.TextWrapped = true
        end
        if text and text ~= "" then
            local body = Instance.new("TextLabel", content)
            body.BackgroundTransparency = 1
            body.AutomaticSize = Enum.AutomaticSize.Y
            body.Size = UDim2.new(1, 0, 0, 0)
            body.Font = Enum.Font.Gotham
            body.Text = text
            body.TextColor3 = THEME.textDim
            body.TextSize = 12
            body.TextWrapped = true
            body.TextXAlignment = Enum.TextXAlignment.Left
        end

        RunService.Heartbeat:Wait()
        bubble.Position = UDim2.new(0.5, 0, 1, 40)
        local appear = TweenService:Create(bubble, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 1, -86),
        })
        appear:Play()
        local appearFade = Library:_TweenGroupTransparency(bubble, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), 0)
        if appearFade then appearFade:Play() end

        task.delay(duration, function()
            local disappear = TweenService:Create(bubble, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, 0, 1, 40),
            })
            disappear:Play()
            local fadeOut = Library:_TweenGroupTransparency(bubble, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), 1)
            if fadeOut then fadeOut:Play() end
            disappear.Completed:Connect(function()
                bubble:Destroy()
            end)
        end)
    end
end

