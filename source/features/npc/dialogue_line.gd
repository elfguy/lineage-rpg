## 대화 라인
## 대화 트리의 단일 노드를 나타냅니다.

class_name DialogueLine
extends Resource

@export var speaker: String = ""
@export var text: String = ""
@export var choices: Array[DialogueChoice] = []

## 선택지가 없으면 다음 라인으로 자동 진행
func has_choices() -> bool:
	return choices.size() > 0
