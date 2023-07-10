require("util_functions")
require("util_gui")
function on_main_form_init(form)
  form.Fixed = false
  form.LimitInScreen = true
  form.roomname = ""
  form.times = 120
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 4
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "affirm_down_time", form)
    timer:Register(1000, -1, nx_current(), "affirm_down_time", form, -1, -1)
  end
end
function on_main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "affirm_down_time", form)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
end
function on_btn_agree_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  btn.Enabled = false
  form.btn_cancel.Enabled = false
  nx_execute("custom_sender", "custom_revenge_match", 4, form.roomname, 1)
  form.lbl_affirm_a.Visible = true
  form.lbl_msg.Text = nx_widestr("@ui_match_revenge_affirm_2")
  if form.lbl_affirm_a.Visible and form.lbl_affirm_b.Visible then
    form:Close()
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_revenge_match", 4, form.roomname, 0)
  form:Close()
end
function fresh_fight_state(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local roomname = nx_string(arg[1])
  local playername = nx_widestr(arg[2])
  local state = nx_number(arg[3])
  local playera = form.lbl_name_a.Text
  local playerb = form.lbl_name_b.Text
  if nx_ws_equal(playername, playera) then
    nx_msgbox("error!")
  elseif nx_ws_equal(playername, playerb) then
    if state == 1 then
      form.lbl_affirm_b.Visible = false
      form:Close()
    else
      form.lbl_affirm_b.Visible = true
      form.lbl_msg.Text = nx_widestr("@ui_match_revenge_affirm_1")
    end
  else
    return
  end
  if nx_is_valid(form) and form.lbl_affirm_a.Visible and form.lbl_affirm_b.Visible then
    form:Close()
  end
end
function fresh_fight_msg(...)
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form:Close()
  end
  if not nx_is_valid(form) then
    form = util_get_form(nx_current(), true)
  end
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  form.roomname = nx_string(arg[1])
  form.lbl_name_a.Text = nx_widestr(client_player:QueryProp("Name"))
  form.lbl_integral_a.Text = nx_widestr(nx_string(arg[2]))
  form.lbl_powerlevel_a.Text = util_text(nx_call("form_stage_main\\form_match\\form_match_rank", "get_powerlevel_title_one", nx_number(client_player:QueryProp("PowerLevel"))))
  form.lbl_school_a.Text = util_text(client_player:QueryProp("School"))
  form.lbl_affirm_a.Visible = false
  form.lbl_name_b.Text = nx_widestr(arg[3])
  form.lbl_integral_b.Text = nx_widestr(nx_string(arg[8]))
  form.lbl_powerlevel_b.Text = util_text(nx_call("form_stage_main\\form_match\\form_match_rank", "get_powerlevel_title_one", nx_number(arg[7])))
  form.lbl_school_b.Text = util_text(arg[5])
  form.lbl_affirm_b.Visible = false
end
function affirm_down_time(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.btn_cancel.Text = nx_widestr(gui.TextManager:GetFormatText("ui_revenge_giveup", nx_int(form.times)))
  form.times = form.times - 1
  if form.times <= 0 then
    if form.lbl_affirm_a.Visible == false then
      on_btn_cancel_click(form.btn_cancel)
    else
      form:Close()
    end
  end
end
