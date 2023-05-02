require("form_task\\form_task")
local RULE_CONFIG_XML = "editor\\ini\\rule_config.xml"
function main_form_init(self)
  self.Fixed = false
  self.groupbox = nil
  self.path = nx_function("ext_get_full_path", "..\\..\\..\\02_Server\\Cons\\Res")
  if not nx_path_exists(self.path) then
    self.path = nx_function("ext_get_full_path", "..\\..\\02_Server\\Res")
    if not nx_path_exists(self.path) then
      self.path = ""
    end
  end
  return 1
end
function main_form_open(self)
  self.btn_add.Visible = false
  self.btn_delete.Visible = false
  self.btn_add_rule.Visible = false
  self.btn_delete_rule.Visible = false
  load_rule_config_xml(self)
  update_infiles_list(self.infiles_list)
  load_file_list(self)
  return 1
end
function main_form_close(self)
  local rule_config = nx_value("rule_config")
  if nx_is_valid(rule_config) then
    nx_destroy(rule_config)
  end
  nx_destroy(self)
end
function btn_close_click(self)
  local form = self.Parent
  form:Close()
end
function open_files_transformer_form()
  local files_transformer_form = nx_value("files_transformer_form")
  if not nx_is_valid(files_transformer_form) then
    local gui = nx_value("gui")
    local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "\\form_task\\form_files_transformer.xml")
    dialog:Show()
    nx_set_value("files_transformer_form", dialog)
  end
end
function update_infiles_list(control_box)
  local gui = nx_value("gui")
  control_box:ClearControl()
  control_box.SelectIndex = -1
  local rule_config = nx_value("rule_config")
  if nx_is_valid(rule_config) then
    local item_list = rule_config:GetChildList()
    for i = 1, table.getn(item_list) do
      local infile = item_list[i].Name
      local model = item_list[i].model
      local groupbox = CREATE_CONTROL("GroupBox")
      groupbox.Width = 300
      groupbox.Height = 60
      groupbox.LineColor = "0,0,0,0"
      groupbox.BackColor = "0,0,0,0"
      groupbox.info = item_list[i]
      local checkbutton = CREATE_CONTROL("CheckButton")
      checkbutton.Width = 20
      checkbutton.Top = 10
      checkbutton.Left = 10
      checkbutton.Checked = false
      groupbox:Add(checkbutton)
      groupbox.ctrl = checkbutton
      local label = CREATE_CONTROL("Label")
      label.Text = nx_widestr(infile)
      label.Left = 30
      label.Top = 10
      label.Height = 20
      groupbox:Add(label)
      local combobox = CREATE_CONTROL("ComboBox")
      combobox.Text = nx_widestr(model)
      combobox.Left = 30
      combobox.Top = 30
      combobox.Width = 80
      combobox.DropListBox:AddString(nx_widestr("normal"))
      combobox.DropListBox:AddString(nx_widestr("special"))
      groupbox:Add(combobox)
      control_box:AddControl(groupbox)
    end
  end
  return 1
end
function update_outfiles_list(control_box, item)
  local gui = nx_value("gui")
  control_box:ClearControl()
  control_box.SelectIndex = -1
  local out_list = item:GetChildList()
  for i = 1, table.getn(out_list) do
    local outfile = out_list[i].Name
    local groupbox = CREATE_CONTROL("GroupBox")
    groupbox.Width = 300
    groupbox.Height = 50
    groupbox.LineColor = "0,0,0,0"
    groupbox.BackColor = "0,0,0,0"
    groupbox.info = out_list[i]
    local outfile_edit = CREATE_CONTROL("Edit")
    outfile_edit.Text = nx_widestr(outfile)
    outfile_edit.Left = 10
    outfile_edit.Top = 10
    outfile_edit.Width = 200
    nx_bind_script(outfile_edit, nx_current())
    nx_callback(outfile_edit, "on_lost_focus", "outfile_edit_lost_focus")
    groupbox:Add(outfile_edit)
    control_box:AddControl(groupbox)
  end
  return 1
