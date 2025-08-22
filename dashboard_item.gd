@tool
extends Resource
class_name DashboardItem

@export var name: String
@export var property_path: String

@export_tool_button("Select") var select_action: Callable = select_node_property

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