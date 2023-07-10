require("util_gui")
require("util_functions")
require("tips_game")
local DONGHAI_FUNC_PENGLAI = 0
local DONGHAI_FUNC_WUJI = 1
local DONGHAI_FUNC_XIAKE = 2
local DONGHAI_TYPE_FIND_NPC = 1
local DONGHAI_TYPE_OPEN_UI = 2
local DONGHAI_ALL = 0
local DONGHAI_CAN_JOIN = 1
local DONGHAI_CANNOT_JOIN = 2
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function main_form_init(form)
  form.Fixed = false
  form.current_func = DONGHAI_FUNC_PENGLAI
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  local combobox = form.combobox_area
  combobox.DropListBox:ClearString()
  combobox.DropListBox:AddString(nx_widestr(util_text("ui_dhact_state_0")))
  combobox.DropListBox:AddString(nx_widestr(util_text("ui_dhact_state_2")))
  combobox.DropListBox:AddString(nx_widestr(util_text("ui_dhact_state_1")))
  combobox.DropListBox.SelectIndex = 0
  combobox.InputEdit.Text = combobox.DropListBox:GetString(0)
  local form_logic = nx_value("form_activity_donghai")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
  form_logic = nx_create("form_activity_donghai")
  if nx_is_valid(form_logic) then
    nx_set_value("form_activity_donghai", form_logic)
  end
  form.rbtn_penglai.Checked = true
  form_logic:ShowDhData(DONGHAI_FUNC_PENGLAI, DONGHAI_ALL)
end
function on_main_form_close(form)
  local form_logic = nx_value("form_activity_donghai")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_combobox_area_selected(self)
  local index = self.DropListBox.SelectIndex
  local form = self.ParentForm
  refresh_activities(form.current_func, index)
end
function on_rbtn_penglai_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  refresh_activities(DONGHAI_FUNC_PENGLAI, DONGHAI_ALL)
  local form = rbtn.ParentForm
  local combobox = form.combobox_area
  combobox.DropListBox.SelectIndex = DONGHAI_ALL
  combobox.InputEdit.Text = combobox.DropListBox:GetString(DONGHAI_ALL)
  form.current_func = DONGHAI_FUNC_PENGLAI
end
function on_rbtn_wuji_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  refresh_activities(DONGHAI_FUNC_WUJI, DONGHAI_ALL)
  local form = rbtn.ParentForm
  local combobox = form.combobox_area
  combobox.DropListBox.SelectIndex = DONGHAI_ALL
  combobox.InputEdit.Text = combobox.DropListBox:GetString(DONGHAI_ALL)
  form.current_func = DONGHAI_FUNC_WUJI
end
function on_rbtn_xialke_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  refresh_activities(DONGHAI_FUNC_XIAKE, DONGHAI_ALL)
  local form = rbtn.ParentForm
  local combobox = form.combobox_area
  combobox.DropListBox.SelectIndex = DONGHAI_ALL
  combobox.InputEdit.Text = combobox.DropListBox:GetString(DONGHAI_ALL)
  form.current_func = DONGHAI_FUNC_XIAKE
end
function refresh_activities(func_type, selected)
  local form_logic = nx_value("form_activity_donghai")
  if nx_is_valid(form_logic) then
    form_logic:ShowDhData(func_type, selected)
  end
end
function on_imagegrid_prize_lost_capture(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_imagegrid_prize_get_capture(grid, index)
  local gui = nx_value("gui")
  nx_execute("tips_game", "hide_tip")
  local x, y = gui:GetCursorClientPos()
  if grid.tips ~= "" and grid.tips ~= nil then
    nx_execute("tips_game", "show_text_tip", util_text(grid.tips), x, y)
  end
end
function find_npc(self)
  nx_execute("hyperlink_manager", "find_path_npc_item", nx_widestr(self.DataSource))
end
function open_activity_ui(self)
end
