local FORM_RECORDS = "form_stage_main\\form_sweet_employ\\form_offline_employee_records"
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  change_form_size(form)
  init_form(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function init_form(form)
  if not nx_is_valid(form) then
    return
  end
  del_subcontrol(form.gsb_records)
  show_context(form)
end
function show_context(form)
  if not nx_is_valid(form) then
    return
  end
  local records_number = 6
  for i = 1, records_number do
    local gb = clone_records_groupbox(form)
    if nx_is_valid(gb) then
      gb.Visible = true
      fill_records_info(i, gb)
      form.gsb_records:Add(gb)
    end
  end
  form.gsb_records.IsEditMode = false
  form.gsb_records:ResetChildrenYPos()
end
function fill_records_info(i, gb)
  if nx_number(i) < nx_number(1) or not nx_is_valid(gb) then
    return
  end
  gb.lbl_time.Text = nx_widestr("\202\177\188\228\163\186") .. nx_widestr(i)
  gb.mltbox_txt.HtmlText = nx_widestr("\196\218\200\221\163\186") .. nx_widestr(i)
end
function open_form()
  local form = nx_value(FORM_RECORDS)
  if nx_is_valid(form) then
    form.Visible = false
    form:Close()
    return
  end
  form = nx_execute("util_gui", "util_get_form", FORM_RECORDS, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function change_form_size(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function clone_records_groupbox(form)
  local gui = nx_value("gui")
  if not nx_is_valid(form) or not nx_is_valid(gui) then
    return nil
  end
  local item = gui:Create("GroupBox")
  local tpl_item = form.gb_item
  if not nx_is_valid(item) or not nx_is_valid(tpl_item) then
    return nil
  end
  item.dynamic_create = true
  local prop_tab = nx_property_list(tpl_item)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(item, prop_tab[i], nx_property(tpl_item, prop_tab[i]))
  end
  local tmp_time = tpl_item:Find("lbl_time")
  local lbl_time = gui:Create("Label")
  if nx_is_valid(lbl_time) and nx_is_valid(tmp_time) then
    local props_tab = nx_property_list(tmp_time)
    for i = 1, table.getn(props_tab) do
      nx_set_property(lbl_time, props_tab[i], nx_property(tmp_time, props_tab[i]))
    end
    item:Add(lbl_time)
    item.lbl_time = lbl_time
  end
  local tmp_mtbox = tpl_item:Find("mltbox_txt")
  local mltbox_txt = gui:Create("MultiTextBox")
  if nx_is_valid(mltbox_txt) and nx_is_valid(tmp_mtbox) then
    local props_tab = nx_property_list(tmp_mtbox)
    for i = 1, table.getn(props_tab) do
      nx_set_property(mltbox_txt, props_tab[i], nx_property(tmp_mtbox, props_tab[i]))
    end
    item:Add(mltbox_txt)
    item.mltbox_txt = mltbox_txt
  end
  return item
end
function del_subcontrol(ctl)
  local child_table = ctl:GetChildControlList()
  local child_count = table.getn(child_table)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  for i = child_count, 1, -1 do
    local child = child_table[i]
    if nx_is_valid(child) and nx_name(child) == "GroupBox" and nx_find_custom(child, "dynamic_create") then
      ctl:Remove(child)
      gui:Delete(child)
    end
  end
end
