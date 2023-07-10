require("util_gui")
require("util_functions")
require("util_static_data")
require("define\\sysinfo_define")
require("custom_sender")
require("form_stage_main\\form_taosha\\apex_util")
name_col = 1
kill_col = 2
help_kill_col = 3
help_count_col = 4
relife_col = 5
damage_col = 6
be_damage_col = 7
col_count = 7
local FORM_NAME = "form_stage_main\\form_taosha\\form_apex_awards"
function open_form(...)
  local form = get_form()
  if not nx_is_valid(form) then
    util_show_form(FORM_NAME, true)
  end
  receive_ui(unpack(arg))
end
function close_form()
  local form = get_form()
  if nx_is_valid(form) then
    form:Close()
  end
end
function clone_control(form, control_name, aid)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  local control = nx_custom(form, nx_string(control_name))
  local new_control = gui.Designer:Clone(control)
  if not nx_is_valid(new_control) then
    return nx_null()
  end
  nx_bind_script(new_control, nx_current())
  new_control.DesignMode = false
  new_control.Name = string.format("%s_%s", nx_string(control_name), nx_string(aid))
  new_control.Visible = true
  new_control.aid = aid
  local child_list = control:GetChildControlList()
  for _, child_control in pairs(child_list) do
    if nx_is_valid(child_control) then
      local new_child = gui.Designer:Clone(child_control)
      new_child.fatherctl = new_control
      new_child.DesignMode = false
      new_child.Name = string.format("%s_%s", nx_string(child_control.Name), nx_string(aid))
      new_child.aid = aid
      new_control:Add(new_child)
    end
  end
  return new_control
end
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  reset_form_position()
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_see_click(btn)
  nx_execute("form_stage_main\\form_taosha\\apex_util", "see_other")
  nx_execute("form_stage_main\\form_taosha\\form_apex_notice", "show_stopsee_btn")
  close_form()
end
function on_btn_close_click(btn)
  close_form()
end
function on_cbtn_box_checked_changed(btn)
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  btn.Enbaled = false
  if btn.Checked == false then
    return
  end
  request_get_prize()
end
function reset_form_position()
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.rank = 0
  form.team_kill = 0
  form.is_get_prize = 0
end
function request_open_ui()
  custom_apex(nx_int(104))
end
function request_quit()
  confirm_quit()
end
function request_get_prize()
  custom_apex(nx_int(5))
end
function receive_ui(...)
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  form.rank = nx_int(arg[1])
  form.team_kill = nx_int(arg[2])
  table.remove(arg, 1)
  table.remove(arg, 1)
  form.is_get_prize = 0
  local flag = false
  if nx_int(form.is_get_prize) == nx_int(1) then
    flag = true
  end
  if nx_int(form.rank) == nx_int(1) then
    form.lbl_win.Visible = true
    form.lbl_fail.Visible = false
  else
    form.lbl_win.Visible = false
    form.lbl_fail.Visible = true
  end
  form.lbl_rank.Text = nx_widestr(form.rank)
  form.lbl_team_kill.Text = nx_widestr(form.team_kill)
  form.cbtn_box.Checked = flag
  if flag then
    form.cbtn_box.Enabled = false
  else
    form.cbtn_box.Enabled = true
  end
  refresh_form(form, unpack(arg))
end
function refresh_form(form, ...)
  local temp_table = arg
  local count = table.getn(temp_table) / col_count
  if nx_int(count) <= nx_int(0) then
    return
  end
  local framebox = form.groupbox_1
  local gui = nx_value("gui")
  local index = 1
  for i = 1, count do
    local item_box = clone_control(form, "member_box", nx_string(i))
    framebox:Add(item_box)
    if i == 1 then
      local index = 2
      item_box.Left = 5 + (index - 1) * item_box.Width + 10
      item_box.Top = 5
    elseif i == 2 then
      local index = 1
      item_box.Left = 5 + (index - 1) * item_box.Width + 10
      item_box.Top = 5
    elseif i == 3 then
      local index = 3
      item_box.Left = 5 + (index - 1) * item_box.Width + 10
      item_box.Top = 5
    end
    local name_index = (i - 1) * col_count + name_col
    local name = temp_table[name_index]
    local kill_index = (i - 1) * col_count + kill_col
    local kill = temp_table[kill_index]
    local help_kill_index = (i - 1) * col_count + help_kill_col
    local help_kill = temp_table[help_kill_index]
    local help_count_index = (i - 1) * col_count + help_count_col
    local help_count = temp_table[help_count_index]
    local relife_index = (i - 1) * col_count + relife_col
    local relife = temp_table[relife_index]
    local damage_index = (i - 1) * col_count + damage_col
    local damage = temp_table[damage_index]
    local be_damage_index = (i - 1) * col_count + be_damage_col
    local be_damage = temp_table[be_damage_index]
    local child_name = string.format("%s_%s", nx_string("member_name"), nx_string(i))
    local name_control = item_box:Find(child_name)
    name_control.Text = nx_widestr(name)
    child_name = string.format("%s_%s", nx_string("member_kill"), nx_string(i))
    local kill_control = item_box:Find(child_name)
    kill_control.Text = nx_widestr(kill)
    child_name = string.format("%s_%s", nx_string("member_hlepkill"), nx_string(i))
    local help_kill_control = item_box:Find(child_name)
    help_kill_control.Text = nx_widestr(help_kill)
    child_name = string.format("%s_%s", nx_string("member_helpcount"), nx_string(i))
    local help_count_control = item_box:Find(child_name)
    help_count_control.Text = nx_widestr(help_count)
    child_name = string.format("%s_%s", nx_string("member_relife"), nx_string(i))
    local relife_control = item_box:Find(child_name)
    relife_control.Text = nx_widestr(relife)
    child_name = string.format("%s_%s", nx_string("member_damage"), nx_string(i))
    local damage_control = item_box:Find(child_name)
    damage_control.Text = nx_widestr(damage)
    child_name = string.format("%s_%s", nx_string("member_be_damage"), nx_string(i))
    local be_damage_control = item_box:Find(child_name)
    be_damage_control.Text = nx_widestr(be_damage)
  end
end
function l(info)
  nx_msgbox(nx_string(info))
end
function get_form()
  local form = nx_value(FORM_NAME)
  return form
end
