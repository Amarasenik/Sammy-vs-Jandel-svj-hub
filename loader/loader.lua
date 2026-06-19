--======================================================
-- WALL WARS UTILITY v3.7 (Fix Release - Box ESP & Event Engine)
--======================================================
print("начало инжекта")

local Players = game.Players or game:findService("Players")
local Workspace = game.Workspace or game:findService("Workspace")
local UserInputService = game.UserInputService or game:findService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local character = player.Character
local hrp = character and character:FindFirstChild("HumanoidRootPart")
local humanoid = character and character:FindFirstChild("Humanoid")

player.CharacterAdded:Connect(function(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
    print("SVJ: Персонаж обновился и готов!")
end)

if character and not hrp then
    hrp = character:FindFirstChild("HumanoidRootPart")
    humanoid = character:FindFirstChild("Humanoid")
end

local ESP_ORE_ENABLED = true
local TARGET_PLAYER = nil 
local ORE_ESPs = {}

local flingObject = Instance.new("BodyAngularVelocity")
flingObject.Name = "SVJ_Fling"
flingObject.MaxTorque = Vector3.new(0, math.huge, 0)
flingObject.AngularVelocity = Vector3.new(0, 99999, 0)

--======================================================
-- 1. БИНДЫ (УПРАВЛЕНИЕ СКОРОСТЬЮ)
--======================================================
print("бинды")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.B then
        if humanoid and hrp then
            humanoid.WalkSpeed = 150
            Workspace.Gravity = 196.2
            flingObject.Parent = hrp
            print("SVJ: СКОРОСТЬ 150 + ФЛИНГ АКТИВИРОВАН")
        end
    end
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
-- 2. СЕТЕВАЯ ДЖАМП-АТАКА (ФИКС BINDABLE EVENT)
--======================================================
print("атака")
local function getActualSword()
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
        task.wait(0.05)
        if TARGET_PLAYER and TARGET_PLAYER.Character and hrp and humanoid then
            local tChar = TARGET_PLAYER.Character
            local tHrp = tChar:FindFirstChild("HumanoidRootPart")
            local tHum = tChar:FindFirstChild("Humanoid")
            
            if tHrp and tHum and tHum.Health > 0 then
                local sword = getActualSword()
                if sword then
                    if sword.Parent == player.Backpack then
                        humanoid:EquipTool(sword)
                        task.wait(0.02)
                    end
                    
                    local targetVelocity = tHrp.AssemblyLinearVelocity
                    local predictedPosition = tHrp.CFrame + (targetVelocity * 0.05)
                    hrp.CFrame = predictedPosition * CFrame.new(0, 2.5, 0)
                    
                    local remote = sword:FindFirstChild("ActivateTool")
                    if remote then
                        if remote:IsA("BindableEvent") then
                            remote:Fire() -- Фикс: вызываем как обычный ивент!
                        local_remote_fired = true
                        else
                            remote:FireServer()
                        end
                    else
                        sword:Activate()
                    end
                    
                    task.wait(0.02)
                    local freshHrp = tChar:FindFirstChild("HumanoidRootPart")
                    if freshHrp then
                        hrp.CFrame = freshHrp.CFrame * CFrame.new(0, 24, 0)
                    end
                    task.wait(0.15)
                else
                    hrp.CFrame = tHrp.CFrame * CFrame.new(0, 20, 0)
                end
            else
                TARGET_PLAYER = nil
            end
        end
    end
end)

--======================================================
-- 3. НЕУБИВАЕМЫЙ BOX-ESP НА ПАПКУ ORES (РАБОТАЕТ ВЕЗДЕ)
--======================================================
print("есп")
local function applyOreESP(part)
    if not part:IsA("BasePart") or ORE_ESPs[part] then return end
    
    -- Создаем коробку-подсветку сквозь стены
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "SVJ_Ore_Box"
    box.Size = part.Size + Vector3.new(0.1, 0.1, 0.1)
    box.Color3 = Color3.fromRGB(255, 215, 0) -- Золотой
    box.Transparency = 0.4
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Adornee = part
    box.Visible = ESP_ORE_ENABLED
    box.Parent = player:WaitForChild("PlayerGui") -- Надежное место для рендера adornment
    
    ORE_ESPs[part] = box
