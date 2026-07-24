-- =====================================================
-- MEHFIL BETA – Final Complete C2 UI (Stats Visible)
-- =====================================================

local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- ========== Folder Setup ==========
local configFolder = "Mehfil"
local configSubFolder = configFolder .. "/configs"
if not isfolder(configFolder) then makefolder(configFolder) end
if not isfolder(configSubFolder) then makefolder(configSubFolder) end
local CONFIG_FILE = configSubFolder .. "/CurrentSettings.json"

-- ========== Themes ==========
local Themes = {
    Default = {
        Background = Color3.fromRGB(14, 14, 18), WindowBG = Color3.fromRGB(20, 20, 26),
        TitleBar = Color3.fromRGB(16, 16, 22), Border = Color3.fromRGB(35, 35, 42),
        Accent = Color3.fromRGB(120, 150, 255), AccentHover = Color3.fromRGB(150, 175, 255),
        Text = Color3.fromRGB(220, 225, 235), SubText = Color3.fromRGB(140, 145, 160),
        Element = Color3.fromRGB(28, 28, 34), ElementHover = Color3.fromRGB(38, 38, 46),
        PillActive = Color3.fromRGB(100, 130, 255), PillInactive = Color3.fromRGB(40, 40, 50),
        SwitchOn = Color3.fromRGB(120, 150, 255), SwitchOff = Color3.fromRGB(45, 45, 55),
        SwitchKnob = Color3.new(1, 1, 1),
    },
}
local savedTheme = "Default"
pcall(function()
    if readfile and isfile(CONFIG_FILE) then
        local data = readfile(CONFIG_FILE)
        if data then
            local ok, parsed = pcall(function() return HttpService:JSONDecode(data) end)
            if ok and parsed and parsed.theme then savedTheme = parsed.theme end
        end
    end
end)
local C = Themes[savedTheme] or Themes.Default

-- Utility
local function tween(obj, t, props, style, dir)
    style = style or Enum.EasingStyle.Quart; dir = dir or Enum.EasingDirection.Out
    local tw = TweenService:Create(obj, TweenInfo.new(t, style, dir), props); tw:Play(); return tw
end
local function create(class, props)
    local obj = Instance.new(class); for k, v in pairs(props) do obj[k] = v end; return obj
end

-- Control registry
local allControls = {}
local function RegisterControl(name, controlObj, pageName)
    table.insert(allControls, { name = name, type = controlObj.type, get = controlObj.GetValue or controlObj.GetOption, set = controlObj.SetValue or controlObj.SetIndex, page = pageName })
end

-- UI Components
local CoreGui = game:GetService("CoreGui")
for _, name in ipairs({"C2UI", "C2DropdownLayer", "C2StatsLayer"}) do
    local old = CoreGui:FindFirstChild(name); if old then old:Destroy(); task.wait(0.1) end
end

-- Dropdown layer (popup parent)
local dropdownLayer = Instance.new("ScreenGui")
dropdownLayer.Name = "C2DropdownLayer"; dropdownLayer.ResetOnSpawn = false
dropdownLayer.IgnoreGuiInset = true; dropdownLayer.DisplayOrder = 5
dropdownLayer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; dropdownLayer.Parent = CoreGui

-- Dedicated stats layer (above everything)
local statsLayer = Instance.new("ScreenGui")
statsLayer.Name = "C2StatsLayer"; statsLayer.ResetOnSpawn = false
statsLayer.IgnoreGuiInset = true; statsLayer.DisplayOrder = 6
statsLayer.Parent = CoreGui

-- ==================== UI ELEMENTS ====================
-- Toggle with keybind
local function AddToggleWithKeybind(parent, text, default, callback)
    local state = default or false
    local row = create("Frame", { Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Parent = parent })
    local label = create("TextLabel", { Size = UDim2.new(0.5, -4, 1, 0), BackgroundTransparency = 1, Text = text, TextColor3 = C.Text, TextSize = 9, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })

    local track = create("TextButton", { Size = UDim2.new(0, 22, 0, 10), Position = UDim2.new(1, -58, 0.5, -5), BackgroundColor3 = state and C.SwitchOn or C.SwitchOff, BorderSizePixel = 0, Text = "", AutoButtonColor = false, Parent = row })
    create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
    local knob = create("Frame", { Size = UDim2.new(0, 8, 0, 8), Position = UDim2.new(0, state and 12 or 2, 0.5, -4), BackgroundColor3 = C.SwitchKnob, BorderSizePixel = 0, Parent = track })
    create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
    local ctrl = { type = "toggle" }
    function ctrl:SetValue(val)
        state = val
        TweenService:Create(track, TweenInfo.new(0.12, Enum.EasingStyle.Quad), { BackgroundColor3 = val and C.SwitchOn or C.SwitchOff }):Play()
        TweenService:Create(knob, TweenInfo.new(0.12, Enum.EasingStyle.Quad), { Position = UDim2.new(0, val and 12 or 2, 0.5, -4) }):Play()
        pcall(callback, val)
    end
    function ctrl:GetValue() return state end
    track.MouseButton1Click:Connect(function() ctrl:SetValue(not state) end)

    local toggleKey = nil
    local keyBtn = create("TextButton", {
        Size = UDim2.new(0, 34, 0, 14), Position = UDim2.new(1, -34, 0, 0),
        BackgroundColor3 = C.Element, BorderSizePixel = 1, BorderColor3 = C.Border,
        Text = "...", TextColor3 = C.Text, TextSize = 9, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = row
    })
    create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = keyBtn })
    local binding = false
    keyBtn.MouseButton1Click:Connect(function()
        binding = true; keyBtn.Text = "..."
        local conn
        conn = UIS.InputBegan:Connect(function(input, gp)
            if gp then return end
            if binding then
                local key = input.KeyCode
                if key == Enum.KeyCode.Backspace then
                    toggleKey = nil; keyBtn.Text = "..."
                elseif key ~= Enum.KeyCode.Unknown then
                    toggleKey = key.Name; keyBtn.Text = key.Name
                end
                binding = false; conn:Disconnect()
            end
        end)
    end)

    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if toggleKey and input.KeyCode.Name == toggleKey then
            ctrl:SetValue(not state)
        end
    end)

    RegisterControl(text, ctrl, parent.Name)
    return ctrl
