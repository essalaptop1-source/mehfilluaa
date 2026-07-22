-- ==============================================
-- MEHFIL LUA – FULL CHEAT SCRIPT
-- No key, no webhook, no game lock
-- ==============================================
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local isMobile = UserInputService.TouchEnabled

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CUSTOM_CURSOR_ID = "rbxassetid://10397909758"
Mouse.Icon = CUSTOM_CURSOR_ID
Mouse:GetPropertyChangedSignal("Icon"):Connect(function()
    if Mouse.Icon ~= CUSTOM_CURSOR_ID then Mouse.Icon = CUSTOM_CURSOR_ID end
end)

local Blur = Instance.new("BlurEffect")
Blur.Name = "GameBackgroundBlur"
Blur.Size = 0
Blur.Parent = Lighting
local TWEEN_TIME, TARGET_BLUR_SIZE = 0.4, 24
local function BlurOn() TweenService:Create(Blur, TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = TARGET_BLUR_SIZE}):Play() end
local function BlurOff() TweenService:Create(Blur, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = 0}):Play() end

local toggleBtn, fpsFrame, fpsStroke, fpsLabel
local menuInfos = {}
local hideNotifsToggle = {}
local hideStatsToggle = {}
local hideButtonToggle = {}
local configsOpen = false
local updateAutoLoadDropdownHeight

shared.SavedConfigs_Config2 = shared.SavedConfigs_Config2 or {}
shared.AutoLoadConfig_Config2 = shared.AutoLoadConfig_Config2 or "None"

if writefile and makefolder and isfolder then
    if not isfolder("Configuration2") then pcall(makefolder, "Configuration2") end
    if not isfolder("Configuration2/configs") then pcall(makefolder, "Configuration2/configs") end
end

local function loadFileConfigs()
    if not isfolder or not listfiles or not readfile then return end
    if not isfolder("Configuration2/configs") then return end
    local ok, files = pcall(listfiles, "Configuration2/configs")
    if not ok then return end
    for _, file in ipairs(files) do
        if file:match("%.json$") then
            local name = file:match("([^/\\]+)%.json$")
            if name then
                local success, json = pcall(readfile, file)
                if success and json and json ~= "" then
                    local decoded_ok, decoded = pcall(HttpService.JSONDecode, HttpService, json)
                    if decoded_ok and type(decoded) == "table" then
                        shared.SavedConfigs_Config2[name] = decoded
                    end
                end
            end
        end
    end
end
loadFileConfigs()

if readfile and isfile then
    local autoLoadPath = "Configuration2/autoload.txt"
    local ok2, autoLoadData = pcall(function()
        if isfile(autoLoadPath) then return readfile(autoLoadPath) end
        return nil
    end)
    if ok2 and autoLoadData and autoLoadData ~= "" then
        shared.AutoLoadConfig_Config2 = autoLoadData
    end
end

local themes = {
    Default   = {bg = Color3.fromRGB(0,0,0),       elem = Color3.fromRGB(20,20,20),   accent = Color3.fromRGB(255,255,255), text = Color3.fromRGB(255,255,255), toggleOff = Color3.fromRGB(40,40,40),   border = Color3.fromRGB(50,50,50),   sliderBar = Color3.fromRGB(30,30,30)},
    Obsidian  = {bg = Color3.fromRGB(5,5,5),        elem = Color3.fromRGB(18,18,18),   accent = Color3.fromRGB(255,255,255), text = Color3.fromRGB(255,255,255), toggleOff = Color3.fromRGB(35,35,35),   border = Color3.fromRGB(45,45,45),   sliderBar = Color3.fromRGB(25,25,25)},
    Carbon    = {bg = Color3.fromRGB(20,20,20),     elem = Color3.fromRGB(30,30,30),   accent = Color3.fromRGB(255,255,255), text = Color3.fromRGB(240,240,240), toggleOff = Color3.fromRGB(50,50,50),   border = Color3.fromRGB(60,60,60),   sliderBar = Color3.fromRGB(40,40,40)},
    Crimson   = {bg = Color3.fromRGB(15,0,0),       elem = Color3.fromRGB(30,5,5),     accent = Color3.fromRGB(255,80,80),   text = Color3.fromRGB(255,220,220), toggleOff = Color3.fromRGB(60,20,20),   border = Color3.fromRGB(80,30,30),   sliderBar = Color3.fromRGB(40,10,10)},
    Ocean     = {bg = Color3.fromRGB(0,5,15),       elem = Color3.fromRGB(5,15,30),    accent = Color3.fromRGB(80,180,255),  text = Color3.fromRGB(220,240,255), toggleOff = Color3.fromRGB(20,40,60),   border = Color3.fromRGB(30,60,90),   sliderBar = Color3.fromRGB(10,25,45)},
    Forest    = {bg = Color3.fromRGB(0,15,0),       elem = Color3.fromRGB(5,30,5),     accent = Color3.fromRGB(80,255,80),   text = Color3.fromRGB(220,255,220), toggleOff = Color3.fromRGB(20,60,20),   border = Color3.fromRGB(30,80,30),   sliderBar = Color3.fromRGB(10,40,10)},
    Midnight  = {bg = Color3.fromRGB(10,10,20),     elem = Color3.fromRGB(20,20,35),   accent = Color3.fromRGB(140,100,255), text = Color3.fromRGB(240,240,240), toggleOff = Color3.fromRGB(35,35,55),   border = Color3.fromRGB(55,55,85),   sliderBar = Color3.fromRGB(25,25,45)},
    Ametrine  = {bg = Color3.fromRGB(20,10,25),     elem = Color3.fromRGB(35,20,45),   accent = Color3.fromRGB(220,100,255), text = Color3.fromRGB(245,230,255), toggleOff = Color3.fromRGB(55,30,70),   border = Color3.fromRGB(75,45,100),  sliderBar = Color3.fromRGB(45,25,55)},
    Nordic    = {bg = Color3.fromRGB(46,52,64),     elem = Color3.fromRGB(59,66,82),   accent = Color3.fromRGB(143,188,187), text = Color3.fromRGB(236,239,244), toggleOff = Color3.fromRGB(76,86,106),  border = Color3.fromRGB(76,86,106),  sliderBar = Color3.fromRGB(46,52,64)},
    Cyberpunk = {bg = Color3.fromRGB(15,15,20),     elem = Color3.fromRGB(25,25,35),   accent = Color3.fromRGB(0,255,255),   text = Color3.fromRGB(255,0,128),   toggleOff = Color3.fromRGB(40,40,55),   border = Color3.fromRGB(255,0,128),  sliderBar = Color3.fromRGB(30,30,45)},
    Sakura    = {bg = Color3.fromRGB(30,20,25),     elem = Color3.fromRGB(50,30,40),   accent = Color3.fromRGB(255,180,200), text = Color3.fromRGB(255,240,245), toggleOff = Color3.fromRGB(75,45,60),   border = Color3.fromRGB(110,65,85),  sliderBar = Color3.fromRGB(60,35,48)},
}
local currentThemeName = "Default"
local currentTheme = themes[currentThemeName]

local availableFonts = {
    "Gotham","SourceSans","Arial","Legacy","FredokaOne","Michroma","Oswald","Roboto","Montserrat",
}
local currentFontName = "Gotham"
local currentFont = Enum.Font[currentFontName] or Enum.Font.Gotham

local allUIElements = {}
local function registerElement(obj, role)
    table.insert(allUIElements, {obj = obj, role = role})
end

local themeHeaderRef, fontHeaderRef = nil, nil

local function applyFont(fontName)
    local font = Enum.Font[fontName]
    if not font then return end
    currentFontName = fontName
    currentFont = font
    for _, item in ipairs(allUIElements) do
        local obj = item.obj
        if item.role == "text" and (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
            obj.Font = font
        end
    end
end

local function applyTheme(name)
    local newTheme = themes[name]
    if not newTheme then return end
    currentTheme = newTheme
    currentThemeName = name
    for _, item in ipairs(allUIElements) do
        local obj, role = item.obj, item.role
        if not obj or not obj.Parent then continue end
        if role == "bg" and (obj:IsA("Frame") or obj:IsA("ScrollingFrame")) then
            obj.BackgroundColor3 = newTheme.bg
        elseif role == "elem" and (obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("TextBox") or obj:IsA("ScrollingFrame")) then
            obj.BackgroundColor3 = newTheme.elem
        elseif role == "accent" and obj:IsA("TextButton") then
            obj.BackgroundColor3 = newTheme.accent
        elseif role == "toggleOff" and obj:IsA("TextButton") then
            obj.BackgroundColor3 = newTheme.toggleOff
        elseif role == "text" and (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
            obj.TextColor3 = newTheme.text
            obj.Font = currentFont
        elseif role == "border" and obj:IsA("UIStroke") then
            obj.Color = newTheme.border
        elseif role == "sliderBar" and obj:IsA("Frame") then
            obj.BackgroundColor3 = newTheme.sliderBar
        end
    end
    if toggleBtn then
        toggleBtn.BackgroundColor3 = newTheme.bg
        toggleBtn.TextColor3 = newTheme.text
    end
    if fpsFrame then fpsFrame.BackgroundColor3 = newTheme.bg end
    if fpsStroke then fpsStroke.Color = newTheme.border end
    if fpsLabel then fpsLabel.TextColor3 = newTheme.text end
    if themeHeaderRef then themeHeaderRef.Text = "▼ Theme: " .. name end
    if fontHeaderRef then fontHeaderRef.Text = "▼ Font: " .. currentFontName end
end

local function addCorners(f, r)
    local c = Instance.new("UICorner"); c.CornerRadius = r or UDim.new(0,10); c.Parent = f
end

local Notify
do
    local NOTIF_WIDTH, NOTIF_HEIGHT = 140, 24
    local TOP_OFFSET = isMobile and 50 or 30
    local SPACING = 6
    local ScreenGui = CoreGui:FindFirstChild("RobloxNotifierContainer") or Instance.new("ScreenGui")
    if not ScreenGui.Parent then
        ScreenGui.Name = "RobloxNotifierContainer"; ScreenGui.ResetOnSpawn = false; ScreenGui.Parent = CoreGui
    end
    shared.ActiveNotifs = shared.ActiveNotifs or {}
    local function UpdatePositions()
        local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
        for i, frame in ipairs(shared.ActiveNotifs) do
            local targetY = TOP_OFFSET + (i-1)*(NOTIF_HEIGHT+SPACING)
            TweenService:Create(frame, tweenInfo, {Position = UDim2.new(1, -(NOTIF_WIDTH+15), 0, targetY)}):Play()
        end
    end
    function Notify(message)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(0, NOTIF_WIDTH, 0, NOTIF_HEIGHT)
        Frame.Position = UDim2.new(1, 15, 0, TOP_OFFSET)
        Frame.BackgroundColor3 = currentTheme.bg
        Frame.BorderSizePixel = 0
        Frame.Parent = ScreenGui
        local stroke = Instance.new("UIStroke", Frame)
        stroke.Color = currentTheme.border; stroke.Transparency = 0.4; stroke.Thickness = 1
        local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0,4); corner.Parent = Frame
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -12, 1, 0); label.Position = UDim2.new(0,6,0,0)
        label.BackgroundTransparency = 1; label.Text = message or "Executed"
        label.TextColor3 = currentTheme.text; label.Font = currentFont; label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextTruncate = Enum.TextTruncate.AtEnd
        label.Parent = Frame
        table.insert(shared.ActiveNotifs, 1, Frame)
        UpdatePositions()
        local function DestroyNotif()
            for i, f in ipairs(shared.ActiveNotifs) do if f == Frame then table.remove(shared.ActiveNotifs, i) break end end
            local tween = TweenService:Create(Frame, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
                {Position = UDim2.new(1, 15, 0, Frame.Position.Y.Offset)})
            tween:Play(); UpdatePositions()
            tween.Completed:Connect(function() Frame:Destroy() end)
        end
        task.delay(2.5, DestroyNotif)
    end
end

local gui = Instance.new("ScreenGui")
gui.Name = "BlackUI"; gui.ResetOnSpawn = false
gui.Parent = (gethui and gethui()) or CoreGui

toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 60, 0, 26)
toggleBtn.Position = UDim2.new(0.02, 0, 0.02, 0)
toggleBtn.BackgroundColor3 = currentTheme.bg
toggleBtn.TextColor3 = currentTheme.text
toggleBtn.Font = currentFont
toggleBtn.TextSize = 14
toggleBtn.AutoButtonColor = false
toggleBtn.BorderSizePixel = 0
toggleBtn.ZIndex = 100
toggleBtn.Text = "Close"
toggleBtn.Parent = gui
addCorners(toggleBtn, UDim.new(0,6))
local toggleStroke = Instance.new("UIStroke", toggleBtn)
toggleStroke.Color = currentTheme.border
registerElement(toggleBtn, "bg")
registerElement(toggleStroke, "border")

local statsGui = Instance.new("ScreenGui")
statsGui.Name = "StatsGui"; statsGui.ResetOnSpawn = false
statsGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

fpsFrame = Instance.new("Frame")
fpsFrame.Size = UDim2.new(0, 130, 0, 25)
fpsFrame.Position = UDim2.new(0, 10, 0, 10)
fpsFrame.BackgroundColor3 = currentTheme.bg
fpsFrame.BorderSizePixel = 0
fpsFrame.Parent = statsGui
addCorners(fpsFrame, UDim.new(0,6))
registerElement(fpsFrame, "bg")
fpsStroke = Instance.new("UIStroke")
fpsStroke.Color = currentTheme.border; fpsStroke.Thickness = 1; fpsStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
fpsStroke.Parent = fpsFrame
registerElement(fpsStroke, "border")
fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, 0, 1, 0); fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = currentTheme.text; fpsLabel.Font = currentFont; fpsLabel.TextSize = 13
fpsLabel.TextXAlignment = Enum.TextXAlignment.Center; fpsLabel.TextYAlignment = Enum.TextYAlignment.Center
fpsLabel.Text = "MehfilLuaBeta | --"
fpsLabel.Parent = fpsFrame
registerElement(fpsLabel, "text")

