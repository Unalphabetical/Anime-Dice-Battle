local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

local InventoryTypes = require(ReplicatedStorage.Shared.InventoryTypes)
local CharacterTypes = require(ReplicatedStorage.Shared.CharacterTypes)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()

local RemoteEvent = ReplicatedStorage:WaitForChild(InventoryTypes.REMOTE_EVENT_NAME)

local hotbar: InventoryTypes.Hotbar = {}
local inventory: InventoryTypes.Inventory = {}
local deck: InventoryTypes.Hotbar = {}
local selectedSlot = 1
local inventoryOpen = false

local gui: ScreenGui
local hotbarFrame: Frame
local slots: {Frame} = {}
local deckSlots: {Frame} = {}
local inventoryPanel: Frame
local diceGrid: ScrollingFrame
local charGrid: ScrollingFrame
local dragPreview: Frame
local isDragging = false
local dragItemId: string? = nil
local dragSource: string? = nil
local dragSlotIndex: number? = nil

local COLORS = {
	background = Color3.fromRGB(25, 25, 35),
	panelBg = Color3.fromRGB(16, 16, 26),
	panelBorder = Color3.fromRGB(50, 50, 65),
	deckBg = Color3.fromRGB(22, 22, 34),
	slot = Color3.fromRGB(50, 50, 65),
	slotBorder = Color3.fromRGB(70, 70, 90),
	selected = Color3.fromRGB(80, 140, 255),
	hover = Color3.fromRGB(65, 65, 85),
	text = Color3.fromRGB(230, 230, 230),
	muted = Color3.fromRGB(160, 160, 170),
	accent = Color3.fromRGB(60, 120, 240),
	drag = Color3.fromRGB(60, 120, 240),
	sectionBg = Color3.fromRGB(20, 20, 32),
}

local function getItemDisplay(itemId: string)
	local display = {
		name = itemId,
		iconText = string.sub(itemId, 1, 1):upper(),
		color = Color3.fromRGB(200, 200, 200),
		rarityTag = "",
	}
	local itemDef = InventoryTypes.ITEM_DEFS[itemId]
	if itemDef then
		display.name = itemDef.name
		display.color = itemDef.color
	else
		local card = CharacterTypes.getCard(itemId)
		if card then
			display.name = card.Name
			local rarity = card.tier or "Uncommon"
			display.color = CharacterTypes.RARITY_COLORS[rarity] or Color3.fromRGB(200, 200, 200)
			display.iconText = string.sub(card.Name, 1, 1):upper()
			display.rarityTag = rarity
		end
	end
	return display
end

local function createSlotFrame(slotIndex: number, parent: Instance): Frame
	local slot = Instance.new("Frame")
	slot.Name = "Slot" .. slotIndex
	slot.Size = UDim2.new(0, 52, 0, 52)
	slot.BackgroundColor3 = COLORS.slot
	slot.BorderSizePixel = 1
	slot.BorderColor3 = COLORS.slotBorder

	local uicorner = Instance.new("UICorner")
	uicorner.CornerRadius = UDim.new(0, 4)
	uicorner.Parent = slot

	local keybind = Instance.new("TextLabel")
	keybind.Name = "Keybind"
	keybind.Size = UDim2.new(0, 18, 0, 16)
	keybind.Position = UDim2.new(0, 2, 0, 2)
	keybind.BackgroundTransparency = 1
	keybind.Text = tostring(slotIndex)
	keybind.TextColor3 = COLORS.muted
	keybind.TextSize = 11
	keybind.Font = Enum.Font.GothamBold
	keybind.TextXAlignment = Enum.TextXAlignment.Center
	keybind.TextYAlignment = Enum.TextYAlignment.Top
	keybind.Parent = slot

	local icon = Instance.new("Frame")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 30, 0, 30)
	icon.Position = UDim2.new(0.5, -15, 0.5, -15)
	icon.BackgroundColor3 = COLORS.text
	icon.BackgroundTransparency = 1
	icon.BorderSizePixel = 0

	local uicorner2 = Instance.new("UICorner")
	uicorner2.CornerRadius = UDim.new(0, 6)
	uicorner2.Parent = icon

	local itemName = Instance.new("TextLabel")
	itemName.Name = "ItemName"
	itemName.Size = UDim2.new(1, -4, 0, 14)
	itemName.Position = UDim2.new(0, 2, 0.5, -7)
	itemName.BackgroundTransparency = 1
	itemName.Text = ""
	itemName.TextColor3 = COLORS.text
	itemName.TextSize = 10
	itemName.Font = Enum.Font.GothamBold
	itemName.TextXAlignment = Enum.TextXAlignment.Center
	itemName.TextYAlignment = Enum.TextYAlignment.Center
	itemName.Visible = false
	itemName.Parent = icon

	icon.Parent = slot

	local quantity = Instance.new("TextLabel")
	quantity.Name = "Quantity"
	quantity.Size = UDim2.new(1, -4, 0, 14)
	quantity.Position = UDim2.new(0, 2, 1, -16)
	quantity.BackgroundTransparency = 1
	quantity.Text = ""
	quantity.TextColor3 = COLORS.muted
	quantity.TextSize = 11
	quantity.Font = Enum.Font.GothamMedium
	quantity.TextXAlignment = Enum.TextXAlignment.Right
	quantity.TextYAlignment = Enum.TextYAlignment.Bottom
	quantity.Parent = slot

	slot.Parent = parent
	return slot