end

-- Standard toggle
local function AddToggle(parent, text, default, callback)
    local state = default or false
    local row = create("Frame", { Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Parent = parent })
    local label = create("TextLabel", { Size = UDim2.new(0.5, -4, 1, 0), BackgroundTransparency = 1, Text = text, TextColor3 = C.Text, TextSize = 9, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
    local track = create("TextButton", { Size = UDim2.new(0, 22, 0, 10), Position = UDim2.new(1, -22, 0.5, -5), BackgroundColor3 = state and C.SwitchOn or C.SwitchOff, BorderSizePixel = 0, Text = "", AutoButtonColor = false, Parent = row })
    create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
    local knob = create("Frame", { Size = UDim2.new(0, 8, 0, 8), Position = UDim2.new(0, state and 12 or 2, 0.5, -4), BackgroundColor3 = C.SwitchKnob, BorderSizePixel = 0, Parent = track })
    create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
    local ctrl = { type = "toggle" }
    function ctrl:SetValue(val)
        state = val
        TweenService:Create(track, TweenInfo.new(0.12, Enum.EasingStyle.Quad), { BackgroundColor3 = val and C.SwitchOn or C.SwitchOff }):Play()
        TweenService:Create(knob, TweenInfo.new(0.12, Enum.EasingStyle.Quad), { Position = UDim2.new(0, val and 12 or 2, 0.5, -4) }):Play()
        pcall(callback, val)
    end
    function ctrl:GetValue() return state end
    track.MouseButton1Click:Connect(function() ctrl:SetValue(not state) end)
    RegisterControl(text, ctrl, parent.Name)
    return ctrl
end

-- Slider
local function AddSlider(parent, text, minVal, maxVal, default, callback)
    callback = callback or function() end
    local value = default or minVal
    local row = create("Frame", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Parent = parent })
    local label = create("TextLabel", { Size = UDim2.new(0.4, -4, 0, 10), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, Text = text, TextColor3 = C.Text, TextSize = 9, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
    local valLabel = create("TextLabel", { Size = UDim2.new(0, 30, 0, 10), Position = UDim2.new(1, -30, 0, 0), BackgroundTransparency = 1, Text = string.format("%.1f", value), TextColor3 = C.Accent, TextSize = 9, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Right, Parent = row })
    local track = create("Frame", { Size = UDim2.new(1, -36, 0, 2), Position = UDim2.new(0, 0, 0, 12), BackgroundColor3 = C.Element, BorderSizePixel = 0, Parent = row })
    create("UICorner", { CornerRadius = UDim.new(0, 1), Parent = track })
    local ratio = (value - minVal) / (maxVal - minVal)
    local fill = create("Frame", { Size = UDim2.new(ratio, 0, 1, 0), BackgroundColor3 = C.Accent, BorderSizePixel = 0, Parent = track })
    create("UICorner", { CornerRadius = UDim.new(0, 1), Parent = fill })
    local knob = create("Frame", { Size = UDim2.new(0, 6, 0, 6), Position = UDim2.new(ratio, -3, 0.5, -3), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, Parent = track })
    create("UICorner", { CornerRadius = UDim.new(1,0), Parent = knob })
    create("UIStroke", { Color = C.Accent, Thickness = 1, Parent = knob })
    local dragging = false
    local function setFromX(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        value = minVal + (maxVal - minVal) * rel
        valLabel.Text = string.format("%.1f", value)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -3, 0.5, -3)
        pcall(callback, value)
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; setFromX(i.Position.X) end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then setFromX(i.Position.X) end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    local ctrl = { type = "slider", min = minVal, max = maxVal, GetValue = function() return value end, SetValue = function(v) setFromX(track.AbsolutePosition.X + (v-minVal)/(maxVal-minVal)*track.AbsoluteSize.X) end }
    RegisterControl(text, ctrl, parent.Name)
    return ctrl
end

-- Animated Dropdown
local function AddDropdown(parent, text, options, initialIndex, callback)
    callback = callback or function() end
    local currentIndex = initialIndex or 1
    local row = create("Frame", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Parent = parent })
    local label = create("TextLabel", { Size = UDim2.new(0.45, -4, 1, 0), BackgroundTransparency = 1, Text = text, TextColor3 = C.Text, TextSize = 9, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
    local button = create("TextButton", { Size = UDim2.new(0.5, -4, 0, 14), Position = UDim2.new(0.5, 4, 0.5, -7), BackgroundColor3 = C.Element, BorderSizePixel = 1, BorderColor3 = C.Border, Text = options[currentIndex] or "", TextColor3 = C.Text, TextSize = 8, Font = Enum.Font.Gotham, AutoButtonColor = false, Parent = row })
    create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = button })
    create("TextLabel", { Size = UDim2.new(0, 12, 1, 0), Position = UDim2.new(1, -12, 0, 0), BackgroundTransparency = 1, Text = "▼", TextColor3 = C.SubText, TextSize = 7, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Center, Parent = button })
    local popup, closeBtn, isOpen, previousSelection = nil, nil, false, options[currentIndex] or ""
    local function closePopup(instant)
        if not popup then return end
        if not instant then
            tween(popup, 0.15, { Size = UDim2.new(0, button.AbsoluteSize.X, 0, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            tween(closeBtn, 0.15, { BackgroundTransparency = 1 })
            task.delay(0.15, function()
                if popup then popup:Destroy(); popup = nil end
                if closeBtn then closeBtn:Destroy(); closeBtn = nil end
            end)
        else
            if popup then popup:Destroy(); popup = nil end
            if closeBtn then closeBtn:Destroy(); closeBtn = nil end
        end
        isOpen = false
    end
    local function openPopup()
        closePopup(true); isOpen = true
        closeBtn = create("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", BorderSizePixel = 0, ZIndex = 100, Parent = dropdownLayer })
        closeBtn.MouseButton1Click:Connect(function() closePopup() end)
        local maxVisible = 5
        local itemHeight = 14
        local totalItems = #options
        local visibleHeight = math.min(totalItems, maxVisible) * itemHeight
        local totalHeight = totalItems * itemHeight
        popup = create("Frame", {
            Size = UDim2.new(0, button.AbsoluteSize.X, 0, 0),
            Position = UDim2.new(0, button.AbsolutePosition.X, 0, button.AbsolutePosition.Y + button.AbsoluteSize.Y + 2),
            BackgroundColor3 = C.Element, BorderSizePixel = 1, BorderColor3 = C.Border, ZIndex = 200, ClipsDescendants = true, Parent = dropdownLayer,
        })
        create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = popup })
        if totalItems > maxVisible then
            local scroll = create("ScrollingFrame", {
                Size = UDim2.new(1, 0, 1, 0), CanvasSize = UDim2.new(0, 0, 0, totalHeight),
                ScrollBarThickness = 3, ScrollBarImageColor3 = C.Border, BackgroundTransparency = 1, BorderSizePixel = 0, Parent = popup
            })
            create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = scroll })
            for idx, option in ipairs(options) do
                local optBtn = create("TextButton", {
                    Size = UDim2.new(1, 0, 0, itemHeight), BackgroundColor3 = C.Element, BorderSizePixel = 0, Text = option,
                    TextColor3 = (idx == currentIndex) and C.Accent or C.Text, TextSize = 8, Font = Enum.Font.Gotham, AutoButtonColor = false, ZIndex = 200, Parent = scroll,
                })
                optBtn.MouseEnter:Connect(function() optBtn.BackgroundColor3 = C.ElementHover end)
                optBtn.MouseLeave:Connect(function() optBtn.BackgroundColor3 = C.Element end)
                optBtn.MouseButton1Click:Connect(function()
                    currentIndex = idx; button.Text = option; previousSelection = option; pcall(callback, option, idx); closePopup()
                end)
            end
        else
            create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = popup })
            for idx, option in ipairs(options) do
                local optBtn = create("TextButton", {
                    Size = UDim2.new(1, 0, 0, itemHeight), BackgroundColor3 = C.Element, BorderSizePixel = 0, Text = option,
                    TextColor3 = (idx == currentIndex) and C.Accent or C.Text, TextSize = 8, Font = Enum.Font.Gotham, AutoButtonColor = false, ZIndex = 200, Parent = popup,
                })
                optBtn.MouseEnter:Connect(function() optBtn.BackgroundColor3 = C.ElementHover end)
                optBtn.MouseLeave:Connect(function() optBtn.BackgroundColor3 = C.Element end)
                optBtn.MouseButton1Click:Connect(function()
                    currentIndex = idx; button.Text = option; previousSelection = option; pcall(callback, option, idx); closePopup()
                end)
            end
        end
        local screenHeight = Camera.ViewportSize.Y
        local btnBottom = button.AbsolutePosition.Y + button.AbsoluteSize.Y
        if btnBottom + visibleHeight + 10 > screenHeight then
            popup.Position = UDim2.new(0, button.AbsolutePosition.X, 0, button.AbsolutePosition.Y - visibleHeight - 2)
        else
            popup.Position = UDim2.new(0, button.AbsolutePosition.X, 0, btnBottom + 2)
        end
        tween(popup, 0.15, { Size = UDim2.new(0, button.AbsoluteSize.X, 0, visibleHeight) }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    end
    button.MouseButton1Click:Connect(function() if isOpen then closePopup() else openPopup() end end)
    local ctrl = {
        type = "dropdown", options = options,
        GetOption = function() return options[currentIndex] end,
        GetIndex = function() return currentIndex end,
        SetIndex = function(idx) idx = math.clamp(idx, 1, #options); currentIndex = idx; button.Text = options[idx]; previousSelection = options[idx]; closePopup() end,
        UpdateOptions = function(newOpts) options = newOpts; local found=false; for i,opt in ipairs(options) do if opt==previousSelection then currentIndex=i; found=true break end end; if not found then currentIndex=1 end; button.Text=options[currentIndex] or ""; closePopup() end,
        Button = button, IsOpen = function() return isOpen end,
    }
    RegisterControl(text, ctrl, parent.Name)
    return ctrl
end

-- ==================== MAIN UI WINDOW ====================
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "C2UI"; mainGui.ResetOnSpawn = false; mainGui.IgnoreGuiInset = true; mainGui.DisplayOrder = 4; mainGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 280); MainFrame.Position = UDim2.new(0.5, -150, 0.5, -140); MainFrame.BackgroundColor3 = C.WindowBG; MainFrame.BorderSizePixel = 0; MainFrame.ClipsDescendants = true; MainFrame.Visible = true; MainFrame.Parent = mainGui
create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = MainFrame })
create("UIStroke", { Color = C.Border, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = MainFrame })