end
function outfiles_list_select_click(self, index)
  local form = self.Parent
  local current_groupbox = self:GetControl(index)
  if not nx_find_custom(current_groupbox, "info") then
    return 0
  end
  if nx_is_valid(form.groupbox) then
    local groupbox_index = self:FindControl(form.groupbox)
    self:RemoveControl(form.groupbox)
    if groupbox_index ~= index + 1 then
      form.groupbox = create_rule_control(self, current_groupbox.info, index + 1)
    end
  else
    form.groupbox = create_rule_control(self, current_groupbox.info, index + 1)
  end
  return 1
end
function create_rule_control(control_box, info, index)
  local gui = nx_value("gui")
  local groupbox = CREATE_CONTROL("GroupBox")
  groupbox.Width = 300
  groupbox.Height = 10
  groupbox.LineColor = "0,0,0,0"
  local child_list = info:GetChildList()
  for i = 1, table.getn(child_list) do
    local child = child_list[i]
    local combobox = CREATE_CONTROL("ComboBox")
    combobox.Text = nx_widestr(child.prop)
    combobox.Left = 10
    combobox.Top = groupbox.Height
    combobox.Width = 60
    combobox.DropListBox:AddString(nx_widestr("ID"))
    combobox.DropListBox:AddString(nx_widestr("TID"))
    combobox.DropListBox:AddString(nx_widestr("FID"))
    combobox.DropListBox:AddString(nx_widestr("QID"))
    groupbox:Add(combobox)
    local rule_edit = CREATE_CONTROL("Edit")
    rule_edit.Text = nx_widestr(child.rule)
    rule_edit.Left = combobox.Left + combobox.Width + 10
    rule_edit.Top = groupbox.Height
    rule_edit.Width = 140
    groupbox:Add(rule_edit)
    groupbox.Height = groupbox.Height + combobox.Height + 10
  end
  control_box:AddControlByIndex(groupbox, index)
  return groupbox
end
function prop_edit_lost_focus(self)
  local child = self.Parent.info
  if nx_is_valid(child) then
    child.prop = nx_string(self.Text)
    save_rule_config_xml()
  end
  return 1
end
function rule_edit_lost_focus(self)
  local child = self.Parent.info
  if nx_is_valid(child) then
    child.rule = nx_string(self.Text)
    save_rule_config_xml()
  end
  return 1
end
function outfile_edit_lost_focus(self)
  local child = self.Parent.info
  if nx_is_valid(child) then
    child.outfile = nx_string(self.Text)
    save_rule_config_xml()
  end
  return 1
end
function model_combobox_select(self)
  local child = self.Parent.info
  if nx_is_valid(child) then
    child.model = nx_string(self.Text)
    save_rule_config_xml()
  end
  return 1
end
function button_click(self)
  local form = nx_value("files_transformer_form")
  local gui = nx_value("gui")
  local pictfile_form = nx_value("pictfile_form")
  if not nx_is_valid(pictfile_form) then
    pictfile_form = LOAD_FORM(nx_resource_path(), gui.skin_path .. "\\form_task\\form_pictfile.xml")
    nx_set_value("pictfile_form", pictfile_form)
  end
  pictfile_form.path = form.path
  pictfile_form:ShowModal()
  local res, new_name = nx_wait_event(100000000, pictfile_form, "pictfile_return")
  if res == "cancel" then
    return 0
  end
  self.ctrl.Text = nx_widestr(new_name)
  local child = self.Parent.info
  if nx_is_valid(child) then
    child.outfile = new_name
    save_rule_config_xml()
  end
  return 1
end
function create_file(file_name)
  local xml_doc = nx_create("XmlDocument")
  local root = xml_doc:CreateRootElement("object")
  if not xml_doc:SaveFile(file_name) then
    nx_msgbox("\180\180\189\168(" .. file_name .. ")\206\196\188\254\202\167\176\220")
    nx_destroy(xml_doc)
    return 0
  end
  nx_destroy(xml_doc)
