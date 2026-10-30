-- [INIT]
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- [DELTA API]
local genv = getgenv and getgenv() or _G

-- === ПАЛИТРА (2 акцентных цвета) ===
local C = {
    bg        = Color3.fromRGB(16, 14, 26),
    bgDark    = Color3.fromRGB(10, 9, 17),
    bgDarker  = Color3.fromRGB(6, 5, 10),
    panel     = Color3.fromRGB(24, 21, 38),
    panelHi   = Color3.fromRGB(34, 30, 54),
    border    = Color3.fromRGB(50, 44, 78),
    accent1   = Color3.fromRGB(0, 255, 200),   -- cyan
    accent2   = Color3.fromRGB(170, 100, 255), -- purple
    accentDim = Color3.fromRGB(0, 180, 140),
    text      = Color3.fromRGB(240, 235, 250),
    textDim   = Color3.fromRGB(130, 125, 155),
    info      = Color3.fromRGB(255, 210, 120),
}

-- === UTILS ===
local function corner(parent, r)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end
local function stroke(parent, color, thick, transp)
    local s = Instance.new("UIStroke", parent)
    s.Color = color or C.border
    s.Thickness = thick or 1
    s.Transparency = transp or 0.3
    return s
end
local function gradient(parent, c1, c2, rot)
    local g = Instance.new("UIGradient", parent)
    g.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, c1),
        ColorSequenceKeypoint.new(0.5, c2),
        ColorSequenceKeypoint.new(1, c1)
    }
    g.Rotation = rot or 90
    return g
end
local function padding(parent, all)
    local p = Instance.new("UIPadding", parent)
    p.PaddingTop = UDim.new(0, all or 4)
    p.PaddingBottom = UDim.new(0, all or 4)
    p.PaddingLeft = UDim.new(0, all or 4)
    p.PaddingRight = UDim.new(0, all or 4)
    return p
end

-- === GUI ===
local gui = Instance.new("ScreenGui")
gui.Name = "BABFT_" .. tostring(math.random(1e6))
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent = LP:WaitForChild("PlayerGui")

-- === TOGGLE BUTTON (анимированная) ===
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 14, 0.5, -25)
toggleBtn.BackgroundColor3 = C.panel
toggleBtn.Text = "≡"
toggleBtn.TextColor3 = C.text
toggleBtn.TextSize = 24
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = gui
corner(toggleBtn, 13)

local tbGrad = gradient(toggleBtn, C.accent1, C.accent2, 0)
local tbStroke = stroke(toggleBtn, C.accent1, 2, 0.3)

-- внутренняя подсветка
local tbGlow = Instance.new("Frame")
tbGlow.Size = UDim2.new(1, -6, 1, -6)
tbGlow.Position = UDim2.new(0, 3, 0, 3)
tbGlow.BackgroundColor3 = C.bgDarker
tbGlow.BackgroundTransparency = 0.85
tbGlow.BorderSizePixel = 0
tbGlow.ZIndex = 0
tbGlow.Parent = toggleBtn
corner(tbGlow, 10)

-- текст поверх (ZIndex)
toggleBtn.ZIndex = 2
toggleBtn.TextTransparency = 0

-- анимация вращения градиента на кнопке (всегда)
task.spawn(function()
    while gui.Parent do
        task.wait(0.05)
        if tbGrad then
            tbGrad.Rotation = (tbGrad.Rotation + 4) % 360
        end
    end
end)

-- пульсация кнопки когда меню закрыто
task.spawn(function()
    local t = 0
    while gui.Parent do
        task.wait(0.05)
        if not isOpen and tbStroke then
            t = t + 0.05
            local p = (math.sin(t * 2.5) + 1) / 2
            tbStroke.Transparency = 0.6 - p * 0.45
            tbStroke.Thickness = 1.5 + p * 1.5
            tbStroke.Color = C.accent1:Lerp(C.accent2, p)
        end
    end
end)

