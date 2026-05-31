local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InventoryTypes = require(ReplicatedStorage.Shared.InventoryTypes)
local ShopTypes = require(ReplicatedStorage.Shared.ShopTypes)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ShopRemote = ReplicatedStorage:WaitForChild(ShopTypes.REMOTE_EVENT_NAME)

local shopOpen = false
local gui: ScreenGui?
local shopPanel: Frame?
local currencyLabel: TextLabel?
local hudCurrencyLabel: TextLabel?
local itemList: ScrollingFrame?

local SUFFIXES = {
	"K", "M", "B", "T", "Q",
	"Qi", "Sx", "Sp", "Oc", "No",
	"Dc", "UDc", "DDc", "TDc", "QaDc",
	"QiDc", "SxDc", "SpDc", "OcDc", "NoDc",
	"Vg", "UVg", "DVg", "TVg", "QaVg",
	"QiVg", "SxVg", "SpVg", "OcVg", "NoVg",
	"Tg", "UTg", "DTg",
}

local function formatNumber(n: number): string
	if n < 1000 then
		return tostring(math.floor(n))
	end

	local tier = 0
	local value = n
	while value >= 1000 and tier < #SUFFIXES do
		value /= 1000
		tier += 1
	end

	if value >= 1000 then
		local exp = math.floor(math.log10(n))
		local mantissa = n / (10 ^ exp)
		return string.format("%.1fe%d", mantissa, exp)
	end

	local whole = math.floor(value)
	local decimal = math.floor((value - whole) * 100)

	if decimal == 0 then
		return tostring(whole) .. SUFFIXES[tier]
	elseif decimal % 10 == 0 then
		return tostring(whole) .. "." .. tostring(math.floor(decimal / 10)) .. SUFFIXES[tier]
	end

	return tostring(whole) .. "." .. tostring(decimal) .. SUFFIXES[tier]
end

local COLORS = {
	background = Color3.fromRGB(25, 25, 35),
	panelBg = Color3.fromRGB(20, 20, 30),
	slot = Color3.fromRGB(50, 50, 65),
	slotBorder = Color3.fromRGB(70, 70, 90),
	text = Color3.fromRGB(230, 230, 230),
	muted = Color3.fromRGB(160, 160, 170),
	accent = Color3.fromRGB(60, 120, 240),
	success = Color3.fromRGB(80, 200, 80),
	error = Color3.fromRGB(220, 60, 60),
	gold = Color3.fromRGB(255, 200, 50),
}

local function getItemDisplay(itemId: string)
	local def = InventoryTypes.ITEM_DEFS[itemId]
	if def then
		return def
	end
	return {
		name = itemId,
		color = Color3.fromRGB(200, 200, 200),
		description = "",
	}
end

local function closeShop()
	if gui then
		gui.Enabled = false
	end
	shopOpen = false
end

