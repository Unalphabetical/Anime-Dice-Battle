export type ItemEntry = {
	quantity: number,
}

export type Inventory = {[string]: ItemEntry}

export type HotbarSlot = {
	itemId: string,
	quantity: number,
}

export type Hotbar = {[number]: HotbarSlot?}

export type ItemDef = {
	name: string,
	color: Color3,
	description: string,
	useText: string,
}

export type ItemDefs = {[string]: ItemDef}

local REMOTE_EVENT_NAME = "InventoryRemote"
local HOTBAR_SLOTS = 9

local Methods = {
	UseItem = "UseItem",
	UpdateItem = "UpdateItem",
	RemoveItem = "RemoveItem",
	GetInventory = "GetInventory",
	GetHotbar = "GetHotbar",
	UpdateHotbarSlot = "UpdateHotbarSlot",
	ReturnToInventory = "ReturnToInventory",
	SwapHotbarSlots = "SwapHotbarSlots",
}

local ITEM_DEFS: ItemDefs = {
	common_dice = {
		name = "Common Dice",
		color = Color3.fromRGB(180, 180, 180),
		description = "A basic dice",
		useText = "Rolled Common Dice!",
	},
	uncommon_dice = {
		name = "Uncommon Dice",
		color = Color3.fromRGB(100, 200, 100),
		description = "A decent dice",
		useText = "Rolled Uncommon Dice!",
	},
	rare_dice = {
		name = "Rare Dice",
		color = Color3.fromRGB(100, 180, 255),
		description = "A rare dice",
		useText = "Rolled Rare Dice!",
	},
	epic_dice = {
		name = "Epic Dice",
		color = Color3.fromRGB(180, 100, 255),
		description = "An epic dice",
		useText = "Rolled Epic Dice!",
	},
	legendary_dice = {
		name = "Legendary Dice",
		color = Color3.fromRGB(255, 200, 50),
		description = "A legendary dice",
		useText = "Rolled Legendary Dice!",
	},
}

return {
	REMOTE_EVENT_NAME = REMOTE_EVENT_NAME,
	HOTBAR_SLOTS = HOTBAR_SLOTS,
	Methods = Methods,
	ITEM_DEFS = ITEM_DEFS,
}
