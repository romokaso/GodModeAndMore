local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local GodModeActive = false
local AntiTPActive = false
local AntiFallActive = false
local AntiFallTeleporting = false
local CurrentTheme = "Dark"
local GodmodeMethod = 1

local godmodeConnections = {}
local antiTPConnections = {}
local antiFallConnections = {}

local godmodeCooldown = false
local antiTPCooldown = false
local antiFallCooldown = false

local godmodeMethod1Connection
local function ApplyGodmodeMethod1()
    if godmodeMethod1Connection then godmodeMethod1Connection:Disconnect() end
    
    godmodeMethod1Connection = RunService.Stepped:Connect(function()
        if GodModeActive and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                if hum.Health < hum.MaxHealth then
                    hum.Health = hum.MaxHealth
                end
            end
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanTouch = true
                end
            end
        elseif not GodModeActive and player.Character then
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanTouch = true
                end
            end
        end
    end)
end

local function startGodmode()
    for _, conn in pairs(godmodeConnections) do
        if conn then conn:Disconnect() end
    end
    godmodeConnections = {}

    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end

    task.wait(0.1)

    godmodeConnections[1] = humanoid.HealthChanged:Connect(function(health)
        if health < humanoid.MaxHealth and health > 0 then
            humanoid.Health = humanoid.MaxHealth
        end
    end)

    godmodeConnections[2] = RunService.Stepped:Connect(function()
        if humanoid.Health > 0 then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)

            for _, v in pairs(character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanTouch = true
                end
            end
        end
    end)

    humanoid.Died:Connect(function()
        for _, conn in pairs(godmodeConnections) do
            if conn then conn:Disconnect() end
        end
        godmodeConnections = {}
    end)
end

local function stopGodmode()
    for _, conn in pairs(godmodeConnections) do
        if conn then conn:Disconnect() end
    end
    godmodeConnections = {}
    
    if godmodeMethod1Connection then
        godmodeMethod1Connection:Disconnect()
    end

    if player.Character then
        for _, v in pairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanTouch = true
            end
        end
    end
end

local function startAntiTP()
    for _, conn in pairs(antiTPConnections) do
        if conn then conn:Disconnect() end
    end
    antiTPConnections = {}

    local character = player.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end

    task.wait(0.1)
    local safePosition = hrp.CFrame

    antiTPConnections[1] = RunService.Stepped:Connect(function()
        if humanoid.Health > 0 then
            local dist = (hrp.CFrame.Position - safePosition.Position).Magnitude
            if dist > 10 and not AntiFallTeleporting then
                hrp.CFrame = safePosition
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            else
                safePosition = hrp.CFrame
            end
        end
    end)

    antiTPConnections[2] = RunService.Heartbeat:Connect(function()
        if humanoid.Health > 0 then
            local dist = (hrp.CFrame.Position - safePosition.Position).Magnitude
            if dist > 10 and not AntiFallTeleporting then
                hrp.CFrame = safePosition
            end
        end
    end)

    humanoid.Died:Connect(function()
        for _, conn in pairs(antiTPConnections) do
            if conn then conn:Disconnect() end
        end
        antiTPConnections = {}
    end)
end

local function stopAntiTP()
    for _, conn in pairs(antiTPConnections) do
        if conn then conn:Disconnect() end
    end
    antiTPConnections = {}
end

local function startAntiFall()
    for _, conn in pairs(antiFallConnections) do
        if conn then conn:Disconnect() end
    end
    antiFallConnections = {}

    local character = player.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end

    task.wait(0.1)
    local lastGroundPosition = hrp.CFrame
    local lastGroundY = hrp.Position.Y

    antiFallConnections[1] = RunService.Heartbeat:Connect(function()
        if humanoid.Health > 0 then
            local currentY = hrp.Position.Y

            if humanoid.FloorMaterial ~= Enum.Material.Air then
                lastGroundPosition = hrp.CFrame
                lastGroundY = currentY
            end

            if lastGroundY - currentY > 15 then
                AntiFallTeleporting = true

                hrp.CFrame = lastGroundPosition
                hrp.AssemblyLinearVelocity = Vector3.zero

                task.delay(0.1, function()
                    AntiFallTeleporting = false
                end)
            end
        end
    end)

    humanoid.Died:Connect(function()
        for _, conn in pairs(antiFallConnections) do
            if conn then conn:Disconnect() end
        end
        antiFallConnections = {}
    end)
