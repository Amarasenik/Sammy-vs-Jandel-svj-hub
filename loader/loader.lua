--======================================================
-- WALL WARS UTILITY v3.6 (Final Release - Anti-Bug Engine)
--======================================================

-- Безопасный обход бага инжектора с DataModel "Ugc"
local Players = game.Players or game:findService("Players")
local Workspace = game.Workspace or game:findService("Workspace")
local UserInputService = game.UserInputService or game:findService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService") -- для хука доната

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

player.CharacterAdded:Connect(function(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
end)

-- ГЛОБАЛЬНЫЕ НАСТРОЙКИ
local ESP_ORE_ENABLED = true
local TARGET_PLAYER = nil 
local ORE_ESPs = {}

-- Создаем крутилку (Флинг) на клавишу B
local flingObject = Instance.new("BodyAngularVelocity")
flingObject.Name = "SVJ_Fling"
flingObject.MaxTorque = Vector3.new(0, math.huge, 0)
flingObject.AngularVelocity = Vector3.new(0, 99999, 0)

--======================================================
-- 1. БИНДЫ (УПРАВЛЕНИЕ СКОРОСТЬЮ)
--======================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- [B] - Безопасный разгон (150) + Флинг
    if input.KeyCode == Enum.KeyCode.B then
        if humanoid and hrp then
            humanoid.WalkSpeed = 150
            Workspace.Gravity = 196.2
            flingObject.Parent = hrp
            print("SVJ: СКОРОСТЬ 150 + ФЛИНГ АКТИВИРОВАН")
        end
    end
    
    -- [C] - Полный тормоз / Сброс
    if input.KeyCode == Enum.KeyCode.C then
        if humanoid and hrp then
            humanoid.WalkSpeed = 16
            if hrp:FindFirstChild("SVJ_Fling") then hrp.SVJ_Fling.Parent = nil end
            hrp.Velocity = Vector3.new(0,0,0)
            hrp.RotVelocity = Vector3.new(0,0,0)
            print("SVJ: СБРОС СКОРОСТИ")
        end
    end
end)

--======================================================
-- 2. СЕТЕВАЯ ДЖАМП-АТАКА (ТОЛЬКО SWORD + REMOTE)
--======================================================
local function getActualSword()
    -- Ищем строго предмет с оригинальным именем "Sword"
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name == "Sword" then return tool end
    end
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") and tool.Name == "Sword" then return tool end
    end
    return nil
end

task.spawn(function()
    while true do
        task.wait(0.05) -- Ускоренная частота проверки
        
        if TARGET_PLAYER and TARGET_PLAYER.Character and hrp and humanoid then
            local tChar = TARGET_PLAYER.Character
            local tHrp = tChar:FindFirstChild("HumanoidRootPart")
            local tHum = tChar:FindFirstChild("Humanoid")
            
            if tHrp and tHum and tHum.Health > 0 then
                local sword = getActualSword()
                
                if sword then
                    -- Берем меч в руки, если он в рюкзаке
                    if sword.Parent == player.Backpack then
                        humanoid:EquipTool(sword)
                        task.wait(0.02)
                    end
                    
                    -- Упреждение движения цели
                    local targetVelocity = tHrp.AssemblyLinearVelocity
                    local predictedPosition = tHrp.CFrame + (targetVelocity * 0.05)
                    
                    -- Пикирование сверху
                    hrp.CFrame = predictedPosition * CFrame.new(0, 2.5, 0)
                    
                    -- МГНОВЕННЫЙ СЕТЕВОЙ УДАР (Молния из Dex)
                    local remote = sword:FindFirstChild("ActivateTool")
                    if remote then
                        remote:FireServer()
                    else
                        sword:Activate() -- Запасной вариант
                    end
                    
                    task.wait(0.02)
                    
                    -- Моментальный взлет вверх (Безопасная зона)
                    local freshHrp = tChar:FindFirstChild("HumanoidRootPart")
                    if freshHrp then
                        hrp.CFrame = freshHrp.CFrame * CFrame.new(0, 24, 0)
                    end
                    task.wait(0.15)
                else
                    -- Если меча нет, просто зависаем над врагом
                    hrp.CFrame = tHrp.CFrame * CFrame.new(0, 20, 0)
                end
            else
                TARGET_PLAYER = nil
            end
        end
    end
end)

--======================================================
-- 3. ИСПРАВЛЕННЫЙ ТАРГЕТНЫЙ ESP НА ПАПКУ ORES
--======================================================
local function applyOreESP(part)
    if not part:IsA("BasePart") or ORE_ESPs[part] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "SVJ_Ore_Highlight"
    highlight.Adornee = part
    highlight.FillColor = Color3.fromRGB(255, 215, 0) -- Золотой цвет
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.3
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = ESP_ORE_ENABLED
    highlight.Parent = part
    
    ORE_ESPs[part] = highlight
end

