require("util_functions")
require("util_gui")
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
local OFFSET_H = 0
local OFFSET_W = 0
local set_ent_property = function(source_node, target_node)
  if not nx_is_valid(source_node) or not nx_is_valid(target_node) then
    return
  end
  local prop_list = nx_property_list(source_node)
  for i, prop in ipairs(prop_list) do
    local value = nx_property(target_node, prop)
    local custom_type = nx_type(value)
    if "number" == nx_string(custom_type) then
      nx_set_property(target_node, prop, nx_number(nx_property(source_node, prop)))
    elseif "string" == nx_string(custom_type) then
      nx_set_property(target_node, prop, nx_property(source_node, prop))
    elseif "boolean" == nx_string(custom_type) then
      nx_set_property(target_node, prop, nx_boolean(nx_property(source_node, prop)))
    end
  end
end
local get_text = function(ui_text, ...)
  local gui = nx_value("gui")
  local size = table.getn(arg)
  gui.TextManager:Format_SetIDName(ui_text)
  for i = 1, size do
    gui.TextManager:Format_AddParam(arg[i])
  end
  return gui.TextManager:Format_GetText()
end
function on_main_form_init(self)
  self.Fixed = true
  self.rbtn_OFFSET_W = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) * 0.5
  form.Top = (gui.Height - form.Height) * 0.5
  create_update_rbtn_from_ini(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function create_update_rbtn_from_ini(form)
  local ini = get_ini("ini\\update\\update_list.ini")
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex("update_list")
  if -1 == index then
    return
  end
  local item_index = ini:FindSectionItemIndex(index, "e")
  if -1 == item_index then
    return
  end
  local item_value_list = ini:GetItemValueList(index, "e")
  form.groupbox_main:DeleteAll()
  local gui = nx_value("gui")
  local size = table.getn(item_value_list)
  if size < 0 then
    return
  end
  local first_rbtn = nx_null()
  OFFSET_W = form.groupbox_main.Width / 5
  form.rbtn_OFFSET_W = OFFSET_W
  local index_no = 1
  for i, info in pairs(item_value_list) do
    local rbtn = gui:Create("RadioButton")
    if nx_is_valid(rbtn) then
      nx_bind_script(rbtn, nx_current())
      nx_callback(rbtn, "on_checked_changed", "on_rbtn_versions_checked_changed")
      if 1 == index_no then
        on_set_main_rbtn_prop(rbtn)
      else
        on_set_minor_rbtn_prop(rbtn)
      end
      rbtn.AutoSize = false
      rbtn.DrawMode = "FitWindow"
      rbtn.Name = nx_string(info) .. nx_string(i)
      rbtn.Text = get_text("ui_" .. info)
      rbtn.Left = OFFSET_W * (i - 1) + OFFSET_H
      rbtn.Width = OFFSET_W
      rbtn.Top = 6
      rbtn.file_name = "ini\\update\\" .. info .. ".ini"
      rbtn.index_no = index_no
      index_no = index_no + 1
      if not nx_is_valid(first_rbtn) then
        first_rbtn = rbtn
      end
      form.groupbox_main:Add(rbtn)
    end
  end
  first_rbtn.Checked = true
  form.show_index = 1
end
function create_update_cbtn_from_ini(form, file_name)
  local ini = get_ini(file_name)
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex("update")
  if -1 == index then
    return
  end
  local item_index = ini:FindSectionItemIndex(index, "i")
  if -1 == item_index then
    return
  end
  form.groupbox_first:DeleteAll()
  local frist_value = ini:GetSectionItemValue(index, item_index)
  local gui = nx_value("gui")
  local rbtn = gui:Create("RadioButton")
  local offset_h = nx_int(form.rbtn_template.DataSource)
  set_rbtn_info(form, form.rbtn_template, rbtn, 1, frist_value, offset_h)
  rbtn.file_name = file_name
  nx_bind_script(rbtn, nx_current())
  nx_callback(rbtn, "on_checked_changed", "on_rbtn_homepage_checked_changed")
  local item_value_list = ini:GetItemValueList(index, "e")
  local size = table.getn(item_value_list)
  if size < 0 then
    return
  end
  for i, info in pairs(item_value_list) do
    local rbtn = gui:Create("RadioButton")
    set_rbtn_info(form, form.rbtn_template, rbtn, i, info, form.rbtn_template.Height + offset_h - 5)
    rbtn.file_name = file_name
    nx_bind_script(rbtn, nx_current())
    nx_callback(rbtn, "on_checked_changed", "on_rbtn_checked_changed")
  end
  form.groupbox_first.IsEditMode = false
  form.groupbox_first:ResetChildrenYPos()
  rbtn.Checked = true
end
function set_rbtn_info(form, rbtn_template, rbtn, index, info, offset_h)
  on_set_detail_rbtn_prop(rbtn)
  rbtn.Name = nx_string(info) .. nx_string(index)
  rbtn.Text = get_text("ui_" .. info)
  rbtn.sect = info
  form.groupbox_first:Add(rbtn)
end
function on_rbtn_homepage_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.groupbox_1.Visible = false
    form.groupbox_2.Visible = false
    form.groupbox_3.Visible = false
    form.groupbox_4.Visible = false
    local ini = get_ini(rbtn.file_name)
    if not nx_is_valid(ini) then
      return
    end
    local index = ini:FindSectionIndex(rbtn.sect)
    if -1 == index then
      return
    end
    local item_index = ini:FindSectionItemIndex(index, "photo")
    if -1 == item_index then
      return
    end
    local item_value = ini:GetSectionItemValue(index, item_index)
    form.groupbox_page.BackImage = item_value
  end
end
function on_rbtn_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    local ini = get_ini(rbtn.file_name)
    if not nx_is_valid(ini) then
      return
    end
    local index = ini:FindSectionIndex(rbtn.sect)
    if -1 == index then
      return
    end
    local photo_list = ini:GetItemValueList(index, "photo")
    local text_list = ini:GetItemValueList(index, "text")
    local data_list = ini:GetItemValueList(index, "data_info")
    if 1 > table.getn(photo_list) then
      return
    end
    for i = 1, 4 do
      local groupbox = nx_custom(form, "groupbox_" .. i)
      local mltbox = nx_custom(form, "mltbox_" .. i + 4)
      local btn = nx_custom(form, "btn_" .. i)
      local lbl = nx_custom(form, "lbl_" .. i)
      set_groupbox_info(groupbox, mltbox, btn, lbl, photo_list[i], text_list[i], data_list[i])
    end
    form.groupbox_page.BackImage = ""
  end
end
function set_groupbox_info(groupbox, mltbox, btn, lbl, photo, text, data_info)
  btn.BackImage = photo
  mltbox.HtmlText = get_text(text)
  groupbox.Visible = true
  if "" == data_info then
    lbl.Visible = false
  else
    lbl.Visible = true
  end
  nx_set_custom(btn, "data_info", data_info)
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
    create_update_cbtn_from_ini(form, rbtn.file_name)
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
      control.Left = OFFSET_W * (i - show_index) + OFFSET_H
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
      control.Left = OFFSET_W * (i - start) + OFFSET_H
    end
  end
  rbtn.Checked = true
end
function on_set_main_rbtn_prop(main_rbtn)
  if not nx_is_valid(main_rbtn) then
    return
  end
  main_rbtn.BoxSize = 12
  main_rbtn.NormalImage = "gui\\special\\gengxintishi\\newversion_out.png"
  main_rbtn.FocusImage = "gui\\special\\gengxintishi\\newversion_on.png"
  main_rbtn.CheckedImage = "gui\\special\\gengxintishi\\newversion_down.png"
  main_rbtn.FocusBlendColor = "255,255,255,255"
  main_rbtn.PushBlendColor = "255,255,255,255"
  main_rbtn.DisableBlendColor = "255,255,255,255"
  main_rbtn.NormalColor = "0,0,0,0"
  main_rbtn.FocusColor = "255,255,255,255"
  main_rbtn.PushColor = "255,255,204,0"
  main_rbtn.DisableColor = "0,0,0,0"
  main_rbtn.Left = 64
  main_rbtn.Top = 615
  main_rbtn.Width = 134
  main_rbtn.Height = 38
  main_rbtn.ForeColor = "255,197,184,159"
  main_rbtn.BackColor = "255,197,184,159"
  main_rbtn.ShadowColor = "0,0,0,0"
  main_rbtn.Font = "font_main"
  main_rbtn.TabStop = true
end
function on_set_minor_rbtn_prop(minor_rbtn)
  if not nx_is_valid(minor_rbtn) then
    return
  end
  minor_rbtn.BoxSize = 12
  minor_rbtn.NormalImage = "gui\\special\\gengxintishi\\newversion_out.png"
  minor_rbtn.FocusImage = "gui\\special\\gengxintishi\\newversion_on.png"
  minor_rbtn.CheckedImage = "gui\\special\\gengxintishi\\newversion_down.png"
  minor_rbtn.FocusBlendColor = "255,255,255,255"
  minor_rbtn.PushBlendColor = "255,255,255,255"
  minor_rbtn.DisableBlendColor = "255,255,255,255"
  minor_rbtn.NormalColor = "0,0,0,0"
  minor_rbtn.FocusColor = "255,255,255,255"
  minor_rbtn.PushColor = "255,255,204,0"
  minor_rbtn.DisableColor = "0,0,0,0"
  minor_rbtn.Left = 152
  minor_rbtn.Top = 623
  minor_rbtn.Width = 134
  minor_rbtn.Height = 38
  minor_rbtn.ForeColor = "255,204,204,204"
  minor_rbtn.BackColor = "255,192,192,192"
  minor_rbtn.ShadowColor = "0,0,0,0"
  minor_rbtn.Font = "font_main"
  minor_rbtn.TabStop = true
end
function on_set_detail_rbtn_prop(detail_rbtn)
  if not nx_is_valid(detail_rbtn) then
    return
  end
  detail_rbtn.BoxSize = 12
  detail_rbtn.NormalImage = "gui\\special\\gengxintishi\\gengxin_out.png"
  detail_rbtn.FocusImage = "gui\\special\\gengxintishi\\gengxin_on.png"
  detail_rbtn.CheckedImage = "gui\\special\\gengxintishi\\gengxin_down.png"
  detail_rbtn.FocusBlendColor = "255,255,255,255"
  detail_rbtn.PushBlendColor = "255,255,255,255"
  detail_rbtn.DisableBlendColor = "255,255,255,255"
  detail_rbtn.NormalColor = "0,0,0,0"
  detail_rbtn.FocusColor = "0,0,0,0"
  detail_rbtn.PushColor = "0,0,0,0"
  detail_rbtn.DisableColor = "0,0,0,0"
  detail_rbtn.Left = 8
  detail_rbtn.Top = 40
  detail_rbtn.Width = 150
  detail_rbtn.Height = 39
  detail_rbtn.ForeColor = "255,247,242,151"
  detail_rbtn.BackColor = "255,192,192,192"
  detail_rbtn.ShadowColor = "0,0,0,0"
  detail_rbtn.DataSource = "-2"
  detail_rbtn.Font = "font_main"
  detail_rbtn.TabStop = true
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