-- Title bar
local titleBar = create("Frame", { Size = UDim2.new(1, 0, 0, 16), BackgroundColor3 = C.TitleBar, BorderSizePixel = 0, Parent = MainFrame })
create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = titleBar })
create("TextLabel", { Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 6, 0, 0), BackgroundTransparency = 1, Text = "Mehfil", TextColor3 = C.Text, TextSize = 10, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = titleBar })
local closeBtn = create("TextButton", { Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -14, 0, 2), BackgroundColor3 = C.Element, Text = "×", TextColor3 = C.Text, TextSize = 8, Font = Enum.Font.GothamBold, BorderSizePixel = 0, AutoButtonColor = false, Parent = titleBar })
create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = closeBtn })
local minBtn = create("TextButton", { Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -28, 0, 2), BackgroundColor3 = C.Element, Text = "−", TextColor3 = C.Text, TextSize = 8, Font = Enum.Font.GothamBold, BorderSizePixel = 0, AutoButtonColor = false, Parent = titleBar })
create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = minBtn })
local minimized = false; local origSize = UDim2.new(0, 300, 0, 280); local minSize = UDim2.new(0, 300, 0, 16)
minBtn.MouseButton1Click:Connect(function() minimized = not minimized; tween(MainFrame, 0.2, { Size = minimized and minSize or origSize }) end)
closeBtn.MouseButton1Click:Connect(function() mainGui:Destroy(); dropdownLayer:Destroy(); statsLayer:Destroy(); pcall(function() UIS.MouseIconEnabled = true end) end)