end

local function createDeckSlotFrame(slotIndex: number, parent: Instance): Frame
	local slot = Instance.new("Frame")
	slot.Name = "DeckSlot" .. slotIndex
	slot.Size = UDim2.new(0, 100, 0, 100)
	slot.BackgroundColor3 = COLORS.slot
	slot.BorderSizePixel = 1
	slot.BorderColor3 = COLORS.slotBorder

	local uicorner = Instance.new("UICorner")
	uicorner.CornerRadius = UDim.new(0, 8)
	uicorner.Parent = slot

	local keybind = Instance.new("TextLabel")
	keybind.Name = "Keybind"
	keybind.Size = UDim2.new(0, 22, 0, 16)
	keybind.Position = UDim2.new(0, 4, 0, 4)
	keybind.BackgroundTransparency = 1
	keybind.Text = "D" .. tostring(slotIndex)
	keybind.TextColor3 = COLORS.muted
	keybind.TextSize = 11
	keybind.Font = Enum.Font.GothamBold
	keybind.TextXAlignment = Enum.TextXAlignment.Left
	keybind.Parent = slot

	local icon = Instance.new("Frame")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 50, 0, 50)
	icon.Position = UDim2.new(0.5, -25, 0.5, -25)
	icon.BackgroundColor3 = COLORS.text
	icon.BackgroundTransparency = 1
	icon.BorderSizePixel = 0

	local uicorner2 = Instance.new("UICorner")
	uicorner2.CornerRadius = UDim.new(0, 10)
	uicorner2.Parent = icon

	local itemName = Instance.new("TextLabel")
	itemName.Name = "ItemName"
	itemName.Size = UDim2.new(1, -4, 0, 14)
	itemName.Position = UDim2.new(0, 2, 0.5, 18)
	itemName.BackgroundTransparency = 1
	itemName.Text = ""
	itemName.TextColor3 = COLORS.text
	itemName.TextSize = 10
	itemName.Font = Enum.Font.GothamBold
	itemName.TextXAlignment = Enum.TextXAlignment.Center
	itemName.TextYAlignment = Enum.TextYAlignment.Center
	itemName.Visible = false
	itemName.Parent = icon

	icon.Parent = slot

	local quantity = Instance.new("TextLabel")
	quantity.Name = "Quantity"
	quantity.Size = UDim2.new(1, -4, 0, 14)
	quantity.Position = UDim2.new(0, 2, 1, -16)
	quantity.BackgroundTransparency = 1
	quantity.Text = ""
	quantity.TextColor3 = COLORS.muted
	quantity.TextSize = 11
	quantity.Font = Enum.Font.GothamMedium
	quantity.TextXAlignment = Enum.TextXAlignment.Right
	quantity.TextYAlignment = Enum.TextYAlignment.Bottom
	quantity.Parent = slot

	slot.Parent = parent
	return slot
end

