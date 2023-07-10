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
  form.AbsLeft = (gui.Desktop.Width - form.Width) * 21 / 20
  form.AbsTop = (gui.Desktop.Height - form.Height) / 10
end
function on_main_form_close(form)
  if nx_running(nx_current(), "form_count_tick") then
    nx_kill(nx_current(), "form_count_tick")
  end
  nx_gen_event(form, "avatar_notice", "cancel")
  nx_destroy(form)
end
function show_avatar_notice_form(form)
  if not nx_is_valid(form) then
    return
  end
  form.count_tick = 60
  form.lbl_time.Text = nx_widestr("60")
  form:Show()
  form.Visible = true
end
function on_btn_btn_scaldfish_click(btn)
  local form = btn.Parent
  local confirm_form = nx_value("form_stage_main\\form_avatar_clone\\form_avatar_clone_confirm")
  if not nx_is_valid(confirm_form) then
    confirm_form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_avatar_clone\\form_avatar_clone_confirm", true, false)
    nx_set_value("form_stage_main\\form_avatar_clone\\form_avatar_clone_confirm", confirm_form)
  end
  confirm_form.count_tick = form.count_tick
  nx_execute("form_stage_main\\form_avatar_clone\\form_avatar_clone_confirm", "show_confirm_info", confirm_form)
  form:Close()
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
      nx_gen_event(form, "avatar_notice", "cancel")
      form:Close()
      return
    end
    form.count_tick = time
    form.lbl_time.Text = nx_widestr(time)
  end
end
