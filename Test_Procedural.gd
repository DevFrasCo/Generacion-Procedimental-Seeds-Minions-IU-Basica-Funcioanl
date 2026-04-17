extends Node2D

@export var noise_height_texture : NoiseTexture2D
var noise : Noise

var width : int =  50
var height : int = 50

var source_id = 0
var water_atlas = Vector2(0,0)
var grass_atlas = Vector2(1,1)
var sand_atlas = Vector2(1,1)

@onready var sand_layer: TileMapLayer = $Sand_Layer
@onready var water_layer: TileMapLayer = $Water_Layer
@onready var grass_layer: TileMapLayer = $Grass_Layer


@onready var props_container: Node2D = $Props

var tree_positions := {}

const TREE_MIN_DISTANCE := 2          # separación entre árboles
const COAST_CHECK_RADIUS := 1      # en tiles
const BASE_TREE_CHANCE := 0.25      # probabilidad base

var occupied_positions := {}



@export var vegetation_props := [
	{ "scene": preload("res://Scenes/Tree.tscn"), "weight": 5, "min_dist": 2 },
	{ "scene": preload("res://Scenes/Tree_Fruit.tscn"), "weight": 2, "min_dist": 3 },
	{ "scene": preload("res://Scenes/Bush.tscn"), "weight": 3, "min_dist": 2 },
	{ "scene": preload("res://Scenes/Bush_Fruit.tscn"), "weight": 1, "min_dist": 2},
]

@export var rock_props := [
	{ "scene": preload("res://Scenes/Small_Rock.tscn"), "weight": 9,"min_dist": 2 },
	{ "scene": preload("res://Scenes/Medium_Rock.tscn"), "weight": 7, "min_dist": 3 },
	{ "scene": preload("res://Scenes/Big_Rock.tscn"), "weight": 6, "min_dist": 4 }
]

@export var ore_props := [
	{ "scene": preload("res://Scenes/Iron_Ore.tscn"), "weight": 4, "min_dist": 2 },
	{ "scene": preload("res://Scenes/Gold_Ore.tscn"), "weight": 4, "min_dist": 2 },
	{ "scene": preload("res://Scenes/Silver_Ore.tscn"), "weight": 2, "min_dist": 1 },
	{ "scene": preload("res://Scenes/Daimond_Ore.tscn"), "weight": 3, "min_dist": 2 }
]


func _ready() -> void:
	noise = noise_height_texture.noise
	generate_world()

	randomize()
	generate_all_props()

func generate_world():
	for x in range(width):
		for y in range(height):
			var n := noise.get_noise_2d(x, y)
			var pos := Vector2i(x, y)
			if n < -0.10:
				water_layer.set_cell(pos, source_id, water_atlas)
			elif n < 0.05:
				sand_layer.set_cell(pos, source_id, sand_atlas)
			else:
				grass_layer.set_cell(pos, source_id, grass_atlas)

func get_coast_factor(pos: Vector2i) -> float:
	for dx in range(-COAST_CHECK_RADIUS, COAST_CHECK_RADIUS + 1):
		for dy in range(-COAST_CHECK_RADIUS, COAST_CHECK_RADIUS + 1):
			var check_pos := pos + Vector2i(dx, dy)

			if is_water_tile(check_pos):
				return 0.05  # cerca del agua → casi no hay árboles

	return 1.0  # lejos del agua → densidad normal

func is_water_tile(pos: Vector2i) -> bool:
	return water_layer.get_cell_tile_data(pos) != null
	for dx in range(-TREE_MIN_DISTANCE, TREE_MIN_DISTANCE + 1):
		for dy in range(-TREE_MIN_DISTANCE, TREE_MIN_DISTANCE + 1):
			if dx == 0 and dy == 0:
				continue

			var check_pos := pos + Vector2i(dx, dy)
			if tree_positions.has(check_pos):
				return true

	return false


func is_grass_tile(pos: Vector2i) -> bool:
	var data := grass_layer.get_cell_tile_data(pos)
	return data != null

func is_sand_tile(pos: Vector2i) -> bool:
	var data := sand_layer.get_cell_tile_data(pos)
	return data != null



func generate_category(prop_list, base_chance: float, terrain_type: String):
	for x in range(width):
		for y in range(height):
			var pos := Vector2i(x, y)

			var is_grass := is_grass_tile(pos)
			var is_sand := is_sand_tile(pos)

			# BLOQUEAR agua u otros terrenos
			if not is_grass and not is_sand:
				continue

			# FILTRO POR TIPO
			if terrain_type == "grass" and not is_grass:
				continue

			if terrain_type == "sand" and not is_sand:
				continue

			var chance := base_chance

			# Si es modo mixto, ajustamos densidad
			if terrain_type == "mixed":
				if is_sand:
					chance *= 1.5
				elif is_grass:
					chance *= 0.6

			if randf() > chance:
				continue

			var entry = pick_weighted(prop_list)

			if has_prop_near(pos, entry.min_dist):
				continue

			spawn_prop(entry.scene, pos)
			occupied_positions[pos] = true



func generate_all_props():
	occupied_positions.clear()

	# Vegetación (solo pasto)
	generate_category(vegetation_props, 0.18, "grass")

	# Rocas (ambos, más arena)
	generate_category(rock_props, 0.20, "mixed")

	# Minerales (ambos, más arena)
	generate_category(ore_props, 0.12, "mixed")



func pick_weighted(list: Array) -> Dictionary:
	var total := 0
	
	for e in list:
		total += e["weight"]
	
	var r := randi() % total
	
	for e in list:
		r -= e["weight"]
		if r < 0:
			return e
	
	return list[0]

func has_prop_near(pos: Vector2i, min_dist: int) -> bool:
	for dx in range(-min_dist, min_dist + 1):
		for dy in range(-min_dist, min_dist + 1):
			var check_pos := pos + Vector2i(dx, dy)
			
			if occupied_positions.has(check_pos):
				return true
	
	return false

func spawn_prop(scene: PackedScene, tile_pos: Vector2i):
	var prop = scene.instantiate()
	
	prop.position = grass_layer.map_to_local(tile_pos)
	
	props_container.add_child(prop)