end
function load_rule_config_xml(form)
  local rule_config = nx_value("rule_config")
  if not nx_is_valid(rule_config) then
    rule_config = nx_create("ArrayList", "rule_config")
    nx_set_value("rule_config", rule_config)
  else
    rule_config:ClearChild()
  end
  local xml_doc = nx_create("XmlDocument")
  if not xml_doc:LoadFile(nx_resource_path() .. RULE_CONFIG_XML) then
    nx_destroy(xml_doc)
    create_file(nx_resource_path() .. RULE_CONFIG_XML)
    return 0
  else
    local item_list = xml_doc.RootElement:GetChildList("item")
    local item_count = table.getn(item_list)
    for i = 1, item_count do
      local item_ins = item_list[i]
      local infile = item_ins:QueryAttr("infile")
      local model = item_ins:QueryAttr("model")
      local path = item_ins:QueryAttr("path")
      if "" ~= infile then
        local item = rule_config:CreateChild(infile)
        item.model = model
        item.path = path
        local out_list = item_ins:GetChildList()
        local out_count = table.getn(out_list)
        for j = 1, out_count do
          local rulefile = out_list[j]:QueryAttr("rulefile")
          local key = out_list[j]:QueryAttr("key")
          if rulefile == "" then
            local outfile = out_list[j]:QueryAttr("outfile")
            local out = item:CreateChild(outfile)
            local child_list = out_list[j]:GetChildList()
            for k = 1, table.getn(child_list) do
              local child = out:CreateChild(child_list[j]:QueryAttr("prop"))
              child.prop = child_list[j]:QueryAttr("prop")
              child.rule = child_list[j]:QueryAttr("rule")
            end
          else
            local ini = nx_create("IniDocument")
            ini.FileName = form.path .. rulefile
            if ini:LoadFromFile() then
              local sect_list = ini:GetSectionList()
              local sect_count = table.getn(sect_list)
              for k = 1, sect_count do
                local sect_name = sect_list[k]
                local value = ini:ReadString(sect_name, key, "")
                if value ~= "" then
                  local list = nx_function("ext_split_string", value, ";")
                  local out
                  if 0 < table.getn(list) then
                    out = item:CreateChild(list[1])
                    out.key = key
                    out.rulefile = rulefile
                  end
                  for n = 3, table.getn(list), 2 do
                    local child = out:CreateChild(list[n - 1])
                    child.prop = list[n - 1]
                    child.rule = list[n]
                  end
                end
              end
            end
            nx_destroy(ini)
          end
        end
      end
    end
    nx_destroy(xml_doc)
  end
  return 1
end
function transform_files(form, item)
  local infile = item.Name
  local model = item.model
  local path = item.path
  local out_list = item:GetChildList()
  for j = 1, table.getn(out_list) do
    local textgrid = nx_create("TextGrid")
    if path == "client" then
      textgrid.FileName = nx_resource_path() .. out_list[j].Name
    else
      textgrid.FileName = form.path .. out_list[j].Name
    end
    if not textgrid:LoadFromFile(2) then
      nx_msgbox("\180\242\191\170\206\196\188\254(" .. textgrid.FileName .. ")\202\167\176\220")
    else
      textgrid:RemoveAllCell()
      if path == "client" then
        local textgrid_src = nx_create("TextGrid")
        textgrid_src.FileName = nx_resource_path() .. infile
        if not textgrid_src:LoadFromFile(2) then
          nx_msgbox("\188\211\212\216\206\196\188\254\163\168" .. textgrid_src.FileName .. "\163\169\202\167\176\220")
        else
          for k = 0, textgrid_src.RowCount - 1 do
            local key_value = textgrid_src:GetValueString(nx_int(k), nx_int(0))
            if key_value ~= "" then
              local lst = nx_function("ext_split_string", key_value, "=")
              if table.getn(lst) > 0 then
                add_item_info_outfile(model, out_list[j], lst[1], textgrid, key_value, textgrid_src)
              end
            end
          end
        end
        nx_destroy(textgrid_src)
      else
        local ini = nx_create("IniDocument")
        ini.FileName = form.path .. infile
        if not ini:LoadFromFile() then
          nx_msgbox("\188\211\212\216\206\196\188\254\163\168" .. ini.FileName .. "\163\169\202\167\176\220")
        else
          local sect_list = ini:GetSectionList()
          local sect_count = table.getn(sect_list)
          for k = 1, sect_count do
            add_item_info_outfile(model, out_list[j], sect_list[k], textgrid, "", ini)
          end
        end
        nx_destroy(ini)
      end
    end
    if not textgrid:SaveToFile() then
      nx_msgbox(textgrid.FileName .. " - \206\196\188\254\177\163\180\230\180\237\206\243")
      nx_destroy(textgrid)
      return 0
    end
    nx_destroy(textgrid)
  end
  return 1