local deltaTimeAccumulator = 0
local frameCount = 0
RunService.RenderStepped:Connect(function(deltaTime)
    frameCount = frameCount + 1
    deltaTimeAccumulator = deltaTimeAccumulator + deltaTime
    if deltaTimeAccumulator >= 0.5 then
        local fps = math.round(frameCount / deltaTimeAccumulator)
        fpsLabel.Text = "MehfilLuaBeta | " .. fps
        frameCount = 0; deltaTimeAccumulator = 0
    end
end)

local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    fpsFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
fpsFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = fpsFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
fpsFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

local menuW = isMobile and 160 or 200
local sideH = isMobile and 200 or 250
local centerH = isMobile and 260 or 320

local menuData = {
    { name = "Orbit",    icon = "rbxassetid://100697683578520", layoutOrder = 1, width = menuW, height = sideH },
    { name = "Void spam", icon = "rbxassetid://130413215442677", layoutOrder = 2, width = menuW, height = centerH },
    { name = "Settings", icon = "rbxassetid://96083562140908",  layoutOrder = 3, width = menuW, height = sideH },
}

local containerWidth = 3 * menuW + 20
local container = Instance.new("Frame")
container.AnchorPoint = Vector2.new(0.5,0)
container.Position = isMobile and UDim2.new(0.5, 0, 0.04, 0) or UDim2.new(0.5, 0, 0.06, 0)
container.BackgroundTransparency = 1; container.BorderSizePixel = 0
container.Size = UDim2.new(0, containerWidth, 0, 350)
container.Parent = gui
local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.Padding = UDim.new(0,10)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = container

for i, data in ipairs(menuData) do
    local menu = Instance.new("Frame")
    menu.Name = data.name; menu.LayoutOrder = data.layoutOrder
    menu.Size = UDim2.new(0, data.width, 0, data.height)
    menu.BackgroundColor3 = currentTheme.bg; menu.BorderSizePixel = 0; menu.ClipsDescendants = true
    menu.ZIndex = 1; menu.Visible = true; menu.BackgroundTransparency = 0; menu.Parent = container
    addCorners(menu)
    registerElement(menu, "bg")
    local stroke = Instance.new("UIStroke", menu)
    stroke.Color = currentTheme.border; stroke.Thickness = 1.5
    registerElement(stroke, "border")

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1,0,0,26); titleBar.BackgroundTransparency = 1; titleBar.BorderSizePixel = 0; titleBar.Parent = menu
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0,18,0,18); icon.Position = UDim2.new(0,6,0.5,-9); icon.BackgroundTransparency = 1
    pcall(function() icon.Image = data.icon end); icon.Parent = titleBar
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-60,1,0); title.Position = UDim2.new(0,28,0,0); title.BackgroundTransparency = 1
    title.Text = data.name; title.TextColor3 = currentTheme.text; title.Font = currentFont; title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = titleBar
    registerElement(title, "text")

    if data.name == "Void spam" then
        local rightContainer = Instance.new("Frame")
        rightContainer.Size = UDim2.new(0, 56, 1, 0)
        rightContainer.Position = UDim2.new(1, -60, 0, 0)
        rightContainer.BackgroundTransparency = 1
        rightContainer.Parent = titleBar

        local function createIconButtonBox(iconId, name, posX)
            local box = Instance.new("Frame")
            box.Size = UDim2.new(0, 26, 0, 26)
            box.Position = UDim2.new(0, posX, 0.5, -13)
            box.BackgroundColor3 = currentTheme.elem
            box.BorderSizePixel = 0
            box.Parent = rightContainer
            addCorners(box, UDim.new(0, 5))
            local boxStroke = Instance.new("UIStroke", box)
            boxStroke.Color = currentTheme.border
            boxStroke.Thickness = 1

            local btn = Instance.new("ImageButton")
            btn.Size = UDim2.new(0, 20, 0, 20)
            btn.Position = UDim2.new(0.5, -10, 0.5, -10)
            btn.BackgroundTransparency = 1
            btn.Image = "rbxassetid://" .. tostring(iconId)
            btn.Name = name
            btn.Parent = box

            return btn
        end

        local miscBtn = createIconButtonBox(115458898390425, "MiscBtn", 0)
        local espBtn = createIconButtonBox(126382982896675, "EspBtn", 30)
    end

    if data.name == "Settings" then
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Size = UDim2.new(1,-6,1,-28); scrollFrame.Position = UDim2.new(0,3,0,26)
        scrollFrame.BackgroundColor3 = currentTheme.bg; scrollFrame.BorderSizePixel = 0; scrollFrame.ScrollBarThickness = 3
        scrollFrame.CanvasSize = UDim2.new(0,0,0,0); scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scrollFrame.Parent = menu; addCorners(scrollFrame, UDim.new(0,6))
        registerElement(scrollFrame, "bg")
        local scrollLayout2 = Instance.new("UIListLayout")
        scrollLayout2.Padding = UDim.new(0,4); scrollLayout2.SortOrder = Enum.SortOrder.LayoutOrder; scrollLayout2.Parent = scrollFrame
        table.insert(menuInfos, {frame = menu, scroll = scrollFrame, height = data.height, width = data.width, name = data.name, featureToggle = nil})
    else
        table.insert(menuInfos, {frame = menu, scroll = nil, height = data.height, width = data.width, name = data.name, featureToggle = nil})
    end
end

-- ===== ADMIN PANEL =====
local adminMenu, adminContentFrame
local function createAdminPanel()
    if adminMenu then return end
    local settingsMenu = menuInfos[3].frame
    local adminWidth, adminHeight = settingsMenu.Size.X.Offset, settingsMenu.Size.Y.Offset
    local screenSize = gui.AbsoluteSize
    local spawnX = math.clamp((screenSize.X / 2) + (3 * menuW / 2) + 20, 10, screenSize.X - adminWidth - 10)
    local spawnY = math.clamp(screenSize.Y * 0.06, 10, screenSize.Y - adminHeight - 10)
    adminMenu = Instance.new("Frame")
    adminMenu.Name = "AdminPanel"
    adminMenu.Size = UDim2.new(0, adminWidth, 0, adminHeight)
    adminMenu.Position = UDim2.new(0, spawnX, 0, spawnY)
    adminMenu.BackgroundColor3 = currentTheme.bg
    adminMenu.BorderSizePixel = 0; adminMenu.ClipsDescendants = true
    adminMenu.ZIndex = 10; adminMenu.Visible = false; adminMenu.Active = true; adminMenu.Parent = gui
    addCorners(adminMenu)
    registerElement(adminMenu, "bg")
    local stroke = Instance.new("UIStroke", adminMenu)
    stroke.Color = currentTheme.border; stroke.Thickness = 1.5
    registerElement(stroke, "border")
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 26); titleBar.BackgroundTransparency = 1; titleBar.BorderSizePixel = 0; titleBar.Parent = adminMenu
    local adminIcon = Instance.new("ImageLabel")
    adminIcon.Size = UDim2.new(0, 18, 0, 18); adminIcon.Position = UDim2.new(0, 6, 0.5, -9); adminIcon.BackgroundTransparency = 1
    adminIcon.Image = "rbxassetid://107381595114199"; adminIcon.Parent = titleBar
    local adminTitle = Instance.new("TextLabel")
    adminTitle.Size = UDim2.new(1, -32, 1, 0); adminTitle.Position = UDim2.new(0, 28, 0, 0); adminTitle.BackgroundTransparency = 1
    adminTitle.Text = "Admin"; adminTitle.TextColor3 = currentTheme.text; adminTitle.Font = currentFont; adminTitle.TextSize = 14
    adminTitle.TextXAlignment = Enum.TextXAlignment.Left; adminTitle.Parent = titleBar
    registerElement(adminTitle, "text")
    local inlineClose = Instance.new("TextButton")
    inlineClose.Size = UDim2.new(0, 22, 0, 22); inlineClose.AnchorPoint = Vector2.new(1, 0.5); inlineClose.Position = UDim2.new(1, -4, 0.5, 0)
    inlineClose.BackgroundTransparency = 1; inlineClose.Text = "X"; inlineClose.TextColor3 = currentTheme.text; inlineClose.Font = currentFont; inlineClose.TextSize = 15
    inlineClose.AutoButtonColor = false; inlineClose.BorderSizePixel = 0; inlineClose.ZIndex = 12; inlineClose.Parent = titleBar
    registerElement(inlineClose, "text")
    inlineClose.MouseButton1Click:Connect(hideAdminPanel)
    adminContentFrame = Instance.new("Frame")
    adminContentFrame.Size = UDim2.new(1, -12, 0, 0); adminContentFrame.Position = UDim2.new(0, 6, 0, 32)
    adminContentFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 80); adminContentFrame.BorderSizePixel = 0
    adminContentFrame.AutomaticSize = Enum.AutomaticSize.Y; adminContentFrame.Parent = adminMenu
    addCorners(adminContentFrame, UDim.new(0, 6))
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 4); contentLayout.SortOrder = Enum.SortOrder.LayoutOrder; contentLayout.Parent = adminContentFrame
    local headerLabel = Instance.new("TextLabel")
    headerLabel.Size = UDim2.new(1, -8, 0, 24); headerLabel.Position = UDim2.new(0, 4, 0, 4); headerLabel.BackgroundTransparency = 1
    headerLabel.TextColor3 = currentTheme.text; headerLabel.Font = currentFont; headerLabel.TextSize = 14
    headerLabel.Text = "Admin Panel"; headerLabel.TextXAlignment = Enum.TextXAlignment.Left; headerLabel.Parent = adminContentFrame
    registerElement(headerLabel, "text")
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -8, 0, 0); infoLabel.AutomaticSize = Enum.AutomaticSize.Y; infoLabel.Position = UDim2.new(0, 4, 0, 4)
    infoLabel.BackgroundTransparency = 1; infoLabel.TextColor3 = currentTheme.text; infoLabel.Font = currentFont; infoLabel.TextSize = 12
    infoLabel.TextWrapped = true; infoLabel.Text = "Loaded by: " .. LocalPlayer.Name .. "\nUserID: " .. LocalPlayer.UserId
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left; infoLabel.Parent = adminContentFrame
    registerElement(infoLabel, "text")
    local dragActive, dragStartPos, dragPanelStart
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragActive = true; dragStartPos = input.Position; dragPanelStart = adminMenu.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragActive = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragActive then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStartPos
            adminMenu.Position = UDim2.new(dragPanelStart.X.Scale, dragPanelStart.X.Offset + delta.X, dragPanelStart.Y.Scale, dragPanelStart.Y.Offset + delta.Y)
        end
    end)
end

