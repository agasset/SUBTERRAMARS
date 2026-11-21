extends RefCounted

const CLASSIC_ORDER := [1,4,7,10,13,16,19,20]
const STARTS := [1,4,7,10,13,16,19,20]

static func order_for_seed(seed_value: int) -> Array:
	var middle := [4,7,10,13]
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([seed_value,"campaign_biome_order_v1"])
	for i in range(middle.size()-1,0,-1):
		var j := rng.randi_range(0,i)
		var swap: int = middle[i]
		middle[i] = middle[j]
		middle[j] = swap
	return [1] + middle + [16,19,20]

static func valid_order(order: Array) -> bool:
	for value in order:
		if not value is int: return false
	if order.size()!=8 or order[0]!=1 or order.slice(5)!=[16,19,20]: return false
	var middle := order.slice(1,5)
	middle.sort()
	return middle == [4,7,10,13]

static func block_start(depth: int) -> int:
	return clampi(depth,19,20) if depth>=19 else 1+floori(float(maxi(1,depth)-1)/3.0)*3

static func biome_at_depth(depth: int, order: Array) -> int:
	return int(order[STARTS.find(block_start(depth))])

static func is_boundary(depth: int) -> bool:
	return depth in [3,6,9,12,15,18,19]

static func requirement(biome: int) -> String:
	match biome:
		1: return "Escàner biològic Nv. 2 operatiu"
		4: return "Capçal de precisió actiu · eina de mineria operativa"
		7: return "Grampons actius · botes operatives"
		10: return "Sola de drenatge activa · botes operatives"
		13: return "Sola tèrmica activa amb botes operatives, o aïllament tèrmic actiu amb vestit operatiu"
		16: return "Filtre de bioluminescència actiu · escàner operatiu"
		19: return "Escàner biològic Nv. 3 operatiu"
	return ""

static func requirement_met(game, biome: int) -> bool:
	match biome:
		1: return game.bio_scanner_tier>=1 and game.bio_scanner_integrity>0
		4: return game._modifier_protects("mineria","quars") and game.mining_tool_integrity>0
		7: return game._modifier_protects("botes","gel") and game.boots_integrity>0
		10: return game._modifier_protects("botes","aigua") and game.boots_integrity>0
		13: return (game._modifier_protects("botes","calent") and game.boots_integrity>0) or (game._modifier_protects("vestit","calent") and game.suit_integrity>0)
		16: return game._modifier_protects("escaner","abyss") and game.bio_scanner_integrity>0
		19: return game.bio_scanner_tier>=2 and game.bio_scanner_integrity>0
	return true