end
function add_item_info_outfile(model, out, sect_name, textgrid, key_value, file_point)
  if model == "special" then
    if out:GetChildCount() <= 0 then
      if key_value == "" then
        local item_list = file_point:GetItemValueList(sect_name, "r")
        for i = 1, table.getn(item_list) do
          local value_list = nx_function("ext_split_string", item_list[i], ",")
          local row = textgrid:AddRow(sect_name)
          for j = 1, table.getn(value_list) do
            textgrid:SetValueString(nx_int(row), nx_int(j), value_list[j])
          end
        end
      else
        local row = textgrid:AddRow(key_value)
      end
      return 1
    end
    local child = out:GetChild("ID")
    if nx_is_valid(child) then
      local rule = child.rule
      if is_num_in_range(sect_name, rule) then
        if key_value == "" then
          local item_list = file_point:GetItemValueList(sect_name, "r")
          for i = 1, table.getn(item_list) do
            local value_list = nx_function("ext_split_string", item_list[i], ",")
            local row = textgrid:AddRow(sect_name)
            for j = 1, table.getn(value_list) do
              textgrid:SetValueString(nx_int(row), nx_int(j), value_list[j])
            end
          end
        else
          local row = textgrid:AddRow(key_value)
        end
      end
      return 1
    end
    local child = out:GetChild("CID")
    if nx_is_valid(child) then
      local rule = child.rule
      local str_list = nx_function("ext_split_string", sect_name, "-")
      if table.getn(str_list) == 2 and 0 < nx_number(str_list[1]) and 0 < nx_number(str_list[2]) and is_num_in_range(nx_number(str_list[2]), rule) then
        if key_value == "" then
          local item_list = file_point:GetItemValueList(sect_name, "r")
          for i = 1, table.getn(item_list) do
            local value_list = nx_function("ext_split_string", item_list[i], ",")
            local row = textgrid:AddRow(sect_name)
            for j = 1, table.getn(value_list) do
              textgrid:SetValueString(nx_int(row), nx_int(j), value_list[j])
            end
          end
        else
          local row = textgrid:AddRow(key_value)
        end
      end
      return 1
    end
    local id_type, position = get_id_type(get_string_before_number(sect_name))
    if id_type ~= nil then
      local child = out:GetChild(id_type)
      if nx_is_valid(child) then
        local rule = child.rule
        if is_num_in_range(get_compare_number(sect_name, position), rule) then
          if key_value == "" then
            local item_list = file_point:GetItemValueList(sect_name, "r")
            for i = 1, table.getn(item_list) do
              local value_list = nx_function("ext_split_string", item_list[i], ",")
              local row = textgrid:AddRow(sect_name)
              for j = 1, table.getn(value_list) do
                textgrid:SetValueString(nx_int(row), nx_int(j), value_list[j])
              end
            end
          else
            local row = textgrid:AddRow(key_value)
          end
        end
        return 1
      end
    else
      nx_msgbox(sect_name)
    end
  else
    if out:GetChildCount() <= 0 then
      if key_value == "" then
        local row = textgrid:AddRow(sect_name)
        local key_list = file_point:GetItemList(sect_name)
        for m = 1, table.getn(key_list) do
          local value = file_point:ReadString(sect_name, key_list[m], "")
          textgrid:SetValueString(nx_int(row), key_list[m], value)
        end
      else
        local row = textgrid:AddRow(key_value)
      end
      return 1
    end
    local child = out:GetChild("ID")
    if nx_is_valid(child) then
      local rule = child.rule
      if is_num_in_range(sect_name, rule) then
        if key_value == "" then
          local row = textgrid:AddRow(sect_name)
          local key_list = file_point:GetItemList(sect_name)
          for m = 1, table.getn(key_list) do
            local value = file_point:ReadString(sect_name, key_list[m], "")
            textgrid:SetValueString(nx_int(row), key_list[m], value)
          end
        else
          local row = textgrid:AddRow(key_value)
        end
      end
      return 1
    end
    local child = out:GetChild("CID")
    if nx_is_valid(child) then
      local rule = child.rule
      local str_list = nx_function("ext_split_string", sect_name, "-")
      if table.getn(str_list) == 2 and 0 < nx_number(str_list[1]) and 0 < nx_number(str_list[2]) and is_num_in_range(nx_number(str_list[2]), rule) then
        if key_value == "" then
          local row = textgrid:AddRow(sect_name)
          local key_list = file_point:GetItemList(sect_name)
          for m = 1, table.getn(key_list) do
            local value = file_point:ReadString(sect_name, key_list[m], "")
            textgrid:SetValueString(nx_int(row), key_list[m], value)
          end
        else
          local row = textgrid:AddRow(key_value)
        end
      end
      return 1
    end
    local id_type, position = get_id_type(get_string_before_number(sect_name))
    if id_type ~= nil then
      local child = out:GetChild(id_type)
      if nx_is_valid(child) then
        local rule = child.rule
        if is_num_in_range(get_compare_number(sect_name, position), rule) then
          if key_value == "" then
            local row = textgrid:AddRow(sect_name)
            local key_list = file_point:GetItemList(sect_name)
            for m = 1, table.getn(key_list) do
              local value = file_point:ReadString(sect_name, key_list[m], "")
              textgrid:SetValueString(nx_int(row), key_list[m], value)
            end
          else
            local row = textgrid:AddRow(key_value)
          end
        end
        return 1
      end
    end
  end
  return 1
