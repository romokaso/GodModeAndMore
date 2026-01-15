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

local godmodeConnections = {}
local antiTPConnections = {}
local antiFallConnections = {}

local godmodeCooldown = false
local antiTPCooldown = false
local antiFallCooldown = false

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

local MainGui = Instance.new("ScreenGui", CoreGui)
MainGui.Name = "GodModeAndMore"
MainGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", MainGui)
Frame.Size = UDim2.new(0, 240, 0, 200)
Frame.Position = UDim2.new(0.5, -120, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.ClipsDescendants = true

local FrameCorner = Instance.new("UICorner", Frame)
FrameCorner.CornerRadius = UDim.new(0, 12)

local FrameStroke = Instance.new("UIStroke", Frame)
FrameStroke.Thickness = 2
FrameStroke.Color = Color3.fromRGB(60, 60, 60)
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
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TitleBar.BorderSizePixel = 0

local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 12)

local TitleFix = Instance.new("Frame", TitleBar)
TitleFix.Size = UDim2.new(1, 0, 0, 15)
TitleFix.Position = UDim2.new(0, 0, 1, -15)
TitleFix.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TitleFix.BorderSizePixel = 0

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "GODMODE & MORE"
Title.TextColor3 = Color3.fromRGB(220, 220, 220)
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

local MinimizeBtn = Instance.new("TextButton", TitleBar)
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.Position = UDim2.new(1, -62, 0.5, -14)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeBtn.Text = "−"
MinimizeBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 16
MinimizeBtn.BorderSizePixel = 0

local MinCorner = Instance.new("UICorner", MinimizeBtn)
MinCorner.CornerRadius = UDim.new(0, 8)

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -32, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.BorderSizePixel = 0

local CloseCorner = Instance.new("UICorner", CloseBtn)
CloseCorner.CornerRadius = UDim.new(0, 8)

local Content = Instance.new("Frame", Frame)
Content.Size = UDim2.new(1, -14, 1, -48)
Content.Position = UDim2.new(0, 7, 0, 41)
Content.BackgroundTransparency = 1

local function CreateButton(text, position, callback)
local btn = Instance.new("TextButton", Content)
btn.Size = UDim2.new(1, 0, 0, 36)
btn.Position = position
btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
btn.Text = text
btn.TextColor3 = Color3.fromRGB(220, 220, 220)
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
    TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()  
    TweenService:Create(glow, TweenInfo.new(0.1), {Thickness = 2, Transparency = 0.4}):Play()  
end)  
  
btn.MouseLeave:Connect(function()  
    TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()  
    TweenService:Create(glow, TweenInfo.new(0.1), {Thickness = 0, Transparency = 1}):Play()  
end)  
  
btn.MouseButton1Click:Connect(function()  
    callback(btn)  
end)  
  
return btn

end

local GodmodeBtn = CreateButton(
"GODMODE: OFF",
UDim2.new(0, 0, 0, 0),
function(btn)
if godmodeCooldown then return end
godmodeCooldown = true

GodModeActive = not GodModeActive  
    btn.Text = "GODMODE: " .. (GodModeActive and "ON" or "OFF")  
      
    if GodModeActive then  
        startGodmode()  
    else  
        stopGodmode()  
    end  
      
    task.wait(0.1)  
    godmodeCooldown = false  
end

)

local AntiTPBtn = CreateButton(
"ANTI-TP: OFF",
UDim2.new(0, 0, 0, 43),
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
UDim2.new(0, 0, 0, 86),
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

local ConfirmFrame = Instance.new("Frame", Frame)
ConfirmFrame.Size = UDim2.new(1, 0, 1, 0)
ConfirmFrame.Position = UDim2.new(0, 0, 0, 0)
ConfirmFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ConfirmFrame.BorderSizePixel = 0
ConfirmFrame.Visible = false
ConfirmFrame.ZIndex = 20
ConfirmFrame.BackgroundTransparency = 0.05

local ConfirmCorner = Instance.new("UICorner", ConfirmFrame)
ConfirmCorner.CornerRadius = UDim.new(0, 12)

local ConfirmStroke = Instance.new("UIStroke", ConfirmFrame)
ConfirmStroke.Thickness = 3
ConfirmStroke.Color = Color3.fromRGB(60, 60, 60)

local ConfirmText = Instance.new("TextLabel", ConfirmFrame)
ConfirmText.Size = UDim2.new(1, -20, 0, 60)
ConfirmText.Position = UDim2.new(0, 10, 0, 45)
ConfirmText.Text = "Are you sure you want\nto close the GUI?"
ConfirmText.TextColor3 = Color3.fromRGB(220, 220, 220)
ConfirmText.BackgroundTransparency = 1
ConfirmText.Font = Enum.Font.GothamBold
ConfirmText.TextSize = 14
ConfirmText.TextXAlignment = Enum.TextXAlignment.Center
ConfirmText.ZIndex = 21

local YesBtn = Instance.new("TextButton", ConfirmFrame)
YesBtn.Size = UDim2.new(0, 95, 0, 35)
YesBtn.Position = UDim2.new(0, 15, 1, -50)
YesBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
YesBtn.Text = "YES"
YesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
YesBtn.Font = Enum.Font.GothamBold
YesBtn.TextSize = 14
YesBtn.BorderSizePixel = 0
YesBtn.ZIndex = 21

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
NoBtn.ZIndex = 21

local NoCorner = Instance.new("UICorner", NoBtn)
NoCorner.CornerRadius = UDim.new(0, 9)

local isMinimized = false
local isClosing = false
local minimizeCooldown = false
local closeCooldown = false
local confirmDialogOpen = false

MinimizeBtn.MouseButton1Click:Connect(function()
if minimizeCooldown or confirmDialogOpen then return end
minimizeCooldown = true

isMinimized = not isMinimized  
  
if isMinimized then  
    TweenService:Create(Frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {  
        Size = UDim2.new(0, 240, 0, 35)  
    }):Play()  
    MinimizeBtn.Text = "+"  
else  
    TweenService:Create(Frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {  
        Size = UDim2.new(0, 240, 0, 200)  
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

if isMinimized then  
    isMinimized = false  
    TweenService:Create(Frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {  
        Size = UDim2.new(0, 240, 0, 200)  
    }):Play()  
    MinimizeBtn.Text = "−"  
    task.wait(0.1)  
end  
  
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
Size = UDim2.new(0, 240, 0, 200),
Position = UDim2.new(0.5, -120, 0.5, -100)
}):Play()

player.CharacterAdded:Connect(function()
task.wait(0.1)
if GodModeActive then
startGodmode()
end
if AntiTPActive then
startAntiTP()
end
if AntiFallActive then
startAntiFall()
end
end)
