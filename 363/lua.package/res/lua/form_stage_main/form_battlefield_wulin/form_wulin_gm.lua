require("util_gui")
require("util_functions")
require("util_static_data")
require("define\\sysinfo_define")
require("form_stage_main\\form_battlefield_wulin\\wudao_util")
require("custom_sender")
local FORM_WULIN_GM = "form_stage_main\\form_battlefield_wulin\\form_wulin_gm"
local steps = {}
local step_array = {
  apply = {
    ui_name = "ui_wudaodahui_gm_1",
    group_box = nil
  },
  sea = {
    ui_name = "ui_wudaodahui_gm_2",
    group_box = nil
  },
  group = {
    ui_name = "ui_wudaodahui_gm_3",
    group_box = nil
  },
  final = {
    ui_name = "ui_wudaodahui_gm_4",
    group_box = nil
  }
}
function open_form()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not is_in_wudao_prepare_scene() then
    showtip("wudao_systeminfo_10032")
    return
  end
  local form = get_form()
  if nx_is_valid(form) and not form.Visible then
    form.Visible = true
  else
    util_show_form(FORM_WULIN_GM, true)
  end
end
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.AbsLeft = (gui.Width - self.Width) / 2
    self.AbsTop = (gui.Height - self.Height) / 2
  end
  self.rbtn_gm.Checked = true
  steps = {}
  add_step_groupbox("apply")
  add_step_groupbox("sea")
  add_step_groupbox("group")
  add_step_groupbox("final")
  request_gm_ui()
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  nx_destroy(self)
end
function get_form()
  local form = nx_value(FORM_WULIN_GM)
  return form
end
function add_step_groupbox(step_name)
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  local group1 = form.groupbox_gm:Find(nx_string("groupscrollbox_10"))
  local group2 = group1:Find("groupbox_11")
  local groupbox_step = group2:Find("groupbox_step")
  groupbox_step.Visible = false
  local copy = clone(groupbox_step, step_name)
  if not nx_is_valid(copy) then
    return
  end
  table.insert(steps, copy)
  local n = #steps
  copy.Visible = true
  copy.DesignMode = false
  copy.Top = 50 + (n - 1) * 80
  local lbl_step_name = copy:Find("lbl_step_name")
  local btn_save = copy:Find("btn_save")
  local rbtn_is_step_open = copy:Find("rbtn_is_step_open")
  lbl_step_name.Text = nx_widestr(util_text(step_array[step_name].ui_name))
  btn_save.step_name = nx_string(step_name)
  nx_bind_script(btn_save, nx_current())
  nx_callback(btn_save, "on_click", "on_btn_save_click")
  nx_bind_script(rbtn_is_step_open, nx_current())
  group2:Add(copy)
  step_array[step_name].group_box = copy
end
function clone(old_control, new_name)
  local gui = nx_value("gui")
  local copy = gui.Designer:Clone(old_control)
  if nx_is_valid(copy) then
    local child_list = old_control:GetChildControlList()
    for _, old_child in pairs(child_list) do
      if nx_is_valid(old_child) then
        local new_child = gui.Designer:Clone(old_child)
        new_child.fatherctl = new_control
        new_child.DesignMode = false
        new_child.Name = old_child.Name
        new_child.aid = aid
        copy:Add(new_child)
      end
    end
    copy.Name = nx_string(new_name)
    nx_bind_script(copy, nx_current())
    return copy
  end
end
function get_control_by_step(step_name, control_name)
  local groupbox = get_groupbox_by_step(step_name)
  if nx_is_valid(groupbox) then
    return groupbox:Find(control_name)
  end
end
function get_groupbox_by_step(step_name)
  for key, value in pairs(step_array) do
    if nx_string(key) == nx_string(step_name) then
      return value.group_box
    end
  end