end

local function stopAntiFall()
    for _, conn in pairs(antiFallConnections) do
        if conn then conn:Disconnect() end
    end
    antiFallConnections = {}
end

local Themes = {
    Dark = {
        Background = Color3.fromRGB(10, 10, 10),
        TitleBar = Color3.fromRGB(15, 15, 15),
        Button = Color3.fromRGB(25, 25, 25),
        ButtonHover = Color3.fromRGB(35, 35, 35),
        Text = Color3.fromRGB(220, 220, 220),
        Border = Color3.fromRGB(60, 60, 60),
        TopButtons = Color3.fromRGB(40, 40, 40)
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 240),
        TitleBar = Color3.fromRGB(220, 220, 220),
        Button = Color3.fromRGB(255, 255, 255),
        ButtonHover = Color3.fromRGB(230, 230, 230),
        Text = Color3.fromRGB(20, 20, 20),
        Border = Color3.fromRGB(180, 180, 180),
        TopButtons = Color3.fromRGB(200, 200, 200)
    }
}

local MainGui = Instance.new("ScreenGui", CoreGui)
MainGui.Name = "GodModeAndMore"
MainGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", MainGui)
Frame.Size = UDim2.new(0, 240, 0, 250)
Frame.Position = UDim2.new(0.5, -120, 0.5, -125)
Frame.BackgroundColor3 = Themes.Dark.Background
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.ClipsDescendants = true

local FrameCorner = Instance.new("UICorner", Frame)
FrameCorner.CornerRadius = UDim.new(0, 12)

local FrameStroke = Instance.new("UIStroke", Frame)
FrameStroke.Thickness = 2
FrameStroke.Color = Themes.Dark.Border
FrameStroke.Transparency = 0.2

local Shadow = Instance.new("ImageLabel", Frame)
Shadow.Name = "Shadow"
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0, -15, 0, -15)
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.ZIndex = 0
Shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5

local TitleBar = Instance.new("Frame", Frame)
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Themes.Dark.TitleBar
TitleBar.BorderSizePixel = 0

local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 12)

local TitleFix = Instance.new("Frame", TitleBar)
TitleFix.Size = UDim2.new(1, 0, 0, 15)
TitleFix.Position = UDim2.new(0, 0, 1, -15)
TitleFix.BackgroundColor3 = Themes.Dark.TitleBar
TitleFix.BorderSizePixel = 0

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "GODMODE & MORE"
Title.TextColor3 = Themes.Dark.Text
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local dragging = false
local dragInput
local dragStart
local startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local SettingsBtn = Instance.new("TextButton", TitleBar)
SettingsBtn.Size = UDim2.new(0, 28, 0, 28)
SettingsBtn.Position = UDim2.new(1, -92, 0.5, -14)
SettingsBtn.BackgroundColor3 = Themes.Dark.TopButtons
SettingsBtn.Text = "⚙"
SettingsBtn.TextColor3 = Themes.Dark.Text
SettingsBtn.Font = Enum.Font.GothamBold
SettingsBtn.TextSize = 16
SettingsBtn.BorderSizePixel = 0

local SettingsCorner = Instance.new("UICorner", SettingsBtn)
SettingsCorner.CornerRadius = UDim.new(0, 8)

local MinimizeBtn = Instance.new("TextButton", TitleBar)
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.Position = UDim2.new(1, -62, 0.5, -14)
MinimizeBtn.BackgroundColor3 = Themes.Dark.TopButtons
MinimizeBtn.Text = "−"
MinimizeBtn.TextColor3 = Themes.Dark.Text
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 16
MinimizeBtn.BorderSizePixel = 0

