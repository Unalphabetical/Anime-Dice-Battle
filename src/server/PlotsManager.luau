local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local CharacterTypes = require(ReplicatedStorage.Shared.CharacterTypes)
local InventoryHandler = require(script.Parent.InventoryHandler)

local REMOTE_EVENT_NAME = "PlotsRemote"
local PLOTS_PER_PLAYER = 3
local GRID_COLUMNS = 4
local PLOT_SIZE = 250
local PLOT_SPACING = 300
local GRID_ORIGIN = Vector3.new(-450, 0, -150)

local PlotsRemote = Instance.new("RemoteEvent")
PlotsRemote.Name = REMOTE_EVENT_NAME
PlotsRemote.Parent = ReplicatedStorage

local Methods = {
	PlotClicked = "PlotClicked",
	ClaimPlot = "ClaimPlot",
	PlaceCard = "PlaceCard",
	RemoveCard = "RemoveCard",
	UnclaimPlot = "UnclaimPlot",
	PlotUpdated = "PlotUpdated",
	ClaimedPlots = "ClaimedPlots",
	OpenPlot = "OpenPlot",
}

local totalPlots = 8
local plots: { [number]: {
	owner: number?,
	ownerName: string?,
	card: CharacterTypes.CharacterCard?,
	plotPart: Part?,
	displayModel: Model?,
	plotTag: TextLabel?,
} } = {}

local playerPlotCount: { [number]: { [number]: boolean } } = {}

local function getPlayerCardIds(player: Player): { string }
	local data = InventoryHandler.playerData[player.UserId]
	if not data then return {} end

	local seen: { [string]: boolean } = {}
	local result: { string } = {}

	local function addIfCard(id: string)
		if seen[id] then return end
		if string.find(id, "char_") ~= 1 then return end
		if CharacterTypes.getCard(id) then
			seen[id] = true
			table.insert(result, id)
		end
	end

	for itemId, entry in data.inventory do
		if entry.quantity > 0 then
			addIfCard(itemId)
		end
	end

	for _, slotData in data.deck do
		if slotData then
			addIfCard(slotData.itemId)
		end
	end

	return result
end

local function updatePlotTag(plotIndex: number)
	local info = plots[plotIndex]
	if not info or not info.plotTag then return end

	if info.owner then
		if info.card then
			info.plotTag.Text = info.card.Name .. " [" .. info.card.tier .. "]"
			info.plotTag.TextColor3 = CharacterTypes.RARITY_COLORS[info.card.tier]
		else
			info.plotTag.Text = "Plot #" .. plotIndex .. " (" .. info.ownerName .. ")"
			info.plotTag.TextColor3 = Color3.fromRGB(100, 255, 100)
		end
	else
		info.plotTag.Text = "Plot #" .. plotIndex .. " (Empty)"
		info.plotTag.TextColor3 = Color3.fromRGB(180, 180, 180)
	end
end

local function broadcastPlotUpdate(plotIndex: number)
	local info = plots[plotIndex]
	if not info then return end

	PlotsRemote:FireAllClients(Methods.PlotUpdated, {
		plotIndex = plotIndex,
		owner = info.owner,
		ownerName = info.ownerName,
		card = info.card,
	})
end

local function clearDisplay(plotIndex: number)
	local info = plots[plotIndex]
	if not info then return end

	if info.displayModel then
		info.displayModel:Destroy()
		info.displayModel = nil
	end
end

