require("util_gui")
require("util_functions")
function main_form_init(self)
  self.Fixed = false
  self.old_name = nx_widestr("")
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = 0 - (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.ok_btn.Enabled = false
  self.lbl_name_state.Visible = false
  show_CD_time(self)
  show_player_info(self)
  local databinder = nx_value("data_binder")
  databinder:AddRolePropertyBind("ChangeNameTime", "int", self, nx_current(), "on_CD_time_change")
  databinder:AddRolePropertyBind("Name", "widestr", self, nx_current(), "on_name_change")
  self.btn_name.Visible = false
  local CheckWords = nx_value("CheckWords")
  if not nx_is_valid(CheckWords) then
    return 0
  end
  local rule_info = CheckWords:GetNameRule()
  if #rule_info < 4 then
    return 0
  end
  local bRes = 0
  if nx_int(rule_info[1]) == nx_int(1) then
    self.btn_name.Visible = true
  end
  return 1
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function on_CD_time_change(form)
  show_CD_time(form)
end
function on_name_change(form, ...)
  local name = arg[3]
  if nx_widestr(form.old_name) ~= nx_widestr(name) and nx_widestr(form.old_name) ~= nx_widestr("") then
    show_player_info(form)
    nx_execute("form_stage_main\\form_name_modify_endtime", "show_revise_exit_time_form", 5)
  end
end
function show_player_info(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  form.lbl_photo.BackImage = client_player:QueryProp("Photo")
  form.ipt_name.Text = client_player:QueryProp("Name")
  form.old_name = client_player:QueryProp("Name")
end
function show_CD_time(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local change_time = client_player:QueryProp("ChangeNameTime")
  if change_time == 0 then
    return
  end
  local wstr_time = nx_execute("form_stage_main\\form_vip_info", "format_time_form", change_time)
  local wstr_time_text = util_format_string("ui_revise_remain_time", wstr_time)
  form.lbl_2.Text = wstr_time_text
end
function on_server_msg(...)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_name_modify", true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  nx_execute("util_gui", "ui_show_attached_form", form)
  return true
end
function on_main_form_close(self)
  if nx_is_valid(self) then
    ui_destroy_attached_form(self)
  end
  nx_destroy(self)
end
function ok_btn_click(self)
  local form = self.ParentForm
  local CheckWords = nx_value("CheckWords")
  if not nx_is_valid(CheckWords) then
    return 0
  end
  local rule_info = CheckWords:GetNameRule()
  if #rule_info < 4 then
    return 0
  end
  local bRes = 0
  if nx_int(rule_info[1]) == nx_int(1) then
    bRes = CheckWords:CheckBadName(form.ipt_1.Text, nx_int(0))
  end
  if nx_int(bRes) == nx_int(0) then
    local op_type = 0
    if form.cbtn_1.Checked == true then
      op_type = op_type + 1
    end
    if form.cbtn_2.Checked == true then
      op_type = op_type + 2
    end
    if form.cbtn_3.Checked == true then
      op_type = op_type + 4
    end
    if form.cbtn_4.Checked == true then
      op_type = op_type + 8
    end
    if get_confirm(util_format_string("ui_revise_sure")) == true then
      nx_execute("custom_sender", "custom_send_name_change", nx_widestr(form.ipt_1.Text), nx_int(op_type))
    end
  end
  return 1
end
function get_confirm(confirm_text)
  local confirm_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local gui = nx_value("gui")
  confirm_dialog.Left = (gui.Width - confirm_dialog.Width) / 2
  confirm_dialog.Top = (gui.Height - confirm_dialog.Height) / 2
  nx_execute("form_common\\form_confirm", "show_common_text", confirm_dialog, confirm_text)
  confirm_dialog:ShowModal()
  local res = nx_wait_event(100000000, confirm_dialog, "confirm_return")
  return res == "ok"
end
function cancel_btn_click(self)
  local form = self.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
  return 1
end
function on_ipt_1_changed(self)
  local form = self.Parent
  if not nx_is_valid(form) then
    return
  end
  local CheckWords = nx_value("CheckWords")
  local rule_info = CheckWords:GetNameRule()
  if #rule_info < 4 then
    form.lbl_name_state.Visible = false
    form.ok_btn.Enabled = true
    return 0
  end
  local bRes = 0
  if nx_int(rule_info[1]) == nx_int(1) then
    bRes = CheckWords:CheckBadName(form.ipt_1.Text, nx_int(0))
  end
  if bRes == 0 then
    form.lbl_name_state.Visible = false
    form.ok_btn.Enabled = true
  else
    if self.Text ~= nx_widestr("") then
      form.lbl_name_state.Visible = true
    else
      form.lbl_name_state.Visible = false
    end
    form.ok_btn.Enabled = false
  end
end
function on_btn_name_click(self)
  local form = self.Parent
  if not nx_is_valid(form) then
    return
  end
  local first_name = nx_execute("form_stage_main\\form_firstname_list", "firstname_random", 9, 1)
  local second_name = get_second_name_random()
  form.ipt_1.Text = first_name .. second_name
end
function get_second_name_random()
  local filename = get_ini_file_name()
  local ini = nx_execute("util_functions", "get_ini", nx_string(filename))
  if not nx_is_valid(ini) then
    return nx_widestr("")
  end
  local second_name = ini:GetSectionList()
  local nNameCount = nx_int(ini:GetSectionCount())
  local randoms = math.random(nx_number(nNameCount))
  local name = ini:ReadString(nx_int(second_name[randoms]), "SecondName", "")
  return nx_widestr(util_text(name))
end
function get_ini_file_name()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local sex = client_player:QueryProp("Sex")
  local file_name
  if nx_int(sex) == nx_int(0) then
    file_name = "ini\\name\\second_name_boy.ini"
  else
    file_name = "ini\\name\\second_name_girl.ini"
  end
  return file_name
end
function on_ready()
  local form = nx_value("form_stage_main\\form_name_modify")
  if nx_is_valid(form) then
    on_main_form_close(form)
  end
end