-- Dragging
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
titleBar.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Tab bar
local TopBar = create("Frame", { Size = UDim2.new(1, -10, 0, 18), Position = UDim2.new(0, 5, 0, 18), BackgroundColor3 = C.Background, BorderSizePixel = 0, Parent = MainFrame })
create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = TopBar })
create("UIStroke", { Color = C.Border, Thickness = 1, Parent = TopBar })
create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = TopBar })
create("UIPadding", { PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3), Parent = TopBar })

local tabNames = {"Main", "Settings"}
local tabPills = {}
for _, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Name = name.."Tab"; btn.Text = name; btn.Size = UDim2.new(0, 52, 1, 0); btn.TextColor3 = Color3.new(1,1,1); btn.BackgroundTransparency = 1; btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 9; btn.AutoButtonColor = false; btn.Parent = TopBar
    local pill = create("Frame", { Size = UDim2.new(1,0,1,0), BackgroundColor3 = (name=="Main") and C.PillActive or C.PillInactive, BorderSizePixel = 0, ZIndex = 0, Parent = btn })
    create("UICorner", { CornerRadius = UDim.new(0,4), Parent = pill })
    tabPills[name] = pill
end

local PagesContainer = Instance.new("Frame")
PagesContainer.Size = UDim2.new(1, -10, 1, -38); PagesContainer.Position = UDim2.new(0, 5, 0, 36); PagesContainer.BackgroundTransparency = 1; PagesContainer.BorderSizePixel = 0; PagesContainer.Parent = MainFrame

local function buildScrollingPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name; page.Size = UDim2.new(1,0,1,0); page.BackgroundColor3 = C.TitleBar; page.BorderSizePixel = 0
    page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = C.Border; page.CanvasSize = UDim2.new(0,0,0,0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y; page.ClipsDescendants = true; page.Visible = false; page.Parent = PagesContainer
    create("UICorner", { CornerRadius = UDim.new(0,6), Parent = page })
    create("UIStroke", { Color = C.Border, Thickness = 1, Parent = page })
    create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,2), Parent = page })
    create("UIPadding", { PaddingLeft = UDim.new(0,6), PaddingRight = UDim.new(0,6), PaddingTop = UDim.new(0,2), PaddingBottom = UDim.new(0,2), Parent = page })
    return page
end

local MainPage = buildScrollingPage("MainPage")
local SettingsPage = buildScrollingPage("SettingsPage")

