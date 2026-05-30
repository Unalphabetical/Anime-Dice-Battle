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
}

local STARTING_CURRENCY = 200

return {
	REMOTE_EVENT_NAME = REMOTE_EVENT_NAME,
	Methods = Methods,
	SHOP_ITEMS = SHOP_ITEMS,
	STARTING_CURRENCY = STARTING_CURRENCY,
}
