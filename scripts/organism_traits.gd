extends RefCounted

# Keep option order stable. The recipe stores indices into these tables.
const ANIMAL := {
	"legs": ["una pota", "dues potes", "tres potes", "quatre potes"],
	"color": ["ambre", "corall", "verd", "blau", "violeta", "ivori"],
	"fur": ["sense pèl", "amb pèl"],
	"size": ["molt petit", "petit", "mitjà", "gran", "molt gran"],
	"pattern": ["llis", "una franja", "dues franges", "taques"],
	"armor": ["pell llisa", "plaques", "espines"],
	"antennae": ["sense antenes", "antenes curtes", "antenes llargues"],
	"tail": ["sense cua", "cua curta", "cua bifurcada"],
	"movement": ["pausat", "vivaç", "a batzegades"],
}
const PLANT := {
	"form": ["en ventall", "en roseta", "ramificada", "en coixinet"],
	"stems": ["una tija", "dues tiges", "tres tiges", "quatre tiges", "cinc tiges"],
	"leaf": ["arrodonida", "punxeguda", "en làmina"],
	"color": ["menta", "turquesa", "lavanda", "coure", "corall", "ivori"],
	"size": ["baixa", "mitjana", "alta"],
	"texture": ["llisa", "estriada", "pigallada"],
	"tip": ["borrons", "flors", "espores"],
	"glow": ["sense llum", "llum suau", "llum intensa"],
}
const PLANT_COLORS := ["85dc9c", "6adee5", "cb8aef", "e89c59", "f4848e", "ebe9cd"]
const NAME_ROOTS := ["Bri", "Rastre", "Ombra", "Punt", "Llambreig", "Espurna", "Fil", "Vel", "Eco", "Brot", "Reflex", "Macla"]
const BIOME_NAME_FORMS := {
	1: ["del ferro", "de la pols roja", "de l’òxid", "del coure"],
	4: ["de la geoda", "del quars", "del cristall", "del prisma"],
	7: ["del gebre", "del glaç blau", "de la neu", "de la gelera"],
	10: ["del jardí", "del fullatge", "del sotabosc", "de les arrels"],
	13: ["de la brasa", "del basalt calent", "de la fumarola", "del magma"],
	16: ["de l’abisme", "del pou fosc", "de la fondària", "de l’ombra profunda"],
	19: ["del llindar", "de la frontera", "del darrer pas", "de la darrera volta"],
	20: ["del nucli", "del cor de Mart", "del fons", "de la cambra central"],
}

static func roll(family: String, traits: Dictionary, rng: RandomNumberGenerator) -> String:
	var recipe := PackedStringArray([family, "2"])
	for options in traits.values():
		recipe.append(str(rng.randi_range(0, options.size() - 1)))
	return "~".join(recipe)

static func decode(id: String, traits: Dictionary) -> Dictionary:
	var recipe := id.split("~")
	if recipe.size() != traits.size() + 2 or recipe[1] != "2":
		return {}
	var result := {}
	var index := 2
	for key in traits:
		var value := recipe[index].to_int()
		if not recipe[index].is_valid_int() or value < 0 or value >= traits[key].size():
			return {}
		result[key] = value
		index += 1
	return result

static func display_name(id: String, family_name: String, origin_biome: int) -> String:
	var name_seed := hash(id) & 0x7fffffff
	var suffix: String = NAME_ROOTS[name_seed % NAME_ROOTS.size()]
	var forms: Array = BIOME_NAME_FORMS.get(origin_biome, BIOME_NAME_FORMS[1])
	var form: String = forms[floori(float(name_seed) / NAME_ROOTS.size()) % forms.size()]
	return "%s · %s %s" % [family_name, suffix, form]

static func describe(recipe: Dictionary, traits: Dictionary) -> String:
	var labels := PackedStringArray()
	for key in traits:
		labels.append(traits[key][recipe[key]])
	return " · ".join(labels)
