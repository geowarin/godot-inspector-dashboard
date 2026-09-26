@tool
@abstract
extends Resource
class_name DashboardItem

func get_property_descriptor() -> Dictionary:
	return {}

func set_property(_value: Variant) -> bool:
	return false

func get_property() -> Variant:
	return null

func can_revert() -> bool:
	return false

func get_revert() -> Variant:
	return null

func get_property_name() -> String:
	var prop := get_property_descriptor()
	if prop.is_empty():
		return ""
	return prop.get("name", "")