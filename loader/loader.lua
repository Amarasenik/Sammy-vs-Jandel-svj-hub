-- =========================
-- SVJ SCRIPT HUB v6.1 - Fruiter Aero Style
-- =========================

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
	h.FillTransparency = 0.3
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
-- GUI - Fruiter Aero Style
--========================
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "SVJHubGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.27,0.58)
frame.Position = UDim2.fromScale(0.05,0.2)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0