toggleBtn.MouseEnter:Connect(function()
    if UserInputService.TouchEnabled then return end
    TweenService:Create(toggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
        Size = UDim2.new(0, 54, 0, 54),
        Position = UDim2.new(0, 12, 0.5, -27)
    }):Play()
end)
toggleBtn.MouseLeave:Connect(function()
    if UserInputService.TouchEnabled then return end
    TweenService:Create(toggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0, 14, 0.5, -25)
    }):Play()
end)

-- === MAIN PANEL ===
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 260, 0, 340)
main.Position = UDim2.new(0, 14, 0.5, -170)
main.BackgroundColor3 = C.bg
main.BorderSizePixel = 0
main.Visible = false
main.ClipsDescendants = true
main.Active = true
main.Parent = gui
corner(main, 16)

local mainGrad = Instance.new("UIGradient", main)
mainGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, C.bgDark),
    ColorSequenceKeypoint.new(0.5, C.panel),
    ColorSequenceKeypoint.new(1, C.bgDark)
}
mainGrad.Rotation = 90

local mainStroke = stroke(main, C.border, 1.2, 0.2)

-- живой фон (медленно вращающийся градиент)
task.spawn(function()
    while gui.Parent do
        task.wait(0.1)
        if mainGrad then
            mainGrad.Rotation = (mainGrad.Rotation + 0.6) % 360
        end
    end
end)

-- декоративное свечение в углу
local glowFrame = Instance.new("Frame")
glowFrame.Size = UDim2.new(0, 120, 0, 120)
glowFrame.Position = UDim2.new(1, -70, 0, -50)
glowFrame.BackgroundColor3 = C.accent2
glowFrame.BackgroundTransparency = 0.88
glowFrame.BorderSizePixel = 0
glowFrame.ZIndex = 0
glowFrame.Parent = main
local gc = Instance.new("UICorner", glowFrame)
gc.CornerRadius = UDim.new(1, 0)

-- === HEADER ===
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 44)
header.BackgroundColor3 = C.panel
header.BackgroundTransparency = 0.15
header.BorderSizePixel = 0
header.Parent = main
corner(header, 16)

local headerGrad = Instance.new("UIGradient", header)
headerGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, C.panelHi),
    ColorSequenceKeypoint.new(1, C.panel)
}
headerGrad.Rotation = 0

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 44, 0, 0)
title.BackgroundTransparency = 1
title.Text = "BABFT"
title.TextColor3 = C.text
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(0, 60, 0, 12)
subtitle.Position = UDim2.new(0, 44, 1, -18)
subtitle.BackgroundTransparency = 1
subtitle.Text = "FARM HUB"
subtitle.TextColor3 = C.accent1
subtitle.TextSize = 8
subtitle.Font = Enum.Font.GothamBold
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

-- логотип точка
local logo = Instance.new("Frame")
logo.Size = UDim2.new(0, 24, 0, 24)
logo.Position = UDim2.new(0, 14, 0.5, -12)
logo.BackgroundColor3 = C.accent1
logo.BorderSizePixel = 0
logo.Parent = header
corner(logo, 8)
local logoGrad = gradient(logo, C.accent1, C.accent2, 45)
task.spawn(function()
    while gui.Parent do
        task.wait(0.05)
        if logoGrad then logoGrad.Rotation = (logoGrad.Rotation + 3) % 360 end
    end
end)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0.5, -15)
closeBtn.BackgroundColor3 = C.panelHi
closeBtn.Text = "×"
closeBtn.TextColor3 = C.text
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.AutoButtonColor = false
closeBtn.Parent = header
corner(closeBtn, 8)
local closeStroke = stroke(closeBtn, C.border, 1, 0.5)

closeBtn.MouseEnter:Connect(function()
    if UserInputService.TouchEnabled then return end
    TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.accent2}):Play()
end)
closeBtn.MouseLeave:Connect(function()
    if UserInputService.TouchEnabled then return end
    TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.panelHi}):Play()
end)

