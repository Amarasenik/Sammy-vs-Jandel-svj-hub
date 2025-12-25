--========================
-- SVJ SCRIPT HUB v6.1
-- ESP ORE + TP FLAG + AUTO FARM + FAST HEALTH 500 + HEARTS TOGGLE
--========================

-- SERVICES
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

--========================
-- ORE ESP
--========================

local ESP_ENABLED = true
local ESPs = {}

local function addESP(model)
	if not model:IsA("Model") then return end
	if ESPs[model] then return end

	local h = Instance.new("Highlight")
	h.Name = "ORE_ESP"
	h.Adornee = model
	h.FillColor = Color3.fromRGB(255,255,0)
	h.OutlineColor = Color3.fromRGB(255,255,255)
	h.FillTransparency = 0.25
	h.OutlineTransparency = 0
	h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	h.Enabled = ESP_ENABLED
	h.Parent = model

	ESPs[model] = h
end

for _,v in ipairs(workspace:GetDescendants()) do
	if v:IsA("Model") and v.Name == "Ore" then
		addESP(v)
	end
end

workspace.DescendantAdded:Connect(function(v)
	if v:IsA("Model") and v.Name == "Ore" then
		task.wait(0.05)
		addESP(v)
	end
end)

--========================
-- FAST HEALTH (500 HP)
--========================

local GOD_HEALTH = false
local MAX_HEALTH = 500

humanoid.HealthChanged:Connect(function(hp)
	if GOD_HEALTH and hp < humanoid.MaxHealth then
		humanoid.Health = humanoid.MaxHealth
	end
end)

--========================
-- GUI
--========================

local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "SVJHubGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.25, 0.65)
frame.Position = UDim2.fromScale(0.05, 0.18)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,16)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.fromScale(1,0.08)
title.BackgroundTransparency = 1
title.Text = "SVJ SCRIPT HUB"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255,215,0)

--========================
-- ESP BUTTON
--========================

local espBtn = Instance.new("TextButton", frame)
espBtn.Size = UDim2.fromScale(0.8,0.075)
espBtn.Position = UDim2.fromScale(0.1,0.1)
espBtn.Text = "ESP ORE : ON"
espBtn.Font = Enum.Font.GothamBold
espBtn.TextScaled = true
espBtn.BackgroundColor3 = Color3.fromRGB(255,215,0)
espBtn.TextColor3 = Color3.new(0,0,0)
Instance.new("UICorner", espBtn).CornerRadius = UDim.new(0,12)

espBtn.MouseButton1Click:Connect(function()
	ESP_ENABLED = not ESP_ENABLED
	for _,h in pairs(ESPs) do
		h.Enabled = ESP_ENABLED
	end
	espBtn.Text = ESP_ENABLED and "ESP ORE : ON" or "ESP ORE : OFF"
end)

--========================
-- AUTO FARM BUTTON
--========================

local AUTO_FARM = false
local autoFarmLoaded = false

local autoFarmBtn = Instance.new("TextButton", frame)
autoFarmBtn.Size = UDim2.fromScale(0.8,0.075)
autoFarmBtn.Position = UDim2.fromScale(0.1,0.19)
autoFarmBtn.Text = "AUTO FARM : OFF"
autoFarmBtn.Font = Enum.Font.GothamBold
autoFarmBtn.TextScaled = true
autoFarmBtn.BackgroundColor3 = Color3.fromRGB(120,120,255)
autoFarmBtn.TextColor3 = Color3.new(0,0,0)
Instance.new("UICorner", autoFarmBtn).CornerRadius = UDim.new(0,12)

autoFarmBtn.MouseButton1Click:Connect(function()
	AUTO_FARM = not AUTO_FARM

	if AUTO_FARM then
		autoFarmBtn.Text = "AUTO FARM : ON"
		autoFarmBtn.BackgroundColor3 = Color3.fromRGB(80,255,120)

		if not autoFarmLoaded then
			autoFarmLoaded = true
			task.spawn(function()
				loadstring(game:HttpGet("https://pastebin.com/raw/HtXhtCku"))()
			end)
		end
	else
		autoFarmBtn.Text = "AUTO FARM : OFF"
		autoFarmBtn.BackgroundColor3 = Color3.fromRGB(120,120,255)
	end
end)

--========================
-- TP FLAG LITE
--========================

local tpBtn = Instance.new("TextButton", frame)
tpBtn.Size = UDim2.fromScale(0.8,0.075)
tpBtn.Position = UDim2.fromScale(0.1,0.28)
tpBtn.Text = "TP FLAG LITE"
tpBtn.Font = Enum.Font.GothamBold
tpBtn.TextScaled = true
tpBtn.BackgroundColor3 = Color3.fromRGB(0,255,150)
tpBtn.TextColor3 = Color3.new(0,0,0)
Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0,12)

local flagFrame = Instance.new("Frame", frame)
flagFrame.Size = UDim2.fromScale(0.8,0.18)
flagFrame.Position = UDim2.fromScale(0.1,0.37)
flagFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
flagFrame.Visible = false
Instance.new("UICorner", flagFrame).CornerRadius = UDim.new(0,12)

