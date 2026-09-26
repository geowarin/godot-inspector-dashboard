@tool
extends DashboardItem
class_name DashboardProperty

@export var property_path: String

@export_tool_button("Pick scene property") var select_action: Callable = select_node_property

func select_node_property() -> void:
	EditorInterface.popup_node_selector(_on_node_selected)

func _on_node_selected(node_path: NodePath) -> void:
	if node_path.is_empty():
		return

	var node := EditorInterface.get_edited_scene_root().get_node_or_null(node_path)
	if node == null:
		return

	EditorInterface.popup_property_selector(
			node,
			_on_object_property_selected.bind(node_path, node, PackedStringArray())
	)

func _on_object_property_selected(
		prop_path: NodePath,
		node_path: NodePath,
		object: Object,
		property_parts: PackedStringArray
) -> void:
	if prop_path.is_empty():
		return

	var next_property_parts := property_parts.duplicate()
	next_property_parts.append(prop_path.get_concatenated_subnames())

	var value: Variant = object.get_indexed(prop_path)
	if value is Resource:
		EditorInterface.popup_property_selector(
				value,
				_on_object_property_selected.bind(node_path, value, next_property_parts)
		)
		return

	property_path = node_path.get_concatenated_names() + ":" + ":".join(next_property_parts)
	emit_changed()

# The node or resource that owns the property.
func _get_target() -> Object:
	var root: Node = EditorInterface.get_edited_scene_root()
	if root == null or property_path.is_empty():
		return null
	var path := root.get_node_and_resource(NodePath(property_path))
	if path[0] == null:
		return null
	return path[1] if path[1] != null else path[0]

func _get_property_name() -> StringName:
	var node_path := NodePath(property_path)
	var count := node_path.get_subname_count()
	if count == 0:
		return &""
	return node_path.get_subname(count - 1)

func get_property_descriptor() -> Dictionary:
	var target := _get_target()
	if target == null:
		return {}

	var property_name := _get_property_name()
	for prop in target.get_property_list():
		if prop.name == property_name:
			return prop

	return {}

func _get_node() -> Node:
	var root: Node = EditorInterface.get_edited_scene_root()
	if root == null or property_path.is_empty():
		return null
	return root.get_node_or_null(NodePath(property_path))

# Property path relative to the node, e.g. ":material:albedo_color".
func _get_indexed_path() -> NodePath:
	return NodePath(":" + NodePath(property_path).get_concatenated_subnames())

func set_property(value: Variant) -> bool:
	var node := _get_node()
	if node == null:
		return false
	node.set_indexed(_get_indexed_path(), value)
	return true

func get_property() -> Variant:
	var node := _get_node()
	if node == null:
		return null
	return node.get_indexed(_get_indexed_path())

func can_revert() -> bool:
	return get_revert() != null

# Object.property_can_revert only covers classes overriding _property_can_revert,
# so fall back to script and engine defaults like the regular inspector does.
func get_revert() -> Variant:
	var target := _get_target()
	if target == null:
		return null

	var property_name := _get_property_name()
	if target.property_can_revert(property_name):
		return target.property_get_revert(property_name)

	var script: Script = target.get_script()
	if script != null:
		var script_default: Variant = script.get_property_default_value(property_name)
		if script_default != null:
			return script_default

	return ClassDB.class_get_property_default_value(target.get_class(), property_name)

func get_source() -> StringName: return &"Node"
func get_key() -> String: return property_path.replace(":", "/")