local function createCardDisplay(plotIndex: number)
	local info = plots[plotIndex]
	if not info or not info.card or not info.plotPart then return end

	clearDisplay(plotIndex)

	local card = info.card
	local model = Instance.new("Model")
	model.Name = "CardDisplay"

	local cardPart = Instance.new("Part")
	cardPart.Size = Vector3.new(2.8, 3.8, 0.3)
	cardPart.Position = info.plotPart.Position + Vector3.new(0, 3, 0)
	cardPart.Anchored = true
	cardPart.CanCollide = false
	cardPart.BrickColor = BrickColor.new("Black")
	cardPart.Material = Enum.Material.SmoothPlastic
	cardPart.Parent = model

	local displayGui = Instance.new("SurfaceGui")
	displayGui.Face = Enum.NormalId.Front
	displayGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	displayGui.PixelsPerStud = 50
	displayGui.ClipsDescendants = false
	displayGui.Parent = cardPart

	local cardFrame = Instance.new("Frame")
	cardFrame.Size = UDim2.new(1, 0, 1, 0)
	cardFrame.BackgroundColor3 = CharacterTypes.RARITY_COLORS[card.tier]
	cardFrame.BackgroundTransparency = 0.1
	cardFrame.BorderSizePixel = 0
	cardFrame.Parent = displayGui

	local innerFrame = Instance.new("Frame")
	innerFrame.Size = UDim2.new(0.9, 0, 0.9, 0)
	innerFrame.Position = UDim2.new(0.05, 0, 0.05, 0)
	innerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	innerFrame.BorderSizePixel = 0
	innerFrame.Parent = cardFrame

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, 24)
	nameLabel.Position = UDim2.new(0, 0, 0.05, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = card.Name
	nameLabel.TextColor3 = CharacterTypes.RARITY_COLORS[card.tier]
	nameLabel.TextSize = 18
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Center
	nameLabel.TextStrokeTransparency = 0.3
	nameLabel.Parent = innerFrame

	local tierLabel = Instance.new("TextLabel")
	tierLabel.Size = UDim2.new(1, 0, 0, 18)
	tierLabel.Position = UDim2.new(0, 0, 0.35, 0)
	tierLabel.BackgroundTransparency = 1
	tierLabel.Text = "[" .. card.tier .. "]"
	tierLabel.TextColor3 = CharacterTypes.RARITY_COLORS[card.tier]
	tierLabel.TextSize = 14
	tierLabel.Font = Enum.Font.GothamBold
	tierLabel.TextXAlignment = Enum.TextXAlignment.Center
	tierLabel.TextStrokeTransparency = 0.3
	tierLabel.Parent = innerFrame

	local seriesLabel = Instance.new("TextLabel")
	seriesLabel.Size = UDim2.new(1, 0, 0, 16)
	seriesLabel.Position = UDim2.new(0, 0, 0.55, 0)
	seriesLabel.BackgroundTransparency = 1
	seriesLabel.Text = card.series
	seriesLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
	seriesLabel.TextSize = 10
	seriesLabel.Font = Enum.Font.GothamMedium
	seriesLabel.TextXAlignment = Enum.TextXAlignment.Center
	seriesLabel.TextStrokeTransparency = 0.5
	seriesLabel.Parent = innerFrame

	local statsLabel = Instance.new("TextLabel")
	statsLabel.Size = UDim2.new(1, 0, 0, 14)
	statsLabel.Position = UDim2.new(0, 0, 0.75, 0)
	statsLabel.BackgroundTransparency = 1
	statsLabel.Text = "HP:" .. card.Health .. " ATK:" .. card.Attack .. " SPD:" .. card.Speed
	statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	statsLabel.TextSize = 9
	statsLabel.Font = Enum.Font.GothamMedium
	statsLabel.TextXAlignment = Enum.TextXAlignment.Center
	statsLabel.TextStrokeTransparency = 0.5
	statsLabel.Parent = innerFrame

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "OwnerTag"
	billboard.Size = UDim2.new(0, 160, 0, 24)
	billboard.StudsOffset = Vector3.new(0, 5, 0)
	billboard.AlwaysOnTop = true
	billboard.ResetOnSpawn = false

	local ownerLabel = Instance.new("TextLabel")
	ownerLabel.Size = UDim2.new(1, 0, 1, 0)
	ownerLabel.BackgroundTransparency = 1
	ownerLabel.Text = "Owned by " .. (info.ownerName or "Unknown")
	ownerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	ownerLabel.TextSize = 12
	ownerLabel.Font = Enum.Font.GothamMedium
	ownerLabel.TextXAlignment = Enum.TextXAlignment.Center
	ownerLabel.TextStrokeTransparency = 0.5
	ownerLabel.Parent = billboard

	billboard.Parent = model

	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Adornee = cardPart
	selectionBox.LineThickness = 0.05
	selectionBox.Color3 = CharacterTypes.RARITY_COLORS[card.tier]
	selectionBox.Transparency = 0.3
	selectionBox.Parent = model

	model.Parent = Workspace
	info.displayModel = model

	local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	local floatTween = TweenService:Create(
		cardPart,
		tweenInfo,
		{ Position = cardPart.Position + Vector3.new(0, 0.5, 0) }
	)
	floatTween:Play()
end

local function createPlot(index: number)
	local row = math.floor((index - 1) / GRID_COLUMNS)
	local col = (index - 1) % GRID_COLUMNS

	local pos = GRID_ORIGIN + Vector3.new(col * PLOT_SPACING, 0.25, row * PLOT_SPACING)

	local plotPart = Instance.new("Part")
	plotPart.Name = "Plot_" .. index
	plotPart.Size = Vector3.new(PLOT_SIZE, 0.5, PLOT_SIZE)
	plotPart.Position = pos
	plotPart.Anchored = true
	plotPart.CanCollide = true
	plotPart.BrickColor = BrickColor.new("Dark green")
	plotPart.Material = Enum.Material.Grass
	plotPart.Parent = Workspace

	local border = Instance.new("Part")
	border.Name = "Border"
	border.Size = Vector3.new(PLOT_SIZE + 2, 0.2, PLOT_SIZE + 2)
	border.Position = pos - Vector3.new(0, 0.15, 0)
	border.Anchored = true
	border.CanCollide = false
	border.BrickColor = BrickColor.new("Dark stone grey")
	border.Transparency = 0.2
	border.Material = Enum.Material.WoodPlanks
	border.Parent = plotPart

	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 60
	clickDetector.Parent = plotPart

	local plotGui = Instance.new("BillboardGui")
	plotGui.Name = "PlotTag"
	plotGui.Size = UDim2.new(0, 280, 0, 48)
	plotGui.StudsOffset = Vector3.new(0, 4, 0)
	plotGui.AlwaysOnTop = true
	plotGui.ResetOnSpawn = false

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "Plot #" .. index .. " (Empty)"
	label.TextColor3 = Color3.fromRGB(180, 180, 180)
	label.TextSize = 22
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextStrokeTransparency = 0.4
	label.Parent = plotGui

	plotGui.Parent = plotPart

	plots[index] = {
		owner = nil,
		ownerName = nil,
		card = nil,
		plotPart = plotPart,
		displayModel = nil,
		plotTag = label,
	}

	clickDetector.MouseClick:Connect(function(player: Player)
		local info = plots[index]
		if not info then return end

		if info.owner == nil then
			local count = 0
			if playerPlotCount[player.UserId] then
				for _ in playerPlotCount[player.UserId] do
					count += 1
				end
			end
			if count >= PLOTS_PER_PLAYER then
				PlotsRemote:FireClient(player, Methods.OpenPlot, {
					error = "You already own " .. PLOTS_PER_PLAYER .. " plots! Unclaim one first.",
				})
				return
			end
			info.owner = player.UserId
			info.ownerName = player.Name
			if not playerPlotCount[player.UserId] then
				playerPlotCount[player.UserId] = {}
			end
			playerPlotCount[player.UserId][index] = true
			updatePlotTag(index)
			broadcastPlotUpdate(index)
			PlotsRemote:FireClient(player, Methods.ClaimPlot, {
				plotIndex = index,
				cardIds = getPlayerCardIds(player),
			})
		elseif info.owner == player.UserId then
			PlotsRemote:FireClient(player, Methods.OpenPlot, {
				plotIndex = index,
				isOwner = true,
				hasCard = info.card ~= nil,
				card = info.card,
				cardIds = getPlayerCardIds(player),
			})
		else
			PlotsRemote:FireClient(player, Methods.OpenPlot, {
				plotIndex = index,
				isOwner = false,
				ownerName = info.ownerName,
				card = info.card,
			})
		end
	end)
end

local function placeCardOnPlot(player: Player, plotIndex: number, cardId: string)
	local info = plots[plotIndex]
	if not info or info.owner ~= player.UserId then
		PlotsRemote:FireClient(player, Methods.OpenPlot, { error = "You don't own this plot!" })
		return false
	end

	local cardDef = CharacterTypes.getCard(cardId)
	if not cardDef then
		PlotsRemote:FireClient(player, Methods.OpenPlot, { error = "Card not found!" })
		return false
	end

	local data = InventoryHandler.playerData[player.UserId]
	if not data then return false end

	local found = false
	if data.inventory[cardId] and data.inventory[cardId].quantity > 0 then
		found = true
	end
	if not found then
		for _, slotData in data.deck do
			if slotData and slotData.itemId == cardId then
				found = true
				break
			end
		end
	end
	if not found then
		PlotsRemote:FireClient(player, Methods.OpenPlot, { error = "You don't own this card!" })
		return false
	end

	info.card = cardDef
	updatePlotTag(plotIndex)
	createCardDisplay(plotIndex)
	broadcastPlotUpdate(plotIndex)
	PlotsRemote:FireClient(player, Methods.PlaceCard, { plotIndex = plotIndex, card = cardDef })
	return true
end

local function removeCardFromPlot(player: Player, plotIndex: number)
	local info = plots[plotIndex]
	if not info or info.owner ~= player.UserId then return false end

	info.card = nil
	clearDisplay(plotIndex)
	updatePlotTag(plotIndex)
	broadcastPlotUpdate(plotIndex)
	PlotsRemote:FireClient(player, Methods.RemoveCard, { plotIndex = plotIndex })
	return true
end

local function unclaimPlot(player: Player, plotIndex: number)
	local info = plots[plotIndex]
	if not info or info.owner ~= player.UserId then return false end

	removeCardFromPlot(player, plotIndex)

	info.owner = nil
	info.ownerName = nil

	if playerPlotCount[player.UserId] then
		playerPlotCount[player.UserId][plotIndex] = nil
	end

	updatePlotTag(plotIndex)
	broadcastPlotUpdate(plotIndex)
	PlotsRemote:FireClient(player, Methods.UnclaimPlot, { plotIndex = plotIndex })
	return true
end

local function initialize()
	for i = 1, totalPlots do
		createPlot(i)
	end
end

PlotsRemote.OnServerEvent:Connect(function(player: Player, method: string, data: any)
	if method == Methods.PlaceCard then
		if data and data.plotIndex and data.cardId then
			placeCardOnPlot(player, data.plotIndex, data.cardId)
		end
	elseif method == Methods.RemoveCard then
		if data and data.plotIndex then
			removeCardFromPlot(player, data.plotIndex)
		end
	elseif method == Methods.UnclaimPlot then
		if data and data.plotIndex then
			unclaimPlot(player, data.plotIndex)
		end
	elseif method == Methods.ClaimedPlots then
		local list: { number } = {}
		if playerPlotCount[player.UserId] then
			for idx in playerPlotCount[player.UserId] do
				table.insert(list, idx)
			end
		end
		PlotsRemote:FireClient(player, Methods.ClaimedPlots, { plots = list })
	end
end)

Players.PlayerAdded:Connect(function(player: Player)
	playerPlotCount[player.UserId] = {}
end)

Players.PlayerRemoving:Connect(function(player: Player)
	if playerPlotCount[player.UserId] then
		for idx in playerPlotCount[player.UserId] do
			local info = plots[idx]
			if info then
				clearDisplay(idx)
				info.owner = nil
				info.ownerName = nil
				info.card = nil
				updatePlotTag(idx)
				broadcastPlotUpdate(idx)
			end
		end
		playerPlotCount[player.UserId] = nil
	end
end)

initialize()

return {}
