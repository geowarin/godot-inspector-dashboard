@tool
extends Node

@export var properties: Array[DashboardItem] = []:
    set(value):
        properties = value
        for prop in value:
            if !prop.changed.is_connected(notify_property_list_changed):
                prop.changed.connect(notify_property_list_changed)
        notify_property_list_changed()

func _get_property_list() -> Array[Dictionary]:
    var property_list: Array[Dictionary] = []
    for item in properties:
        var prop := get_property(item.property_path)
        if prop.is_empty():
            continue
        var item_dict: Dictionary = {
            "name": item.name,
            "type": prop.type,
            "hint": prop.hint,
            "hint_string": prop.hint_string
        }
        property_list.append(item_dict)
    return property_list

func _set(property: StringName, value: Variant) -> bool:
    for item in properties:
        if item.name == property:
            var prop := get_node_and_resource(item.property_path)
            var node: Node = prop[0]
            if node == null:
                return false
            node.set_indexed(prop[2], value)
            return true
    return false

func _get(property: StringName) -> Variant:
    for item in properties:
        if item == null || item.name.is_empty():
            continue

        if item.name == property:
            var prop := get_node_and_resource(item.property_path)
            var node: Node = prop[0]
            if node == null:
                return null
            return node.get_indexed(prop[2])
    return null


func get_property(node_path: NodePath) -> Dictionary:
    var path := get_node_and_resource(node_path)
    var node: Node = path[0]

    if node == null:
        return {}

    for prop in node.get_property_list():
        if prop.name == node_path.get_subname(0):
            return prop

    return {}