local function createInventoryItemButton(itemId: string, entry: InventoryTypes.ItemEntry): Frame
	local display = getItemDisplay(itemId)

	local frame = Instance.new("Frame")
	frame.Name = "Item_" .. itemId
	frame.Size = UDim2.new(0, 80, 0, 80)
	frame.BackgroundColor3 = display.color
	frame.BackgroundTransparency = 0.8
	frame.BorderSizePixel = 1
	frame.BorderColor3 = display.color

	local uicorner = Instance.new("UICorner")
	uicorner.CornerRadius = UDim.new(0, 6)
	uicorner.Parent = frame

	local itemIcon = Instance.new("Frame")
	itemIcon.Name = "ItemIcon"
	itemIcon.Size = UDim2.new(0, 36, 0, 36)
	itemIcon.Position = UDim2.new(0.5, -18, 0.5, -22)
	itemIcon.BackgroundColor3 = display.color
	itemIcon.BackgroundTransparency = 0.4
	itemIcon.BorderSizePixel = 0

	local uicorner3 = Instance.new("UICorner")
	uicorner3.CornerRadius = UDim.new(0, 8)
	uicorner3.Parent = itemIcon

	local iconLabel = Instance.new("TextLabel")
	iconLabel.Name = "IconLabel"
	iconLabel.Size = UDim2.new(1, 0, 1, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = display.iconText
	iconLabel.TextColor3 = COLORS.text
	iconLabel.TextSize = 18
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.TextXAlignment = Enum.TextXAlignment.Center
	iconLabel.TextYAlignment = Enum.TextYAlignment.Center
	iconLabel.Parent = itemIcon

	itemIcon.Parent = frame

	local itemName = Instance.new("TextLabel")
	itemName.Name = "ItemName"
	itemName.Size = UDim2.new(1, -4, 0, 16)
	itemName.Position = UDim2.new(0, 2, 0.5, 8)
	itemName.BackgroundTransparency = 1
	itemName.Text = display.name
	itemName.TextColor3 = COLORS.text
	itemName.TextSize = 11
	itemName.Font = Enum.Font.GothamBold
	itemName.TextXAlignment = Enum.TextXAlignment.Center
	itemName.TextYAlignment = Enum.TextYAlignment.Top
	itemName.Parent = frame

	local quantityLabel = Instance.new("TextLabel")
	quantityLabel.Name = "Quantity"
	quantityLabel.Size = UDim2.new(1, -4, 0, 14)
	quantityLabel.Position = UDim2.new(0, 2, 1, -16)
	quantityLabel.BackgroundTransparency = 1
	quantityLabel.Text = "x" .. tostring(entry.quantity)
	quantityLabel.TextColor3 = COLORS.muted
	quantityLabel.TextSize = 10
	quantityLabel.Font = Enum.Font.GothamMedium
	quantityLabel.TextXAlignment = Enum.TextXAlignment.Right
	quantityLabel.TextYAlignment = Enum.TextYAlignment.Bottom
	quantityLabel.Parent = frame

	local uipadding = Instance.new("UIPadding")
	uipadding.PaddingTop = UDim.new(0, 4)
	uipadding.PaddingBottom = UDim.new(0, 4)
	uipadding.Parent = frame

	return frame
end

local function attachDragToButton(button: Frame, itemId: string)
	local hover = Instance.new("Frame")
	hover.Name = "Hover"
	hover.Size = UDim2.new(1, 0, 1, 0)
	hover.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	hover.BackgroundTransparency = 1
	hover.BorderSizePixel = 0
	hover.ZIndex = 3
	hover.Parent = button

	local clickRegion = Instance.new("TextButton")
	clickRegion.Name = "ClickRegion"
	clickRegion.Size = UDim2.new(1, 0, 1, 0)
	clickRegion.BackgroundTransparency = 1
	clickRegion.AutoButtonColor = false
	clickRegion.Text = ""
	clickRegion.ZIndex = 2
	clickRegion.Parent = button

	clickRegion.MouseButton1Down:Connect(function()
		isDragging = true
		dragSource = "inventory"
		dragSlotIndex = nil
		dragItemId = itemId
		dragPreview.Visible = true
		local display = getItemDisplay(itemId)
		dragPreview.BackgroundColor3 = display.color
		local dragLabel = dragPreview:FindFirstChild("DragLabel")
		if dragLabel then
			dragLabel.Text = display.name
		end
	end)

	clickRegion.MouseEnter:Connect(function()
		if not isDragging then
			hover.BackgroundTransparency = 0.7
		end
	end)

	clickRegion.MouseLeave:Connect(function()
		hover.BackgroundTransparency = 1
	end)
end

local function updateHotbarUI()
	for i = 1, InventoryTypes.HOTBAR_SLOTS do
		local slot = slots[i]
		local icon = slot:FindFirstChild("Icon")
		local itemName = icon:FindFirstChild("ItemName")
		local quantity = slot:FindFirstChild("Quantity")
		local slotData = hotbar[i]

		if slotData then
			local display = getItemDisplay(slotData.itemId)
			icon.BackgroundTransparency = 0.3
			icon.BackgroundColor3 = display.color
			itemName.Visible = true
			itemName.Text = display.name
			quantity.Text = tostring(slotData.quantity)
		else
			icon.BackgroundTransparency = 1
			itemName.Visible = false
			quantity.Text = ""
		end
	end
end

local function updateSlotSelection()
	for i, slot in slots do
		if i == selectedSlot then
			slot.BackgroundColor3 = COLORS.selected
			slot.BorderColor3 = Color3.fromRGB(150, 190, 255)
		else
			slot.BackgroundColor3 = COLORS.slot
			slot.BorderColor3 = COLORS.slotBorder
		end
	end
end

local function updateDeckUI()
	for i = 1, InventoryTypes.DECK_SLOTS do
		local slot = deckSlots[i]
		if not slot then continue end
		local icon = slot:FindFirstChild("Icon")
		local itemName = icon:FindFirstChild("ItemName")
		local quantity = slot:FindFirstChild("Quantity")
		local slotData = deck[i]

		if slotData then
			local display = getItemDisplay(slotData.itemId)
			icon.BackgroundTransparency = 0.3
			icon.BackgroundColor3 = display.color
			itemName.Visible = true
			itemName.Text = display.name
			quantity.Text = tostring(slotData.quantity)
		else
			icon.BackgroundTransparency = 1
			itemName.Visible = false
			quantity.Text = ""
		end
	end
end

local function populateGrid(grid: ScrollingFrame, items: {[string]: InventoryTypes.ItemEntry}, emptyText: string)
	for _, child in grid:GetChildren() do
		if child:IsA("Frame") or child:IsA("TextLabel") then
			child:Destroy()
		end
	end

	if not next(items) then
		local empty = Instance.new("TextLabel")
		empty.Name = "EmptyLabel"
		empty.Size = UDim2.new(1, 0, 1, 0)
		empty.BackgroundTransparency = 1
		empty.Text = emptyText
		empty.TextColor3 = COLORS.muted
		empty.TextSize = 16
		empty.Font = Enum.Font.GothamMedium
		empty.TextXAlignment = Enum.TextXAlignment.Center
		empty.TextYAlignment = Enum.TextYAlignment.Center
		empty.Parent = grid
		return
	end

	for itemId, entry in items do
		local button = createInventoryItemButton(itemId, entry)
		attachDragToButton(button, itemId)
		button.Parent = grid
	end
end

local function rebuildInventoryPanel()
	if not inventoryPanel then return end

	local diceItems: {[string]: InventoryTypes.ItemEntry} = {}
	local charItems: {[string]: InventoryTypes.ItemEntry} = {}
	for itemId, entry in inventory do
		if InventoryTypes.ITEM_DEFS[itemId] then
			diceItems[itemId] = entry
		else
			charItems[itemId] = entry
		end
	end

	populateGrid(diceGrid, diceItems, "No dice items")
	populateGrid(charGrid, charItems, "No character items")
end

local function toggleInventory()
	inventoryOpen = not inventoryOpen
	inventoryPanel.Visible = inventoryOpen
	if inventoryOpen then
		rebuildInventoryPanel()
		updateDeckUI()
	end
end

local function useSelectedSlot()
	if not hotbar[selectedSlot] then return end
	RemoteEvent:FireServer(InventoryTypes.Methods.UseItem, selectedSlot)
end

local function setupUI()
	gui = Instance.new("ScreenGui")
	gui.Name = "InventoryGUI"
	gui.ResetOnSpawn = false
	gui.Parent = playerGui

	hotbarFrame = Instance.new("Frame")
	hotbarFrame.Name = "Hotbar"
	hotbarFrame.Size = UDim2.new(0, 520, 0, 60)
	hotbarFrame.Position = UDim2.new(0.5, -260, 1, -75)
	hotbarFrame.BackgroundColor3 = COLORS.background
	hotbarFrame.BackgroundTransparency = 0.4
	hotbarFrame.BorderSizePixel = 0

	local uicorner_hotbar = Instance.new("UICorner")
	uicorner_hotbar.CornerRadius = UDim.new(0, 8)
	uicorner_hotbar.Parent = hotbarFrame

	local uistroke = Instance.new("UIStroke")
	uistroke.Color = Color3.fromRGB(60, 60, 80)
	uistroke.Thickness = 1
	uistroke.Parent = hotbarFrame

	local hotbarList = Instance.new("UIListLayout")
	hotbarList.FillDirection = Enum.FillDirection.Horizontal
	hotbarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	hotbarList.VerticalAlignment = Enum.VerticalAlignment.Center
	hotbarList.Padding = UDim.new(0, 4)
	hotbarList.Parent = hotbarFrame

	local uipadding_hotbar = Instance.new("UIPadding")
	uipadding_hotbar.PaddingTop = UDim.new(0, 4)
	uipadding_hotbar.PaddingBottom = UDim.new(0, 4)
	uipadding_hotbar.PaddingLeft = UDim.new(0, 4)
	uipadding_hotbar.PaddingRight = UDim.new(0, 4)
	uipadding_hotbar.Parent = hotbarFrame

	for i = 1, InventoryTypes.HOTBAR_SLOTS do
		slots[i] = createSlotFrame(i, hotbarFrame)
	end

	hotbarFrame.Parent = gui

	local dragHolder = Instance.new("Frame")
	dragHolder.Name = "DragHolder"
	dragHolder.Size = UDim2.new(1, 0, 1, 0)
	dragHolder.BackgroundTransparency = 1
	dragHolder.ZIndex = 100
	dragHolder.Parent = gui

	dragPreview = Instance.new("Frame")
	dragPreview.Name = "DragPreview"
	dragPreview.Size = UDim2.new(0, 64, 0, 64)
	dragPreview.BackgroundColor3 = COLORS.drag
	dragPreview.BackgroundTransparency = 0.25
	dragPreview.BorderSizePixel = 0
	dragPreview.Visible = false
	dragPreview.ZIndex = 101

	local uicorner_drag = Instance.new("UICorner")
	uicorner_drag.CornerRadius = UDim.new(0, 8)
	uicorner_drag.Parent = dragPreview

	local uistroke_drag = Instance.new("UIStroke")
	uistroke_drag.Color = Color3.fromRGB(255, 255, 255)
	uistroke_drag.Thickness = 1
	uistroke_drag.Transparency = 0.5
	uistroke_drag.Parent = dragPreview

	local dragLabel = Instance.new("TextLabel")
	dragLabel.Name = "DragLabel"
	dragLabel.Size = UDim2.new(1, 0, 1, 0)
	dragLabel.BackgroundTransparency = 1
	dragLabel.Text = ""
	dragLabel.TextColor3 = COLORS.text
	dragLabel.TextSize = 12
	dragLabel.Font = Enum.Font.GothamBold
	dragLabel.TextXAlignment = Enum.TextXAlignment.Center
	dragLabel.TextYAlignment = Enum.TextYAlignment.Center
	dragLabel.Parent = dragPreview

	dragPreview.Parent = dragHolder

	inventoryPanel = Instance.new("Frame")
	inventoryPanel.Name = "InventoryPanel"
	inventoryPanel.Size = UDim2.new(0.85, 0, 0.85, 0)
	inventoryPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	inventoryPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
	inventoryPanel.BackgroundColor3 = COLORS.panelBg
	inventoryPanel.BorderSizePixel = 0
	inventoryPanel.Visible = false

	local uicorner_inv = Instance.new("UICorner")
	uicorner_inv.CornerRadius = UDim.new(0, 10)
	uicorner_inv.Parent = inventoryPanel

	local uistroke_inv = Instance.new("UIStroke")
	uistroke_inv.Color = COLORS.panelBorder
	uistroke_inv.Thickness = 1
	uistroke_inv.Parent = inventoryPanel

	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, 38)
	titleBar.BackgroundColor3 = COLORS.background
	titleBar.BorderSizePixel = 0

	local uicorner_title = Instance.new("UICorner")
	uicorner_title.CornerRadius = UDim.new(0, 10)
	uicorner_title.Parent = titleBar

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -40, 1, 0)
	titleLabel.Position = UDim2.new(0, 14, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "Inventory"
	titleLabel.TextColor3 = COLORS.text
	titleLabel.TextSize = 18
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextYAlignment = Enum.TextYAlignment.Center
	titleLabel.Parent = titleBar

	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseBtn"
	closeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeBtn.Position = UDim2.new(1, -36, 0.5, -15)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = "X"
	closeBtn.TextColor3 = COLORS.muted
	closeBtn.TextSize = 18
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextXAlignment = Enum.TextXAlignment.Center
	closeBtn.TextYAlignment = Enum.TextYAlignment.Center
	closeBtn.Parent = titleBar
	closeBtn.MouseButton1Click:Connect(function()
		toggleInventory()
	end)

	titleBar.Parent = inventoryPanel

	local deckPanel = Instance.new("Frame")
	deckPanel.Name = "DeckPanel"
	deckPanel.Size = UDim2.new(0, 210, 1, -50)
	deckPanel.Position = UDim2.new(0, 8, 0, 42)
	deckPanel.BackgroundColor3 = COLORS.deckBg
	deckPanel.BorderSizePixel = 0

	local uicorner_deck = Instance.new("UICorner")
	uicorner_deck.CornerRadius = UDim.new(0, 8)
	uicorner_deck.Parent = deckPanel

	local deckTitle = Instance.new("TextLabel")
	deckTitle.Name = "DeckTitle"
	deckTitle.Size = UDim2.new(1, 0, 0, 28)
	deckTitle.Position = UDim2.new(0, 0, 0, 6)
	deckTitle.BackgroundTransparency = 1
	deckTitle.Text = "DECK"
	deckTitle.TextColor3 = COLORS.text
	deckTitle.TextSize = 13
	deckTitle.Font = Enum.Font.GothamBold
	deckTitle.TextXAlignment = Enum.TextXAlignment.Center
	deckTitle.TextYAlignment = Enum.TextYAlignment.Center
	deckTitle.Parent = deckPanel

	local deckList = Instance.new("UIListLayout")
	deckList.FillDirection = Enum.FillDirection.Vertical
	deckList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	deckList.VerticalAlignment = Enum.VerticalAlignment.Center
	deckList.Padding = UDim.new(0, 10)
	deckList.Parent = deckPanel

	for i = 1, InventoryTypes.DECK_SLOTS do
		deckSlots[i] = createDeckSlotFrame(i, deckPanel)
	end

	deckPanel.Parent = inventoryPanel

	local contentPanel = Instance.new("Frame")
	contentPanel.Name = "ContentPanel"
	contentPanel.Size = UDim2.new(1, -234, 1, -50)
	contentPanel.Position = UDim2.new(0, 226, 0, 42)
	contentPanel.BackgroundTransparency = 1
	contentPanel.BorderSizePixel = 0
	contentPanel.ClipsDescendants = true

	local contentLayout = Instance.new("UIListLayout")
	contentLayout.FillDirection = Enum.FillDirection.Vertical
	contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.Parent = contentPanel

	local diceSection = Instance.new("Frame")
	diceSection.Name = "DiceSection"
	diceSection.LayoutOrder = 1
	diceSection.Size = UDim2.new(1, 0, 0.25, 0)
	diceSection.BackgroundColor3 = COLORS.sectionBg
	diceSection.BorderSizePixel = 0

	local uicorner_dice = Instance.new("UICorner")
	uicorner_dice.CornerRadius = UDim.new(0, 8)
	uicorner_dice.Parent = diceSection

	local diceSeparator = Instance.new("UIStroke")
	diceSeparator.Color = COLORS.panelBorder
	diceSeparator.Thickness = 1
	diceSeparator.Parent = diceSection

	local diceLabel = Instance.new("TextLabel")
	diceLabel.Name = "SectionTitle"
	diceLabel.Size = UDim2.new(1, -12, 0, 24)
	diceLabel.Position = UDim2.new(0, 8, 0, 4)
	diceLabel.BackgroundTransparency = 1
	diceLabel.Text = "Dice"
	diceLabel.TextColor3 = COLORS.text
	diceLabel.TextSize = 14
	diceLabel.Font = Enum.Font.GothamBold
	diceLabel.TextXAlignment = Enum.TextXAlignment.Left
	diceLabel.TextYAlignment = Enum.TextYAlignment.Center
	diceLabel.Parent = diceSection

	diceGrid = Instance.new("ScrollingFrame")
	diceGrid.Name = "DiceGrid"
	diceGrid.Size = UDim2.new(1, -8, 1, -32)
	diceGrid.Position = UDim2.new(0, 4, 0, 28)
	diceGrid.BackgroundTransparency = 1
	diceGrid.BorderSizePixel = 0
	diceGrid.CanvasSize = UDim2.new(0, 0, 0, 0)
	diceGrid.ScrollBarThickness = 6
	diceGrid.ScrollBarImageColor3 = COLORS.muted

	local diceGridLayout = Instance.new("UIGridLayout")
	diceGridLayout.CellSize = UDim2.new(0, 80, 0, 80)
	diceGridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
	diceGridLayout.FillDirection = Enum.FillDirection.Horizontal
	diceGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	diceGridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	diceGridLayout.Parent = diceGrid

	diceGrid.Parent = diceSection

	diceSection.Parent = contentPanel

	local charSection = Instance.new("Frame")
	charSection.Name = "CharSection"
	charSection.LayoutOrder = 2
	charSection.Size = UDim2.new(1, 0, 0.75, 0)
	charSection.BackgroundColor3 = COLORS.sectionBg
	charSection.BorderSizePixel = 0

	local uicorner_char = Instance.new("UICorner")
	uicorner_char.CornerRadius = UDim.new(0, 8)
	uicorner_char.Parent = charSection

	local charSeparator = Instance.new("UIStroke")
	charSeparator.Color = COLORS.panelBorder
	charSeparator.Thickness = 1
	charSeparator.Parent = charSection

	local charLabel = Instance.new("TextLabel")
	charLabel.Name = "SectionTitle"
	charLabel.Size = UDim2.new(1, -12, 0, 24)
	charLabel.Position = UDim2.new(0, 8, 0, 4)
	charLabel.BackgroundTransparency = 1
	charLabel.Text = "Characters"
	charLabel.TextColor3 = COLORS.text
	charLabel.TextSize = 14
	charLabel.Font = Enum.Font.GothamBold
	charLabel.TextXAlignment = Enum.TextXAlignment.Left
	charLabel.TextYAlignment = Enum.TextYAlignment.Center
	charLabel.Parent = charSection

	charGrid = Instance.new("ScrollingFrame")
	charGrid.Name = "CharGrid"
	charGrid.Size = UDim2.new(1, -8, 1, -32)
	charGrid.Position = UDim2.new(0, 4, 0, 28)
	charGrid.BackgroundTransparency = 1
	charGrid.BorderSizePixel = 0
	charGrid.CanvasSize = UDim2.new(0, 0, 0, 0)
	charGrid.ScrollBarThickness = 6
	charGrid.ScrollBarImageColor3 = COLORS.muted

	local charGridLayout = Instance.new("UIGridLayout")
	charGridLayout.CellSize = UDim2.new(0, 80, 0, 80)
	charGridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
	charGridLayout.FillDirection = Enum.FillDirection.Horizontal
	charGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	charGridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	charGridLayout.Parent = charGrid

	charGrid.Parent = charSection

	charSection.Parent = contentPanel

	contentPanel.Parent = inventoryPanel

	inventoryPanel.Parent = gui

	updateSlotSelection()
end

local function setupInput()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.B then
				toggleInventory()
				return
			end

			local keyCodes = {
				Enum.KeyCode.One,
				Enum.KeyCode.Two,
				Enum.KeyCode.Three,
				Enum.KeyCode.Four,
				Enum.KeyCode.Five,
				Enum.KeyCode.Six,
				Enum.KeyCode.Seven,
				Enum.KeyCode.Eight,
				Enum.KeyCode.Nine,
			}
			for i = 1, InventoryTypes.HOTBAR_SLOTS do
				if input.KeyCode == keyCodes[i] then
					selectedSlot = i
					updateSlotSelection()
					return
				end
			end
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local mousePos = Vector2.new(mouse.X, mouse.Y)
			local processedDrop = false

			if isDragging then
				processedDrop = true

				if dragSource == "inventory" and dragItemId then
					for i, slotFrame in deckSlots do
						local absPos = slotFrame.AbsolutePosition
						local absSize = slotFrame.AbsoluteSize
						if mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X
							and mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y then
							RemoteEvent:FireServer(InventoryTypes.Methods.UpdateDeckSlot, i, dragItemId)
							break
						end
					end

					for i, slotFrame in slots do
						local absPos = slotFrame.AbsolutePosition
						local absSize = slotFrame.AbsoluteSize
						if mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X
							and mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y then
							RemoteEvent:FireServer(InventoryTypes.Methods.UpdateHotbarSlot, i, dragItemId)
							break
						end
					end
				elseif dragSource == "deck" and dragItemId and dragSlotIndex then
					for i, slotFrame in deckSlots do
						if i == dragSlotIndex then continue end
						local absPos = slotFrame.AbsolutePosition
						local absSize = slotFrame.AbsoluteSize
						if mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X
							and mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y then
							RemoteEvent:FireServer(InventoryTypes.Methods.SwapDeckSlots, dragSlotIndex, i)
							break
						end
					end

					if inventoryOpen then
						local invPos = inventoryPanel.AbsolutePosition
						local invSize = inventoryPanel.AbsoluteSize
						if mousePos.X >= invPos.X and mousePos.X <= invPos.X + invSize.X
							and mousePos.Y >= invPos.Y and mousePos.Y <= invPos.Y + invSize.Y then
							RemoteEvent:FireServer(InventoryTypes.Methods.ReturnDeckToInventory, dragSlotIndex, dragItemId)
						end
					end

					for i, slotFrame in slots do
						local absPos = slotFrame.AbsolutePosition
						local absSize = slotFrame.AbsoluteSize
						if mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X
							and mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y then
							RemoteEvent:FireServer(InventoryTypes.Methods.UpdateHotbarSlot, i, dragItemId)
							break
						end
					end
				elseif dragSource == "hotbar" and dragSlotIndex then
					for i, slotFrame in slots do
						if i == dragSlotIndex then continue end
						local absPos = slotFrame.AbsolutePosition
						local absSize = slotFrame.AbsoluteSize
						if mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X
							and mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y then
							RemoteEvent:FireServer(InventoryTypes.Methods.SwapHotbarSlots, dragSlotIndex, i)
							break
						end
					end

					if inventoryOpen then
						local invPos = inventoryPanel.AbsolutePosition
						local invSize = inventoryPanel.AbsoluteSize
						if mousePos.X >= invPos.X and mousePos.X <= invPos.X + invSize.X
							and mousePos.Y >= invPos.Y and mousePos.Y <= invPos.Y + invSize.Y then
							RemoteEvent:FireServer(InventoryTypes.Methods.ReturnToInventory, dragSlotIndex, dragItemId)
						end
					end

					for i, slotFrame in deckSlots do
						local absPos = slotFrame.AbsolutePosition
						local absSize = slotFrame.AbsoluteSize
						if mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X
							and mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y then
							RemoteEvent:FireServer(InventoryTypes.Methods.UpdateDeckSlot, i, dragItemId)
							break
						end
					end
				end

				isDragging = false
				dragSource = nil
				dragItemId = nil
				dragSlotIndex = nil
				dragPreview.Visible = false
			end

			if not processedDrop and inventoryOpen then
				for i, slotFrame in deckSlots do
					local absPos = slotFrame.AbsolutePosition
					local absSize = slotFrame.AbsoluteSize
					if mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X
						and mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y then
						local slotData = deck[i]
						if slotData then
							isDragging = true
							dragSource = "deck"
							dragSlotIndex = i
							dragItemId = slotData.itemId
							dragPreview.Visible = true
							local display = getItemDisplay(slotData.itemId)
							dragPreview.BackgroundColor3 = display.color
							local dragLabel = dragPreview:FindFirstChild("DragLabel")
							if dragLabel then
								dragLabel.Text = display.name
							end
						end
						break
					end
				end

				if not isDragging then
					for i, slotFrame in slots do
						local absPos = slotFrame.AbsolutePosition
						local absSize = slotFrame.AbsoluteSize
						if mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X
							and mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y then
							local slotData = hotbar[i]
							if slotData then
								isDragging = true
								dragSource = "hotbar"
								dragSlotIndex = i
								dragItemId = slotData.itemId
								dragPreview.Visible = true
								local display = getItemDisplay(slotData.itemId)
								dragPreview.BackgroundColor3 = display.color
								local dragLabel = dragPreview:FindFirstChild("DragLabel")
								if dragLabel then
									dragLabel.Text = display.name
								end
							end
							break
						end
					end
				end
			end

			if not inventoryOpen and hotbar[selectedSlot] then
				useSelectedSlot()
			end
		end
	end)
