@tool
@abstract
extends Resource
class_name DashboardItem

@abstract func get_property_descriptor() -> Dictionary
@abstract func set_property(_value: Variant) -> bool
@abstract func get_property() -> Variant

func can_revert() -> bool:
	return false

func get_revert() -> Variant:
	return null

@abstract func get_source() -> StringName
@abstract func get_key() -> String

func get_property_name() -> StringName:
	var key := get_key()
	if key.is_empty():
		return &""
	return StringName(get_source() + "/" + key)