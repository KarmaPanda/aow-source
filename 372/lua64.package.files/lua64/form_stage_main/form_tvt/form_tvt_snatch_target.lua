require("util_gui")
require("util_functions")
require("form_stage_main\\form_tvt\\define")
function on_main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.LimitInScreen = true
  form.target_school_1 = ""
  form.target_school_2 = ""
end
function on_main_form_open(form)
  form.count_time = nx_int(15)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:Register(1000, 16, nx_current(), "timer_count_down", form, 0, 0)
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.TextManager:Format_SetIDName("ui_duoshu_15time")
  gui.TextManager:Format_AddParam(nx_int(form.count_time))
  local info = gui.TextManager:Format_GetText()
  form.lbl_info.Text = info
end
function on_main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "timer_count_down", form)
  end
  nx_destroy(form)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  local target_scene_index = form.combobox_snatch_target.DropListBox.SelectIndex + 1
  local scene_resource = ""
  local school_name = "target_school_" .. target_scene_index
  if nx_find_custom(form, school_name) then
    scene_resource = nx_custom(form, school_name)
  end
  scene_resource = scene_resource or ""
  send_server_msg(g_msg_accept_snatch_target, scene_resource)
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_main_form_get_capture(form)
end
function show_form(...)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_tvt\\form_tvt_snatch_target", true)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.combobox_snatch_target.InputEdit.Text = gui.TextManager:GetText(arg[1])
  form.combobox_snatch_target.DropListBox:ClearString()
  form.target_school_1 = ""
  form.target_school_2 = ""
  local count = table.getn(arg)
  if 2 < count then
    count = 2
  end
  for i = 1, count do
    form.combobox_snatch_target.DropListBox:AddString(gui.TextManager:GetText(arg[i]))
    local school_name = "target_school_" .. i
    if nx_find_custom(form, school_name) then
      nx_set_custom(form, school_name, arg[i])
    end
  end
  form.combobox_snatch_target.OnlySelect = true
  form.combobox_snatch_target.DropListBox.SelectIndex = 0
  nx_execute("util_gui", "util_show_form", "form_stage_main\\form_tvt\\form_tvt_snatch_target", true)
end
function timer_count_down(form, para1, para2)
  if form.count_time <= 0 then
    local target_scene_index = form.combobox_snatch_target.DropListBox.SelectIndex + 1
    local scene_resource = ""
    local school_name = "target_school_" .. target_scene_index
    if nx_find_custom(form, school_name) then
      scene_resource = nx_custom(form, school_name)
    end
    scene_resource = scene_resource or ""
    send_server_msg(g_msg_accept_snatch_target, scene_resource)
    form:Close()
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.count_time = form.count_time - 1
  gui.TextManager:Format_SetIDName("ui_duoshu_15time")
  gui.TextManager:Format_AddParam(nx_int(form.count_time))
  local info = gui.TextManager:Format_GetText()
  form.lbl_info.Text = info
end
