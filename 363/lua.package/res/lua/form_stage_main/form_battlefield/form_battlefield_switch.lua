require("util_functions")
require("form_stage_main\\form_battlefield\\battlefield_define")
local SIDE_WHITE = 3
local SIDE_FASTENTER = 5
local CLIENT_SUBMSG_REQUEST_ENTER = 1
function on_main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.LimitInScreen = true
end
function on_main_form_open(form)
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  local side_type = nx_int(SIDE_WHITE + form.combobox_side.DropListBox.SelectIndex)
  nx_execute("custom_sender", "custom_battlefield", CLIENT_SUBMSG_REQUEST_ENTER, form.select_buddy, form.node_id, form.node_rule, form.play_way, side_type, form.white_force, form.black_force)
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_main_form_get_capture(form)
end
function on_btn_quickjoin_click(btn)
  local form = btn.ParentForm
  local side_type = nx_int(SIDE_FASTENTER)
  nx_execute("custom_sender", "custom_battlefield", CLIENT_SUBMSG_REQUEST_ENTER, form.select_buddy, form.node_id, form.node_rule, form.play_way, side_type, form.white_force, form.black_force)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  form:Close()
end
function show_form(ini, id, rule, play_way, white, black, select)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_battlefield\\form_battlefield_switch", true)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.node_id = id
  form.node_rule = rule
  form.play_way = play_way
  form.white_force = white
  form.black_force = black
  form.select_buddy = select
  if rule == BATTLEFIELD_RULETYPE_1 then
    form.lbl_1.Text = nx_widestr(util_text("ui_battlefield_cooperate"))
    form.combobox_side.DropListBox:ClearString()
    form.combobox_side.DropListBox:AddString(nx_widestr(util_text(form.white_force)))
    form.combobox_side.DropListBox:AddString(nx_widestr(util_text(form.black_force)))
    form.combobox_side.DropListBox.SelectIndex = 0
    form.combobox_side.InputEdit.Text = form.combobox_side.DropListBox.SelectString
    form.combobox_side.OnlySelect = true
    form.combobox_side.DropListBox.SelectIndex = 0
  elseif rule == BATTLEFIELD_RULETYPE_3 then
    form.lbl_1.Text = nx_widestr(util_text("ui_battlefield_side"))
    form.combobox_side.DropListBox:ClearString()
    form.combobox_side.DropListBox:AddString(nx_widestr(util_text("ui_white")))
    form.combobox_side.DropListBox:AddString(nx_widestr(util_text("ui_black")))
    form.combobox_side.DropListBox.SelectIndex = 0
    form.combobox_side.InputEdit.Text = form.combobox_side.DropListBox.SelectString
    form.combobox_side.OnlySelect = true
    form.combobox_side.DropListBox.SelectIndex = 0
  end
  nx_execute("util_gui", "util_show_form", "form_stage_main\\form_battlefield\\form_battlefield_switch", true)
end
function get_mapid_section_index(ini, map_id, rule_type)
  if not nx_is_valid(ini) then
    return -1
  end
  local section_count = ini:GetSectionCount()
  for i = 1, section_count do
    local sec_index = i - 1
    local id = ini:ReadString(sec_index, "map_id", "")
    local rule = ini:ReadInteger(sec_index, "rule", 0)
    if id == map_id and rule_type == rule then
      return sec_index
    end
  end
  return -1
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_battlefield\\form_battlefield_switch", false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
