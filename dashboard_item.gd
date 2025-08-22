@tool
extends Resource
class_name DashboardItem

func get_property_descriptor() -> Dictionary:
    return {}

func set_property(_value: Variant) -> bool:
    return false

func get_property() -> Variant:
    return null