## NPC 컨트롤러
## NPC 상호작용 및 대화를 관리합니다.

class_name NPCController
extends CharacterBody2D

signal interaction_available(npc: NPCController)
signal interaction_ended()

@export var npc_data: NPCResource = null
@export var interaction_range: float = 50.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_label: Label = $InteractionLabel

var player_nearby: bool = false
var is_interacting: bool = false
var dialogue_lines: Array[DialogueLine] = []
var current_dialogue_index: int = 0

func _ready() -> void:
	if interaction_label:
		interaction_label.visible = false

func _process(_delta: float) -> void:
	if not player_ref_check():
		if player_nearby and interaction_label:
			interaction_label.visible = false
			player_nearby = false
		if is_interacting:
			end_interaction()
		return

	var distance: float = global_position.distance_to(get_player().global_position)
	var was_nearby: bool = player_nearby
	player_nearby = distance <= interaction_range

	if interaction_label:
		interaction_label.visible = player_nearby and not is_interacting

	if player_nearby and not was_nearby:
		interaction_available.emit(self)

## 상호작용 시작
func start_interaction() -> void:
	if not player_nearby or is_interacting:
		return
	is_interacting = true
	current_dialogue_index = 0
	_show_current_dialogue()

## 상호작용 종료
func end_interaction() -> void:
	is_interacting = false
	if interaction_label:
		interaction_label.visible = player_nearby
	interaction_ended.emit()

## 다음 대화 진행
func advance_dialogue() -> void:
	if not is_interacting:
		return
	current_dialogue_index += 1
	if current_dialogue_index >= dialogue_lines.size():
		end_interaction()
	else:
		_show_current_dialogue()

## 선택지 선택
func choose_option(choice_index: int) -> void:
	if not is_interacting:
		return
	if current_dialogue_index < dialogue_lines.size():
		var line: DialogueLine = dialogue_lines[current_dialogue_index]
		if choice_index < line.choices.size():
			var choice: DialogueChoice = line.choices[choice_index]
			current_dialogue_index = choice.next_line_index
			if current_dialogue_index < 0 or current_dialogue_index >= dialogue_lines.size():
				end_interaction()
			else:
				_show_current_dialogue()

## NPC 데이터에서 대화 라인 생성
func load_dialogue_from_data() -> void:
	dialogue_lines.clear()
	if npc_data == null:
		return
	for text: String in npc_data.dialogue:
		var line: DialogueLine = DialogueLine.new()
		line.speaker = npc_data.npc_name
		line.text = text
		dialogue_lines.append(line)

func _show_current_dialogue() -> void:
	if current_dialogue_index < dialogue_lines.size():
		var line: DialogueLine = dialogue_lines[current_dialogue_index]
		if interaction_label:
			interaction_label.text = line.text

func player_ref_check() -> bool:
	var player: CharacterBody2D = get_player()
	return player != null and is_instance_valid(player)

func get_player() -> CharacterBody2D:
	var player_nodes: Array[Node] = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		return player_nodes[0] as CharacterBody2D
	return null