local function switchToPage(page, tabName)
    for _, p in pairs({MainPage, SettingsPage}) do p.Visible = false end
    page.Visible = true
    for n, pill in pairs(tabPills) do pill.BackgroundColor3 = (n == tabName) and C.PillActive or C.PillInactive end
end

for tabName, page in pairs({Main = MainPage, Settings = SettingsPage}) do
    local button = TopBar:FindFirstChild(tabName.."Tab")
    if button then button.MouseButton1Click:Connect(function() switchToPage(page, tabName) end) end
end
switchToPage(MainPage, "Main")

-- ==================== FEATURE LOGIC ====================
local aimEnabled = false; local aimbotSmoothness = 1
task.spawn(function()
    while true do
        if aimEnabled then
            local nearest = math.huge; local targetHead = nil
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        if LocalPlayer.Team and p.Team and LocalPlayer.Team == p.Team then continue end
                        local head = p.Character.Head
                        local dist = (Camera.CFrame.Position - head.Position).Magnitude
                        if dist < nearest then nearest = dist; targetHead = head end
                    end
                end
            end
            if targetHead then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, targetHead.Position), aimbotSmoothness)
            end
        end
        task.wait()
    end
end)

local silentAimEnabled = false
RunService.RenderStepped:Connect(function()
    if not silentAimEnabled then return end
    local closestDist = math.huge; local target = nil
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            local hum = v.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if LocalPlayer.Team and v.Team and LocalPlayer.Team == v.Team then continue end
                local part = v.Character.Head
                local dist = (Camera.CFrame.Position - part.Position).Magnitude
                if dist < closestDist then closestDist = dist; target = v end
            end
        end
    end
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local part = target.Character.Head
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 0)
        task.wait()
        VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 0)
    end
end)

-- Wallbang
local wallBangEnabled = false; local wallBangHook = nil
local function enableWallBang() if wallBangHook then return end; pcall(function() local old; old = hookfunction(Workspace.FindPartOnRayWithIgnoreList, function(...) local args = {...}; if wallBangEnabled and args[4] and typeof(args[4])=="table" then local newIgnore={}; for _,obj in ipairs(args[3]) do if not obj:IsA("Terrain") and not obj:IsDescendantOf(Workspace) then table.insert(newIgnore,obj) end end; return old(args[1],args[2],newIgnore) end; return old(...) end); wallBangHook=old end) end
local function disableWallBang() if not wallBangHook then return end; pcall(function() hookfunction(Workspace.FindPartOnRayWithIgnoreList,wallBangHook) end); wallBangHook=nil end

-- Void Spam
local voidActive = false; local voidConn = nil
local function startVoidSpam() if voidActive then return end; voidActive = true; local char = LocalPlayer.Character; if not char then return end; local hrp = char:WaitForChild("HumanoidRootPart"); voidConn = RunService.Heartbeat:Connect(function() if voidActive and hrp and hrp.Parent then hrp.CFrame = CFrame.new(hrp.Position.X+2e15,999999,hrp.Position.Z+2e15) end end) end
local function stopVoidSpam() voidActive = false; if voidConn then voidConn:Disconnect(); voidConn=nil end end