tpBtn.MouseButton1Click:Connect(function()
	flagFrame.Visible = not flagFrame.Visible
end)

local redBtn = Instance.new("TextButton", flagFrame)
redBtn.Size = UDim2.fromScale(0.8,0.42)
redBtn.Position = UDim2.fromScale(0.1,0.05)
redBtn.Text = "TP TO RED"
redBtn.Font = Enum.Font.GothamBold
redBtn.TextScaled = true
redBtn.BackgroundColor3 = Color3.fromRGB(255,0,0)
redBtn.TextColor3 = Color3.new(0,0,0)
Instance.new("UICorner", redBtn).CornerRadius = UDim.new(0,12)

redBtn.MouseButton1Click:Connect(function()
	hrp.CFrame = CFrame.new(574, 640.503, -5664) * CFrame.new(0,3,0)
end)

local greenBtn = Instance.new("TextButton", flagFrame)
greenBtn.Size = UDim2.fromScale(0.8,0.42)
greenBtn.Position = UDim2.fromScale(0.1,0.53)
greenBtn.Text = "TP TO GREEN"
greenBtn.Font = Enum.Font.GothamBold
greenBtn.TextScaled = true
greenBtn.BackgroundColor3 = Color3.fromRGB(0,255,0)
greenBtn.TextColor3 = Color3.new(0,0,0)
Instance.new("UICorner", greenBtn).CornerRadius = UDim.new(0,12)

greenBtn.MouseButton1Click:Connect(function()
	hrp.CFrame = CFrame.new(1557, 640.623, -5664) * CFrame.new(0,3,0)
end)

--========================
-- FAST HEALTH BUTTON
--========================

local godBtn = Instance.new("TextButton", frame)
godBtn.Size = UDim2.fromScale(0.8,0.075)
godBtn.Position = UDim2.fromScale(0.1,0.58)
godBtn.Text = "FAST HEALTH : OFF"
godBtn.Font = Enum.Font.GothamBold
godBtn.TextScaled = true
godBtn.BackgroundColor3 = Color3.fromRGB(255,80,80)
godBtn.TextColor3 = Color3.new(0,0,0)
Instance.new("UICorner", godBtn).CornerRadius = UDim.new(0,12)

godBtn.MouseButton1Click:Connect(function()
	GOD_HEALTH = not GOD_HEALTH
	if GOD_HEALTH then
		humanoid.MaxHealth = MAX_HEALTH
		humanoid.Health = MAX_HEALTH
		godBtn.Text = "FAST HEALTH : ON (500)"
		godBtn.BackgroundColor3 = Color3.fromRGB(80,255,80)
	else
		humanoid.MaxHealth = 100
		humanoid.Health = 100
		godBtn.Text = "FAST HEALTH : OFF"
		godBtn.BackgroundColor3 = Color3.fromRGB(255,80,80)
	end
end)

--========================
-- HEARTS UI TOGGLE
--========================

local healthUI
pcall(function()
	healthUI = player.PlayerGui.Scene_MainTop.Health
end)

local heartsVisible = true

local heartsBtn = Instance.new("TextButton", frame)
heartsBtn.Size = UDim2.fromScale(0.8,0.075)
heartsBtn.Position = UDim2.fromScale(0.1,0.67)
heartsBtn.Text = "HEARTS : ON"
heartsBtn.Font = Enum.Font.GothamBold
heartsBtn.TextScaled = true
heartsBtn.BackgroundColor3 = Color3.fromRGB(255,80,80)
heartsBtn.TextColor3 = Color3.new(0,0,0)
Instance.new("UICorner", heartsBtn).CornerRadius = UDim.new(0,12)

heartsBtn.MouseButton1Click:Connect(function()
	if not healthUI then return end
	heartsVisible = not heartsVisible
	healthUI.Visible = heartsVisible
	heartsBtn.Text = heartsVisible and "HEARTS : ON" or "HEARTS : OFF"
end)

--========================
-- HIDE / SHOW GUI
--========================

local hideBtn = Instance.new("TextButton", frame)
hideBtn.Size = UDim2.fromScale(0.8,0.075)
hideBtn.Position = UDim2.fromScale(0.1,0.76)
hideBtn.Text = "HIDE GUI"
hideBtn.Font = Enum.Font.GothamBold
hideBtn.TextScaled = true
hideBtn.BackgroundColor3 = Color3.fromRGB(200,200,200)
hideBtn.TextColor3 = Color3.new(0,0,0)
Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0,12)

hideBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
end)

local showBtn = Instance.new("TextButton", gui)
showBtn.Size = UDim2.fromScale(0.08,0.05)
showBtn.Position = UDim2.fromScale(0.01,0.01)
showBtn.Text = "SHOW"
showBtn.Font = Enum.Font.GothamBold
showBtn.TextScaled = true
showBtn.BackgroundColor3 = Color3.fromRGB(255,215,0)
showBtn.TextColor3 = Color3.new(0,0,0)
Instance.new("UICorner", showBtn).CornerRadius = UDim.new(0,10)

showBtn.MouseButton1Click:Connect(function()
	frame.Visible = true
end)
