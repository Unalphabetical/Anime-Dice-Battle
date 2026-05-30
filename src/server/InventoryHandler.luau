local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local InventoryTypes = require(ReplicatedStorage.Shared.InventoryTypes)

local RemoteEvent = Instance.new("RemoteEvent")
RemoteEvent.Name = InventoryTypes.REMOTE_EVENT_NAME
RemoteEvent.Parent = ReplicatedStorage

local playerData: {[number]: {
	inventory: InventoryTypes.Inventory,
	hotbar: InventoryTypes.Hotbar,
}} = {}

local function getPlayerData(player: Player)
	return playerData[player.UserId]
end

local itemEffects: {[string]: (player: Player) -> ()} = {
	common_dice = function(player: Player)
		player:SetAttribute("LastDiceRoll", "common")
		player:SetAttribute("DiceValue", math.random(1, 6))
	end,
	uncommon_dice = function(player: Player)
		player:SetAttribute("LastDiceRoll", "uncommon")
		player:SetAttribute("DiceValue", math.random(1, 8))
	end,
	rare_dice = function(player: Player)
		player:SetAttribute("LastDiceRoll", "rare")
		player:SetAttribute("DiceValue", math.random(1, 12))
	end,
	epic_dice = function(player: Player)
		player:SetAttribute("LastDiceRoll", "epic")
		player:SetAttribute("DiceValue", math.random(1, 20))
	end,
	legendary_dice = function(player: Player)
		player:SetAttribute("LastDiceRoll", "legendary")
		player:SetAttribute("DiceValue", math.random(1, 100))
	end,
}

local function giveItem(player: Player, itemId: string, quantity: number)
	local data = getPlayerData(player)
	if not data then return end
	local entry = data.inventory[itemId]
	if entry then
		entry.quantity += quantity
	else
		data.inventory[itemId] = { quantity = quantity }
	end
	RemoteEvent:FireClient(player, InventoryTypes.Methods.UpdateItem, itemId, data.inventory[itemId])
end

local function removeItem(player: Player, itemId: string, quantity: number)
	local data = getPlayerData(player)
	if not data then return end
	local entry = data.inventory[itemId]
	if not entry then return end
	entry.quantity -= quantity
	if entry.quantity <= 0 then
		data.inventory[itemId] = nil
		RemoteEvent:FireClient(player, InventoryTypes.Methods.RemoveItem, itemId)
	else
		RemoteEvent:FireClient(player, InventoryTypes.Methods.UpdateItem, itemId, data.inventory[itemId])
	end
end

local function useItem(player: Player, slotIndex: number)
	local data = getPlayerData(player)
	if not data then return end
	local slotData = data.hotbar[slotIndex]
	if not slotData then return end

	slotData.quantity -= 1
	if slotData.quantity <= 0 then
		data.hotbar[slotIndex] = nil
		RemoteEvent:FireClient(player, InventoryTypes.Methods.UpdateHotbarSlot, slotIndex, nil)
	else
		RemoteEvent:FireClient(player, InventoryTypes.Methods.UpdateHotbarSlot, slotIndex, slotData)
	end

	local effect = itemEffects[slotData.itemId]
	if effect then
		effect(player)
	end
end

local function setupPlayer(player: Player)
	local data = {
		inventory = {},
		hotbar = {},
	}
	playerData[player.UserId] = data

	for i = 1, InventoryTypes.HOTBAR_SLOTS do
		RemoteEvent:FireClient(player, InventoryTypes.Methods.UpdateHotbarSlot, i, nil)
	end
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
	playerData[player.UserId] = nil
end)

RemoteEvent.OnServerEvent:Connect(function(player, method, ...)
	local data = getPlayerData(player)
	if method == InventoryTypes.Methods.UseItem then
		local slotIndex = ...
		useItem(player, slotIndex)
	elseif method == InventoryTypes.Methods.GetInventory then
		if data then
			RemoteEvent:FireClient(player, InventoryTypes.Methods.GetInventory, data.inventory)
		end
	elseif method == InventoryTypes.Methods.GetHotbar then
		if data then
			RemoteEvent:FireClient(player, InventoryTypes.Methods.GetHotbar, data.hotbar)
		end
	elseif method == InventoryTypes.Methods.UpdateHotbarSlot then
		if not data then return end
		local slot, itemId = ...
		if slot and slot >= 1 and slot <= InventoryTypes.HOTBAR_SLOTS and itemId then
			local invEntry = data.inventory[itemId]
			if invEntry and invEntry.quantity > 0 then
				local moveQty = invEntry.quantity
				data.inventory[itemId] = nil
				RemoteEvent:FireClient(player, InventoryTypes.Methods.RemoveItem, itemId)

				local slotData = data.hotbar[slot]
				if slotData and slotData.itemId == itemId then
					slotData.quantity += moveQty
				else
					data.hotbar[slot] = { itemId = itemId, quantity = moveQty }
				end
				RemoteEvent:FireClient(player, InventoryTypes.Methods.UpdateHotbarSlot, slot, data.hotbar[slot])
			end
		end
	elseif method == InventoryTypes.Methods.ReturnToInventory then
		if not data then return end
		local slot, itemId = ...
		if slot and slot >= 1 and slot <= InventoryTypes.HOTBAR_SLOTS and itemId then
			local slotData = data.hotbar[slot]
			if slotData and slotData.itemId == itemId then
				local qty = slotData.quantity
				data.hotbar[slot] = nil
				RemoteEvent:FireClient(player, InventoryTypes.Methods.UpdateHotbarSlot, slot, nil)

				local invEntry = data.inventory[itemId]
				if invEntry then
					invEntry.quantity += qty
				else
					data.inventory[itemId] = { quantity = qty }
				end
				RemoteEvent:FireClient(player, InventoryTypes.Methods.UpdateItem, itemId, data.inventory[itemId])
			end
		end
	end
end)

return {
	giveItem = giveItem,
	removeItem = removeItem,
	playerData = playerData,
}