function showAdminPanel()
    if not adminMenu then createAdminPanel() end
    adminMenu.Visible = true
    TweenService:Create(adminMenu, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()
end

function hideAdminPanel()
    if not adminMenu then return end
    local t = TweenService:Create(adminMenu, TweenInfo.new(0.2), {BackgroundTransparency = 1})
    t:Play()
    t.Completed:Connect(function() adminMenu.Visible = false end)
end

-- ===== SETTINGS TAB =====
do
    local settingsMenu = menuInfos[3]
    local scrollFrame = settingsMenu.scroll

    local cfgNameBox = Instance.new("TextBox")
    cfgNameBox.Size = UDim2.new(1, -4, 0, 22); cfgNameBox.BackgroundColor3 = currentTheme.elem; cfgNameBox.TextColor3 = currentTheme.text
    cfgNameBox.Font = currentFont; cfgNameBox.PlaceholderText = "Config name"; cfgNameBox.Text = ""; cfgNameBox.ClearTextOnFocus = false
    cfgNameBox.Parent = scrollFrame; addCorners(cfgNameBox, UDim.new(0,4))
    registerElement(cfgNameBox, "elem"); registerElement(cfgNameBox, "text")

    local createBtn = Instance.new("TextButton")
    createBtn.Size = UDim2.new(1, -4, 0, 22); createBtn.BackgroundColor3 = currentTheme.elem; createBtn.TextColor3 = currentTheme.text
    createBtn.Font = currentFont; createBtn.Text = "Create Config"; createBtn.TextSize = 12; createBtn.AutoButtonColor = false
    createBtn.Parent = scrollFrame; addCorners(createBtn, UDim.new(0,4))
    registerElement(createBtn, "elem"); registerElement(createBtn, "text")

    local configsDropdownHeader = Instance.new("TextButton")
    configsDropdownHeader.Size = UDim2.new(1, -4, 0, 22); configsDropdownHeader.BackgroundColor3 = currentTheme.elem
    configsDropdownHeader.TextColor3 = currentTheme.text; configsDropdownHeader.Font = currentFont; configsDropdownHeader.TextSize = 12
    configsDropdownHeader.Text = "▼ Configs"; configsDropdownHeader.TextXAlignment = Enum.TextXAlignment.Left; configsDropdownHeader.AutoButtonColor = false
    configsDropdownHeader.Parent = scrollFrame; addCorners(configsDropdownHeader, UDim.new(0,4))
    registerElement(configsDropdownHeader, "elem"); registerElement(configsDropdownHeader, "text")

    local configsDropdownContent = Instance.new("Frame")
    configsDropdownContent.Size = UDim2.new(1, -4, 0, 0); configsDropdownContent.BackgroundColor3 = currentTheme.elem
    configsDropdownContent.BorderSizePixel = 0; configsDropdownContent.ClipsDescendants = true; configsDropdownContent.Parent = scrollFrame
    addCorners(configsDropdownContent, UDim.new(0,4))
    registerElement(configsDropdownContent, "elem")
    local configsDropdownLayout = Instance.new("UIListLayout"); configsDropdownLayout.Padding = UDim.new(0, 2); configsDropdownLayout.Parent = configsDropdownContent

    local loadBtn = Instance.new("TextButton")
    loadBtn.Size = UDim2.new(1, -4, 0, 20); loadBtn.BackgroundColor3 = currentTheme.elem; loadBtn.TextColor3 = currentTheme.text
    loadBtn.Font = currentFont; loadBtn.Text = "Load Config"; loadBtn.TextSize = 11; loadBtn.AutoButtonColor = false; loadBtn.Visible = false
    loadBtn.Parent = scrollFrame; addCorners(loadBtn, UDim.new(0,4))
    registerElement(loadBtn, "elem"); registerElement(loadBtn, "text")

    local overwriteBtn = Instance.new("TextButton")
    overwriteBtn.Size = UDim2.new(1, -4, 0, 20); overwriteBtn.BackgroundColor3 = currentTheme.elem; overwriteBtn.TextColor3 = currentTheme.text
    overwriteBtn.Font = currentFont; overwriteBtn.Text = "Overwrite Config"; overwriteBtn.TextSize = 11; overwriteBtn.AutoButtonColor = false; overwriteBtn.Visible = false
    overwriteBtn.Parent = scrollFrame; addCorners(overwriteBtn, UDim.new(0,4))
    registerElement(overwriteBtn, "elem"); registerElement(overwriteBtn, "text")

    local deleteBtn = Instance.new("TextButton")
    deleteBtn.Size = UDim2.new(1, -4, 0, 20); deleteBtn.BackgroundColor3 = currentTheme.elem; deleteBtn.TextColor3 = currentTheme.text
    deleteBtn.Font = currentFont; deleteBtn.Text = "Delete Config"; deleteBtn.TextSize = 11; deleteBtn.AutoButtonColor = false; deleteBtn.Visible = false
    deleteBtn.Parent = scrollFrame; addCorners(deleteBtn, UDim.new(0,4))
    registerElement(deleteBtn, "elem"); registerElement(deleteBtn, "text")

    local selectedConfig = nil
    local deleteConfirm, deleteTimerThread = false, nil

    local function resetDeleteButtonState()
        if deleteTimerThread then task.cancel(deleteTimerThread); deleteTimerThread = nil end
        deleteConfirm = false; deleteBtn.Text = "Delete Config"
    end

    local function getCurrentSettings()
        return {
            theme = currentThemeName,
            font = currentFontName,
            hideNotifications = hideNotifsToggle.state,
            hideStats = hideStatsToggle.state,
            hideButton = hideButtonToggle.state,
        }
    end

    local function applySettings(settings)
        if not settings then return end
        if settings.theme and themes[settings.theme] then applyTheme(settings.theme) end
        if settings.font then applyFont(settings.font) end
        if settings.hideNotifications ~= nil and hideNotifsToggle.SetState then hideNotifsToggle.SetState(settings.hideNotifications) end
        if settings.hideStats ~= nil and hideStatsToggle.SetState then hideStatsToggle.SetState(settings.hideStats) end
        if settings.hideButton ~= nil and hideButtonToggle.SetState then hideButtonToggle.SetState(settings.hideButton) end
    end

    local function saveConfigToFile(name, settings)
        shared.SavedConfigs_Config2[name] = settings
        if writefile and makefolder and isfolder then
            if not isfolder("Configuration2/configs") then pcall(makefolder, "Configuration2/configs") end
            pcall(writefile, "Configuration2/configs/" .. name .. ".json", HttpService:JSONEncode(settings))
        end
    end

    local function saveAutoLoad(name)
        shared.AutoLoadConfig_Config2 = name
        if writefile then pcall(writefile, "Configuration2/autoload.txt", name) end
    end

    local function refreshConfigsDropdown()
        for _, child in ipairs(configsDropdownContent:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("TextLabel") then child:Destroy() end
        end
        local configNames = {}
        for name, _ in pairs(shared.SavedConfigs_Config2) do table.insert(configNames, name) end
        table.sort(configNames)
        if #configNames == 0 then
            local placeholder = Instance.new("TextLabel")
            placeholder.Size = UDim2.new(1, -4, 0, 18); placeholder.BackgroundTransparency = 1
            placeholder.TextColor3 = currentTheme.text; placeholder.Font = currentFont; placeholder.TextSize = 11
            placeholder.Text = "(no configs)"; placeholder.Parent = configsDropdownContent
            registerElement(placeholder, "text")
        else
            for _, name in ipairs(configNames) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, -4, 0, 18); optBtn.BackgroundColor3 = currentTheme.sliderBar; optBtn.TextColor3 = currentTheme.text
                optBtn.Font = currentFont; optBtn.TextSize = 11; optBtn.Text = name; optBtn.AutoButtonColor = false
                optBtn.Parent = configsDropdownContent; addCorners(optBtn, UDim.new(0,3))
                registerElement(optBtn, "sliderBar"); registerElement(optBtn, "text")
                optBtn.MouseButton1Click:Connect(function()
                    selectedConfig = name
                    loadBtn.Visible = true; overwriteBtn.Visible = true; deleteBtn.Visible = true
                    configsDropdownHeader.Text = "▼ Configs: " .. name
                end)
            end
        end
        if configsOpen then
            local count = 0
            for _, child in ipairs(configsDropdownContent:GetChildren()) do
                if child:IsA("TextButton") or child:IsA("TextLabel") then count = count + 1 end
            end
            configsDropdownContent.Size = UDim2.new(1, -4, 0, count * 20 + 10)
        end
        if updateAutoLoadDropdownHeight then updateAutoLoadDropdownHeight() end
    end

    configsDropdownHeader.MouseButton1Click:Connect(function()
        configsOpen = not configsOpen
        refreshConfigsDropdown()
        if configsOpen then
            local count = 0
            for _, child in ipairs(configsDropdownContent:GetChildren()) do
                if child:IsA("TextButton") or child:IsA("TextLabel") then count = count + 1 end
            end
            TweenService:Create(configsDropdownContent, TweenInfo.new(0.3), {Size = UDim2.new(1, -4, 0, count * 20 + 10)}):Play()
        else
            TweenService:Create(configsDropdownContent, TweenInfo.new(0.3), {Size = UDim2.new(1, -4, 0, 0)}):Play()
        end
    end)

    createBtn.MouseButton1Click:Connect(function()
        local name = cfgNameBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
        if name == "" then Notify("Enter a config name") return end
        local settings = getCurrentSettings()
        saveConfigToFile(name, settings)
        Notify("Config '" .. name .. "' saved")
        cfgNameBox.Text = ""
        refreshConfigsDropdown()
    end)

    local function runLoadLogic(name)
        local settings = shared.SavedConfigs_Config2[name]
        if not settings then Notify("Config not found") return end
        applySettings(settings)
    end

    loadBtn.MouseButton1Click:Connect(function()
        if not selectedConfig then return end
        runLoadLogic(selectedConfig)
        Notify("Config '" .. selectedConfig .. "' loaded")
    end)

    overwriteBtn.MouseButton1Click:Connect(function()
        if not selectedConfig then return end
        local settings = getCurrentSettings()
        saveConfigToFile(selectedConfig, settings)
        Notify("Config '" .. selectedConfig .. "' overwritten")
    end)

    deleteBtn.MouseButton1Click:Connect(function()
        if not selectedConfig then return end
        if not deleteConfirm then
            deleteConfirm = true
            local secs = 3
            deleteBtn.Text = "Are you sure? (" .. secs .. "s)"
            deleteTimerThread = task.spawn(function()
                while secs > 0 do task.wait(1); secs = secs - 1
                    if secs > 0 then deleteBtn.Text = "Are you sure? (" .. secs .. "s)" end
                end
                resetDeleteButtonState()
            end)
        else
            shared.SavedConfigs_Config2[selectedConfig] = nil
            if shared.AutoLoadConfig_Config2 == selectedConfig then saveAutoLoad("None") end
            if isfile and delfile then
                local path = "Configuration2/configs/" .. selectedConfig .. ".json"
                if pcall(isfile, path) then pcall(delfile, path) end
            end
            Notify("Config '" .. selectedConfig .. "' deleted")
            selectedConfig = nil
            loadBtn.Visible = false; overwriteBtn.Visible = false; deleteBtn.Visible = false
            configsDropdownHeader.Text = "▼ Configs"
            resetDeleteButtonState()
            refreshConfigsDropdown()
        end
    end)

    local themeHeader = Instance.new("TextButton")
    themeHeader.Size = UDim2.new(1, -4, 0, 22); themeHeader.BackgroundColor3 = currentTheme.elem; themeHeader.TextColor3 = currentTheme.text
    themeHeader.Font = currentFont; themeHeader.TextSize = 12; themeHeader.Text = "▼ Theme: " .. currentThemeName
    themeHeader.TextXAlignment = Enum.TextXAlignment.Left; themeHeader.AutoButtonColor = false
    themeHeader.Parent = scrollFrame; addCorners(themeHeader, UDim.new(0,4))
    registerElement(themeHeader, "elem"); registerElement(themeHeader, "text")
    themeHeaderRef = themeHeader

    local themeContent = Instance.new("Frame")
    themeContent.Size = UDim2.new(1, -4, 0, 0); themeContent.BackgroundColor3 = currentTheme.elem
    themeContent.BorderSizePixel = 0; themeContent.ClipsDescendants = true; themeContent.Parent = scrollFrame
    addCorners(themeContent, UDim.new(0,4)); registerElement(themeContent, "elem")
    local themeLayout2 = Instance.new("UIListLayout"); themeLayout2.Padding = UDim.new(0, 2); themeLayout2.Parent = themeContent

    local function rebuildThemeOptions()
        for _, child in ipairs(themeContent:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
        local sortedThemes = {}
        for thmName, _ in pairs(themes) do table.insert(sortedThemes, thmName) end
        table.sort(sortedThemes)
        for _, thmName in ipairs(sortedThemes) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, -4, 0, 18); optBtn.BackgroundColor3 = currentTheme.sliderBar; optBtn.TextColor3 = currentTheme.text
            optBtn.Font = currentFont; optBtn.TextSize = 11; optBtn.Text = thmName; optBtn.AutoButtonColor = false
            optBtn.Parent = themeContent; addCorners(optBtn, UDim.new(0,3))
            registerElement(optBtn, "sliderBar"); registerElement(optBtn, "text")
            optBtn.MouseButton1Click:Connect(function() applyTheme(thmName); rebuildThemeOptions(); Notify("Theme: " .. thmName) end)
        end
    end
    rebuildThemeOptions()

    local themeOpen = false
    themeHeader.MouseButton1Click:Connect(function()
        themeOpen = not themeOpen
        if themeOpen then
            local count = 0; for _ in pairs(themes) do count = count + 1 end
            TweenService:Create(themeContent, TweenInfo.new(0.3), {Size = UDim2.new(1, -4, 0, count * 20 + 10)}):Play()
        else
            TweenService:Create(themeContent, TweenInfo.new(0.3), {Size = UDim2.new(1, -4, 0, 0)}):Play()
        end
    end)

    local fontHeader = Instance.new("TextButton")
    fontHeader.Size = UDim2.new(1, -4, 0, 22); fontHeader.BackgroundColor3 = currentTheme.elem; fontHeader.TextColor3 = currentTheme.text
    fontHeader.Font = currentFont; fontHeader.TextSize = 12; fontHeader.Text = "▼ Font: " .. currentFontName
    fontHeader.TextXAlignment = Enum.TextXAlignment.Left; fontHeader.AutoButtonColor = false
    fontHeader.Parent = scrollFrame; addCorners(fontHeader, UDim.new(0,4))
    registerElement(fontHeader, "elem"); registerElement(fontHeader, "text")
    fontHeaderRef = fontHeader

    local fontContent = Instance.new("Frame")
    fontContent.Size = UDim2.new(1, -4, 0, 0); fontContent.BackgroundColor3 = currentTheme.elem
    fontContent.BorderSizePixel = 0; fontContent.ClipsDescendants = true; fontContent.Parent = scrollFrame
    addCorners(fontContent, UDim.new(0,4)); registerElement(fontContent, "elem")
    local fontLayout = Instance.new("UIListLayout"); fontLayout.Padding = UDim.new(0, 2); fontLayout.Parent = fontContent

    local function rebuildFontOptions()
        for _, child in ipairs(fontContent:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
        for _, fName in ipairs(availableFonts) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, -4, 0, 18); optBtn.BackgroundColor3 = currentTheme.sliderBar; optBtn.TextColor3 = currentTheme.text
            optBtn.Font = currentFont; optBtn.TextSize = 11; optBtn.Text = fName; optBtn.AutoButtonColor = false
            optBtn.Parent = fontContent; addCorners(optBtn, UDim.new(0,3))
            registerElement(optBtn, "sliderBar"); registerElement(optBtn, "text")
            optBtn.MouseButton1Click:Connect(function() applyFont(fName); rebuildFontOptions(); Notify("Font: " .. fName) end)
        end
    end
    rebuildFontOptions()

    local fontOpen = false
    fontHeader.MouseButton1Click:Connect(function()
        fontOpen = not fontOpen
        if fontOpen then
            TweenService:Create(fontContent, TweenInfo.new(0.3), {Size = UDim2.new(1, -4, 0, #availableFonts * 20 + 10)}):Play()
        else
            TweenService:Create(fontContent, TweenInfo.new(0.3), {Size = UDim2.new(1, -4, 0, 0)}):Play()
        end
    end)

    do
        local row = Instance.new("Frame"); row.Size = UDim2.new(1, -4, 0, 22); row.BackgroundTransparency = 1; row.Parent = scrollFrame
        local label = Instance.new("TextLabel"); label.Size = UDim2.new(1, -28, 1, 0); label.Position = UDim2.new(0, 4, 0, 0); label.BackgroundTransparency = 1
        label.TextColor3 = currentTheme.text; label.Font = currentFont; label.TextSize = 11; label.Text = "Hide Notifications"
        label.TextXAlignment = Enum.TextXAlignment.Left; label.Parent = row; registerElement(label, "text")
        local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0,18,0,18); btn.Position = UDim2.new(1,-22,0.5,-9)
        btn.BackgroundColor3 = currentTheme.toggleOff; btn.Text = ""; btn.AutoButtonColor = false; btn.BorderSizePixel = 0; btn.Parent = row
        addCorners(btn, UDim.new(1,0))
        registerElement(btn, "toggleOff")
        local tick = Instance.new("TextLabel"); tick.Size = UDim2.new(1,0,1,0); tick.BackgroundTransparency = 1
        tick.Text = "✓"; tick.TextColor3 = Color3.fromRGB(0,0,0); tick.Font = Enum.Font.GothamBold; tick.TextSize = 13; tick.Visible = false; tick.Parent = btn
        hideNotifsToggle.state = false
        function hideNotifsToggle.SetState(val)
            hideNotifsToggle.state = val
            if val then
                btn.BackgroundColor3 = currentTheme.accent; tick.Visible = true
                local c = CoreGui:FindFirstChild("RobloxNotifierContainer"); if c then c.Enabled = false end
            else
                btn.BackgroundColor3 = currentTheme.toggleOff; tick.Visible = false
                local c = CoreGui:FindFirstChild("RobloxNotifierContainer"); if c then c.Enabled = true end
            end
        end
        btn.MouseButton1Click:Connect(function() hideNotifsToggle.SetState(not hideNotifsToggle.state) end)
    end

    do
        local row = Instance.new("Frame"); row.Size = UDim2.new(1, -4, 0, 22); row.BackgroundTransparency = 1; row.Parent = scrollFrame
        local label = Instance.new("TextLabel"); label.Size = UDim2.new(1, -28, 1, 0); label.Position = UDim2.new(0, 4, 0, 0); label.BackgroundTransparency = 1
        label.TextColor3 = currentTheme.text; label.Font = currentFont; label.TextSize = 11; label.Text = "Hide Stats"
        label.TextXAlignment = Enum.TextXAlignment.Left; label.Parent = row; registerElement(label, "text")
        local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0,18,0,18); btn.Position = UDim2.new(1,-22,0.5,-9)
        btn.BackgroundColor3 = currentTheme.toggleOff; btn.Text = ""; btn.AutoButtonColor = false; btn.BorderSizePixel = 0; btn.Parent = row
        addCorners(btn, UDim.new(1,0))
        registerElement(btn, "toggleOff")
        local tick = Instance.new("TextLabel"); tick.Size = UDim2.new(1,0,1,0); tick.BackgroundTransparency = 1
        tick.Text = "✓"; tick.TextColor3 = Color3.fromRGB(0,0,0); tick.Font = Enum.Font.GothamBold; tick.TextSize = 13; tick.Visible = false; tick.Parent = btn
        hideStatsToggle.state = false
        function hideStatsToggle.SetState(val)
            hideStatsToggle.state = val
            if val then
                btn.BackgroundColor3 = currentTheme.accent; tick.Visible = true
                statsGui.Enabled = false
            else
                btn.BackgroundColor3 = currentTheme.toggleOff; tick.Visible = false
                statsGui.Enabled = true
            end
        end
        btn.MouseButton1Click:Connect(function() hideStatsToggle.SetState(not hideStatsToggle.state) end)
    end

    do
        local row = Instance.new("Frame"); row.Size = UDim2.new(1, -4, 0, 22); row.BackgroundTransparency = 1; row.Parent = scrollFrame
        local label = Instance.new("TextLabel"); label.Size = UDim2.new(1, -28, 1, 0); label.Position = UDim2.new(0, 4, 0, 0); label.BackgroundTransparency = 1
        label.TextColor3 = currentTheme.text; label.Font = currentFont; label.TextSize = 11; label.Text = "Hide Button"
        label.TextXAlignment = Enum.TextXAlignment.Left; label.Parent = row; registerElement(label, "text")
        local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0,18,0,18); btn.Position = UDim2.new(1,-22,0.5,-9)
        btn.BackgroundColor3 = currentTheme.toggleOff; btn.Text = ""; btn.AutoButtonColor = false; btn.BorderSizePixel = 0; btn.Parent = row
        addCorners(btn, UDim.new(1,0))
        registerElement(btn, "toggleOff")
        local tick = Instance.new("TextLabel"); tick.Size = UDim2.new(1,0,1,0); tick.BackgroundTransparency = 1
        tick.Text = "✓"; tick.TextColor3 = Color3.fromRGB(0,0,0); tick.Font = Enum.Font.GothamBold; tick.TextSize = 13; tick.Visible = false; tick.Parent = btn
        hideButtonToggle.state = false
        function hideButtonToggle.SetState(val)
            hideButtonToggle.state = val
            if val then
                btn.BackgroundColor3 = currentTheme.accent; tick.Visible = true
                toggleBtn.BackgroundTransparency = 1; toggleBtn.TextTransparency = 1
            else
                btn.BackgroundColor3 = currentTheme.toggleOff; tick.Visible = false
                toggleBtn.BackgroundTransparency = 0; toggleBtn.TextTransparency = 0
            end
        end
        btn.MouseButton1Click:Connect(function() hideButtonToggle.SetState(not hideButtonToggle.state) end)
    end

    local autoLoadHeader = Instance.new("TextButton")
    autoLoadHeader.Size = UDim2.new(1, -4, 0, 22); autoLoadHeader.BackgroundColor3 = currentTheme.elem; autoLoadHeader.TextColor3 = currentTheme.text
    autoLoadHeader.Font = currentFont; autoLoadHeader.TextSize = 12; autoLoadHeader.Text = "▼ Auto Load: " .. shared.AutoLoadConfig_Config2
    autoLoadHeader.TextXAlignment = Enum.TextXAlignment.Left; autoLoadHeader.AutoButtonColor = false
    autoLoadHeader.Parent = scrollFrame; addCorners(autoLoadHeader, UDim.new(0,4))
    registerElement(autoLoadHeader, "elem"); registerElement(autoLoadHeader, "text")

    local autoLoadContent = Instance.new("Frame")
    autoLoadContent.Size = UDim2.new(1, -4, 0, 0); autoLoadContent.BackgroundColor3 = currentTheme.elem
    autoLoadContent.BorderSizePixel = 0; autoLoadContent.ClipsDescendants = true; autoLoadContent.Parent = scrollFrame
    addCorners(autoLoadContent, UDim.new(0,4)); registerElement(autoLoadContent, "elem")
    local autoLoadLayout2 = Instance.new("UIListLayout"); autoLoadLayout2.Padding = UDim.new(0, 2); autoLoadLayout2.Parent = autoLoadContent

    local autoLoadOpen = false
    local function rebuildAutoLoadOptions()
        for _, child in ipairs(autoLoadContent:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
        local optionsList = {"None"}
        for name, _ in pairs(shared.SavedConfigs_Config2) do table.insert(optionsList, name) end
        table.sort(optionsList)
        for _, name in ipairs(optionsList) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, -4, 0, 18); optBtn.BackgroundColor3 = currentTheme.sliderBar; optBtn.TextColor3 = currentTheme.text
            optBtn.Font = currentFont; optBtn.TextSize = 11; optBtn.Text = name; optBtn.AutoButtonColor = false
            optBtn.Parent = autoLoadContent; addCorners(optBtn, UDim.new(0,3))
            registerElement(optBtn, "sliderBar"); registerElement(optBtn, "text")
            optBtn.MouseButton1Click:Connect(function()
                saveAutoLoad(name); autoLoadHeader.Text = "▼ Auto Load: " .. name
                Notify("Auto Load: " .. name); autoLoadOpen = false
                TweenService:Create(autoLoadContent, TweenInfo.new(0.3), {Size = UDim2.new(1, -4, 0, 0)}):Play()
            end)
        end
    end

    updateAutoLoadDropdownHeight = function()
        rebuildAutoLoadOptions()
        if autoLoadOpen then
            local count = 0; for _ in ipairs(autoLoadContent:GetChildren()) do count = count + 1 end
            autoLoadContent.Size = UDim2.new(1, -4, 0, count * 20 + 10)
        end
    end

    autoLoadHeader.MouseButton1Click:Connect(function()
        autoLoadOpen = not autoLoadOpen
        if autoLoadOpen then
            rebuildAutoLoadOptions()
            local count = 0; for _ in ipairs(autoLoadContent:GetChildren()) do count = count + 1 end
            TweenService:Create(autoLoadContent, TweenInfo.new(0.3), {Size = UDim2.new(1, -4, 0, count * 20 + 10)}):Play()
        else
            TweenService:Create(autoLoadContent, TweenInfo.new(0.3), {Size = UDim2.new(1, -4, 0, 0)}):Play()
        end
    end)

    local adminBtn = Instance.new("TextButton")
    adminBtn.Size = UDim2.new(1, -4, 0, 22); adminBtn.BackgroundColor3 = currentTheme.elem; adminBtn.TextColor3 = currentTheme.text
    adminBtn.Font = currentFont; adminBtn.TextSize = 12; adminBtn.Text = "Open Admin Panel"; adminBtn.AutoButtonColor = false
    adminBtn.Parent = scrollFrame; addCorners(adminBtn, UDim.new(0,4))
    registerElement(adminBtn, "elem"); registerElement(adminBtn, "text")
    adminBtn.MouseButton1Click:Connect(showAdminPanel)

    task.spawn(function()
        refreshConfigsDropdown()
        autoLoadHeader.Text = "▼ Auto Load: " .. shared.AutoLoadConfig_Config2
        if shared.AutoLoadConfig_Config2 ~= "None" then
            local cfg = shared.SavedConfigs_Config2[shared.AutoLoadConfig_Config2]
            if cfg then runLoadLogic(shared.AutoLoadConfig_Config2); Notify("Auto-loaded: " .. shared.AutoLoadConfig_Config2) end
        end
    end)
end

-- ======================================================================
-- VOID SPAM & ORBIT BACKEND
-- ======================================================================
local voidSpamEnabled = false
local currentTarget = nil
local currentCycleState = "Idle"
local spinConstraint = nil
local aimbotConnection = nil
local safeY = Workspace.FallenPartsDestroyHeight or -500

local spawnCamLocked = false
local spawnCamCFrame = nil
local cameraLockConnection = nil
local camPitch = 0
local camYaw = 0
local camPos = Vector3.new()

local voidConfig = {
    voidDepth = 150,
    voidRetention = 0.5,
    contactDuration = 0.3,
    targetMode = "Manual Select",
    manualTargetName = nil,
    maxDistance = 1000,
}

local orbitEnabled = false
local orbitConnection = nil
local orbitConfig = {
    mode = "Target Lock",
    speed = 50,
    range = 3,
    antiAim = true
}

local function getTeamPlayers()
    local myTeam = LocalPlayer.Team
    if not myTeam then return {} end
    local teamPlayers = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team == myTeam then teamPlayers[player] = true end
    end
    return teamPlayers
end
local function isTeammate(player)
    local teamPlayers = getTeamPlayers()
    return teamPlayers[player] == true
end
local function getValidTargets()
    local targets = {}
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return targets end
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if isTeammate(player) then continue end
        local char = player.Character
        if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        local dist = (root.Position - myRoot.Position).Magnitude
        if dist <= voidConfig.maxDistance then
            table.insert(targets, player)
        end
    end
    return targets
end
local function findClosestTarget()
    local targets = getValidTargets()
    if #targets == 0 then return nil end
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myPos then return nil end
    local closest, closestDist = nil, math.huge
    for _, player in ipairs(targets) do
        local root = player.Character.HumanoidRootPart
        local dist = (root.Position - myPos.Position).Magnitude
        if dist < closestDist then
            closestDist = dist; closest = player
        end
    end
    return closest
end
local function findAttacker()
    local targets = getValidTargets()
    if #targets == 0 then return nil end
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myPos then return nil end
    local closest, closestDist = nil, math.huge
    for _, player in ipairs(targets) do
        local root = player.Character.HumanoidRootPart
        local dist = (root.Position - myPos.Position).Magnitude
        if dist < closestDist then
            closestDist = dist; closest = player
        end
    end
    return closest
end
local function findVoidTarget()
    local targets = getValidTargets()
    for _, player in ipairs(targets) do
        local root = player.Character.HumanoidRootPart
        if root and root.Position.Y < -50 then return player end
    end
    return nil
end
local function getTargetByPriority()
    if voidConfig.targetMode == "Manual Select" then
        if voidConfig.manualTargetName then
            local p = Players:FindFirstChild(voidConfig.manualTargetName)
            if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then return p end
        end
        return findVoidTarget() or findAttacker() or findClosestTarget()
    elseif voidConfig.targetMode == "Void Target" then
        return findVoidTarget() or findAttacker() or findClosestTarget()
    elseif voidConfig.targetMode == "Attacker Priority" then
        return findAttacker() or findClosestTarget()
    end
    return findClosestTarget()
end

local healthChangedConnection = nil
local function setupHealthListener()
    if healthChangedConnection then healthChangedConnection:Disconnect() end
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    local previousHealth = humanoid.Health
    healthChangedConnection = humanoid.HealthChanged:Connect(function(newHealth)
        if newHealth < previousHealth then
            if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
                local root = currentTarget.Character.HumanoidRootPart
                local voidY = root.Position.Y - 500
                if voidY < safeY + 10 then voidY = safeY + 10 end
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(root.Position.X, voidY, root.Position.Z)
                end
            end
        end
        previousHealth = newHealth
    end)
end
local function cleanupHealthListener()
    if healthChangedConnection then healthChangedConnection:Disconnect(); healthChangedConnection = nil end
end

local function onCharacterAdded(character)
    if not voidSpamEnabled and not orbitEnabled then return end
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid and voidSpamEnabled then
        setupHealthListener()
    end
    if spinConstraint then spinConstraint:Destroy(); spinConstraint = nil end
    if spawnCamLocked then
        unlockCamera()
        task.wait(0.1)
        lockCameraAtSpawn()
    end
end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
if LocalPlayer.Character then task.spawn(onCharacterAdded, LocalPlayer.Character) end

local function safeHeadCFrame(target)
    local head = target.Character and target.Character:FindFirstChild("Head")
    if not head then return nil end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, target.Character}
    local headHit = Workspace:Raycast(head.Position, Vector3.new(0,0,0), rayParams)
    if headHit then return nil end
    local cf = head.CFrame * CFrame.new(0, 1.5, 0)
    local downHit = Workspace:Raycast(cf.Position, Vector3.new(0, -3, 0), rayParams)
    local upHit = Workspace:Raycast(cf.Position, Vector3.new(0, 3, 0), rayParams)
    if downHit then cf = cf + Vector3.new(0, 2, 0) end
    if upHit then cf = cf - Vector3.new(0, 2, 0) end
    local directions = {Vector3.new(1,0,0), Vector3.new(-1,0,0), Vector3.new(0,0,1), Vector3.new(0,0,-1)}
    for _, dir in ipairs(directions) do
        local ray = Workspace:Raycast(cf.Position, dir * 2, rayParams)
        if ray then cf = cf - dir * 2 end
    end
    return cf
