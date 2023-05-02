require("util_gui")
require("util_functions")
require("define\\request_type")
require("form_stage_main\\form_teacher_pupil\\teacherpupil_define")
REQUEST_BAISHI = 1
REQUEST_SHOUTU = 2
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local cur_main_game_step = switch_manager:GetMainGameStep()
  local neigonglevel = get_neigong_level()
  local max_neigonglevel
  if nx_int(cur_main_game_step) > nx_int(neigonglevel) then
    max_neigonglevel = neigonglevel
  else
    max_neigonglevel = cur_main_game_step
  end
  for i = 2, max_neigonglevel do
    if nx_int(form.request_type) == nx_int(REQUEST_BAISHI) then
      form.combobox_ng.DropListBox:AddString(nx_widestr(util_text("ui_shixiong_" .. i)))
    else
      form.combobox_ng.DropListBox:AddString(nx_widestr(util_text("ui_shidi_" .. i)))
    end
  end
  if nx_int(form.request_type) == nx_int(REQUEST_BAISHI) then
    form.combobox_ng.Text = nx_widestr(util_text("ui_shixiong_2"))
    form.lbl_6.Text = util_text("ui_shitu_jinmai")
  else
    form.combobox_ng.Text = nx_widestr(util_text("ui_shidi_2"))
    form.lbl_6.Text = util_text("ui_shitu_jinmai_1")
  end
  form.max_neigonglevel = max_neigonglevel
  form.level = 2
  form.btn_ok.Enabled = false
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local name = form.target_name
  if nx_widestr(form.target_name) == nx_widestr("") then
    return
  end
  local rq_type = form.request_type
  if form.rbtn_jingmai.Checked then
    if nx_int(rq_type) == nx_int(REQUEST_BAISHI) then
      nx_execute("custom_sender", "custom_teacher_pupil", 9, nx_widestr(name), ShiTuType_JingMai)
    else
      nx_execute("custom_sender", "custom_teacher_pupil", 6, nx_widestr(name), ShiTuType_JingMai)
    end
  else
    local teacher_level = form.level
    if nx_int(rq_type) == nx_int(REQUEST_BAISHI) then
      nx_execute("custom_sender", "custom_teacher_pupil", 9, nx_widestr(name), ShiTuType_NeiGong, teacher_level)
    else
      nx_execute("custom_sender", "custom_teacher_pupil", 6, nx_widestr(name), ShiTuType_NeiGong, teacher_level)
    end
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
function on_combobox_ng_selected(combox)
  local form = combox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  for i = 2, form.max_neigonglevel do
    if nx_int(form.request_type) == nx_int(REQUEST_BAISHI) then
      if nx_widestr(util_text("ui_shixiong_" .. i)) == nx_widestr(combox.Text) then
        form.level = i
      end
    elseif nx_widestr(util_text("ui_shidi_" .. i)) == nx_widestr(combox.Text) then
      form.level = i
    end
  end
end
function on_rbtn_jingmai_click(btn)
  btn.ParentForm.btn_ok.Enabled = true
end
function on_rbtn_neigong_click(btn)
  btn.ParentForm.btn_ok.Enabled = true
end
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
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_teacher_pupil\\form_teacherpupil_request", true, false)
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
function get_neigong_level()
  local ini = nx_execute("util_functions", "get_ini", "share\\rule\\shitu\\teacherpupil.ini")
  if not nx_is_valid(ini) then
    return 0
  end
  local index = ini:FindSectionIndex(nx_string("BaseConfig"))
  if index < 0 then
    return 0
  end
  local nOpenNeiGong = ini:ReadInteger(index, "OpenNeiGong", 0)
  return nOpenNeiGong
end
function on_server_msg(submsg, ...)
  if nx_int(submsg) == nx_int(1) then
  elseif nx_int(submsg) == nx_int(2) then
    util_show_form("form_stage_main\\form_teacher_pupil\\form_teacherpupil_register_info", true)
  elseif nx_int(submsg) == nx_int(3) then
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    local shitu_type = nx_int(arg[1])
    if nx_int(1) == nx_int(shitu_type) then
      local name = nx_widestr(arg[2])
      local neigonglevel = nx_int(arg[3])
      local npersent = nx_int(arg[4])
      gui.TextManager:Format_SetIDName("ui_shitu_shoutu")
      gui.TextManager:Format_AddParam(nx_widestr(name))
      gui.TextManager:Format_AddParam(nx_int(neigonglevel))
      gui.TextManager:Format_AddParam(nx_int(npersent))
      local info = gui.TextManager:Format_GetText()
      local res = show_tip_dialog(info)
      if res ~= "ok" then
        return
      end
      local teacher_level = nx_int(arg[4])
      nx_execute("custom_sender", "custom_request", 54, nx_widestr(name), 1, teacher_level)
    else
      local name = nx_widestr(arg[2])
      local xuewei_count = nx_int(arg[3])
      local inc_times = nx_int(arg[4])
      gui.TextManager:Format_SetIDName("ui_shitu_shoutu_1")
      gui.TextManager:Format_AddParam(nx_widestr(name))
      gui.TextManager:Format_AddParam(nx_int(xuewei_count))
      gui.TextManager:Format_AddParam(nx_int(inc_times))
      local info = gui.TextManager:Format_GetText()
      local res = show_tip_dialog(info)
      if res ~= "ok" then
        return
      end
      nx_execute("custom_sender", "custom_request", 54, nx_widestr(name), 2)
    end
  elseif nx_int(submsg) == nx_int(4) then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    if not nx_is_valid(dialog) then
      return
    end
    dialog:ShowModal()
    dialog.mltbox_info:Clear()
    local text = nx_widestr(util_text("ui_shitu_jingmai_buf_01"))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_teacher_pupil", 7)
    end
  elseif nx_int(submsg) == nx_int(5) then
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    local shitu_type = nx_int(arg[1])
    local name = nx_widestr(arg[2])
    local count = nx_int(arg[3])
    gui.TextManager:Format_SetIDName("ui_shitu_baishi_1")
    gui.TextManager:Format_AddParam(nx_widestr(name))
    gui.TextManager:Format_AddParam(nx_int(count))
    local info = gui.TextManager:Format_GetText()
    local res = show_tip_dialog(info)
    if res ~= "ok" then
      return
    end
    if nx_int(ShiTuType_JingMai) == nx_int(shitu_type) then
      nx_execute("custom_sender", "custom_request", 53, nx_widestr(name), ShiTuType_JingMai)
    else
      local teacher_level = nx_int(arg[4])
      nx_execute("custom_sender", "custom_request", 53, nx_widestr(name), ShiTuType_NeiGong, teacher_level)
    end
  elseif nx_int(submsg) == nx_int(TP_STC_CHISHI) then
    local res = show_tip_dialog(util_text("ui_shitu_chushi_vip"))
    if res ~= "ok" then
      return
    end
    nx_execute("custom_sender", "custom_teacher_pupil", TP_CTS_CHISHI)
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
