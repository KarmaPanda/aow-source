require("util_gui")
require("util_functions")
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  choose_page(self)
  self.cbtn_1.Checked = load_tvt_update_checkstate()
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.Left = (gui.Width - self.Width) / 2
    self.Top = (gui.Height - self.Height) / 2
  end
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_rbtn_1_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  form.groupbox_1:DeleteAll()
  local form_update = util_get_form("form_stage_main\\form_main\\form_main_update", true, false)
  if nx_is_valid(form_update) then
    form.lbl_title.Text = rbtn.Text
    form.groupbox_1:Add(form_update)
    form_update.Left = 0
    form_update.Top = 0
  end
end
function on_rbtn_2_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  form.groupbox_1:DeleteAll()
  local form_tvt_active = util_get_form("form_stage_main\\form_tvt\\form_tvt_active", true, false)
  if nx_is_valid(form_tvt_active) then
    form.lbl_title.Text = rbtn.Text
    form.groupbox_1:Add(form_tvt_active)
    form_tvt_active.Left = 0
    form_tvt_active.Top = 0
  end
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function on_cbtn_1_checked_changed(cbtn)
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    nx_destroy(ini)
    return
  end
  ini.FileName = account .. "\\tvt_update.ini"
  ini:LoadFromFile()
  ini:WriteInteger("show", "checked", nx_int(cbtn.Checked))
  ini:SaveToFile()
  nx_destroy(ini)
end
function load_tvt_update_checkstate()
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return true
  end
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    nx_destroy(ini)
    return true
  end
  ini.FileName = account .. "\\tvt_update.ini"
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return true
  end
  local checked = 1 == ini:ReadInteger("show", "checked", 1)
  nx_destroy(ini)
  return checked
end
function is_need_tips()
  if load_tvt_update_checkstate() then
    return false
  end
  return true
end
function choose_page(form)
  if not nx_is_valid(form) then
    return
  end
  local default = form.rbtn_2
  local ini = get_ini("ini\\update\\update_choose.ini")
  if not nx_is_valid(ini) then
    default.Checked = true
    return
  end
  local time_str = ini:ReadString("update", "d", "")
  local mid = string.find(time_str, "-")
  if nil == mid then
    default.Checked = true
    return
  end
  local begin_time = string.sub(time_str, 0, mid - 1)
  local end_time = string.sub(time_str, mid + 1, string.len(time_str))
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    default.Checked = true
    return
  end
  local now = msg_delay:GetServerDateTime()
  local year, month, day, hour, mins, sec = nx_function("ext_decode_date", now)
  local data_now = string.format("%04d%02d%02d", year, month, day)
  if nx_string(data_now) >= nx_string(begin_time) and nx_string(data_now) <= nx_string(end_time) then
    default = form.rbtn_1
    default.Checked = true
    return
  end
  default.Checked = true
  return
end
