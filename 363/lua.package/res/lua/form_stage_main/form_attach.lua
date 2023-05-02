require("util_gui")
require("util_functions")
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_form_active(self)
  local owner_form = self.owner_form
  nx_execute("util_gui", "ui_bring_attach_form_to_front", owner_form)
end
function on_main_form_visible(self)
  local ini = get_attach_ini()
  if not nx_is_valid then
    return
  end
  local form = self.ParentForm
  if not nx_find_custom(form, "owner_form") then
    return
  end
  local owner_form = form.owner_form
  local master_name = owner_form.Name
  if ini:FindItem("AutoAttach", master_name) then
    return
  end
  form.cbtn_hide.Checked = true
end
function on_btn_close_click(self)
  local form = self.ParentForm
  if nx_find_custom(form, "owner_form") then
    local owner_form = form.owner_form
    owner_form.btn_help.Checked = not owner_form.btn_help.Checked
  end
end
function on_mltbox_info_click_hyperlink(self, index, data)
  data = nx_string(data)
  nx_execute("form_stage_main\\form_helper\\form_theme_helper", "util_open_theme", data)
end
function update_attach_form(form)
  if not nx_find_custom(form, "owner_form") then
    return
  end
  local owner_form = form.owner_form
  local master_name = owner_form.Name
  local ini = nx_execute("util_functions", "get_ini", "ini\\attach_form.ini")
  if not nx_is_valid(ini) then
    return
  end
  local title_id = "ui_attach_hint"
  local info_id = ""
  local sect_index = ini:FindSectionIndex(master_name)
  if 0 <= sect_index then
    info_id = ini:ReadString(sect_index, "info", "")
  end
  local gui = nx_value("gui")
  form.lbl_tittle.Text = gui.TextManager:GetText(title_id)
  form.mltbox_info:Clear()
  local info_id_list = util_split_string(info_id, ";")
  for _, str_id in ipairs(info_id_list) do
    form.mltbox_info:AddHtmlText(gui.TextManager:GetText(str_id), -1)
  end
  form.mltbox_info.VScrollBar.Value = 0
  local ini = get_attach_ini()
  if nx_is_valid(ini) then
    form.cbtn_hide.Checked = 1 == ini:ReadInteger("AutoAttach", master_name, 0)
  end
end
function on_cbtn_hide_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "owner_form") then
    return
  end
  local owner_form = form.owner_form
  local master_name = owner_form.Name
  local ini = get_attach_ini()
  if nx_is_valid(ini) then
    ini:WriteInteger("AutoAttach", master_name, self.Checked)
    ini:SaveToFile()
  end
end