end

local function startAimbot()
    if spawnCamLocked then return end
    if aimbotConnection then return end
    local camera = Workspace.CurrentCamera
    if not camera then return end
    camera.CameraType = Enum.CameraType.Custom
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if not voidSpamEnabled or not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("Head") then
            stopAimbot()
            return
        end
        camera.CameraSubject = currentTarget.Character:FindFirstChild("Humanoid") or currentTarget.Character
        local headPart = currentTarget.Character:FindFirstChild("HeadHB") or currentTarget.Character:FindFirstChild("Head")
        if headPart then
            local pos, onScreen = camera:WorldToViewportPoint(headPart.Position)
            if onScreen then
                local mouseLoc = UserInputService:GetMouseLocation()
                local deltaX = (pos.X - mouseLoc.X) * 0.4
                local deltaY = (pos.Y - mouseLoc.Y) * 0.4
                if mousemoverel then
                    mousemoverel(deltaX, deltaY)
                end
            end
        end
    end)
end
local function stopAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
    local camera = Workspace.CurrentCamera
    if camera and not spawnCamLocked then
        camera.CameraType = Enum.CameraType.Custom
        camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    end
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end

local function teleportTo(cframe)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = cframe end
end

local function startSpin()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if spinConstraint then spinConstraint:Destroy() end
    spinConstraint = Instance.new("AlignOrientation")
    spinConstraint.RigidityEnabled = true
    spinConstraint.MaxAngularVelocity = math.huge
    spinConstraint.MaxTorque = math.huge
    spinConstraint.PrimaryAxisOnly = false
    spinConstraint.Parent = hrp
    hrp.AssemblyAngularVelocity = Vector3.new(0, 200000, 0)