-- === TABS ===
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -20, 0, 32)
tabBar.Position = UDim2.new(0, 10, 0, 50)
tabBar.BackgroundColor3 = C.bgDarker
tabBar.BorderSizePixel = 0
tabBar.Parent = main
corner(tabBar, 9)
stroke(tabBar, C.border, 1, 0.5)

local tabsContainer = Instance.new("Frame")
tabsContainer.Size = UDim2.new(1, -6, 1, -6)
tabsContainer.Position = UDim2.new(0, 3, 0, 3)
tabsContainer.BackgroundTransparency = 1
tabsContainer.Parent = tabBar

local tabLayout = Instance.new("UIListLayout", tabsContainer)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 3)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- === PAGES ===
local pageHolder = Instance.new("Frame")
pageHolder.Size = UDim2.new(1, -20, 1, -140)
pageHolder.Position = UDim2.new(0, 10, 0, 88)
pageHolder.BackgroundTransparency = 1
pageHolder.ClipsDescendants = true
pageHolder.Parent = main

local function createPage(name)
    local p = Instance.new("ScrollingFrame")
    p.Name = name
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 3
    p.ScrollBarImageColor3 = C.accent1
    p.CanvasSize = UDim2.new(0, 0, 0, 0)
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.Visible = false
    p.Parent = pageHolder
    local l = Instance.new("UIListLayout", p)
    l.Padding = UDim.new(0, 6)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    return p
end

local farmPage = createPage("Farm")
local waterPage = createPage("Water")

-- === TAB BUTTONS ===
local pageButtons = {}
local function createTab(text, page, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, -3, 1, 0)
    btn.BackgroundColor3 = C.panelHi
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.TextColor3 = C.textDim
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.LayoutOrder = order
    btn.Parent = tabsContainer
    corner(btn, 7)

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(1, 0, 1, 0)
    indicator.BackgroundColor3 = C.accent1
    indicator.BackgroundTransparency = 1
    indicator.BorderSizePixel = 0
    indicator.ZIndex = 0
    indicator.Parent = btn
    corner(indicator, 7)
    local ig = Instance.new("UIGradient", indicator)
    ig.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, C.accent1),
        ColorSequenceKeypoint.new(1, C.accent2)
    }
    ig.Rotation = 0

    pageButtons[#pageButtons + 1] = {btn = btn, page = page, indicator = indicator, grad = ig}

    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(pageButtons) do
            t.page.Visible = false
            TweenService:Create(t.btn, TweenInfo.new(0.2), {TextColor3 = C.textDim}):Play()
            TweenService:Create(t.indicator, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        end
        page.Visible = true
        TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = C.bgDarker}):Play()
        TweenService:Create(indicator, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
    return btn
end

createTab("FARM", farmPage, 1)
createTab("WATER", waterPage, 2)

-- === COMPONENTS ===
local function createToggle(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = C.panel
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    corner(btn, 9)
    local s = stroke(btn, C.border, 1, 0.5)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = C.text
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn

    local switchBg = Instance.new("Frame")
    switchBg.Size = UDim2.new(0, 34, 0, 18)
    switchBg.Position = UDim2.new(1, -46, 0.5, -9)
    switchBg.BackgroundColor3 = C.bgDarker
    switchBg.BorderSizePixel = 0
    switchBg.Parent = btn
    corner(switchBg, 9)
    stroke(switchBg, C.border, 1, 0.3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = C.accent1
    fill.BorderSizePixel = 0
    fill.Parent = switchBg
    corner(fill, 9)
    local fillGrad = Instance.new("UIGradient", fill)
    fillGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, C.accent1),
        ColorSequenceKeypoint.new(1, C.accent2)
    }
    fillGrad.Rotation = 0

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = C.textDim
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    knob.Parent = switchBg
    corner(knob, 7)

    local isOn = false
    local function setState(on)
        isOn = on
        local tween = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        TweenService:Create(knob, tween, {
            Position = on and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
            BackgroundColor3 = on and Color3.fromRGB(255, 255, 255) or C.textDim,
        }):Play()
        TweenService:Create(fill, tween, {
            Size = on and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 1, 0)
        }):Play()
        TweenService:Create(s, TweenInfo.new(0.25), {
            Color = on and C.accent1 or C.border,
            Transparency = on and 0.15 or 0.5
        }):Play()
        TweenService:Create(switchBg, TweenInfo.new(0.25), {
            BackgroundColor3 = on and C.panelHi or C.bgDarker
        }):Play()
    end

    btn.MouseButton1Click:Connect(function()
        setState(not isOn)
        pcall(callback, isOn)
    end)
    return btn
