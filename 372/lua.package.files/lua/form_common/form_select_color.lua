require("utils")
function main_form_init(self)
  self.Fixed = false
  self.color = ""
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  local file_list = self.file_list
  local designer = gui.Designer
  local num = designer:GetResFileCount("color")
  local res_table = designer:GetResFileList("color")
  for i = 1, num do
    local res_file = res_table[i]
    file_list:AddString(nx_widestr(res_file))
  end
  self.color_name_label.Text = nx_widestr("")
  self.alpha_edit.Text = nx_widestr("0")
  self.red_edit.Text = nx_widestr("0")
  self.green_edit.Text = nx_widestr("0")
  self.blue_edit.Text = nx_widestr("0")
  if self.color ~= "" then
    set_current_color(self, self.color)
  end
  return 1
end
function ok_btn_click(self)
  local form = self.Parent
  local color = nx_string(form.color_name_label.Text)
  form:Close()
  nx_gen_event(form, "select_color_return", "ok", color)
  nx_destroy(form)
  return 1
end
function cancel_btn_click(self)
  local form = self.Parent
  form:Close()
  nx_gen_event(form, "select_color_return", "cancel")
  nx_destroy(form)
  return 1
end
function add_file_btn_click(self)
  local gui = nx_value("gui")
  local form = gui.Loader:LoadForm(nx_resource_path(), "skin_editor\\form_filename.xml")
  form.title_label.Text = nx_widestr("\209\161\212\241\209\213\201\171\206\196\188\254")
  form.path = gui.Designer.DefaultPath
  form.file = "*.xml"
  form:ShowModal()
  local res, filename = nx_wait_event(100000000, form, "filename_return")
  if res == "cancel" then
    return 0
  end
  if not nx_file_exists(gui.DefaultPath .. filename) then
    disp_error("\206\196\188\254\178\187\180\230\212\218")
    return 0
  end
  local file_list = self.Parent.file_list
  if file_list:FindString(nx_widestr(filename)) ~= -1 then
    disp_error("\178\187\191\201\214\216\184\180\204\237\188\211\206\196\188\254")
    return 0
  end
  if not gui.Designer:AddResFile("color", filename) then
    disp_error("\188\211\212\216\209\213\201\171\215\202\212\180\206\196\188\254\202\167\176\220")
    return 0
  end
  file_list:AddString(nx_widestr(filename))
  resource_changed()
  return 1
end
function remove_file_btn_click(self)
  local gui = nx_value("gui")
  local file_list = self.Parent.file_list
  if file_list.SelectIndex == -1 then
    return 0
  end
  local filename = nx_string(file_list.SelectString)
  if filename == "" then
    return 0
  end
  local form = gui.Loader:LoadForm(nx_resource_path(), "skin_editor\\form_confirm.xml")
  form.info_label.Text = nx_widestr("\200\183\202\181\210\170\210\198\179\253\209\213\201\171\206\196\188\254[" .. filename .. "]\194\240\163\191")
  form:ShowModal()
  local res = nx_wait_event(100000000, form, "confirm_return")
  if res == "cancel" then
    return 0
  end
  if not gui.Designer:RemoveResFile("color", filename) then
    disp_error("\210\198\179\253\209\213\201\171\215\202\212\180\206\196\188\254\202\167\176\220")
    return 0
  end
  if nx_string(file_list.SelectString) == filename then
    self.Parent.res_list:ClearString()
  end
  file_list:RemoveString(nx_widestr(filename))
  resource_changed()
  return 1
end
function color_btn_click(self)
  local form = self.Parent
  local gui = nx_value("gui")
  local dialog = gui.Loader:LoadForm(nx_resource_path(), "skin_editor\\form_set_color.xml")
  dialog.alpha = form.alpha_track.Value
  dialog.red = form.red_track.Value
  dialog.green = form.green_track.Value
  dialog.blue = form.blue_track.Value
  dialog:ShowModal()
  local res, alpha, red, green, blue = nx_wait_event(100000000, dialog, "set_color_return")
  if res == "cancel" then
    return 0
  end
  form.alpha_track.Value = alpha
  form.red_track.Value = red
  form.green_track.Value = green
  form.blue_track.Value = blue
  return 1
