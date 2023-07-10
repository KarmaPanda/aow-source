require("utils")
require("util_functions")
function main_form_init(self)
  self.Fixed = false
  self.color = ""
  self.font = ""
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  local designer = gui.Designer
  local num = designer:GetResFileCount("font")
  local res_table = designer:GetResFileList("font")
  for i = 1, num do
    local res_file = res_table[i]
    file_list:AddString(nx_widestr(res_file))
  end
  file_select_changed(self, "res_font.xml")
  self.font_name_label.Text = nx_widestr("")
  if self.font ~= "" then
    self.font_name_label.Text = nx_widestr(self.font)
  end
  self.color_name_label.Text = nx_widestr("")
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
  local res_list = form.res_list
  form:Close()
  nx_gen_event(form, "select_font_return", "ok", nx_string(res_list.SelectString), form.color)
  nx_destroy(form)
  return 1
end
function cancel_btn_click(self)
  local form = self.Parent
  form:Close()
  nx_gen_event(form, "select_font_return", "cancel")
  nx_destroy(form)
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
  local form = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = nx_widestr(util_text("ui_SureToDeleteFontFileX") .. nx_widestr(filename) .. util_text("ui_TanCiMa"))
  nx_execute("form_common\\form_confirm", "show_common_text", form, text)
  form:ShowModal()
  local res = nx_wait_event(100000000, form, "confirm_return")
  if res == "cancel" then
    return 0
  end
  if not gui.Designer:RemoveResFile("font", filename) then
    disp_error(util_text("ui_DeleteFontFileFailed"))
    return 0
  end
  if nx_string(file_list.SelectString) == filename then
    self.Parent.res_list:ClearString()
  end
  file_list:RemoveString(nx_widestr(filename))
  resource_changed()
  return 1
end
function file_select_changed(self, filename)
  local form = self
  local gui = nx_value("gui")
  local filepath = gui.Designer.DefaultPath .. "skin\\" .. filename
  local doc = nx_create("XmlDocument")
  if not doc:LoadFile(filepath) then
    nx_destroy(doc)
    return 0
  end
  local res_list = form.res_list
  res_list:ClearString()
  local node_table = doc.RootElement:GetChildList("font")
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
  local sample = self.Parent.sample_label
  sample.Font = name
  self.Parent.font_name_label.Text = nx_widestr(name)
  return 1
end
function update_sample_color(form)
  local color = nx_string(255) .. "," .. nx_string(form.red_edit.Text) .. "," .. nx_string(form.green_edit.Text) .. "," .. nx_string(form.blue_edit.Text)
  form.color_name_label.Text = nx_widestr(color)
  form.sample_label.ForeColor = color
  form.color = color
end
function set_current_color(form, color)
  local gui = nx_value("gui")
  form.sample_label.ForeColor = color
  form.color_name_label.Text = nx_widestr(color)
  local designer = gui.Designer
  local red = designer:GetColorRed(color)
  local green = designer:GetColorGreen(color)
  local blue = designer:GetColorBlue(color)
  form.red_edit.Text = nx_widestr(red)
  form.green_edit.Text = nx_widestr(green)
  form.blue_edit.Text = nx_widestr(blue)
  form.red_track.Value = red
  form.green_track.Value = green
  form.blue_track.Value = blue
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