local MinCorner = Instance.new("UICorner", MinimizeBtn)
MinCorner.CornerRadius = UDim.new(0, 8)

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -32, 0.5, -14)
CloseBtn.BackgroundColor3 = Themes.Dark.TopButtons
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Themes.Dark.Text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.BorderSizePixel = 0

local CloseCorner = Instance.new("UICorner", CloseBtn)
CloseCorner.CornerRadius = UDim.new(0, 8)

local Content = Instance.new("Frame", Frame)
Content.Size = UDim2.new(1, -14, 1, -48)
Content.Position = UDim2.new(0, 7, 0, 41)
Content.BackgroundTransparency = 1

local MethodBtn = Instance.new("TextButton", Content)
MethodBtn.Size = UDim2.new(1, 0, 0, 30)
MethodBtn.Position = UDim2.new(0, 0, 0, 0)
MethodBtn.BackgroundColor3 = Themes.Dark.Button
MethodBtn.Text = "METHOD: 1 (MAXHEALTH)"
MethodBtn.TextColor3 = Themes.Dark.Text
MethodBtn.Font = Enum.Font.GothamBold
MethodBtn.TextSize = 11
MethodBtn.BorderSizePixel = 0

local MethodCorner = Instance.new("UICorner", MethodBtn)
MethodCorner.CornerRadius = UDim.new(0, 9)

local MethodFrame = Instance.new("Frame", Content)
MethodFrame.Size = UDim2.new(1, 0, 0, 75)
MethodFrame.Position = UDim2.new(0, 0, 0, 35)
MethodFrame.BackgroundColor3 = Themes.Dark.Background
MethodFrame.BorderSizePixel = 0
MethodFrame.Visible = false
MethodFrame.ZIndex = 15

local MethodFrameCorner = Instance.new("UICorner", MethodFrame)
MethodFrameCorner.CornerRadius = UDim.new(0, 9)

local MethodFrameStroke = Instance.new("UIStroke", MethodFrame)
MethodFrameStroke.Thickness = 2
MethodFrameStroke.Color = Themes.Dark.Border
MethodFrameStroke.Transparency = 0.2

local Method1Btn = Instance.new("TextButton", MethodFrame)
Method1Btn.Size = UDim2.new(1, -10, 0, 30)
Method1Btn.Position = UDim2.new(0, 5, 0, 5)
Method1Btn.BackgroundColor3 = Themes.Dark.Button
Method1Btn.Text = "METHOD 1: MAXHEALTH"
Method1Btn.TextColor3 = Themes.Dark.Text
Method1Btn.Font = Enum.Font.GothamBold
Method1Btn.TextSize = 10
Method1Btn.BorderSizePixel = 0
Method1Btn.ZIndex = 16

local Method1Corner = Instance.new("UICorner", Method1Btn)
Method1Corner.CornerRadius = UDim.new(0, 7)

local Method2Btn = Instance.new("TextButton", MethodFrame)
Method2Btn.Size = UDim2.new(1, -10, 0, 30)
Method2Btn.Position = UDim2.new(0, 5, 0, 40)
Method2Btn.BackgroundColor3 = Themes.Dark.Button
Method2Btn.Text = "METHOD 2: HEALTH CHANGER"
Method2Btn.TextColor3 = Themes.Dark.Text
Method2Btn.Font = Enum.Font.GothamBold
Method2Btn.TextSize = 10
Method2Btn.BorderSizePixel = 0
Method2Btn.ZIndex = 16

local Method2Corner = Instance.new("UICorner", Method2Btn)
Method2Corner.CornerRadius = UDim.new(0, 7)

local buttonReferences = {}