end
function file_select_changed(self, old)
  local gui = nx_value("gui")
  local filename = gui.Designer.DefaultPath .. nx_string(self.SelectString)
  local doc = nx_create("XmlDocument")
  if not doc:LoadFile(filename) then
    nx_destroy(doc)
    return 0
  end
  local res_list = self.Parent.res_list
  res_list:ClearString()
  local node_table = doc.RootElement:GetChildList("color")
  local node_num = table.getn(node_table)
  for i = 1, node_num do
    local element = node_table[i]
    local name = element:QueryAttr("name")
    if name ~= "" then
      res_list:AddString(nx_widestr(name))
    end
  end
  nx_destroy(doc)
  return 1
end
function res_select_changed(self, old)
  local name = nx_string(self.SelectString)
  if name == "" then
    return 0
  end
  set_current_color(self.Parent, name)
  return 1
end
function set_current_color(form, color)
  local gui = nx_value("gui")
  form.preview_group.BackColor = color
  form.color_name_label.Text = nx_widestr(color)
  local designer = gui.Designer
  local alpha = designer:GetColorAlpha(color)
  local red = designer:GetColorRed(color)
  local green = designer:GetColorGreen(color)
  local blue = designer:GetColorBlue(color)
  form.alpha_edit.Text = nx_widestr(alpha)
  form.red_edit.Text = nx_widestr(red)
  form.green_edit.Text = nx_widestr(green)
  form.blue_edit.Text = nx_widestr(blue)
  form.alpha_track.Value = alpha
  form.red_track.Value = red
  form.green_track.Value = green
  form.blue_track.Value = blue
  return 1
end
function update_sample_color(form)
  local color = nx_string(form.alpha_edit.Text) .. "," .. nx_string(form.red_edit.Text) .. "," .. nx_string(form.green_edit.Text) .. "," .. nx_string(form.blue_edit.Text)
  form.preview_group.BackColor = color
  form.color_name_label.Text = nx_widestr(color)
end
function alpha_value_changed(self)
  self.Parent.alpha_edit.Text = nx_widestr(self.Value)
  update_sample_color(self.Parent)
  return 1
end
function red_value_changed(self)
  self.Parent.red_edit.Text = nx_widestr(self.Value)
  update_sample_color(self.Parent)
  return 1
end
function green_value_changed(self)
  self.Parent.green_edit.Text = nx_widestr(self.Value)
  update_sample_color(self.Parent)
  return 1
end
function blue_value_changed(self)
  self.Parent.blue_edit.Text = nx_widestr(self.Value)
  update_sample_color(self.Parent)
  return 1
end
function alpha_drag_leave(self)
  self.Parent.alpha_edit.Text = nx_widestr(self.Value)
  update_sample_color(self.Parent)
  return 1
end
function red_drag_leave(self)
  self.Parent.red_edit.Text = nx_widestr(self.Value)
  update_sample_color(self.Parent)
  return 1
end
function green_drag_leave(self)
  self.Parent.green_edit.Text = nx_widestr(self.Value)
  update_sample_color(self.Parent)
  return 1
end
function blue_drag_leave(self)
  self.Parent.blue_edit.Text = nx_widestr(self.Value)
  update_sample_color(self.Parent)
  return 1
end
function alpha_edit_lost_focus(self)
  local num = nx_number(self.Text)
  if num < 0 then
    num = 0
  end
  if 255 < num then
    num = 255
  end
  self.Text = nx_widestr(num)
  self.Parent.alpha_track.Value = num
  update_sample_color(self.Parent)
  return 1
end
function red_edit_lost_focus(self)
  local num = nx_number(self.Text)
  if num < 0 then
    num = 0
  end
  if 255 < num then
    num = 255
  end
  self.Text = nx_widestr(num)
  self.Parent.red_track.Value = num
  update_sample_color(self.Parent)
  return 1
end
function green_edit_lost_focus(self)
  local num = nx_number(self.Text)
  if num < 0 then
    num = 0
  end
  if 255 < num then
    num = 255
  end
  self.Text = nx_widestr(num)
  self.Parent.green_track.Value = num
  update_sample_color(self.Parent)
  return 1
end
function blue_edit_lost_focus(self)
  local num = nx_number(self.Text)
  if num < 0 then
    num = 0
  end
  if 255 < num then
    num = 255
  end
  self.Text = nx_widestr(num)
  self.Parent.blue_track.Value = num
  update_sample_color(self.Parent)
  return 1
end