local function rebuildItemList(currency: number)
	if not itemList then return end

	for _, child in itemList:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local uilist = itemList:FindFirstChild("UIListLayout")
	if not uilist then
		uilist = Instance.new("UIListLayout")
		uilist.Padding = UDim.new(0, 4)
		uilist.FillDirection = Enum.FillDirection.Vertical
		uilist.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uilist.SortOrder = Enum.SortOrder.LayoutOrder
		uilist.Parent = itemList
	end

	for itemId, shopItem in ShopTypes.SHOP_ITEMS do
		local display = getItemDisplay(itemId)
		local canAfford = currency >= shopItem.price

		local row = Instance.new("Frame")
		row.Name = "Item_" .. itemId
		row.Size = UDim2.new(1, -12, 0, 48)
		row.BackgroundColor3 = COLORS.slot
		row.BackgroundTransparency = 0.5
		row.BorderSizePixel = 0

		local uicorner = Instance.new("UICorner")
		uicorner.CornerRadius = UDim.new(0, 6)
		uicorner.Parent = row

		local colorSwatch = Instance.new("Frame")
		colorSwatch.Size = UDim2.new(0, 32, 0, 32)
		colorSwatch.Position = UDim2.new(0, 8, 0.5, -16)
		colorSwatch.BackgroundColor3 = display.color
		colorSwatch.BackgroundTransparency = 0.3
		colorSwatch.BorderSizePixel = 0

		local swatchCorner = Instance.new("UICorner")
		swatchCorner.CornerRadius = UDim.new(0, 6)
		swatchCorner.Parent = colorSwatch

		colorSwatch.Parent = row

		local itemName = Instance.new("TextLabel")
		itemName.Size = UDim2.new(0, 140, 1, 0)
		itemName.Position = UDim2.new(0, 48, 0, 0)
		itemName.BackgroundTransparency = 1
		itemName.Text = display.name
		itemName.TextColor3 = COLORS.text
		itemName.TextSize = 15
		itemName.Font = Enum.Font.GothamBold
		itemName.TextXAlignment = Enum.TextXAlignment.Left
		itemName.TextYAlignment = Enum.TextYAlignment.Center
		itemName.Parent = row

		local priceLabel = Instance.new("TextLabel")
		priceLabel.Size = UDim2.new(0, 80, 1, 0)
		priceLabel.Position = UDim2.new(0, 190, 0, 0)
		priceLabel.BackgroundTransparency = 1
		priceLabel.Text = formatNumber(shopItem.price) .. "g"
		priceLabel.TextColor3 = canAfford and COLORS.gold or COLORS.error
		priceLabel.TextSize = 14
		priceLabel.Font = Enum.Font.GothamBold
		priceLabel.TextXAlignment = Enum.TextXAlignment.Center
		priceLabel.TextYAlignment = Enum.TextYAlignment.Center
		priceLabel.Parent = row

		local buyButton = Instance.new("TextButton")
		buyButton.Size = UDim2.new(0, 70, 0, 30)
		buyButton.Position = UDim2.new(1, -78, 0.5, -15)
		buyButton.BackgroundColor3 = canAfford and COLORS.success or COLORS.muted
		buyButton.BackgroundTransparency = 0.4
		buyButton.BorderSizePixel = 0
		buyButton.Text = canAfford and "Buy" or "---"
		buyButton.TextColor3 = COLORS.text
		buyButton.TextSize = 13
		buyButton.Font = Enum.Font.GothamBold
		buyButton.AutoButtonColor = true

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 4)
		btnCorner.Parent = buyButton

		if canAfford then
			buyButton.MouseButton1Click:Connect(function()
				ShopRemote:FireServer(ShopTypes.Methods.BuyItem, itemId)
			end)
		end

		buyButton.Parent = row
		row.Parent = itemList
	end

	local padding = itemList:FindFirstChild("UIPadding")
	if not padding then
		padding = Instance.new("UIPadding")
		padding.PaddingTop = UDim.new(0, 4)
		padding.Parent = itemList
	end

	local listHeight = 0
	for _, child in itemList:GetChildren() do
		if child:IsA("Frame") then
			listHeight += 52
		end
	end
	itemList.CanvasSize = UDim2.new(0, 0, 0, listHeight + 8)
end

local function openShop(currency: number)
	if not shopPanel then return end

	local text = "Gold: " .. formatNumber(currency)
	if currencyLabel then
		currencyLabel.Text = text
	end
	if hudCurrencyLabel then
		hudCurrencyLabel.Text = "$" .. formatNumber(currency)
	end

	rebuildItemList(currency)

	if gui then
		gui.Enabled = true
	end
	shopOpen = true
end

local function updateCurrency(amount: number)
	local text = "Gold: " .. formatNumber(amount)
	if currencyLabel then
		currencyLabel.Text = text
	end
	if hudCurrencyLabel then
		hudCurrencyLabel.Text = "$" .. formatNumber(amount)
	end
	if shopOpen and gui and gui.Enabled then
		rebuildItemList(amount)
	end
end

local function setupHUD()
	local hudGui = Instance.new("ScreenGui")
	hudGui.Name = "CurrencyHUD"
	hudGui.ResetOnSpawn = false
	hudGui.Parent = playerGui

	hudCurrencyLabel = Instance.new("TextLabel")
	hudCurrencyLabel.Name = "CurrencyLabel"
	hudCurrencyLabel.Size = UDim2.new(0, 180, 0, 50)
	hudCurrencyLabel.Position = UDim2.new(0, 12, 1, -12)
	hudCurrencyLabel.AnchorPoint = Vector2.new(0, 1)
	hudCurrencyLabel.BackgroundTransparency = 1
	hudCurrencyLabel.Text = "$" .. formatNumber(0)
	hudCurrencyLabel.TextColor3 = COLORS.gold
	hudCurrencyLabel.TextSize = 40
	hudCurrencyLabel.Font = Enum.Font.GothamBold
	hudCurrencyLabel.TextXAlignment = Enum.TextXAlignment.Left
	hudCurrencyLabel.TextYAlignment = Enum.TextYAlignment.Center

	hudCurrencyLabel.Parent = hudGui
end

