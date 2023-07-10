local form_name = "form_stage_main\\form_home\\form_home_help_tygn"
function main_form_init(form)
  form.Fixed = false
  form.page_index = 1
  return 1
end
function open_form()
  local form = nx_execute("util_gui", "util_get_form", form_name, true)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.page_index = 1
  form.btn_ok.Visible = false
  form.btn_front.Visible = false
  form.groupbox_1.Visible = true
  form.groupbox_2.Visible = false
  form.groupbox_3.Visible = false
  form.groupbox_4.Visible = false
  form.groupbox_5.Visible = false
  form.groupbox_6.Visible = false
  form.groupbox_7.Visible = false
  form.groupbox_8.Visible = false
  form.groupbox_9.Visible = false
  form.groupbox_10.Visible = false
  form.btn_next.Visible = true
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  timer:Register(6000, 1, nx_current(), "auto_show_form", form, -1, -1)
  return
end
function on_main_form_close(form)
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  timer:UnRegister(nx_current(), "auto_show_form", form)
  nx_destroy(form)
  return
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  return
end
function on_btn_front_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.page_index < 2 or form.page_index > 10 then
    return
  end
  local page = {
    form.groupbox_1,
    form.groupbox_2,
    form.groupbox_3,
    form.groupbox_4,
    form.groupbox_5,
    form.groupbox_6,
    form.groupbox_7,
    form.groupbox_8,
    form.groupbox_9,
    form.groupbox_10
  }
  page[form.page_index].Visible = false
  page[form.page_index - 1].Visible = true
  if form.page_index == 2 then
    form.btn_front.Visible = false
  end
  form.btn_next.Visible = true
  form.btn_ok.Visible = false
  form.page_index = form.page_index - 1
  return
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.page_index < 1 or form.page_index > 9 then
    return
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  local page = {
    form.groupbox_1,
    form.groupbox_2,
    form.groupbox_3,
    form.groupbox_4,
    form.groupbox_5,
    form.groupbox_6,
    form.groupbox_7,
    form.groupbox_8,
    form.groupbox_9,
    form.groupbox_10
  }
  page[form.page_index].Visible = false
  page[form.page_index + 1].Visible = true
  if form.page_index == 9 then
    form.btn_next.Visible = false
    form.btn_ok.Visible = true
  end
  if form.page_index == 1 then
    form.btn_next.Visible = true
  end
  form.btn_front.Visible = true
  form.page_index = form.page_index + 1
  return
end
function auto_show_form(form)
  form.Visible = true
end
