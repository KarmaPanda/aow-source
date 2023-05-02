require("util_gui")
require("util_functions")
local FORM_NAME = "form_stage_main\\form_sworn\\form_sworn_title"
local CTS_SUB_MSG_SWORN_CHANGE_TITLE = 4
function main_form_init(form)
  if not nx_is_valid(form) then
    return
  end
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.ipt_input.Text = ""
  form.lbl_count.Text = ""
  form.lbl_select_name.Text = ""
  form.title_id = 0
  nx_execute("custom_sender", "custom_sworn", nx_int(8))
  return
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
  return
end
function on_btn_close_click(btn)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_sure_click(btn)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local title_name = form.ipt_input.Text
  if nx_int(nx_ws_length(nx_widestr(title_name))) ~= nx_int(2) then
    return
  end
  if nx_int(form.title_id) == nx_int(0) then
    return
  end
  nx_execute("custom_sender", "custom_sworn", nx_int(CTS_SUB_MSG_SWORN_CHANGE_TITLE), nx_widestr(title_name), nx_int(form.title_id))
end
function on_btn_click(self)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.title_id = nx_int(self.Name)
  form.lbl_select_name.Text = gui.TextManager:GetText("ui_sworn_lbl_" .. nx_string(form.title_id))
end
function open_form()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    return
  end
  form = nx_execute("util_gui", "util_get_form", FORM_NAME, true, false)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
    return
  end
end
function close_form()
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    form:Close()
  end
end
function get_sworn_num(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local player_num = nx_int(arg[1])
  if nx_int(player_num) >= nx_int(2) and nx_int(player_num) <= nx_int(6) then
    form.lbl_count.Text = gui.TextManager:GetText("ui_sworn_" .. nx_string(player_num))
  end
end
function split_sworn_title(title_info)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return ""
  end
  local list = util_split_wstring(nx_widestr(title_info), nx_widestr("-"))
  local counts = table.getn(list)
  if counts < 3 then
    return ""
  end
  local title_name = nx_widestr(list[1])
  local player_num = nx_int(list[2])
  local title_id = nx_int(list[3])
  local sworn_title = nx_widestr(gui.TextManager:GetFormatText("role_title_" .. nx_string(player_num) .. "_" .. nx_string(title_id), nx_widestr(title_name)))
  return nx_widestr(sworn_title)
end
function show_sworn_title(TitleID)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return ""
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  local title_info = player:QueryProp("SwornTitleInfo")
  local list = util_split_wstring(nx_widestr(title_info), nx_widestr(","))
  local counts = table.getn(list)
  if counts < 3 then
    return ""
  end
  local title_name = nx_widestr(list[1])
  local player_num = nx_int(list[2])
  local sworn_title = nx_widestr(gui.TextManager:GetFormatText("role_title_" .. nx_string(player_num) .. "_" .. nx_string(TitleID), nx_widestr(title_name)))
  return nx_widestr(sworn_title)
end