end

local function createSlider(parent, labelText, minVal, maxVal, defaultVal, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 54)
    container.BackgroundColor3 = C.panel
    container.BorderSizePixel = 0
    container.Active = true
    container.Parent = parent
    corner(container, 9)
    local cs = stroke(container, C.border, 1, 0.5)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 0, 20)
    label.Position = UDim2.new(0, 12, 0, 6)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = C.text
    label.TextSize = 12
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0, 50, 0, 20)
    valLabel.Position = UDim2.new(1, -62, 0, 6)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(defaultVal)
    valLabel.TextColor3 = C.accent1
    valLabel.TextSize = 13
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent = container

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -24, 0, 6)
    sliderBg.Position = UDim2.new(0, 12, 1, -18)
    sliderBg.BackgroundColor3 = C.bgDarker
    sliderBg.BorderSizePixel = 0
    sliderBg.Active = true
    sliderBg.Parent = container
    corner(sliderBg, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = C.accent1
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    corner(fill, 3)
    local fg = Instance.new("UIGradient", fill)
    fg.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, C.accent1),
        ColorSequenceKeypoint.new(1, C.accent2)
    }
    fg.Rotation = 0

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(fill.Size.X.Scale, -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    knob.Active = false
    knob.Parent = sliderBg
    corner(knob, 7)
    local knStroke = stroke(knob, C.accent1, 2, 0)

    -- пульсация ползунка
    task.spawn(function()
        local t = 0
        while knob.Parent do
            task.wait(0.05)
            t = t + 0.05
            local p = (math.sin(t * 3) + 1) / 2
            if knStroke then
                knStroke.Color = C.accent1:Lerp(C.accent2, p)
            end
        end
    end)

    local hitbox = Instance.new("Frame")
    hitbox.Size = UDim2.new(1, 0, 0, 32)
    hitbox.Position = UDim2.new(0, 0, 0.5, -16)
    hitbox.BackgroundTransparency = 1
    hitbox.Active = true
    hitbox.Parent = sliderBg
    hitbox.ZIndex = 3

    local function setValue(ratio)
        ratio = math.clamp(ratio, 0, 1)
        local val = math.floor(minVal + (maxVal - minVal) * ratio + 0.5)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        knob.Position = UDim2.new(ratio, -7, 0.5, -7)
        valLabel.Text = tostring(val)
        pcall(callback, val)
    end

    hitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local rel = (input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
            setValue(rel)
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.Change then
                    local rel2 = (input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
                    setValue(rel2)
                elseif input.UserInputState == Enum.UserInputState.End or input.UserInputState == Enum.UserInputState.Cancel then
                    if conn then conn:Disconnect() end
                end
            end)
        end
    end)
    return container
end

-- === ANIMATIONS ===
local openInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local closeInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local isOpen = false
local function setOpen(state)
    if isOpen == state then return end
    isOpen = state
    if state then
        main.Visible = true
        main.Size = UDim2.new(0, 0, 0, 0)
        main.Position = UDim2.new(0, 14, 0.5, -170)
        TweenService:Create(main, openInfo, {Size = UDim2.new(0, 260, 0, 340)}):Play()
    else
        local tw = TweenService:Create(main, closeInfo, {Size = UDim2.new(0, 0, 0, 0)})
        tw:Play()
        tw.Completed:Connect(function() if not isOpen then main.Visible = false end end)
    end
end

toggleBtn.MouseButton1Click:Connect(function()
    setOpen(not isOpen)
end)
closeBtn.MouseButton1Click:Connect(function() setOpen(false) end)

-- === DRAG ===
local dragging, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = main.Position
        local conn
        conn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End or input.UserInputState == Enum.UserInputState.Cancel then
                dragging = false
                if conn then conn:Disconnect() end
            end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- === FOOTER ===
local footer = Instance.new("Frame")
footer.Size = UDim2.new(1, -20, 0, 38)
footer.Position = UDim2.new(0, 10, 1, -48)
footer.BackgroundColor3 = C.panel
footer.BorderSizePixel = 0
footer.Parent = main
corner(footer, 10)
stroke(footer, C.border, 1, 0.4)

local footerGrad = Instance.new("UIGradient", footer)
footerGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, C.panel),
    ColorSequenceKeypoint.new(1, C.panelHi)
}
footerGrad.Rotation = 0

