-- ================== SVJ HUB (FULL INTEGRATED) ==================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

-- ========== SETTINGS ==========
local BARS_FOLDER = workspace.CurrentGame.SpawnPool.Bars
local TP_OFFSET_Y = 3
local SEARCH_RADIUS = 60
local MAX_STEPS = 10
local COOLDOWN = 1

-- ========== STATE ==========
local ESPEnabled = true
local MiniFarmEnabled = false
local HoldingE = false
local Busy = false

-- ========== GUI ==========
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "SVJ_HUB_GUI"

local function createButton(text, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,200,0,40)
    btn.Position = pos
    btn.Text = text
    btn.Parent = ScreenGui
    btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextScaled = true
    return btn
end

-- Buttons
local ESPButton = createButton("ESP Ore [ON]", UDim2.new(0,10,0,10))
local TPRedButton = createButton("TP to Red", UDim2.new(0,10,0,60))
local TPGreenButton = createButton("TP to Green", UDim2.new(0,10,0,110))
local MiniFarmButton = createButton("Mini Auto-Farm [OFF]", UDim2.new(0,10,0,160))

-- ========== FUNCTIONS ==========

-- ESP Function
local function highlightOre()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Ore" then
            if ESPEnabled and not obj:FindFirstChild("SVJ_Highlight") then
                local h = Instance.new("Highlight")
                h.Name = "SVJ_Highlight"
                h.FillColor = Color3.fromRGB(255,255,0)
                h.FillTransparency = 0.3
                h.OutlineTransparency = 0
                h.Parent = obj
            elseif not ESPEnabled then
                local h = obj:FindFirstChild("SVJ_Highlight")
                if h then h:Destroy() end
            end
        end
    end
end

-- TP Functions
local function getHRP()
    return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

local function tpToPosition(pos)
    local hrp = getHRP()
    if hrp then
        hrp.CFrame = CFrame.new(pos + Vector3.new(0,TP_OFFSET_Y,0))
    end
end

-- Mini Auto-Farm Functions
local function getNearestBars()
    local hrp = getHRP()
    if not hrp then return {} end
    local list = {}
    for _, obj in ipairs(BARS_FOLDER:GetChildren()) do
        if obj:IsA("BasePart") then
            local dist = (obj.Position - hrp.Position).Magnitude
            if dist <= SEARCH_RADIUS then
                table.insert(list, {part = obj, dist = dist})
            end
        end
    end
    table.sort(list, function(a,b) return a.dist < b.dist end)
    local result = {}
    for i = 1, math.min(MAX_STEPS, #list) do
        table.insert(result, list[i].part)
    end
    return result
end

local function tpToBar(part)
    local hrp = getHRP()
    if hrp then
        hrp.CFrame = CFrame.new(part.Position + Vector3.new(0,TP_OFFSET_Y,0))
    end
end

local function showHint(msg)
    StarterGui:SetCore("SendNotification", {
        Title = "SVJ HUB",
        Text = msg,
        Duration = 2
    })
end

local function runMiniFarm()
    if Busy then return end
    Busy = true
    local bars = getNearestBars()
    for _, bar in ipairs(bars) do
        if not MiniFarmEnabled or not HoldingE then break end
        tpToBar(bar)
        showHint("Нажми E для сбора")
        task.wait(COOLDOWN)
    end
    Busy = false
end

-- ========== BUTTON EVENTS ==========

ESPButton.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    ESPButton.Text = ESPEnabled and "ESP Ore [ON]" or "ESP Ore [OFF]"
    highlightOre()
end)

TPRedButton.MouseButton1Click:Connect(function()
    tpToPosition(Vector3.new(574, 640.503, -5664))
end)

TPGreenButton.MouseButton1Click:Connect(function()
    tpToPosition(Vector3.new(1557, 640.623, -5664))
end)

MiniFarmButton.MouseButton1Click:Connect(function()
    MiniFarmEnabled = not MiniFarmEnabled
    MiniFarmButton.Text = MiniFarmEnabled and "Mini Auto-Farm [ON]" or "Mini Auto-Farm [OFF]"
end)

-- ========== USER INPUT ==========

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.E then
        HoldingE = true
        if MiniFarmEnabled then
            task.spawn(runMiniFarm)
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then
        HoldingE = false
    end
end)

-- ========== RUN LOOP ==========
game:GetService("RunService").RenderStepped:Connect(function()
    highlightOre()
end)

-- =========================================================
