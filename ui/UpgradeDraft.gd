# ui/UpgradeDraft.gd
# Controller-navigable 3-card upgrade draft overlay.
#
# process_mode = PROCESS_MODE_ALWAYS so this layer stays responsive when
# Engine.time_scale = 0 (the world-pause we apply during level-up).
#
# Usage (Game.gd):
#   _upgrade_draft.setup(upgrades)            # populate & focus card 0
#   var id: String = await _upgrade_draft.upgrade_chosen
#   _upgrade_draft.visible = false
extends CanvasLayer

signal upgrade_chosen(upgrade_id: String)

@onready var _cards: Array = [
	$CenterContainer/VBoxContainer/CardsRow/Card0,
	$CenterContainer/VBoxContainer/CardsRow/Card1,
	$CenterContainer/VBoxContainer/CardsRow/Card2,
]

var _upgrade_ids: Array[String] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	# Connect each card's pressed signal once; bind the index for identification.
	for i in _cards.size():
		_cards[i].pressed.connect(_on_card_pressed.bind(i))


## Populate all 3 cards and move controller focus to card 0.
func setup(upgrades: Array) -> void:
	_upgrade_ids.clear()
	for i in upgrades.size():
		_upgrade_ids.append(upgrades[i].get("id", ""))
		_cards[i].populate(upgrades[i])
	_cards[0].grab_focus()


func _on_card_pressed(index: int) -> void:
	emit_signal("upgrade_chosen", _upgrade_ids[index])