end
function on_rbtn_child_form_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local groupbox_list = {
    form.groupbox_gm,
    form.groupbox_ready
  }
  for i = 1, table.maxn(groupbox_list) do
    local groupbox = groupbox_list[i]
    groupbox.Visible = false
  end
  if nx_widestr("rbtn_gm") == nx_widestr(rbtn.Name) then
    form.groupbox_gm.Visible = true
  elseif nx_widestr("rbtn_equip") == nx_widestr(rbtn.Name) then
    form.groupbox_ready.Visible = true
  end
end
function on_btn_save_click(btn)
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  local groupbox = get_groupbox_by_step(btn.step_name)
  local lbl_open_tip = groupbox:Find("lbl_open_tip")
  local rbtn_is_step_open = groupbox:Find("rbtn_is_step_open")
  local ipt_begin_time = groupbox:Find("ipt_begin_time")
  local ipt_end_time = groupbox:Find("ipt_end_time")
  local ipt_day_begin_time = groupbox:Find("ipt_day_begin_time")
  local ipt_day_end_time = groupbox:Find("ipt_day_end_time")
  local str_day_time = nx_string(ipt_day_begin_time.Text) .. nx_string("~") .. nx_string(ipt_day_end_time.Text)
  custom_wudao(nx_int(120), nx_string(btn.step_name), nx_string(ipt_begin_time.Text), nx_string(ipt_end_time.Text), nx_string(str_day_time), str_day_time)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function receive_gm_ui(...)
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local n = #arg
  for step = 1, n do
    local step_text = arg[step]
    local one_step = util_split_string(step_text, ",")
    local step_name = nx_string(one_step[1])
    local is_step_open = nx_int(one_step[2])
    local step_begin_time = nx_int64(one_step[3])
    local step_end_time = nx_int64(one_step[4])
    local day_time = nx_string(one_step[5])
    local day_time_list = util_split_string(day_time, "|")
    local first_day_time = day_time_list[1]
    local day_begin_end_time = util_split_string(first_day_time, "~")
    local day_begin_time = ""
    local day_end_time = ""
    if 2 <= #day_begin_end_time then
      day_begin_time = day_begin_end_time[1]
      day_end_time = day_begin_end_time[2]
    end
    local groupbox = get_groupbox_by_step(step_name)
    local lbl_open_tip = groupbox:Find("lbl_open_tip")
    local rbtn_is_step_open = groupbox:Find("rbtn_is_step_open")
    local ipt_begin_time = groupbox:Find("ipt_begin_time")
    local ipt_end_time = groupbox:Find("ipt_end_time")
    local ipt_day_begin_time = groupbox:Find("ipt_day_begin_time")
    local ipt_day_end_time = groupbox:Find("ipt_day_end_time")
    if is_step_open > nx_int(0) then
      lbl_open_tip.Text = nx_widestr(util_text("ui_wudaodahui_gm_8"))
      rbtn_is_step_open.HintText = nx_widestr(util_text("ui_wudaodahui_gm_17"))
      rbtn_is_step_open.Enabled = true
      rbtn_is_step_open.Checked = true
    else
      lbl_open_tip.Text = nx_widestr(util_text("ui_wudaodahui_gm_7"))
      rbtn_is_step_open.HintText = nx_widestr(util_text("ui_wudaodahui_gm_16"))
      rbtn_is_step_open.Enabled = false
      rbtn_is_step_open.Checked = false
    end
    ipt_begin_time.Text = nx_widestr(get_time_text(step_begin_time))
    ipt_end_time.Text = nx_widestr(get_time_text(step_end_time))
    ipt_day_begin_time.Text = nx_widestr(day_begin_time)
    ipt_day_end_time.Text = nx_widestr(day_end_time)
  end
end
function request_gm_ui()
  custom_wudao(nx_int(119))
end
function get_time_text(time64)
  if nx_int64(time64) == nx_int64(0) then
    return ""
  else
    local year, month, day, hour, mins, sec = nx_function("util_time_utc_to_local", time64)
    local strTime = nx_string(year .. "/" .. month .. "/" .. day .. " " .. hour .. ":" .. mins)
    return strTime
  end
end
function showtip(strTent)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    local info = util_text(strTent)
    SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
  end
end
