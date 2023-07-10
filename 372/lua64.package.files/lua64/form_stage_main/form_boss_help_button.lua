function main_form_init(form)
  form.Fixed = true
end
function main_form_open(form)
  form.count_tick = 10
  if nx_running(nx_current(), "form_count_tick") then
    nx_kill(nx_current(), "form_count_tick")
  end
  nx_execute(nx_current(), "form_count_tick", form)
  form.lbl_time.Visible = false
  local gui = nx_value("gui")
  form.Left = gui.Desktop.Width - form.Width
  form.Top = (gui.Desktop.Height - form.Height) * 2 / 10
  dove_pass(form, gui)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
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
function dove_pass(form, gui)
  local top_start = form.Top
  local top_end = (gui.Desktop.Height - form.Height) * 5 / 10
  local use_time = 1
  local count_tick = 10
  local common_execute = nx_value("common_execute")
  if nx_is_valid(common_execute) then
    common_execute:RemoveExecute("DoveMove", form)
    common_execute:AddExecute("DoveMove", form, nx_float(0), nx_float(top_start), nx_float(top_end), nx_float(use_time), nx_float(count_tick))
  end
end
function on_btn_show_click(btn)
  local form = btn.ParentForm
  nx_gen_event(form, "show_info", "ok", form.count_tick)
  form:Close()
end
