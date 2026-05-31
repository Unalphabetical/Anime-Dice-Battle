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
		color = Color3.fromRGB(180, 180, 190),
		description = "A basic dice",
		useText = "Rolled Common Dice!",
	},
	uncommon_dice = {
		name = "Uncommon Dice",
		color = Color3.fromRGB(80, 220, 80),
		description = "A decent dice",
		useText = "Rolled Uncommon Dice!",
	},
	rare_dice = {
		name = "Rare Dice",
		color = Color3.fromRGB(60, 160, 255),
		description = "A rare dice",
		useText = "Rolled Rare Dice!",
	},
	epic_dice = {
		name = "Epic Dice",
		color = Color3.fromRGB(180, 80, 255),
		description = "An epic dice",
		useText = "Rolled Epic Dice!",
	},
	legendary_dice = {
		name = "Legendary Dice",
		color = Color3.fromRGB(255, 200, 50),
		description = "A legendary dice",
		useText = "Rolled Legendary Dice!",
	},
	mythic_dice = {
		name = "Mythic Dice",
		color = Color3.fromRGB(255, 70, 70),
		description = "A mythic dice",
		useText = "Rolled Mythic Dice!",
	},
	godly_dice = {
		name = "Godly Dice",
		color = Color3.fromRGB(255, 255, 200),
		description = "A godly dice",
		useText = "Rolled Godly Dice!",
	},
	divine_dice = {
		name = "Divine Dice",
		color = Color3.fromRGB(100, 220, 255),
		description = "A divine dice",
		useText = "Rolled Divine Dice!",
	},
	celestial_dice = {
		name = "Celestial Dice",
		color = Color3.fromRGB(255, 100, 200),
		description = "A celestial dice",
		useText = "Rolled Celestial Dice!",
	},
	ethereal_dice = {
		name = "Ethereal Dice",
		color = Color3.fromRGB(100, 255, 200),
		description = "An ethereal dice",
		useText = "Rolled Ethereal Dice!",
	},
	shadow_dice = {
		name = "Shadow Dice",
		color = Color3.fromRGB(140, 60, 180),
		description = "A shadow dice",
		useText = "Rolled Shadow Dice!",
	},
	arcane_dice = {
		name = "Arcane Dice",
		color = Color3.fromRGB(50, 50, 200),
		description = "An arcane dice",
		useText = "Rolled Arcane Dice!",
	},
	primordial_dice = {
		name = "Primordial Dice",
		color = Color3.fromRGB(200, 150, 80),
		description = "A primordial dice",
		useText = "Rolled Primordial Dice!",
	},
	transcendent_dice = {
		name = "Transcendent Dice",
		color = Color3.fromRGB(255, 255, 255),
		description = "A transcendent dice",
		useText = "Rolled Transcendent Dice!",
	},
	void_dice = {
		name = "Void Dice",
		color = Color3.fromRGB(120, 20, 160),
		description = "A void dice",
		useText = "Rolled Void Dice!",
	},
	apex_dice = {
		name = "Apex Dice",
		color = Color3.fromRGB(255, 50, 50),
		description = "An apex dice",
		useText = "Rolled Apex Dice!",
	},
}

return {
	REMOTE_EVENT_NAME = REMOTE_EVENT_NAME,
	HOTBAR_SLOTS = HOTBAR_SLOTS,
	Methods = Methods,
	ITEM_DEFS = ITEM_DEFS,
}
