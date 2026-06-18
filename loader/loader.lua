--======================================================
-- WALL WARS UTILITY v3.4 (Smart Weapon & ESP Fix)
--======================================================

local Players = game.Players or game:findService("Players")
local Workspace = game.Workspace or game:findService("Workspace")
local UserInputService = game.UserInputService or game:findService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

player.CharacterAdded:Connect(function(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
end)

local ESP_ORE_ENABLED = true
local TARGET_PLAYER = nil 
local ESPs = {}

-- Флинг-крутилка
local flingObject = Instance.new("BodyAngularVelocity")
flingObject.Name = "SVJ_Fling"
flingObject.MaxTorque = Vector3.new(0, math.huge, 0)
flingObject.AngularVelocity = Vector3.new(0, 999, 0)

-- БИНДЫ (B и C)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.B then
        if humanoid and hrp then
            humanoid.WalkSpeed = 300
            Workspace.Gravity = 196.2
            flingObject.Parent = hrp
        end
    end
    if input.KeyCode == Enum.KeyCode.C then
        if humanoid and hrp then
            humanoid.WalkSpeed = 16
            if hrp:FindFirstChild("SVJ_Fling") then hrp.SVJ_Fling.Parent = nil end
            hrp.Velocity = Vector3.new(0,0,0)
            hrp.RotVelocity = Vector3.new(0,0,0)
        end
    end
end)

--======================================================
-- 1. УМНЫЙ ESP НА РУДУ (Сканирует всё)
--======================================================
local function addESP(obj)
    if ESPs[obj] then return end
    
    -- Проверяем, руда ли это (по имени блока или модели)
    local name = obj.Name:lower()
    if name:find("ore") or name:find("mineral") or name:find("руда") or (obj:IsA("Model") and name:find("block")) then
        local h = Instance.new("Highlight")
        h.Name = "ORE_ESP"
        h.Adornee = obj
        h.FillColor = Color3.fromRGB(255, 215, 0) -- Золотой
        h.OutlineColor = Color3.fromRGB(255, 255, 255)
        h.FillTransparency = 0.3
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Enabled = ESP_ORE_ENABLED
        h.Parent = obj
        ESPs[obj] = h
    end
end

-- Первичный запуск поиска руды
for _, v in ipairs(Workspace:GetDescendants()) do addESP(v) end
-- Поиск новых блоков (если они спавнятся)
Workspace.DescendantAdded:Connect(function(v)
    task.wait(0.1)
    addESP(v)
end)

--======================================================
-- 2. ИСПРАВЛЕННАЯ АТАКА С НЕБА (Только оружие!)
--======================================================
local function getActualWeapon()
    -- Ищем предмет в рюкзаке или в руках, который НЕ является блоком
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and not tool.Name:lower():find("block") and not tool.Name:lower():find("блок") then
            return tool
        end
    end
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") and not tool.Name:lower():find("block") and not tool.Name:lower():find("блок") then
            return tool
        end
    end
    return nil
end

task.spawn(function()
    while true do
        task.wait(0.1)
        
        if TARGET_PLAYER and TARGET_PLAYER.Character and hrp and humanoid then
            local tChar = TARGET_PLAYER.Character
            local tHrp = tChar:FindFirstChild("HumanoidRootPart")
            local tHum = tChar:FindFirstChild("Humanoid")
            
            if tHrp and tHum and tHum.Health > 0 then
                local sword = getActualWeapon() -- Берем ТОЛЬКО кирку или меч!
                
                if sword then
                    if sword.Parent == player.Backpack then
                        humanoid:EquipTool(sword)
                        task.wait(0.05)
                    end
                    
                    local targetVelocity = tHrp.AssemblyLinearVelocity
                    local predictedPosition = tHrp.CFrame + (targetVelocity * 0.05)
                    
                    hrp.CFrame = predictedPosition * CFrame.new(0, 2.5, 0)
                    sword:Activate()
                    task.wait(0.05)
                    
                    local freshHrp = tChar:FindFirstChild("HumanoidRootPart")
                    if freshHrp then
                        hrp.CFrame = freshHrp.CFrame * CFrame.new(0, 24, 0)
                    end
                    task.wait(0.2)
                else
                    -- Если оружия нет вообще, просто летаем над ним
                    hrp.CFrame = tHrp.CFrame * CFrame.new(0, 20, 0)
                end
            else
                TARGET_PLAYER = nil
            end
        end
    end
end)

