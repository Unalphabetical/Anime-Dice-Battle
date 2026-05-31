local CharacterTypes = {}

export type CharacterCard = {
	id: string,
	Name: string,
	Weight: number,
	series: string,
	ImageId: string,
	BaseSpeed: number,
	Speed: number,
	HealthMax: number,
	Health: number,
	Attack: number,
	AbilityText: string,
	tier: string,
}

local TIERS = {
	Common = { weight = 2^1, color = Color3.fromRGB(180, 180, 190) },
	Uncommon = { weight = 2^2, color = Color3.fromRGB(80, 220, 80) },
	Rare = { weight = 2^3, color = Color3.fromRGB(60, 160, 255) },
	Epic = { weight = 2^4, color = Color3.fromRGB(180, 80, 255) },
	Legendary = { weight = 2^5, color = Color3.fromRGB(255, 200, 50) },
	Mythic = { weight = 2^6, color = Color3.fromRGB(255, 70, 70) },
	Godly = { weight = 2^7, color = Color3.fromRGB(255, 255, 200) },
	Divine = { weight = 2^8, color = Color3.fromRGB(100, 220, 255) },
	Celestial = { weight = 2^9, color = Color3.fromRGB(255, 100, 200) },
	Ethereal = { weight = 2^10, color = Color3.fromRGB(100, 255, 200) },
	Shadow = { weight = 2^11, color = Color3.fromRGB(140, 60, 180) },
	Arcane = { weight = 2^12, color = Color3.fromRGB(50, 50, 200) },
	Primordial = { weight = 2^13, color = Color3.fromRGB(200, 150, 80) },
	Transcendent = { weight = 2^14, color = Color3.fromRGB(255, 255, 255) },
	Void = { weight = 2^15, color = Color3.fromRGB(120, 20, 160) },
	Apex = { weight = 2^16, color = Color3.fromRGB(255, 50, 50) },
}

CharacterTypes.RARITY_COLORS = {}
CharacterTypes.RARITY_RATES = {}
for tierName, config in TIERS do
	CharacterTypes.RARITY_COLORS[tierName] = config.color
	CharacterTypes.RARITY_RATES[tierName] = "1/" .. tostring(config.weight)
end

local TIER_ORDER = { "Apex", "Void", "Transcendent", "Primordial", "Arcane", "Shadow", "Ethereal", "Celestial", "Divine", "Godly", "Mythic", "Legendary", "Epic", "Rare", "Uncommon", "Common" }

local cardLookup: { [string]: CharacterCard } = {}
local allCards: { CharacterCard } = {}

local function makeId(name: string): string
	return "char_" .. string.lower(string.gsub(name, "[^%w]", "_"))
end

local function addCardToPool(tierName: string, name: string, series: string, imageId: string, speed: number, health: number, attack: number, abilityText: string)
	local id = makeId(name)
	local card: CharacterCard = {
		id = id,
		Name = name,
		Weight = TIERS[tierName].weight,
		series = series,
		ImageId = imageId,
		BaseSpeed = speed,
		Speed = speed,
		HealthMax = health,
		Health = health,
		Attack = attack,
		AbilityText = abilityText,
		tier = tierName,
	}
	cardLookup[id] = card
	table.insert(allCards, card)
end

addCardToPool("Common", "Tanjiro", "Demon Slayer", "", 10, 60, 10, "Water Breathing")
addCardToPool("Common", "Deku", "My Hero Academia", "", 12, 65, 10, "One For All")
addCardToPool("Common", "Naruto", "Naruto", "", 10, 70, 8, "Shadow Clone")
addCardToPool("Common", "Luffy", "One Piece", "", 8, 75, 8, "Gomu Gomu Pistol")
addCardToPool("Common", "Gon", "Hunter x Hunter", "", 12, 55, 10, "Jajanken")
addCardToPool("Common", "Natsu", "Fairy Tail", "", 10, 60, 12, "Fire Dragon Roar")

addCardToPool("Uncommon", "Zoro", "One Piece", "", 16, 100, 18, "Three Sword Style")
addCardToPool("Uncommon", "Sasuke", "Naruto", "", 22, 90, 20, "Chidori")
addCardToPool("Uncommon", "Killua", "Hunter x Hunter", "", 30, 75, 16, "Lightning Palm")
addCardToPool("Uncommon", "Bakugo", "My Hero Academia", "", 18, 85, 22, "Explosion")
addCardToPool("Uncommon", "Levi", "Attack on Titan", "", 28, 95, 20, "Omni Slash")

addCardToPool("Rare", "Itachi", "Naruto", "", 24, 130, 28, "Mangekyo Sharingan")
addCardToPool("Rare", "Todoroki", "My Hero Academia", "", 16, 120, 35, "Half Hot Half Cold")
addCardToPool("Rare", "Hisoka", "Hunter x Hunter", "", 30, 100, 30, "Bungee Gum")
addCardToPool("Rare", "Rengoku", "Demon Slayer", "", 20, 140, 32, "Flame Breathing")

