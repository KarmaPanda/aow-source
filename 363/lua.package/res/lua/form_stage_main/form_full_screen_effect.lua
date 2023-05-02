require("util_gui")
function start()
  local form = nx_value("form_stage_main\\form_full_screen_effect")
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "in_time") then
    if form.in_time > 0 then
      nx_execute("util_gui", "util_form_alpha_in", "form_stage_main\\form_full_screen_effect", form.in_time / 1000)
    else
      form = util_get_form("form_stage_main\\form_full_screen_effect", false, false)
      form.BlendAlpha = 255
      form.Visible = true
      form:Show()
    end
  end
end
function on_main_form_init(form)
end
function on_main_form_open(form)
  if not nx_find_custom(form, "in_time") or not nx_find_custom(form, "show_time") then
    return
  end
  local gui = nx_value("gui")
  form.Top = 0
  form.Left = 0
  form.Width = gui.Desktop.Width
  form.Height = gui.Desktop.Height
  form.lbl_1.Top = 0
  form.lbl_1.Left = 0
  form.lbl_1.Width = gui.Desktop.Width
  form.lbl_1.Height = gui.Desktop.Height
  form.lbl_1.BackImage = form.back_image
  if form.show_time > 0 then
    local timer = nx_value(GAME_TIMER)
    if nx_is_valid(timer) then
      timer:Register(form.in_time + form.show_time, 1, nx_current(), "timer_callback", form, -1, -1)
    end
  end
end
function timer_callback(form, param1, param2)
  if nx_find_custom(form, "out_time") then
    if form.out_time > 0 then
      nx_execute("util_gui", "util_form_alpha_out", "form_stage_main\\form_full_screen_effect", form.out_time / 1000)
    else
      form:Close()
    end
  end
end
function on_main_form_close(form)
  nx_destroy(form)
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_full_screen_effect")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Top = 0
  form.Left = 0
  form.Width = gui.Desktop.Width
  form.Height = gui.Desktop.Height
  form.lbl_1.Top = 0
  form.lbl_1.Left = 0
  form.lbl_1.Width = gui.Desktop.Width
  form.lbl_1.Height = gui.Desktop.Height
end
function finish(form)
  if nx_is_valid(form) then
    timer_callback(form, -1, -1)
  end
end
