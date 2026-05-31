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
	Legendary = { weight = 1^2, color = Color3.fromRGB(255, 200, 50) },
	Epic = { weight = 2^2, color = Color3.fromRGB(180, 80, 255) },
	Rare = { weight = 3^2, color = Color3.fromRGB(60, 160, 255) },
	Uncommon = { weight = 4^2, color = Color3.fromRGB(80, 220, 80) },
	Common = { weight = 5^2, color = Color3.fromRGB(180, 180, 190) },
}

CharacterTypes.RARITY_COLORS = {}
CharacterTypes.RARITY_RATES = {}
for tierName, config in TIERS do
	CharacterTypes.RARITY_COLORS[tierName] = config.color
	CharacterTypes.RARITY_RATES[tierName] = "1/" .. tostring(config.weight)
end

local TIER_ORDER = { "Legendary", "Epic", "Rare", "Uncommon", "Common" }

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

addCardToPool("Legendary", "Titan", "Mythos", "", 18, 200, 55, "Crushing Blow")
addCardToPool("Legendary", "Overlord", "Mythos", "", 22, 170, 60, "Domination")

addCardToPool("Epic", "Paladin", "Sanctuary", "", 16, 180, 35, "Holy Strike")
addCardToPool("Epic", "Archmage", "Sanctuary", "", 12, 110, 45, "Arcane Blast")
addCardToPool("Epic", "Assassin", "Shadow", "", 30, 90, 40, "Shadow Strike")

addCardToPool("Rare", "Knight", "Kingdom", "", 14, 150, 28, "Shield Bash")
addCardToPool("Rare", "Mage", "Kingdom", "", 10, 90, 38, "Fireball")
addCardToPool("Rare", "Rogue", "Shadow", "", 26, 80, 30, "Backstab")
addCardToPool("Rare", "Hunter", "Wilds", "", 20, 110, 25, "Precision Shot")

addCardToPool("Uncommon", "Warrior", "Frontier", "", 12, 130, 22, "Power Strike")
addCardToPool("Uncommon", "Archer", "Frontier", "", 16, 90, 20, "Quick Shot")
addCardToPool("Uncommon", "Thief", "Shadow", "", 24, 70, 18, "Steal")
addCardToPool("Uncommon", "Cleric", "Sanctuary", "", 10, 110, 14, "Heal")
addCardToPool("Uncommon", "Scout", "Frontier", "", 20, 80, 16, "Survey")

addCardToPool("Common", "Peasant", "Village", "", 8, 55, 8, "Farm")
addCardToPool("Common", "Recruit", "Kingdom", "", 10, 75, 10, "Charge")
addCardToPool("Common", "Apprentice", "Kingdom", "", 8, 55, 12, "Study")
addCardToPool("Common", "Squire", "Kingdom", "", 10, 85, 10, "Serve")
addCardToPool("Common", "Novice", "Frontier", "", 10, 60, 8, "Learn")
addCardToPool("Common", "Villager", "Village", "", 8, 50, 6, "Work")

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
	local totalTierWeight = 0
	for _, config in TIERS do
		totalTierWeight += config.weight
	end

	local roll = math.random(1, totalTierWeight)
	local cumulative = 0
	local chosenTier: string = TIER_ORDER[#TIER_ORDER]
	for _, tierName in TIER_ORDER do
		cumulative += TIERS[tierName].weight
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