addCardToPool("Epic", "Ichigo", "Bleach", "", 20, 160, 40, "Bankai")
addCardToPool("Epic", "Eren", "Attack on Titan", "", 28, 180, 38, "Attack Titan")
addCardToPool("Epic", "Gojo", "Jujutsu Kaisen", "", 22, 150, 45, "Infinity")

addCardToPool("Legendary", "Goku", "Dragon Ball", "", 30, 200, 55, "Super Saiyan")
addCardToPool("Legendary", "Saitama", "One Punch Man", "", 35, 220, 60, "Serious Punch")

addCardToPool("Mythic", "Madara", "Naruto", "", 32, 280, 80, "Perfect Susanoo")
addCardToPool("Mythic", "Meruem", "Hunter x Hunter", "", 40, 300, 75, "Rage Blast")

addCardToPool("Godly", "Beerus", "Dragon Ball", "", 36, 380, 105, "Hakai")
addCardToPool("Godly", "Escanor", "Seven Deadly Sins", "", 34, 400, 115, "Divine Axe Rhitta")

addCardToPool("Divine", "Rimuru", "That Time I Got Slime", "", 42, 500, 145, "Predator")
addCardToPool("Divine", "Anos", "Misfit Demon Academy", "", 44, 480, 155, "Source of All Magic")

addCardToPool("Celestial", "Zeno", "Dragon Ball", "", 46, 650, 190, "Erase")
addCardToPool("Celestial", "Yhwach", "Bleach", "", 48, 600, 210, "The Almighty")

addCardToPool("Ethereal", "Yoriichi", "Demon Slayer", "", 52, 800, 250, "Sun Breathing")
addCardToPool("Ethereal", "Aizen", "Bleach", "", 55, 750, 270, "Kyoka Suigetsu")

addCardToPool("Shadow", "Light", "Death Note", "", 58, 850, 290, "Death Note")
addCardToPool("Shadow", "Lelouch", "Code Geass", "", 56, 900, 310, "Geass")

addCardToPool("Arcane", "Merlin", "Seven Deadly Sins", "", 58, 1050, 360, "Infinity")
addCardToPool("Arcane", "Ainz", "Overlord", "", 60, 1000, 380, "Goal of All Life")

addCardToPool("Primordial", "Zeref", "Fairy Tail", "", 55, 1600, 480, "Death Magic")
addCardToPool("Primordial", "Acnologia", "Fairy Tail", "", 62, 1500, 520, "Dragon King's Roar")

addCardToPool("Transcendent", "Sukuna", "Jujutsu Kaisen", "", 68, 2100, 620, "Malevolent Shrine")
addCardToPool("Transcendent", "Muzan", "Demon Slayer", "", 72, 1900, 670, "Demon King")

addCardToPool("Void", "Kaguya", "Naruto", "", 78, 2900, 850, "Infinite Tsukuyomi")
addCardToPool("Void", "Alucard", "Hellsing", "", 82, 2600, 950, "Level Zero")

addCardToPool("Apex", "Saiki", "Saiki K", "", 95, 4200, 1300, "Psychic Power")
addCardToPool("Apex", "Anos Voldigoad", "Misfit Demon Academy", "", 100, 3700, 1600, "Venuzdonoa")

local function getCard(id: string): CharacterCard?
	return cardLookup[id]
end

local function getTierByWeight(weight: number): string?
	for _, tierName in TIER_ORDER do
		if TIERS[tierName].weight == weight then
			return tierName
		end
	end
	return nil
end

local function rollCharacter(): CharacterCard?
	local totalRate = 0
	for _, config in TIERS do
		totalRate += 1 / config.weight
	end

	local roll = math.random() * totalRate
	local cumulative = 0
	local chosenTier: string = TIER_ORDER[#TIER_ORDER]
	for _, tierName in TIER_ORDER do
		cumulative += 1 / TIERS[tierName].weight
		if roll <= cumulative then
			chosenTier = tierName
			break
		end
	end

	local tierCards: { CharacterCard } = {}
	for _, card in allCards do
		if card.tier == chosenTier then
			table.insert(tierCards, card)
		end
	end

	if #tierCards == 0 then return nil end
	return tierCards[math.random(1, #tierCards)]
end

CharacterTypes.SUMMON_REMOTE_NAME = "SummonRemote"
CharacterTypes.SUMMON_METHODS = {
	SummonResult = "SummonResult",
}

CharacterTypes.TIERS = TIERS
CharacterTypes.TIER_ORDER = TIER_ORDER
CharacterTypes.AllCards = allCards
CharacterTypes.getCard = getCard
CharacterTypes.rollCharacter = rollCharacter
CharacterTypes.getTierByWeight = getTierByWeight

return CharacterTypes
