require("util_functions")
require("share\\client_custom_define")
require("const_define")
require("util_gui")
require("control_set")
CH_SUB_MSG_CALL_RESPOND = 1
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
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
  nx_gen_event(form, "boss_help_request", "ok")
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.Parent
  nx_gen_event(form, "boss_help_request", "cancel")
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.Parent
  nx_gen_event(form, "boss_help_request", "cancel")
  form:Close()
end
function show_info(boss_config_id, boss_help_info, time_count)
  local form = nx_value("form_stage_main\\form_boss_help")
  if nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form = util_get_form("form_stage_main\\form_boss_help", true, false)
  form.count_tick = time_count
  form.boss_id = boss_config_id
  form.boss_info = boss_help_info
  form.lbl_time.Text = nx_widestr(time_count)
  form:Show()
  form.Visible = true
  form.mltbox_sender:AddHtmlText(gui.TextManager:GetFormatText(boss_config_id), -1)
  form.mltbox_help_info:AddHtmlText(gui.TextManager:GetFormatText(boss_help_info), -1)
  local res, npc_scene = nx_wait_event(100000000, form, "boss_help_request")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  if res == "ok" then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ALLOW_BOSS_CALL_HELP))
  elseif res == "cancel" then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REFUSE_BOSS_CALL_HELP))
  end
end
function show_boss_help_info(boss_config_id, boss_help_info)
  local indirect = GetIniInfo("boss_help_indirect")
  if nx_int(indirect) == nx_int(0) then
    show_info(boss_config_id, boss_help_info, 10)
  elseif nx_int(indirect) == nx_int(1) then
    local btn_form = util_get_form("form_stage_main\\form_boss_help_button", true, false)
    btn_form:Show()
    btn_form.Visible = true
    local res, time_count = nx_wait_event(100000000, btn_form, "show_info")
    if res == "ok" then
      show_info(boss_config_id, boss_help_info, time_count)
    elseif res == "cancel" then
    end
  else
    SetIniInfo("boss_help_indirect", 0)
  end
end
function show_call_info(call_id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = util_get_form("form_stage_main\\form_boss_help", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.count_tick = 30
  form.lbl_time.Text = nx_widestr(time_count)
  form:Show()
  form.Visible = true
  local info = get_callhelper_tips(call_id)
  form.mltbox_help_info:AddHtmlText(gui.TextManager:GetFormatText(info), -1)
  local res, npc_scene = nx_wait_event(100000000, form, "boss_help_request")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if res == "ok" then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CALL_HELPER), nx_int(CH_SUB_MSG_CALL_RESPOND))
  elseif res == "cancel" then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CALL_HELPER))
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
      nx_gen_event(form, "boss_help_request", "cancel")
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
function get_callhelper_tips(call_id)
  local ini = nx_execute("util_functions", "get_ini", "ini\\ui\\force\\ui_call_helper.ini")
  if nx_is_valid(ini) then
    local index = ini:FindSectionIndex(nx_string(call_id))
    if index ~= -1 then
      local info = ini:ReadString(index, "TipsInfo", "")
      return info
    end
  end
end
