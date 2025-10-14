local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

return function(Library)
    local centerContainer

    local function ensureCenter()
        if centerContainer and centerContainer.Parent and centerContainer.Parent.Parent then return end
        local root = PlayerGui:FindFirstChild("Eps1llon_Notifications")
        if not root then
            root = Instance.new("ScreenGui")
            root.Name = "Eps1llon_Notifications"
            root.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            root.DisplayOrder = 999
            root.ResetOnSpawn = false
            root.Parent = PlayerGui
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

    -- Center-screen bubble notification used by the section help button
    function Library:NotifyCenter(options)
        ensureCenter()
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

        -- Appear animation (fade + slight scale pop)
        local scale = Instance.new("UIScale", bubble)
        scale.Scale = 0.92
        RunService.Heartbeat:Wait()
        local appear = TweenService:Create(scale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
        local fadeIn = Library:_TweenGroupTransparency(bubble, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 0)
        appear:Play(); if fadeIn then fadeIn:Play() end

        -- Auto-dismiss
        task.delay(duration, function()
            local fadeOut = Library:_TweenGroupTransparency(bubble, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), 1)
            local shrink = TweenService:Create(scale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.97 })
            shrink:Play(); if fadeOut then fadeOut:Play() end
            fadeOut.Completed:Connect(function()
                bubble:Destroy()
            end)
        end)
    end

    -- Bottom-of-screen, slide-up explanation toast
    function Library:NotifyBottom(options)
        ensureCenter()
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

