@tool
extends Node

@export var properties: Array[DashboardItem] = []:
	set(value):
		properties = value
		for prop in value:
			if prop == null:
				continue
			if !prop.changed.is_connected(notify_property_list_changed):
				prop.changed.connect(notify_property_list_changed)
		notify_property_list_changed()

@export_tool_button("Refresh") var select_action: Callable = notify_property_list_changed

# Rebuilt with the property list, so lookups don't resolve every item on each call.
var _items_by_name: Dictionary[StringName, DashboardItem] = {}

func _get_property_list() -> Array[Dictionary]:
	_items_by_name.clear()
	var property_list: Array[Dictionary] = []
	for item in properties:
		if item == null:
			continue

		var prop := item.get_property_descriptor()
		if prop.is_empty():
			continue
		var property_name := item.get_property_name()
		_items_by_name[property_name] = item
		var item_dict: Dictionary = {
			"name": property_name,
			"type": prop.type,
			"hint": prop.hint if prop.hint != PROPERTY_HINT_GROUP_ENABLE else PROPERTY_HINT_NONE,
			"hint_string": prop.hint_string,
			"class_name": prop.class_name,
			# we keep the default value, as it's a convenient way to enable undo/redo
			# "usage": PROPERTY_USAGE_EDITOR
		}
		property_list.append(item_dict)
	return property_list

func _find_item(property: StringName) -> DashboardItem:
	return _items_by_name.get(property)

func _set(property: StringName, value: Variant) -> bool:
	var item := _find_item(property)
	if item == null:
		return false
	return item.set_property(value)

func _get(property: StringName) -> Variant:
	var item := _find_item(property)
	if item == null:
		return null
	return item.get_property()

func _property_can_revert(property: StringName) -> bool:
	var item := _find_item(property)
	return item != null and item.can_revert()

func _property_get_revert(property: StringName) -> Variant:
	var item := _find_item(property)
	if item == null:
		return null
	return item.get_revert()
