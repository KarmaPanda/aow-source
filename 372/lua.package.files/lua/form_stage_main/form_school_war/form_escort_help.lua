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
  form.count_tick = 60
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
  nx_gen_event(form, "escort_help_request", "ok")
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.Parent
  nx_gen_event(form, "escort_help_request", "cancel")
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.Parent
  nx_gen_event(form, "escort_help_request", "cancel")
  form:Close()
end
function show_info(infotype, text, ...)
  local form = nx_value("form_stage_main\\form_school_war\\form_escort_help")
  if nx_is_valid(form) then
    return
  end
  form = util_get_form("form_stage_main\\form_school_war\\form_escort_help", true, false)
  if infotype == 0 then
    form.mltbox_sender.HtmlText = nx_widestr(util_text("ui_escort_escortrequest"))
  else
    form.mltbox_sender.HtmlText = nx_widestr(util_text("ui_escort_robrequest"))
  end
  form:Show()
  form.Visible = true
  form.mltbox_help_info.HtmlText = nx_widestr(text)
  local res, npc_scene = nx_wait_event(100000000, form, "escort_help_request")
  if res == "ok" then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    if nx_int(0) == nx_int(infotype) then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ESCORT_MSG), 4, nx_int(arg[1]), nx_int(arg[2]), nx_int(arg[3]), nx_int(arg[4]), nx_int(arg[5]))
    elseif nx_int(1) == nx_int(infotype) then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ESCORT_MSG), 5, nx_int(arg[1]), nx_int(arg[2]), nx_string(arg[3]))
    end
  elseif res == "cancel" then
  end
end
function show_escort_help_info(...)
  local indirect = nx_execute("game_config", "load_game_config_item", "systeminfo.ini", "Config", "escort_help_indirect")
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local GoldEscortType = nx_int(arg[8])
  if nx_int(GoldEscortType) == nx_int(2) then
    gui.TextManager:Format_SetIDName("ui_escort_shengzhu_help")
  else
    gui.TextManager:Format_SetIDName("ui_escort_help")
  end
  gui.TextManager:Format_AddParam(nx_string(arg[2]))
  local text = nx_widestr(gui.TextManager:Format_GetText())
  if nx_int(indirect) == nx_int(0) then
    show_info(0, text, nx_int(arg[3]), nx_int(arg[4]), nx_int(arg[5]), nx_int(arg[6]), nx_int(arg[7]))
  elseif nx_int(indirect) == nx_int(1) then
    local btn_form = util_get_form("form_stage_main\\form_school_war\\form_escort_help_button", true, false)
    btn_form:Show()
    btn_form.Visible = true
    local res = nx_wait_event(100000000, btn_form, "show_info")
    if res == "ok" then
      show_info(0, text, nx_int(arg[3]), nx_int(arg[4]), nx_int(arg[5]), nx_int(arg[6]), nx_int(arg[7]))
    elseif res == "cancel" then
    end
  end
end
function show_rob_info(...)
  local indirect = nx_execute("game_config", "load_game_config_item", "systeminfo.ini", "Config", "escort_help_indirect")
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local GoldEscortType = nx_int(arg[6])
  if nx_int(GoldEscortType) == nx_int(2) then
    gui.TextManager:Format_SetIDName("ui_escort_shengzhu_anshaojijie")
  else
    gui.TextManager:Format_SetIDName("ui_escort_anshaojijie")
  end
  gui.TextManager:Format_AddParam(nx_string(arg[2]))
  gui.TextManager:Format_AddParam(nx_string(arg[3]))
  gui.TextManager:Format_AddParam(nx_string(arg[4]))
  local text = nx_widestr(gui.TextManager:Format_GetText())
  if nx_int(indirect) == nx_int(0) then
    show_info(1, text, nx_int(arg[5]), nx_int(arg[6]), nx_string(arg[7]))
  elseif nx_int(indirect) == nx_int(1) then
    local btn_form = util_get_form("form_stage_main\\form_school_war\\form_escort_help_button", true, false)
    btn_form:Show()
    btn_form.Visible = true
    local res = nx_wait_event(100000000, btn_form, "show_info")
    if res == "ok" then
      show_info(1, text, nx_int(arg[5]), nx_int(arg[6]), nx_string(arg[7]))
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
      nx_gen_event(form, "escort_help_request", "cancel")
      form:Close()
      return
    end
    form.count_tick = time
    form.lbl_time.Text = nx_widestr(time)
  end
end
function init_cbtn_indirect(form)
  local cbtn = form.cbtn_indirect
  local check = nx_execute("game_config", "load_game_config_item", "systeminfo.ini", "Config", "escort_help_indirect")
  if nx_int(check) == nx_int(0) then
    cbtn.Checked = false
  elseif nx_int(check) == nx_int(1) then
    cbtn.Checked = true
  end
end
function on_cbtn_indirect_checked_changed(cbtn)
  if cbtn.Checked == false then
    nx_execute("game_config", "save_game_config_item", "systeminfo.ini", "Config", "escort_help_indirect", 0)
  else
    nx_execute("game_config", "save_game_config_item", "systeminfo.ini", "Config", "escort_help_indirect", 1)
  end
end
