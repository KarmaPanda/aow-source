local FORM_LINGXIAO = "form_stage_main\\form_lingxiao\\form_lingxiao"
function main_form_init(form)
  form.Fixed = false
  form.page_index = 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.page_index = 1
  form.btn_ok.Visible = false
  form.btn_front.Visible = false
  form.btn_next.Visible = true
  form.groupbox_1.Visible = true
  form.groupbox_2.Visible = false
  form.groupbox_3.Visible = false
  form.groupbox_4.Visible = false
  form.groupbox_5.Visible = false
end
function on_main_form_close(form)
  local form_lingxiao = nx_value(FORM_LINGXIAO)
  if nx_is_valid(form_lingxiao) then
    form_lingxiao.btn_help.Enabled = false
    form_lingxiao.btn_help.Checked = false
    form_lingxiao.btn_help.Enabled = true
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_front_click(btn)
  local form = btn.ParentForm
  hide_all_groupbox(form)
  form.page_index = form.page_index - 1
  if nx_int(form.page_index) < nx_int(1) then
    form.page_index = 1
  end
  show_groupbox(form, form.page_index)
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  hide_all_groupbox(form)
  form.page_index = form.page_index + 1
  if nx_int(form.page_index) > nx_int(5) then
    form.page_index = 5
  end
  show_groupbox(form, form.page_index)
end
function show_groupbox(form, index)
  if not nx_is_valid(form) then
    return
  end
  local name = "groupbox_" .. nx_string(index)
  if nx_find_custom(form, name) then
    local groupbox = nx_custom(form, name)
    if nx_is_valid(groupbox) then
      groupbox.Visible = true
    end
  end
  if nx_int(form.page_index) >= nx_int(2) then
    form.btn_front.Visible = true
  else
    form.btn_front.Visible = false
  end
  if nx_int(form.page_index) == nx_int(5) then
    form.btn_next.Visible = false
    form.btn_ok.Visible = true
  else
    form.btn_next.Visible = true
    form.btn_ok.Visible = false
  end
end
function hide_all_groupbox(form)
  if not nx_is_valid(form) then
    return
  end
  local page = {
    form.groupbox_1,
    form.groupbox_2,
    form.groupbox_3,
    form.groupbox_4,
    form.groupbox_5
  }
  for i = 1, table.getn(page) do
    local groupbox = page[i]
    if nx_is_valid(groupbox) then
      groupbox.Visible = false
    end
  end
end
