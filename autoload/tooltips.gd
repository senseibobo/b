extends CanvasLayer


@export var tooltip_panel: PanelContainer

@export var title_label: Label
@export var description_label: Label
@export var disclaimer_label: Label

var time_still: float = 0.0
var last_hovered: Control


func _ready():
	tooltip_panel.visible = false


func show_tooltip(pos: Vector2, tooltip_info: TooltipInfo):
	disclaimer_label.visible = tooltip_info.disclaimer != ""
	title_label.text = tooltip_info.title
	description_label.text = tooltip_info.description
	disclaimer_label.text = tooltip_info.disclaimer
	tooltip_panel.global_position = pos
	tooltip_panel.visible = true


func add_tooltip(control: Control, title, description, disclaimer):
	var tooltip_info := TooltipInfo.new()
	tooltip_info.title = title
	tooltip_info.description = description
	tooltip_info.disclaimer = disclaimer
	control.set_meta(&"tooltip_info", tooltip_info)
	control.mouse_entered.connect(_on_mouse_entered.bind(control))
	control.mouse_exited.connect(_on_mouse_exited.bind(control))


func _on_mouse_entered(control: Control):
	time_still = 0.0
	last_hovered = control


func _on_mouse_exited(control: Control):
	if last_hovered == control: last_hovered = null
	time_still = 0.0
	tooltip_panel.visible = false
	
	
func _process(delta):
	if not tooltip_panel.visible and is_instance_valid(last_hovered):
		var tooltip_info = last_hovered.get_meta(&"tooltip_info", null)
		time_still += delta
		if time_still >= 0.01:
			show_tooltip(tooltip_panel.get_global_mouse_position(), tooltip_info)
		
