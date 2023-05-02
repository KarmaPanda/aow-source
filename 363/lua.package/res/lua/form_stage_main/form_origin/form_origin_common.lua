require("form_stage_main\\form_origin\\form_origin_define")
function main_form_init(form)
  form.Fixed = true
  form.Top = 0
  form.Left = 0
end
function on_main_form_open(form)
  form.Top = 0
  form.Left = 0
  form.jianghu_pageno = 1
  form.page_count = 0
  form.page_next_ok = 1
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_click(btn)
  nx_execute(FORM_ORIGIN_LINE, "on_btn_click", btn)
end
function on_life_btn_pre_click(btn)
  local form = btn.ParentForm
  local step = form.groupbox_lines_index.Width / form.page_count
  if form.groupbox_lines_index.Left < -step then
    form.groupbox_lines_index.Left = form.groupbox_lines_index.Left + step
    form.btn_pre.Enabled = true
  else
    form.groupbox_lines_index.Left = 0
    form.btn_pre.Enabled = false
  end
  form.btn_next.Enabled = true
end
function on_life_btn_next_click(btn)
  local form = btn.ParentForm
  local line_left = form.groupbox_lines_index.Left
  local window_width = form.groupbox_window.Width
  local line_width = form.groupbox_lines_index.Width
  local step = line_width / form.page_count
  if line_left > window_width - line_width + step then
    form.groupbox_lines_index.Left = line_left - step
    form.btn_next.Enabled = true
  else
    form.groupbox_lines_index.Left = window_width - line_width
    form.btn_next.Enabled = false
  end
  form.btn_pre.Enabled = true
end
function on_select_btn_click(btn)
  if not btn.Checked then
    return
  end
  local form = btn.ParentForm
  form.lbl_2.Left = btn.Left + 30
  local line = btn.line
  nx_execute(FORM_ORIGIN_LINE, "refresh_life", nx_int(line))
end
function on_btn_pre_click(btn)
  local form = btn.ParentForm
  if form.jianghu_pageno > 1 then
    get_origin_list(form, form.jianghu_pageno - 1)
    form.page_next_ok = 1
  end
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if 0 < form.page_next_ok then
    get_origin_list(form, form.jianghu_pageno + 1)
  end
end
function get_origin_list(form, pageno)
  local from = (nx_int(pageno) - 1) * PAGE_COUNT + 1
  local to = pageno * PAGE_COUNT
  if to > LINE_NUM_JIANGHU_CHENGJIU then
    to = LINE_NUM_JIANGHU_CHENGJIU
    form.page_next_ok = 0
  end
  nx_execute(FORM_ORIGIN_LINE, "refresh_jianghu_chengjiu", from, to)
end
function on_rbtn_checked_changed(btn)
  if not btn.Checked then
    return
  end
  local form_line = btn.ParentForm
  form_line.lbl_4.Left = btn.Left + 30
  local form_origin_main = nx_value(FORM_ORIGIN)
  if form_origin_main.sub_type == 2 then
    nx_execute(FORM_ORIGIN_LINE, "refresh_jianghu_chengjiu", nx_string(btn.sub_type))
  elseif form_origin_main.sub_type == 3 then
    nx_execute(FORM_ORIGIN_LINE, "refresh_jianghu_wuxue", nx_string(btn.sub_type))
  elseif form_origin_main.sub_type == 4 then
    nx_execute(FORM_ORIGIN_LINE, "refresh_jianghu_marry", nx_string(btn.sub_type))
  elseif form_origin_main.sub_type == 5 then
    nx_execute(FORM_ORIGIN_LINE, "refresh_jianghu_lover", nx_string(btn.sub_type))
  elseif form_origin_main.sub_type == 6 then
    nx_execute(FORM_ORIGIN_LINE, "refresh_jianghu_vip", nx_string(btn.sub_type))
  elseif form_origin_main.sub_type == 7 then
    nx_execute(FORM_ORIGIN_LINE, "refresh_jianghu_body", nx_string(btn.sub_type))
  end
end
function on_force_line_checked_changed(btn)
  if not btn.Checked then
    return
  end
  local form_force = btn.ParentForm
  form_force.lbl_4.Left = btn.Left + 43
  local form_origin_main = nx_value(FORM_ORIGIN)
  nx_execute(FORM_ORIGIN_LINE, "refresh_force", nx_string(btn.sub_type))
end
function on_new_school_line_checked_changed(btn)
  if not btn.Checked then
    return
  end
  local form = btn.ParentForm
  form.lbl_4.Left = btn.Left + 43
  form.groupscrollbox_100.Visible = false
  local form_origin = nx_value(FORM_ORIGIN)
  local name = btn.Name
  if name == "btn_line_1" then
    form_origin.cbtn_index = 1
  elseif name == "btn_line_2" then
    form_origin.cbtn_index = 2
  elseif name == "btn_line_3" then
    form_origin.cbtn_index = 3
  end
  nx_execute(FORM_ORIGIN_LINE, "refresh_new_shcool", nx_string(btn.sub_type))
end
function on_btn_jj_click(btn)
  if not btn.Checked then
    return
  end
  local form = btn.ParentForm
  form.lbl_4.Left = btn.Left + 43
  form.groupbox_1.Visible = false
  form.groupbox_2.Visible = false
  form.groupscrollbox_100.Visible = true
  local form_origin = nx_value(FORM_ORIGIN)
  form_origin.cbtn_index = 4
  nx_execute(FORM_ORIGIN_LINE, "refresh_new_school_stage_line", 6, nx_string(btn.sub_type))
end
