return function(Library)
function Library:CreateWindow(title, subtitle)
  -- WINDOW_IMPL_START
  task.wait()
  local initialFadeInTween = Library:_TweenGroupTransparency(rootFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), 0)
  initialFadeInTween.Completed:Connect(function()
      isAnimating = false
      isVisible = true
  end)
  initialFadeInTween:Play()

  function Window:SetPageOrder(order)
      applyPageOrder(order)
  end
  function Window:GetPageOrder()
      return getPageOrder()
  end

  return Window
  local originalSize = UDim2.fromOffset(guiWidth, guiHeight)
  local lastPosition = rootFrame.Position
  local lastSize = originalSize
  local isMinimized = false
  local windowAnimating = false
  local isExpanded = false
  local originalTitleText = nil
  local originalSubtitleText = nil
  local minimizedTitle = Library.asText(options and (options.MinimizedTitle or options.MinTitle), "Eps1llon Hub")
  local minimizedSubtitle = Library.asText(options and (options.MinimizedSubtitle or options.MinSubTitle), "Premium")

  local restoreBtn = Instance.new("Frame", rootFrame)
  restoreBtn.Size = UDim2.fromOffset(30, headerHeight)
  restoreBtn.Position = UDim2.new(1, -40, 0, 0)
  restoreBtn.BackgroundTransparency = 1
  Library:_SetGroupTransparency(restoreBtn, 1)
  restoreBtn.ZIndex = 3
  restoreBtn.Visible = false
  local restoreBtnImage = Instance.new("ImageButton", restoreBtn)
  restoreBtnImage.Size = UDim2.fromOffset(24, 24)
  restoreBtnImage.Position = UDim2.new(0.5, 0, 0.5, 0)
  restoreBtnImage.AnchorPoint = Vector2.new(0.5, 0.5)
  restoreBtnImage.BackgroundTransparency = 1
  restoreBtnImage.Image = "rbxassetid://137817849385475"
  restoreBtnImage.ImageColor3 = THEME.textDim
  restoreBtnImage.MouseEnter:Connect(function()
      TweenService:Create(restoreBtnImage, TweenInfo.new(0.2), { ImageColor3 = Color3.new(1, 1, 1) }):Play()
  end)
  restoreBtnImage.MouseLeave:Connect(function()
      TweenService:Create(restoreBtnImage, TweenInfo.new(0.2), { ImageColor3 = THEME.textDim }):Play()
  end)

  local function playAllTweens(tweens, onDone)
      local remaining = #tweens
      if remaining == 0 then
          if onDone then onDone() end
          return
      end
      for _, tw in ipairs(tweens) do
          tw.Completed:Connect(function()
              remaining = remaining - 1
              if remaining <= 0 and onDone then onDone() end
          end)
          tw:Play()
      end
  end

  local function setMinimizedState(minimize)
      if isMinimized == minimize then return end
      if windowAnimating then return end
      windowAnimating = true
      isMinimized = minimize
      closeActiveDropdown()
      if isExpanded then
          isExpanded = false
      end
      local tweenInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
      local tweens = {}
      if minimize then
          if not originalTitleText then originalTitleText = brandTitlePrimary.Text end
          if not originalSubtitleText then originalSubtitleText = brandSubtitle.Text end
          brandTitlePrimary.Text = minimizedTitle
          brandSubtitle.Text = minimizedSubtitle
          brandSubtitle.Visible = true

          local titleSize = TextService:GetTextSize(minimizedTitle, brandTitlePrimary.TextSize, brandTitlePrimary.Font, Vector2.new(10000, 10000))
          local subtitleSize = Vector2.new(0,0)
          if minimizedSubtitle and minimizedSubtitle ~= "" then
              subtitleSize = TextService:GetTextSize(minimizedSubtitle, brandSubtitle.TextSize, brandSubtitle.Font, Vector2.new(10000, 10000))
          end
          local textWidth = math.max(titleSize.X, subtitleSize.X)

          local leftPadding = 42
          local rightPadding = HEADER_RIGHT_PADDING_MINI
          local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
          local maxMinWidth = math.max(MINIMIZED_MIN_WIDTH, 220)
          local compactCap = 320
          local maxWidth = math.min(compactCap, math.floor(viewport.X - 40))
          local visibleTextWidth = math.min(textWidth, compactCap - leftPadding - rightPadding)
          local targetWidth = math.clamp(leftPadding + visibleTextWidth + rightPadding, maxMinWidth, maxWidth)

          local dynamicSize = UDim2.fromOffset(targetWidth, headerHeight)
          table.insert(tweens, TweenService:Create(rootFrame, tweenInfo, { Size = dynamicSize }))
          table.insert(tweens, TweenService:Create(brandContainer, tweenInfo, { Size = UDim2.new(1, -HEADER_RIGHT_PADDING_MINI, 0, 32) }))

          headerControls.Visible = true
          minimizeBtn.Visible = false
          expandBtn.Visible = true
          closeBtn.Visible = false
          headerControls.Size = UDim2.new(0, HEADER_RIGHT_PADDING_MINI, 0, headerHeight)
          expandBtn.Position = UDim2.new(1, -30, 0.5, 0)

          local tgc1 = Library:_TweenGroupTransparency(mainContent, tweenInfo, 1)
          if tgc1 then table.insert(tweens, tgc1) end
          table.insert(tweens, TweenService:Create(headerControls, tweenInfo, { Position = HEADER_CONTROLS_MINI_POS }))
      else
          if originalTitleText then brandTitlePrimary.Text = originalTitleText end
          if originalSubtitleText ~= nil then brandSubtitle.Text = originalSubtitleText end
          table.insert(tweens, TweenService:Create(rootFrame, tweenInfo, { Size = originalSize }))
          local tgc2 = Library:_TweenGroupTransparency(mainContent, tweenInfo, 0)
          if tgc2 then table.insert(tweens, tgc2) end
          headerControls.Visible = true
          minimizeBtn.Visible = true
          expandBtn.Visible = true
          closeBtn.Visible = true
          brandSubtitle.Visible = true
          table.insert(tweens, TweenService:Create(brandContainer, tweenInfo, { Size = BRAND_CONTAINER_DEFAULT_SIZE }))
          headerControls.Size = UDim2.new(0, 100, 0, headerHeight)
          expandBtn.Position = UDim2.new(0, 40, 0.5, 0)
          table.insert(tweens, TweenService:Create(headerControls, tweenInfo, { Position = HEADER_CONTROLS_DEFAULT_POS }))
          task.delay(tweenInfo.Time, function()
              restoreBtn.Visible = false
              Library:_SetGroupTransparency(restoreBtn, 1)
          end)
      end
      playAllTweens(tweens, function()
          windowAnimating = false
      end)
  end

  minimizeBtn.Activated:Connect(function()
      setMinimizedState(true)
  end)
  restoreBtnImage.Activated:Connect(function()
      setMinimizedState(false)
  end)

  local function toggleExpand()
      if windowAnimating then return end
      windowAnimating = true
      isExpanded = not isExpanded

      local expandTweenInfo = TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
      local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920,1080)
      local absSize = rootFrame.AbsoluteSize
      local oldW, oldH = absSize.X, absSize.Y

      local targetSize, targetPosition
      if isExpanded then
          lastPosition = rootFrame.Position
          lastSize = rootFrame.Size
          local factor = 1.2
          local maxW = math.max(420, math.floor(viewport.X * 0.6))
          local maxH = math.max(300, math.floor(viewport.Y * 0.6))
          local newW = math.min(math.floor(oldW * factor + 0.5), maxW)
          local newH = math.min(math.floor(oldH * factor + 0.5), maxH)
          targetSize = UDim2.fromOffset(newW, newH)
          local newOffsetX = rootFrame.Position.X.Offset + math.floor(oldW/2) - math.floor(newW/2)
          local newOffsetY = rootFrame.Position.Y.Offset + math.floor(oldH/2) - math.floor(newH/2)
          targetPosition = UDim2.new(rootFrame.Position.X.Scale, newOffsetX, rootFrame.Position.Y.Scale, newOffsetY)
      else
          targetSize = lastSize or UDim2.fromOffset(guiWidth, guiHeight)
          local curAbs = rootFrame.AbsoluteSize
          local newW = targetSize.X.Offset
          local newH = targetSize.Y.Offset
          local newOffsetX = rootFrame.Position.X.Offset + math.floor(curAbs.X/2) - math.floor(newW/2)
          local newOffsetY = rootFrame.Position.Y.Offset + math.floor(curAbs.Y/2) - math.floor(newH/2)
          targetPosition = UDim2.new(rootFrame.Position.X.Scale, newOffsetX, rootFrame.Position.Y.Scale, newOffsetY)
      end

      local tween = TweenService:Create(rootFrame, expandTweenInfo, { Size = targetSize, Position = targetPosition })
      tween.Completed:Connect(function()
          windowAnimating = false
      end)
      tween:Play()
  end

  expandBtn.Activated:Connect(function()
      if isMinimized then
          setMinimizedState(false)
          return
      end
      toggleExpand()
  end)

  local draggingWindow, dragInputWindow, frameStartPos, dragStartPos = false, nil, nil, nil
  local targetPositionWindow = rootFrame.Position
  local smoothOffset = Vector2.new(rootFrame.Position.X.Offset, rootFrame.Position.Y.Offset)
  dragFrame.InputBegan:Connect(function(input)
      if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
          draggingWindow = true
          dragInputWindow = input
          frameStartPos = UDim2.new(
              rootFrame.Position.X.Scale,
              math.floor(rootFrame.Position.X.Offset + 0.5),
              rootFrame.Position.Y.Scale,
              math.floor(rootFrame.Position.Y.Offset + 0.5)
          )
          dragStartPos = UserInputService:GetMouseLocation()
          smoothOffset = Vector2.new(frameStartPos.X.Offset, frameStartPos.Y.Offset)
      end
  end)
  UserInputService.InputEnded:Connect(function(input)
      if input == dragInputWindow then
          draggingWindow = false
          local roundedPos = UDim2.new(
              rootFrame.Position.X.Scale,
              math.floor(rootFrame.Position.X.Offset + 0.5),
              rootFrame.Position.Y.Scale,
              math.floor(rootFrame.Position.Y.Offset + 0.5)
          )
          rootFrame.Position = roundedPos
          if not isExpanded then
              lastPosition = roundedPos
          end
          targetPositionWindow = roundedPos
          smoothOffset = Vector2.new(roundedPos.X.Offset, roundedPos.Y.Offset)
      end
  end)
  RunService.RenderStepped:Connect(function(dt)
      if draggingWindow then
          local mouseDelta = UserInputService:GetMouseLocation() - dragStartPos
          local newPos = UDim2.new(
              frameStartPos.X.Scale,
              frameStartPos.X.Offset + mouseDelta.X,
              frameStartPos.Y.Scale,
              frameStartPos.Y.Offset + mouseDelta.Y
          )
          targetPositionWindow = newPos
      end
      if not windowAnimating then
          local targetOffset = Vector2.new(targetPositionWindow.X.Offset, targetPositionWindow.Y.Offset)
          local delta = targetOffset - smoothOffset
          if delta.Magnitude > 0.001 then
              local factor
              local hl = tonumber(CONFIG.DragHalfLife)
              if hl and hl > 0 then
                  factor = 1 - (2 ^ (-((dt or 1/60) / hl)))
              else
                  local k = math.clamp(CONFIG.DragSmoothness, 0, 1)
                  factor = 1 - math.exp(-10 * k * (dt or 1/60))
              end
              smoothOffset = smoothOffset + delta * factor
          else
              smoothOffset = targetOffset
          end
          local finalOffsetX = math.floor(smoothOffset.X + 0.5)
          local finalOffsetY = math.floor(smoothOffset.Y + 0.5)
          rootFrame.Position = UDim2.new(targetPositionWindow.X.Scale, finalOffsetX, targetPositionWindow.Y.Scale, finalOffsetY)
      else
          targetPositionWindow = rootFrame.Position
          smoothOffset = Vector2.new(rootFrame.Position.X.Offset, rootFrame.Position.Y.Offset)
      end
  end)

  UserInputService.InputBegan:Connect(function(input, gp)
      if gp then return end
      if Library._captureBlockInput then return end
      if input.UserInputType == Enum.UserInputType.Keyboard then
          local kc = input.KeyCode
          local list = Library._toggleBinds[kc]
          if list then
              for _, b in ipairs(list) do
                  local ok, cur = pcall(b.get)
                  local newVal = not cur
                  if b.type == "Toggle" then
                      pcall(b.set, newVal)
                  end
              end
          end
      end
      if input.KeyCode == CONFIG.ToggleKey then
          if isAnimating then return end
          isAnimating = true
          isVisible = not isVisible
          local tweenInfo = TweenInfo.new(FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
          if isVisible then
              mainGui.Enabled = true
              local tween = Library:_TweenGroupTransparency(rootFrame, tweenInfo, 0)
              tween.Completed:Connect(function()
                  isAnimating = false
              end)
              tween:Play()
          else
              local tween = Library:_TweenGroupTransparency(rootFrame, tweenInfo, 1)
              tween.Completed:Connect(function()
                  if not isVisible then mainGui.Enabled = false end
                  isAnimating = false
              end)
              tween:Play()
          end
      end
  end)

  closeBtn.Activated:Connect(function()
      if isAnimating then return end
      isAnimating = true
      local tweenInfo = TweenInfo.new(FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
      local fadeOutTween = Library:_TweenGroupTransparency(rootFrame, tweenInfo, 1)
      fadeOutTween.Completed:Connect(function()
          mainGui:Destroy()
      end)
      fadeOutTween:Play()
  end)

  local function updateActiveIndicator()
      if not activePage or not activePage.button then
          activeTabIndicator.Visible = false
          return
      end
      local btnPos = activePage.button.AbsolutePosition
      local mainPos = mainContent.AbsolutePosition
      local offset = btnPos - mainPos
      activeTabIndicator.Position = UDim2.fromOffset(offset.X, offset.Y)
      activeTabIndicator.Visible = true
  end
  tabsContainer:GetPropertyChangedSignal("CanvasPosition"):Connect(updateActiveIndicator)
  listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateActiveIndicator)
  rootFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateActiveIndicator)
  rootFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateActiveIndicator)

  local function applyPageOrder(order)
      if not pages or #pages == 0 then return end
      local map = {}
      for _, pObj in ipairs(pages) do
          map[pObj.button.Name] = pObj
          map[pObj] = pObj
      end
      local used = {}
      local newOrder = {}
      for _, item in ipairs(order) do
          local pObj = nil
          if _typeof(item) == "string" and map[item] then
              pObj = map[item]
          elseif _typeof(item) == "table" and map[item] then
              pObj = map[item]
          end
          if pObj and not used[pObj] then
              table.insert(newOrder, pObj)
              used[pObj] = true
          end
      end
      for _, pObj in ipairs(pages) do
          if not used[pObj] then
              table.insert(newOrder, pObj)
          end
      end
      pages = newOrder
      for idx, pObj in ipairs(pages) do
          pObj.button.LayoutOrder = idx
      end
      updateActiveIndicator()
  end

  local function getPageOrder()
      local order = {}
      for _, pObj in ipairs(pages) do
          table.insert(order, pObj.button.Name)
      end
      return order
  end

  -- WINDOW_IMPL_START
  function Window:CreatePage(options)
      local Page = {}
      options = options or {}
      local pageTitleRaw = options.Title or "Unnamed Page"
      local pageTitle = Library:_Translate(pageTitleRaw)
      local pageIcon = options.Icon

      local pageCanvas = Instance.new("Frame", pageHost)
      pageCanvas.Size = UDim2.new(1, 0, 1, 0)
      pageCanvas.Position = UDim2.new(0, 0, 0, 0)
      pageCanvas.BackgroundTransparency = 1
      pageCanvas.Visible = false
      Library:_SetGroupTransparency(pageCanvas, 0)

      local pageContainer = Instance.new("ScrollingFrame", pageCanvas)
      pageContainer.Name = pageTitle
      pageContainer.Size = UDim2.new(1, 0, 1, 0)
      pageContainer.BackgroundTransparency = 1
      pageContainer.BorderSizePixel = 0
      pageContainer.ScrollBarThickness = 0
      pageContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
      local pageLayout = Instance.new("UIListLayout", pageContainer)
      pageLayout.Padding = UDim.new(0, 10)
      local p = Instance.new("UIPadding", pageContainer)
      p.PaddingTop = UDim.new(0, 10)
      p.PaddingBottom = UDim.new(0, 10)
      p.PaddingLeft = UDim.new(0, 10)
      p.PaddingRight = UDim.new(0, 10)

      local tabButton = Instance.new("TextButton", tabsContainer)
      tabButton.Name = pageTitle .. "Tab"
      tabButton.Size = UDim2.new(1, 0, 0, 32)
      tabButton.BackgroundTransparency = 1
      tabButton.Text = ""
      tabButton.ZIndex = 3
      tabButton.LayoutOrder = #pages + 1
      local tabLayout = Instance.new("UIListLayout", tabButton)
      tabLayout.FillDirection = Enum.FillDirection.Horizontal
      tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
      tabLayout.Padding = UDim.new(0, 8)
      local tabPadding = Instance.new("UIPadding", tabButton)
      if pageIcon then
          tabPadding.PaddingLeft = UDim.new(0, 15)
          local icon = Instance.new("ImageLabel", tabButton)
          icon.Name = "Icon"
          icon.Size = UDim2.fromOffset(16, 16)
          icon.BackgroundTransparency = 1
          icon.Image = pageIcon
          icon.LayoutOrder = 1
      else
          tabPadding.PaddingLeft = UDim.new(0, 25)
      end
      local titleLabel = Instance.new("TextLabel", tabButton)
      titleLabel.Name = "TitleLabel"
      titleLabel.AutomaticSize = Enum.AutomaticSize.X
      titleLabel.Size = UDim2.new(0, 0, 1, 0)
      titleLabel.BackgroundTransparency = 1
      titleLabel.Font = Enum.Font.GothamBold
      local displayTitle = (Library.Locale == "en") and toTitleCase(pageTitle) or pageTitle
      titleLabel.Text = displayTitle
      titleLabel.TextColor3 = THEME.textDim
      titleLabel.TextSize = 14
      titleLabel.TextXAlignment = Enum.TextXAlignment.Left
      titleLabel.LayoutOrder = 2

      Library:_onLanguageChanged(function()
          local newTitle = Library:_Translate(pageTitleRaw)
          local disp = (Library.Locale == "en") and toTitleCase(newTitle) or newTitle
          titleLabel.Text = disp
          pageContainer.Name = newTitle
          tabButton.Name = newTitle .. "Tab"
      end)

      local pageObject = { button = tabButton, canvas = pageCanvas, container = pageContainer }
      table.insert(pages, pageObject)

      local function setPageActive(page, isInstant)
          closeActiveDropdown()
          if activePage == page and not isInstant then return end
          local newPage = page
          local prevPage = activePage
          activePage = newPage
          local tweenInfoColor = isInstant and TweenInfo.new(0) or TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
          for _, pObj in ipairs(pages) do
              local targetColor = (pObj == newPage) and THEME.textActive or THEME.textDim
              TweenService:Create(pObj.button.TitleLabel, tweenInfoColor, { TextColor3 = targetColor }):Play()
          end
          if prevPage and prevPage.canvas then
              if isInstant then
                  prevPage.canvas.Visible = false
                  prevPage.canvas.Position = UDim2.new(0, 0, 0, 0)
              else
                  prevPage.canvas.Position = UDim2.new(0, 0, 0, 0)
                  local slideOut = TweenService:Create(prevPage.canvas, TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.new(-1, 0, 0, 0) })
                  slideOut.Completed:Connect(function()
                      if prevPage ~= activePage then
                          prevPage.canvas.Visible = false
                          prevPage.canvas.Position = UDim2.new(0, 0, 0, 0)
                      end
                  end)
                  slideOut:Play()
              end
          end
          if newPage and newPage.canvas then
              if isInstant then
                  newPage.canvas.Visible = true
                  newPage.canvas.Position = UDim2.new(0, 0, 0, 0)
              else
                  newPage.canvas.Position = UDim2.new(1, 0, 0, 0)
                  newPage.canvas.Visible = true
                  TweenService:Create(newPage.canvas, TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, 0) }):Play()
              end
          end
          if newPage and newPage.button then
              local btnPos = newPage.button.AbsolutePosition
              local mainPos = mainContent.AbsolutePosition
              local offset = btnPos - mainPos
              local targetUDim = UDim2.fromOffset(offset.X, offset.Y)
              if isInstant then
                  activeTabIndicator.Position = targetUDim
                  activeTabIndicator.Visible = true
              else
                  activeTabIndicator.Visible = true
                  local indicatorTween = TweenService:Create(activeTabIndicator, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = targetUDim })
                  indicatorTween:Play()
              end
          end
      end

      if #pages == 1 then
          task.wait()
          setPageActive(pageObject, true)
      end

      tabButton.MouseEnter:Connect(function()
          if activePage ~= pageObject then
              TweenService:Create(titleLabel, TweenInfo.new(0.2), { TextColor3 = THEME.text }):Play()
          end
      end)
      tabButton.MouseLeave:Connect(function()
          if activePage ~= pageObject then
              TweenService:Create(titleLabel, TweenInfo.new(0.2), { TextColor3 = THEME.textDim }):Play()
          end
      end)
      tabButton.Activated:Connect(function()
          setPageActive(pageObject)
      end)

      function Page:CreateSection(secOptions)
          -- SECTION_IMPL_START
          function Section:CreateSliderButtonDropdown(opts)
              opts = opts or {}
              local items = opts.Items or {}
              local defaultItem = opts.DefaultItem or 1
              local sliderMin = opts.Min or 0
              local sliderMax = opts.Max or 100
              local sliderDefault = opts.Default or sliderMin
              local decimals = opts.Decimals or 0
              local savedState = nil
              if opts.SaveKey then
                  local saved = Library:_GetSetting(opts.SaveKey, nil)
                  if typeof(saved) == "table" then savedState = saved end
              end
              local currentSelection = items[defaultItem]
              if savedState and savedState.value ~= nil then
                  local v = tonumber(savedState.value)
                  if v and v >= sliderMin and v <= sliderMax then sliderDefault = v end
              end
              local dropdownRow = Instance.new("Frame", contentFrame)
              dropdownRow.Size = UDim2.new(1, 0, 0, 28)
              dropdownRow.BackgroundTransparency = 1
              local dropdownTitleLabel = Instance.new("TextLabel", dropdownRow)
              dropdownTitleLabel.Size = UDim2.new(0.5, -10, 1, 0)
              dropdownTitleLabel.BackgroundTransparency = 1
              dropdownTitleLabel.Font = Enum.Font.GothamSemibold
              dropdownTitleLabel.Text = Library:_Translate(opts.DropdownTitle or (opts.Title or "Select"))
              dropdownTitleLabel.TextColor3 = THEME.text
              dropdownTitleLabel.TextSize = 13
              dropdownTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
              Library:_BindLocaleText(dropdownTitleLabel, opts.DropdownTitle or (opts.Title or "Select"))
              local dropdownButton = Instance.new("TextButton", dropdownRow)
              dropdownButton.Size = UDim2.new(0.5, 0, 1, 0)
              dropdownButton.Position = UDim2.new(0.5, 0, 0, 0)
              dropdownButton.BackgroundColor3 = THEME.panelHighlight
              dropdownButton.BackgroundTransparency = 0.5
              dropdownButton.Text = ""
              Instance.new("UICorner", dropdownButton).CornerRadius = UDim.new(0, 6)
              Instance.new("UIStroke", dropdownButton).Color = THEME.separator
              local selectedLabel = Instance.new("TextLabel", dropdownButton)
              selectedLabel.Size = UDim2.new(1, -8, 1, 0)
              selectedLabel.Position = UDim2.fromOffset(8, 0)
              selectedLabel.BackgroundTransparency = 1
              selectedLabel.Font = Enum.Font.Gotham
              selectedLabel.Text = Library:_Translate(currentSelection or "")
              selectedLabel.TextColor3 = THEME.textDim
              selectedLabel.TextSize = 13
              selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
              selectedLabel.TextWrapped = false
              selectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
              local function _refreshSelectedText() selectedLabel.Text = Library:_Translate(currentSelection or "") end
              Library:_onLanguageChanged(_refreshSelectedText)
              local function openDropdown(btn, createItemsFunc)
                  if activeDropdown == btn then closeActiveDropdown() return end
                  if activeDropdown then closeActiveDropdown() end
                  for _, child in ipairs(dropdownHost:GetChildren()) do
                      if child:IsA("GuiObject") and not child:IsA("UILayout") and not child:IsA("UIPadding") and not child:IsA("UIStroke") and not child:IsA("UICorner") then
                          child:Destroy()
                      end
                  end
                  activeDropdown = btn
                  clickToClose.Visible = true
                  createItemsFunc()
                  local openPos = UDim2.new(1, -dropdownHost.AbsoluteSize.X - 8, 0, headerHeight + 8)
                  TweenService:Create(dropdownHost, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = openPos }):Play()
              end
              dropdownButton.Activated:Connect(function()
                  openDropdown(dropdownButton, function()
                      local seen = {}
                      for _, item in ipairs(items) do
                          if not seen[item] then
                              seen[item] = true
                              local optionBtn = Instance.new("TextButton", dropdownHost)
                              optionBtn.Size = UDim2.new(1, 0, 0, 32)
                              optionBtn.BackgroundTransparency = 1
                              optionBtn.Text = ""
                              optionBtn:SetAttribute("rawItem", item)
                              local marker = Instance.new("Frame", optionBtn)
                              marker.Size = UDim2.fromOffset(2, 18)
                              marker.Position = UDim2.new(0, 3, 0.5, 0)
                              marker.AnchorPoint = Vector2.new(0, 0.5)
                              marker.BackgroundColor3 = THEME.accent
                              marker.BorderSizePixel = 0
                              Instance.new("UICorner", marker).CornerRadius = UDim.new(1, 0)
                              local optionLabel = Instance.new("TextLabel", optionBtn)
                              optionLabel.Size = UDim2.new(1, -16, 1, 0)
                              optionLabel.Position = UDim2.fromOffset(8, 0)
                              optionLabel.BackgroundTransparency = 1
                              optionLabel.Font = Enum.Font.GothamSemibold
                              optionLabel.Text = Library:_Translate(item)
                              optionLabel.TextColor3 = THEME.text
                              optionLabel.TextSize = 13
                              optionLabel.TextXAlignment = Enum.TextXAlignment.Left
                              optionLabel.TextWrapped = false
                              optionLabel.TextTruncate = Enum.TextTruncate.AtEnd
                              marker.Visible = (item == currentSelection)
                              optionBtn.MouseEnter:Connect(function()
                                  TweenService:Create(optionBtn, TweenInfo.new(0.2), { BackgroundColor3 = THEME.panelHighlight, BackgroundTransparency = 0.5 }):Play()
                              end)
                              optionBtn.MouseLeave:Connect(function()
                                  TweenService:Create(optionBtn, TweenInfo.new(0.2), { BackgroundColor3 = THEME.panel, BackgroundTransparency = 1 }):Play()
                              end)
                              optionBtn.Activated:Connect(function()
                                  currentSelection = item
                                  _refreshSelectedText()
                                  for _, c in ipairs(dropdownHost:GetChildren()) do
                                      if c:IsA("TextButton") then
                                          local m
                                          for _, cc in ipairs(c:GetChildren()) do if cc:IsA("Frame") then m = cc break end end
                                          local raw = c:GetAttribute("rawItem")
                                          if m then m.Visible = (raw == currentSelection) end
                                      end
                                  end
                                  if opts.OnDropdownChange then opts.OnDropdownChange(item) end
                                  if opts.SaveKey then Library:_SaveSetting(opts.SaveKey, { item = currentSelection, value = currentValue }) end
                                  closeActiveDropdown()
                              end)
                          end
                      end
                  end)
              end)
              local holderRow = Instance.new("Frame", contentFrame)
              holderRow.Size = UDim2.new(1, 0, 0, 48)
              holderRow.BackgroundTransparency = 1
              local sliderPortion = opts.SliderPortion or 0.7
              local sliderHolder = Instance.new("Frame", holderRow)
              sliderHolder.Size = UDim2.new(sliderPortion, -4, 1, 0)
              sliderHolder.Position = UDim2.new(0, 0, 0, 0)
              sliderHolder.BackgroundTransparency = 1
              local topRow = Instance.new("Frame", sliderHolder)
              topRow.Size = UDim2.new(1, 0, 0, 18)
              topRow.BackgroundTransparency = 1
              local titleSlider = Instance.new("TextLabel", topRow)
              titleSlider.Size = UDim2.new(0.5, 0, 1, 0)
              titleSlider.BackgroundTransparency = 1
              titleSlider.Font = Enum.Font.GothamSemibold
              titleSlider.Text = Library:_Translate(opts.SliderTitle or "Quantity")
              titleSlider.TextColor3 = THEME.text
              titleSlider.TextSize = 13
              titleSlider.TextXAlignment = Enum.TextXAlignment.Left
              Library:_BindLocaleText(titleSlider, opts.SliderTitle or "Quantity")
              local valueLabel = Instance.new("TextLabel", topRow)
              valueLabel.Size = UDim2.new(0.5, 0, 1, 0)
              valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
              valueLabel.BackgroundTransparency = 1
              valueLabel.Font = Enum.Font.Gotham
              valueLabel.TextColor3 = THEME.textDim
              valueLabel.TextSize = 13
              valueLabel.TextXAlignment = Enum.TextXAlignment.Right
              local track = Instance.new("Frame", sliderHolder)
              track.Size = UDim2.new(1, 0, 0, 6)
              track.Position = UDim2.new(0, 0, 0, 20)
              track.BackgroundColor3 = THEME.panelHighlight
              track.BorderSizePixel = 0
              Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
              local fill = Instance.new("Frame", track)
              fill.BackgroundColor3 = THEME.accent
              fill.BorderSizePixel = 0
              Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
              local knob = Instance.new("ImageLabel", track)
              knob.Size = UDim2.fromOffset(14, 14)
              knob.AnchorPoint = Vector2.new(0.5, 0.5)
              knob.Position = UDim2.new(0, 0, 0.5, 0)
              knob.BackgroundTransparency = 1
              knob.Image = "rbxassetid://3570695787"
              knob.ImageColor3 = THEME.textActive
              local minVal, maxVal, defaultVal, dec = sliderMin, sliderMax, sliderDefault, decimals
              local currentValue, targetPercentage, currentPercentage = defaultVal, (defaultVal - minVal) / (maxVal - minVal), (defaultVal - minVal) / (maxVal - minVal)
              local draggingSlider = false
              local format = "%" .. "." .. dec .. "f"
              local function UpdateVisuals(percentage)
                  local value = minVal + (maxVal - minVal) * percentage
                  fill.Size = UDim2.new(percentage, 0, 1, 0)
                  knob.Position = UDim2.new(percentage, 0, 0.5, 0)
                  valueLabel.Text = string.format(format, value)
                  currentValue = value
                  if opts.OnSliderChange then opts.OnSliderChange(currentValue) end
                  if opts.SaveKey then Library:_SaveSetting(opts.SaveKey, { item = currentSelection, value = currentValue }) end
              end
              RunService.Heartbeat:Connect(function()
                  if currentPercentage ~= targetPercentage then
                      currentPercentage = currentPercentage + (targetPercentage - currentPercentage) * 0.1
                      if math.abs(currentPercentage - targetPercentage) < 0.001 then currentPercentage = targetPercentage end
                      UpdateVisuals(currentPercentage)
                  end
              end)
              track.InputBegan:Connect(function(input)
                  if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                      draggingSlider = true
                      targetPercentage = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                  end
              end)
              UserInputService.InputChanged:Connect(function(input)
                  if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                      targetPercentage = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                  end
              end)
              UserInputService.InputEnded:Connect(function(input)
                  if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                      draggingSlider = false
                  end
              end)
              UpdateVisuals(currentPercentage)
              local buttonHolder = Instance.new("TextButton", holderRow)
              buttonHolder.Size = UDim2.new(1 - sliderPortion, 4, 1, 0)
              buttonHolder.Position = UDim2.new(sliderPortion, 4, 0, 0)
              buttonHolder.BackgroundColor3 = THEME.panelHighlight
              buttonHolder.BackgroundTransparency = 0.8
              buttonHolder.Font = Enum.Font.GothamBold
              buttonHolder.Text = opts.ButtonTitle or "Confirm"
              buttonHolder.TextColor3 = THEME.text
              buttonHolder.TextSize = 13
              Instance.new("UICorner", buttonHolder).CornerRadius = UDim.new(0, 6)
              local strokeBtn2 = Instance.new("UIStroke", buttonHolder)
              strokeBtn2.Color = THEME.separator
              strokeBtn2.Transparency = 0.8
              buttonHolder.MouseEnter:Connect(function() TweenService:Create(buttonHolder, TweenInfo.new(0.2), { BackgroundTransparency = 0.65 }):Play() end)
              buttonHolder.MouseLeave:Connect(function() TweenService:Create(buttonHolder, TweenInfo.new(0.2), { BackgroundTransparency = 0.8 }):Play() end)
              buttonHolder.Activated:Connect(function()
                  if opts.Callback and not Library._suppressCallbacks then opts.Callback(currentSelection, currentValue) end
                  if opts.SaveKey then Library:_SaveSetting(opts.SaveKey, { item = currentSelection, value = currentValue }) end
              end)
              local sbdObject = {}
              sbdObject.Object = { Dropdown = dropdownButton, Slider = sliderHolder, ConfirmButton = buttonHolder }
              sbdObject.GetSelection = function() return currentSelection end
              sbdObject.SetSelection = function(val)
                  if val and table.find(items, val) then
                      currentSelection = val
                      selectedLabel.Text = Library:_Translate(val)
                      if opts.OnDropdownChange then opts.OnDropdownChange(val) end
                      if opts.SaveKey then Library:_SaveSetting(opts.SaveKey, { item = currentSelection, value = currentValue }) end
                  end
              end
              sbdObject.GetValue = function() return currentValue end
              sbdObject.SetValue = function(v)
                  v = math.clamp(v, minVal, maxVal)
                  local percentage = (v - minVal) / (maxVal - minVal)
                  targetPercentage = percentage
                  currentPercentage = percentage
                  UpdateVisuals(percentage)
              end
              sbdObject.Call = function(item, value)
                  local sel = item or currentSelection
                  local val = value or currentValue
                  if opts.Callback and not Library._suppressCallbacks then opts.Callback(sel, val) end
              end
              if opts.SaveKey then
                  Library._widgetRegistry[opts.SaveKey] = sbdObject
              end
              return sbdObject
          end
          -- SECTION_IMPL_START
          function Section:CreateSliderToggle(opts)
              opts = opts or {}
              local sliderMin = opts.Min or 0
              local sliderMax = opts.Max or 100
              local sliderDefault = opts.Default or sliderMin
              local decimals = opts.Decimals or 0
              local sliderTitle = Library:_Translate(opts.Title or "Value")
              local toggleDefault = opts.DefaultToggle or false
              local sliderPortion = opts.SliderPortion or 0.7
              if opts.SaveKey then
                  local saved = Library:_GetSetting(opts.SaveKey, nil)
                  if typeof(saved) == "table" then
                      if saved.value ~= nil then
                          local v = tonumber(saved.value)
                          if v and v >= sliderMin and v <= sliderMax then sliderDefault = v end
                      end
                      if saved.toggled ~= nil then toggleDefault = saved.toggled and true or false end
                  end
              end
              local rowFrame = Instance.new("Frame", contentFrame)
              rowFrame.Size = UDim2.new(1, 0, 0, 48)
              rowFrame.BackgroundTransparency = 1
              local sliderHolder = Instance.new("Frame", rowFrame)
              sliderHolder.Size = UDim2.new(sliderPortion, -4, 1, 0)
              sliderHolder.Position = UDim2.new(0, 0, 0, 0)
              sliderHolder.BackgroundTransparency = 1
              local topRow = Instance.new("Frame", sliderHolder)
              topRow.Size = UDim2.new(1, 0, 0, 18)
              topRow.BackgroundTransparency = 1
              local titleSlider = Instance.new("TextLabel", topRow)
              titleSlider.Size = UDim2.new(0.5, 0, 1, 0)
              titleSlider.BackgroundTransparency = 1
              titleSlider.Font = Enum.Font.GothamSemibold
              titleSlider.Text = sliderTitle
              titleSlider.TextColor3 = THEME.text
              titleSlider.TextSize = 13
              titleSlider.TextXAlignment = Enum.TextXAlignment.Left
              Library:_BindLocaleText(titleSlider, opts.Title or "Value")
              local valueLabel = Instance.new("TextLabel", topRow)
              valueLabel.Size = UDim2.new(0.5, 0, 1, 0)
              valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
              valueLabel.BackgroundTransparency = 1
              valueLabel.Font = Enum.Font.Gotham
              valueLabel.TextColor3 = THEME.textDim
              valueLabel.TextSize = 13
              valueLabel.TextXAlignment = Enum.TextXAlignment.Right
              local track = Instance.new("Frame", sliderHolder)
              track.Size = UDim2.new(1, 0, 0, 6)
              track.Position = UDim2.new(0, 0, 0, 20)
              track.BackgroundColor3 = THEME.panelHighlight
              track.BorderSizePixel = 0
              Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
              local fill = Instance.new("Frame", track)
              fill.BackgroundColor3 = THEME.accent
              fill.BorderSizePixel = 0
              Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
              local knob = Instance.new("ImageLabel", track)
              knob.Size = UDim2.fromOffset(14, 14)
              knob.AnchorPoint = Vector2.new(0.5, 0.5)
              knob.Position = UDim2.new(0, 0, 0.5, 0)
              knob.BackgroundTransparency = 1
              knob.Image = "rbxassetid://3570695787"
              knob.ImageColor3 = THEME.textActive
              local minVal, maxVal = sliderMin, sliderMax
              local currentValue = sliderDefault
              local targetPercentage = (sliderDefault - minVal) / (maxVal - minVal)
              local currentPercentage = targetPercentage
              local draggingSlider = false
              local format = "%" .. "." .. decimals .. "f"
              local toggledState = toggleDefault
              local function UpdateSliderVisuals(percentage)
                  local value = minVal + (maxVal - minVal) * percentage
                  fill.Size = UDim2.new(percentage, 0, 1, 0)
                  knob.Position = UDim2.new(percentage, 0, 0.5, 0)
                  valueLabel.Text = string.format(format, value)
                  currentValue = value
                  if opts.OnSliderChange then opts.OnSliderChange(value) end
                  if opts.Callback and not Library._suppressCallbacks then opts.Callback(currentValue, toggledState) end
                  if opts.SaveKey then Library:_SaveSetting(opts.SaveKey, { value = currentValue, toggled = toggledState }) end
              end
              RunService.Heartbeat:Connect(function()
                  if currentPercentage ~= targetPercentage then
                      currentPercentage = currentPercentage + (targetPercentage - currentPercentage) * 0.1
                      if math.abs(currentPercentage - targetPercentage) < 0.001 then currentPercentage = targetPercentage end
                      UpdateSliderVisuals(currentPercentage)
                  end
              end)
              track.InputBegan:Connect(function(input)
                  if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                      draggingSlider = true
                      targetPercentage = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                  end
              end)
              UserInputService.InputChanged:Connect(function(input)
                  if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                      targetPercentage = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                  end
              end)
              UserInputService.InputEnded:Connect(function(input)
                  if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                      draggingSlider = false
                  end
              end)
              UpdateSliderVisuals(targetPercentage)
              local toggleHolder = Instance.new("TextButton", rowFrame)
              toggleHolder.Size = UDim2.new(1 - sliderPortion, 4, 1, 0)
              toggleHolder.Position = UDim2.new(sliderPortion, 4, 0, 0)
              toggleHolder.BackgroundTransparency = 1
              toggleHolder.Text = ""
              local trackToggle = Instance.new("Frame", toggleHolder)
              trackToggle.Size = UDim2.fromOffset(36, 18)
              trackToggle.Position = UDim2.new(1, -36, 0.5, 0)
              trackToggle.AnchorPoint = Vector2.new(1, 0.5)
              trackToggle.BackgroundColor3 = THEME.panelHighlight
              Instance.new("UICorner", trackToggle).CornerRadius = UDim.new(1, 0)
              local thumb = Instance.new("Frame", trackToggle)
              thumb.Size = UDim2.fromOffset(14, 14)
              thumb.AnchorPoint = Vector2.new(0.5, 0.5)
              thumb.BackgroundColor3 = THEME.textActive
              Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
              local function UpdateToggleVisuals(isOn, isInstant)
                  local tweenInfo = isInstant and TweenInfo.new(0) or TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                  local targetTrackColor = isOn and THEME.accent or THEME.panelHighlight
                  local targetThumbPos = isOn and UDim2.new(1, -9, 0.5, 0) or UDim2.new(0, 9, 0.5, 0)
                  TweenService:Create(trackToggle, tweenInfo, { BackgroundColor3 = targetTrackColor }):Play()
                  TweenService:Create(thumb, tweenInfo, { Position = targetThumbPos }):Play()
              end
              Library:_OnAccentChanged(function() UpdateToggleVisuals(toggledState, true) end)
              toggleHolder.Activated:Connect(function()
                  toggledState = not toggledState
                  UpdateToggleVisuals(toggledState, false)
                  if opts.OnToggleChange then opts.OnToggleChange(toggledState) end
                  if opts.Callback and not Library._suppressCallbacks then opts.Callback(currentValue, toggledState) end
                  if opts.SaveKey then Library:_SaveSetting(opts.SaveKey, { value = currentValue, toggled = toggledState }) end
              end)
              UpdateToggleVisuals(toggledState, true)
              local stObject = {}
              stObject.Object = { Slider = sliderHolder, Toggle = toggleHolder }
              stObject.GetSliderValue = function() return currentValue end
              stObject.SetSliderValue = function(v)
                  v = math.clamp(v, sliderMin, sliderMax)
                  local percentage = (v - sliderMin) / (sliderMax - sliderMin)
                  targetPercentage = percentage
                  currentPercentage = percentage
                  UpdateSliderVisuals(percentage)
              end
              stObject.GetToggleState = function() return toggledState end
              stObject.SetToggleState = function(v)
                  local newState = v and true or false
                  if toggledState == newState then return end
                  toggledState = newState
                  UpdateToggleVisuals(toggledState, false)
                  if opts.OnToggleChange then opts.OnToggleChange(toggledState) end
                  if opts.Callback and not Library._suppressCallbacks then opts.Callback(currentValue, toggledState) end
                  if opts.SaveKey then Library:_SaveSetting(opts.SaveKey, { value = currentValue, toggled = toggledState }) end
              end
              stObject.Call = function(val, toggle)
                  local value = val or currentValue
                  local tog = (toggle ~= nil) and toggle or toggledState
                  if opts.Callback and not Library._suppressCallbacks then opts.Callback(value, tog) end
              end
              if opts.SaveKey then
                  Library._widgetRegistry[opts.SaveKey] = stObject
              end
              return stObject
          end
          -- SECTION_IMPL_START
          function Section:CreateMultiSelectDropdown(opts)
              opts = opts or {}
              local items = opts.Items or {}
              local savedSelections = nil
              if opts.SaveKey then
                  local saved = Library:_GetSetting(opts.SaveKey, nil)
                  if typeof(saved) == "table" then savedSelections = saved end
              end
              local selections = {}
              local selectionCount = 0
              local holderMulti = Instance.new("Frame", contentFrame)
              holderMulti.Size = UDim2.new(1, 0, 0, 28)
              holderMulti.BackgroundTransparency = 1
              local titleMulti = Instance.new("TextLabel", holderMulti)
              titleMulti.Size = UDim2.new(0.5, -10, 1, 0)
              titleMulti.BackgroundTransparency = 1
              titleMulti.Font = Enum.Font.GothamSemibold
              titleMulti.Text = Library:_Translate(opts.Title or "Multi-Select")
              titleMulti.TextColor3 = THEME.text
              titleMulti.TextSize = 13
              titleMulti.TextXAlignment = Enum.TextXAlignment.Left
              Library:_BindLocaleText(titleMulti, opts.Title or "Multi-Select")
              local dropdownButton = Instance.new("TextButton", holderMulti)
              dropdownButton.Size = UDim2.new(0.5, 0, 1, 0)
              dropdownButton.Position = UDim2.new(0.5, 0, 0, 0)
              dropdownButton.BackgroundColor3 = THEME.panelHighlight
              dropdownButton.BackgroundTransparency = 0.5
              dropdownButton.Text = ""
              Instance.new("UICorner", dropdownButton).CornerRadius = UDim.new(0, 6)
              Instance.new("UIStroke", dropdownButton).Color = THEME.separator
              local selectedLabel = Instance.new("TextLabel", dropdownButton)
              selectedLabel.Size = UDim2.new(1, -8, 1, 0)
              selectedLabel.Position = UDim2.fromOffset(8, 0)
              selectedLabel.BackgroundTransparency = 1
              selectedLabel.Font = Enum.Font.Gotham
              selectedLabel.TextColor3 = THEME.textDim
              selectedLabel.TextSize = 13
              selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
              local function updateSelectionLabel()
                  selectedLabel.Text = selectionCount .. " / " .. #items .. " Selected"
              end
              local function getSelectedItemsAsTable()
                  local result = {}
                  for item, isSelected in pairs(selections) do if isSelected then table.insert(result, item) end end
                  return result
              end
              for _, item in ipairs(items) do
                  local isSelected = false
                  if savedSelections and savedSelections[item] ~= nil then isSelected = savedSelections[item] end
                  selections[item] = isSelected
                  if isSelected then selectionCount = selectionCount + 1 end
              end
              updateSelectionLabel()
              local function openDropdown(btn, createItemsFunc)
                  if activeDropdown == btn then closeActiveDropdown() return end
                  if activeDropdown then closeActiveDropdown() end
                  for _, child in ipairs(dropdownHost:GetChildren()) do
                      if child:IsA("GuiObject") and not child:IsA("UILayout") and not child:IsA("UIPadding") and not child:IsA("UIStroke") and not child:IsA("UICorner") then
                          child:Destroy()
                      end
                  end
                  activeDropdown = btn
                  clickToClose.Visible = true
                  createItemsFunc()
                  local openPos = UDim2.new(1, -dropdownHost.AbsoluteSize.X - 8, 0, headerHeight + 8)
                  TweenService:Create(dropdownHost, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = openPos }):Play()
              end
              dropdownButton.Activated:Connect(function()
                  openDropdown(dropdownButton, function()
                      local seen = {}
                      for _, item in ipairs(items) do
                          if not seen[item] then
                              seen[item] = true
                              local optionBtn = Instance.new("TextButton", dropdownHost)
                              optionBtn.Size = UDim2.new(1, 0, 0, 32)
                              optionBtn.BackgroundTransparency = 1
                              optionBtn.Text = ""
                              local boxMulti = Instance.new("Frame", optionBtn)
                              boxMulti.Size = UDim2.fromOffset(18, 18)
                              boxMulti.Position = UDim2.new(1, -8, 0.5, 0)
                              boxMulti.AnchorPoint = Vector2.new(1, 0.5)
                              boxMulti.BackgroundColor3 = THEME.accent
                              Instance.new("UICorner", boxMulti).CornerRadius = UDim.new(0, 4)
                              Library:_RegisterAccent(boxMulti, "BackgroundColor3")
                              local strokeMulti = Instance.new("UIStroke", boxMulti)
                              strokeMulti.Color = THEME.separator
                              strokeMulti.Transparency = 0.8
                              strokeMulti.Thickness = 0.5
                              local checkmarkMulti = Instance.new("ImageLabel", boxMulti)
                              checkmarkMulti.Size = UDim2.new(1, -4, 1, -4)
                              checkmarkMulti.Position = UDim2.new(0.5, 0, 0.5, 0)
                              checkmarkMulti.AnchorPoint = Vector2.new(0.5, 0.5)
                              checkmarkMulti.BackgroundTransparency = 1
                              checkmarkMulti.Image = "rbxassetid://101733655234124"
                              checkmarkMulti.ImageColor3 = THEME.textActive
                              local optionLabelMulti = Instance.new("TextLabel", optionBtn)
                              optionLabelMulti.Size = UDim2.new(1, -44, 1, 0)
                              optionLabelMulti.Position = UDim2.fromOffset(8, 0)
                              optionLabelMulti.BackgroundTransparency = 1
                              optionLabelMulti.Font = Enum.Font.Gotham
                              optionLabelMulti.Text = item
                              optionLabelMulti.TextColor3 = THEME.text
                              optionLabelMulti.TextSize = 13
                              optionLabelMulti.TextXAlignment = Enum.TextXAlignment.Left
                              optionLabelMulti.TextWrapped = false
                              optionLabelMulti.TextTruncate = Enum.TextTruncate.AtEnd
                              local function updateVisual(isInstant)
                                  local checked = selections[item]
                                  local tweenInfo = isInstant and TweenInfo.new(0) or TweenInfo.new(0.2)
                                  TweenService:Create(boxMulti, tweenInfo, { BackgroundTransparency = checked and 0 or 1 }):Play()
                                  TweenService:Create(checkmarkMulti, tweenInfo, { ImageTransparency = checked and 0 or 1 }):Play()
                              end
                              updateVisual(true)
                              optionBtn.Activated:Connect(function()
                                  selections[item] = not selections[item]
                                  if selections[item] then selectionCount += 1 else selectionCount -= 1 end
                                  updateVisual(false)
                                  updateSelectionLabel()
                                  if opts.Callback and not Library._suppressCallbacks then opts.Callback(getSelectedItemsAsTable()) end
                                  if opts.SaveKey then Library:_SaveSetting(opts.SaveKey, selections) end
                              end)
                          end
                      end
                  end)
              end)
              local multiObject = {}
              multiObject.Object = dropdownButton
              multiObject.GetSelections = function() return selections end
              multiObject.GetSelectedItems = function() return getSelectedItemsAsTable() end
              multiObject.SetSelection = function(values)
                  selections = values
                  selectionCount = 0
                  for _,v in pairs(values) do if v then selectionCount += 1 end end
                  updateSelectionLabel()
                  if opts.SaveKey then Library:_SaveSetting(opts.SaveKey, selections) end
                  if opts.Callback and not Library._suppressCallbacks then opts.Callback(getSelectedItemsAsTable()) end
              end
              multiObject.Call = function()
                  if opts.Callback and not Library._suppressCallbacks then opts.Callback(getSelectedItemsAsTable()) end
              end
              if opts.SaveKey then
                  Library._widgetRegistry[opts.SaveKey] = multiObject
              end
              return multiObject
          end
          -- SECTION_IMPL_START
          function Section:CreateInputBox(opts)
              opts = opts or {}
              local holderInput = Instance.new("Frame", contentFrame)
              holderInput.Size = UDim2.new(1, 0, 0, 28)
              holderInput.BackgroundTransparency = 1
              local titleInput = Instance.new("TextLabel", holderInput)
              titleInput.Size = UDim2.new(0.5, -10, 1, 0)
              titleInput.BackgroundTransparency = 1
              titleInput.Font = Enum.Font.GothamSemibold
              titleInput.Text = Library:_Translate(opts.Title or "Input")
              titleInput.TextColor3 = THEME.text
              titleInput.TextSize = 13
              titleInput.TextXAlignment = Enum.TextXAlignment.Left
              Library:_BindLocaleText(titleInput, opts.Title or "Input")
              local inputBox = Instance.new("TextBox", holderInput)
              inputBox.AutomaticSize = Enum.AutomaticSize.X
              inputBox.Size = UDim2.new(0, 120, 1, 0)
              inputBox.Position = UDim2.new(0.5, 0, 0, 0)
              inputBox.BackgroundColor3 = THEME.panelHighlight
              inputBox.BackgroundTransparency = 0.5
              inputBox.Font = Enum.Font.Gotham
              inputBox.TextColor3 = THEME.text
              inputBox.TextSize = 13
              local _phRaw = opts.Placeholder or "Enter text..."
              inputBox.PlaceholderText = Library:_Translate(_phRaw)
              inputBox.PlaceholderColor3 = THEME.textDim
              inputBox.TextXAlignment = Enum.TextXAlignment.Left
              inputBox.ClearTextOnFocus = false
              Library:_BindLocalePlaceholder(inputBox, _phRaw)
              local textPaddingInput = Instance.new("UIPadding", inputBox)
              textPaddingInput.PaddingLeft = UDim.new(0, 8)
              textPaddingInput.PaddingRight = UDim.new(0, 8)
              local cornerInput = Instance.new("UICorner", inputBox)
              cornerInput.CornerRadius = UDim.new(0, 6)
              local strokeInput = Instance.new("UIStroke", inputBox)
              strokeInput.Color = THEME.separator
              strokeInput.Transparency = 0.8
              strokeInput.Thickness = 1
              local function adjustWidth()
                  local w = inputBox.TextBounds.X
                  if w == 0 then w = 40 end
                  local newSize = UDim2.new(0, math.clamp(w + 16, 80, math.floor(holderInput.AbsoluteSize.X * 0.48)), 1, 0)
                  TweenService:Create(inputBox, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = newSize }):Play()
              end
              inputBox.Focused:Connect(function()
                  TweenService:Create(strokeInput, TweenInfo.new(0.2), { Color = THEME.accent, Transparency = 0.4 }):Play()
              end)
              inputBox.FocusLost:Connect(function(enterPressed)
                  TweenService:Create(strokeInput, TweenInfo.new(0.2), { Color = THEME.separator, Transparency = 0.8 }):Play()
                  if enterPressed and opts.Callback and not Library._suppressCallbacks then
                      opts.Callback(inputBox.Text)
                  end
                  if opts.SaveKey and enterPressed then
                      Library:_SaveSetting(opts.SaveKey, inputBox.Text)
                  end
                  adjustWidth()
              end)
              inputBox:GetPropertyChangedSignal("Text"):Connect(adjustWidth)
              if opts.SaveKey then
                  local savedVal = Library:_GetSetting(opts.SaveKey, nil)
                  if savedVal ~= nil then
                      inputBox.Text = tostring(savedVal)
                  end
              end
              local inputObject = {}
              inputObject.Object = inputBox
              inputObject.GetText = function() return inputBox.Text end
              inputObject.SetText = function(v)
                  local text = tostring(v)
                  inputBox.Text = text
                  if opts.Callback and not Library._suppressCallbacks then
                      opts.Callback(text)
                  end
                  if opts.SaveKey then
                      Library:_SaveSetting(opts.SaveKey, text)
                  end
              end
              inputObject.Call = function(val)
                  local v = val or inputBox.Text
                  if opts.Callback and not Library._suppressCallbacks then opts.Callback(v) end
              end
              if opts.SaveKey then
                  Library._widgetRegistry[opts.SaveKey] = inputObject
              end
              return inputObject
          end

          function Section:CreateDropdown(opts)
              opts = opts or {}
              local items = opts.Items or {}
              local defaultIndex = opts.Default or 1
              local currentSelection = items[defaultIndex]
              if opts.SaveKey then
                  local saved = Library:_GetSetting(opts.SaveKey, nil)
                  if saved ~= nil then
                      currentSelection = saved
                  end
              end
              local holderDrop = Instance.new("Frame", contentFrame)
              holderDrop.Size = UDim2.new(1, 0, 0, 28)
              holderDrop.BackgroundTransparency = 1
              local titleDrop = Instance.new("TextLabel", holderDrop)
              titleDrop.Size = UDim2.new(0.5, -10, 1, 0)
              titleDrop.BackgroundTransparency = 1
              titleDrop.Font = Enum.Font.GothamSemibold
              titleDrop.Text = Library:_Translate(opts.Title or "Dropdown")
              titleDrop.TextColor3 = THEME.text
              titleDrop.TextSize = 13
              titleDrop.TextXAlignment = Enum.TextXAlignment.Left
              Library:_BindLocaleText(titleDrop, opts.Title or "Dropdown")
              local dropdownButton = Instance.new("TextButton", holderDrop)
              dropdownButton.Size = UDim2.new(0.5, 0, 1, 0)
              dropdownButton.Position = UDim2.new(0.5, 0, 0, 0)
              dropdownButton.BackgroundColor3 = THEME.panelHighlight
              dropdownButton.BackgroundTransparency = 0.5
              dropdownButton.Text = ""
              Instance.new("UICorner", dropdownButton).CornerRadius = UDim.new(0, 6)
              Instance.new("UIStroke", dropdownButton).Color = THEME.separator
              local selectedLabel = Instance.new("TextLabel", dropdownButton)
              selectedLabel.Size = UDim2.new(1, -8, 1, 0)
              selectedLabel.Position = UDim2.fromOffset(8, 0)
              selectedLabel.BackgroundTransparency = 1
              selectedLabel.Font = Enum.Font.Gotham
              selectedLabel.Text = Library:_Translate(currentSelection)
              selectedLabel.TextColor3 = THEME.textDim
              selectedLabel.TextSize = 13
              selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
              selectedLabel.TextWrapped = false
              selectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
              local function _refreshSelectedText()
                  selectedLabel.Text = Library:_Translate(currentSelection)
              end
              Library:_onLanguageChanged(_refreshSelectedText)
              local function openDropdown(btn, createItemsFunc)
                  if activeDropdown == btn then
                      closeActiveDropdown()
                      return
                  end
                  if activeDropdown then
                      closeActiveDropdown()
                  end
                  for _, child in ipairs(dropdownHost:GetChildren()) do
                      if child:IsA("GuiObject") and not child:IsA("UILayout") and not child:IsA("UIPadding") and not child:IsA("UIStroke") and not child:IsA("UICorner") then
                          child:Destroy()
                      end
                  end
                  activeDropdown = btn
                  clickToClose.Visible = true
                  createItemsFunc()
                  local openPos = UDim2.new(1, -dropdownHost.AbsoluteSize.X - 8, 0, headerHeight + 8)
                  TweenService:Create(dropdownHost, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = openPos }):Play()
              end
              dropdownButton.Activated:Connect(function()
                  openDropdown(dropdownButton, function()
                      local seenItems = {}
                      for _, item in ipairs(items) do
                          if not seenItems[item] then
                              seenItems[item] = true
                              local optionBtn = Instance.new("TextButton", dropdownHost)
                              optionBtn.Size = UDim2.new(1, 0, 0, 32)
                              optionBtn.BackgroundColor3 = THEME.panel
                              optionBtn.BackgroundTransparency = 1
                              optionBtn.Text = ""
                              optionBtn:SetAttribute("rawItem", item)
                              Instance.new("UICorner", optionBtn).CornerRadius = UDim.new(0, 6)
                              local marker = Instance.new("Frame", optionBtn)
                              marker.Size = UDim2.fromOffset(2, 18)
                              marker.Position = UDim2.new(0, 3, 0.5, 0)
                              marker.AnchorPoint = Vector2.new(0, 0.5)
                              marker.BackgroundColor3 = THEME.accent
                              marker.BorderSizePixel = 0
                              Instance.new("UICorner", marker).CornerRadius = UDim.new(1, 0)
                              local optionLabel = Instance.new("TextLabel", optionBtn)
                              optionLabel.Size = UDim2.new(1, -16, 1, 0)
                              optionLabel.Position = UDim2.fromOffset(8, 0)
                              optionLabel.BackgroundTransparency = 1
                              optionLabel.Font = Enum.Font.GothamSemibold
                              optionLabel.Text = Library:_Translate(item)
                              optionLabel.TextColor3 = THEME.text
                              optionLabel.TextSize = 13
                              optionLabel.TextXAlignment = Enum.TextXAlignment.Left
                              optionLabel.TextWrapped = false
                              optionLabel.TextTruncate = Enum.TextTruncate.AtEnd
                              marker.Visible = (item == currentSelection)
                              optionBtn.MouseEnter:Connect(function()
                                  TweenService:Create(optionBtn, TweenInfo.new(0.2), { BackgroundColor3 = THEME.panelHighlight, BackgroundTransparency = 0.5 }):Play()
                              end)
                              optionBtn.MouseLeave:Connect(function()
                                  TweenService:Create(optionBtn, TweenInfo.new(0.2), { BackgroundColor3 = THEME.panel, BackgroundTransparency = 1 }):Play()
                              end)
                              optionBtn.Activated:Connect(function()
                                  currentSelection = item
                                  _refreshSelectedText()
                                  for _, c in ipairs(dropdownHost:GetChildren()) do
                                      if c:IsA("TextButton") then
                                          local m
                                          for _, cc in ipairs(c:GetChildren()) do if cc:IsA("Frame") then m = cc break end end
                                          local raw = c:GetAttribute("rawItem")
                                          if m then m.Visible = (raw == currentSelection) end
                                      end
                                  end
                                  if opts.Callback and not Library._suppressCallbacks then opts.Callback(item) end
                                  if opts.SaveKey then Library:_SaveSetting(opts.SaveKey, item) end
                                  closeActiveDropdown()
                              end)
                          end
                      end
                  end)
              end)
              local dropdownObject = {}
              dropdownObject.Object = dropdownButton
              dropdownObject.GetSelection = function() return currentSelection end
              dropdownObject.SetSelection = function(val)
                  if not val then return end
                  if not table.find(items, val) then return end
                  currentSelection = val
                  selectedLabel.Text = Library:_Translate(val)
                  if opts.Callback and not Library._suppressCallbacks then opts.Callback(val) end
                  if opts.SaveKey then Library:_SaveSetting(opts.SaveKey, val) end
              end
              dropdownObject.Call = function(val)
                  local v = val or currentSelection
                  if opts.Callback and not Library._suppressCallbacks then opts.Callback(v) end
              end
              if opts.SaveKey then
                  Library._widgetRegistry[opts.SaveKey] = dropdownObject
              end
              return dropdownObject
          end
          -- SECTION_IMPL_START
          function Section:CreateCheckbox(opts)
              opts = opts or {}
              local checked = Library:_GetSetting(opts.SaveKey, opts.Default or false)
              local holder = Instance.new("TextButton", contentFrame)
              holder.Size = UDim2.new(1, 0, 0, 26)
              holder.BackgroundTransparency = 1
              holder.Text = ""
              local titleCheck = Instance.new("TextLabel", holder)
              titleCheck.Size = UDim2.new(1, -30, 1, 0)
              titleCheck.BackgroundTransparency = 1
              titleCheck.Font = Enum.Font.GothamSemibold
              titleCheck.Text = Library:_Translate(opts.Title or "Checkbox")
              titleCheck.TextColor3 = THEME.text
              titleCheck.TextSize = 13
              titleCheck.TextXAlignment = Enum.TextXAlignment.Left
              Library:_BindLocaleText(titleCheck, opts.Title or "Checkbox")
              local box = Instance.new("Frame", holder)
              box.Size = UDim2.fromOffset(18, 18)
              box.Position = UDim2.new(1, 0, 0.5, 0)
              box.AnchorPoint = Vector2.new(1, 0.5)
              box.BackgroundColor3 = THEME.accent
              box.BackgroundTransparency = 1
              Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
              local strokeCheck = Instance.new("UIStroke", box)
              strokeCheck.Color = THEME.separator
              strokeCheck.Transparency = 0.8
              strokeCheck.Thickness = 0.5
              local checkmark = Instance.new("ImageLabel", box)
              checkmark.Size = UDim2.new(1, -4, 1, -4)
              checkmark.Position = UDim2.new(0.5, 0, 0.5, 0)
              checkmark.AnchorPoint = Vector2.new(0.5, 0.5)
              checkmark.BackgroundTransparency = 1
              checkmark.Image = "rbxassetid://101733655234124"
              checkmark.ImageColor3 = THEME.textActive
              checkmark.ImageTransparency = 1
              local function UpdateCheckbox(state, isInstant)
                  checked = state
                  local tweenInfo = isInstant and TweenInfo.new(0) or TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                  local targetBgTransparency = checked and 0 or 1
                  local targetCheckTransparency = checked and 0 or 1
                  local targetStrokeTransparency = checked and 1 or 0.8
                  TweenService:Create(box, tweenInfo, { BackgroundTransparency = targetBgTransparency }):Play()
                  TweenService:Create(checkmark, tweenInfo, { ImageTransparency = targetCheckTransparency }):Play()
                  TweenService:Create(strokeCheck, tweenInfo, { Transparency = targetStrokeTransparency }):Play()
                  if opts.Callback and not isInstant and not Library._suppressCallbacks then
                      opts.Callback(checked)
                  end
                  if opts.SaveKey and not isInstant then
                      Library:_SaveSetting(opts.SaveKey, checked)
                  end
              end
              holder.Activated:Connect(function() UpdateCheckbox(not checked) end)
              UpdateCheckbox(checked, true)
              local checkboxObject = {}
              checkboxObject.Object = holder
              checkboxObject.GetState = function() return checked end
              checkboxObject.SetState = function(v) UpdateCheckbox(v, false) end
              checkboxObject.Call = function(val)
                  local v = (val ~= nil) and val or checked
                  if opts.Callback and not Library._suppressCallbacks then opts.Callback(v) end
              end
              if opts.SaveKey then
                  Library._widgetRegistry[opts.SaveKey] = checkboxObject
              end
              return checkboxObject
          end

          function Section:CreateKeybind(opts)
              opts = opts or {}
              local defaultKC = opts.Default or Library.Config.ToggleKey
              if opts.SaveKey then
                  local saved = Library:_GetSetting(opts.SaveKey, nil)
                  if saved then
                      local kc = Library.stringToKeycode(saved)
                      if kc then defaultKC = kc end
                  end
              end
              local holder = Instance.new("Frame", contentFrame)
              holder.Size = UDim2.new(1, 0, 0, 28)
              holder.BackgroundTransparency = 1
              local title = Instance.new("TextLabel", holder)
              title.Size = UDim2.new(1, -120, 1, 0)
              title.BackgroundTransparency = 1
              title.Font = Enum.Font.GothamSemibold
              title.Text = Library:_Translate(opts.Title or "Toggle Key")
              title.TextColor3 = THEME.text
              title.TextSize = 13
              title.TextXAlignment = Enum.TextXAlignment.Left
              Library:_BindLocaleText(title, opts.Title or "Toggle Key")
              local bindBtn = Instance.new("TextButton", holder)
              bindBtn.Size = UDim2.new(0, 110, 1, 0)
              bindBtn.Position = UDim2.new(1, 0, 0, 0)
              bindBtn.AnchorPoint = Vector2.new(1, 0)
              bindBtn.BackgroundColor3 = THEME.panelHighlight
              bindBtn.BackgroundTransparency = 0.5
              bindBtn.Text = Library.keycodeToString(defaultKC)
              bindBtn.Font = Enum.Font.Gotham
              bindBtn.TextSize = 12
              bindBtn.TextColor3 = THEME.textDim
              Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 6)
              local stroke = Instance.new("UIStroke", bindBtn)
              stroke.Color = THEME.separator
              stroke.Transparency = 0.85
              stroke.Thickness = 1
              local currentKC = defaultKC
              local listenConn
              local listening = false
              local function setKey(kc, fromUser)
                  if not kc then return end
                  currentKC = kc
                  bindBtn.Text = Library.keycodeToString(kc)
                  local w = bindBtn.TextBounds.X
                  if w == 0 then w = 40 end
                  bindBtn.Size = UDim2.new(0, math.clamp(w + 16, 60, 200), 1, 0)
                  if opts.SetToggleKey ~= false then
                      Library.Config.ToggleKey = kc
                  end
                  if opts.Callback and not Library._suppressCallbacks then opts.Callback(kc) end
                  if opts.SaveKey then Library:_SaveSetting(opts.SaveKey, Library.keycodeToString(kc)) end
              end
              bindBtn.Activated:Connect(function()
                  if listening then return end
                  listening = true
                  Library._captureBlockInput = true
                  bindBtn.Text = "Press a key..."
                  listenConn = UserInputService.InputBegan:Connect(function(input, gp)
                      if gp then return end
                      if input.UserInputType == Enum.UserInputType.Keyboard then
                          local kc = input.KeyCode
                          if kc and kc ~= Enum.KeyCode.Unknown then
                              setKey(kc, true)
                              listening = false
                              Library._captureBlockInput = false
                              listenConn:Disconnect()
                          end
                      end
                  end)
              end)
              setKey(currentKC, false)
              local bindObj = {}
              bindObj.Object = bindBtn
              bindObj.GetKey = function() return currentKC end
              bindObj.SetKey = function(v)
                  local kc = v
                  if typeof(v) == "string" then kc = Library.stringToKeycode(v) end
                  if kc then setKey(kc, false) end
              end
              bindObj.Call = function(v)
                  if opts.Callback and not Library._suppressCallbacks then opts.Callback(v or currentKC) end
              end
              if opts.SaveKey then
                  Library._widgetRegistry[opts.SaveKey] = bindObj
              end
              return bindObj
          end
          -- SECTION_IMPL_START
          function Section:CreateSlider(opts)
              opts = opts or {}
              local sliderHolder = Instance.new("Frame", contentFrame)
              sliderHolder.Size = UDim2.new(1, 0, 0, 38)
              sliderHolder.BackgroundTransparency = 1
              local topRow = Instance.new("Frame", sliderHolder)
              topRow.Size = UDim2.new(1, 0, 0, 18)
              topRow.BackgroundTransparency = 1
              local titleSlider = Instance.new("TextLabel", topRow)
              titleSlider.Size = UDim2.new(0.5, 0, 1, 0)
              titleSlider.BackgroundTransparency = 1
              titleSlider.Font = Enum.Font.GothamSemibold
              titleSlider.Text = Library:_Translate(opts.Title or "Slider")
              titleSlider.TextColor3 = THEME.text
              titleSlider.TextSize = 13
              titleSlider.TextXAlignment = Enum.TextXAlignment.Left
              Library:_BindLocaleText(titleSlider, opts.Title or "Slider")
              local valueLabel = Instance.new("TextLabel", topRow)
              valueLabel.Size = UDim2.new(0.5, 0, 1, 0)
              valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
              valueLabel.BackgroundTransparency = 1
              valueLabel.Font = Enum.Font.Gotham
              valueLabel.TextColor3 = THEME.textDim
              valueLabel.TextSize = 13
              valueLabel.TextXAlignment = Enum.TextXAlignment.Right
              local track = Instance.new("Frame", sliderHolder)
              track.Size = UDim2.new(1, 0, 0, 6)
              track.Position = UDim2.new(0, 0, 0, 20)
              track.BackgroundColor3 = THEME.panelHighlight
              track.BorderSizePixel = 0
              Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
              local fill = Instance.new("Frame", track)
              fill.BackgroundColor3 = THEME.accent
              fill.BorderSizePixel = 0
              Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
              Library:_RegisterAccent(fill, "BackgroundColor3")
              local knob = Instance.new("ImageLabel", track)
              knob.Size = UDim2.fromOffset(14, 14)
              knob.AnchorPoint = Vector2.new(0.5, 0.5)
              knob.Position = UDim2.new(0, 0, 0.5, 0)
              knob.BackgroundTransparency = 1
              knob.Image = "rbxassetid://3570695787"
              knob.ImageColor3 = THEME.textActive
              local minVal, maxVal, defaultVal, decimals = opts.Min or 0, opts.Max or 100, opts.Default or 50, opts.Decimals or 0
              defaultVal = Library:_GetSetting(opts.SaveKey, defaultVal)
              local currentValue, targetPercentage, currentPercentage = defaultVal, (defaultVal - minVal) / (maxVal - minVal), (defaultVal - minVal) / (maxVal - minVal)
              local draggingSlider = false
              local format = "%" .. "." .. decimals .. "f"
              local function UpdateVisuals(percentage)
                  local value = minVal + (maxVal - minVal) * percentage
                  fill.Size = UDim2.new(percentage, 0, 1, 0)
                  knob.Position = UDim2.new(percentage, 0, 0.5, 0)
                  valueLabel.Text = string.format(format, value)
                  if currentValue ~= value then
                      currentValue = value
                      if opts.Callback and not Library._suppressCallbacks then opts.Callback(value) end
                      if opts.SaveKey then
                          Library:_SaveSetting(opts.SaveKey, value)
                      end
                  end
              end
              RunService.Heartbeat:Connect(function()
                  if currentPercentage ~= targetPercentage then
                      currentPercentage = currentPercentage + (targetPercentage - currentPercentage) * 0.1
                      if math.abs(currentPercentage - targetPercentage) < 0.001 then currentPercentage = targetPercentage end
                      UpdateVisuals(currentPercentage)
                  end
              end)
              track.InputBegan:Connect(function(input)
                  if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                      draggingSlider = true
                      targetPercentage = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                  end
              end)
              UserInputService.InputChanged:Connect(function(input)
                  if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                      targetPercentage = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                  end
              end)
              UserInputService.InputEnded:Connect(function(input)
                  if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                      draggingSlider = false
                  end
              end)
              UpdateVisuals(currentPercentage)
              local sliderObject = {}
              sliderObject.Object = sliderHolder
              sliderObject.GetValue = function() return currentValue end
              sliderObject.SetNumber = function(setval)
                  setval = math.clamp(setval, minVal, maxVal)
                  local percentage = (setval - minVal) / (maxVal - minVal)
                  targetPercentage = percentage
                  currentPercentage = percentage
                  UpdateVisuals(percentage)
                  if opts.Callback and not Library._suppressCallbacks then opts.Callback(setval) end
              end
              sliderObject.Call = function(val)
                  local value = val or currentValue
                  if opts.Callback and not Library._suppressCallbacks then opts.Callback(value) end
              end
              if opts.SaveKey then
                  Library._widgetRegistry[opts.SaveKey] = sliderObject
              end
              return sliderObject
          end

          function Section:CreateToggle(opts)
              opts = opts or {}
              local toggled = Library:_GetSetting(opts.SaveKey, opts.Default or false)
              local holderToggle = Instance.new("TextButton", contentFrame)
              holderToggle.Size = UDim2.new(1, 0, 0, 26)
              holderToggle.BackgroundTransparency = 1
              holderToggle.Text = ""
              local titleToggle = Instance.new("TextLabel", holderToggle)
              titleToggle.Size = UDim2.new(1, -50, 1, 0)
              titleToggle.BackgroundTransparency = 1
              titleToggle.Font = Enum.Font.GothamSemibold
              titleToggle.Text = Library:_Translate(opts.Title or "Toggle")
              titleToggle.TextColor3 = THEME.text
              titleToggle.TextSize = 13
              titleToggle.TextXAlignment = Enum.TextXAlignment.Left
              Library:_BindLocaleText(titleToggle, opts.Title or "Toggle")
              local trackToggle = Instance.new("Frame", holderToggle)
              trackToggle.Size = UDim2.fromOffset(36, 18)
              trackToggle.Position = UDim2.new(1, 0, 0.5, 0)
              trackToggle.AnchorPoint = Vector2.new(1, 0.5)
              trackToggle.BackgroundColor3 = THEME.panelHighlight
              Instance.new("UICorner", trackToggle).CornerRadius = UDim.new(1, 0)
              local thumb = Instance.new("Frame", trackToggle)
              thumb.Size = UDim2.fromOffset(14, 14)
              thumb.AnchorPoint = Vector2.new(0.5, 0.5)
              thumb.BackgroundColor3 = THEME.textActive
              Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
              local function UpdateToggle(state, isInstant)
                  toggled = state
                  local tweenInfo = isInstant and TweenInfo.new(0) or TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                  local targetTrackColor = toggled and THEME.accent or THEME.panelHighlight
                  local targetThumbPos = toggled and UDim2.new(1, -9, 0.5, 0) or UDim2.new(0, 9, 0.5, 0)
                  TweenService:Create(trackToggle, tweenInfo, { BackgroundColor3 = targetTrackColor }):Play()
                  TweenService:Create(thumb, tweenInfo, { Position = targetThumbPos }):Play()
                  if opts.Callback and not isInstant and not Library._suppressCallbacks then
                      opts.Callback(toggled)
                  end
                  if opts.SaveKey and not isInstant then
                      Library:_SaveSetting(opts.SaveKey, toggled)
                  end
              end
              Library:_OnAccentChanged(function() UpdateToggle(toggled, true) end)
              holderToggle.Activated:Connect(function() UpdateToggle(not toggled) end)
              UpdateToggle(toggled, true)
              local toggleObject = {}
              toggleObject.Object = holderToggle
              toggleObject.GetState = function() return toggled end
              toggleObject.SetState = function(v) UpdateToggle(v, false) end
              toggleObject.Call = function(val)
                  local v = (val ~= nil) and val or toggled
                  if opts.Callback and not Library._suppressCallbacks then opts.Callback(v) end
              end
              if opts.SaveKey then
                  Library._widgetRegistry[opts.SaveKey] = toggleObject
              end
              return toggleObject
          end
          -- SECTION_IMPL_START
          local Section = {}
          secOptions = secOptions or {}
          local sectionTitle = Library:_Translate(secOptions.Title or "Unnamed Section")
          local sectionIcon = secOptions.Icon
          local sectionHelpText = Library:_Translate(secOptions.HelpText or secOptions.Description or "")
          local expanded = false

          local sectionFrame = Instance.new("Frame", pageContainer)
          sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
          sectionFrame.Size = UDim2.new(1, 0, 0, 0)
          sectionFrame.BackgroundColor3 = THEME.panel
          sectionFrame.BackgroundTransparency = 0.7
          sectionFrame.BorderSizePixel = 0
          Instance.new("UICorner", sectionFrame).CornerRadius = UDim.new(0, 6)
          local sectionStroke = Instance.new("UIStroke", sectionFrame)
          sectionStroke.Color = THEME.separator
          sectionStroke.Transparency = 0.9
          sectionStroke.Thickness = 1
          sectionStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

          local layout = Instance.new("UIListLayout", sectionFrame)
          layout.SortOrder = Enum.SortOrder.LayoutOrder
          local header = Instance.new("TextButton", sectionFrame)
          header.Name = "Header"
          header.Size = UDim2.new(1, 0, 0, 34)
          header.BackgroundTransparency = 1
          header.Text = ""
          header.LayoutOrder = 1
          if sectionIcon then
              local icon = Instance.new("ImageLabel", header)
              icon.Size = UDim2.fromOffset(16, 16)
              icon.Position = UDim2.new(0, 15, 0.5, 0)
              icon.AnchorPoint = Vector2.new(0, 0.5)
              icon.BackgroundTransparency = 1
              icon.Image = sectionIcon
          end
          local titleLabel2 = Instance.new("TextLabel", header)
          local titleXOffset = sectionIcon and 38 or 15
          titleLabel2.Size = UDim2.new(1, -(titleXOffset + 25), 1, 0)
          titleLabel2.Position = UDim2.fromOffset(titleXOffset, 0)
          titleLabel2.BackgroundTransparency = 1
          titleLabel2.Font = Enum.Font.GothamBold
          titleLabel2.Text = sectionTitle
          titleLabel2.TextColor3 = THEME.text
          titleLabel2.TextSize = 14
          titleLabel2.TextXAlignment = Enum.TextXAlignment.Left
          Library:_BindLocaleText(titleLabel2, secOptions.Title or "Unnamed Section")

          local helpBtn = Instance.new("TextButton", header)
          local helpBtnConnected = false
          helpBtn.Name = "HelpButton"
          helpBtn.Size = UDim2.fromOffset(16, 16)
          helpBtn.Position = UDim2.new(1, -12, 0.5, 0)
          helpBtn.AnchorPoint = Vector2.new(1, 0.5)
          helpBtn.AutoButtonColor = false
          helpBtn.BackgroundColor3 = THEME.panel
          helpBtn.BackgroundTransparency = 0.6
          helpBtn.Text = ""
          helpBtn.Visible = false
          Instance.new("UICorner", helpBtn).CornerRadius = UDim.new(0, 4)
          local helpStroke = Instance.new("UIStroke", helpBtn)
          helpStroke.Color = THEME.separator
          helpStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
          helpStroke.LineJoinMode = Enum.LineJoinMode.Round
          helpStroke.Thickness = 0.5
          helpStroke.Transparency = 0.95
          local iconImg = Instance.new("ImageLabel", helpBtn)
          iconImg.BackgroundTransparency = 1
          iconImg.Size = UDim2.fromOffset(12, 12)
          iconImg.AnchorPoint = Vector2.new(0.5, 0.5)
          iconImg.Position = UDim2.fromScale(0.5, 0.5)
          iconImg.Image = "rbxassetid://80209557780292"
          iconImg.ImageColor3 = THEME.text
          iconImg.ImageTransparency = 0.05
          local helpScale = Instance.new("UIScale", helpBtn)
          helpScale.Scale = 0.96

          local collapsedIcon = Instance.new("ImageLabel", header)
          collapsedIcon.Name = "CollapsedFingerprint"
          collapsedIcon.Size = UDim2.fromOffset(16, 16)
          collapsedIcon.Position = UDim2.new(1, -12, 0.5, 0)
          collapsedIcon.AnchorPoint = Vector2.new(1, 0.5)
          collapsedIcon.BackgroundTransparency = 1
          collapsedIcon.Image = "rbxassetid://125804091911528"
          local FP_DEFAULT_COLOR = THEME.textDim
          local FP_DEFAULT_TRANSP = 0.30
          local FP_HOVER_COLOR = THEME.text
          local FP_HOVER_TRANSP = 0.05
          collapsedIcon.ImageColor3 = FP_DEFAULT_COLOR
          collapsedIcon.ImageTransparency = FP_DEFAULT_TRANSP
          collapsedIcon.ZIndex = 2
          collapsedIcon.Visible = true

          local hoverTI = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
          header.MouseEnter:Connect(function()
              if not expanded and collapsedIcon.Visible then
                  TweenService:Create(collapsedIcon, hoverTI, {
                      ImageColor3 = FP_HOVER_COLOR,
                      ImageTransparency = FP_HOVER_TRANSP,
                  }):Play()
              end
          end)
          header.MouseLeave:Connect(function()
              if not expanded and collapsedIcon.Visible then
                  TweenService:Create(collapsedIcon, hoverTI, {
                      ImageColor3 = FP_DEFAULT_COLOR,
                      ImageTransparency = FP_DEFAULT_TRANSP,
                  }):Play()
              end
          end)

          local separator = Instance.new("Frame", sectionFrame)
          separator.LayoutOrder = 2
          separator.Size = UDim2.new(1, 0, 0, 1)
          separator.BackgroundColor3 = THEME.separator
          separator.BackgroundTransparency = 0.9
          separator.BorderSizePixel = 0
          separator.Visible = false

          local contentFrame = Instance.new("Frame", sectionFrame)
          contentFrame.Name = "Content"
          contentFrame.Size = UDim2.new(1, 0, 0, 0)
          contentFrame.BackgroundTransparency = 1
          contentFrame.ClipsDescendants = true
          contentFrame.LayoutOrder = 3
          local contentLayout = Instance.new("UIListLayout", contentFrame)
          contentLayout.Padding = UDim.new(0, 8)
          local contentPadding = Instance.new("UIPadding", contentFrame)
          contentPadding.PaddingTop = UDim.new(0, 8)
          contentPadding.PaddingLeft = UDim.new(0, 15)
          contentPadding.PaddingRight = UDim.new(0, 15)
          contentPadding.PaddingBottom = UDim.new(0, 12)

          header.Activated:Connect(function()
              expanded = not expanded
              separator.Visible = expanded
              local contentSize = contentLayout.AbsoluteContentSize.Y + contentPadding.PaddingTop.Offset + contentPadding.PaddingBottom.Offset
              local targetSize = expanded and UDim2.new(1, 0, 0, contentSize) or UDim2.new(1, 0, 0, 0)
              local duration = math.clamp(0.25 + (contentSize / 600), 0.3, 0.7)
              local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
              TweenService:Create(contentFrame, tweenInfo, { Size = targetSize }):Play()

              if expanded then
                  if collapsedIcon.Visible then
                      local outTI = TweenInfo.new(math.min(duration * 0.5, 0.28), Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                      TweenService:Create(collapsedIcon, outTI, {
                          ImageTransparency = 1,
                          ImageColor3 = FP_DEFAULT_COLOR,
                      }):Play()
                      task.delay(outTI.Time, function()
                          if expanded then
                              collapsedIcon.Visible = false
                              collapsedIcon.ImageColor3 = FP_DEFAULT_COLOR
                              collapsedIcon.ImageTransparency = FP_DEFAULT_TRANSP
                          end
                      end)
                  end
                  helpBtn.Visible = true
                  helpScale.Scale = 0.92
                  helpBtn.BackgroundTransparency = 1
                  iconImg.ImageTransparency = 1
                  helpStroke.Transparency = 0.95
                  local tiIn = TweenInfo.new(math.min(duration * 0.5, 0.28), Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                  TweenService:Create(helpBtn, tiIn, { BackgroundTransparency = 0.6 }):Play()
                  TweenService:Create(iconImg, tiIn, { ImageTransparency = 0.05 }):Play()
                  TweenService:Create(helpScale, TweenInfo.new(tiIn.Time, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
              else
                  local tiOut = TweenInfo.new(math.min(duration * 0.45, 0.26), Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                  local fadeOut = TweenService:Create(helpBtn, tiOut, { BackgroundTransparency = 1 })
                  local iconFade = TweenService:Create(iconImg, tiOut, { ImageTransparency = 1 })
                  local shrink = TweenService:Create(helpScale, TweenInfo.new(tiOut.Time, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.96 })
                  shrink:Play(); iconFade:Play(); fadeOut:Play()
                  fadeOut.Completed:Connect(function()
                      helpBtn.Visible = false
                  end)
                  collapsedIcon.Visible = true
                  collapsedIcon.ImageTransparency = 1
                  collapsedIcon.ImageColor3 = FP_DEFAULT_COLOR
                  TweenService:Create(collapsedIcon, tiOut, {
                      ImageTransparency = FP_DEFAULT_TRANSP,
                      ImageColor3 = FP_DEFAULT_COLOR,
                  }):Play()
              end

              if not helpBtnConnected then
                  helpBtnConnected = true
                  helpBtn.Activated:Connect(function()
                      local pulse1 = TweenService:Create(helpScale, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1.06 })
                      pulse1.Completed:Connect(function()
                          TweenService:Create(helpScale, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Scale = 1 }):Play()
                      end)
                      pulse1:Play()
                      local text = sectionHelpText
                      if text == nil or text == "" then
                          text = ""
                      end
                      Library:NotifyBottom({ Title = sectionTitle, Text = text, Duration = 3.5 })
                  end)
              end

              if expanded then
                  task.delay(0.02, function()
                      local scroller = pageContainer
                      if scroller and scroller:IsA("ScrollingFrame") then
                          local contentSizeNow = contentLayout.AbsoluteContentSize.Y + contentPadding.PaddingTop.Offset + contentPadding.PaddingBottom.Offset
                          local bottom = sectionFrame.AbsolutePosition.Y + contentSizeNow + 34 - scroller.AbsolutePosition.Y
                          local overflow = bottom - scroller.AbsoluteSize.Y
                          if overflow > 0 then
                              local target = Vector2.new(scroller.CanvasPosition.X, overflow + 12)
                              local t = 0
                              local start = scroller.CanvasPosition
                              local dur = math.clamp(duration, 0.2, 0.6)
                              local conn
                              conn = RunService.RenderStepped:Connect(function(dt)
                                  t = math.min(t + dt, dur)
                                  local alpha = t / dur
                                  scroller.CanvasPosition = start:Lerp(target, alpha)
                                  if t >= dur and conn then conn:Disconnect() end
                              end)
                          end
                      end
                  end)
              end
          end)

          function Section:CreateDivider(opts)
              opts = opts or {}
              local rawName = opts.Title or opts.Label or "Divider"
              local holder = Instance.new("Frame", contentFrame)
              holder.Size = UDim2.new(1, 0, 0, 12)
              holder.BackgroundTransparency = 1
              holder.ClipsDescendants = false
              local label = Instance.new("TextLabel", holder)
              label.BackgroundTransparency = 1
              label.Font = Enum.Font.GothamBold
              label.TextSize = 12
              label.Text = Library:_Translate(rawName)
              label.TextColor3 = THEME.textDim
              label.TextXAlignment = Enum.TextXAlignment.Center
              label.AnchorPoint = Vector2.new(0.5, 0.5)
              label.Position = UDim2.new(0.5, 0, 0.5, 0)
              label.ZIndex = 2
              Library:_BindLocaleText(label, rawName)
              local leftLine = Instance.new("Frame", holder)
              leftLine.Name = "LeftLine"
              leftLine.AnchorPoint = Vector2.new(0, 0.5)
              leftLine.Position = UDim2.new(0, 0, 0.5, 0)
              leftLine.Size = UDim2.new(0.5, -40, 0, 1)
              leftLine.BackgroundColor3 = THEME.separator
              leftLine.BackgroundTransparency = 0.85
              leftLine.BorderSizePixel = 0
              local rightLine = Instance.new("Frame", holder)
              rightLine.Name = "RightLine"
              rightLine.AnchorPoint = Vector2.new(1, 0.5)
              rightLine.Position = UDim2.new(1, 0, 0.5, 0)
              rightLine.Size = UDim2.new(0.5, -40, 0, 1)
              rightLine.BackgroundColor3 = THEME.separator
              rightLine.BackgroundTransparency = 0.85
              rightLine.BorderSizePixel = 0
              local gap = (opts.Gap ~= nil) and opts.Gap or 8
              local extend = (opts.Extend ~= nil) and opts.Extend or 10
              local function adjust()
                  local absW = holder.AbsoluteSize.X
                  if absW <= 0 then return end
                  local textW = math.floor(label.TextBounds.X + 0.5)
                  local lineW = math.max(0, math.floor((absW - textW) * 0.5 - gap + extend))
                  leftLine.Size = UDim2.new(0, lineW, 0, 1)
                  rightLine.Size = UDim2.new(0, lineW, 0, 1)
              end
              label:GetPropertyChangedSignal("TextBounds"):Connect(adjust)
              holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(adjust)
              Library._deferCompat(adjust)
              local obj = { Object = holder }
              obj.SetTitle = function(v)
                  label.Text = tostring(v)
                  adjust()
              end
              return obj
          end

          function Section:CreateImage(opts)
              opts = opts or {}
              local imageAsset = opts.Asset
              if not imageAsset then return end
              local height = opts.Height or 120
              local imageHolder = Instance.new("Frame", contentFrame)
              imageHolder.Size = UDim2.new(1, 0, 0, height)
              imageHolder.BackgroundTransparency = 1
              local image = Instance.new("ImageLabel", imageHolder)
              image.Size = UDim2.new(1, 0, 1, 0)
              image.BackgroundTransparency = 1
              image.Image = imageAsset
              image.ScaleType = Enum.ScaleType.Fit
              Instance.new("UICorner", image).CornerRadius = UDim.new(0, 6)
              return { Object = image, Call = function() end }
          end

          -- SECTION_IMPL_START
          return Section
      end

      return Page
  end
  -- WINDOW_IMPL_START
  local _typeof = typeof or function(v) return type(v) end
  local TweenService = Library.Services.TweenService
  local TextService = Library.Services.TextService
  local UserInputService = Library.Services.UserInputService
  local RunService = Library.Services.RunService
  local PlayerGui = Library.PlayerGui

  local function toTitleCase(s)
      return (s:gsub("(%a)([%w_']*)", function(first, rest)
          return first:upper() .. rest:lower()
      end))
  end

  local options
  if _typeof(title) == "table" then
      options = title
      title = options.Title or options.WindowTitle or options[1] or title
      subtitle = options.Subtitle or options.SubTitle or options.SubtitleText or options.Description or subtitle
  end

  if options and (options.AutoDetectLanguage or options.ForceAutoLanguage) then
      self:AutoDetectLanguage({ Force = options.ForceAutoLanguage })
  end

  title = Library.asText(title, "UI Library")
  subtitle = Library.asText(subtitle, "Premium")

  if options and options.ToggleKey then
      local kc = options.ToggleKey
      if _typeof(kc) == "string" then kc = Library.stringToKeycode(kc) end
      if _typeof(kc) == "EnumItem" then
          self.Config.ToggleKey = kc
      end
  end

  if options and options.KeySystem ~= nil then
      self:ConfigureKeySystem(options.KeySystem)
  end

  if not self:_EnsureKeySystem() then
      return nil
  end

  if PlayerGui:FindFirstChild("Eps1llonUI_Window") then
      PlayerGui.Eps1llonUI_Window:Destroy()
  end

  local Window = {}
  local THEME = Library.Theme
  local CONFIG = Library.Config
  local HEADER_RIGHT_PADDING = 110
  local HEADER_RIGHT_PADDING_MINI = 48
  local MINIMIZED_MIN_WIDTH = 220
  local pages, activePage = {}, nil
  local isVisible = false
  local isAnimating = true
  local FADE_TIME = 0.2
  local mainGui = Instance.new("ScreenGui")
  mainGui.Name = "Eps1llonUI_Window"
  mainGui.ResetOnSpawn = false
  mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
  mainGui.Parent = PlayerGui
  local guiWidth, guiHeight = 580, 340

  local rootFrame = Instance.new("Frame")
  rootFrame.Name = "Root"
  rootFrame.Size = UDim2.fromOffset(guiWidth, guiHeight)
  rootFrame.AnchorPoint = Vector2.new(0, 0)
  rootFrame.Position = UDim2.new(0.5, -guiWidth/2, 0.5, -guiHeight/2)
  rootFrame.BackgroundColor3 = THEME.bg
  rootFrame.BackgroundTransparency = 0
  rootFrame.BorderSizePixel = 0
  rootFrame.Parent = mainGui
  rootFrame.ClipsDescendants = true
  Library:_SetGroupTransparency(rootFrame, 1)
  Instance.new("UICorner", rootFrame).CornerRadius = UDim.new(0, 14)

  local clickToClose = Instance.new("TextButton", rootFrame)
  clickToClose.Name = "ClickToClose"
  clickToClose.Size = UDim2.new(1, 0, 1, 0)
  clickToClose.BackgroundTransparency = 1
  clickToClose.Text = ""
  clickToClose.Visible = false
  clickToClose.ZIndex = 5

  local strokeHolder = Instance.new("Frame", rootFrame)
  strokeHolder.Name = "StrokeHolder"
  strokeHolder.Size = UDim2.new(1, 0, 1, 0)
  strokeHolder.BackgroundTransparency = 1
  Instance.new("UICorner", strokeHolder).CornerRadius = UDim.new(0, 14)
  local rootStroke = Instance.new("UIStroke", strokeHolder)
  rootStroke.Color = Color3.fromRGB(255, 255, 255)
  rootStroke.Transparency = 0.9
  rootStroke.Thickness = 1
  rootStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

  local headerHeight, tabsWidth = 44, 140
  local dragFrame = Instance.new("Frame", rootFrame)
  dragFrame.Size = UDim2.new(1, 0, 0, headerHeight)
  dragFrame.BackgroundTransparency = 1
  dragFrame.ZIndex = 2

  local brandLogo = Instance.new("ImageLabel", rootFrame)
  brandLogo.Size = UDim2.fromOffset(24, 24)
  brandLogo.Position = UDim2.fromOffset(12, 10)
  brandLogo.BackgroundTransparency = 1
  brandLogo.Image = "rbxassetid://116553067824026"

  local BRAND_CONTAINER_DEFAULT_SIZE = UDim2.new(1, -HEADER_RIGHT_PADDING, 0, 32)
  local brandContainer = Instance.new("Frame", rootFrame)
  brandContainer.Size = BRAND_CONTAINER_DEFAULT_SIZE
  brandContainer.Position = UDim2.fromOffset(42, 8)
  brandContainer.BackgroundTransparency = 1
  brandContainer.ClipsDescendants = true

  local brandTitlePrimary = Instance.new("TextLabel", brandContainer)
  brandTitlePrimary.Size = UDim2.new(1, 0, 0, 17)
  brandTitlePrimary.BackgroundTransparency = 1
  local _windowTitleRaw = title or "UI Library"
  brandTitlePrimary.Text = Library:_Translate(_windowTitleRaw)
  brandTitlePrimary.TextColor3 = THEME.text
  brandTitlePrimary.TextSize = 17
  brandTitlePrimary.Font = Enum.Font.GothamBold
  brandTitlePrimary.TextXAlignment = Enum.TextXAlignment.Left
  brandTitlePrimary.TextTruncate = Enum.TextTruncate.AtEnd

  local brandSubtitle = Instance.new("TextLabel", brandContainer)
  brandSubtitle.Size = UDim2.new(1, 0, 0, 13)
  brandSubtitle.Position = UDim2.fromOffset(0, 17)
  brandSubtitle.BackgroundTransparency = 1
  local _windowSubtitleRaw = subtitle or "Premium"
  brandSubtitle.Text = Library:_Translate(_windowSubtitleRaw)
  brandSubtitle.TextColor3 = THEME.textDim
  brandSubtitle.TextSize = 11
  brandSubtitle.Font = Enum.Font.GothamSemibold
  brandSubtitle.TextXAlignment = Enum.TextXAlignment.Left
  brandSubtitle.TextTruncate = Enum.TextTruncate.AtEnd

  Library:_BindLocaleText(brandTitlePrimary, _windowTitleRaw)
  Library:_BindLocaleText(brandSubtitle, _windowSubtitleRaw)

  local horizontalLine = Instance.new("Frame", rootFrame)
  horizontalLine.Size = UDim2.new(1, 0, 0, 1)
  horizontalLine.Position = UDim2.fromOffset(0, headerHeight)
  horizontalLine.BackgroundColor3 = THEME.separator
  horizontalLine.BackgroundTransparency = 0.9
  horizontalLine.BorderSizePixel = 0

  local mainContent = Instance.new("Frame", rootFrame)
  mainContent.Name = "MainContent"
  mainContent.Size = UDim2.new(1, 0, 1, -headerHeight)
  mainContent.Position = UDim2.fromOffset(0, headerHeight)
  mainContent.BackgroundTransparency = 1

  local verticalLine = Instance.new("Frame", mainContent)
  verticalLine.Size = UDim2.new(0, 1, 1, -1)
  verticalLine.Position = UDim2.fromOffset(tabsWidth, 1)
  verticalLine.BackgroundColor3 = THEME.separator
  verticalLine.BackgroundTransparency = 0.9
  verticalLine.BorderSizePixel = 0

  local tabsContainer = Instance.new("ScrollingFrame", mainContent)
  tabsContainer.Name = "TabsContainer"
  tabsContainer.Size = UDim2.new(0, tabsWidth, 1, 0)
  tabsContainer.Position = UDim2.fromOffset(0, 0)
  tabsContainer.BackgroundTransparency = 1
  tabsContainer.BorderSizePixel = 0
  tabsContainer.ScrollBarThickness = 0
  local listLayout = Instance.new("UIListLayout", tabsContainer)
  listLayout.Padding = UDim.new(0, CONFIG.TabPadding)
  listLayout.SortOrder = Enum.SortOrder.LayoutOrder
  Instance.new("UIPadding", tabsContainer).PaddingTop = UDim.new(0, 10)

  local activeTabIndicator = Instance.new("Frame", mainContent)
  activeTabIndicator.Name = "ActiveTabIndicator"
  activeTabIndicator.Size = UDim2.fromOffset(tabsWidth, 32)
  activeTabIndicator.Position = UDim2.fromOffset(0, headerHeight)
  activeTabIndicator.BackgroundTransparency = 1
  activeTabIndicator.ZIndex = 2
  activeTabIndicator.Visible = false

  local indicatorBG = Instance.new("Frame", activeTabIndicator)
  indicatorBG.Name = "IndicatorBG"
  indicatorBG.BackgroundColor3 = THEME.panelHighlight
  indicatorBG.BorderSizePixel = 0
  indicatorBG.Size = UDim2.new(1, -10, 1, -4)
  indicatorBG.Position = UDim2.new(0.5, 0, 0.5, 0)
  indicatorBG.AnchorPoint = Vector2.new(0.5, 0.5)
  indicatorBG.BackgroundTransparency = 0.75
  Instance.new("UICorner", indicatorBG).CornerRadius = UDim.new(0, 6)

  local activeMarker = Instance.new("Frame", activeTabIndicator)
  activeMarker.Name = "ActiveMarker"
  activeMarker.BackgroundColor3 = THEME.accent
  activeMarker.BorderSizePixel = 0
  activeMarker.Size = UDim2.fromOffset(2, 18)
  activeMarker.AnchorPoint = Vector2.new(0.5, 0.5)
  activeMarker.Position = UDim2.new(0, 12, 0.5, 0)
  Instance.new("UICorner", activeMarker).CornerRadius = UDim.new(1, 0)
  Library:_RegisterAccent(activeMarker, "BackgroundColor3")

  local pageHost = Instance.new("Frame", mainContent)
  pageHost.Size = UDim2.new(1, -tabsWidth, 1, 0)
  pageHost.Position = UDim2.fromOffset(tabsWidth, 0)
  pageHost.BackgroundTransparency = 1
  pageHost.ClipsDescendants = true

  local dropdownHost = Instance.new("ScrollingFrame", rootFrame)
  dropdownHost.Size = UDim2.new(0, 160, 1, -headerHeight - 20)
  dropdownHost.Position = UDim2.new(1, 10, 0, headerHeight + 10)
  dropdownHost.BackgroundColor3 = THEME.panel
  dropdownHost.BorderSizePixel = 0
  dropdownHost.ZIndex = 10
  dropdownHost.BackgroundTransparency = 0
  dropdownHost.ScrollBarThickness = 2
  dropdownHost.AutomaticCanvasSize = Enum.AutomaticSize.Y
  Instance.new("UICorner", dropdownHost).CornerRadius = UDim.new(0, 8)
  local dropdownStroke = Instance.new("UIStroke", dropdownHost)
  dropdownStroke.Color = THEME.separator
  dropdownStroke.Transparency = 0.9
  dropdownStroke.Thickness = 1
  Instance.new("UIListLayout", dropdownHost).Padding = UDim.new(0, 2)
  local dropdownPadding = Instance.new("UIPadding", dropdownHost)
  dropdownPadding.PaddingTop = UDim.new(0, 8)
  dropdownPadding.PaddingBottom = UDim.new(0, 8)
  dropdownPadding.PaddingLeft = UDim.new(0, 8)
  dropdownPadding.PaddingRight = UDim.new(0, 8)

  local activeDropdown = nil
  local activeContext = nil
  local activeBindEditor = nil
  local function closeActiveDropdown()
      if not activeDropdown then return end
      activeDropdown = nil
      clickToClose.Visible = false
      local closeTween = TweenService:Create(dropdownHost, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
          Position = UDim2.new(1, 10, 0, headerHeight + 10),
      })
      closeTween:Play()
      closeTween.Completed:Connect(function()
          for _, child in ipairs(dropdownHost:GetChildren()) do
              if child:IsA("GuiObject")
                  and not child:IsA("UILayout")
                  and not child:IsA("UIPadding")
                  and not child:IsA("UIStroke")
                  and not child:IsA("UICorner") then
                  child:Destroy()
              end
          end
      end)
  end
  local function closeActiveContext()
      if activeContext then pcall(function() activeContext:Destroy() end); activeContext = nil end
      if activeBindEditor then pcall(function() activeBindEditor:Destroy() end); activeBindEditor = nil end
      clickToClose.Visible = false
  end
  clickToClose.Activated:Connect(function()
      closeActiveDropdown()
      closeActiveContext()
  end)

  local headerControls = Instance.new("Frame", rootFrame)
  headerControls.Name = "HeaderControls"
  headerControls.Size = UDim2.new(0, 100, 0, headerHeight)
  local HEADER_CONTROLS_DEFAULT_POS = UDim2.new(1, -HEADER_RIGHT_PADDING, 0, 0)
  local HEADER_CONTROLS_MINI_POS = UDim2.new(1, -HEADER_RIGHT_PADDING_MINI, 0, 0)
  headerControls.Position = HEADER_CONTROLS_DEFAULT_POS
  headerControls.BackgroundTransparency = 1
  headerControls.ZIndex = 3

  local minimizeBtn = Instance.new("ImageButton", headerControls)
  minimizeBtn.Size = UDim2.fromOffset(20, 20)
  minimizeBtn.Position = UDim2.new(0, 10, 0.5, 0)
  minimizeBtn.AnchorPoint = Vector2.new(0, 0.5)
  minimizeBtn.BackgroundTransparency = 1
  minimizeBtn.Image = "rbxassetid://110574729016386"
  minimizeBtn.ImageColor3 = THEME.textDim

  local expandBtn = Instance.new("ImageButton", headerControls)
  expandBtn.Size = UDim2.fromOffset(20, 20)
  expandBtn.Position = UDim2.new(0, 40, 0.5, 0)
  expandBtn.AnchorPoint = Vector2.new(0, 0.5)
  expandBtn.BackgroundTransparency = 1
  expandBtn.Image = "rbxassetid://137817849385475"
  expandBtn.ImageColor3 = THEME.textDim

  local closeBtn = Instance.new("ImageButton", headerControls)
  closeBtn.Size = UDim2.fromOffset(20, 20)
  closeBtn.Position = UDim2.new(0, 70, 0.5, 0)
  closeBtn.AnchorPoint = Vector2.new(0, 0.5)
  closeBtn.BackgroundTransparency = 1
  closeBtn.Image = "rbxassetid://71175513861523"
  closeBtn.ImageColor3 = THEME.textDim

  for _, btn in ipairs({ minimizeBtn, expandBtn, closeBtn }) do
      btn.MouseEnter:Connect(function()
          TweenService:Create(btn, TweenInfo.new(0.2), { ImageColor3 = Color3.new(1, 1, 1) }):Play()
      end)
      btn.MouseLeave:Connect(function()
          TweenService:Create(btn, TweenInfo.new(0.2), { ImageColor3 = THEME.textDim }):Play()
      end)
  end

  -- WINDOW_IMPL_START
  -- WINDOW_IMPL_END
end
end
