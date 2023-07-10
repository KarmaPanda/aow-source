require("util_functions")
require("share\\client_custom_define")
require("const_define")
require("util_gui")
require("control_set")
local CLIENT_CUSTOMMSG_ALLOW_QS_HELPER = 0
local CLIENT_CUSTOMMSG_REFUSE_QS_HELPER = 1
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
function show_info(player_name, help_info, time_count)
  local form = nx_value("form_stage_main\\form_force_school\\form_qs_helper")
  if nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form = util_get_form("form_stage_main\\form_force_school\\form_qs_helper", true, false)
  form.count_tick = time_count
  form.boss_id = player_name
  form.boss_info = help_info
  form.lbl_time.Text = nx_widestr(time_count)
  form:Show()
  form.Visible = true
  form.mltbox_sender:AddHtmlText(nx_widestr(player_name), -1)
  form.mltbox_help_info:AddHtmlText(gui.TextManager:GetFormatText(help_info), -1)
  local res, npc_scene = nx_wait_event(100000000, form, "boss_help_request")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if res == "ok" then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_QS_HELPER), nx_int(CLIENT_CUSTOMMSG_ALLOW_QS_HELPER))
  elseif res == "cancel" then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_QS_HELPER), nx_int(CLIENT_CUSTOMMSG_REFUSE_QS_HELPER))
  end
end
function show_boss_help_info(player_name, help_info)
  show_info(player_name, help_info, 10)
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