end
local function stopSpin()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if spinConstraint then spinConstraint:Destroy(); spinConstraint = nil end
    if hrp then hrp.AssemblyAngularVelocity = Vector3.zero end
end

local orbitDirection = 1
local lastDirectionChange = 0
local lastSpeedChange = 0
local currentSpeed = orbitConfig.speed

local function doOrbitFrame(target, dt)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local root = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if tick() - lastSpeedChange > 0.2 then
        currentSpeed = orbitConfig.speed * (0.6 + math.random() * 0.8)
        lastSpeedChange = tick()
    end

    if tick() - lastDirectionChange > 0.2 + math.random() * 0.4 then
        orbitDirection = -orbitDirection
        lastDirectionChange = tick()
    end

    local angle = (tick() * currentSpeed * orbitDirection) % (math.pi * 2)
    local range = orbitConfig.range

    local teleportOffset = Vector3.new(math.random()*10-5, math.random()*6-3, math.random()*10-5)
    local yBounce = math.sin(tick() * 30) * 2

    local targetPos = root.Position
    local orbitPos = targetPos + Vector3.new(math.cos(angle) * range, yBounce, math.sin(angle) * range) + teleportOffset

    hrp.CFrame = CFrame.new(orbitPos)
    if orbitConfig.antiAim then
        hrp.CFrame = CFrame.new(orbitPos) * CFrame.Angles(math.random()*math.pi*2, math.random()*math.pi*2, math.random()*math.pi*2)
    else
        local lookAt = CFrame.lookAt(orbitPos, targetPos)
        hrp.CFrame = lookAt
    end
end

local function startStandaloneOrbit()
    if orbitConnection then return end
    Notify("Orbit started")
    lockCameraAtSpawn()
    orbitConnection = RunService.RenderStepped:Connect(function(dt)
        if not orbitEnabled then return end
        local target = (voidSpamEnabled and currentTarget) or getTargetByPriority()
        if target then
            doOrbitFrame(target, dt)
        end
    end)
end
local function stopStandaloneOrbit()
    if orbitConnection then
        orbitConnection:Disconnect()
        orbitConnection = nil
    end
    Notify("Orbit stopped")
    unlockCamera()
end

local function onOrbitToggle(enabled)
    orbitEnabled = enabled
    if enabled then
        if not voidSpamEnabled then
            startStandaloneOrbit()
        end
    else
        stopStandaloneOrbit()
    end
end

local function lockCameraAtSpawn()
    if spawnCamLocked then return end
    local camera = Workspace.CurrentCamera
    if not camera then return end
    spawnCamCFrame = camera.CFrame
    camPitch, camYaw = 0, 0
    camPos = spawnCamCFrame.Position
    camera.CameraType = Enum.CameraType.Scriptable
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    spawnCamLocked = true

    local moveSpeed = 50
    local keys = {}

    local inputBeganCon = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        keys[input.KeyCode] = true
    end)
    local inputEndedCon = UserInputService.InputEnded:Connect(function(input)
        keys[input.KeyCode] = nil
    end)

    cameraLockConnection = RunService.RenderStepped:Connect(function(dt)
        if not spawnCamLocked then
            inputBeganCon:Disconnect()
            inputEndedCon:Disconnect()
            return
        end

        local delta = UserInputService:GetMouseDelta()
        camPitch = math.clamp(camPitch - delta.Y * 0.003, -math.pi/2, math.pi/2)
        camYaw = camYaw - delta.X * 0.003

        local rotYaw = CFrame.Angles(0, camYaw, 0)
        local rotPitch = CFrame.Angles(camPitch, 0, 0)
        local rotCFrame = rotYaw * rotPitch

        local moveDir = Vector3.new()
        if keys[Enum.KeyCode.W] or keys[Enum.KeyCode.Up] then
            moveDir = moveDir + rotCFrame.LookVector
        end
        if keys[Enum.KeyCode.S] or keys[Enum.KeyCode.Down] then
            moveDir = moveDir - rotCFrame.LookVector
        end
        if keys[Enum.KeyCode.A] or keys[Enum.KeyCode.Left] then
            moveDir = moveDir - rotCFrame.RightVector
        end
        if keys[Enum.KeyCode.D] or keys[Enum.KeyCode.Right] then
            moveDir = moveDir + rotCFrame.RightVector
        end
        if keys[Enum.KeyCode.Space] then
            moveDir = moveDir + Vector3.new(0,1,0)
        end
        if keys[Enum.KeyCode.LeftShift] or keys[Enum.KeyCode.RightShift] then
            moveDir = moveDir - Vector3.new(0,1,0)
        end
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit * moveSpeed * dt
            camPos = camPos + moveDir
        end

        camera.CFrame = CFrame.new(camPos) * rotCFrame
    end)
end

local function unlockCamera()
    if not spawnCamLocked then return end
    spawnCamLocked = false
    if cameraLockConnection then
        cameraLockConnection:Disconnect()
        cameraLockConnection = nil
    end
    local camera = Workspace.CurrentCamera
    if camera then
        camera.CameraType = Enum.CameraType.Custom
        camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    end
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end

local loopThread = nil
local function voidSpamLoop()
    while voidSpamEnabled do
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            task.wait(0.2) continue
        end
        local target = getTargetByPriority()
        currentTarget = target
        if not target or not target.Character or not target.Character:FindFirstChild("Head") then
            currentCycleState = "Searching"
            task.wait(0.1) continue
        end
        local root = target.Character:FindFirstChild("HumanoidRootPart")
        if not root then task.wait(0.1) continue end

        currentCycleState = "In Void"
        local voidY = root.Position.Y - voidConfig.voidDepth
        if voidY < safeY + 10 then voidY = safeY + 10 end
        local voidCFrame = CFrame.new(root.Position.X, voidY, root.Position.Z)
        teleportTo(voidCFrame)
        task.wait(voidConfig.voidRetention)

        local headCFrame = safeHeadCFrame(target)
        if headCFrame then
            currentCycleState = "On Enemy Head"
            teleportTo(headCFrame)
            if orbitEnabled then
                local orbitEnd = tick() + voidConfig.contactDuration
                local orbitConn = RunService.RenderStepped:Connect(function()
                    if not voidSpamEnabled then orbitConn:Disconnect() return end
                    if tick() >= orbitEnd then orbitConn:Disconnect() return end
                    if currentTarget then doOrbitFrame(currentTarget, task.wait()) end
                end)
                task.wait(voidConfig.contactDuration)
                orbitConn:Disconnect()
            else
                startSpin()
                if not tabHeld then startAimbot() end
                local elapsed = 0
                while elapsed < voidConfig.contactDuration do
                    if not voidSpamEnabled then break end
                    local valid = currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Head")
                    if not valid then break end
                    local newCF = safeHeadCFrame(currentTarget)
                    if newCF then teleportTo(newCF) else break end
                    task.wait(0.05)
                    elapsed = elapsed + 0.05
                end
                stopSpin()
                stopAimbot()
            end
        else
            currentCycleState = "Searching"
            task.wait(0.1)
        end
    end
    stopSpin()
    stopAimbot()
    unlockCamera()
    currentCycleState = "Idle"
    currentTarget = nil
end

local function startVoidSpam()
    if voidSpamEnabled then return end
    voidSpamEnabled = true
    lockCameraAtSpawn()
    setupHealthListener()
    loopThread = task.spawn(voidSpamLoop)
    if orbitEnabled then stopStandaloneOrbit() end
    if not orbitEnabled and not tabHeld and currentTarget then startAimbot() end
end
local function stopVoidSpam()
    voidSpamEnabled = false
    cleanupHealthListener()
    stopSpin()
    stopAimbot()
    if loopThread then task.cancel(loopThread); loopThread = nil end
    unlockCamera()
    currentCycleState = "Idle"
    if orbitEnabled then startStandaloneOrbit() end
end

-- ===== Stats Panel =====
local statsPanel = nil
local function toggleStatsPanel()
    if statsPanel then statsPanel.Visible = not statsPanel.Visible return end
    local statsGui2 = Instance.new("ScreenGui")
    statsGui2.Name = "VoidStatsGui"; statsGui2.ResetOnSpawn = false; statsGui2.Parent = CoreGui; statsGui2.DisplayOrder = 100
    statsPanel = Instance.new("Frame")
    statsPanel.Size = UDim2.new(0, 200, 0, 110)
    statsPanel.Position = UDim2.new(0, 10, 0.5, -55)
    statsPanel.BackgroundColor3 = currentTheme.bg
    statsPanel.BorderSizePixel = 0; statsPanel.Visible = true; statsPanel.Parent = statsGui2
    addCorners(statsPanel, UDim.new(0,6)); registerElement(statsPanel, "bg")
    local uistroke = Instance.new("UIStroke", statsPanel); uistroke.Color = currentTheme.border; uistroke.Thickness = 1.5; registerElement(uistroke, "border")
    local title = Instance.new("TextLabel"); title.Size = UDim2.new(1, -8, 0, 20); title.Position = UDim2.new(0,4,0,4); title.BackgroundTransparency = 1
    title.TextColor3 = currentTheme.text; title.Font = currentFont; title.TextSize = 13; title.Text = "Void Spam Stats"
    title.TextXAlignment = Enum.TextXAlignment.Center; title.Parent = statsPanel; registerElement(title, "text")
    local distLabel = Instance.new("TextLabel"); distLabel.Size = UDim2.new(1, -8, 0, 18); distLabel.Position = UDim2.new(0,4,0,26); distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = currentTheme.text; distLabel.Font = currentFont; distLabel.TextSize = 12; distLabel.Text = "Distance: --"
    distLabel.Parent = statsPanel; registerElement(distLabel, "text")
    local stateLabel = Instance.new("TextLabel"); stateLabel.Size = UDim2.new(1, -8, 0, 18); stateLabel.Position = UDim2.new(0,4,0,46); stateLabel.BackgroundTransparency = 1
    stateLabel.TextColor3 = currentTheme.text; stateLabel.Font = currentFont; stateLabel.TextSize = 12; stateLabel.Text = "State: Idle"
    stateLabel.Parent = statsPanel; registerElement(stateLabel, "text")
    local targetLabel = Instance.new("TextLabel"); targetLabel.Size = UDim2.new(1, -8, 0, 18); targetLabel.Position = UDim2.new(0,4,0,66); targetLabel.BackgroundTransparency = 1
    targetLabel.TextColor3 = currentTheme.text; targetLabel.Font = currentFont; targetLabel.TextSize = 12; targetLabel.Text = "Target: None"
    targetLabel.Parent = statsPanel; registerElement(targetLabel, "text")
    local draggingPanel, dragStartPanel, startPosPanel
    statsPanel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingPanel = true; dragStartPanel = input.Position; startPosPanel = statsPanel.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then draggingPanel = false end end)
        end
    end)
    statsPanel.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if draggingPanel then
                local delta = input.Position - dragStartPanel
                statsPanel.Position = UDim2.new(startPosPanel.X.Scale, startPosPanel.X.Offset + delta.X, startPosPanel.Y.Scale, startPosPanel.Y.Offset + delta.Y)
            end
        end
    end)
    task.spawn(function()
        while statsPanel and statsPanel.Parent do
            local dist = "N/A"
            if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                dist = string.format("%.1f Studs", (LocalPlayer.Character.HumanoidRootPart.Position - currentTarget.Character.HumanoidRootPart.Position).Magnitude)
            end
            distLabel.Text = "Distance: " .. dist
            stateLabel.Text = "State: " .. currentCycleState
            targetLabel.Text = "Target: " .. (currentTarget and currentTarget.Name or "None")
            task.wait(0.2)
        end
    end)
end

