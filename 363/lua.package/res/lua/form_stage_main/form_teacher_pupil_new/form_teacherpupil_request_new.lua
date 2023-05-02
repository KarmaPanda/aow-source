require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("form_stage_main\\form_teacher_pupil_new\\teacherpupil_define_new")
function custom_request_teacher_pupil(rq_type, name)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if nx_int(1) == nx_int(rq_type) then
    gui.TextManager:Format_SetIDName("ui_shitu_desc_01")
  else
    gui.TextManager:Format_SetIDName("ui_shitu_desc_02")
  end
  local dialog = nx_execute("util_gui", "util_get_form", FORM_REQUEST_NEW, true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog.mltbox_info:Clear()
  local info = gui.TextManager:Format_GetText()
  local index = dialog.mltbox_info:AddHtmlText(nx_widestr(info), -1)
  dialog.request_type = rq_type
  dialog.target_name = name
  dialog:ShowModal()
end
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local name = form.target_name
  if nx_widestr(form.target_name) == nx_widestr("") then
    return
  end
  local rq_type = form.request_type
  if nx_int(rq_type) == nx_int(REQUEST_BAISHI) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_TEACHER), nx_int(11), nx_int(1), nx_widestr(name))
  else
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_TEACHER), nx_int(11), nx_int(2), nx_widestr(name))
  end
  nx_gen_event(form, "confirm_return", "ok")
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_gen_event(form, "confirm_return", "cancel")
  form:Close()
end
function on_server_msg(sub_msg, ...)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  if nx_int(sub_msg) == nx_int(0) then
    local name = nx_widestr(arg[1])
    local has_reward = nx_int(arg[2])
    gui.TextManager:Format_SetIDName("ui_shitu_shoutu")
    gui.TextManager:Format_AddParam(nx_widestr(name))
    gui.TextManager:Format_AddParam(nx_int(has_reward))
    local info = gui.TextManager:Format_GetText()
    local res = show_tip_dialog(info)
    if res ~= "ok" then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_TEACHER), nx_int(NT_CTS_ANS_BAI_SHI), nx_int(1))
  elseif nx_int(sub_msg) == nx_int(1) then
    local name = nx_widestr(arg[1])
    local can_chushi = nx_int(arg[2])
    gui.TextManager:Format_SetIDName("ui_shitu_baishi_1")
    gui.TextManager:Format_AddParam(nx_widestr(name))
    gui.TextManager:Format_AddParam(nx_int(can_chushi))
    local info = gui.TextManager:Format_GetText()
    local res = show_tip_dialog(info)
    if res ~= "ok" then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_TEACHER), nx_int(NT_CTS_ANS_SHOU_TU), nx_int(1))
  elseif nx_int(sub_msg) == nx_int(4) then
    local name = nx_widestr(arg[1])
    local request_type = nx_int(arg[2])
    local ret_value = nx_int(arg[3])
    local text
    if request_type == nx_int(1) then
      gui.TextManager:Format_SetIDName("ui_new_request_before_baishi")
    else
      gui.TextManager:Format_SetIDName("ui_new_request_before_shoutu")
    end
    gui.TextManager:Format_AddParam(nx_widestr(name))
    gui.TextManager:Format_AddParam(nx_int(ret_value))
    local info = gui.TextManager:Format_GetText()
    if request_type == nx_int(2) then
      local chushi_reward = nx_int(arg[4])
      if nx_int(chushi_reward) == nx_int(0) then
        text = nx_widestr(util_format_string("ui_new_teacher_chushi_no"))
      else
        text = nx_widestr(util_format_string("ui_new_teacher_chushi_yes"))
      end
      info = info .. text
    end
    local res = show_tip_dialog(info)
    if res ~= "ok" then
      return
    end
    if request_type == nx_int(1) then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_TEACHER), nx_int(NT_CTS_ASK_BAI_SHI), nx_widestr(name))
    else
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_TEACHER), nx_int(NT_CTS_ASK_SHOU_TU), nx_widestr(name))
    end
  end
end
function show_tip_dialog(text)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog:ShowModal()
  dialog.mltbox_info:Clear()
  local index = dialog.mltbox_info:AddHtmlText(nx_widestr(text), -1)
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  return res
end
