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
  if nx_running(nx_current(), "form_count_tick") then
    nx_kill(nx_current(), "form_count_tick")
  end
  nx_execute(nx_current(), "form_count_tick", form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.AbsLeft = (gui.Desktop.Width - form.Width) / 2
  form.AbsTop = (gui.Desktop.Height - form.Height) / 2
end
function on_main_form_close(form)
  if nx_running(nx_current(), "form_count_tick") then
    nx_kill(nx_current(), "form_count_tick")
  end
  nx_gen_event(form, "avatar_clone_confirm", "cancel")
  nx_destroy(form)
end
function on_btn_ok_click(btn)
  local form = btn.Parent
  nx_gen_event(form, "avatar_clone_confirm", "ok")
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.Parent
  nx_gen_event(form, "avatar_clone_confirm", "cancel")
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.Parent
  nx_gen_event(form, "avatar_clone_confirm", "cancel")
  form:Close()
end
function show_confirm_info(form)
  if not nx_is_valid(form) then
    return
  end
  form.count_tick = form.count_tick - 1
  form.lbl_time.Text = nx_widestr(form.count_tick)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form:Show()
  form.Visible = true
  form.mltbox_help_info:AddHtmlText(gui.TextManager:GetFormatText("ui_xmqy_invite_06"), -1)
  local res = nx_wait_event(100000000, form, "avatar_clone_confirm")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if res == "ok" then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUEST_CREATE_AVATAR_CLONE))
  elseif res == "cancel" then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GIVEUP_CREATE_AVATAR_CLONE))
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
      nx_gen_event(form, "avatar_clone_confirm", "cancel")
      form:Close()
      return
    end
    form.count_tick = time
    form.lbl_time.Text = nx_widestr(time)
  end
end