task.spawn(function()
    -- Ждем загрузки папки ores, которая лежит рядом с block
    local oresFolder = Workspace:WaitForChild("ores", 5) or Workspace:FindFirstChild("ores", true)
    if oresFolder then
        for _, part in ipairs(oresFolder:GetChildren()) do applyOreESP(part) end
        oresFolder.ChildAdded:Connect(applyOreESP)
        print("SVJ: Оптимизированный ESP на папку Ores успешно запущен!")
    else
        print("SVJ: Предупреждение! Папка 'ores' не найдена в корне.")
    end
end)

--======================================================
-- 4. МЕТОД ПРИЗРАКА (СНОС ВОРОТ И NOBUILDZONE)
--======================================================
local function makeGhost(part, transparency)
    if part and part:IsA("BasePart") then
        part.CanCollide = false
        part.CanTouch = false
        part.Transparency = transparency
    end
end

-- А) Уничтожение зон NoBuild по твоему пути из Студии
task.spawn(function()
    local nbFolder = Workspace:WaitForChild("CurrentGame", 5)
        and Workspace.CurrentGame:WaitForChild("LocalPositions", 5)
        and Workspace.CurrentGame.LocalPositions:WaitForChild("NoBuildZone", 5)
        
    if nbFolder then
        for _, part in ipairs(nbFolder:GetChildren()) do
            if part.Name == "NoBuildZone" then makeGhost(part, 1) end
        end
        nbFolder.ChildAdded:Connect(function(part)
            if part.Name == "NoBuildZone" then task.wait(0.1) makeGhost(part, 1) end
        end)
        print("SVJ: Все зоны NoBuildZone успешно аннигилированы!")
    end
end)

-- Б) Снос 12 Gate и 2 InvisibleGate прямо из Workspace
task.spawn(function()
    local function checkAndDestroyGate(obj)
        if obj:IsA("BasePart") then
            if obj.Name == "Gate" then
                makeGhost(obj, 0.5) -- Полупрозрачные, чтобы видеть проход
            elseif obj.Name == "InvisibleGate" then
                makeGhost(obj, 1) -- Полностью невидимые
            end
        end
    end
    
    for _, obj in ipairs(Workspace:GetChildren()) do checkAndDestroyGate(obj) end
    Workspace.ChildAdded:Connect(checkAndDestroyGate)
    print("SVJ: Все ворота Gate и InvisibleGate переведены в режим призрака!")
end)

--======================================================
-- 5. АНТИ-ДОНАТ ЩИТ (BLOCK GAMEPASS PROMPTS)
--======================================================
local hook
hook = hookmetamethod(game, "__index", function(self, key)
    if self == MarketplaceService and (key == "PromptGamePassPurchase" or key == "PromptPurchase" or key == "PromptProductPurchase") then
        return function() 
            print("SVJ: Заблокирована наглая попытка впарить геймпас!")
            return nil 
        end
    end
    return hook(self, key)
end)

--======================================================
-- 6. ГРАФИЧЕСКИЙ ИНТЕРФЕЙС (GUI)
--======================================================
pcall(function()
    local oldGui = player:WaitForChild("PlayerGui"):FindFirstChild("WallWarsHub_Safe")
    if oldGui then oldGui:Destroy() end

    local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui.Name = "WallWarsHub_Safe"
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.fromScale(0.35, 0.65)
    frame.Position = UDim2.fromScale(0.05, 0.2)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.fromScale(1, 0.12)
    title.BackgroundTransparency = 1
    title.Text = "SVJ HUB v3.6"
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.TextColor3 = Color3.fromRGB(255, 215, 0)

    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.fromScale(0.55, 0.8)
    scroll.Position = UDim2.fromScale(0.05, 0.15)
    scroll.BackgroundTransparency = 0.9
    scroll.BackgroundColor3 = Color3.new(0, 0, 0)
    scroll.ScrollBarThickness = 4

    local listLayout = Instance.new("UIListLayout", scroll)
    listLayout.Padding = UDim.new(0, 5)

    local function updatePlayerList()
        for _, child in ipairs(scroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
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
                
                pBtn.MouseButton1Click:Connect(function() TARGET_PLAYER = p print("Цель выбрана: "..p.Name) end)
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
    
    createRightBtn("TOGGLE ORE ESP", Color3.fromRGB(255, 215, 0), function()
        ESP_ORE_ENABLED = not ESP_ORE_ENABLED
        for _, h in pairs(ORE_ESPs) do if h then h.Enabled = ESP_ORE_ENABLED end end
    end)
    
    createRightBtn("TP RED BASE", Color3.fromRGB(255, 100, 100), function() if hrp then hrp.CFrame = CFrame.new(574, 640.5, -5664) + Vector3.new(0, 3, 0) end end)
    createRightBtn("TP GREEN BASE", Color3.fromRGB(100, 255, 100), function() if hrp then hrp.CFrame = CFrame.new(1557, 640.6, -5664) + Vector3.new(0, 3, 0) end end)

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

print("SVJ HUB v3.6 УСПЕШНО ЗАПУЩЕН! Ворота испарились, NoBuild снят, донат заблокирован.")
