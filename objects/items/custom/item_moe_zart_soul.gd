extends ItemScript

const STAGGER_TIME := 0.5
const HEAL_AMT := 0.8

var health_monitoring := false
var current_hp := 0
var boost := 0
var inverted := false

var heal_queue: Array[int] = []
var can_queue_heal := true


func on_collect(_item: Item, _object: Node3D) -> void:
	setup()

func on_load(_item: Item) -> void:
	setup()

func setup() -> void:
	BattleService.s_battle_started.connect(battle_started)
	
	var player: Player
	if not is_instance_valid(Util.get_player()):
		player = await Util.s_player_assigned
	else:
		player = Util.get_player()

func battle_started(battle: BattleManager) -> void:
	battle.s_participant_died.connect(participant_died)

func participant_died(participant: Node3D) -> void:
	if participant is Cog:
		queue_heal(ceili((participant.level * HEAL_AMT)/2))

func do_heal(amount: int) -> void:
	Util.get_player().quick_heal(amount)

func queue_heal(amount: int) -> void:
	if heal_queue.is_empty() and can_queue_heal:
		run_heal(amount)
	else:
		heal_queue.append(amount)

func run_heal(amount: int) -> void:
	do_heal(amount)
	can_queue_heal = false
	await TaskMgr.delay(STAGGER_TIME)
	if heal_queue.is_empty():
		can_queue_heal = true
	else:
		run_heal(heal_queue.pop_front())