local function CreateButton(text, position, callback)
    local btn = Instance.new("TextButton", Content)
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.Position = position
    btn.BackgroundColor3 = Themes[CurrentTheme].Button
    btn.Text = text
    btn.TextColor3 = Themes[CurrentTheme].Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextScaled = false
    btn.TextWrapped = false
    btn.TextXAlignment = Enum.TextXAlignment.Center
    btn.TextYAlignment = Enum.TextYAlignment.Center
    btn.BorderSizePixel = 0
    btn.ClipsDescendants = true

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 9)

    local glow = Instance.new("UIStroke", btn)
    glow.Thickness = 0
    glow.Color = Color3.fromRGB(80, 80, 80)
    glow.Transparency = 1

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Themes[CurrentTheme].ButtonHover}):Play()
        TweenService:Create(glow, TweenInfo.new(0.1), {Thickness = 2, Transparency = 0.4}):Play()
    end)

    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Themes[CurrentTheme].Button}):Play()
        TweenService:Create(glow, TweenInfo.new(0.1), {Thickness = 0, Transparency = 1}):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        callback(btn)
    end)

    table.insert(buttonReferences, btn)
    return btn
end

local GodmodeBtn = CreateButton(
    "GODMODE: OFF",
    UDim2.new(0, 0, 0, 37),
    function(btn)
        if godmodeCooldown then return end
        godmodeCooldown = true

        GodModeActive = not GodModeActive
        btn.Text = "GODMODE: " .. (GodModeActive and "ON" or "OFF")

        if GodModeActive then
            if GodmodeMethod == 1 then
                ApplyGodmodeMethod1()
            else
                startGodmode()
            end
        else
            stopGodmode()
        end

        task.wait(0.1)
        godmodeCooldown = false
    end
)

local AntiTPBtn = CreateButton(
    "ANTI-TP: OFF",
    UDim2.new(0, 0, 0, 80),
    function(btn)
        if antiTPCooldown then return end
        antiTPCooldown = true

        AntiTPActive = not AntiTPActive
        btn.Text = "ANTI-TP: " .. (AntiTPActive and "ON" or "OFF")

        if AntiTPActive then
            startAntiTP()
        else
            stopAntiTP()
        end

        task.wait(0.1)
        antiTPCooldown = false
    end
)

local AntiFallBtn = CreateButton(
    "ANTI-FALL (BETA): OFF",
    UDim2.new(0, 0, 0, 123),
    function(btn)
        if antiFallCooldown then return end
        antiFallCooldown = true

        AntiFallActive = not AntiFallActive
        btn.Text = "ANTI-FALL (BETA): " .. (AntiFallActive and "ON" or "OFF")

        if AntiFallActive then
            startAntiFall()
        else
            stopAntiFall()
        end

        task.wait(0.1)
        antiFallCooldown = false
    end
)

local Credit = Instance.new("TextLabel", Content)
Credit.Size = UDim2.new(1, 0, 0, 22)
Credit.Position = UDim2.new(0, 0, 1, -22)
Credit.Text = "by: romokaso"
Credit.TextColor3 = Color3.fromRGB(120, 120, 120)
Credit.BackgroundTransparency = 1
Credit.Font = Enum.Font.GothamBold
Credit.TextSize = 10

local SettingsFrame = Instance.new("Frame", Frame)
SettingsFrame.Size = UDim2.new(1, 0, 1, 0)
SettingsFrame.Position = UDim2.new(0, 0, 0, 0)
SettingsFrame.BackgroundColor3 = Themes.Dark.Background
SettingsFrame.BorderSizePixel = 0
SettingsFrame.Visible = false
SettingsFrame.ZIndex = 20

local SettingsFrameCorner = Instance.new("UICorner", SettingsFrame)
SettingsFrameCorner.CornerRadius = UDim.new(0, 12)

local SettingsTitle = Instance.new("TextLabel", SettingsFrame)
SettingsTitle.Size = UDim2.new(1, 0, 0, 40)
SettingsTitle.Position = UDim2.new(0, 0, 0, 10)
SettingsTitle.Text = "SETTINGS"
SettingsTitle.TextColor3 = Themes.Dark.Text
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Font = Enum.Font.GothamBold
SettingsTitle.TextSize = 16
SettingsTitle.ZIndex = 21

