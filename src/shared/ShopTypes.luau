export type ShopItem = {
	itemId: string,
	price: number,
}

export type ShopDefs = {[string]: ShopItem}

local REMOTE_EVENT_NAME = "ShopRemote"

local Methods = {
	OpenShop = "OpenShop",
	BuyItem = "BuyItem",
	UpdateCurrency = "UpdateCurrency",
	PurchaseFailed = "PurchaseFailed",
}

local SHOP_ITEMS: ShopDefs = {
	common_dice = {
		itemId = "common_dice",
		price = 50,
	},
	uncommon_dice = {
		itemId = "uncommon_dice",
		price = 150,
	},
	rare_dice = {
		itemId = "rare_dice",
		price = 400,
	},
	epic_dice = {
		itemId = "epic_dice",
		price = 1000,
	},
	legendary_dice = {
		itemId = "legendary_dice",
		price = 5000,
	},
	mythic_dice = {
		itemId = "mythic_dice",
		price = 10000,
	},
	godly_dice = {
		itemId = "godly_dice",
		price = 25000,
	},
	divine_dice = {
		itemId = "divine_dice",
		price = 50000,
	},
	celestial_dice = {
		itemId = "celestial_dice",
		price = 100000,
	},
	ethereal_dice = {
		itemId = "ethereal_dice",
		price = 250000,
	},
	shadow_dice = {
		itemId = "shadow_dice",
		price = 500000,
	},
	arcane_dice = {
		itemId = "arcane_dice",
		price = 1000000,
	},
	primordial_dice = {
		itemId = "primordial_dice",
		price = 2500000,
	},
	transcendent_dice = {
		itemId = "transcendent_dice",
		price = 5000000,
	},
	void_dice = {
		itemId = "void_dice",
		price = 10000000,
	},
	apex_dice = {
		itemId = "apex_dice",
		price = 50000000,
	},
}

local STARTING_CURRENCY = 200

return {
	REMOTE_EVENT_NAME = REMOTE_EVENT_NAME,
	Methods = Methods,
	SHOP_ITEMS = SHOP_ITEMS,
	STARTING_CURRENCY = STARTING_CURRENCY,
}
