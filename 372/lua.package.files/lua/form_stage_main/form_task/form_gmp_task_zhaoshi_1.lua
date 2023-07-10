require("util_functions")
require("util_gui")
require("share\\client_custom_define")
function tc(msg)
  nx_msgbox(nx_string(msg))
end
function main_form_init(form)
  form.Fixed = false
  form.lefttime = 0
  return 1
end
function on_main_form_open(form)
end
function open_form(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  end
  if not nx_is_valid(form) then
    return
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("DoubleXiuLianSelfPoint", "int", form, nx_current(), "on_qicao_point_change")
    databinder:AddRolePropertyBind("DoubleXiuLianMemberPoint", "int", form, nx_current(), "on_qicao_point_change")
  end
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_time", form)
  timer:Register(1000, -1, nx_current(), "on_update_time", form, -1, -1)
  form.Visible = true
  form:Show()
  form.pbar_1.Value = 0
  form.pbar_2.Value = 0
  form.pbar_1.Maximum = arg[1]
  form.pbar_2.Maximum = arg[1]
  form.lefttime = arg[2] * 60
  form.lbl_lefttime.Text = nx_widestr(form.lefttime)
end
function on_main_form_close(form)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_time", form)
  nx_destroy(form)
end
function on_btn_1_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local text = nx_widestr(gui.TextManager:GetText(nx_string("gmp_srtx_wg_007")))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_time", form)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_DOUBLE_XIULIAN))
  end
  form:Close()
end
function close_form()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_time", form)
  form:Close()
end
function on_update_time(form)
  if not nx_is_valid(form) then
    return
  end
  form.lefttime = form.lefttime - 1
  form.lbl_lefttime.Text = nx_widestr(form.lefttime)
  if form.lefttime <= 0 then
    local timer = nx_value("timer_game")
    timer:UnRegister(nx_current(), "on_update_time", form)
    form.lbl_lefttime.Text = nx_widestr(0)
  end
end
function on_qicao_point_change(bind_id, prop_name, prop_type, value)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_task\\form_gmp_task_zhaoshi_1", true, false)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(bind_id) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not client_player:FindProp(prop_name) then
    return
  end
  local self_point = client_player:QueryProp("DoubleXiuLianSelfPoint")
  local member_point = client_player:QueryProp("DoubleXiuLianMemberPoint")
  form.pbar_1.Value = self_point
  form.pbar_2.Value = member_point
end