local ThemeLabel = Instance.new("TextLabel", SettingsFrame)
ThemeLabel.Size = UDim2.new(1, -20, 0, 25)
ThemeLabel.Position = UDim2.new(0, 10, 0, 60)
ThemeLabel.Text = "THEME:"
ThemeLabel.TextColor3 = Themes.Dark.Text
ThemeLabel.BackgroundTransparency = 1
ThemeLabel.Font = Enum.Font.GothamBold
ThemeLabel.TextSize = 13
ThemeLabel.TextXAlignment = Enum.TextXAlignment.Left
ThemeLabel.ZIndex = 21

local DarkThemeBtn = Instance.new("TextButton", SettingsFrame)
DarkThemeBtn.Size = UDim2.new(0.45, -5, 0, 35)
DarkThemeBtn.Position = UDim2.new(0, 10, 0, 90)
DarkThemeBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 100)
DarkThemeBtn.Text = "DARK"
DarkThemeBtn.TextColor3 = Color3.new(1, 1, 1)
DarkThemeBtn.Font = Enum.Font.GothamBold
DarkThemeBtn.TextSize = 13
DarkThemeBtn.BorderSizePixel = 0
DarkThemeBtn.ZIndex = 21

local DarkCorner = Instance.new("UICorner", DarkThemeBtn)
DarkCorner.CornerRadius = UDim.new(0, 9)

local LightThemeBtn = Instance.new("TextButton", SettingsFrame)
LightThemeBtn.Size = UDim2.new(0.45, -5, 0, 35)
LightThemeBtn.Position = UDim2.new(0.55, 0, 0, 90)
LightThemeBtn.BackgroundColor3 = Themes.Dark.Button
LightThemeBtn.Text = "LIGHT"
LightThemeBtn.TextColor3 = Themes.Dark.Text
LightThemeBtn.Font = Enum.Font.GothamBold
LightThemeBtn.TextSize = 13
LightThemeBtn.BorderSizePixel = 0
LightThemeBtn.ZIndex = 21

local LightCorner = Instance.new("UICorner", LightThemeBtn)
LightCorner.CornerRadius = UDim.new(0, 9)

local BackBtn = Instance.new("TextButton", SettingsFrame)
BackBtn.Size = UDim2.new(0.9, 0, 0, 35)
BackBtn.Position = UDim2.new(0.05, 0, 1, -50)
BackBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
BackBtn.Text = "BACK"
BackBtn.TextColor3 = Color3.new(1, 1, 1)
BackBtn.Font = Enum.Font.GothamBold
BackBtn.TextSize = 14
BackBtn.BorderSizePixel = 0
BackBtn.ZIndex = 21

local BackCorner = Instance.new("UICorner", BackBtn)
BackCorner.CornerRadius = UDim.new(0, 9)

local function ApplyTheme(theme)
    local colors = Themes[theme]
    CurrentTheme = theme

    Frame.BackgroundColor3 = colors.Background
    TitleBar.BackgroundColor3 = colors.TitleBar
    TitleFix.BackgroundColor3 = colors.TitleBar
    Title.TextColor3 = colors.Text
    FrameStroke.Color = colors.Border

    SettingsBtn.BackgroundColor3 = colors.TopButtons
    SettingsBtn.TextColor3 = colors.Text
    MinimizeBtn.BackgroundColor3 = colors.TopButtons
    MinimizeBtn.TextColor3 = colors.Text
    CloseBtn.BackgroundColor3= colors.TopButtons
    CloseBtn.TextColor3 = colors.Text

    MethodBtn.BackgroundColor3 = colors.Button
    MethodBtn.TextColor3 = colors.Text
    MethodFrame.BackgroundColor3 = colors.Background
    MethodFrameStroke.Color = colors.Border
    Method1Btn.BackgroundColor3 = colors.Button
    Method1Btn.TextColor3 = colors.Text
    Method2Btn.BackgroundColor3 = colors.Button
    Method2Btn.TextColor3 = colors.Text

    for _, btn in pairs(buttonReferences) do
        btn.BackgroundColor3 = colors.Button
        btn.TextColor3 = colors.Text
    end

    SettingsFrame.BackgroundColor3 = colors.Background
    SettingsTitle.TextColor3 = colors.Text
    ThemeLabel.TextColor3 = colors.Text

    ConfirmFrame.BackgroundColor3 = colors.Background
    ConfirmStroke.Color = colors.Border
    ConfirmText.TextColor3 = colors.Text

    if theme == "Dark" then
        DarkThemeBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 100)
        DarkThemeBtn.TextColor3 = Color3.new(1, 1, 1)
        LightThemeBtn.BackgroundColor3 = colors.Button
        LightThemeBtn.TextColor3 = colors.Text
    else
        LightThemeBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 100)
        LightThemeBtn.TextColor3 = Color3.new(1, 1, 1)
        DarkThemeBtn.BackgroundColor3 = colors.Button
        DarkThemeBtn.TextColor3 = colors.Text
    end