local counterLabel = Instance.new("TextLabel")
counterLabel.Size = UDim2.new(1, 0, 1, 0)
counterLabel.BackgroundTransparency = 1
counterLabel.TextColor3 = C.text
counterLabel.TextSize = 10
counterLabel.Font = Enum.Font.GothamBold
counterLabel.Text = "Циклов: 0   ·   Золото: 0   ·   В час: 0"
counterLabel.Parent = footer

-- === UTILS ===
local function getRoot()
    local char = LP.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end
local function getHumanoid()
    local char = LP.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end
local function getChestCFrame()
    local ok, cf = pcall(function()
        local stages = workspace:FindFirstChild("BoatStages")
        local normal = stages and stages:FindFirstChild("NormalStages")
        local theEnd = normal and normal:FindFirstChild("TheEnd")
        local chest = theEnd and theEnd:FindFirstChild("GoldenChest")
        local trigger = chest and (chest:FindFirstChild("Trigger") or chest:FindFirstChild("LightPart") or chest)
        if trigger then return trigger.CFrame end
        return nil
    end)
    if ok then return cf end
    return nil
end
local function isAtBase()
    local hrp = getRoot()
    if not hrp then return false end
    return hrp.Position.Z < 200
end

-- === ФАРМ ===
local farmThread = nil
local currentMode = nil
local cycleCount = 0
local goldEarned = 0
local startTime = tick()
local GOLD_PER_STAGE = 8
local GOLD_PER_TREASURE = 25
local SLOW_STAGES = 8
local FAST_STAGES = 2

local function getGoldPerCycle(mode)
    if mode == "slow" then return SLOW_STAGES * GOLD_PER_STAGE + GOLD_PER_TREASURE end
    if mode == "fast" then return FAST_STAGES * GOLD_PER_STAGE + GOLD_PER_TREASURE end
    return 0
end
local function setInvincible(on)
    local hum = getHumanoid()
    if not hum then return end
    if on then hum.MaxHealth = math.huge; hum.Health = math.huge
    else hum.MaxHealth = 100; hum.Health = 100 end
end
local function setPlatformStand(on)
    local hum = getHumanoid()
    if not hum then return end
    hum.PlatformStand = on
end

local startZ = -50
local chestZ = 9750
local BASE_WAIT = 5
local SLOW_STEP = 120
local SLOW_TIME = 0.26
local SLOW_HANG = 0
local FAST_STEP = 500
local FAST_TIME = 0.06
local FAST_HANG = 2.0

local function updateCounter()
    local elapsed = tick() - startTime
    local perHour = 0
    if elapsed > 10 and goldEarned > 0 then
        perHour = math.floor(goldEarned / elapsed * 3600)
    end
    counterLabel.Text = string.format("Циклов: %d   ·   Золото: %d   ·   В час: %d", cycleCount, goldEarned, perHour)
end
local function resetCounter()
    cycleCount = 0
    goldEarned = 0
    startTime = tick()
    updateCounter()
