## NPC Resource 데이터 모델

class_name NPCResource
extends Resource

## NPC 기본 정보
@export var npc_id: String = ""
@export var npc_name: String = ""
@export var dialogue: Array[String] = []

## 퀘스트 관련
@export var available_quests: Array[String] = []

## 상점
@export var shop_items: Array[String] = []

## 외형
@export var sprite_path: String = ""