end

task.spawn(function()
    local oresFolder = Workspace:WaitForChild("CurrentGame", 5) 
        and Workspace.CurrentGame:WaitForChild("SpawnPool", 5) 
        and Workspace.CurrentGame.SpawnPool:WaitForChild("Ores", 5)
        or Workspace:FindFirstChild("Ores", true)
    
    if oresFolder then
        -- Проверяем все парты внутри папки руды
        for _, child in ipairs(oresFolder:GetChildren()) do
            if child:IsA("BasePart") then 
                applyOreESP(child) 
            end
            for _, subChild in ipairs(child:GetDescendants()) do
                if subChild:IsA("BasePart") then applyOreESP(subChild) end
            end
        end
        
        oresFolder.ChildAdded:Connect(function(child)
            task.wait(0.2)
            if child:IsA("BasePart") then applyOreESP(child) end
            for _, subChild in ipairs(child:GetDescendants()) do
                if subChild:IsA("BasePart") then applyOreESP(subChild) end
            end
        end)
        print("SVJ: Железный BOX-ESP на папку Ores успешно запущен!")
    else
        print("SVJ: Предупреждение! Папка 'Ores' не найдена.")
    end
end)

--======================================================
-- 4. МЕТОД ПРИЗРАКА (СНОС ВОРОТ И NOBUILDZONE)
--======================================================
print("снос")
local function makeGhost(part, transparency)
    if part and part:IsA("BasePart") then
        part.CanCollide = false
        part.CanTouch = false
        part.Transparency = transparency
    end
end

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

task.spawn(function()
    local function checkAndDestroyGate(obj)
        if obj:IsA("BasePart") then
            if obj.Name == "Gate" then
                makeGhost(obj, 0.5)
            elseif obj.Name == "InvisibleGate" then
                makeGhost(obj, 1)
            end
        end
    end
    for _, obj in ipairs(Workspace:GetChildren()) do checkAndDestroyGate(obj) end
    Workspace.ChildAdded:Connect(checkAndDestroyGate)
    print("SVJ: Все ворота Gate и InvisibleGate переведены в режим призрака!")
end)

--======================================================
-- 5. АНТИ-ДОНАТ ЩИТ (БЕЗОПАСНЫЙ ХУК)
--======================================================
print("антидонат")
pcall(function()
    local hookfn = hookmetamethod or (getrawmetatable and function(obj, mt, f) 
        local old = getrawmetatable(obj)[mt]
        setreadonly(getrawmetatable(obj), false)
        getrawmetatable(obj)[mt] = f
        return old
    end)

    if hookfn then
        local hook
        hook = hookfn(game, "__index", function(self, key)
            if self == MarketplaceService and (key == "PromptGamePassPurchase" or key == "PromptPurchase" or key == "PromptProductPurchase") then
                return function() 
                    print("SVJ: Заблокирована наглая попытка впарить геймпас!")
                    return nil 
                end
            end
            return hook(self, key)
        end)
        print("SVJ: Анти-донат щит успешно активирован.")
    else
        print("SVJ: Хуки не поддерживаются инжектором, пропускаем донат-щит.")
    end
end)

--======================================================
-- 6. ГРАФИЧЕСКИЙ ИНТЕРФЕЙС (GUI)
--======================================================
print("графон")
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
    title.Text = "SVJ HUB v3.7"
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
        for _, box in pairs(ORE_ESPs) do if box then box.Visible = ESP_ORE_ENABLED end end
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

print("SVJ HUB v3.7 ЗАПУЩЕН! Ошибки ивента устранены, ESP переведен на Adornments.")
print("конец инжекта")