end

local function runFarm(getParams)
    farmThread = task.spawn(function()
        setInvincible(true)
        setPlatformStand(true)
        while currentMode ~= nil do
            local hrp = getRoot()
            if not hrp then task.wait(0.5); continue end
            local params = getParams()
            if not params then break end

            hrp.CFrame = CFrame.new(0, 15, startZ)
            hrp.Velocity = Vector3.zero
            task.wait(0.5)

            local twInfo = TweenInfo.new(params.time, Enum.EasingStyle.Linear)
            local hangZ = 5000

            if params.hang > 0 then
                for z = startZ, hangZ, params.step do
                    if currentMode == nil then break end
                    local h = getRoot(); if not h then break end
                    local tw = TweenService:Create(h, twInfo, {CFrame = CFrame.new(0, 30, z)})
                    tw:Play(); tw.Completed:Wait()
                    h.Velocity = Vector3.zero; h.AssemblyLinearVelocity = Vector3.zero
                end
                if currentMode == nil then break end
                local hw = 0
                while hw < params.hang and currentMode ~= nil do
                    local h = getRoot(); if not h then break end
                    h.CFrame = CFrame.new(0, 30, hangZ); h.Velocity = Vector3.zero
                    task.wait(0.1); hw = hw + 0.1
                end
                if currentMode == nil then break end
                for z = hangZ, chestZ - 200, params.step do
                    if currentMode == nil then break end
                    local h2 = getRoot(); if not h2 then break end
                    local tw = TweenService:Create(h2, twInfo, {CFrame = CFrame.new(0, 30, z)})
                    tw:Play(); tw.Completed:Wait()
                    h2.Velocity = Vector3.zero
                end
            else
                for z = startZ, chestZ - 200, params.step do
                    if currentMode == nil then break end
                    local h = getRoot(); if not h then break end
                    local tw = TweenService:Create(h, twInfo, {CFrame = CFrame.new(0, 30, z)})
                    tw:Play(); tw.Completed:Wait()
                    h.Velocity = Vector3.zero
                end
            end

            if currentMode == nil then break end

            local chestCF = getChestCFrame()
            local h3 = getRoot()
            if h3 then
                local targetCF = chestCF and (chestCF + Vector3.new(0, 6, 0)) or CFrame.new(0, 12, chestZ)
                local tween = TweenService:Create(h3, TweenInfo.new(1.2, Enum.EasingStyle.Quad), {CFrame = targetCF})
                tween:Play(); tween.Completed:Wait()
                h3.Velocity = Vector3.zero
            end

            if currentMode ~= nil then
                local waited = 0
                while waited < 15 and currentMode ~= nil do
                    local h4 = getRoot(); if not h4 then break end
                    local chestCF2 = getChestCFrame()
                    if chestCF2 then h4.CFrame = chestCF2 + Vector3.new(0, 6, 0) end
                    h4.Velocity = Vector3.zero
                    if isAtBase() then break end
                    task.wait(0.2); waited = waited + 0.2
                end
            end

            if currentMode ~= nil then
                cycleCount = cycleCount + 1
                goldEarned = goldEarned + getGoldPerCycle(currentMode)
                updateCounter()
            end
            if currentMode ~= nil then task.wait(BASE_WAIT) end
        end
        setInvincible(false)
        setPlatformStand(false)
    end)
end

local function stopFarm()
    currentMode = nil
    if farmThread then pcall(function() task.cancel(farmThread) end); farmThread = nil end
    setInvincible(false)
    setPlatformStand(false)
end

-- === WATER WALK ===
local waterWalkActive = false
local waterPart = nil
local waterConn = nil
local originalWalkSpeed = 16
local currentSpeed = 50
local WATER_Y = -10
local PART_OFFSET = -0.4
local PART_SIZE = Vector3.new(20, 0.2, 20)

local function applySpeed()
    if not waterWalkActive then return end
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = currentSpeed end
end

