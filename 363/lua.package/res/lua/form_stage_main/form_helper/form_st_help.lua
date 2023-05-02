function main_form_init(form)
  form.Fixed = false
  form.page_index = 1
  return 1
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
  form.btn_next.Left = 223
  form.btn_next.Top = 498
  return
end
function on_main_form_close(form)
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
  if form.page_index < 2 or form.page_index > 4 then
    return
  end
  local page = {
    form.groupbox_1,
    form.groupbox_2,
    form.groupbox_3,
    form.groupbox_4
  }
  page[form.page_index].Visible = false
  page[form.page_index - 1].Visible = true
  if form.page_index == 2 then
    form.btn_front.Visible = false
    form.btn_next.Left = 223
    form.btn_next.Top = 498
  end
  form.btn_ok.Visible = false
  form.btn_next.Visible = true
  form.page_index = form.page_index - 1
  return
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.page_index < 1 or form.page_index >= 4 then
    return
  end
  local page = {
    form.groupbox_1,
    form.groupbox_2,
    form.groupbox_3,
    form.groupbox_4
  }
  page[form.page_index].Visible = false
  page[form.page_index + 1].Visible = true
  if form.page_index == 3 then
    form.btn_next.Visible = false
    form.btn_ok.Visible = true
  end
  if form.page_index == 1 then
    form.btn_next.Left = 342
    form.btn_next.Top = 498
  end
  form.btn_front.Visible = true
  form.page_index = form.page_index + 1
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  return
end