-- Sling Bypass
local slingActive = false; local slingConn, childAddedConn, childRemovedConn; local projectiles = {}; local targetPos = CFrame.new(9000,9000,9000)
local function startSlingBypass() if slingActive then return end; slingActive=true; projectiles={}; childAddedConn=Workspace.ChildAdded:Connect(function(o) if not o:IsA("BasePart") then return end; if o.Name=="CoreProjectile" then projectiles[o]=true elseif o.Name=="Part" then task.defer(function() if o and o.Parent and o.AssemblyLinearVelocity.Magnitude>50 then projectiles[o]=true end end) end end); childRemovedConn=Workspace.ChildRemoved:Connect(function(o) projectiles[o]=nil end); slingConn=RunService.Heartbeat:Connect(function() pcall(function() for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart"); if h then h.CFrame=targetPos h.AssemblyLinearVelocity=Vector3.zero h.AssemblyAngularVelocity=Vector3.zero end end end; for _,o in ipairs(workspace:GetChildren()) do if o.Name=="CoreProjectile" and o:IsA("BasePart") then o.CFrame=targetPos o.AssemblyLinearVelocity=Vector3.zero end end; for p in pairs(projectiles) do if p and p.Parent then p.CFrame=targetPos p.AssemblyLinearVelocity=Vector3.zero else projectiles[p]=nil end end end) end) end
local function stopSlingBypass() slingActive=false; if slingConn then slingConn:Disconnect(); slingConn=nil end; if childAddedConn then childAddedConn:Disconnect(); childAddedConn=nil end; if childRemovedConn then childRemovedConn:Disconnect(); childRemovedConn=nil end; projectiles={} end

-- Anti Riot
local antiRiotEnabled = false; local riotDistance=10; local riotHeight=0; local riotUpdateRate=0.5
local function antiRiotLoop() while antiRiotEnabled do local char=LocalPlayer.Character; if char then local hrp=char:FindFirstChild("HumanoidRootPart"); if hrp then local target=nil; local closestDist=math.huge; for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local hum=p.Character:FindFirstChildOfClass("Humanoid"); if hum and hum.Health>0 then if LocalPlayer.Team and p.Team and LocalPlayer.Team==p.Team then continue end; local dist=(hrp.Position-p.Character.HumanoidRootPart.Position).Magnitude; if dist<closestDist then closestDist=dist; target=p.Character end end end end; if target then local targetRoot=target.HumanoidRootPart; local behindPos=targetRoot.Position-targetRoot.CFrame.LookVector*riotDistance+Vector3.new(0,riotHeight,0); TweenService:Create(hrp,TweenInfo.new(riotUpdateRate,Enum.EasingStyle.Linear),{CFrame=CFrame.new(behindPos)}):Play() end end end; task.wait(riotUpdateRate) end end

-- Orbit
local orbActive = false; local orbConn=nil; local angle=0
local orbitSpeed=1.0; local orbitRadius=6.0; local orbitHeight=4.0; local orbitPhase=0; local orbitStyle="Circle"
local function getClosestTarget() local char=LocalPlayer.Character; if not char then return nil end; local myRoot=char:FindFirstChild("HumanoidRootPart"); if not myRoot then return nil end; local closest,dist=nil,math.huge; for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local sameTeam=(LocalPlayer.Team~=nil and p.Team~=nil and LocalPlayer.Team==p.Team); if not sameTeam then local d=(myRoot.Position-p.Character.HumanoidRootPart.Position).Magnitude; if d<dist then dist=d; closest=p.Character end end end end; return closest end
local function startOrbit() if orbActive then return end; orbActive=true; angle=0; orbConn=RunService.Heartbeat:Connect(function() if not orbActive then return end; local target=getClosestTarget(); if target then local hrp=target:FindFirstChild("HumanoidRootPart"); if hrp then local char=LocalPlayer.Character; if char then local myHrp=char:FindFirstChild("HumanoidRootPart"); if myHrp then angle=angle+(0.18*orbitSpeed); local a=angle+math.rad(orbitPhase); local pos; if orbitStyle=="Circle" then pos=hrp.Position+Vector3.new(math.cos(a)*orbitRadius,orbitHeight,math.sin(a)*orbitRadius) elseif orbitStyle=="Random" then local ang=math.random()*math.pi*2; local dist=math.random(2,orbitRadius); pos=hrp.Position+Vector3.new(math.cos(ang)*dist,math.random(-1,3),math.sin(ang)*dist) elseif orbitStyle=="Teleport" then for i=1,8 do if not orbActive then break end; local ang=(i/8)*math.pi*2; myHrp.CFrame=CFrame.new(hrp.Position+Vector3.new(math.cos(ang)*orbitRadius,orbitHeight,math.sin(ang)*orbitRadius)); task.wait(0.05/orbitSpeed) end; pos=myHrp.Position elseif orbitStyle=="Figure 8" then pos=hrp.Position+Vector3.new(math.sin(a*2)*orbitRadius,orbitHeight,math.sin(a)*orbitRadius) elseif orbitStyle=="Spiral" then local spiralRadius=2+(a%(math.pi*2))*0.1; if spiralRadius>orbitRadius then spiralRadius=2 end; pos=hrp.Position+Vector3.new(math.cos(a)*spiralRadius,orbitHeight,math.sin(a)*spiralRadius) elseif orbitStyle=="Bounce" then pos=hrp.Position+Vector3.new(0,math.sin(a*2)*orbitHeight,0) elseif orbitStyle=="Orbit & Float" then pos=hrp.Position+Vector3.new(math.cos(a)*orbitRadius,orbitHeight+math.sin(a*2)*2,math.sin(a)*orbitRadius) else pos=hrp.Position+Vector3.new(math.cos(a)*orbitRadius,orbitHeight,math.sin(a)*orbitRadius) end; if orbitStyle~="Teleport" then myHrp.CFrame=CFrame.new(pos,hrp.Position) end end end end end end) end
local function stopOrbit() orbActive=false; if orbConn then orbConn:Disconnect(); orbConn=nil end end

-- ==================== BUILD UI PAGES ====================
create("TextLabel", { Size = UDim2.new(1,0,0,12), BackgroundTransparency = 1, Text = "Main", TextColor3 = C.Text, TextSize = 10, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Center, Parent = MainPage })

AddToggleWithKeybind(MainPage, "Aimbot", false, function(v) aimEnabled = v end)
AddSlider(MainPage, "Smoothness", 1, 100, 100, function(v) aimbotSmoothness = v / 100 end)
AddToggle(MainPage, "Silent Aim", false, function(v) silentAimEnabled = v end)
AddToggle(MainPage, "Wall Bang", false, function(v) wallBangEnabled = v; if v then enableWallBang() else disableWallBang() end end)
AddSlider(MainPage, "WB Distance", 50, 1000, 200, function(v) _G.WallBangMaxDistance = v end)
AddToggle(MainPage, "Void Spam", false, function(v) if v then startVoidSpam() else stopVoidSpam() end end)
AddToggle(MainPage, "Sling Bypass", false, function(v) if v then startSlingBypass() else stopSlingBypass() end end)
AddToggle(MainPage, "Anti Riot", false, function(v) antiRiotEnabled = v; if v then task.spawn(antiRiotLoop) end end)
AddSlider(MainPage, "Riot Distance", 0, 20, 10, function(v) riotDistance = v end)
AddSlider(MainPage, "Riot Height", -10, 10, 0, function(v) riotHeight = v end)
AddSlider(MainPage, "Riot Update", 0.1, 5, 0.5, function(v) riotUpdateRate = v end)
AddToggle(MainPage, "Orbit", false, function(v) if v then startOrbit() else stopOrbit() end end)
AddDropdown(MainPage, "Orbit Style", {"Circle","Random","Teleport","Figure 8","Spiral","Bounce","Orbit & Float"}, 1, function(v) orbitStyle = v end)
AddSlider(MainPage, "Orbit Speed", 0.5, 3.0, 1.0, function(v) orbitSpeed = v end)
AddSlider(MainPage, "Orbit Radius", 1.0, 10.0, 6.0, function(v) orbitRadius = v end)
AddSlider(MainPage, "Orbit Height", 0.0, 8.0, 4.0, function(v) orbitHeight = v end)
AddSlider(MainPage, "Phase", 0, 360, 0, function(v) orbitPhase = v end)

-- ==================== SETTINGS PAGE ====================
create("TextLabel", { Size = UDim2.new(1,0,0,12), BackgroundTransparency = 1, Text = "Settings", TextColor3 = C.Text, TextSize = 10, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Center, Parent = SettingsPage })

local configNameBox = create("TextBox", { Size = UDim2.new(1,-4,0,16), BackgroundColor3 = C.Element, BorderSizePixel = 0, Text = "", PlaceholderText = "Config name...", TextColor3 = C.Text, PlaceholderColor3 = C.SubText, TextSize = 9, Font = Enum.Font.Gotham, ClearTextOnFocus = false, Parent = SettingsPage })
create("UICorner", { CornerRadius = UDim.new(0,4), Parent = configNameBox })
local saveBtn = create("TextButton", { Size = UDim2.new(1,0,0,16), BackgroundColor3 = C.Accent, Text = "Save New Config", TextColor3 = Color3.new(1,1,1), TextSize = 9, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = SettingsPage })
create("UICorner", { CornerRadius = UDim.new(0,4), Parent = saveBtn })
local configDropdown = AddDropdown(SettingsPage, "Configs", {"(none)"}, 1)
local loadBtn = create("TextButton", { Size = UDim2.new(1,0,0,16), BackgroundColor3 = C.Element, BorderSizePixel = 1, BorderColor3 = C.Border, Text = "Load Config", TextColor3 = C.Text, TextSize = 9, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = SettingsPage })
create("UICorner", { CornerRadius = UDim.new(0,4), Parent = loadBtn })
local overwriteBtn = create("TextButton", { Size = UDim2.new(1,0,0,16), BackgroundColor3 = C.Element, BorderSizePixel = 1, BorderColor3 = C.Border, Text = "Overwrite Config", TextColor3 = C.Text, TextSize = 9, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = SettingsPage })
create("UICorner", { CornerRadius = UDim.new(0,4), Parent = overwriteBtn })
local deleteBtn = create("TextButton", { Size = UDim2.new(1,0,0,16), BackgroundColor3 = C.Element, BorderSizePixel = 1, BorderColor3 = C.Border, Text = "Delete Config", TextColor3 = C.Text, TextSize = 9, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = SettingsPage })
create("UICorner", { CornerRadius = UDim.new(0,4), Parent = deleteBtn })

-- ==================== STATS POPUP (IN DEDICATED statsLayer) ====================
local statsBtn = create("TextButton", {
    Size = UDim2.new(1,0,0,16),
    BackgroundColor3 = C.Accent,
    Text = "View Stats",
    TextColor3 = Color3.new(1,1,1),
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    Parent = SettingsPage
})
create("UICorner", { CornerRadius = UDim.new(0,4), Parent = statsBtn })

local statsPopup = create("Frame", {
    Size = UDim2.new(0, 200, 0, 160),
    Position = UDim2.new(0.5, -100, 0.5, -80),
    BackgroundColor3 = C.WindowBG,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 1,
    Parent = statsLayer   -- <-- placed in the dedicated top‑most layer
})
create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = statsPopup })
create("UIStroke", { Color = C.Border, Thickness = 1, Parent = statsPopup })

