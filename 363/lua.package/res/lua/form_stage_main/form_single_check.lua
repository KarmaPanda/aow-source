require("share\\client_custom_define")
ESINGLE_CUSTOM_TYPE_MOVE_END = 1
ESINGLE_CUSTOM_TYPE_CONTINUE = 2
ESINGLE_CUSTOM_CHECK_OK = 3
function open_this_form()
  local form = nx_value("form_stage_main\\form_single_check")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_single_check", true)
    nx_set_value("form_stage_main\\form_single_check", form)
  end
  form:Show()
  form.Visible = true
end
function on_size_change()
  local form = nx_value("form_stage_main\\form_single_check")
  if nx_is_valid(form) then
    form_layout_center(form)
  end
end
function form_layout_center(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_open(self)
  form_layout_center(self)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_1_click(self)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SINGLE_STEP), ESINGLE_CUSTOM_TYPE_MOVE_END, nx_int(1))
  end
  local form = nx_value("form_stage_main\\form_single_check")
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_2_click(self)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SINGLE_STEP), ESINGLE_CUSTOM_TYPE_MOVE_END, nx_int(0))
  end
  local form = nx_value("form_stage_main\\form_single_check")
  if nx_is_valid(form) then
    form:Close()
  end
end
function custom_single_set_form(value)
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if nx_is_valid(form) then
    local bshow = false
    if value == 1 then
      bshow = true
    end
    form.groupbox_4.Visible = bshow
  end
end
function single_delete_role()
  local sock = nx_value("game_sock")
  if not nx_is_valid(sock) then
    return
  end
  local IsDelete = sock.Receiver:GetRoleDeleted(0)
  if 0 < IsDelete then
    return false
  end
  local role_index = 0
  local gui = nx_value("gui")
  nx_execute("client", "delete_role", role_index)
  local res = nx_wait_event(100000000, nx_null(), "delete_role")
  return res == "succeed"
end
function single_teach_form(value)
  local form
  if 1 == nx_number(value) then
    form = nx_execute("util_gui", "util_show_form", "form_stage_main\\form_help\\form_help_zhaojia", true)
  elseif 2 == nx_number(value) then
    form = nx_execute("util_gui", "util_show_form", "form_stage_main\\form_help\\form_help_pofang", true)
  elseif 3 == nx_number(value) then
    form = nx_execute("util_gui", "util_show_form", "form_stage_main\\form_help\\form_help_QiZhen", true)
  end
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  end
end
function single_player_giveup()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local player = game_visual:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  nx_pause(1)
  single_delete_role()
end
function single_old_check()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false, "chat")
  if not nx_is_valid(dialog) then
    return false
  end
  local text = gui.TextManager:GetText("ui_muse_lzh_ts")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SINGLE_STEP), ESINGLE_CUSTOM_CHECK_OK)
end