end

local function setupRemoteListeners()
	RemoteEvent.OnClientEvent:Connect(function(method, ...)
		if method == InventoryTypes.Methods.UpdateItem then
			local itemId, entry = ...
			if entry.quantity > 0 then
				inventory[itemId] = entry
			else
				inventory[itemId] = nil
			end
			updateHotbarUI()
			updateDeckUI()
			if inventoryOpen then
				rebuildInventoryPanel()
			end
		elseif method == InventoryTypes.Methods.RemoveItem then
			local itemId = ...
			inventory[itemId] = nil
			updateHotbarUI()
			updateDeckUI()
			if inventoryOpen then
				rebuildInventoryPanel()
			end
		elseif method == InventoryTypes.Methods.GetInventory then
			local inv = ...
			inventory = inv or {}
			updateHotbarUI()
			updateDeckUI()
			if inventoryOpen then
				rebuildInventoryPanel()
			end
		elseif method == InventoryTypes.Methods.GetHotbar then
			local hb = ...
			if hb then
				for i = 1, InventoryTypes.HOTBAR_SLOTS do
					hotbar[i] = hb[i]
				end
			end
			updateHotbarUI()
		elseif method == InventoryTypes.Methods.UpdateHotbarSlot then
			local slot, slotData = ...
			hotbar[slot] = slotData or nil
			updateHotbarUI()
		elseif method == InventoryTypes.Methods.GetDeck then
			local d = ...
			if d then
				for i = 1, InventoryTypes.DECK_SLOTS do
					deck[i] = d[i]
				end
			end
			updateDeckUI()
		elseif method == InventoryTypes.Methods.UpdateDeckSlot then
			local slot, slotData = ...
			deck[slot] = slotData or nil
			updateDeckUI()
		end
	end)
end

local function init()
	setupUI()
	setupInput()
	setupRemoteListeners()

	RemoteEvent:FireServer(InventoryTypes.Methods.GetInventory)
	RemoteEvent:FireServer(InventoryTypes.Methods.GetHotbar)
	RemoteEvent:FireServer(InventoryTypes.Methods.GetDeck)

	RunService.RenderStepped:Connect(function()
		if isDragging and dragPreview.Visible then
			dragPreview.Position = UDim2.new(0, mouse.X - 32, 0, mouse.Y - 32)
		end
	end)
end

init()

return {}
