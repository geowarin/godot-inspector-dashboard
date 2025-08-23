@tool
extends DashboardItem
class_name DashboardProjectSetting

@export var setting: String

@export_tool_button("Pick project setting") var select_action: Callable = select_node_property

func select_node_property() -> void:
	EditorInterface.popup_property_selector(ProjectSettings, _on_property_selected)

func _on_property_selected(prop_path: NodePath) -> void:
	if !prop_path.is_empty():
		setting = prop_path.get_concatenated_subnames()
		emit_changed()

func get_property_descriptor() -> Dictionary:
	for prop in ProjectSettings.get_property_list():
		if prop.name == setting:
			return prop

	return {}

func set_property(value: Variant) -> bool:
	ProjectSettings.set_setting(setting, value)
	return true

func get_property() -> Variant:
	return ProjectSettings.get_setting(setting)