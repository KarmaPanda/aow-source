require("util_functions")
require("util_gui")
function on_main_form_init(self)
  self.Fixed = false
  self.rbtn_OFFSET_W = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) * 0.5
  form.Top = (gui.Height - form.Height) * 0.5
  local form_main_show_update = nx_value("form_main_show_update")
  if not nx_is_valid(form_main_show_update) then
    form_main_show_update = nx_create("form_main_show_update")
  end
  if not nx_is_valid(form_main_show_update) then
    on_main_form_close(form)
    return
  end
  nx_set_value("form_main_show_update", form_main_show_update)
  form_main_show_update:InitForm(form)
end
function on_main_form_close(form)
  local form_main_show_update = nx_value("form_main_show_update")
  if nx_is_valid(form_main_show_update) then
    nx_destroy(form_main_show_update)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_rbtn_homepage_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_find_custom(rbtn, "sect") then
    return
  end
  local form_main_show_update = nx_value("form_main_show_update")
  if nx_is_valid(form_main_show_update) then
    form_main_show_update:UpdatePage(form, rbtn.sect, rbtn.Name, true)
  end
end
function on_rbtn_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_find_custom(rbtn, "sect") then
    return
  end
  local form_main_show_update = nx_value("form_main_show_update")
  if nx_is_valid(form_main_show_update) then
    form_main_show_update:UpdatePage(form, rbtn.sect, rbtn.Name, false)
  end
end
function on_btn_click(btn)
  if not nx_find_custom(btn, "data_info") then
    return
  end
  local data = btn.data_info
  if "" == data then
    return
  end
  local data_list = util_split_string(data, ",")
  if "findnpc_new" == data_list[1] then
    nx_execute("hyperlink_manager", "add_map_label_by_hyerlink", data)
    nx_execute("hyperlink_manager", "find_path_npc_item", data, true)
  elseif "open_form" == data_list[1] then
    if 2 < table.getn(data_list) then
      return
    end
    nx_execute(data_list[2], "open_form")
  end
end
function on_btn_get_capture(btn)
  set_home_page_back_image(btn, false)
end
function on_btn_lost_capture(btn)
  set_home_page_back_image(btn, true)
end
function set_home_page_back_image(btn, is_lost)
  local parent = btn.Parent
  if not nx_is_valid(parent) then
    return
  end
  if not nx_find_custom(btn, "data_info") then
    return
  end
  if "" == btn.data_info then
    return
  end
  if is_lost then
    parent.BackImage = "gui\\special\\gengxintishi\\gengxin_back.png"
  else
    parent.BackImage = "gui\\special\\gengxintishi\\gengxin_back_on.png"
  end
end
function on_rbtn_versions_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.show_index = rbtn.index_no
    local form_main_show_update = nx_value("form_main_show_update")
    if nx_is_valid(form_main_show_update) then
      form_main_show_update:InitPage(form, nx_string(rbtn.Name))
    end
  end
end
function on_btn_last_click(btn)
  local form = btn.ParentForm
  local show_index = form.show_index - 1
  local child_control_list = form.groupbox_main:GetChildControlList()
  local max_size = table.getn(child_control_list)
  if show_index == 0 then
    return
  end
  local cur_rbtn = find_rbtn_by_index(form.groupbox_main, form.show_index)
  if not nx_is_valid(cur_rbtn) then
    return
  end
  local move = false
  if cur_rbtn.Left == 0 then
    move = true
  end
  local rbtn = find_rbtn_by_index(form.groupbox_main, show_index)
  if not nx_is_valid(rbtn) then
    return
  end
  if move == true then
    local OFFSET_W = form.rbtn_OFFSET_W
    for i, control in ipairs(child_control_list) do
      control.Left = OFFSET_W * (i - show_index)
    end
  end
  rbtn.Checked = true
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  local show_index = form.show_index + 1
  local child_control_list = form.groupbox_main:GetChildControlList()
  local max_size = table.getn(child_control_list)
  if show_index > max_size then
    return
  end
  local cur_rbtn = find_rbtn_by_index(form.groupbox_main, form.show_index)
  if not nx_is_valid(cur_rbtn) then
    return
  end
  local rbtn = find_rbtn_by_index(form.groupbox_main, show_index)
  if not nx_is_valid(rbtn) then
    return
  end
  local move = false
  if nx_int(cur_rbtn.Left / form.rbtn_OFFSET_W) >= nx_int(4) then
    move = true
  end
  if move == true then
    local start = show_index - 5 + 1
    local OFFSET_W = form.rbtn_OFFSET_W
    for i, control in ipairs(child_control_list) do
      control.Left = OFFSET_W * (i - start)
    end
  end
  rbtn.Checked = true
end
function find_rbtn_by_index(groupbox, select_index)
  if not nx_is_valid(groupbox) then
    return nx_null()
  end
  local child_control_list = groupbox:GetChildControlList()
  for i, control in ipairs(child_control_list) do
    if nx_find_custom(control, "index_no") and control.index_no == select_index then
      return control
    end
  end
  return nx_null()
end
