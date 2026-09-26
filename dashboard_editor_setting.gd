@tool
extends DashboardItem
class_name DashboardEditorSetting

@export var setting: String

@export_tool_button("Pick editor setting") var select_action: Callable = select_node_property

func select_node_property() -> void:
	var settings: EditorSettings = EditorInterface.get_editor_settings()
	EditorInterface.popup_property_selector(settings, _on_property_selected)

func _on_property_selected(prop_path: NodePath) -> void:
	if !prop_path.is_empty():
		setting = prop_path.get_concatenated_subnames()
		emit_changed()

func get_property_descriptor() -> Dictionary:
	var settings: EditorSettings = EditorInterface.get_editor_settings()

	for prop in settings.get_property_list():
		if prop.name == setting:
			return prop

	return {}

func set_property(value: Variant) -> bool:
	var settings: EditorSettings = EditorInterface.get_editor_settings()
	settings.set(setting, value)
	return true
	

func get_property() -> Variant:
	var settings: EditorSettings = EditorInterface.get_editor_settings()
	return settings.get(setting)

func can_revert() -> bool:
	if setting.is_empty():
		return false
	var settings: EditorSettings = EditorInterface.get_editor_settings()
	return settings.property_can_revert(setting)

func get_revert() -> Variant:
	if setting.is_empty():
		return null
	var settings: EditorSettings = EditorInterface.get_editor_settings()
	return settings.property_get_revert(setting)

func get_source() -> StringName: return &"Editor"
func get_key() -> String: return setting