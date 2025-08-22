@tool
extends DashboardItem
class_name DashboardProperty

@export var name: String
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
    var path := EditorInterface.get_edited_scene_root().get_node_and_resource(node_path)
    var node: Node = path[0]

    if node == null:
        return {}

    for prop in node.get_property_list():
        if prop.name == node_path.get_subname(0):
            return prop

    return {}

func set_property(value: Variant) -> bool:
    var prop := EditorInterface.get_edited_scene_root().get_node_and_resource(property_path)
    var node: Node = prop[0]
    if node == null:
        return false
    node.set_indexed(prop[2], value)
    return true
    

func get_property() -> Variant:
    var prop := EditorInterface.get_edited_scene_root().get_node_and_resource(property_path)
    var node: Node = prop[0]
    if node == null:
        return null
    return node.get_indexed(prop[2])