local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local ShopTypes = require(ReplicatedStorage.Shared.ShopTypes)
local InventoryHandler = require(script.Parent.InventoryHandler)

local ShopRemote = Instance.new("RemoteEvent")
ShopRemote.Name = ShopTypes.REMOTE_EVENT_NAME
ShopRemote.Parent = ReplicatedStorage

local playerCurrency: {[number]: number} = {}

local function getCurrency(player: Player): number
	return playerCurrency[player.UserId] or 0
end

local function setCurrency(player: Player, amount: number)
	playerCurrency[player.UserId] = amount
	ShopRemote:FireClient(player, ShopTypes.Methods.UpdateCurrency, amount)
end

local function buyItem(player: Player, itemId: string)
	local shopItem = ShopTypes.SHOP_ITEMS[itemId]
	if not shopItem then return end

	local balance = getCurrency(player)
	if balance < shopItem.price then
		ShopRemote:FireClient(player, ShopTypes.Methods.PurchaseFailed, "Not enough gold!")
		return
	end

	setCurrency(player, balance - shopItem.price)
	InventoryHandler.giveItem(player, itemId, 1)
end

local function createShopNPC()
	local model = Instance.new("Model")
	model.Name = "Dice Merchant"

	local humanoid = Instance.new("Humanoid")
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.Parent = model

	local rootPart = Instance.new("Part")
	rootPart.Name = "HumanoidRootPart"
	rootPart.Size = Vector3.new(3, 2.5, 1.5)
	rootPart.Position = Vector3.new(0, 1.25, 20)
	rootPart.Anchored = true
	rootPart.CanCollide = true
	rootPart.BrickColor = BrickColor.new("Bright yellow")
	rootPart.Material = Enum.Material.SmoothPlastic
	rootPart.Parent = model
	rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, math.rad(180), 0)

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1.5, 1.5, 1.5)
	head.Position = Vector3.new(0, 3.25, 20)
	head.Anchored = true
	head.CanCollide = false
	head.BrickColor = BrickColor.new("Light reddish violet")
	head.Material = Enum.Material.SmoothPlastic
	head.Parent = model

	local clickDetector = Instance.new("ClickDetector")
	clickDetector.Parent = rootPart

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ShopTag"
	billboard.Size = UDim2.new(0, 240, 0, 60)
	billboard.StudsOffset = Vector3.new(0, 4.5, 0)
	billboard.AlwaysOnTop = true
	billboard.ResetOnSpawn = false

	local nameTag = Instance.new("TextLabel")
	nameTag.Size = UDim2.new(1, 0, 0, 32)
	nameTag.BackgroundTransparency = 1
	nameTag.Text = "Dice Merchant"
	nameTag.TextColor3 = Color3.fromRGB(255, 200, 50)
	nameTag.TextSize = 22
	nameTag.Font = Enum.Font.GothamBold
	nameTag.TextXAlignment = Enum.TextXAlignment.Center
	nameTag.TextYAlignment = Enum.TextYAlignment.Center
	nameTag.TextStrokeTransparency = 0.3
	nameTag.Parent = billboard

	local subTag = Instance.new("TextLabel")
	subTag.Size = UDim2.new(1, 0, 0, 20)
	subTag.Position = UDim2.new(0, 0, 0.5, 5)
	subTag.BackgroundTransparency = 1
	subTag.Text = "[Click to browse]"
	subTag.TextColor3 = Color3.fromRGB(200, 200, 200)
	subTag.TextSize = 14
	subTag.Font = Enum.Font.GothamMedium
	subTag.TextXAlignment = Enum.TextXAlignment.Center
	subTag.TextYAlignment = Enum.TextYAlignment.Top
	subTag.TextStrokeTransparency = 0.5
	subTag.Parent = billboard

	billboard.Parent = head

	model.Parent = Workspace
	return clickDetector
end

local shopDetector = createShopNPC()
shopDetector.MouseClick:Connect(function(player: Player)
	ShopRemote:FireClient(player, ShopTypes.Methods.OpenShop, getCurrency(player))
end)

ShopRemote.OnServerEvent:Connect(function(player: Player, method: string, ...)
	if method == ShopTypes.Methods.BuyItem then
		local itemId: string = ...
		buyItem(player, itemId)
	end
end)

Players.PlayerAdded:Connect(function(player: Player)
	playerCurrency[player.UserId] = ShopTypes.STARTING_CURRENCY
end)

Players.PlayerRemoving:Connect(function(player: Player)
	playerCurrency[player.UserId] = nil
end)

return true