local statsTitleBar = create("Frame", { Size = UDim2.new(1,0,0,16), BackgroundColor3 = C.TitleBar, BorderSizePixel = 0, Parent = statsPopup })
create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = statsTitleBar })
create("TextLabel", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "Stats", TextColor3 = C.Text, Font = Enum.Font.GothamBold, TextSize = 10, Parent = statsTitleBar })

local statsDragging, statsDragStart, statsStartPos
statsTitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        statsDragging = true; statsDragStart = input.Position; statsStartPos = statsPopup.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then statsDragging = false end end)
    end
end)
statsTitleBar.InputChanged:Connect(function(input)
    if statsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - statsDragStart
        statsPopup.Position = UDim2.new(statsStartPos.X.Scale, statsStartPos.X.Offset + delta.X, statsStartPos.Y.Scale, statsStartPos.Y.Offset + delta.Y)
    end
end)

local statsContent = create("Frame", { Size = UDim2.new(1,0,1,-16), Position = UDim2.new(0,0,0,16), BackgroundTransparency = 1, Parent = statsPopup })
create("UIListLayout", { Padding = UDim.new(0,2), Parent = statsContent })
create("UIPadding", { PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8), PaddingTop = UDim.new(0,4), PaddingBottom = UDim.new(0,4), Parent = statsContent })

