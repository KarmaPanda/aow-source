require("util_functions")
require("share\\client_custom_define")
require("const_define")
require("util_gui")
require("control_set")
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
  form.count_tick = 30
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
  nx_gen_event(form, "jianghu_help_request", "ok")
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.Parent
  nx_gen_event(form, "jianghu_help_request", "cancel")
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.Parent
  nx_gen_event(form, "jianghu_help_request", "cancel")
  form:Close()
end
function show_info(player_name, group_id)
  local form = nx_value("form_stage_main\\form_jianghu_help")
  if nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form = util_get_form("form_stage_main\\form_jianghu_help", true, false)
  form.player_name = player_name
  form.group_id = group_id
  form:Show()
  form.Visible = true
  local desc_info = gui.TextManager:GetFormatText("ui_advhelp_detail", nx_widestr(player_name))
  form.mltbox_help_info:AddHtmlText(nx_widestr(desc_info), -1)
  local res, npc_scene = nx_wait_event(100000000, form, "jianghu_help_request")
  if res == "ok" then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACCEPT_ADVE_SUMMON), player_name, group_id)
  elseif res == "cancel" then
  end
end
function show_jianghu_help_info(player_name, group_id)
  local game_config_info = nx_value("game_config_info")
  local indirect = util_get_property_key(game_config_info, "jianghu_help_indirect", 1)
  if nx_int(indirect) == nx_int(0) then
    show_info(player_name, group_id)
  else
    local btn_form = util_get_form("form_stage_main\\form_jianghu_help_button", true, false)
    btn_form:Show()
    btn_form.Visible = true
    local res = nx_wait_event(100000000, btn_form, "show_info")
    if res == "ok" then
      show_info(player_name, group_id)
    elseif res == "cancel" then
    end
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
      nx_gen_event(form, "jianghu_help_request", "cancel")
      form:Close()
      return
    end
    form.count_tick = time
    form.lbl_time.Text = nx_widestr(time)
  end
end
function init_cbtn_indirect(form)
  local cbtn = form.cbtn_indirect
  local game_config_info = nx_value("game_config_info")
  local indirect = util_get_property_key(game_config_info, "jianghu_help_indirect", 1)
  if nx_int(indirect) == nx_int(0) then
    cbtn.Checked = false
  elseif nx_int(indirect) == nx_int(1) then
    cbtn.Checked = true
  end
end
function on_cbtn_indirect_checked_changed(cbtn)
  local game_config_info = nx_value("game_config_info")
  util_set_property_key(game_config_info, "jianghu_help_indirect", nx_int(cbtn.Checked and "1" or "0"))
  if nx_is_valid(game_config_info) then
    nx_execute("game_config", "save_game_config_item", "systeminfo.ini", "Config", "jianghu_help_indirect", nx_int(game_config_info.jianghu_help_indirect))
  end
end
