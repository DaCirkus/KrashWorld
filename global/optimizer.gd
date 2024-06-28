extends Node

# these nodes will just get hidden when too far
var optimized_nodes_t1 := {}
const t1_distance_th := 60.0

var static_collision_containers := {}

func _ready():
	assert(get_tree().connect("node_added", self, "_on_node_entered_tree") == OK)
	for node in get_tree().get_nodes_in_group("static_body_container"):
		_process_static_body_container(node)


func _on_node_entered_tree(node: Node) -> void:
	if node.is_in_group("static_body_container"):
		_process_static_body_container(node)


func _on_node_tree_exiting(_node: Node) -> void:
	pass


func _process_static_body_container(node: Node) -> void:
	var _err = node.connect("tree_exiting", self, "_on_node_tree_exiting", [node])
	yield(get_tree(), "idle_frame")
	if is_instance_valid(node) and node.is_inside_tree():
		for child in node.get_children():
			if child is MeshInstance:
				process_static_mesh(child, node.is_in_group("use_trimesh"))


func process_static_mesh(node: MeshInstance, use_trimesh := false) -> void:
	var _err = node.create_trimesh_collision() if not use_trimesh else node.create_trimesh_collision()
