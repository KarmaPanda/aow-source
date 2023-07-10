require("util_functions")
require("share\\client_custom_define")
require("const_define")
require("util_gui")
require("control_set")
function custom_handle(...)
  local arg_num = nx_number(table.getn(arg))
  if arg_num < 1 then
    return
  end
  local sub_id = nx_number(arg[1])
  if sub_id == 0 then
    if arg_num < 3 then
      return
    end
    local is_showing = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_cpf_helper")
    if is_showing then
      return
    end
    is_showing = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_cpf_helper_btn")
    if is_showing then
      return
    end
    local notice_info = nx_string(arg[2])
    local dst_scene_id = nx_int(arg[3])
    show_notice_form(notice_info, dst_scene_id)
  end
end
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  if nx_running(nx_current(), "form_count_tick") then
    nx_kill(nx_current(), "form_count_tick")
  end
  nx_execute(nx_current(), "form_count_tick", form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.AbsLeft = (gui.Desktop.Width - form.Width) * 9 / 10
  form.AbsTop = (gui.Desktop.Height - form.Height) * 3 / 10
  init_cbtn_indirect(form)
end
function on_main_form_close(form)
  if nx_running(nx_current(), "form_count_tick") then
    nx_kill(nx_current(), "form_count_tick")
  end
  nx_destroy(form)
end
function on_btn_ok_click(btn)
  local form = btn.Parent
  nx_gen_event(form, "cpf_help_request", "ok")
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.Parent
  nx_gen_event(form, "cpf_help_request", "cancel")
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.Parent
  nx_gen_event(form, "cpf_help_request", "cancel")
  form:Close()
end
function show_notice_form(notice_info, dst_scene_id)
  local indirect = GetIniInfo("boss_help_indirect")
  if nx_int(indirect) == nx_int(0) then
    show_info(notice_info, 10, dst_scene_id)
  elseif nx_int(indirect) == nx_int(1) then
    local btn_form = util_get_form("form_stage_main\\form_cpf_helper_btn", true, false)
    btn_form:Show()
    btn_form.Visible = true
    local res, time_count = nx_wait_event(100000000, btn_form, "show_info")
    if res == "ok" then
      show_info(notice_info, time_count, dst_scene_id)
    elseif res == "cancel" then
    end
  else
    SetIniInfo("boss_help_indirect", 0)
  end
end
function show_info(notice_info, time_count, dst_scene_id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local form = util_get_form("form_stage_main\\form_cpf_helper", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.count_tick = time_count
  form.lbl_time.Text = nx_widestr(time_count)
  form:Show()
  form.Visible = true
  form.mltbox_help_info:AddHtmlText(gui.TextManager:GetFormatText(notice_info), -1)
  local res = nx_wait_event(100000000, form, "cpf_help_request")
  if res == "ok" then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CPF_HELPER), 0, 1, dst_scene_id)
  elseif res == "cancel" then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CPF_HELPER), 0, 0, 0)
  end
end
function form_count_tick(form)
  while nx_is_valid(form) do
    nx_pause(1)
    if not nx_is_valid(form) then
      return
    end
    if not nx_find_custom(form, "count_tick") then
      return
    end
    local time = nx_number(form.count_tick)
    time = time - 1
    if nx_number(time) < nx_number(0) then
      nx_gen_event(form, "cpf_help_request", "cancel")
      form:Close()
      return
    end
    form.count_tick = time
    form.lbl_time.Text = nx_widestr(time)
  end
end
function init_cbtn_indirect(form)
  local cbtn = form.cbtn_indirect
  local check = GetIniInfo("boss_help_indirect", "0")
  if nx_int(check) == nx_int(0) then
    cbtn.Checked = false
  elseif nx_int(check) == nx_int(1) then
    cbtn.Checked = true
  end
end
function on_cbtn_indirect_checked_changed(cbtn)
  local check = GetIniInfo("boss_help_indirect")
  local bcheck = false
  if nx_int(check) == nx_int(1) then
    bcheck = true
  end
  if bcheck == cbtn.Checked then
    return
  end
  if cbtn.Checked == true then
    SetIniInfo("boss_help_indirect", 1)
  else
    SetIniInfo("boss_help_indirect", 0)
  end
  local game_config_info = nx_value("game_config_info")
  if nx_is_valid(game_config_info) then
    nx_execute("game_config", "save_game_config_item", "systeminfo.ini", "Config", "boss_help_indirect", game_config_info.boss_help_indirect)
  end
end