--======================================================
-- 3. ИНТЕРФЕЙС
--======================================================
pcall(function()
    local oldGui = player:WaitForChild("PlayerGui"):FindFirstChild("WallWarsHub_Safe")
    if oldGui then oldGui:Destroy() end

    local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui.Name = "WallWarsHub_Safe"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.fromScale(0.35, 0.65)
    frame.Position = UDim2.fromScale(0.05, 0.2)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.fromScale(1, 0.12)
    title.BackgroundTransparency = 1
    title.Text = "SVJ HUB v3.4"
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.TextColor3 = Color3.fromRGB(255, 215, 0)

    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.fromScale(0.55, 0.8)
    scroll.Position = UDim2.fromScale(0.05, 0.15)
    scroll.BackgroundTransparency = 0.9
    scroll.BackgroundColor3 = Color3.new(0, 0, 0)
    scroll.CanvasSize = UDim2.fromScale(0, 0)
    scroll.ScrollBarThickness = 4

    local listLayout = Instance.new("UIListLayout", scroll)
    listLayout.Padding = UDim.new(0, 5)

    local function updatePlayerList()
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local count = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                count = count + 1
                local teamName = p.Team and p.Team.Name or "No Team"
                local teamColor = p.Team and p.Team.TeamColor.Color or Color3.fromRGB(200, 200, 200)
                
                local pBtn = Instance.new("TextButton", scroll)
                pBtn.Size = UDim2.new(0.95, 0, 0, 30)
                pBtn.Text = p.Name .. " [" .. teamName .. "]"
                pBtn.Font = Enum.Font.SourceSansBold
                pBtn.TextColor3 = teamColor
                pBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4)
                
                pBtn.MouseButton1Click:Connect(function() TARGET_PLAYER = p end)
            end
        end
        scroll.CanvasSize = UDim2.new(0, 0, 0, count * 35)
    end

    Players.PlayerAdded:Connect(updatePlayerList)
    Players.PlayerRemoving:Connect(updatePlayerList)
    updatePlayerList()

    local rightFrame = Instance.new("Frame", frame)
    rightFrame.Size = UDim2.fromScale(0.35, 0.8)
    rightFrame.Position = UDim2.fromScale(0.62, 0.15)
    rightFrame.BackgroundTransparency = 1
    Instance.new("UIListLayout", rightFrame).Padding = UDim.new(0, 8)

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

    createRightBtn("STOP JUMP", Color3.fromRGB(255, 50, 50), function() TARGET_PLAYER = nil end)
    createRightBtn("ESP ORE", Color3.fromRGB(255, 215, 0), function()
        ESP_ORE_ENABLED = not ESP_ORE_ENABLED
        for _, h in pairs(ESPs) do if h then h.Enabled = ESP_ORE_ENABLED end end
    end)
    createRightBtn("TP RED", Color3.fromRGB(255, 100, 100), function() if hrp then hrp.CFrame = CFrame.new(574, 640.5, -5664) + Vector3.new(0, 3, 0) end end)
    createRightBtn("TP GREEN", Color3.fromRGB(100, 255, 100), function() if hrp then hrp.CFrame = CFrame.new(1557, 640.6, -5664) + Vector3.new(0, 3, 0) end end)

    local showBtn = Instance.new("TextButton", gui)
    showBtn.Size = UDim2.fromScale(0.12, 0.05)
    showBtn.Position = UDim2.fromScale(0.02, 0.02)
    showBtn.Text = "SHOW / HIDE"
    showBtn.Font = Enum.Font.GothamBold
    showBtn.TextScaled = true
    showBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    showBtn.TextColor3 = Color3.new(0, 0, 0)
    Instance.new("UICorner", showBtn).CornerRadius = UDim.new(0, 8)
    showBtn.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)
end)

print("SVJ HUB v3.4 Запущен! Оружие профикшено, ESP настроен.")
