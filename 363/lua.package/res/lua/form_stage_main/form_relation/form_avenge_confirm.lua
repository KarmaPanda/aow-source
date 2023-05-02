require("share\\client_custom_define")
require("util_gui")
local AVENGE_PAYOFF = 1
local AVENGE_GOTO = 2
function main_form_init(form)
  form.form_type = 0
  form.count_tick = 30
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
  if nx_find_custom(form, "form_type") and form.form_type == AVENGE_PAYOFF and not second_word_unlock() then
    return
  end
  nx_gen_event(form, "avenge_payoff", "ok")
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.Parent
  nx_gen_event(form, "avenge_payoff", "cancel")
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.Parent
  nx_gen_event(form, "avenge_payoff", "cancel")
  form:Close()
end
function show_avenge_payoff_confirm(...)
  if table.getn(arg) < 5 then
    return
  end
  local sub_msg = arg[1]
  local info = arg[2]
  local scene = arg[3]
  local npc_id = arg[4]
  local money = arg[5]
  local form = util_get_form("form_stage_main\\form_relation\\form_avenge_confirm", true, false)
  form.form_type = AVENGE_PAYOFF
  form.count_tick = 20
  form.lbl_time.Text = nx_widestr(form.count_tick)
  local gui = nx_value("gui")
  form.mltbox_sender:Clear()
  form.mltbox_help_info:Clear()
  form.mltbox_sender:AddHtmlText(gui.TextManager:GetFormatText(nx_string(npc_id)), -1)
  form.mltbox_help_info:AddHtmlText(gui.TextManager:GetFormatText(nx_string(info), nx_string(scene), nx_string(npc_id), nx_int(money)), -1)
  form.Visible = true
  form:Show()
  local res = nx_wait_event(100000000, form, "avenge_payoff")
  if res == "ok" then
    nx_execute("custom_sender", "custom_avenge", nx_int(3))
  elseif res == "cancel" then
    nx_execute("custom_sender", "custom_avenge", nx_int(4))
  end
end
function show_avenge_goto_confirm(...)
  if table.getn(arg) < 5 then
    return
  end
  local sub_msg = arg[1]
  local is_sender = arg[2]
  local npc_id = arg[3]
  local target_name = arg[4]
  local tvt_type = arg[5]
  local form = util_get_form("form_stage_main\\form_relation\\form_avenge_confirm", true, false)
  form.form_type = AVENGE_GOTO
  form.count_tick = 20
  form.lbl_time.Text = nx_widestr(form.count_tick)
  local gui = nx_value("gui")
  form.mltbox_sender:Clear()
  form.mltbox_help_info:Clear()
  form.mltbox_sender:AddHtmlText(gui.TextManager:GetFormatText(nx_string(npc_id)), -1)
  local info
  if nx_number(is_sender) == nx_number(1) then
    info = gui.TextManager:GetFormatText(nx_string("ui_mafan_gotoview"), nx_string(npc_id), nx_widestr(target_name), "ui_tvttype_" .. nx_string(tvt_type))
  else
    info = gui.TextManager:GetFormatText(nx_string("ui_mafan_gotoview1"), nx_widestr(target_name), nx_string(npc_id))
  end
  form.mltbox_help_info:AddHtmlText(nx_widestr(info), -1)
  form.Visible = true
  form:Show()
  local res = nx_wait_event(100000000, form, "avenge_payoff")
  if res == "ok" then
    nx_execute("custom_sender", "custom_avenge", nx_int(5))
  end
end
function show_avenge_switch(...)
  if table.getn(arg) < 2 then
    return
  end
  local sub_msg = arg[1]
  local temp = arg[2]
  if nx_number(0) == nx_number(temp) then
    nx_execute("gui", "gui_close_allsystem_form")
    local form_main = nx_value("form_stage_main\\form_main\\form_main")
    if nx_is_valid(form_main) then
      form_main.groupbox_4.Visible = false
      form_main.groupbox_5.Visible = false
    end
    show_or_hide_self_model(false)
    local form_watch = util_get_form("form_stage_main\\form_relation\\form_avenge_watch", true, false)
    if nx_is_valid(form_watch) then
      form_watch:Show()
    end
  else
    nx_execute("gui", "gui_open_closedsystem_form")
    local form_main = nx_value("form_stage_main\\form_main\\form_main")
    if nx_is_valid(form_main) then
      form_main.groupbox_4.Visible = true
      form_main.groupbox_5.Visible = true
    end
    show_or_hide_self_model(true)
    local form_watch = nx_value("form_stage_main\\form_relation\\form_avenge_watch")
    if nx_is_valid(form_watch) then
      form_watch:Close()
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
      nx_gen_event(form, "avenge_payoff", "cancel")
      form:Close()
      return
    end
    form.count_tick = time
    form.lbl_time.Text = nx_widestr(time)
  end
end
function show_or_hide_self_model(isshow)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  local camera_normal = game_control:GetCameraController(0)
  if not nx_is_valid(camera_normal) then
    return
  end
  camera_normal.ShortDisMode = not isshow
  visual_player.Visible = isshow
  local head_game = nx_value("HeadGame")
  if not nx_is_valid(head_game) then
    return
  end
  head_game:ShowHead(visual_player, isshow)
end
function second_word_unlock()
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return false
  end
  local b_ok = condition_manager:CanSatisfyCondition(player, player, 23600)
  if not b_ok then
    return true
  end
  local is_have_second_word = nx_number(player:QueryProp("IsHaveSecondWord"))
  if is_have_second_word == nx_number(0) then
    nx_execute("custom_sender", "request_set_second_word")
    return false
  end
  local is_have_lock = nx_number(player:QueryProp("IsCheckPass"))
  if is_have_lock == 0 then
    nx_execute("form_stage_main\\from_word_protect\\form_protect_sure", "show_form_protect_sure")
    return false
  end
  return true
end