end
function catch_rule(data, rule, position)
  local str_list = nx_function("ext_split_string", rule, ";")
  for i = 1, table.getn(str_list) do
    local list = nx_function("ext_split_string", str_list[i], "-")
    if table.getn(list) == 1 then
      if "*" == rule then
        return true
      elseif data == list[1] then
        return true
      end
    elseif 1 < table.getn(list) then
      if position ~= nil then
        data = get_compare_number(data, position)
      end
      if nx_number(list[1]) <= nx_number(data) and nx_number(list[2]) >= nx_number(data) then
        return true
      end
    end
  end
  return false
end
function infiles_list_select_click(self, index)
  local form = self.Parent
  if index < 0 then
    return 0
  end
  local groupbox = self:GetControl(index)
  local rule_config = nx_value("rule_config")
  if nx_is_valid(rule_config) then
    update_outfiles_list(form.outfiles_list, groupbox.info)
  end
  return 1
end
function btn_add_click(self)
  local gui = nx_value("gui")
  local form = self.Parent
  local pictfile_form = nx_value("pictfile_form")
  if not nx_is_valid(pictfile_form) then
    pictfile_form = LOAD_FORM(nx_resource_path(), gui.skin_path .. "\\form_task\\form_pictfile.xml")
    nx_set_value("pictfile_form", pictfile_form)
  end
  pictfile_form.path = form.path
  pictfile_form:ShowModal()
  local res, new_name = nx_wait_event(100000000, pictfile_form, "pictfile_return")
  if res == "cancel" then
    return 0
  end
  if new_name == "" then
    return 0
  end
  local rule_config = nx_value("rule_config")
  if nx_is_valid(rule_config) then
    local item = rule_config:CreateChild(new_name)
    save_rule_config_xml()
  end
  update_infiles_list(form.infiles_list)
  form.outfiles_list:ClearControl()
  return 1
end
function btn_delete_click(self)
  local form = self.Parent
  local controlbox = form.infiles_list
  local index = controlbox.SelectIndex
  if index < 0 then
    return 0
  end
  local groupbox = controlbox:GetControl(index)
  local rule_config = nx_value("rule_config")
  if nx_is_valid(rule_config) then
    rule_config:RemoveChildByID(groupbox.info)
    save_rule_config_xml()
  end
  controlbox:RemoveControl(groupbox)
  form.outfiles_list:ClearControl()
  return 1
