require("share\\view_define")
require("util_gui")
require("game_object")
require("util_static_data")
require("define\\tip_define")
require("share\\client_custom_define")
require("share\\capital_define")
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Desktop.Width - form.Width) * 6 / 10
  form.Top = (gui.Desktop.Height - form.Height) * 5 / 10
  form.choice = 0
  form.tick = 20
  if nx_running(nx_current(), "form_tick") then
    nx_kill(nx_current(), "form_tick")
  end
  nx_execute(nx_current(), "form_tick", form)
end
function on_main_form_close(form)
  if nx_running(nx_current(), "form_tick") then
    nx_kill(nx_current(), "form_tick")
  end
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_ok_click(btn)
  local form = btn.Parent
  local boss_id = ""
  if nx_find_custom(form, "boss_id") then
    boss_id = form.boss_id
  end
  nx_execute("custom_sender", "custom_clone_reduce_difficulty_choice", nx_int(form.choice), nx_string(boss_id))
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.Parent
  local boss_id = ""
  if nx_find_custom(form, "boss_id") then
    boss_id = form.boss_id
  end
  form:Close()
end
function on_lbl_cancel_click(lbl)
  local form = lbl.Parent
  local boss_id = ""
  if nx_find_custom(form, "boss_id") then
    boss_id = form.boss_id
  end
  nx_execute("custom_sender", "custom_clone_reduce_difficulty_choice", nx_int(0), nx_string(boss_id))
  form:Close()
end
function form_tick(form)
  while nx_is_valid(form) do
    nx_pause(1)
    if not nx_is_valid(form) then
      return
    end
    if not nx_find_custom(form, "tick") then
      return
    end
    local tick = nx_number(form.tick)
    tick = tick - 1
    if tick < nx_number(0) then
      nx_execute("custom_sender", "custom_clone_reduce_difficulty_choice", nx_int(form.choice))
      form:Close()
      return
    end
    form.tick = tick
    form.lbl_tick.Text = nx_widestr(tick)
  end
end
function on_rbtn_col_strength_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.choice = rbtn.change_index
  end
  local control_list = form.groupbox_change:GetChildControlList()
  for i = 1, table.getn(control_list) do
    local control = control_list[i]
    if nx_find_custom(control, "change_index") and nx_int(control.change_index) ~= nx_int(form.choice) then
      control.Checked = false
    end
  end
end
function refresh_form(form, boss_id, ...)
  form.boss_id = boss_id
  if arg == nil then
    return
  end
  local gui = nx_value("gui")
  form.groupbox_change:DeleteAll()
  for i = 1, table.getn(arg) do
    local change_index = nx_int(arg[i])
    local checkbutton = gui:Create("CheckButton")
    checkbutton.AutoSize = true
    checkbutton.NormalImage = "gui\\common\\checkbutton\\cbtn_2_out.png"
    checkbutton.FocusImage = "gui\\common\\checkbutton\\cbtn_2_on.png"
    checkbutton.CheckedImage = "gui\\common\\checkbutton\\cbtn_2_down.png"
    checkbutton.AbsLeft = 20
    checkbutton.AbsTop = i * 24
    nx_bind_script(checkbutton, nx_current(), "")
    nx_callback(checkbutton, "on_checked_changed", "on_rbtn_col_strength_checked_changed")
    checkbutton.change_index = change_index
    form.groupbox_change:Add(checkbutton)
    local label = gui:Create("Label")
    label.AbsLeft = 55
    label.AbsTop = i * 24
    label.ForeColor = "255,255,255,255"
    label.Text = gui.TextManager:GetFormatText("ui_col_strength" .. nx_string(change_index), nx_int(get_change_string_arg(boss_id, change_index)))
    label.Font = "font_text"
    form.groupbox_change:Add(label)
  end
end
function get_change_string_arg(boss_id, change_index)
  local BOSS_STRENGTH_CHANGE_HP1 = 1
  local BOSS_STRENGTH_CHANGE_HP2 = 2
  local BOSS_STRENGTH_CHANGE_HP3 = 3
  local BOSS_STRENGTH_CHANGE_STR1 = 4
  local BOSS_STRENGTH_CHANGE_STR2 = 5
  local BOSS_STRENGTH_CHANGE_STR3 = 6
  local BOSS_STRENGTH_CHANGE_HELPER1 = 7
  local BOSS_STRENGTH_CHANGE_HELPER2 = 8
  if nx_int(change_index) ~= nx_int(BOSS_STRENGTH_CHANGE_HELPER1) and nx_int(change_index) ~= nx_int(BOSS_STRENGTH_CHANGE_HELPER2) then
    return ""
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\clone\\BossCallHelpRule.ini", true)
  if not nx_is_valid(ini) then
    return ""
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return ""
  end
  local scene_config = client_scene:QueryProp("ConfigID")
  local level = client_scene:QueryProp("Level")
  local call_help_index = nx_string(scene_config) .. "_" .. nx_string(level) .. "_" .. nx_string(boss_id)
  local sect_index = ini:FindSectionIndex(nx_string(call_help_index))
  if sect_index < 0 then
    return ""
  end
  if nx_int(change_index) == nx_int(BOSS_STRENGTH_CHANGE_HELPER1) then
    return nx_string(ini:ReadString(sect_index, "CallHelperNum2", ""))
  elseif nx_int(change_index) == nx_int(BOSS_STRENGTH_CHANGE_HELPER2) then
    return nx_string(ini:ReadString(sect_index, "CallHelperNum3", ""))
  end
  return ""
end
