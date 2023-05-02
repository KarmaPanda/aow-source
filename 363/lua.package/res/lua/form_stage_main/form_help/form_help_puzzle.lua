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
  form.btn_front.Enabled = false
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
  if form.page_index < 2 or form.page_index > form.count then
    return
  end
  local groupbox_old = form:Find("groupbox_" .. nx_string(form.page_index))
  if nx_is_valid(groupbox_old) then
    groupbox_old.Visible = false
  end
  local groupbox_new = form:Find("groupbox_" .. nx_string(form.page_index - 1))
  if nx_is_valid(groupbox_new) then
    groupbox_new.Visible = true
  end
  if form.page_index == 2 then
    form.btn_front.Enabled = false
  end
  if form.page_index == form.count then
    form.btn_next.Enabled = true
  end
  form.page_index = form.page_index - 1
  return
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.page_index < 1 or form.page_index > form.count then
    return
  end
  local groupbox_old = form:Find("groupbox_" .. nx_string(form.page_index))
  if nx_is_valid(groupbox_old) then
    groupbox_old.Visible = false
  end
  local groupbox_new = form:Find("groupbox_" .. nx_string(form.page_index + 1))
  if nx_is_valid(groupbox_new) then
    groupbox_new.Visible = true
  end
  if form.page_index == form.count - 1 then
    form.btn_next.Enabled = false
  end
  if form.page_index == 1 then
    form.btn_front.Enabled = true
  end
  form.page_index = form.page_index + 1
  return
end