local statDefs = {
    { name = "Aimbot",      var = "aimEnabled" },
    { name = "Silent Aim",  var = "silentAimEnabled" },
    { name = "Wall Bang",   var = "wallBangEnabled" },
    { name = "Void",        var = "voidActive" },
    { name = "Sling",       var = "slingActive" },
    { name = "Anti Riot",   var = "antiRiotEnabled" },
    { name = "Orbit",       var = "orbActive" },
}
local statLabels = {}
for _, def in ipairs(statDefs) do
    local lbl = create("TextLabel", { Size = UDim2.new(1,0,0,14), BackgroundTransparency = 1, Text = def.name..": OFF", TextColor3 = C.Text, TextSize = 9, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = statsContent })
    table.insert(statLabels, lbl)
end

local closeStatsBtn = create("TextButton", { Size = UDim2.new(1,0,0,16), BackgroundColor3 = C.Element, Text = "Close", TextColor3 = C.Text, TextSize = 9, Font = Enum.Font.GothamBold, AutoButtonColor = false, Parent = statsContent })
create("UICorner", { CornerRadius = UDim.new(0,4), Parent = closeStatsBtn })
closeStatsBtn.MouseButton1Click:Connect(function() statsPopup.Visible = false end)

local function updateStats()
    if not statsPopup.Visible then return end
    local states = { aimEnabled, silentAimEnabled, wallBangEnabled, voidActive, slingActive, antiRiotEnabled, orbActive }
    for i, lbl in ipairs(statLabels) do
        lbl.Text = statDefs[i].name .. ": " .. (states[i] and "ON" or "OFF")
    end
end

statsBtn.MouseButton1Click:Connect(function()
    statsPopup.Visible = not statsPopup.Visible
    if statsPopup.Visible then updateStats() end
end)

RunService.Heartbeat:Connect(function() if statsPopup.Visible then updateStats() end end)

-- ==================== CONFIG MANAGEMENT ====================
local configs = {}
local function getCurrentState()
    local state = {}
    for _, ctrl in ipairs(allControls) do
        if ctrl.type == "toggle" then state[ctrl.name] = {type="toggle", value=ctrl.get()}
        elseif ctrl.type == "slider" then state[ctrl.name] = {type="slider", value=ctrl.get()}
        elseif ctrl.type == "dropdown" then state[ctrl.name] = {type="dropdown", index=ctrl.get()}
        end
    end
    return state
end
local function applyState(state)
    for _, ctrl in ipairs(allControls) do
        local saved = state[ctrl.name]
        if saved then
            if ctrl.type == "toggle" and saved.type=="toggle" then ctrl.set(saved.value)
            elseif ctrl.type == "slider" and saved.type=="slider" then ctrl.set(saved.value)
            elseif ctrl.type == "dropdown" and saved.type=="dropdown" then ctrl.SetIndex(saved.index)
            end
        end
    end
end
local function updateConfigDropdown()
    local names = {}
    for name in pairs(configs) do table.insert(names, name) end
    table.sort(names)
    if #names == 0 then names = {"(none)"} end
    configDropdown.UpdateOptions(names)
end

saveBtn.MouseButton1Click:Connect(function()
    local name = configNameBox.Text:gsub("^%s*(.-)%s*$", "%1")
    if name == "" then return end
    configs[name] = getCurrentState()
    configNameBox.Text = ""
    updateConfigDropdown()
    if writefile then writefile(configSubFolder .. "/" .. name .. ".json", HttpService:JSONEncode(getCurrentState())) end
end)
loadBtn.MouseButton1Click:Connect(function()
    local sel = configDropdown.GetOption()
    if sel and sel ~= "(none)" and configs[sel] then applyState(configs[sel]) end
end)
overwriteBtn.MouseButton1Click:Connect(function()
    local sel = configDropdown.GetOption()
    if sel and sel ~= "(none)" and configs[sel] then
        configs[sel] = getCurrentState()
        if writefile then writefile(configSubFolder .. "/" .. sel .. ".json", HttpService:JSONEncode(getCurrentState())) end
    end
end)
local deleteConfirm = false
deleteBtn.MouseButton1Click:Connect(function()
    local sel = configDropdown.GetOption()
    if sel and sel ~= "(none)" and configs[sel] then
        if not deleteConfirm then
            deleteConfirm = true; deleteBtn.Text = "Are you sure?"; deleteBtn.BackgroundColor3 = Color3.fromRGB(200,80,80)
            task.delay(2, function() if deleteConfirm then deleteConfirm = false; deleteBtn.Text = "Delete Config"; deleteBtn.BackgroundColor3 = C.Element end end)
        else
            configs[sel] = nil; updateConfigDropdown(); deleteConfirm = false; deleteBtn.Text = "Delete Config"; deleteBtn.BackgroundColor3 = C.Element
        end
    end
end)
updateConfigDropdown()

pcall(function()
    if readfile and isfile(CONFIG_FILE) then
        local data = readfile(CONFIG_FILE)
        if data then
            local ok, parsed = pcall(function() return HttpService:JSONDecode(data) end)
            if ok and parsed and parsed.controls then applyState(parsed.controls) end
        end
    end
end)

print("Mehfil Beta loaded. All features ready.")
