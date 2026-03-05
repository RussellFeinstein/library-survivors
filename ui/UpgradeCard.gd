# ui/UpgradeCard.gd
# A single focusable upgrade card.
# Root is a Button so Godot's UI focus system handles controller navigation
# (d-pad / left stick) automatically between sibling cards in the HBoxContainer.
extends Button


@onready var _rarity_label: Label = $MarginContainer/VBoxContainer/RarityLabel
@onready var _name_label: Label   = $MarginContainer/VBoxContainer/NameLabel
@onready var _desc_label: Label   = $MarginContainer/VBoxContainer/DescLabel
@onready var _tags_label: Label   = $MarginContainer/VBoxContainer/TagsLabel


## Fill the card from an upgrade dict {id, name, desc, rarity, tags, effect}.
func populate(upg: Dictionary) -> void:
	_rarity_label.text = upg.get("rarity", "").to_upper()
	_name_label.text   = upg.get("name",   "??")
	_desc_label.text   = upg.get("desc",   "")
	var tags: Array    = upg.get("tags",   [])
	_tags_label.text   = " ".join(tags.map(func(t: String) -> String: return "[%s]" % t))