end

local ConfirmFrame = Instance.new("Frame", Frame)
ConfirmFrame.Size = UDim2.new(1, 0, 1, 0)
ConfirmFrame.Position = UDim2.new(0, 0, 0, 0)
ConfirmFrame.BackgroundColor3 = Themes.Dark.Background
ConfirmFrame.BorderSizePixel = 0
ConfirmFrame.Visible = false
ConfirmFrame.ZIndex = 25
ConfirmFrame.BackgroundTransparency = 0.05

local ConfirmCorner = Instance.new("UICorner", ConfirmFrame)
ConfirmCorner.CornerRadius = UDim.new(0, 12)

local ConfirmStroke = Instance.new("UIStroke", ConfirmFrame)
ConfirmStroke.Thickness = 3
ConfirmStroke.Color = Themes.Dark.Border

local ConfirmText = Instance.new("TextLabel", ConfirmFrame)
ConfirmText.Size = UDim2.new(1, -20, 0, 60)
ConfirmText.Position = UDim2.new(0, 10, 0, 70)
ConfirmText.Text = "Are you sure you want\nto close the GUI?"
ConfirmText.TextColor3 = Themes.Dark.Text
ConfirmText.BackgroundTransparency = 1
ConfirmText.Font = Enum.Font.GothamBold
ConfirmText.TextSize = 14
ConfirmText.TextXAlignment = Enum.TextXAlignment.Center
ConfirmText.ZIndex = 26

local YesBtn = Instance.new("TextButton", ConfirmFrame)
YesBtn.Size = UDim2.new(0, 95, 0, 35)
YesBtn.Position = UDim2.new(0, 15, 1, -50)
YesBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
YesBtn.Text = "YES"
YesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
YesBtn.Font = Enum.Font.GothamBold
YesBtn.TextSize = 14
YesBtn.BorderSizePixel = 0
YesBtn.ZIndex = 26

local YesCorner = Instance.new("UICorner", YesBtn)
YesCorner.CornerRadius = UDim.new(0, 9)

local NoBtn = Instance.new("TextButton", ConfirmFrame)
NoBtn.Size = UDim2.new(0, 95, 0, 35)
NoBtn.Position = UDim2.new(1, -110, 1, -50)
NoBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
NoBtn.Text = "NO"
NoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
NoBtn.Font = Enum.Font.GothamBold
NoBtn.TextSize = 14
NoBtn.BorderSizePixel = 0
NoBtn.ZIndex = 26

local NoCorner = Instance.new("UICorner", NoBtn)
NoCorner.CornerRadius = UDim.new(0, 9)

local isMinimized = false
local isClosing = false
local minimizeCooldown = false
local closeCooldown = false
local confirmDialogOpen = false
local settingsOpen = false

MethodBtn.MouseButton1Click:Connect(function()
    MethodFrame.Visible = not MethodFrame.Visible
end)

Method1Btn.MouseButton1Click:Connect(function()
    GodmodeMethod = 1
    MethodBtn.Text = "METHOD: 1 (MAXHEALTH)"
    MethodFrame.Visible = false
    
    if GodModeActive then
        stopGodmode()
        task.wait(0.1)
        ApplyGodmodeMethod1()
    end
end)

