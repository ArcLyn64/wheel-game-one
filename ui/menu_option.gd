@tool
class_name MenuOption
extends MarginContainer

@export_group('properties')
@export var text:String = '' :
    set(v):
        if label: label.text = v
    get():
        if label: return label.text
        else: return ''
@export var selected:bool = false:
    set(v):
        if highlight: highlight.visible = v
    get():
        if highlight: return highlight.visible
        else: return false
@export var value:String = ''

@export_group('components')
@export var highlight:Control
@export var label:Label