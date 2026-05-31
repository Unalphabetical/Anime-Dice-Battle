local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local CharacterTypes = require(ReplicatedStorage.Shared.CharacterTypes)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local SummonRemote = ReplicatedStorage:WaitForChild(CharacterTypes.SUMMON_REMOTE_NAME)

local gui: ScreenGui
local overlay: Frame
local summonFrame: Frame
local isVisible = false

local function hideSummonResult()
	if not isVisible then return end
	isVisible = false

	TweenService:Create(overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		BackgroundTransparency = 1,
	}):Play()

	local tween = TweenService:Create(summonFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 300, 0, 360),
		Position = UDim2.new(0.5, -150, 0.5, -180),
	})
	tween:Play()
	tween.Completed:Connect(function()
		if gui then gui.Enabled = false end
		if summonFrame then
			summonFrame.Size = UDim2.new(0, 340, 0, 420)
			summonFrame.Position = UDim2.new(0.5, -170, 0.5, -210)
		end
	end)
end

local function createSummonUI()
	gui = Instance.new("ScreenGui")
	gui.Name = "SummonGUI"
	gui.ResetOnSpawn = false
	gui.Enabled = false
	gui.Parent = playerGui

	overlay = Instance.new("Frame")
	overlay.Name = "Overlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.BorderSizePixel = 0
	overlay.Parent = gui

	overlay.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			hideSummonResult()
		end
	end)

	summonFrame = Instance.new("Frame")
	summonFrame.Name = "SummonFrame"
	summonFrame.Size = UDim2.new(0, 340, 0, 420)
	summonFrame.Position = UDim2.new(0.5, -170, 0.5, -210)
	summonFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
	summonFrame.BorderSizePixel = 0
	summonFrame.ClipsDescendants = true
	summonFrame.BackgroundTransparency = 1
	summonFrame.Parent = gui

	local uicorner = Instance.new("UICorner")
	uicorner.CornerRadius = UDim.new(0, 16)
	uicorner.Parent = summonFrame

	local uistroke = Instance.new("UIStroke")
	uistroke.Thickness = 2
	uistroke.Transparency = 1
	uistroke.Name = "RarityStroke"
	uistroke.Parent = summonFrame

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 40)
	title.Position = UDim2.new(0, 0, 0, 8)
	title.BackgroundTransparency = 1
	title.Text = "SUMMON"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 22
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.TextYAlignment = Enum.TextYAlignment.Center
	title.TextTransparency = 1
	title.Parent = summonFrame

	local iconFrame = Instance.new("Frame")
	iconFrame.Name = "IconFrame"
	iconFrame.Size = UDim2.new(0, 100, 0, 100)
	iconFrame.Position = UDim2.new(0.5, -50, 0, 60)
	iconFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
	iconFrame.BorderSizePixel = 0
	iconFrame.BackgroundTransparency = 1
	iconFrame.Parent = summonFrame

	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0, 50)
	iconCorner.Parent = iconFrame

	local iconLabel = Instance.new("TextLabel")
	iconLabel.Name = "IconLabel"
	iconLabel.Size = UDim2.new(1, 0, 1, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = ""
	iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	iconLabel.TextSize = 44
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.TextXAlignment = Enum.TextXAlignment.Center
	iconLabel.TextYAlignment = Enum.TextYAlignment.Center
	iconLabel.TextTransparency = 1
	iconLabel.Parent = iconFrame

	local charName = Instance.new("TextLabel")
	charName.Name = "CharName"
	charName.Size = UDim2.new(1, -20, 0, 36)
	charName.Position = UDim2.new(0, 10, 0, 175)
	charName.BackgroundTransparency = 1
	charName.Text = ""
	charName.TextColor3 = Color3.fromRGB(255, 255, 255)
	charName.TextSize = 22
	charName.Font = Enum.Font.GothamBold
	charName.TextXAlignment = Enum.TextXAlignment.Center
	charName.TextYAlignment = Enum.TextYAlignment.Center
	charName.TextTransparency = 1
	charName.Parent = summonFrame

	local seriesLabel = Instance.new("TextLabel")
	seriesLabel.Name = "Series"
	seriesLabel.Size = UDim2.new(1, -20, 0, 24)
	seriesLabel.Position = UDim2.new(0, 10, 0, 210)
	seriesLabel.BackgroundTransparency = 1
	seriesLabel.Text = ""
	seriesLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	seriesLabel.TextSize = 14
	seriesLabel.Font = Enum.Font.GothamMedium
	seriesLabel.TextXAlignment = Enum.TextXAlignment.Center
	seriesLabel.TextYAlignment = Enum.TextYAlignment.Center
	seriesLabel.TextTransparency = 1
	seriesLabel.Parent = summonFrame

	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Name = "Rarity"
	rarityLabel.Size = UDim2.new(1, -20, 0, 30)
	rarityLabel.Position = UDim2.new(0, 10, 0, 240)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Text = ""
	rarityLabel.TextSize = 16
	rarityLabel.Font = Enum.Font.GothamBold
	rarityLabel.TextXAlignment = Enum.TextXAlignment.Center
	rarityLabel.TextYAlignment = Enum.TextYAlignment.Center
	rarityLabel.TextTransparency = 1
	rarityLabel.Parent = summonFrame

	local statsLabel = Instance.new("TextLabel")
	statsLabel.Name = "Stats"
	statsLabel.Size = UDim2.new(1, -20, 0, 24)
	statsLabel.Position = UDim2.new(0, 10, 0, 275)
	statsLabel.BackgroundTransparency = 1
	statsLabel.Text = ""
	statsLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
	statsLabel.TextSize = 12
	statsLabel.Font = Enum.Font.GothamMedium
	statsLabel.TextXAlignment = Enum.TextXAlignment.Center
	statsLabel.TextYAlignment = Enum.TextYAlignment.Center
	statsLabel.TextTransparency = 1
	statsLabel.Parent = summonFrame

	local abilityLabel = Instance.new("TextLabel")
	abilityLabel.Name = "Ability"
	abilityLabel.Size = UDim2.new(1, -24, 0, 36)
	abilityLabel.Position = UDim2.new(0, 12, 0, 300)
	abilityLabel.BackgroundTransparency = 1
	abilityLabel.Text = ""
	abilityLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	abilityLabel.TextSize = 11
	abilityLabel.Font = Enum.Font.GothamMedium
	abilityLabel.TextXAlignment = Enum.TextXAlignment.Center
	abilityLabel.TextYAlignment = Enum.TextYAlignment.Center
	abilityLabel.TextTransparency = 1
	abilityLabel.Parent = summonFrame

	local dismissButton = Instance.new("TextButton")
	dismissButton.Name = "DismissButton"
	dismissButton.Size = UDim2.new(0, 160, 0, 36)
	dismissButton.Position = UDim2.new(0.5, -80, 1, -48)
	dismissButton.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
	dismissButton.BackgroundTransparency = 0.5
	dismissButton.BorderSizePixel = 0
	dismissButton.Text = "Continue"
	dismissButton.TextColor3 = Color3.fromRGB(180, 180, 180)
	dismissButton.TextSize = 14
	dismissButton.Font = Enum.Font.GothamMedium
	dismissButton.TextXAlignment = Enum.TextXAlignment.Center
	dismissButton.TextYAlignment = Enum.TextYAlignment.Center
	dismissButton.TextTransparency = 1

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = dismissButton

	dismissButton.MouseButton1Click:Connect(function()
		hideSummonResult()
	end)
	dismissButton.Parent = summonFrame
end

local function showSummonResult(card: table)
	if not gui then createSummonUI() end

	local rarity = card.tier or "Uncommon"
	local rarityColor = CharacterTypes.RARITY_COLORS[rarity] or Color3.fromRGB(200, 200, 200)
	local rarityRate = CharacterTypes.RARITY_RATES[rarity] or "?"

	isVisible = true
	gui.Enabled = true

	summonFrame.Size = UDim2.new(0, 320, 0, 400)
	summonFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
	summonFrame.BackgroundTransparency = 1

	local stroke = summonFrame:FindFirstChild("RarityStroke")
	if stroke then
		stroke.Color = rarityColor
		stroke.Transparency = 0.4
	end

	local title = summonFrame:FindFirstChild("Title")
	if title then
		title.Text = rarity .. " SUMMON"
		title.TextColor3 = rarityColor
		title.TextTransparency = 0
	end

	local iconFrame = summonFrame:FindFirstChild("IconFrame")
	if iconFrame then
		iconFrame.BackgroundTransparency = 0
		iconFrame.BackgroundColor3 = rarityColor
		local iconLabel = iconFrame:FindFirstChild("IconLabel")
		if iconLabel then
			iconLabel.Text = string.sub(card.Name, 1, 1)
			iconLabel.TextTransparency = 0
		end
	end

	local charName = summonFrame:FindFirstChild("CharName")
	if charName then
		charName.Text = card.Name
		charName.TextColor3 = rarityColor
		charName.TextTransparency = 0
	end

	local seriesLabel = summonFrame:FindFirstChild("Series")
	if seriesLabel then
		seriesLabel.Text = card.series or ""
		seriesLabel.TextTransparency = 0
	end

	local rarityLabel = summonFrame:FindFirstChild("Rarity")
	if rarityLabel then
		rarityLabel.Text = rarity .. " (" .. rarityRate .. ")"
		rarityLabel.TextColor3 = rarityColor
		rarityLabel.TextTransparency = 0
	end

	local statsLabel = summonFrame:FindFirstChild("Stats")
	if statsLabel then
		statsLabel.Text = "ATK " .. tostring(card.Attack) .. "  |  SPD " .. tostring(card.Speed) .. "  |  HP " .. tostring(card.HealthMax)
		statsLabel.TextTransparency = 0
	end

	local abilityLabel = summonFrame:FindFirstChild("Ability")
	if abilityLabel then
		abilityLabel.Text = card.AbilityText or ""
		abilityLabel.TextTransparency = 0
	end

	local dismissButton = summonFrame:FindFirstChild("DismissButton")
	if dismissButton then
		dismissButton.TextTransparency = 0
		dismissButton.BackgroundTransparency = 0.5
	end

	overlay.BackgroundTransparency = 0.6

	TweenService:Create(summonFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 340, 0, 420),
		Position = UDim2.new(0.5, -170, 0.5, -210),
		BackgroundTransparency = 0,
	}):Play()

	TweenService:Create(overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.6,
	}):Play()

	task.delay(6, function()
		if isVisible then hideSummonResult() end
	end)
end

SummonRemote.OnClientEvent:Connect(function(method: string, card: table)
	if method == CharacterTypes.SUMMON_METHODS.SummonResult then
		showSummonResult(card)
	end
end)

createSummonUI()

return true