end
function save_rule_config_xml()
end
function btn_add_rule_click(self)
  local form = self.Parent
  local controlbox = form.infiles_list
  local index = controlbox.SelectIndex
  if index < 0 then
    return 0
  end
  local groupbox = controlbox:GetControl(index)
  local rule_config = nx_value("rule_config")
  local item = groupbox.info
  if nx_is_valid(item) then
    local child = item:CreateChild("")
    child.outfile = ""
    child.prop = ""
    child.rule = ""
    child.model = "normal"
  else
    nx_msgbox("\212\246\188\211\202\167\176\220")
  end
  update_outfiles_list(form.outfiles_list, item)
  save_rule_config_xml()
  return 1
end
function btn_delete_rule_click(self)
  local form = self.Parent
  local outfiles_index = form.outfiles_list.SelectIndex
  if outfiles_index < 0 then
    return 0
  end
  local groupbox = form.outfiles_list:GetControl(outfiles_index)
  local child = groupbox.info
  local infiles_index = form.infiles_list.SelectIndex
  if infiles_index < 0 then
    return 0
  end
  local groupbox = form.infiles_list:GetControl(infiles_index)
  local item = groupbox.info
  item:RemoveChildByID(child)
  update_outfiles_list(form.outfiles_list, item)
  save_rule_config_xml()
  return 1
end
function btn_change_click(self)
  local form = self.Parent
  local item_count = form.infiles_list.ItemCount
  for i = 0, item_count - 1 do
    local group_item = form.infiles_list:GetControl(i)
    if group_item.ctrl.Checked then
      transform_files(form, group_item.info)
    end
  end
  return 1
end
function load_file_list(form)
  form.file_list:BeginUpdate()
  form.file_list:ClearString()
  form.file_list:AddString(nx_widestr("text\\ChineseS\\stringtask_normal.idres"))
  form.file_list:AddString(nx_widestr("text\\ChineseS\\stringtask_special.idres"))
  form.file_list:EndUpdate()
  return 1
end
function btn_check_click(self)
  local form = self.Parent
  local list = form.pre_list
  list:BeginUpdate()
  list:ClearString()
  for i = 0, form.file_list.ItemCount - 1 do
    local textgrid = nx_create("TextGrid")
    textgrid.FileName = nx_resource_path() .. nx_string(form.file_list:GetString(i))
    if not textgrid:LoadFromFile(2) then
      nx_destroy(textgrid)
      nx_msgbox("\182\193\200\161\206\196\188\254(" .. nx_resource_path() .. nx_string(form.file_list:GetString(i)) .. ")\202\167\176\220")
      return 0
    end
    for j = 0, textgrid.RowCount - 1 do
      local key_value = textgrid:GetValueString(nx_int(j), nx_int(0))
      if key_value ~= "" then
        local begin_index, end_index = string.find(key_value, "=")
        if nil ~= begin_index and 1 ~= begin_index then
          local key = string.sub(key_value, 1, begin_index - 1)
          local pre = get_string_before_number(key)
          if pre ~= "" and -1 == list:FindString(nx_widestr(pre .. "*****\199\176\215\186")) then
            list:AddString(nx_widestr(pre .. "*****\199\176\215\186"))
          end
        else
          local pre = key_value .. "*****\197\228\214\195\211\208\206\243!"
          if -1 == list:FindString(nx_widestr(pre)) then
            list:AddString(nx_widestr(pre))
          end
        end
      end
    end
    nx_destroy(textgrid)
  end
  list:EndUpdate()
  return 1
end
function btn_save_click(self)
  local form = self.Parent
  local list = form.pre_list
  local textgrid = nx_create("TextGrid")
  textgrid.FileName = form.path .. "ini\\Task\\text_pre_file.txt"
  if not textgrid:LoadFromFile(2) then
    nx_msgbox("\180\242\191\170\206\196\188\254(" .. textgrid.FileName .. ")\202\167\176\220")
    return 0
  end
  textgrid:RemoveAllCell()
  for i = 0, list.ItemCount - 1 do
    local value = nx_string(list:GetString(i))
    local str_list = nx_function("ext_split_string", value, "*****")
    local row = textgrid:AddRow(str_list[1])
  end
  if not textgrid:SaveToFile() then
    nx_msgbox(textgrid.FileName .. " - \206\196\188\254\177\163\180\230\180\237\206\243")
    nx_destroy(textgrid)
    return 0
  end
  nx_destroy(textgrid)
  return 1
end