local function setupUI()
	gui = Instance.new("ScreenGui")
	gui.Name = "ShopGUI"
	gui.ResetOnSpawn = false
	gui.Enabled = false
	gui.Parent = playerGui

	shopPanel = Instance.new("Frame")
	shopPanel.Name = "ShopPanel"
	shopPanel.Size = UDim2.new(0, 400, 0, 400)
	shopPanel.Position = UDim2.new(0.5, -200, 0.5, -200)
	shopPanel.BackgroundColor3 = COLORS.panelBg
	shopPanel.BorderSizePixel = 0
	shopPanel.Parent = gui

	local uicorner = Instance.new("UICorner")
	uicorner.CornerRadius = UDim.new(0, 10)
	uicorner.Parent = shopPanel

	local uistroke = Instance.new("UIStroke")
	uistroke.Color = Color3.fromRGB(60, 60, 80)
	uistroke.Thickness = 1
	uistroke.Parent = shopPanel

	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, 40)
	titleBar.BackgroundColor3 = COLORS.background
	titleBar.BorderSizePixel = 0

	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 10)
	titleCorner.Parent = titleBar

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -50, 1, 0)
	titleLabel.Position = UDim2.new(0, 14, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "Dice Shop"
	titleLabel.TextColor3 = COLORS.gold
	titleLabel.TextSize = 18
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextYAlignment = Enum.TextYAlignment.Center
	titleLabel.Parent = titleBar

	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 30, 0, 30)
	closeButton.Position = UDim2.new(1, -36, 0.5, -15)
	closeButton.BackgroundTransparency = 1
	closeButton.Text = "X"
	closeButton.TextColor3 = COLORS.muted
	closeButton.TextSize = 18
	closeButton.Font = Enum.Font.GothamBold

	closeButton.MouseButton1Click:Connect(closeShop)
	closeButton.Parent = titleBar
	titleBar.Parent = shopPanel

	currencyLabel = Instance.new("TextLabel")
	currencyLabel.Name = "CurrencyLabel"
	currencyLabel.Size = UDim2.new(1, -20, 0, 30)
	currencyLabel.Position = UDim2.new(0, 10, 0, 44)
	currencyLabel.BackgroundTransparency = 1
	currencyLabel.Text = "Gold: " .. formatNumber(0)
	currencyLabel.TextColor3 = COLORS.gold
	currencyLabel.TextSize = 16
	currencyLabel.Font = Enum.Font.GothamBold
	currencyLabel.TextXAlignment = Enum.TextXAlignment.Left
	currencyLabel.TextYAlignment = Enum.TextYAlignment.Center
	currencyLabel.Parent = shopPanel

	local separator = Instance.new("Frame")
	separator.Size = UDim2.new(1, -20, 0, 1)
	separator.Position = UDim2.new(0, 10, 0, 78)
	separator.BackgroundColor3 = COLORS.slotBorder
	separator.BorderSizePixel = 0
	separator.Parent = shopPanel

	itemList = Instance.new("ScrollingFrame")
	itemList.Name = "ItemList"
	itemList.Size = UDim2.new(1, -8, 1, -90)
	itemList.Position = UDim2.new(0, 4, 0, 84)
	itemList.BackgroundTransparency = 1
	itemList.BorderSizePixel = 0
	itemList.CanvasSize = UDim2.new(0, 0, 0, 0)
	itemList.ScrollBarThickness = 4
	itemList.ScrollBarImageColor3 = COLORS.muted
	itemList.Parent = shopPanel
end

local function setupInput()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.Escape and shopOpen then
				closeShop()
			end
		end
	end)
end

local function setupRemoteListeners()
	ShopRemote.OnClientEvent:Connect(function(method: string, ...)
		if method == ShopTypes.Methods.OpenShop then
			local currency: number = ...
			openShop(currency)
		elseif method == ShopTypes.Methods.UpdateCurrency then
			local amount: number = ...
			updateCurrency(amount)
		elseif method == ShopTypes.Methods.PurchaseFailed then
			local message: string = ...
			if shopPanel then
				local notification = Instance.new("TextLabel")
				notification.Size = UDim2.new(1, -20, 0, 24)
				notification.Position = UDim2.new(0, 10, 1, -28)
				notification.BackgroundColor3 = COLORS.error
				notification.BackgroundTransparency = 0.3
				notification.Text = message
				notification.TextColor3 = COLORS.text
				notification.TextSize = 13
				notification.Font = Enum.Font.GothamMedium
				notification.TextXAlignment = Enum.TextXAlignment.Center
				notification.TextYAlignment = Enum.TextYAlignment.Center

				local notifCorner = Instance.new("UICorner")
				notifCorner.CornerRadius = UDim.new(0, 4)
				notifCorner.Parent = notification

				notification.Parent = shopPanel

				task.delay(2, function()
					notification:Destroy()
				end)
			end
		end
	end)
end

local function init()
	setupHUD()
	setupUI()
	setupInput()
	setupRemoteListeners()
end

init()

return true
