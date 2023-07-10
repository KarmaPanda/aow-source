require("util_functions")
function main_form_init(form)
  form.Fixed = false
  form.show = true
  form.UpdateFlag = true
  form.HideFlag = false
  return 1
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  local file_name = "share\\Activity\\day_signature.ini"
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(file_name)
  local sec_index = ini:FindSectionIndex(nx_string("time_hot_stage"))
  if sec_index < 0 then
    sec_index = "0"
  else
  end
  form.onlinetime = ini:ReadInteger(sec_index, "OnLineTime", 3600) / 60
  databinder:AddRolePropertyBind("HotOnLineTime", "int", form, nx_current(), "on_update_show_online_time")
  local bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_new")
  if bMovie then
    if not nx_is_valid(form) then
      return
    end
    nx_execute("form_stage_main\\form_movie_new", "add_hide_control", form.groupbox_girl)
    nx_execute("form_stage_main\\form_movie_new", "add_hide_control", form.btn_show)
  end
  return 1
end
function on_update_show_online_time(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local HotOnLineTime = client_player:QueryProp("HotOnLineTime")
  local remaintime = nx_int(form.onlinetime - HotOnLineTime)
  if remaintime <= nx_int(0) then
    nx_destroy(form)
    return
  end
  gui.TextManager:Format_SetIDName("context_time_hot_stage_4")
  gui.TextManager:Format_AddParam(nx_int(remaintime))
  form.lbl_2.Text = nx_widestr(gui.TextManager:Format_GetText())
end
function on_main_form_close(form)
  form.UpdateFlag = true
  form.HideFlag = false
  form.Visible = false
  nx_destroy(form)
end
function on_btn_hide_click(btn)
  local form = btn.ParentForm
  if form.show then
    form.groupbox_girl.Visible = false
    form.btn_show.Visible = true
    form.show = false
  else
    form.groupbox_girl.Visible = true
    form.btn_show.Visible = false
    form.show = true
  end
  if form.HideFlag then
    form.Height = 134
  else
    form.BlendColor = "255,255,255,255"
    change_time_form(form)
  end
end
function change_time_form(form)
  local gui = nx_value("gui")
  form.Height = nx_number(40)
  if form.UpdateFlag then
    form.Width = nx_number(60)
    form.UpdateFlag = false
  else
    form.UpdateFlag = true
    form.Height = nx_number(134)
    form.Width = nx_number(250)
  end
end
