require("util_functions")
require("util_gui")
require("form_stage_main\\form_home\\form_home_msg")
local FORM = "form_stage_main\\form_home\\form_qin_player"
local music_config = "share\\Home\\HomeBuilding\\HomeQinQiNpc.ini"
CLIENT_SUB_HOME_QIN_PLAY = 73
HOME_QIN_SUB_MSG_PLAY = 0
HOME_QIN_SUB_MSG_STOP = 1
HOME_QIN_SUB_MSG_LAST = 2
HOME_QIN_SUB_MSG_NEXT = 3
HOME_QIN_SUB_MSG_MODE = 4
HOME_QIN_SUB_MSG_REQUEST = 5
function main_form_init(form)
  form.Fixed = false
  form.cur_index = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.AbsLeft = (gui.Width - form.Width) / 4
  form.AbsTop = (gui.Height - form.Height) / 2
  init_music_list(form)
  client_to_server_msg(nx_int(CLIENT_SUB_HOME_QIN_PLAY), nx_int(HOME_QIN_SUB_MSG_REQUEST))
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function init_music_list(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", music_config)
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex("home_qin_music")
  if sec_count < 0 then
    return
  end
  local music_count = ini:GetSectionItemCount(sec_count)
  local gb = form.groupscrollbox_music
  if not nx_is_valid(gb) then
    return
  end
  gb.IsEditMode = true
  for i = 1, music_count do
    local rbtn_music = create_ctrl("RadioButton", nx_string("rbtn_music_") .. nx_string(i), form.rbtn_music_mod, gb)
    if math.fmod(music_count, 2) == 0 then
      if i <= music_count / 2 then
        rbtn_music.Top = (i - 1) * rbtn_music.Height + 2
        rbtn_music.Left = 0
      else
        rbtn_music.Top = (i - music_count / 2 - 1) * rbtn_music.Height + 2
        rbtn_music.Left = 150
      end
    elseif i <= (music_count + 1) / 2 then
      rbtn_music.Top = (i - 1) * rbtn_music.Height + 2
      rbtn_music.Left = 0
    else
      rbtn_music.Top = (i - (music_count + 1) / 2 - 1) * rbtn_music.Height + 2
      rbtn_music.Left = 150
    end
    nx_bind_script(rbtn_music, nx_current())
    nx_callback(rbtn_music, "on_checked_changed", "on_rbtn_music_index_checked_changed")
    rbtn_music.index = nx_int(i - 1)
    rbtn_music.Text = nx_widestr(util_text(get_music_dec(i)))
  end
  gb.IsEditMode = false
  gb.Height = gb.Height
  local rbtn_music = gb:Find(nx_string("rbtn_music_1"))
  if nx_is_valid(rbtn_music) then
    rbtn_music.Checked = true
  end
end
function get_music_dec(index)
  local ini = nx_execute("util_functions", "get_ini", music_config)
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_count = ini:FindSectionIndex("music_desc")
  if sec_count < 0 then
    return ""
  end
  local str = ini:ReadString(sec_count, nx_string(index), "")
  return str
end
function on_rbtn_music_index_checked_changed(self)
  if not nx_is_valid(self.ParentForm) then
    return
  end
  if not self.Checked then
    return
  end
  self.ParentForm.cur_index = self.index
end
function on_rbtn_mode_checked_changed(self)
  if not self.Checked then
    return
  end
  local data = self.DataSource
  client_to_server_msg(nx_int(CLIENT_SUB_HOME_QIN_PLAY), nx_int(HOME_QIN_SUB_MSG_MODE), nx_int(data))
end
function on_btn_play_click(self)
  if not nx_is_valid(self.ParentForm) then
    return
  end
  client_to_server_msg(nx_int(CLIENT_SUB_HOME_QIN_PLAY), nx_int(HOME_QIN_SUB_MSG_PLAY), nx_int(self.ParentForm.cur_index))
end
function on_btn_stop_click(self)
  if not nx_is_valid(self.ParentForm) then
    return
  end
  client_to_server_msg(nx_int(CLIENT_SUB_HOME_QIN_PLAY), nx_int(HOME_QIN_SUB_MSG_STOP))
end
function on_btn_close_click(self)
  if not nx_is_valid(self.ParentForm) then
    return
  end
  on_main_form_close(self.ParentForm)
end
function on_btn_last_click(self)
  client_to_server_msg(nx_int(CLIENT_SUB_HOME_QIN_PLAY), nx_int(HOME_QIN_SUB_MSG_LAST))
end
function on_btn_next_click(self)
  client_to_server_msg(nx_int(CLIENT_SUB_HOME_QIN_PLAY), nx_int(HOME_QIN_SUB_MSG_NEXT))
end
function open_form()
  local form = nx_value(FORM)
  if nx_is_valid(form) then
    form:Close()
  end
  form = nx_execute("util_gui", "util_get_form", FORM, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function show_info(...)
  local form = nx_value(FORM)
  if not nx_is_valid(form) then
    return
  end
  local mode = nx_int(arg[1]) + nx_int(1)
  local index = nx_int(arg[2]) + nx_int(1)
  local rbtn_mode = form.groupbox_mode:Find(nx_string("rbtn_") .. nx_string(mode))
  if nx_is_valid(rbtn_mode) then
    rbtn_mode.Checked = true
  end
  local rbtn_music = form.groupscrollbox_music:Find(nx_string("rbtn_music_") .. nx_string(index))
  if nx_is_valid(rbtn_music) then
    rbtn_music.Checked = true
  end
end
function close_form()
  local form = nx_value(FORM)
  if not nx_is_valid(form) then
    return
  end
  on_main_form_close(form)
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  ctrl.Name = name
  return ctrl
end
function a(info)
  nx_msgbox(nx_string(info))
end
