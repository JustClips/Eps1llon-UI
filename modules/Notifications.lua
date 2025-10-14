local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

return function(Library)
    local notificationContainer
    local centerContainer

    local function ensureRoot()
        if notificationContainer and centerContainer then return end
        local root = PlayerGui:FindFirstChild("Eps1llon_Notifications")
        if not root then
            root = Instance.new("ScreenGui")
            root.Name = "Eps1llon_Notifications"
            root.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            root.DisplayOrder = 999
            root.ResetOnSpawn = false
            root.Parent = PlayerGui
        end

        notificationContainer = root:FindFirstChild("Container")
        if not notificationContainer then
            notificationContainer = Instance.new("Frame")
            notificationContainer.Name = "Container"
            notificationContainer.Size = UDim2.new(0, 320, 1, -20)
            notificationContainer.Position = UDim2.new(1, -340, 0, 0)
            notificationContainer.BackgroundTransparency = 1
            notificationContainer.Parent = root
            local listLayout = Instance.new("UIListLayout", notificationContainer)
            listLayout.Padding = UDim.new(0, 8)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
            listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        end

        centerContainer = root:FindFirstChild("CenterContainer")
        if not centerContainer then
            centerContainer = Instance.new("Frame")
            centerContainer.Name = "CenterContainer"
            centerContainer.Size = UDim2.fromScale(1, 1)
            centerContainer.BackgroundTransparency = 1
            centerContainer.Parent = root
        end
    end

    function Library:Notify(options)
        ensureRoot()
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
        local appearTween = TweenService:Create(notifFrame, appearTweenInfo, { Position = UDim2.new(0, 0, 0, 0) })
        appearTween:Play()
        local appearFade = Library:_TweenGroupTransparency(notifFrame, appearTweenInfo, 0)
        if appearFade then appearFade:Play() end

        local timerTween = TweenService:Create(timerBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 3) })
        timerTween:Play()
        timerTween.Completed:Connect(function()
            local disappearTweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            local disappearTween = TweenService:Create(notifFrame, disappearTweenInfo, { Position = UDim2.new(0.2, 0, 0, 0) })
            disappearTween:Play()
            local fadeOut = Library:_TweenGroupTransparency(notifFrame, disappearTweenInfo, 1)
            if fadeOut then fadeOut:Play() end
            disappearTween.Completed:Connect(function()
                notifFrame:Destroy()
            end)
        end)
    end
end

