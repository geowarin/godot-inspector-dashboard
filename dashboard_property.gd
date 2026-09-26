@tool
extends DashboardItem
class_name DashboardProperty

@export var property_path: String

@export_tool_button("Pick scene property") var select_action: Callable = select_node_property

func select_node_property() -> void:
	EditorInterface.popup_node_selector(_on_node_selected)

func _on_node_selected(node_path: NodePath) -> void:
	if !node_path.is_empty():
		var node := EditorInterface.get_edited_scene_root().get_node_or_null(node_path)
		if node == null:
			return
		EditorInterface.popup_property_selector(node, _on_property_selected.bind(node_path))

func _on_property_selected(prop_path: NodePath, node_path: NodePath) -> void:
	if !prop_path.is_empty():
		property_path = node_path.get_concatenated_names() + ":" + prop_path.get_concatenated_subnames()
		emit_changed()

func get_property_descriptor() -> Dictionary:
	var node_path: NodePath = NodePath(property_path)
	var root: Node = EditorInterface.get_edited_scene_root()
	if root == null:
		return {}
	var path := root.get_node_and_resource(node_path)
	var node: Node = path[0]

	if node == null:
		return {}

	var target: Object = path[1] if path[1] != null else node
	var remaining_path: NodePath = path[2]
	var property_name: StringName = remaining_path.get_subname(0) if remaining_path.get_subname_count() > 0 else node_path.get_subname(0)

	for prop in target.get_property_list():
		if prop.name == property_name:
			return prop

	return {}

func set_property(value: Variant) -> bool:
	var prop := EditorInterface.get_edited_scene_root().get_node_and_resource(property_path)
	var node: Node = prop[0]
	if node == null:
		return false

	var target: Object = prop[1] if prop[1] != null else node
	target.set_indexed(prop[2], value)
	return true
	

func get_property() -> Variant:
	var prop := EditorInterface.get_edited_scene_root().get_node_and_resource(property_path)
	var node: Node = prop[0]
	if node == null:
		return null

	var target: Object = prop[1] if prop[1] != null else node
	return target.get_indexed(prop[2])