Method2Btn.MouseButton1Click:Connect(function()
    GodmodeMethod = 2
    MethodBtn.Text = "METHOD: 2 (HEALTH CHANGER)"
    MethodFrame.Visible = false
    
    if GodModeActive then
        if godmodeMethod1Connection then
            godmodeMethod1Connection:Disconnect()
        end
        task.wait(0.1)
        startGodmode()
    end
end)

DarkThemeBtn.MouseButton1Click:Connect(function()
    ApplyTheme("Dark")
end)

LightThemeBtn.MouseButton1Click:Connect(function()
    ApplyTheme("Light")
end)

BackBtn.MouseButton1Click:Connect(function()
    SettingsFrame.Visible = false
    settingsOpen = false
end)

SettingsBtn.MouseButton1Click:Connect(function()
    if confirmDialogOpen then return end
    
    if isMinimized then
        isMinimized = false
        TweenService:Create(Frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 240, 0, 250)
        }):Play()
        MinimizeBtn.Text = "−"
        task.wait(0.1)
    end
    
    SettingsFrame.Visible = not SettingsFrame.Visible
    settingsOpen = SettingsFrame.Visible
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    if minimizeCooldown or confirmDialogOpen then return end
    minimizeCooldown = true
    
    if settingsOpen then
        SettingsFrame.Visible = false
        settingsOpen = false
    end
    
    isMinimized = not isMinimized
    
    if isMinimized then
        TweenService:Create(Frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 240, 0, 35)
        }):Play()
        MinimizeBtn.Text = "+"
    else
        TweenService:Create(Frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 240, 0, 250)
        }):Play()
        MinimizeBtn.Text = "−"
    end
    
    task.wait(0.1)
    minimizeCooldown = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    if closeCooldown or isClosing or confirmDialogOpen then return end
    closeCooldown = true
    confirmDialogOpen = true
    
    if settingsOpen then
        SettingsFrame.Visible = false
        settingsOpen = false
    end
    
    if isMinimized then
        isMinimized = false
        TweenService:Create(Frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 240, 0, 250)
        }):Play()
        MinimizeBtn.Text = "−"
        task.wait(0.1)
    end
    
    local confirmColors = Themes[CurrentTheme]
    ConfirmFrame.BackgroundColor3 = confirmColors.Background
    ConfirmStroke.Color = confirmColors.Border
    ConfirmText.TextColor3 = confirmColors.Text
    
    ConfirmFrame.Visible = true
    ConfirmFrame.BackgroundTransparency = 1
    TweenService:Create(ConfirmFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.05
    }):Play()
    
    task.wait(0.1)
    closeCooldown = false
end)

local noCooldown = false
NoBtn.MouseButton1Click:Connect(function()
    if noCooldown then return end
    noCooldown = true
    
    TweenService:Create(ConfirmFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()
    task.wait(0.1)
    ConfirmFrame.Visible = false
    confirmDialogOpen = false
    
    task.wait(0.1)
    noCooldown = false
end)

local yesCooldown = false
YesBtn.MouseButton1Click:Connect(function()
    if yesCooldown or isClosing then return end
    yesCooldown = true
    isClosing = true
    
    TweenService:Create(ConfirmFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()
    
    task.wait(0.1)
    
    TweenService:Create(Frame, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
    
    task.wait(0.1)
    MainGui:Destroy()
end)

Frame.Size = UDim2.new(0, 0, 0, 0)
Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
TweenService:Create(Frame, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 240, 0, 250),
    Position = UDim2.new(0.5, -120, 0.5, -125)
}):Play()

player.CharacterAdded:Connect(function()
    task.wait(0.1)
    if GodModeActive then
        if GodmodeMethod == 1 then
            ApplyGodmodeMethod1()
        else
            startGodmode()
        end
    end
    if AntiTPActive then
        startAntiTP()
    end
    if AntiFallActive then
        startAntiFall()
    end
end)
