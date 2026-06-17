--======================================================
-- WALL WARS UTILITY v3.1 (Fixed Injection Edition)
--======================================================

local Players = game:Service("Players")
local UserInputService = game:Service("UserInputService")
local RunService = game:Service("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

player.CharacterAdded:Connect(function(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
end)

-- СОСТОЯНИЕ ФУНКЦИЙ
local ESP_ORE_ENABLED = true
local TARGET_PLAYER = nil 
local ESPs = {}

--======================================================
-- 1. ESP ORE (Подсветка руды)
--======================================================
local function addESP(model)
    if not model:IsA("Model") or ESPs[model] then return end
    local h = Instance.new("Highlight")
    h.Name = "ORE_ESP"
    h.Adornee = model
    h.FillColor = Color3.fromRGB(255, 215, 0)
    h.OutlineColor = Color3.fromRGB(255, 255, 255)
    h.FillTransparency = 0.3
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Enabled = ESP_ORE_ENABLED
    h.Parent = model
    ESPs[model] = h
end

for _, v in ipairs(workspace:GetDescendants()) do
    if v:IsA("Model") and v.Name == "Ore" then addESP(v) end
end

workspace.DescendantAdded:Connect(function(v)
    if v:IsA("Model") and v.Name == "Ore" then 
        task.wait(0.2) 
        addESP(v) 
    end
end)

--======================================================
-- 2. НАДЕЖНАЯ ЛОГИКА АТАК С НЕБА (Killer Jump)
--======================================================
task.spawn(function()
    while true do
        task.wait(0.1)
        
        if TARGET_PLAYER and TARGET_PLAYER.Character and hrp and humanoid then
            local tChar = TARGET_PLAYER.Character
            local tHrp = tChar:FindFirstChild("HumanoidRootPart")
            local tHum = tChar:FindFirstChild("Humanoid")
            
            if tHrp and tHum and tHum.Health > 0 then
                -- Умный поиск меча/инструмента
                local sword = player.Backpack:FindFirstChildOfClass("Tool") or character:FindFirstChildOfClass("Tool")
                
                if sword then
                    -- Берем в руки, если он в рюкзаке
                    if sword.Parent == player.Backpack then
                        humanoid:EquipTool(sword)
                        task.wait(0.05)
                    end
                    
                    -- Считываем позицию с упреждением скорости
                    local targetVelocity = tHrp.AssemblyLinearVelocity
                    local predictedPosition = tHrp.CFrame + (targetVelocity * 0.05)
                    
                    -- Пикируем прямо на него
                    hrp.CFrame = predictedPosition * CFrame.new(0, 2.5, 0)
                    
                    -- Удар
                    sword:Activate()
                    task.wait(0.05)
                    
                    -- Отлетаем вверх над его новой позицией
                    local freshHrp = tChar:FindFirstChild("HumanoidRootPart")
                    if freshHrp then
                        hrp.CFrame = freshHrp.CFrame * CFrame.new(0, 24, 0)
                    end
                    
                    task.wait(0.2)
                else
                    -- Если меча нет, просто зависаем над ним
                    hrp.CFrame = tHrp.CFrame * CFrame.new(0, 20, 0)
                end
            else
                TARGET_PLAYER = nil
            end
        end
    end
end)

--======================================================
-- 3. ИНТЕРФЕЙС (GUI)
--======================================================
local gui = Instance.new("ScreenGui")
gui.Name = "WallWarsHub_v3_Fixed"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.35, 0.65)
frame.Position = UDim2.fromScale(0.05, 0.2)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.fromScale(1, 0.12)
title.BackgroundTransparency = 1
title.Text = "SVJ HUB v3.1"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255, 215, 0)

-- Список игроков (Скролл)
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.fromScale(0.55, 0.8)
scroll.Position = UDim2.fromScale(0.05, 0.15)
scroll.BackgroundTransparency = 0.9
scroll.BackgroundColor3 = Color3.new(1, 1, 1)
scroll.CanvasSize = UDim2.fromScale(0, 0)
scroll.ScrollBarThickness = 4

local listLayout = Instance.new("UIListLayout", scroll)
listLayout.Padding = UDim.new(0, 5)

-- Функция обновления списка игроков (Обернута в pcall для безопасности)
local function updatePlayerList()
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local count = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            count = count + 1
            
            local teamName = "No Team"
            local teamColor = Color3.fromRGB(200, 200, 200)
            
            pcall(function()
                if p.Team then
                    teamName = p.Team.Name
                    teamColor = p.Team.TeamColor.Color
                end
            end)
            
            local pBtn = Instance.new("TextButton", scroll)
            pBtn.Size = UDim2.new(0.95, 0, 0, 30)
            pBtn.Text = p.Name .. " [" .. teamName .. "]"
            pBtn.Font = Enum.Font.Gotham
            pBtn.TextSize = 12
            pBtn.TextColor3 = teamColor
            pBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4)
            
            pBtn.MouseButton1Click:Connect(function()
                TARGET_PLAYER = p
            end)
        end
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, count * 35)
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
task.spawn(updatePlayerList)

-- Правая панель кнопок
local rightFrame = Instance.new("Frame", frame)
rightFrame.Size = UDim2.fromScale(0.35, 0.8)
rightFrame.Position = UDim2.fromScale(0.62, 0.15)
rightFrame.BackgroundTransparency = 1

local rightLayout = Instance.new("UIListLayout", rightFrame)
rightLayout.Padding = UDim.new(0, 8)

local function createRightBtn(text, color, callback)
    local btn = Instance.new("TextButton", rightFrame)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(0, 0, 0)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
end

createRightBtn("STOP JUMP", Color3.fromRGB(255, 50, 50), function()
    TARGET_PLAYER = nil
end)

createRightBtn("ESP ORE", Color3.fromRGB(255, 215, 0), function()
    ESP_ORE_ENABLED = not ESP_ORE_ENABLED
    for _, h in pairs(ESPs) do if h then h.Enabled = ESP_ORE_ENABLED end end
end)

createRightBtn("TP RED", Color3.fromRGB(255, 100, 100), function()
    if hrp then hrp.CFrame = CFrame.new(574, 640.5, -5664) + Vector3.new(0, 3, 0) end
end)

createRightBtn("TP GREEN", Color3.fromRGB(100, 255, 100), function()
    if hrp then hrp.CFrame = CFrame.new(1557, 640.6, -5664) + Vector3.new(0, 3, 0) end
end)

-- Кнопка SHOW / HIDE
local showBtn = Instance.new("TextButton", gui)
showBtn.Size = UDim2.fromScale(0.12, 0.05)
showBtn.Position = UDim2.fromScale(0.02, 0.02)
showBtn.Text = "SHOW / HIDE"
showBtn.Font = Enum.Font.GothamBold
showBtn.TextScaled = true
showBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
showBtn.TextColor3 = Color3.new(0, 0, 0)
Instance.new("UICorner", showBtn).CornerRadius = UDim.new(0, 8)

showBtn.MouseButton1Click:Connect(function() 
    frame.Visible = not frame.Visible 
end)