-- ===== Modern Slider =====
local function createModernSlider(parent, name, min, max, default, callback)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1, -4, 0, 45); row.BackgroundTransparency = 1; row.Parent = parent
    local label = Instance.new("TextLabel"); label.Size = UDim2.new(0, 120, 0, 18); label.Position = UDim2.new(0,0,0,0); label.BackgroundTransparency = 1
    label.TextColor3 = currentTheme.text; label.Font = currentFont; label.TextSize = 11; label.Text = name; label.TextXAlignment = Enum.TextXAlignment.Left; label.Parent = row
    local valLabel = Instance.new("TextLabel"); valLabel.Size = UDim2.new(0, 60, 0, 18); valLabel.Position = UDim2.new(1, -60, 0, 0); valLabel.BackgroundTransparency = 1
    valLabel.TextColor3 = currentTheme.text; valLabel.Font = currentFont; valLabel.TextSize = 11; valLabel.Text = tostring(default); valLabel.TextXAlignment = Enum.TextXAlignment.Right; valLabel.Parent = row
    local track = Instance.new("Frame"); track.Size = UDim2.new(1, 0, 0, 8); track.Position = UDim2.new(0,0,0,22); track.BackgroundColor3 = currentTheme.sliderBar; track.BorderSizePixel = 0; track.Parent = row
    addCorners(track, UDim.new(0,4)); registerElement(track, "sliderBar")
    local fill = Instance.new("Frame"); fill.Size = UDim2.new(0, 0, 1, 0); fill.BackgroundColor3 = currentTheme.accent; fill.BorderSizePixel = 0; fill.Parent = track
    addCorners(fill, UDim.new(0,4))
    local knob = Instance.new("TextButton"); knob.Size = UDim2.new(0, 16, 0, 16); knob.Position = UDim2.new(0, 0, 0.5, -8); knob.BackgroundColor3 = currentTheme.text; knob.Text = ""
    knob.AutoButtonColor = false; knob.BorderSizePixel = 0; knob.Parent = track; addCorners(knob, UDim.new(1,0)); knob.ZIndex = 2
    local range = max - min
    local function updateValue(frac)
        local val = min + frac * range
        val = math.clamp(math.round(val * 100) / 100, min, max)
        valLabel.Text = tostring(val)
        fill.Size = UDim2.new(frac, 0, 1, 0)
        knob.Position = UDim2.new(frac, -8, 0.5, -8)
        callback(val)
    end
    updateValue((default - min) / range)
    local draggingKnob = false
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingKnob = true
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then draggingKnob = false end end)
        end
    end)
    knob.InputChanged:Connect(function(input)
        if not draggingKnob then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local relX = math.clamp(input.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
            local frac = relX / track.AbsoluteSize.X
            updateValue(frac)
        end
    end)
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local relX = math.clamp(input.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
            local frac = relX / track.AbsoluteSize.X
            updateValue(frac)
            draggingKnob = true
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then draggingKnob = false end end)
        end
    end)
end

-- ======================================================================
-- ESP BACKEND (with fill transparency & outline thickness)
-- ======================================================================
if Drawing then
    ESP = {
        Enabled = false,
        ChamsEnabled = false,
        OutlineEnabled = false,
        TracerEnabled = false,
        HealthBarEnabled = false,
        DistanceEnabled = false,
        TeamCheck = true,
        FOVEnabled = false,
        FOVSize = 100,
        FOVColor = Color3.new(1, 0, 0),
        FOVFilled = false,
        FOVFillColor = Color3.new(1, 0, 0),
        FOVFillTransparency = 0.5,
        FOVOutlineThickness = 2,
        CrosshairEnabled = false,
        CrosshairColor = Color3.new(1, 1, 1),
        CrosshairSize = 15,
        CrosshairSpeed = 2,
        _renderConnection = nil,
        _playerDrawings = {},
        _highlights = {},
        _fovOutlineCircle = nil,
        _fovFillCircle = nil,
        _crossLines = {},
        _angle = 0,
    }

    local Camera = Workspace.CurrentCamera

    local function getTeamPlayerSet()
        local team = LocalPlayer.Team
        if not team then return {} end
        local set = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Team == team then set[p] = true end
        end
        return set
    end

    function ESP.clearAll()
        for _, drawings in pairs(ESP._playerDrawings) do
            for _, d in pairs(drawings) do if d and d.Remove then pcall(function() d:Remove() end) end end
        end
        table.clear(ESP._playerDrawings)
        for _, hl in pairs(ESP._highlights) do if hl then pcall(function() hl:Destroy() end) end end
        table.clear(ESP._highlights)
        if ESP._fovOutlineCircle then pcall(function() ESP._fovOutlineCircle:Remove() end); ESP._fovOutlineCircle = nil end
        if ESP._fovFillCircle then pcall(function() ESP._fovFillCircle:Remove() end); ESP._fovFillCircle = nil end
        for _, line in ipairs(ESP._crossLines) do if line then pcall(function() line:Remove() end) end end
        table.clear(ESP._crossLines)
    end

    function ESP.stopLoop()
        if ESP._renderConnection then ESP._renderConnection:Disconnect(); ESP._renderConnection = nil end
    end

    local function onRenderStep()
        ESP._angle = (ESP._angle + ESP.CrosshairSpeed * 60 / 360) % 360
        local cam = Camera
        if not cam then return end
        local viewportSize = cam.ViewportSize
        local centerX, centerY = viewportSize.X / 2, viewportSize.Y / 2

        if ESP.FOVEnabled then
            if not ESP._fovOutlineCircle then
                ESP._fovOutlineCircle = Drawing.new("Circle")
                ESP._fovOutlineCircle.Visible = true
                ESP._fovOutlineCircle.Filled = false
            end
            local out = ESP._fovOutlineCircle
            out.Position = Vector2.new(centerX, centerY)
            out.Radius = ESP.FOVSize
            out.Color = ESP.FOVColor
            out.Thickness = ESP.FOVOutlineThickness
            if ESP.FOVFilled then
                if not ESP._fovFillCircle then
                    ESP._fovFillCircle = Drawing.new("Circle")
                    ESP._fovFillCircle.Visible = true
                end
                local fill = ESP._fovFillCircle
                fill.Position = Vector2.new(centerX, centerY)
                fill.Radius = ESP.FOVSize
                fill.Color = ESP.FOVFillColor
                fill.Filled = true
                fill.Transparency = 1 - ESP.FOVFillTransparency
            elseif ESP._fovFillCircle then
                ESP._fovFillCircle:Remove()
                ESP._fovFillCircle = nil
            end
        else
            if ESP._fovOutlineCircle then ESP._fovOutlineCircle:Remove(); ESP._fovOutlineCircle = nil end
            if ESP._fovFillCircle then ESP._fovFillCircle:Remove(); ESP._fovFillCircle = nil end
        end

        if ESP.CrosshairEnabled then
            local size = ESP.CrosshairSize
            local angleRad = math.rad(ESP._angle)
            local cosA = math.cos(angleRad)
            local sinA = math.sin(angleRad)
            if #ESP._crossLines ~= 4 then
                for _, line in ipairs(ESP._crossLines) do if line then pcall(function() line:Remove() end) end end
                table.clear(ESP._crossLines)
                for i = 1, 4 do
                    local line = Drawing.new("Line"); line.Visible = false; table.insert(ESP._crossLines, line)
                end
            end
            local dirs = {{x = size, y = 0}, {x = -size, y = 0}, {x = 0, y = size}, {x = 0, y = -size}}
            for i, dir in ipairs(dirs) do
                local line = ESP._crossLines[i]
                if line then
                    local rx = dir.x * cosA - dir.y * sinA
                    local ry = dir.x * sinA + dir.y * cosA
                    line.From = Vector2.new(centerX, centerY)
                    line.To = Vector2.new(centerX + rx, centerY + ry)
                    line.Color = ESP.CrosshairColor
                    line.Thickness = 1.5
                    line.Visible = true
                end
            end
        else
            for _, line in ipairs(ESP._crossLines) do if line then line.Visible = false end end
        end

        local teamSet = ESP.TeamCheck and getTeamPlayerSet() or {}
        local activePlayers = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if ESP.TeamCheck and teamSet[player] then continue end
            local character = player.Character
            if not character then continue end
            local humanoid = character:FindFirstChild("Humanoid")
            if not humanoid or humanoid.Health <= 0 then continue end
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local head = character:FindFirstChild("Head")
            if not rootPart or not head then continue end

            local rootPos, rootOnScreen = cam:WorldToViewportPoint(rootPart.Position)
            local headPos, headOnScreen = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            if not rootOnScreen and not headOnScreen then continue end

            local function clamp(v) return Vector2.new(math.clamp(v.X, 0, viewportSize.X), math.clamp(v.Y, 0, viewportSize.Y)) end
            rootPos = clamp(rootPos)
            headPos = clamp(headPos)
            table.insert(activePlayers, player)

            if not ESP._playerDrawings[player] then ESP._playerDrawings[player] = {} end
            local drawings = ESP._playerDrawings[player]

            if ESP.OutlineEnabled then
                if not drawings.outline then drawings.outline = Drawing.new("Square") end
                local box = drawings.outline
                local topY = headPos.Y
                local bottomY = rootPos.Y
                local height = math.abs(topY - bottomY)
                local width = height * 0.6
                local leftX = (headPos.X + rootPos.X) / 2 - width / 2
                box.Position = Vector2.new(leftX, math.min(topY, bottomY))
                box.Size = Vector2.new(width, height)
                box.Thickness = 2
                box.Color = Color3.new(1,1,1)
                box.Filled = false
                box.Visible = true
            elseif drawings.outline then drawings.outline.Visible = false end

            if ESP.TracerEnabled then
                if not drawings.tracer then drawings.tracer = Drawing.new("Line") end
                local line = drawings.tracer
                line.From = Vector2.new(centerX, viewportSize.Y)
                line.To = Vector2.new(rootPos.X, rootPos.Y)
                line.Color = Color3.new(1,1,1)
                line.Thickness = 1
                line.Visible = true
            elseif drawings.tracer then drawings.tracer.Visible = false end

            if ESP.HealthBarEnabled then
                if not drawings.healthText then drawings.healthText = Drawing.new("Text") end
                local txt = drawings.healthText
                local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                txt.Text = healthPercent .. "%"
                txt.Position = Vector2.new(headPos.X, headPos.Y - 30)
                txt.Size = 14
                txt.Color = Color3.new(1,0,0)
                txt.Center = true
                txt.Outline = true
                txt.Visible = true
            elseif drawings.healthText then drawings.healthText.Visible = false end

            if ESP.DistanceEnabled then
                if not drawings.distText then drawings.distText = Drawing.new("Text") end
                local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    local dist = (rootPart.Position - myRoot.Position).Magnitude
                    local txt = drawings.distText
                    txt.Text = string.format("%.0f m", dist)
                    txt.Position = Vector2.new(headPos.X, headPos.Y - 44)
                    txt.Size = 13
                    txt.Color = Color3.new(1,1,1)
                    txt.Center = true
                    txt.Outline = true
                    txt.Visible = true
                end
            elseif drawings.distText then drawings.distText.Visible = false end

            if ESP.ChamsEnabled then
                if not ESP._highlights[player] then
                    local hl = Instance.new("Highlight")
                    hl.Name = "ESPCham"
                    hl.FillColor = Color3.new(1,0,0)
                    hl.OutlineColor = Color3.new(1,1,1)
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0
                    hl.Parent = character
                    ESP._highlights[player] = hl
                end
                local hl = ESP._highlights[player]
                if hl then hl.Enabled = true; hl.Adornee = character end
            elseif ESP._highlights[player] then ESP._highlights[player].Enabled = false end
        end

        for player, drawings in pairs(ESP._playerDrawings) do
            if not table.find(activePlayers, player) then
                for _, d in pairs(drawings) do pcall(function() d:Remove() end) end
                ESP._playerDrawings[player] = nil
                if ESP._highlights[player] then ESP._highlights[player]:Destroy(); ESP._highlights[player] = nil end
            end
        end
    end

    function ESP.updateConfig()
        ESP.stopLoop()
        ESP.clearAll()
        if ESP.Enabled then
            ESP._renderConnection = RunService.RenderStepped:Connect(onRenderStep)
            if ESP.ChamsEnabled then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        local char = player.Character
                        if char and char:FindFirstChild("Humanoid") then
                            if not ESP._highlights[player] then
                                local hl = Instance.new("Highlight")
                                hl.Name = "ESPCham"
                                hl.FillColor = Color3.new(1,0,0)
                                hl.OutlineColor = Color3.new(1,1,1)
                                hl.FillTransparency = 0.5
                                hl.OutlineTransparency = 0
                                hl.Parent = char
                                ESP._highlights[player] = hl
                            end
                        end
                    end
                end
            end
        end
    end

    Players.PlayerRemoving:Connect(function(player)
        if ESP._playerDrawings[player] then
            for _, d in pairs(ESP._playerDrawings[player]) do pcall(function() d:Remove() end) end
            ESP._playerDrawings[player] = nil
        end
        if ESP._highlights[player] then ESP._highlights[player]:Destroy(); ESP._highlights[player] = nil end
    end)

    ESP.updateConfig()
else
    warn("Drawing library not found. ESP disabled.")
end

