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
  if form.page_index ~= 2 then
    return
  end
  local page = {
    form.groupbox_1,
    form.groupbox_2
  }
  page[form.page_index].Visible = false
  page[form.page_index - 1].Visible = true
  form.btn_front.Visible = false
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
  if form.page_index ~= 1 then
    return
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_main\\form_main_player", "show_pk_help_arrow")
  end
  local page = {
    form.groupbox_1,
    form.groupbox_2
  }
  page[form.page_index].Visible = false
  page[form.page_index + 1].Visible = true
  form.btn_next.Visible = false
  form.btn_front.Visible = true
  form.btn_ok.Visible = true
  form.page_index = form.page_index + 1
  return
end