local function startWaterWalk()
    if waterWalkActive then return end
    waterWalkActive = true
    local hum = getHumanoid()
    if hum then originalWalkSpeed = hum.WalkSpeed; hum.WalkSpeed = currentSpeed end

    waterPart = Instance.new("Part")
    waterPart.Name = "WaterWalkPart"
    waterPart.Size = PART_SIZE
    waterPart.Anchored = true
    waterPart.CanCollide = true
    waterPart.Transparency = 1
    waterPart.CanTouch = false
    waterPart.CanQuery = false
    waterPart.Material = Enum.Material.SmoothPlastic
    waterPart.Parent = workspace

    local targetY = WATER_Y + PART_OFFSET
    waterConn = RunService.Stepped:Connect(function()
        if not waterWalkActive then return end
        local char = LP.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp or not waterPart or not waterPart.Parent then return end
        waterPart.CFrame = CFrame.new(hrp.Position.X, targetY, hrp.Position.Z)
        if hrp.Position.Y < targetY - 2 then
            hrp.CFrame = CFrame.new(hrp.Position.X, targetY + 3, hrp.Position.Z)
            hrp.Velocity = Vector3.zero
        end
        local h = char:FindFirstChildOfClass("Humanoid")
        if h and h.WalkSpeed ~= currentSpeed then h.WalkSpeed = currentSpeed end
    end)
end

local function stopWaterWalk()
    waterWalkActive = false
    if waterConn then waterConn:Disconnect(); waterConn = nil end
    if waterPart then pcall(function() waterPart:Destroy() end); waterPart = nil end
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = originalWalkSpeed end
end

-- === FARM PAGE CONTENT ===
createToggle(farmPage, "Медленный (все этапы)", function(isOn)
    if isOn then
        stopFarm(); resetCounter(); currentMode = "slow"
        runFarm(function() return {step = SLOW_STEP, time = SLOW_TIME, hang = SLOW_HANG} end)
    else
        if currentMode == "slow" then stopFarm() end
    end
end)

createToggle(farmPage, "Быстрый (только сундук)", function(isOn)
    if isOn then
        stopFarm(); resetCounter(); currentMode = "fast"
        runFarm(function() return {step = FAST_STEP, time = FAST_TIME, hang = FAST_HANG} end)
    else
        if currentMode == "fast" then stopFarm() end
    end
end)

-- === WATER PAGE CONTENT ===
createToggle(waterPage, "Walk on Water", function(isOn)
    if isOn then startWaterWalk() else stopWaterWalk() end
end)

createSlider(waterPage, "Скорость на парте", 16, 100, 50, function(val)
    currentSpeed = val
    if waterWalkActive then applySpeed() end
end)

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, 0, 0, 44)
infoLabel.BackgroundColor3 = C.panel
infoLabel.BackgroundTransparency = 0.2
infoLabel.TextColor3 = C.info
infoLabel.TextSize = 10
infoLabel.Font = Enum.Font.GothamBold
infoLabel.Text = "Моя Y: --   ·   Вода: -10   ·   Парт: --"
infoLabel.Parent = waterPage
corner(infoLabel, 9)
stroke(infoLabel, C.border, 1, 0.5)

task.spawn(function()
    while true do
        task.wait(0.3)
        pcall(function()
            local hrp = getRoot()
            local py = hrp and math.floor(hrp.Position.Y * 10) / 10 or "--"
            local pty = (waterPart and waterPart.Parent) and math.floor(waterPart.Position.Y * 10) / 10 or "--"
            infoLabel.Text = string.format("Моя Y: %s   ·   Вода: %s   ·   Парт: %s", tostring(py), tostring(WATER_Y), tostring(pty))
        end)
    end
end)

-- открываем вкладку Farm по умолчанию
farmPage.Visible = true
pageButtons[1].btn.TextColor3 = C.bgDarker
pageButtons[1].indicator.BackgroundTransparency = 0

pcall(function() if getgenv then genv.BABFT = gui end end)