-- ======================================================================
-- BUILD VOID SPAM UI (FINAL FIX: completely clear & rebuild)
-- ======================================================================
local function setupVoidSpamUI()
    local voidMenu = nil
    for _, info in ipairs(menuInfos) do if info.name == "Void spam" then voidMenu = info.frame; break end end
    if not voidMenu then return end

    local mainScroll = Instance.new("ScrollingFrame")
    mainScroll.Size = UDim2.new(1, -6, 1, -30)
    mainScroll.Position = UDim2.new(0, 3, 0, 26)
    mainScroll.BackgroundColor3 = currentTheme.bg
    mainScroll.BorderSizePixel = 0
    mainScroll.ScrollBarThickness = 3
    mainScroll.CanvasSize = UDim2.new(0,0,0,0)
    mainScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    mainScroll.ZIndex = 1
    mainScroll.Parent = voidMenu
    addCorners(mainScroll, UDim.new(0,6))
    registerElement(mainScroll, "bg")

    local function clearScroll()
        for _, child in ipairs(mainScroll:GetChildren()) do
            pcall(function() child:Destroy() end)
        end
        mainScroll.CanvasSize = UDim2.new(0,0,0,0)
    end

    local function buildVoidControls()
        clearScroll()
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0,4)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = mainScroll

        local toggleRow = Instance.new("Frame"); toggleRow.Size = UDim2.new(1, -4, 0, 22); toggleRow.BackgroundTransparency = 1; toggleRow.Parent = mainScroll
        local toggleLabel = Instance.new("TextLabel"); toggleLabel.Size = UDim2.new(0.7,0,1,0); toggleLabel.Position = UDim2.new(0,4,0,0); toggleLabel.BackgroundTransparency = 1
        toggleLabel.TextColor3 = currentTheme.text; toggleLabel.Font = currentFont; toggleLabel.TextSize = 12; toggleLabel.Text = "Void Spam"
        toggleLabel.TextXAlignment = Enum.TextXAlignment.Left; toggleLabel.Parent = toggleRow
        local toggleBtn2 = Instance.new("TextButton"); toggleBtn2.Size = UDim2.new(0,18,0,18); toggleBtn2.Position = UDim2.new(1,-22,0.5,-9)
        toggleBtn2.BackgroundColor3 = voidSpamEnabled and currentTheme.accent or currentTheme.toggleOff
        toggleBtn2.Text = ""; toggleBtn2.AutoButtonColor = false; toggleBtn2.BorderSizePixel = 0; toggleBtn2.Parent = toggleRow
        addCorners(toggleBtn2, UDim.new(1,0))
        local toggleTick = Instance.new("TextLabel"); toggleTick.Size = UDim2.new(1,0,1,0); toggleTick.BackgroundTransparency = 1
        toggleTick.Text = "✓"; toggleTick.TextColor3 = Color3.fromRGB(0,0,0); toggleTick.Font = Enum.Font.GothamBold; toggleTick.TextSize = 13
        toggleTick.Visible = voidSpamEnabled; toggleTick.Parent = toggleBtn2
        toggleBtn2.MouseButton1Click:Connect(function()
            if voidSpamEnabled then
                toggleBtn2.BackgroundColor3 = currentTheme.toggleOff; toggleTick.Visible = false
                stopVoidSpam()
            else
                toggleBtn2.BackgroundColor3 = currentTheme.accent; toggleTick.Visible = true
                startVoidSpam()
            end
        end)

        createModernSlider(mainScroll, "Void Depth", 50, 500, voidConfig.voidDepth, function(v) voidConfig.voidDepth = v end)
        createModernSlider(mainScroll, "Void Retention (s)", 0.1, 5, voidConfig.voidRetention, function(v) voidConfig.voidRetention = v end)
        createModernSlider(mainScroll, "Contact Duration (s)", 0.05, 2, voidConfig.contactDuration, function(v) voidConfig.contactDuration = v end)
        createModernSlider(mainScroll, "Max Target Distance", 10, 1000, voidConfig.maxDistance, function(v) voidConfig.maxDistance = v end)

        local dropdownHeader = Instance.new("TextButton")
        dropdownHeader.Size = UDim2.new(1, -4, 0, 22); dropdownHeader.BackgroundColor3 = currentTheme.elem; dropdownHeader.TextColor3 = currentTheme.text
        dropdownHeader.Font = currentFont; dropdownHeader.TextSize = 12; dropdownHeader.Text = "▼ Target: " .. voidConfig.targetMode
        dropdownHeader.TextXAlignment = Enum.TextXAlignment.Left; dropdownHeader.AutoButtonColor = false; dropdownHeader.Parent = mainScroll
        addCorners(dropdownHeader, UDim.new(0,4)); registerElement(dropdownHeader, "elem"); registerElement(dropdownHeader, "text")
        local dropdownContent = Instance.new("Frame")
        dropdownContent.Size = UDim2.new(1, -4, 0, 0); dropdownContent.BackgroundColor3 = currentTheme.elem; dropdownContent.BorderSizePixel = 0
        dropdownContent.ClipsDescendants = true; dropdownContent.Parent = mainScroll
        addCorners(dropdownContent, UDim.new(0,4)); registerElement(dropdownContent, "elem")
        local dropdownLayout = Instance.new("UIListLayout"); dropdownLayout.Padding = UDim.new(0,2); dropdownLayout.Parent = dropdownContent
        local targetModes = {"Manual Select", "Void Target", "Attacker Priority"}
        local dropdownOpen = false
        local function rebuildDropdown()
            for _, child in ipairs(dropdownContent:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
            for _, mode in ipairs(targetModes) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -4, 0, 18); btn.BackgroundColor3 = currentTheme.sliderBar; btn.TextColor3 = currentTheme.text
                btn.Font = currentFont; btn.TextSize = 11; btn.Text = mode; btn.AutoButtonColor = false; btn.Parent = dropdownContent
                addCorners(btn, UDim.new(0,3)); registerElement(btn, "sliderBar"); registerElement(btn, "text")
                btn.MouseButton1Click:Connect(function()
                    voidConfig.targetMode = mode; dropdownHeader.Text = "▼ Target: " .. mode
                    dropdownOpen = false; TweenService:Create(dropdownContent, TweenInfo.new(0.3), {Size = UDim2.new(1, -4, 0, 0)}):Play()
                end)
            end
        end
        rebuildDropdown()
        dropdownHeader.MouseButton1Click:Connect(function()
            dropdownOpen = not dropdownOpen
            if dropdownOpen then
                rebuildDropdown()
                TweenService:Create(dropdownContent, TweenInfo.new(0.3), {Size = UDim2.new(1, -4, 0, #targetModes * 20 + 10)}):Play()
            else
                TweenService:Create(dropdownContent, TweenInfo.new(0.3), {Size = UDim2.new(1, -4, 0, 0)}):Play()
            end
        end)

        local manualSelectHeader = Instance.new("TextButton")
        manualSelectHeader.Size = UDim2.new(1, -4, 0, 22); manualSelectHeader.BackgroundColor3 = currentTheme.elem; manualSelectHeader.TextColor3 = currentTheme.text
        manualSelectHeader.Font = currentFont; manualSelectHeader.TextSize = 12; manualSelectHeader.Text = "▼ Select Player"
        manualSelectHeader.TextXAlignment = Enum.TextXAlignment.Left; manualSelectHeader.AutoButtonColor = false; manualSelectHeader.Parent = mainScroll
        addCorners(manualSelectHeader, UDim.new(0,4)); registerElement(manualSelectHeader, "elem"); registerElement(manualSelectHeader, "text")
        local manualSelectContent = Instance.new("Frame")
        manualSelectContent.Size = UDim2.new(1, -4, 0, 0); manualSelectContent.BackgroundColor3 = currentTheme.elem; manualSelectContent.BorderSizePixel = 0
        manualSelectContent.ClipsDescendants = true; manualSelectContent.Parent = mainScroll
        addCorners(manualSelectContent, UDim.new(0,4)); registerElement(manualSelectContent, "elem")
        local manualSelectLayout = Instance.new("UIListLayout"); manualSelectLayout.Padding = UDim.new(0,2); manualSelectLayout.Parent = manualSelectContent
        local manualSelectOpen = false
        local function rebuildManualSelect()
            for _, child in ipairs(manualSelectContent:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
            local targets = getValidTargets()
            for _, player in ipairs(targets) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -4, 0, 18); btn.BackgroundColor3 = currentTheme.sliderBar; btn.TextColor3 = currentTheme.text
                btn.Font = currentFont; btn.TextSize = 11; btn.Text = player.Name; btn.AutoButtonColor = false; btn.Parent = manualSelectContent
                addCorners(btn, UDim.new(0,3)); registerElement(btn, "sliderBar"); registerElement(btn, "text")
                btn.MouseButton1Click:Connect(function()
                    voidConfig.manualTargetName = player.Name; manualSelectHeader.Text = "▼ Select Player: " .. player.Name
                    manualSelectOpen = false; TweenService:Create(manualSelectContent, TweenInfo.new(0.3), {Size = UDim2.new(1, -4, 0, 0)}):Play()
                end)
            end
        end
        manualSelectHeader.MouseButton1Click:Connect(function()
            manualSelectOpen = not manualSelectOpen
            if manualSelectOpen then
                rebuildManualSelect()
                local count = #getValidTargets()
                TweenService:Create(manualSelectContent, TweenInfo.new(0.3), {Size = UDim2.new(1, -4, 0, count * 20 + 10)}):Play()
            else
                TweenService:Create(manualSelectContent, TweenInfo.new(0.3), {Size = UDim2.new(1, -4, 0, 0)}):Play()
            end
        end)

        local statsBtn = Instance.new("TextButton")
        statsBtn.Size = UDim2.new(1, -4, 0, 22); statsBtn.BackgroundColor3 = currentTheme.elem; statsBtn.TextColor3 = currentTheme.text
        statsBtn.Font = currentFont; statsBtn.TextSize = 12; statsBtn.Text = "Toggle Stats Panel"; statsBtn.AutoButtonColor = false; statsBtn.Parent = mainScroll
        addCorners(statsBtn, UDim.new(0,4)); registerElement(statsBtn, "elem"); registerElement(statsBtn, "text")
        statsBtn.MouseButton1Click:Connect(toggleStatsPanel)
    end

    local function buildESPControls()
        clearScroll()
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0,4)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = mainScroll

        local backEsp = Instance.new("TextButton")
        backEsp.Size = UDim2.new(1, -8, 0, 22)
        backEsp.BackgroundColor3 = currentTheme.accent
        backEsp.TextColor3 = Color3.new(1,1,1)
        backEsp.Font = currentFont
        backEsp.TextSize = 12
        backEsp.Text = "← Back"
        backEsp.AutoButtonColor = false
        backEsp.ZIndex = 10
        backEsp.Parent = mainScroll
        addCorners(backEsp, UDim.new(0,4))
        local backStroke = Instance.new("UIStroke", backEsp)
        backStroke.Color = currentTheme.border; backStroke.Thickness = 1
        registerElement(backEsp, "elem"); registerElement(backEsp, "text")
        backEsp.MouseButton1Click:Connect(buildVoidControls)

        local function createESPToggleRow(name, default, callback)
            local row = Instance.new("Frame"); row.Size = UDim2.new(1, -8, 0, 22); row.BackgroundTransparency = 1; row.Parent = mainScroll
            local label = Instance.new("TextLabel"); label.Size = UDim2.new(1, -28, 1, 0); label.Position = UDim2.new(0,4,0,0); label.BackgroundTransparency = 1
            label.TextColor3 = currentTheme.text; label.Font = currentFont; label.TextSize = 11; label.Text = name; label.TextXAlignment = Enum.TextXAlignment.Left; label.Parent = row; registerElement(label, "text")
            local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0,18,0,18); btn.Position = UDim2.new(1,-22,0.5,-9)
            btn.BackgroundColor3 = default and currentTheme.accent or currentTheme.toggleOff; btn.Text = ""; btn.AutoButtonColor = false; btn.BorderSizePixel = 0; btn.Parent = row
            addCorners(btn, UDim.new(1,0)); registerElement(btn, "toggleOff")
            local tick = Instance.new("TextLabel"); tick.Size = UDim2.new(1,0,1,0); tick.BackgroundTransparency = 1; tick.Text = "✓"; tick.TextColor3 = Color3.fromRGB(0,0,0)
            tick.Font = Enum.Font.GothamBold; tick.TextSize = 13; tick.Visible = default; tick.Parent = btn
            local state = default
            local function setState(val)
                state = val
                if val then btn.BackgroundColor3 = currentTheme.accent; tick.Visible = true else btn.BackgroundColor3 = currentTheme.toggleOff; tick.Visible = false end
                callback(val)
            end
            btn.MouseButton1Click:Connect(function() setState(not state) end)
            return setState
        end

        local colorOptions = {
            {Name = "Red", Color = Color3.new(1,0,0)}, {Name = "Green", Color = Color3.new(0,1,0)},
            {Name = "Blue", Color = Color3.new(0,0,1)}, {Name = "White", Color = Color3.new(1,1,1)},
            {Name = "Yellow", Color = Color3.new(1,1,0)}, {Name = "Cyan", Color = Color3.new(0,1,1)},
            {Name = "Magenta", Color = Color3.new(1,0,1)}, {Name = "Orange", Color = Color3.new(1,0.5,0)},
        }
        local function createESPDropdown(parent, label, initialColor, callback)
            local header = Instance.new("TextButton")
            header.Size = UDim2.new(1, -8, 0, 22); header.BackgroundColor3 = currentTheme.elem; header.TextColor3 = currentTheme.text
            header.Font = currentFont; header.TextSize = 11; header.Text = label .. ": " .. initialColor.Name
            header.TextXAlignment = Enum.TextXAlignment.Left; header.AutoButtonColor = false; header.Parent = parent
            addCorners(header, UDim.new(0,4)); registerElement(header, "elem"); registerElement(header, "text")
            local content = Instance.new("Frame")
            content.Size = UDim2.new(1, -8, 0, 0); content.BackgroundColor3 = currentTheme.elem; content.BorderSizePixel = 0; content.ClipsDescendants = true; content.Parent = parent
            addCorners(content, UDim.new(0,4)); registerElement(content, "elem")
            local dropdownLayout = Instance.new("UIListLayout"); dropdownLayout.Padding = UDim.new(0,2); dropdownLayout.Parent = content
            local open = false; local selected = initialColor
            local function rebuild()
                for _, child in ipairs(content:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
                for _, option in ipairs(colorOptions) do
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, -4, 0, 18); btn.BackgroundColor3 = currentTheme.sliderBar; btn.TextColor3 = currentTheme.text
                    btn.Font = currentFont; btn.TextSize = 11; btn.Text = option.Name; btn.AutoButtonColor = false; btn.Parent = content
                    addCorners(btn, UDim.new(0,3)); registerElement(btn, "sliderBar"); registerElement(btn, "text")
                    btn.MouseButton1Click:Connect(function()
                        selected = option; header.Text = label .. ": " .. option.Name; callback(option.Color)
                        open = false; TweenService:Create(content, TweenInfo.new(0.3), {Size = UDim2.new(1, -8, 0, 0)}):Play()
                    end)
                end
            end
            rebuild()
            header.MouseButton1Click:Connect(function()
                open = not open
                if open then rebuild(); TweenService:Create(content, TweenInfo.new(0.3), {Size = UDim2.new(1, -8, 0, #colorOptions * 20 + 10)}):Play()
                else TweenService:Create(content, TweenInfo.new(0.3), {Size = UDim2.new(1, -8, 0, 0)}):Play() end
            end)
        end

        createESPToggleRow("ESP Enabled", ESP.Enabled, function(v) ESP.Enabled = v; ESP.updateConfig() end)
        createESPToggleRow("Chams", ESP.ChamsEnabled, function(v) ESP.ChamsEnabled = v; ESP.updateConfig() end)
        createESPToggleRow("Outline", ESP.OutlineEnabled, function(v) ESP.OutlineEnabled = v; ESP.updateConfig() end)
        createESPToggleRow("Tracer", ESP.TracerEnabled, function(v) ESP.TracerEnabled = v; ESP.updateConfig() end)
        createESPToggleRow("Health Bar", ESP.HealthBarEnabled, function(v) ESP.HealthBarEnabled = v; ESP.updateConfig() end)
        createESPToggleRow("Distance", ESP.DistanceEnabled, function(v) ESP.DistanceEnabled = v; ESP.updateConfig() end)
        createESPToggleRow("Team Check", ESP.TeamCheck, function(v) ESP.TeamCheck = v end)

        createESPToggleRow("Master FOV", ESP.FOVEnabled, function(v) ESP.FOVEnabled = v end)
        createModernSlider(mainScroll, "FOV Size", 10, 300, ESP.FOVSize, function(v) ESP.FOVSize = v end)
        createModernSlider(mainScroll, "FOV Outline Thickness", 1, 10, ESP.FOVOutlineThickness, function(v) ESP.FOVOutlineThickness = v end)
        createESPToggleRow("FOV Fill", ESP.FOVFilled, function(v) ESP.FOVFilled = v end)
        createModernSlider(mainScroll, "FOV Fill Transparency", 0, 1, ESP.FOVFillTransparency, function(v) ESP.FOVFillTransparency = v end)
        createESPDropdown(mainScroll, "FOV Color", {Name="Red", Color=ESP.FOVColor}, function(c) ESP.FOVColor = c end)
        createESPDropdown(mainScroll, "FOV Fill Color", {Name="Red", Color=ESP.FOVFillColor}, function(c) ESP.FOVFillColor = c end)

        createESPToggleRow("Crosshair", ESP.CrosshairEnabled, function(v) ESP.CrosshairEnabled = v end)
        createModernSlider(mainScroll, "Crosshair Size", 5, 40, ESP.CrosshairSize, function(v) ESP.CrosshairSize = v end)
        createModernSlider(mainScroll, "Crosshair Speed", 0.5, 10, ESP.CrosshairSpeed, function(v) ESP.CrosshairSpeed = v end)
        createESPDropdown(mainScroll, "Crosshair Color", {Name="White", Color=ESP.CrosshairColor}, function(c) ESP.CrosshairColor = c end)
    end

    buildVoidControls()

    local titleBar = voidMenu:FindFirstChild("Frame")
    if titleBar then
        local rightContainer = titleBar:FindFirstChild("Frame")
        if rightContainer then
            local miscBtn, espBtn = nil, nil
            for _, child in ipairs(rightContainer:GetChildren()) do
                if child:IsA("Frame") then
                    local btn = child:FindFirstChildWhichIsA("ImageButton")
                    if btn then
                        if btn.Name == "MiscBtn" then miscBtn = btn
                        elseif btn.Name == "EspBtn" then espBtn = btn end
                    end
                end
            end
            if miscBtn then miscBtn.MouseButton1Click:Connect(function() clearScroll() end) end
            if espBtn then espBtn.MouseButton1Click:Connect(buildESPControls) end
        end
    end

    voidMenu.AncestryChanged:Connect(function()
        if not voidMenu.Parent then stopVoidSpam() end
    end)
end
setupVoidSpamUI()

-- ===== BUILD ORBIT UI =====
local function setupOrbitUI()
    local orbitMenu = nil
    for _, info in ipairs(menuInfos) do if info.name == "Orbit" then orbitMenu = info.frame; break end end
    if not orbitMenu then return end
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, -6, 1, -28); sf.Position = UDim2.new(0, 3, 0, 26)
    sf.BackgroundColor3 = currentTheme.bg; sf.BorderSizePixel = 0; sf.ScrollBarThickness = 3
    sf.CanvasSize = UDim2.new(0,0,0,0); sf.AutomaticCanvasSize = Enum.AutomaticSize.Y; sf.Parent = orbitMenu
    addCorners(sf, UDim.new(0,6)); registerElement(sf, "bg")
    local sfLayout = Instance.new("UIListLayout"); sfLayout.Padding = UDim.new(0,4); sfLayout.SortOrder = Enum.SortOrder.LayoutOrder; sfLayout.Parent = sf

    local toggleRow = Instance.new("Frame"); toggleRow.Size = UDim2.new(1, -4, 0, 22); toggleRow.BackgroundTransparency = 1; toggleRow.Parent = sf
    local toggleLabel = Instance.new("TextLabel"); toggleLabel.Size = UDim2.new(0.7,0,1,0); toggleLabel.Position = UDim2.new(0,4,0,0); toggleLabel.BackgroundTransparency = 1
    toggleLabel.TextColor3 = currentTheme.text; toggleLabel.Font = currentFont; toggleLabel.TextSize = 12; toggleLabel.Text = "Orbit"
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left; toggleLabel.Parent = toggleRow
    local toggleBtnOrbit = Instance.new("TextButton"); toggleBtnOrbit.Size = UDim2.new(0,18,0,18); toggleBtnOrbit.Position = UDim2.new(1,-22,0.5,-9)
    toggleBtnOrbit.BackgroundColor3 = currentTheme.toggleOff; toggleBtnOrbit.Text = ""; toggleBtnOrbit.AutoButtonColor = false; toggleBtnOrbit.BorderSizePixel = 0; toggleBtnOrbit.Parent = toggleRow
    addCorners(toggleBtnOrbit, UDim.new(1,0))
    local toggleTickOrbit = Instance.new("TextLabel"); toggleTickOrbit.Size = UDim2.new(1,0,1,0); toggleTickOrbit.BackgroundTransparency = 1; toggleTickOrbit.Text = "✓"; toggleTickOrbit.TextColor3 = Color3.fromRGB(0,0,0)
    toggleTickOrbit.Font = Enum.Font.GothamBold; toggleTickOrbit.TextSize = 13; toggleTickOrbit.Visible = false; toggleTickOrbit.Parent = toggleBtnOrbit
    toggleBtnOrbit.MouseButton1Click:Connect(function()
        orbitEnabled = not orbitEnabled
        if orbitEnabled then toggleBtnOrbit.BackgroundColor3 = currentTheme.accent; toggleTickOrbit.Visible = true
        else toggleBtnOrbit.BackgroundColor3 = currentTheme.toggleOff; toggleTickOrbit.Visible = false end
        onOrbitToggle(orbitEnabled)
    end)

    local antiAimRow = Instance.new("Frame"); antiAimRow.Size = UDim2.new(1, -4, 0, 22); antiAimRow.BackgroundTransparency = 1; antiAimRow.Parent = sf
    local antiAimLabel = Instance.new("TextLabel"); antiAimLabel.Size = UDim2.new(0.7,0,1,0); antiAimLabel.Position = UDim2.new(0,4,0,0); antiAimLabel.BackgroundTransparency = 1
    antiAimLabel.TextColor3 = currentTheme.text; antiAimLabel.Font = currentFont; antiAimLabel.TextSize = 12; antiAimLabel.Text = "Anti‑Aim"
    antiAimLabel.TextXAlignment = Enum.TextXAlignment.Left; antiAimLabel.Parent = antiAimRow
    local antiAimBtn = Instance.new("TextButton"); antiAimBtn.Size = UDim2.new(0,18,0,18); antiAimBtn.Position = UDim2.new(1,-22,0.5,-9)
    antiAimBtn.BackgroundColor3 = currentTheme.accent; antiAimBtn.Text = ""; antiAimBtn.AutoButtonColor = false; antiAimBtn.BorderSizePixel = 0; antiAimBtn.Parent = antiAimRow
    addCorners(antiAimBtn, UDim.new(1,0))
    local antiAimTick = Instance.new("TextLabel"); antiAimTick.Size = UDim2.new(1,0,1,0); antiAimTick.BackgroundTransparency = 1; antiAimTick.Text = "✓"; antiAimTick.TextColor3 = Color3.fromRGB(0,0,0)
    antiAimTick.Font = Enum.Font.GothamBold; antiAimTick.TextSize = 13; antiAimTick.Visible = true; antiAimTick.Parent = antiAimBtn
    antiAimBtn.MouseButton1Click:Connect(function()
        orbitConfig.antiAim = not orbitConfig.antiAim
        if orbitConfig.antiAim then antiAimBtn.BackgroundColor3 = currentTheme.accent; antiAimTick.Visible = true
        else antiAimBtn.BackgroundColor3 = currentTheme.toggleOff; antiAimTick.Visible = false end
    end)

    local modeHeader = Instance.new("TextButton")
    modeHeader.Size = UDim2.new(1, -4, 0, 22); modeHeader.BackgroundColor3 = currentTheme.elem; modeHeader.TextColor3 = currentTheme.text
    modeHeader.Font = currentFont; modeHeader.TextSize = 12; modeHeader.Text = "▼ Orbit Vector: " .. orbitConfig.mode
    modeHeader.TextXAlignment = Enum.TextXAlignment.Left; modeHeader.AutoButtonColor = false; modeHeader.Parent = sf
    addCorners(modeHeader, UDim.new(0,4)); registerElement(modeHeader, "elem"); registerElement(modeHeader, "text")
    local modeContent = Instance.new("Frame")
    modeContent.Size = UDim2.new(1, -4, 0, 0); modeContent.BackgroundColor3 = currentTheme.elem; modeContent.BorderSizePixel = 0; modeContent.ClipsDescendants = true; modeContent.Parent = sf
    addCorners(modeContent, UDim.new(0,4)); registerElement(modeContent, "elem")
    local modeLayout = Instance.new("UIListLayout"); modeLayout.Padding = UDim.new(0,2); modeLayout.Parent = modeContent
    local modes = {"Target Lock", "Spiral Helix", "Jitter Orbit", "Desync Cam"}
    local modeOpen = false
    local function rebuildModeDropdown()
        for _, child in ipairs(modeContent:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
        for _, m in ipairs(modes) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -4, 0, 18); btn.BackgroundColor3 = currentTheme.sliderBar; btn.TextColor3 = currentTheme.text
            btn.Font = currentFont; btn.TextSize = 11; btn.Text = m; btn.AutoButtonColor = false; btn.Parent = modeContent
            addCorners(btn, UDim.new(0,3)); registerElement(btn, "sliderBar"); registerElement(btn, "text")
            btn.MouseButton1Click:Connect(function()
                orbitConfig.mode = m; modeHeader.Text = "▼ Orbit Vector: " .. m
                modeOpen = false; TweenService:Create(modeContent, TweenInfo.new(0.3), {Size = UDim2.new(1, -4, 0, 0)}):Play()
            end)
        end
    end
    rebuildModeDropdown()
    modeHeader.MouseButton1Click:Connect(function()
        modeOpen = not modeOpen
        if modeOpen then
            rebuildModeDropdown()
            TweenService:Create(modeContent, TweenInfo.new(0.3), {Size = UDim2.new(1, -4, 0, #modes * 20 + 10)}):Play()
        else
            TweenService:Create(modeContent, TweenInfo.new(0.3), {Size = UDim2.new(1, -4, 0, 0)}):Play()
        end
    end)

    createModernSlider(sf, "Orbit Speed (Angular)", 0.5, 50, orbitConfig.speed, function(v) orbitConfig.speed = v end)
    createModernSlider(sf, "Orbit Range", 1, 15, orbitConfig.range, function(v) orbitConfig.range = v end)

    orbitMenu.AncestryChanged:Connect(function()
        if not orbitMenu.Parent and orbitEnabled then
            orbitEnabled = false
            onOrbitToggle(false)
        end
    end)
end
setupOrbitUI()

-- ===== APPLY THEME & FONT =====
applyTheme(currentThemeName)
applyFont(currentFontName)

-- ===== MENU TOGGLE + TAB UNLOCK =====
local isOpen = true
local function setMenuState(open)
    if isOpen == open then return end
    isOpen = open
    if open then
        BlurOn()
        for _, info in ipairs(menuInfos) do
            info.frame.Visible = true
            TweenService:Create(info.frame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
        end
        toggleBtn.Text = "Close"
        stopAimbot()
        unlockCamera()
    else
        BlurOff()
        for _, info in ipairs(menuInfos) do
            TweenService:Create(info.frame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            task.delay(0.3, function() if not isOpen then info.frame.Visible = false end end)
        end
        hideAdminPanel()
        toggleBtn.Text = "Open"
        if voidSpamEnabled or orbitEnabled then lockCameraAtSpawn() end
        if voidSpamEnabled and not orbitEnabled and not tabHeld and currentTarget then startAimbot() end
    end
end

toggleBtn.MouseButton1Click:Connect(function() setMenuState(not isOpen) end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F2 or input.KeyCode == Enum.KeyCode.RightShift then
        setMenuState(not isOpen)
    elseif input.KeyCode == Enum.KeyCode.Tab then
        if voidSpamEnabled and not isOpen then tabHeld = true; stopAimbot() end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Tab then
        tabHeld = false
        if voidSpamEnabled and not isOpen and not orbitEnabled and currentTarget then startAimbot() end
    end
end)

for _, info in ipairs(menuInfos) do
    info.frame.Visible = true
    info.frame.BackgroundTransparency = 0
end
toggleBtn.Text = "Close"
BlurOn()
Notify("MehfilLuaBeta loaded")
